#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## The wApp object represents the application itself. It allow only one instance
## for a thread.

const
  wEvent_AppQuit = WM_APP + 1

var wTheApp {.threadvar.}: wApp

proc App*(): wApp =
  ## Constructor.
  if not wTheApp.isNil:
    # "allow only one instance of wApp"
    return wTheApp

  var ctrl = TINITCOMMONCONTROLSEX(dwSize: sizeof(TINITCOMMONCONTROLSEX),
    dwICC: ICC_DATE_CLASSES or ICC_LISTVIEW_CLASSES or ICC_INTERNET_CLASSES or
    ICC_LINK_CLASS or ICC_BAR_CLASSES or ICC_COOL_CLASSES)
  InitCommonControlsEx(ctrl)
  OleInitialize(nil)

  new(result)
  result.mInstance = GetModuleHandle(nil)
  result.mExitCode = 0
  result.mAccelExists = false
  result.mTopLevelWindowList = @[]
  result.mWindowTable = initTable[HWND, wWindow]()
  result.mGDIStockSeq = newSeq[wGdiObject]()
  result.mMessageCountTable = initCountTable[UINT]()

  # initSet is deprecated since v0.20
  when declared(initHashSet):
    result.mPropagationSet = initHashSet[UINT]()
  else:
    result.mPropagationSet = initSet[UINT]()

  wTheApp = result

proc wAppGetCurrentApp*(): wApp {.inline.} =
  ## Gets the current wApp instance.
  result = wTheApp

proc wAppGetInstance(): HANDLE {.inline.} =
  result = wTheApp.mInstance

proc wAppHasTopLevelWindow(): bool {.inline.} =
  result = (wTheApp.mTopLevelWindowList.len != 0)

proc wAppWindowAdd(win: wWindow) {.inline.} =
  wTheApp.mWindowTable[win.mHwnd] = win

proc wAppWindowFindByHwnd(hwnd: HWND): wWindow {.inline.} =
  result = wTheApp.mWindowTable.getOrDefault(hwnd)

proc wAppTopLevelWindowAdd(win: wWindow) {.inline.} =
  wTheApp.mTopLevelWindowList.add(win)

iterator wAppTopLevelWindows(): wWindow {.inline.} =
  for win in wTheApp.mTopLevelWindowList:
    yield win

proc wAppWindowDelete(win: wWindow) =
  wTheApp.mWindowTable.del(win.mHwnd)

  for index, w in wTheApp.mTopLevelWindowList:
    if w == win:
      wTheApp.mTopLevelWindowList.del(index)

proc wAppIsMessagePropagation(msg: UINT): bool {.inline.} =
  result = msg in wTheApp.mPropagationSet

proc wAppIncMessage(msg: UINT) {.inline.} =
  wTheApp.mMessageCountTable.inc(msg, 1)

proc wAppDecMessage(msg: UINT) {.inline.} =
  wTheApp.mMessageCountTable.inc(msg, -1)

proc wAppHasMessage(msg: UINT): bool {.inline.} =
  msg in wTheApp.mMessageCountTable

proc wAppAccelOn() {.inline.} =
  wTheApp.mAccelExists = true

template wAppGDIStock(typ: typedesc, sn: int, obj: wGdiObject): untyped =
  if sn > wTheApp.mGDIStockSeq.high:
    wTheApp.mGDIStockSeq.setlen(sn+1)

  if wTheApp.mGDIStockSeq[sn] == nil:
    wTheApp.mGDIStockSeq[sn] = obj

  typ(wTheApp.mGDIStockSeq[sn])

iterator wAppWindows(): wWindow {.inline.} =
  for hwnd, win in wTheApp.mWindowTable:
    yield win

proc MessageLoop(isMainLoop: bool = true): int =
  var msg: MSG
  while true:
    if GetMessage(msg, 0, 0, 0) == 0 or msg.message == wEvent_AppQuit:
      if isMainLoop == false or wAppHasTopLevelWindow() == false:
        break

    var accelProcessed = false
    if wTheApp.mAccelExists:
      var win = wAppWindowFindByHwnd(msg.hwnd)
      while win != nil:
        if win.mAcceleratorTable != nil:
          let hAccel = win.mAcceleratorTable.getHandle()
          if hAccel != 0 and TranslateAccelerator(win.mHwnd, hAccel, msg) != 0:
            accelProcessed = true
            break

        win = win.mParent

    # we can use IsDialogMessage here to handle key navigation
    # however, it is not flexible enouth
    # so we handle all the navigation by outself in wControl

    if not accelProcessed:
      TranslateMessage(msg)
      DispatchMessage(msg)

  result = int msg.wParam

# user functions

proc mainLoop*(self: wApp): int {.discardable.}=
  ## Execute the main GUI event loop.
  ## The loop will exit after all top-level windows is deleted.
  if wAppHasTopLevelWindow():
    result = MessageLoop(isMainLoop=true)

  for win in wAppWindows():
    discard DestroyWindow(win.mHwnd)

proc setMessagePropagation*(self: wApp, msg: UINT, flag = true) =
  # Events of the classes deriving from wCommandEvent are propagated by default
  # to the parent window if they are not processed in this window itself.

  ## Regist a message associated event to propagate upward by default.
  ## Control events (wEvent_Menu, wEvent_Button, etc) will always propagate by default.
  ## To overdie shouldPropagate() method is a more gentle way.

  if flag:
    self.mPropagationSet.incl msg
  else:
    self.mPropagationSet.excl msg

proc isMessagePropagation*(self: wApp, msg: UINT): bool =
  result = msg in self.mPropagationSet

