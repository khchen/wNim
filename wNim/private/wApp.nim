#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## The wApp object represents the application itself. It allow only one instance
## for a thread. Because every wNim app needs to import this module. So wTypes,
## wColors, and wKeyCodes are exported by this module for convenience.

{.experimental, deadCodeElim: on.}

import tables, sets
import winim/[utils], winim/inc/windef, winimx
import wTypes, wMacros, wHelper, consts/[wColors, wKeyCodes]

# Every wNim app needs wTypes, so export these in wApp to the user for convenience.
export wTypes, wColors, wKeyCodes

const wEvent_AppQuit* = wEventId()
var wTheApp {.threadvar.}: wApp

proc App*(): wApp {.discardable.} =
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
  {.gcsafe.}:
    result.mWinVersion = wGetWinVersionImpl()
    result.mUseTheme = useTheme()

  # initSet is deprecated since v0.20
  when declared(initHashSet):
    result.mPropagationSet = initHashSet[UINT]()
  else:
    result.mPropagationSet = initSet[UINT]()

  wTheApp = result

template wAppGetCurrentApp*(): wApp =
  ## Gets the current wApp instance.
  wTheApp

proc wAppGetInstance(): HANDLE {.inline, shield.} =
  result = wTheApp.mInstance

proc wAppWinVersion(): float {.inline, shield.} =
  result = wTheApp.mWinVersion

proc wUseTheme(): bool {.inline, shield.} =
  result = wTheApp.mUseTheme

proc wAppGetDpi(): int {.shield.} =
  if wTheApp.mDpi == 0:
    var hdc = GetDC(0)
    wTheApp.mDpi = GetDeviceCaps(hdc, LOGPIXELSY)
    ReleaseDC(0, hdc)

  result = wTheApp.mDpi

proc wAppHasTopLevelWindow(): bool {.inline, shield.} =
  result = (wTheApp.mTopLevelWindowTable.len != 0)

proc wAppWindowAdd(win: wWindow) {.inline, shield.} =
  wTheApp.mWindowTable[win.mHwnd] = win

proc wAppWindowFindByHwnd(hwnd: HWND): wWindow {.inline, shield.} =
  result = wTheApp.mWindowTable.getOrDefault(hwnd)

proc wAppTopLevelWindowAdd(win: wWindow) {.inline, shield.} =
  wTheApp.mTopLevelWindowTable[win.mHwnd] = win

proc wAppTopLevelWindowAdd(hwnd: HWND) {.inline, shield.} =
  wTheApp.mTopLevelWindowTable[hwnd] = nil

iterator wAppTopLevelHwnd(): HWND {.inline, shield.} =
  for hwnd in wTheApp.mTopLevelWindowTable.keys:
    yield hwnd

proc wAppWindowDelete(win: wWindow) {.inline, shield.} =
  wTheApp.mWindowTable.del(win.mHwnd)
  wTheApp.mTopLevelWindowTable.del(win.mHwnd)

proc wAppWindowDelete(hwnd: HWND) {.inline, shield.} =
  wTheApp.mWindowTable.del(hwnd)
  wTheApp.mTopLevelWindowTable.del(hwnd)

proc wAppIsMessagePropagation(msg: UINT): bool {.inline, shield.} =
  result = msg in wTheApp.mPropagationSet

proc wAppIncMessage(msg: UINT) {.inline, shield.} =
  wTheApp.mMessageCountTable.inc(msg, 1)

proc wAppDecMessage(msg: UINT) {.inline, shield.} =
  wTheApp.mMessageCountTable.inc(msg, -1)

proc wAppHasMessage(msg: UINT): bool {.inline, shield.} =
  msg in wTheApp.mMessageCountTable

proc wAppAccelOn() {.inline, shield.} =
  wTheApp.mAccelExists = true

proc wAppMenuBaseAdd(menu: wMenuBase) {.inline, shield.} =
  wTheApp.mMenuBaseTable[menu.mHmenu] = cast[pointer](menu)

