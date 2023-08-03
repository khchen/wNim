#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This control may be used to render web (HTML / CSS / javascript) documents.
## As an embedded internet explorer, you can use getComObject() to get a
## winim COM object with IWebBrowser2 interface and then do a lot of thing on it.
## For example, manipulate DOM, call javascript function, and so on.
##
## By default, the control runs in compatibility view mode (IE7). To change the
## compatibility mode, you need to deal with the registry key:
## `FEATURE_BROWSER_EMULATION <https://www.google.com/search?q=FEATURE_BROWSER_EMULATION>`_.
##
## Notice: wWebView is always re-enabled before wEvent_WebViewLoaded event.
## If you need a disabled control, disable it again in the event handler
## of wEvent_WebViewLoaded.
#
## :Appearance:
##   .. image:: images/wWebView.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wWvNoSel                        Does not enable selection of the text.
##   wWvNoScroll                     Does not have scroll bars.
##   wWvNoContextMenu                Does not have context menus.
##   wWvNoFocus                      Does not receive focus.
##   wWvSilent                       Does not display dialog boxes (script error, etc.).
##   ==============================  =============================================================
#
## :Events:
##   `wWebViewEvent <wWebViewEvent.html>`_

include ../pragma
import ../wBase, wControl
export wControl

converter converterVariantPtrToVar(p: ptr VARIANT): var VARIANT = cast[var VARIANT](p)

const
  wWvNoSel* = 1
  wWvNoScroll* = 2
  wWvNoContextMenu* = 4
  wWvNoFocus* = 8
  wWvSilent* = 16
  wWebViewClassName = "wWebViewClass"

type
  wWebViewError* = object of wError
    ## An error raised when webview operation failure.

  wWeb {.pure.} = object
    view: wWebView
    hwnd: HWND
    hwndIe: HWND
    style: DWORD
    canGoBack: bool
    canGoForward: bool
    focusd: bool
    cookie: DWORD
    refs: LONG
    ole: ptr IOleObject
    browser: ptr IWebBrowser2
    dispatch: IDispatch
    clientSite: IOleClientSite
    inPlaceSiteEx: IOleInPlaceSiteEx
    inPlaceFrame: IOleInPlaceFrame
    uiHandler: IDocHostUIHandler

template wWebBase(web, member): ptr wWeb =
  cast[ptr wWeb](cast[int](web) - objectOffset(wWeb, member))

proc AddRef(web: ptr wWeb): ULONG {.discardable.} =
  discard InterlockedIncrement(&web.refs)
  result = web.refs

proc Release(web: ptr wWeb): ULONG  {.discardable.} =
  discard InterlockedDecrement(&web.refs)
  result = web.refs
  if result == 0:
    dealloc(web)

proc QueryInterface(web: ptr wWeb, riid: REFIID, ppvObject: ptr pointer): HRESULT {.discardable.} =
  if ppvObject.isNil:
    return E_POINTER

  elif IsEqualIID(riid, &IID_IUnknown):
    ppvObject[] = &web.dispatch

  elif IsEqualIID(riid, &IID_IDispatch) or
      IsEqualIID(riid, &DIID_DWebBrowserEvents) or
      IsEqualIID(riid, &DIID_DWebBrowserEvents2):
    ppvObject[] = &web.dispatch

  elif IsEqualIID(riid, &IID_IOleClientSite):
    ppvObject[] = &web.clientSite

  elif IsEqualIID(riid, &IID_IOleWindow) or
      IsEqualIID(riid, &IID_IOleInPlaceSite) or
      IsEqualIID(riid, &IID_IOleInPlaceSiteEx):
    ppvObject[] = &web.inPlaceSiteEx

  elif IsEqualIID(riid, &IID_IOleInPlaceFrame):
    ppvObject[] = &web.inPlaceFrame

  elif IsEqualIID(riid, &IID_IDocHostUIHandler):
    ppvObject[] = &web.uiHandler

  else:
    ppvObject[] = nil
    return E_NOINTERFACE

  web.AddRef()
  return S_OK

proc wWebViewSetFocus(web: ptr wWeb) =
  # https://cboard.cprogramming.com/windows-programming/131015-setting-focus-iwebbrowser2.html
  if (web.style and wWvNoFocus) != 0: return
  SetFocus(web.hwndIe)
  if not web.focusd:
    let backStyle = web.style
    defer: web.style = backStyle

    # don't use left button, it click something accidentally
    web.style = web.style or wWvNoContextMenu
    SendMessage(web.hwndIe, WM_RBUTTONDOWN, 0, 0)
    SendMessage(web.hwndIe, WM_RBUTTONUP, 0, 0)
    web.focusd = true

