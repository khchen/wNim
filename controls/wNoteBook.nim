method getClientSize*(self: wNoteBook): wSize =
  var r: RECT
  GetClientRect(mHwnd, r)
  SendMessage(mHwnd, TCM_ADJUSTRECT, false, addr r)
  result.width = r.right - r.left - mMarginX * 2
  result.height = r.bottom - r.top - mMarginY * 2

method getClientAreaOrigin*(self: wNoteBook): wPoint =
  result.x = mMarginX
  result.y = mMarginY

  var r: RECT
  GetClientRect(mHwnd, r)
  SendMessage(mHwnd, TCM_ADJUSTRECT, false, addr r)
  result.x += r.left.int
  result.y += r.top.int

proc updateSelection(self: wNoteBook, n: int) =
  assert n < mPages.len

  if mSelection != -1:
    mPages[mSelection].hide()

  mPages[n].show()
  mSelection = n
  SendMessage(mHwnd, TCM_SETCURSEL, n, 0)

proc adjustPageSize(self: wNoteBook) =
  let size = getClientSize()

  for i, page in mPages:
    page.setSize(0, 0, size.width, size.height)

proc getSelection*(self: wNoteBook): int =
  result = SendMessage(mHwnd, TCM_GETCURSEL, 0, 0).int

proc insertPage*(self: wNoteBook, n: int, page: wWindow = nil, text = "", isSelect = false) =
  var page = page
  if page == nil: page = Panel(self)

  assert page.mParent == self
  doassert n >= 0 and n <= mPages.len

  page.setBackgroundColor(mBackgroundColor)

  var tcitem: TCITEM
  tcitem.mask = TCIF_TEXT
  tcitem.pszText = T(text)
  SendMessage(mHwnd, TCM_INSERTITEM, n, addr tcitem)

  mPages.insert(page, n)
  page.hide()

  adjustPageSize()

  if n <= mSelection:
    mSelection.inc

  if isSelect or mSelection == -1:
    updateSelection(n)

proc addPage*(self: wNoteBook, page: wWindow = nil, text = "", isSelect = false) =
  let count = SendMessage(mHwnd, TCM_GETITEMCOUNT, 0, 0).int
  insertPage(count, page, text, isSelect)

proc getPageCount*(self: wNoteBook): int =
  # assert mPages.len == SendMessage(mHwnd, TCM_GETITEMCOUNT, 0, 0).int
  result = mPages.len

proc getPageText*(self: wNoteBook, n: int): string =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  var
    buffer = T(65536)
  #   pbuffer = allocWString(65536)
  #   buffer = cast[wstring](pbuffer)
  # defer: dealloc(pbuffer)

  var tcitem: TCITEM
  tcitem.mask = TCIF_TEXT
  tcitem.cchTextMax = 65536
  tcitem.pszText = &buffer
  SendMessage(mHwnd, TCM_GETITEM, n, addr tcitem)

  # buffer.setLen(lstrlen(&buffer))
  buffer.nullTerminate
  result = $buffer

proc setPageText*(self: wNoteBook, n: int, text: string) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  var tcitem: TCITEM
  tcitem.mask = TCIF_TEXT
  tcitem.pszText = &(T(text))
  SendMessage(mHwnd, TCM_SETITEM, n, addr tcItem)

# event generated
proc setSelection*(self: wNoteBook, n: int) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  if mSelection == -1 or mSelection != n:
    let id = getId()
    var processed = false
    let ret = self.mMessageHandler(self, wEvent_NoteBookPageChanging, cast[WPARAM](id), 0, processed)

    # FALSE to allow the selection to change
    if not processed or ret == 0:
      SendMessage(mHwnd, TCM_SETCURSEL, n, 0)
      updateSelection(n)
      discard self.mMessageHandler(self, wEvent_NoteBookPageChanged, cast[WPARAM](id), 0, processed)

# no evnet generated
proc changeSelection*(self: wNoteBook, n: int) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  if mSelection == -1 or mSelection != n:
    SendMessage(mHwnd, TCM_SETCURSEL, n, 0)
    updateSelection(n)

proc getCurrentPage*(self: wNoteBook): wWindow =
  if mSelection != -1:
    result = mPages[mSelection]

proc getPage*(self: wNoteBook, n: int): wWindow =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  result = mPages[n]

proc removePage*(self: wNoteBook, n: int, delete = false) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  mPages[n].hide()
  if delete: mPages[n].delete()
  mPages.delete(n)
  SendMessage(mHwnd, TCM_DELETEITEM, n, 0)

  if mPages.len == 0:
    mSelection = -1

  else:
    var newSel = getSelection()
    if newSel != -1:
      mSelection = newSel
      mPages[mSelection].refresh()

    else: # selected page was deleted
      newSel = mSelection
      if newSel == mPages.len: newSel.dec

      mSelection = -1 # make sure setSelection do something
      setSelection(newSel)

proc deletePage*(self: wNoteBook, n: int) =
  removePage(n, delete=true)

proc removeAllPages*(self: wNoteBook, delete = false) =
  for page in mPages:
    page.hide()
    if delete: page.delete()

  mPages.setLen(0)
  SendMessage(mHwnd, TCM_DELETEALLITEMS, 0, 0)
  mSelection = -1

proc deleteAllPages*(self: wNoteBook) =
  removeAllPages(delete=true)

