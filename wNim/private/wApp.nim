#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## The wApp object represents the application itself. It allow only one instance
## for a thread. For convenience, *wTypes*, *wColors*, and *wKeyCodes* are
## exported by this module automatically. The users don't need to import these
## three modules directly.

{.experimental, deadCodeElim: on.}
when defined(gcDestructors): {.push sinkInference: off.}

import tables, sets
import winim/[utils, winstr], winim/inc/windef, winimx
import wTypes, wMacros, wHelper, consts/[wColors, wKeyCodes]

# Every wNim app needs wTypes, so export these in wApp to the user for convenience.
export wTypes, wColors, wKeyCodes

const wEvent_AppQuit* = wEventId()
const wEvent_WindowUnregister* = wEventId()

proc App*(): wApp {.discardable.} =
  ## Constructor.
  if not wBaseApp.isNil:
    # "allow only one instance of wApp"
    return wBaseApp

  var ctrl = TINITCOMMONCONTROLSEX(dwSize: sizeof(TINITCOMMONCONTROLSEX),
    dwICC: ICC_DATE_CLASSES or ICC_LISTVIEW_CLASSES or ICC_INTERNET_CLASSES or
    ICC_LINK_CLASS or ICC_BAR_CLASSES or ICC_COOL_CLASSES)
  InitCommonControlsEx(ctrl)
  OleInitialize(nil)

  new(result)
  result.mInstance = GetModuleHandle(nil)
  result.mExitCode = 0
  result.mAccelExists = false
  result.mClassAtomTable = initTable[string, ATOM]()
  result.mTopLevelWindowTable = initTable[HWND, wWindow]()
  result.mWindowTable = initTable[HWND, wWindow]()
  result.mMenuBaseTable = initTable[HMENU, pointer]()
  result.mGDIStockSeq = newSeq[wGdiObject]()
  result.mMessageCountTable = initTable[UINT, int]()
  result.mPropagationSet = initHashSet[UINT]()
  result.mWinVersion = wGetWinVersionImpl()
  result.mUsingTheme = usingTheme()

  wBaseApp = result

proc wAppGetInstance(): HANDLE {.inline, shield.} =
  App()
  result = wBaseApp.mInstance

proc wAppWinVersion(): float {.inline, shield.} =
  App()
  result = wBaseApp.mWinVersion

proc wUsingTheme(): bool {.inline, shield.} =
  App()
  result = wBaseApp.mUsingTheme

proc wAppGetDpi(): int {.shield.} =
  App()
  if wBaseApp.mDpi == 0:
    var hdc = GetDC(0)
    wBaseApp.mDpi = GetDeviceCaps(hdc, LOGPIXELSY)
    ReleaseDC(0, hdc)

  result = wBaseApp.mDpi

proc wAppHasTopLevelWindow(): bool {.inline, shield.} =
  App()
  result = (wBaseApp.mTopLevelWindowTable.len != 0)

proc wAppWindowAdd(win: wWindow) {.inline, shield.} =
  App()
  wBaseApp.mWindowTable[win.mHwnd] = win

proc wAppWindowFindByHwnd(hwnd: HWND): wWindow {.inline, shield.} =
  App()
  result = wBaseApp.mWindowTable.getOrDefault(hwnd)

proc wAppTopLevelWindowAdd(win: wWindow) {.inline, shield.} =
  App()
  wBaseApp.mTopLevelWindowTable[win.mHwnd] = win

proc wAppTopLevelWindowAdd(hwnd: HWND) {.inline, shield.} =
  App()
  wBaseApp.mTopLevelWindowTable[hwnd] = nil

iterator wAppTopLevelHwnd(): HWND {.inline, shield.} =
  App()
  for hwnd in wBaseApp.mTopLevelWindowTable.keys:
    yield hwnd

proc wAppWindowDelete(hwnd: HWND) {.inline, shield.} =
  App()
  wBaseApp.mWindowTable.del(hwnd)
  wBaseApp.mTopLevelWindowTable.del(hwnd)

proc wAppRegisterClassAtom(className: string, atom: ATOM) {.inline, shield.} =
  App()
  if atom != 0:
    wBaseApp.mClassAtomTable[className] = atom