proc wWebViewSubClass(web: ptr wWeb) =

  proc processKeyMessage(web: ptr wWeb, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool =
    # We deal with the key message in subclass proc instead of main loop,
    # make a fake MSG object

    let pos = GetMessagePos()
    var message = MSG(hwnd: web.hwnd, message: msg, wParam: wParam, lParam: lParam)
    message.time = GetMessageTime()
    message.pt.x = GET_X_LPARAM(pos)
    message.pt.y = GET_Y_LPARAM(pos)

    # if it's wNim's accelerator key?
    if wAppProcessAcceleratorMessage(message) > 0:
      return true

    message.hwnd = web.hwndIe

    # let embedded browser deal with this key
    var active: ptr IOleInPlaceActiveObject
    if web.browser.QueryInterface(&IID_IOleInPlaceActiveObject, &active).FAILED or
        active == nil: return false
    defer: active.Release()

    if active.TranslateAccelerator(&message) == S_OK:
      return true

  proc wSubExplorerProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM,
      uIdSubclass: UINT_PTR, dwRefData: DWORD_PTR): LRESULT {.stdcall.} =

    let web = cast[ptr wWeb](dwRefData)

    # let wWebView's event hander can process message of IE's window
    # only mosue and key message for now, need more?

    if web.view != nil:
      if msg in WM_MOUSEFIRST..WM_MOUSELAST or msg in WM_KEYFIRST..WM_KEYLAST:
        if web.view.processMessage(msg, wParam, lParam, result):
          return result

    if msg == WM_NCDESTROY:
      RemoveWindowSubclass(hwnd, wSubExplorerProc, uIdSubclass)
      web.Release()

    elif msg in WM_KEYFIRST..WM_KEYLAST:
      if web.processKeyMessage(msg, wParam, lParam):
        return 0

    elif msg == WM_SETFOCUS:
      if (web.style and wWvNoFocus) != 0:
        # give focus back to who has lost focus
        SetFocus(HWND wParam)
        return 0

    return DefSubclassProc(hwnd, msg, wParam, lParam)

  proc findExplorerWindow(win: HWND): HWND =
    let hwnd = FindWindowEx(win, 0, "Internet Explorer_Server", nil)
    if hwnd != 0: return hwnd

    var win = GetWindow(win, GW_CHILD)
    while win != 0:
      let hwnd = findExplorerWindow(win)
      if hwnd != 0: return hwnd
      win = GetWindow(win, GW_HWNDNEXT)

  # here we subclass the embedded browser's hwnd to deal with the key messaage
  if web.hwndIe == 0:
    web.hwndIe = findExplorerWindow(web.hwnd)
    if web.hwndIe != 0:
      web.AddRef()
      SetWindowSubclass(web.hwndIe, wSubExplorerProc, cast[UINT_PTR](web), cast[DWORD_PTR](web))

      if GetFocus() == web.hwnd:
        web.wWebViewSetFocus()

