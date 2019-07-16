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
  result.mTopLevelWindowTable = initTable[HWND, wWindow]()
  result.mWindowTable = initTable[HWND, wWindow]()
  result.mMenuBaseTable = initTable[HMENU, pointer]()
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
  result = (wTheApp.mTopLevelWindowTable.len != 0)

proc wAppWindowAdd(win: wWindow) {.inline.} =
  wTheApp.mWindowTable[win.mHwnd] = win

proc wAppWindowFindByHwnd(hwnd: HWND): wWindow {.inline.} =
  result = wTheApp.mWindowTable.getOrDefault(hwnd)

proc wAppTopLevelWindowAdd(win: wWindow) {.inline.} =
  wTheApp.mTopLevelWindowTable[win.mHwnd] = win

proc wAppTopLevelWindowAdd(hwnd: HWND) {.inline.} =
  wTheApp.mTopLevelWindowTable[hwnd] = nil

iterator wAppTopLevelHwnd(): HWND {.inline.} =
  for hwnd in wTheApp.mTopLevelWindowTable.keys:
    yield hwnd

proc wAppWindowDelete(win: wWindow) {.inline.} =
  wTheApp.mWindowTable.del(win.mHwnd)
  wTheApp.mTopLevelWindowTable.del(win.mHwnd)

proc wAppWindowDelete(hwnd: HWND) {.inline.} =
  wTheApp.mWindowTable.del(hwnd)
  wTheApp.mTopLevelWindowTable.del(hwnd)

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

proc wAppMenuBaseAdd(menu: wMenuBase) {.inline.} =
  wTheApp.mMenuBaseTable[menu.mHmenu] = cast[pointer](menu)

proc wAppMenuBaseDelete(menu: wMenuBase) {.inline.} =
  wTheApp.mMenuBaseTable.del(menu.mHmenu)

template wAppGDIStock(typ: typedesc, sn: int, obj: wGdiObject): untyped =
  if sn > wTheApp.mGDIStockSeq.high:
    wTheApp.mGDIStockSeq.setlen(sn+1)

  if wTheApp.mGDIStockSeq[sn] == nil:
    wTheApp.mGDIStockSeq[sn] = obj

  typ(wTheApp.mGDIStockSeq[sn])

iterator wAppWindows(): wWindow {.inline.} =
  for hwnd, win in wTheApp.mWindowTable:
    yield win

iterator wAppMenuBase(): wMenuBase =
  for hMenu in wTheApp.mMenuBaseTable.keys:
    if IsMenu(hMenu):
      let menuBase = cast[wMenuBase](wTheApp.mMenuBaseTable[hMenu])
      yield menuBase

proc wAppGetMenuBase(hMenu: HMENU): wMenuBase {.inline.} =
  if hMenu in wTheApp.mMenuBaseTable:
    return cast[wMenuBase](wTheApp.mMenuBaseTable[hMenu])

proc wAppProcessDialogMessage(msg: var MSG): bool =
  # find the top-level non-child window.
  var hwnd = GetAncestor(msg.hwnd, GA_ROOT)

  # if the window don't belong to wNim, call IsDialogMessage() for it.
  if hwnd != 0 and wAppWindowFindByHwnd(hwnd) == nil:
    # here we can use GetClassName() to check if the class name == "#32770",
    # but is it necessary?
    return IsDialogMessage(hwnd, msg)

proc wAppProcessAcceleratorMessage(msg: var MSG): bool =
  if wTheApp.mAccelExists:
    var win = wAppWindowFindByHwnd(msg.hwnd)
    while win != nil:
      if win.mAcceleratorTable != nil:
        let hAccel = win.mAcceleratorTable.getHandle()
        if hAccel != 0 and TranslateAccelerator(win.mHwnd, hAccel, msg) != 0:
          return true

      win = win.mParent
  return false

proc MessageLoop(modalWin: HWND = 0): int =
  var msg: MSG
  while true:
    if GetMessage(msg, 0, 0, 0) == 0 or msg.message == wEvent_AppQuit:
      if not wAppHasTopLevelWindow() or
          (msg.message == wEvent_AppQuit and
            modalWin != 0 and modalWin == msg.lParam):
        break

    # let system modeless dialog (find/replace) works.
    if wAppProcessDialogMessage(msg):
      continue

    if wAppProcessAcceleratorMessage(msg):
      continue

    # we can use IsDialogMessage here to handle key navigation
    # however, it is not flexible enouth
    # so we handle all the navigation by ourself in wControl

    TranslateMessage(msg)
    DispatchMessage(msg)

  result = int msg.wParam

# user functions

proc mainLoop*(self: wApp): int {.discardable.}=
  ## Execute the main GUI event loop.
  ## The loop will exit after all top-level windows is deleted.
  if wAppHasTopLevelWindow():
    result = MessageLoop()

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