proc wAppMenuBaseDelete(menu: wMenuBase) {.inline, shield.} =
  wTheApp.mMenuBaseTable.del(menu.mHmenu)

# template wAppGDIStock(typ: typedesc, sn: int, obj: wGdiObject): untyped =
#   if sn > wTheApp.mGDIStockSeq.high:
#     wTheApp.mGDIStockSeq.setlen(sn+1)

#   if wTheApp.mGDIStockSeq[sn] == nil:
#     wTheApp.mGDIStockSeq[sn] = obj

#   typ(wTheApp.mGDIStockSeq[sn])

iterator wAppWindows(): wWindow {.inline, shield.} =
  for hwnd, win in wTheApp.mWindowTable:
    yield win

iterator wAppMenuBase(): wMenuBase {.shield.} =
  for hMenu in wTheApp.mMenuBaseTable.keys:
    if IsMenu(hMenu):
      let menuBase = cast[wMenuBase](wTheApp.mMenuBaseTable[hMenu])
      yield menuBase

proc wAppGetMenuBase(hMenu: HMENU): wMenuBase {.inline, shield.} =
  if hMenu in wTheApp.mMenuBaseTable:
    return cast[wMenuBase](wTheApp.mMenuBaseTable[hMenu])

proc wAppExclMenuId(menuId: uint16) {.inline, shield.} =
  wTheApp.mMenuIdSet.excl menuId

proc wAppInclMenuId(menuId: uint16) {.inline, shield.} =
  wTheApp.mMenuIdSet.incl menuId

proc wAppNextMenuId(): uint16 {.inline, shield.} =
  for i in wIdUser.uint16 .. uint16.high:
    if i notin wTheApp.mMenuIdSet:
      return i

proc wAppProcessDialogMessage(msg: var MSG): bool {.shield.} =
  # find the top-level non-child window.
  var hwnd = GetAncestor(msg.hwnd, GA_ROOT)

  # if the window don't belong to wNim, call IsDialogMessage() for it.
  if hwnd != 0 and wAppWindowFindByHwnd(hwnd) == nil:
    # here we can use GetClassName() to check if the class name == "#32770",
    # but is it necessary?
    return IsDialogMessage(hwnd, msg)

proc wAppProcessAcceleratorMessage(msg: var MSG): bool {.shield.}=
  if wTheApp.mAccelExists:
    var win = wAppWindowFindByHwnd(msg.hwnd)
    while win != nil:
      if win.mAcceleratorTable != nil:
        let hAccel = win.mAcceleratorTable.getHandle()
        if hAccel != 0 and TranslateAccelerator(win.mHwnd, hAccel, msg) != 0:
          return true

      win = win.mParent
  return false

proc messageLoop(modalWin: HWND = 0): int {.shield.} =
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

    # In some case (wFrame.showWindowModal() reenter), wEvent_AppQuit will miss
    # the handle. So check whether the window is alive or not for a modal loop
    # and break it anyway if the window is dead.
    if modalWin != 0 and IsWindow(modalWin) == 0:
      break

  result = int msg.wParam

proc mainLoop*(self: wApp): int {.validate, discardable.}=
  ## Execute the main GUI event loop.
  ## The loop will exit after all top-level windows is deleted.
  if wAppHasTopLevelWindow():
    result = messageLoop()

  for win in wAppWindows():
    discard DestroyWindow(win.mHwnd)

proc setMessagePropagation*(self: wApp, msg: UINT, flag = true) {.validate.} =
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
  ## Checks whether the msg is propagated by default.
  result = msg in self.mPropagationSet

proc broadcastTopLevelMessage*(self: wApp, msg: UINT, wParam: wWparam, lParam: wLparam) =
  ## Broadcast a event to all toplevel windows.
  for hWnd in self.mTopLevelWindowTable.keys:
    PostMessage(hWnd, msg, wParam, lParam)

proc broadcastMessage*(self: wApp,  msg: UINT, wParam: wWparam, lParam: wLparam) =
  ## Broadcast a event to all windows.
  for hWnd in self.mWindowTable.keys:
    PostMessage(hWnd, msg, wParam, lParam)