proc initDispatchVtbl(): ptr IDispatchVtbl =
  template WEB: ptr wWeb = self.wWebBase(dispatch)

  var vtbl {.global.}: IDispatchVtbl
  result = addr vtbl
  if result.QueryInterface != nil: return

  vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
    WEB.QueryInterface(riid, ppvObject)

  vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.AddRef()

  vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.Release()

  vtbl.GetTypeInfoCount = proc(self: ptr IDispatch, pctinfo: ptr UINT): HRESULT {.stdcall.} =
    pctinfo[] = 0
    return S_OK

  vtbl.GetTypeInfo = proc(self: ptr IDispatch, iTInfo: UINT, lcid: LCID, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.} =
    ppTInfo[] = nil
    return TYPE_E_ELEMENTNOTFOUND

  vtbl.GetIDsOfNames = proc(self: ptr IDispatch, riid: REFIID, rgszNames: ptr LPOLESTR, cNames: UINT, lcid: LCID, rgDispId: ptr DISPID): HRESULT {.stdcall.} =
    for i in 0..<cNames:
      let arr = cast[ptr UncheckedArray[DISPID]](rgDispId)
      arr[i] = DISPID_UNKNOWN
    return DISP_E_UNKNOWNNAME

  vtbl.Invoke = proc(self: ptr IDispatch, dispIdMember: DISPID, riid: REFIID, lcid: LCID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.stdcall.} =
    let
      args = cast[ptr UncheckedArray[VARIANT]](pDispParams.rgvarg)
      web = WEB

    # remove codes about avoiding stealing focus
    #  -> not always work and induce strange result sometimes

    case dispIdMember
    of DISPID_BEFORENAVIGATE2:
      let
        win = web.view
        url = $args[5].pvarVal.bstrVal
        cancel = args[0].pboolVal
        event = wWebViewEvent Event(window=win, msg=wEvent_WebViewNavigating)

      assert win != nil
      event.mUrl = url
      if win.processEvent(event) and not event.isAllowed:
        cancel[] = VARIANT_TRUE

    of DISPID_NAVIGATECOMPLETE2:
      # subclass the embedded browser asap.
      WEB.wWebViewSubClass()

    of DISPID_NAVIGATEERROR:
      let
        win = web.view
        url = $args[3].pvarVal.bstrVal
        status = args[1].pvarVal.lVal
        cancel = args[0].pboolVal
        event = wWebViewEvent Event(window=win, msg=wEvent_WebViewError)

      assert win != nil
      event.mUrl = url
      event.mLparam = LPARAM status
      if win.processEvent(event) and not event.isAllowed:
        cancel[] = VARIANT_TRUE

    of DISPID_PROGRESSCHANGE:
      let
        win = WEB.view
        progressMax = args[0].lVal
        progress = args[1].lVal

      assert win != nil
      if progress < 0 or progressMax < 0:
        let event = Event(window=win, msg=wEvent_WebViewLoaded)
        win.processEvent(event)

    of DISPID_STATUSTEXTCHANGE:
      let
        win = WEB.view
        text = $args[0].bstrVal
        event = wWebViewEvent Event(window=win, msg=wEvent_WebViewStatusChanged)

      assert win != nil
      event.mText = text
      win.processEvent(event)

    of DISPID_TITLECHANGE:
      let
        win = WEB.view
        text = $args[0].bstrVal
        event = wWebViewEvent Event(window=win, msg=wEvent_WebViewTitleChanged)

      assert win != nil
      event.mText = text
      win.processEvent(event)

    of DISPID_COMMANDSTATECHANGE:
      let
        cmd = args[1].lVal
        enabled = args[0].boolVal
      var changed = false

      if cmd == CSC_NAVIGATEBACK:
        if (enabled != 0) != web.canGoBack:
          changed = true
          web.canGoBack = not web.canGoBack

      elif cmd == CSC_NAVIGATEFORWARD:
        if (enabled != 0) != web.canGoForward:
          changed = true
          web.canGoForward = not web.canGoForward

      if changed:
        let
          win = WEB.view
          event = wWebViewEvent Event(window=win, msg=wEvent_WebViewHistoryChanged)

        assert win != nil
        win.processEvent(event)

    of DISPID_NEWWINDOW2:
      let
        win = WEB.view
        cancel = args[0].pboolVal
        event = wWebViewEvent Event(window=win, msg=wEvent_WebViewNewWindow)

      assert win != nil
      if win.processEvent(event) and not event.isAllowed:
        cancel[] = VARIANT_TRUE

    of DISPID_NEWWINDOW3:
      let
        win = WEB.view
        url = $args[0].bstrVal
        cancel = args[3].pboolVal
        event = wWebViewEvent Event(window=win, msg=wEvent_WebViewNewWindow)

      assert win != nil
      event.mUrl = url
      if win.processEvent(event) and not event.isAllowed:
        cancel[] = VARIANT_TRUE

    else:
      return DISP_E_MEMBERNOTFOUND

    return S_OK

proc initClientSiteVtbl(): ptr IOleClientSiteVtbl =
  template WEB: ptr wWeb = self.wWebBase(clientSite)

  var vtbl {.global.}: IOleClientSiteVtbl
  result = addr vtbl
  if vtbl.QueryInterface != nil: return

  vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
    WEB.QueryInterface(riid, ppvObject)

  vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.AddRef()

  vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.Release()

  vtbl.SaveObject = proc(self: ptr IOleClientSite): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.GetMoniker = proc(self: ptr IOleClientSite, dwAssign: DWORD, dwWhichMoniker: DWORD, ppmk: ptr ptr IMoniker): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.GetContainer = proc(self: ptr IOleClientSite, ppContainer: ptr ptr IOleContainer): HRESULT {.stdcall.} =
    ppContainer[] = nil
    return E_NOINTERFACE

  vtbl.ShowObject = proc(self: ptr IOleClientSite): HRESULT {.stdcall.} =
    return S_OK

  vtbl.OnShowWindow = proc(self: ptr IOleClientSite, fShow: WINBOOL): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.RequestNewObjectLayout = proc(self: ptr IOleClientSite): HRESULT {.stdcall.} =
    return E_NOTIMPL