proc wAppIsMessagePropagation(msg: UINT): bool {.inline, shield.} =
  App()
  result = msg in wBaseApp.mPropagationSet

proc wAppIncMessage(msg: UINT) {.inline, shield.} =
  App()
  wBaseApp.mMessageCountTable.inc(msg)

proc wAppDecMessage(msg: UINT) {.inline, shield.} =
  App()
  wBaseApp.mMessageCountTable.dec(msg)

proc wAppHasMessage(msg: UINT): bool {.inline, shield.} =
  App()
  msg in wBaseApp.mMessageCountTable

proc wAppAccelOn() {.inline, shield.} =
  App()
  wBaseApp.mAccelExists = true

proc wAppMenuBaseAdd(menu: wMenuBase) {.inline, shield.} =
  App()
  wBaseApp.mMenuBaseTable[menu.mHmenu] = cast[pointer](menu)

proc wAppMenuBaseDelete(menu: wMenuBase) {.inline, shield.} =
  App()
  wBaseApp.mMenuBaseTable.del(menu.mHmenu)

proc wAppExclMenuId(menuId: uint16) {.inline, shield.} =
  App()
  wBaseApp.mMenuIdSet.excl menuId

proc wAppInclMenuId(menuId: uint16) {.inline, shield.} =
  App()
  wBaseApp.mMenuIdSet.incl menuId

proc wAppNextMenuId(): uint16 {.inline, shield.} =
  App()
  for i in countdown(uint16.high - 1, wIdUser.uint16):
    if i notin wBaseApp.mMenuIdSet:
      return i

iterator wAppWindows(): wWindow {.inline, shield.} =
  App()
  for hwnd, win in wBaseApp.mWindowTable:
    yield win

iterator wAppTopLevelWindows(): wWindow {.inline, shield.} =
  App()
  for hwnd, win in wBaseApp.mTopLevelWindowTable:
    yield win

iterator wAppMenuBase(): wMenuBase {.shield.} =
  App()
  for hMenu in wBaseApp.mMenuBaseTable.keys:
    if IsMenu(hMenu):
      let menuBase = cast[wMenuBase](wBaseApp.mMenuBaseTable[hMenu])
      yield menuBase

proc wAppGetMenuBase(hMenu: HMENU): wMenuBase {.inline, shield.} =
  App()
  if hMenu in wBaseApp.mMenuBaseTable:
    return cast[wMenuBase](wBaseApp.mMenuBaseTable[hMenu])

proc wAppProcessDialogMessage(msg: var MSG): bool =
  # find the top-level non-child window.
  var hwnd = GetAncestor(msg.hwnd, GA_ROOT)

  # if the window don't belong to wNim, call IsDialogMessage() for it.
  if hwnd != 0 and wAppWindowFindByHwnd(hwnd) == nil:
    # here we can use GetClassName() to check if the class name == "#32770",
    # but is it necessary?
    return IsDialogMessage(hwnd, msg)

proc wAppProcessAcceleratorMessage(msg: var MSG): bool {.shield.} =
  if wBaseApp.mAccelExists:
    var win = wAppWindowFindByHwnd(msg.hwnd)
    while win != nil:
      if win.mAcceleratorTable != nil:
        let hAccel = win.mAcceleratorTable.getHandle()
        if hAccel != 0 and TranslateAccelerator(win.mHwnd, hAccel, msg) != 0:
          return true

      win = win.mParent
  return false

proc wAppPostUnregisterMessage(win: wWindow) {.shield, inline.} =
  # we cannot call UnregisterClass in WM_NCDESTROY, so let the mainloop do it.
  wBaseApp.mClassAtomTable.withValue(win.mClassName, atom):
    PostMessage(0, wEvent_WindowUnregister, WPARAM atom[], 0)

proc wAppProcessWindowUnregister(msg: var MSG): bool =
  if msg.message == wEvent_WindowUnregister:
    result = true

    let atom = ATOM msg.wParam
    if UnregisterClass(cast[LPCTSTR](atom), wAppGetInstance()) != 0:

      for key, value in wBaseApp.mClassAtomTable:
        if value == atom:
          wBaseApp.mClassAtomTable.del(key)
          break

proc messageLoop(modalWin: HWND = 0): int {.shield.} =
  App()
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

    if wAppProcessWindowUnregister(msg):
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