proc getThemeBackgroundColor*(self: wNoteBook): wColor =
  var gResult {.global.}: wColor = wDefaultColor
  if gResult != wDefaultColor:
    return gResult

  else:
    type
      GetCurrentThemeName = proc (pszThemeFileName: LPWSTR, dwMaxNameChars: int32, pszColorBuff: LPWSTR, cchMaxColorChars: int32, pszSizeBuff: LPWSTR, cchMaxSizeChars: int32): HRESULT {.stdcall.}
      OpenThemeData = proc (hwnd: HWND, pszClassList: LPCWSTR): HANDLE {.stdcall.}
      CloseThemeData = proc (hTheme: HANDLE): HRESULT {.stdcall.}
      GetThemeColor = proc (hTheme: HANDLE, iPartId, iStateId, iPropId: int32, pColor: ptr wColor): HRESULT {.stdcall.}
      IsAppThemed = proc (): BOOL {.stdcall.}
      IsThemeActive = proc (): BOOL {.stdcall.}

    let
      comctl32Lib = loadLib("comctl32.dll")
      themeLib = loadLib("uxtheme.dll")

    if themeLib != nil:
      # if aero theme is active: use white color
      try:
        if comctl32Lib == nil: raise
        defer: comctl32Lib.unloadLib()

        let
          isAppThemed = cast[IsAppThemed](themeLib.checkedSymAddr("IsThemeActive"))
          isThemeActive = cast[IsThemeActive](themeLib.checkedSymAddr("IsThemeActive"))
          getCurrentThemeName = cast[GetCurrentThemeName](themeLib.checkedSymAddr("GetCurrentThemeName"))

        if isAppThemed() == 0 or isThemeActive() == 0: raise

        var
          themeFile = newWString(1024)
          themeColor = newWString(256)

        if getCurrentThemeName(themeFile, 1024, themeColor, 256, nil, 0).FAILED or
          "Aero" notin $themeFile or "NormalColor" notin $themeColor: raise

        let dllGetVersion = cast[DLLGETVERSIONPROC](comctl32Lib.checkedSymAddr("DllGetVersion"))
        var dvi = DLLVERSIONINFO(cbSize: sizeof(DLLVERSIONINFO).DWORD)
        if dllGetVersion(dvi).FAILED or dvi.dwMajorVersion < 6.DWORD: raise

        gResult = wWHITE
        return gResult

      except: discard

      # check theme color
      try:
        const
          TABP_BODY = 10
          NORMAL = 1
          FILLCOLORHINT = 3821
          FILLCOLOR = 3802

        let
          openThemeData = cast[OpenThemeData](themeLib.checkedSymAddr("OpenThemeData"))
          closeThemeData = cast[CloseThemeData](themeLib.checkedSymAddr("CloseThemeData"))
          getThemeColor = cast[GetThemeColor](themeLib.checkedSymAddr("GetThemeColor"))
          hTheme = openThemeData(mHwnd, "TAB")

        if hTheme == 0: raise
        defer: discard closeThemeData(hTheme)

        var color: wColor
        if getThemeColor(hTheme, TABP_BODY, NORMAL, FILLCOLORHINT, addr color).SUCCEEDED and color != 1:
          gResult = color
          return gResult

        if getThemeColor(hTheme, TABP_BODY, NORMAL, FILLCOLOR, addr color).SUCCEEDED:
          gResult = color
          return gResult

      except: discard

    gResult = mBackgroundColor
    return gResult

proc wNoteBookNotifyHandler(self: wNoteBook, code: INT, id: UINT_PTR, lparam: LPARAM, processed: var bool): LRESULT =
  var eventType: UINT
  case code
  of TCN_SELCHANGE: eventType = wEvent_NoteBookPageChanged
  of TCN_SELCHANGING: eventType = wEvent_NoteBookPageChanging
  else: return self.wControlNotifyHandler(code, id, lparam, processed)

  if code == TCN_SELCHANGE:
    updateSelection(getSelection())

  result = self.mMessageHandler(self, eventType, cast[WPARAM](id), lparam, processed)

proc wNoteBookInit(self: wNoteBook, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  # don't allow TCS_MULTILINE -> too many windows system bug to hack away
  wControlInit(self, className=WC_TABCONTROL, parent=parent, id=id, label=label, pos=pos, size=size, style=style or TCS_FOCUSONBUTTONDOWN or WS_CHILD or WS_VISIBLE or TCS_FIXEDWIDTH or WS_TABSTOP)

  mPages = newSeq[wWindow]()
  mSelection = -1

  let bkColor = getThemeBackgroundColor()
  if bkColor != mBackgroundColor:
    self.setBackgroundColor(bkColor)

  wNoteBook.setNotifyHandler(wNoteBookNotifyHandler)
  mKeyUsed = {wUSE_LEFT, wUSE_RIGHT} # left and right to navigate between tabs

  systemConnect(WM_SIZE) do (event: wEvent):
    self.adjustPageSize()

  # up and down to pass focus to child
  hardConnect(WM_KEYDOWN) do (event: wEvent):
    var processed = false
    defer: event.mSkip = not processed
    if mHwnd == event.mWindow.mHwnd:

      let keyCode = event.mWparam
      case self.eatKey(keyCode, processed)
      of wUSE_DOWN:
        for win in mPages[mSelection].mChildren:
          if win of wControl and cast[wControl](win).focusable():
            win.setFocus()
            break

      of wUSE_UP:
        for i in countdown(mPages[mSelection].mChildren.len-1, 0):
          let win = mPages[mSelection].mChildren[i]
          if win of wControl and cast[wControl](win).focusable():
            win.setFocus()
            break

      else: discard

proc NoteBook*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wNoteBook =
  new(result)
  result.wNoteBookInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)

# nim style getter/setter

proc selection*(self: wNoteBook): int = getSelection()
proc pageCount*(self: wNoteBook): int = getPageCount()
proc currentPage*(self: wNoteBook): wWindow = getCurrentPage()
proc page*(self: wNoteBook, n: int): wWindow = getPage(n)
proc `selection=`*(self: wNoteBook, n: int) = setSelection(n)