proc initInPlaceSiteExVtbl(): ptr IOleInPlaceSiteExVtbl =
  template WEB: ptr wWeb = self.wWebBase(inPlaceSiteEx)

  var vtbl {.global.}: IOleInPlaceSiteExVtbl
  result = addr vtbl
  if vtbl.QueryInterface != nil: return

  vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
    WEB.QueryInterface(riid, ppvObject)

  vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.AddRef()

  vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.Release()

  vtbl.GetWindow = proc(self: ptr IOleWindow, phwnd: ptr HWND): HRESULT {.stdcall.} =
    phwnd[] = WEB.hwnd
    return S_OK

  vtbl.ContextSensitiveHelp = proc(self: ptr IOleWindow, fEnterMode: WINBOOL): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.CanInPlaceActivate = proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.} =
    return S_OK

  vtbl.OnInPlaceActivate = proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.} =
    return S_OK

  vtbl.OnUIActivate = proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.} =
    return S_OK

  vtbl.GetWindowContext = proc(self: ptr IOleInPlaceSite, ppFrame: ptr ptr IOleInPlaceFrame, ppDoc: ptr ptr IOleInPlaceUIWindow, lprcPosRect: LPRECT, lprcClipRect: LPRECT, lpFrameInfo: LPOLEINPLACEFRAMEINFO): HRESULT {.stdcall.} =
    let web = WEB
    ppFrame[] = &web.inPlaceFrame
    ppFrame[].AddRef()
    ppDoc[] = nil
    lpFrameInfo.fMDIApp = FALSE
    lpFrameInfo.hwndFrame = GetAncestor(web.hwnd, GA_ROOT)
    lpFrameInfo.haccel = 0
    lpFrameInfo.cAccelEntries = 0
    GetClientRect(web.hwnd, lprcPosRect)
    GetClientRect(web.hwnd, lprcClipRect)
    return S_OK

  vtbl.Scroll = proc(self: ptr IOleInPlaceSite, scrollExtant: SIZE): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.OnUIDeactivate = proc(self: ptr IOleInPlaceSite, fUndoable: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.OnInPlaceDeactivate = proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.} =
    return S_OK

  vtbl.DiscardUndoState = proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.DeactivateAndUndo = proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.OnPosRectChange = proc(self: ptr IOleInPlaceSite, lprcPosRect: LPCRECT): HRESULT {.stdcall.} =
    var inPlace: ptr IOleInPlaceObject
    if WEB.ole.QueryInterface(&IID_IOleInPlaceObject, &inPlace).FAILED or
        inPlace == nil:
      return E_UNEXPECTED

    inPlace.SetObjectRects(lprcPosRect, lprcPosRect)
    inPlace.Release()
    return S_OK

  vtbl.OnInPlaceActivateEx = proc(self: ptr IOleInPlaceSiteEx, pfNoRedraw: ptr WINBOOL, dwFlags: DWORD): HRESULT {.stdcall.} =
    pfNoRedraw[] = TRUE
    return S_OK

  vtbl.OnInPlaceDeactivateEx = proc(self: ptr IOleInPlaceSiteEx, fNoRedraw: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.RequestUIActivate = proc(self: ptr IOleInPlaceSiteEx): HRESULT {.stdcall.} =
    return S_OK

proc initInPlaceFrameVtbl(): ptr IOleInPlaceFrameVtbl =
  template WEB: ptr wWeb = self.wWebBase(inPlaceFrame)

  var vtbl {.global.}: IOleInPlaceFrameVtbl
  result = addr vtbl
  if vtbl.QueryInterface != nil: return

  vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
    WEB.QueryInterface(riid, ppvObject)

  vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.AddRef()

  vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.Release()

  vtbl.GetWindow = proc(self: ptr IOleWindow, phwnd: ptr HWND): HRESULT {.stdcall.} =
    phwnd[] = GetAncestor(WEB.hwnd, GA_ROOT)
    return S_OK

  vtbl.ContextSensitiveHelp = proc(self: ptr IOleWindow, fEnterMode: WINBOOL): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.GetBorder = proc(self: ptr IOleInPlaceUIWindow, lprectBorder: LPRECT): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.RequestBorderSpace = proc(self: ptr IOleInPlaceUIWindow, pborderwidths: LPCBORDERWIDTHS): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.SetBorderSpace = proc(self: ptr IOleInPlaceUIWindow, pborderwidths: LPCBORDERWIDTHS): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.SetActiveObject = proc(self: ptr IOleInPlaceUIWindow, pActiveObject: ptr IOleInPlaceActiveObject, pszObjName: LPCOLESTR): HRESULT {.stdcall.} =
    return S_OK

  vtbl.InsertMenus = proc(self: ptr IOleInPlaceFrame, hmenuShared: HMENU, lpMenuWidths: LPOLEMENUGROUPWIDTHS): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.SetMenu = proc(self: ptr IOleInPlaceFrame, hmenuShared: HMENU, holemenu: HOLEMENU, hwndActiveObject: HWND): HRESULT {.stdcall.} =
    return S_OK

  vtbl.RemoveMenus = proc(self: ptr IOleInPlaceFrame, hmenuShared: HMENU): HRESULT {.stdcall.} =
    return E_NOTIMPL

  vtbl.SetStatusText = proc(self: ptr IOleInPlaceFrame, pszStatusText: LPCOLESTR): HRESULT {.stdcall.} =
    return S_OK

  vtbl.EnableModeless = proc(self: ptr IOleInPlaceFrame, fEnable: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.TranslateAccelerator = proc(self: ptr IOleInPlaceFrame, lpmsg: LPMSG, wID: WORD): HRESULT {.stdcall.} =
    return E_NOTIMPL

proc initUiHandlerVtbl(): ptr IDocHostUIHandlerVtbl =
  template WEB: ptr wWeb = self.wWebBase(uiHandler)

  var vtbl {.global.}: IDocHostUIHandlerVtbl
  result = addr vtbl
  if vtbl.QueryInterface != nil: return

  vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
    WEB.QueryInterface(riid, ppvObject)

  vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.AddRef()

  vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    WEB.Release()

  vtbl.ShowContextMenu = proc(self: ptr IDocHostUIHandler, dwID: DWORD, ppt: ptr POINT, pcmdtReserved: ptr IUnknown, pdispReserved: ptr IDispatch): HRESULT {.stdcall.}  =
    let style = WEB.style
    if (style and wWvNoContextMenu) != 0:
      return S_OK

    let win = WEB.view
    assert win != nil

    let event = wWebViewEvent Event(window=win, msg=wEvent_WebViewContextMenu)
    if win.processEvent(event) and not event.isAllowed:
      return S_OK

    return S_FALSE

  vtbl.GetHostInfo = proc(self: ptr IDocHostUIHandler, pInfo: ptr DOCHOSTUIINFO): HRESULT {.stdcall.} =
    let style = WEB.style
    zeroMem(pInfo, sizeof(DOCHOSTUIINFO))
    pInfo.cbSize = sizeof(DOCHOSTUIINFO)
    pInfo.dwFlags = DOCHOSTUIFLAG_NO3DOUTERBORDER or DOCHOSTUIFLAG_THEME

    if (style and wWvNoSel) != 0:
      pInfo.dwFlags = pInfo.dwFlags or DOCHOSTUIFLAG_DIALOG

    if (style and wWvNoScroll) != 0:
      pInfo.dwFlags = pInfo.dwFlags or DOCHOSTUIFLAG_SCROLL_NO

    return S_OK

  vtbl.ShowUI = proc(self: ptr IDocHostUIHandler, dwID: DWORD, pActiveObject: ptr IOleInPlaceActiveObject, pCommandTarget: ptr IOleCommandTarget, pFrame: ptr IOleInPlaceFrame, pDoc: ptr IOleInPlaceUIWindow): HRESULT {.stdcall.} =
    return S_OK

  vtbl.HideUI = proc(self: ptr IDocHostUIHandler): HRESULT {.stdcall.} =
    return S_OK

  vtbl.UpdateUI = proc(self: ptr IDocHostUIHandler): HRESULT {.stdcall.} =
    return S_OK

  vtbl.EnableModeless = proc(self: ptr IDocHostUIHandler, fEnable: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.OnDocWindowActivate = proc(self: ptr IDocHostUIHandler, fActivate: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.OnFrameWindowActivate = proc(self: ptr IDocHostUIHandler, fActivate: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.ResizeBorder = proc(self: ptr IDocHostUIHandler, prcBorder: LPCRECT, pUIWindow: ptr IOleInPlaceUIWindow, fRameWindow: WINBOOL): HRESULT {.stdcall.} =
    return S_OK

  vtbl.TranslateAccelerator = proc(self: ptr IDocHostUIHandler, lpMsg: LPMSG, pguidCmdGroup: ptr GUID, nCmdID: DWORD): HRESULT {.stdcall.} =
    return S_FALSE

  vtbl.GetOptionKeyPath = proc(self: ptr IDocHostUIHandler, pchKey: ptr LPOLESTR, dw: DWORD): HRESULT {.stdcall.} =
    pchKey[] = nil
    return E_NOTIMPL

  vtbl.GetDropTarget = proc(self: ptr IDocHostUIHandler, pDropTarget: ptr IDropTarget, ppDropTarget: ptr ptr IDropTarget): HRESULT {.stdcall.} =
    ppDropTarget[] = nil
    return E_NOTIMPL

  vtbl.GetExternal = proc(self: ptr IDocHostUIHandler, ppDispatch: ptr ptr IDispatch): HRESULT {.stdcall.} =
    ppDispatch[] = nil
    return E_NOTIMPL

  vtbl.TranslateUrl = proc(self: ptr IDocHostUIHandler, dwTranslate: DWORD, pchURLIn: LPWSTR, ppchURLOut: ptr LPWSTR): HRESULT {.stdcall.} =
    ppchURLOut[] = nil
    return S_FALSE

  vtbl.FilterDataObject = proc(self: ptr IDocHostUIHandler, pDO: ptr IDataObject, ppDORet: ptr ptr IDataObject): HRESULT {.stdcall.} =
    ppDORet[] = nil
    return S_FALSE

proc wWebViewClassInit(className: string) =

  proc allocWeb(hwnd: HWND, style: LONG): ptr wWeb =
    result = cast[ptr wWeb](alloc0(sizeof(wWeb)))
    if result != nil:
      result.refs = 1
      result.dispatch.lpVtbl = initDispatchVtbl()
      result.clientSite.lpVtbl = initClientSiteVtbl()
      result.inPlaceSiteEx.lpVtbl = initInPlaceSiteExVtbl()
      result.inPlaceFrame.lpVtbl = initInPlaceFrameVtbl()
      result.uiHandler.lpVtbl = initUiHandlerVtbl()
      result.hwnd = hwnd
      result.style = style

  proc init(web: ptr wWeb): bool =
    if CoCreateInstance(&CLSID_WebBrowser, NULL, CLSCTX_INPROC_SERVER or
        CLSCTX_INPROC_HANDLER, &IID_IOleObject, &web.ole).FAILED: return false

    if web.ole.QueryInterface(&IID_IWebBrowser2, &web.browser).FAILED or
        web.browser == nil:
      return false

    if web.ole.SetClientSite(&web.clientSite).FAILED:
      return false

    var rect: RECT
    GetClientRect(web.hwnd, &rect)

    if web.ole.DoVerb(OLEIVERB_INPLACEACTIVATE, nil, &web.clientSite, 0,
        web.hwnd, &rect).FAILED: return false

    var container: ptr IConnectionPointContainer
    if web.ole.QueryInterface(&IID_IConnectionPointContainer, &container).FAILED or
        container == nil:
      return false

    defer: container.Release()

    var point: ptr IConnectionPoint
    if container.FindConnectionPoint(&DIID_DWebBrowserEvents2, &point).FAILED or
        point == nil:
      return false

    defer: point.Release()

    if point.Advise(&web.client_site, &web.cookie).FAILED:
      return false

    web.browser.put_Left(0)
    web.browser.put_Top(0)

    if (web.style and wWvSilent) != 0:
      web.browser.put_Silent(VARIANT_TRUE)

    return true

  proc release(web: ptr wWeb) =
    # http://stackoverflow.com/a/14652605/917880
    if web.browser != nil:
      if web.cookie != 0:
        var container: ptr IConnectionPointContainer
        if web.browser.QueryInterface(&IID_IConnectionPointContainer,
            &container).SUCCEEDED and container != nil:
          defer: container.Release()

          var point: ptr IConnectionPoint
          if container.FindConnectionPoint(&DIID_DWebBrowserEvents2, &point).SUCCEEDED and
              point != nil:
            defer: point.Release()

            point.Unadvise(web.cookie)
            web.cookie = 0

      web.browser.put_Visible(VARIANT_FALSE)
      web.browser.Stop()
      web.browser.Release()
      web.browser = nil

    if web.ole != nil:
      web.ole.DoVerb(OLEIVERB_HIDE, nil, &web.client_site, 0, web.hwnd, nil)
      web.ole.Close(OLECLOSE_NOSAVE)
      OleSetContainedObject(web. ole, FALSE)
      web.ole.SetClientSite(nil)
      CoDisconnectObject(web.ole, 0)
      web.ole.Release()
      web.ole = nil

    web.hwnd = 0
    web.Release()

  proc wWebViewProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT
      {.stdcall.} =
    var web = cast[ptr wWeb](GetWindowLongPtr(hwnd, 0))

    if msg in WM_KEYFIRST..WM_KEYLAST and web != nil:
      if web.hwndIe != 0:
        return SendMessage(web.hwndIe, msg, wParam, lParam)

    case msg
    of WM_SIZE:
      if web != nil:
        web.browser.put_Width(LONG LOWORD(lParam))
        web.browser.put_Height(LONG HIWORD(lParam))
      return 0

    of WM_CREATE:
      let cs = cast[ptr CREATESTRUCT](lParam)
      let web = allocWeb(hwnd, cs.style)
      if web != nil:
        SetWindowLongPtr(hwnd, 0, cast[LONG_PTR](web))
        if web.init():
          return 0
      return -1

    of WM_DESTROY:
      if web != nil:
        web.release()
      return 0

    else:
      return DefWindowProc(hwnd, msg, wParam, lParam)

  var wc = WNDCLASSEX(cbSize: sizeof(WNDCLASSEX))
  wc.style = CS_PARENTDC
  wc.cbWndExtra = sizeof(ptr wWeb)
  wc.lpfnWndProc = wWebViewProc
  wc.hInstance = wAppGetInstance()
  wc.lpszClassName = className
  RegisterClassEx(wc)

proc getWeb(self: wWebView): ptr wWeb =
  result = cast[ptr wWeb](GetWindowLongPtr(self.mHwnd, 0))
  assert result != nil

method getDefaultSize*(self: wWebView): wSize {.property.} =
  ## Returns the default size for the control.
  result = self.mParent.getClientSize()

method getBestSize*(self: wWebView): wSize {.property.} =
  ## Returns the best acceptable size for the control.
  result = self.mParent.getClientSize()

template getComObject*(self: wWebView): untyped =
  ## Returns a winim COM object with IWebBrowser2 interface. Import winim/com
  ## before using this template.
  when declared(com.wrap):
    # the dirty code is used to get winim/com.IDispatch instead of winimx.IDispatch
    # I tried using cast[com.IDispatch]() but still not work.
    let web = cast[ptr wWeb](GetWindowLongPtr(self.mHwnd, 0))
    let disp = cast[variant().pdispVal.type](web.browser)
    wrap(disp)

  else:
    {.fatal: "winim/com module is not imported.".}

template comObject*(self: wWebView): untyped =
  ## The same as getComObject().
  self.getComObject()

proc navigate*(self: wWebView, url: string, noHistory = false) {.validate.} =
  ## Navigating the given url.
  let web = self.getWeb()
  var vUrl: VARIANT
  vUrl.vt = VT_BSTR
  vUrl.bstrVal = SysAllocString(url)

  var vFlag: VARIANT
  vFlag.vt = VT_I4
  if noHistory:
    vFlag.lVal = navNoHistory

  web.browser.Navigate2(&vUrl, &vFlag, nil, nil, nil)
  VariantClear(&vUrl)

proc getDocument(self: wWebView): ptr IHTMLDocument2 =
  let web = self.getWeb()
  var dispatch: ptr IDispatch
  if web.browser.get_Document(&dispatch).FAILED or dispatch == nil:
    # always try to get a document object, event a blank one
    self.navigate("about:blank")
    if web.browser.get_Document(&dispatch).FAILED or dispatch == nil:
      raise newException(wWebViewError, "wWebView.getDocument failure")

  defer: dispatch.Release()
  if dispatch.QueryInterface(&IID_IHTMLDocument2, &result).FAILED:
    raise newException(wWebViewError, "wWebView.getDocument failure")

proc runScript*(self: wWebView, code: string) {.validate.} =
  ## Runs the given javascript code. This function discard the result. If you
  ## need the result from the javascript code, use *eval* instead. For example:
  ##
  ## .. code-block:: Nim
  ##   var obj = webView.getComObject()
  ##   echo obj.document.script.call("eval", "1 + 2 * 3")
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var window: ptr IHTMLWindow2
  if document.get_parentWindow(&window).FAILED or window == nil:
    raise newException(wWebViewError, "wWebView.runScript failure")
  defer: window.Release()

  var
    bstrCode = SysAllocString(code)
    bstrLang = SysAllocString("javascript")
    ret: VARIANT

  defer:
    SysFreeString(bstrCode)
    SysFreeString(bstrLang)
    VariantClear(&ret)

  window.execScript(bstrCode, bstrLang, &ret)

proc getHtml*(self: wWebView): string {.validate, property.} =
  ## Get the HTML source code of the currently displayed document.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var body: ptr IHTMLElement
  if document.get_body(&body).FAILED or body == nil:
    raise newException(wWebViewError, "wWebView.getHtml failure")
  defer: body.Release()

  var html: ptr IHTMLElement
  if body.get_parentElement(&html).FAILED or body == nil:
    raise newException(wWebViewError, "wWebView.getHtml failure")
  defer: html.Release()

  var bstr: BSTR
  if html.get_outerHTML(&bstr).FAILED or bstr == nil:
    raise newException(wWebViewError, "wWebView.getHtml failure")
  defer: SysFreeString(bstr)

  result = $bstr

proc setHtml*(self: wWebView, html: string) {.validate, property.} =
  ## Set the displayed page HTML source to the contents of the given string.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var safeArray = SafeArrayCreateVector(VT_VARIANT, 0, 1)
  if safeArray == nil:
    raise newException(wWebViewError, "wWebView.setHtml failure")
  defer: SafeArrayDestroy(safeArray)

  var param: ptr VARIANT
  SafeArrayAccessData(safeArray, &param)
  param.vt = VT_BSTR
  param.bstrVal = SysAllocString(html)
  SafeArrayUnaccessData(safeArray)

  document.write(safeArray)
  document.close()

proc canGoBack*(self: wWebView): bool {.validate, inline.} =
  ## Returns true if it is possible to navigate backward.
  result = self.getWeb().canGoBack

proc canGoForward*(self: wWebView): bool {.validate, inline.} =
  ## Returns true if it is possible to navigate forward.
  result = self.getWeb().canGoForward

proc goBack*(self: wWebView) {.validate, inline.} =
  ## Navigate back.
  let web = self.getWeb()
  if web.canGoBack:
    web.browser.GoBack()

proc goForward*(self: wWebView) {.validate, inline.} =
  ## Navigate forward.
  let web = self.getWeb()
  if web.canGoForward:
    web.browser.GoForward()

proc refresh*(self: wWebView) {.validate, inline.} =
  ## Navigate forward.
  let web = self.getWeb()
  web.browser.Refresh()

proc stop*(self: wWebView) {.validate, inline.} =
  ## Stop the current page loading process.
  let web = self.getWeb()
  web.browser.Stop()

proc isBusy*(self: wWebView): bool {.validate.} =
  ## Returns whether the web control is currently busy.
  let web = self.getWeb()
  var busy: VARIANT_BOOL
  result = web.browser.get_Busy(&busy).SUCCEEDED and busy != VARIANT_FALSE

proc getCurrentUrl*(self: wWebView): string {.validate, property.} =
  ## Get the URL of the currently displayed document.
  let web = self.getWeb()
  var bstr: BSTR
  if web.browser.get_LocationURL(&bstr).SUCCEEDED and bstr != nil:
    defer: SysFreeString(bstr)
    result = $bstr

proc getCurrentTitle*(self: wWebView): string {.validate, property.} =
  ## Get the title of the current web page, or its URL/path if title is not available.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var bstr: BSTR
  if document.get_nameProp(&bstr).SUCCEEDED and bstr != nil:
    defer: SysFreeString(bstr)
    result = $bstr

proc getText*(self: wWebView): string {.validate, property.} =
  ## Get the text of the current page.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var body: ptr IHTMLElement
  if document.get_body(&body).FAILED or body == nil:
    raise newException(wWebViewError, "wWebView.getText failure")
  defer: body.Release()

  var bstr: BSTR
  if body.get_innerText(&bstr).SUCCEEDED and bstr != nil:
    defer: SysFreeString(bstr)
    result = $bstr

proc getSelectedHtml*(self: wWebView): string {.validate, property.} =
  ## Returns the currently selected HTML source.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var selection: ptr IHTMLSelectionObject
  if document.get_selection(&selection).FAILED or selection == nil:
    raise newException(wWebViewError, "wWebView.getSelectedHtml failure")
  defer: selection.Release()

  var disp: ptr IDispatch
  if selection.createRange(&disp).FAILED or disp == nil:
    raise newException(wWebViewError, "wWebView.getSelectedHtml failure")
  defer: disp.Release()

  var range: ptr IHTMLTxtRange
  if disp.QueryInterface(&IID_IHTMLTxtRange, &range).FAILED or range == nil:
    raise newException(wWebViewError, "wWebView.getSelectedHtml failure")
  defer: range.Release()

  var bstr: BSTR
  if range.get_htmlText(&bstr).SUCCEEDED and bstr != nil:
    defer: SysFreeString(bstr)
    result = $bstr

proc getSelectedText*(self: wWebView): string {.validate, property.} =
  ## Returns the currently selected text.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var selection: ptr IHTMLSelectionObject
  if document.get_selection(&selection).FAILED or selection == nil:
    raise newException(wWebViewError, "wWebView.getSelectedText failure")
  defer: selection.Release()

  var disp: ptr IDispatch
  if selection.createRange(&disp).FAILED or disp == nil:
    raise newException(wWebViewError, "wWebView.getSelectedText failure")
  defer: disp.Release()

  var range: ptr IHTMLTxtRange
  if disp.QueryInterface(&IID_IHTMLTxtRange, &range).FAILED or range == nil:
    raise newException(wWebViewError, "wWebView.getSelectedText failure")
  defer: range.Release()

  var bstr: BSTR
  if range.get_text(&bstr).SUCCEEDED and bstr != nil:
    defer: SysFreeString(bstr)
    result = $bstr

proc clearSelection*(self: wWebView) {.validate.} =
  ## Clears the current selection.
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var selection: ptr IHTMLSelectionObject
  if document.get_selection(&selection).FAILED or selection == nil:
    raise newException(wWebViewError, "wWebView.clearSelection failure")
  defer: selection.Release()

  selection.empty()

proc execCommand(self: wWebView, cmd: string) =
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var bstr = SysAllocString(cmd)
  defer: SysFreeString(bstr)
  document.execCommand(bstr, VARIANT_FALSE, VARIANT(), nil)

proc canExecCommand(self: wWebView, cmd: string): bool =
  let document = self.getDocument()
  assert document != nil
  defer: document.Release()

  var bstr = SysAllocString(cmd)
  defer: SysFreeString(bstr)

  var enabled: VARIANT_BOOL
  document.queryCommandEnabled(bstr, &enabled)
  result = (enabled == VARIANT_TRUE)

proc selectAll*(self: wWebView) {.validate, inline.} =
  ## Selects the entire page.
  self.execCommand("SelectAll")

proc canCopy*(self: wWebView): bool {.validate, inline.} =
  ## Returns true if the current selection can be copied.
  result = self.canExecCommand("Copy")

proc copy*(self: wWebView) {.validate, inline.} =
  ## Copies the current selection.
  self.execCommand("Copy")

method trigger(self: wWebView) =
  let web = self.getWeb()
  web.view = self

wClass(wWebView of wControl):

  method release*(self: wWebView) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wWebView, parent: wWindow, id = wDefaultID, pos = wDefaultPoint,
      size = wDefaultSize, style: wStyle = 0) {.validate.} =
    ## Initializes a webview control.
    wValidate(parent)

    wWebViewClassInit(wWebViewClassName)

    self.wControl.init(className=wWebViewClassName, parent=parent, id=id,
      pos=pos, size=size, style=style or WS_CHILD or WS_TABSTOP or WS_VISIBLE)

    # make sure WM_SIZE and WM_DESTROY for wWeb won't override by newer event handler
    self.systemConnect(WM_SIZE) do (event: wEvent):
      DefSubclassProc(self.mHwnd, WM_SIZE, event.mWparam, event.mLparam)

    self.systemConnect(WM_DESTROY) do (event: wEvent):
      DefSubclassProc(self.mHwnd, WM_DESTROY, event.mWparam, event.mLparam)

    if (style and wWvNoFocus) != 0:
      self.mFocusable = false

    else:
      self.mFocusable = true
      self.systemConnect(WM_SETFOCUS) do (event: wEvent):
        let web = self.getWeb()
        if web.hwndIe != 0:
          web.wWebViewSetFocus()

    self.wEvent_Navigation do (event: wEvent):
      event.veto
