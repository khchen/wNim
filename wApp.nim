## **The wxApp object represents the application itself. It allow only one instance for a thread.**

const
  wEvent_AppQuit = WM_APP + 1

var wTheApp {.threadvar.}: wApp

proc App*(): wApp =
  ## Constructor.
  if not wTheApp.isNil:
    raise newException(LibraryError, "allow only one instance of wApp")

  var ctrl = TINITCOMMONCONTROLSEX(dwSize: sizeof(TINITCOMMONCONTROLSEX),
    dwICC: ICC_DATE_CLASSES or ICC_LISTVIEW_CLASSES)
  InitCommonControlsEx(ctrl)

  when compileOption("threads"):
    discard CoInitializeEx(nil, COINIT_MULTITHREADED)
  else:
    discard CoInitialize(nil)

  new(result)
  result.mInstance = GetModuleHandle(nil)
  result.mExitCode = 0
  result.mTopLevelWindowList = @[]
  result.mWindowTable = initTable[HWND, wWindow]()
  result.mGDIStockSeq = newSeq[wGdiObject]()
  result.mPropagationSet = initSet[UINT]()
  result.mMessageCountTable = initCountTable[UINT]()
  wTheApp = result

proc wAppGetInstance(): HANDLE {.inline.} =
  result = wTheApp.mInstance

proc wAppHasTopLevelWindow(): bool {.inline.} =
  result = (wTheApp.mTopLevelWindowList.len != 0)

proc wAppWindowAdd(win: wWindow) {.inline.} =
  wTheApp.mWindowTable[win.mHwnd] = win

proc wAppWindowChange(win: wWindow) =
  for key, value in wTheApp.mWindowTable:
    if value == win:
      wTheApp.mWindowTable.del(key)
      break

  wAppWindowAdd(win)

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

    TranslateMessage(msg)
    DispatchMessage(msg)

  result = msg.wParam.int

# user functions

proc MainLoop*(self: wApp): int {.discardable.}=
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
