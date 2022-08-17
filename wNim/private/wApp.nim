#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## The wApp object represents the application itself. It allow only one instance
## for a thread. For convenience, *wTypes*, *wColors*, and *wKeyCodes* are
## exported by this module automatically. The users don't need to import these
## three modules directly.

include pragma
import tables
import winim/[utils, winstr], winim/inc/[windef, winbase], winimx
import wTypes, wMacros, wHelper, consts/[wColors, wKeyCodes]

# Every wNim app needs wTypes, so export these in wApp to the user for convenience.
export wTypes, wColors, wKeyCodes

const
  wEvent_AppQuit* = wEventId()
  wEvent_WindowUnregister* = wEventId()

  wAppMainLoopBreak = -1
  wAppMainLoopContinue = 1

type
  wDpiAware* = enum
    wNoDpiAware, wSystemDpiAware, wPerMonitorDpiAware

# Forward declarations
proc wAppProcessQuitMessage(msg: var wMsg, modalHwnd: HWND = 0): int
proc wAppProcessDialogMessage(msg: var wMsg, modalHwnd: HWND = 0): int
proc wAppProcessAcceleratorMessage(msg: var wMsg, modalHwnd: HWND = 0): int {.shield.}
proc wAppProcessWindowUnregister(msg: var wMsg, modalHwnd: HWND = 0): int

proc addMessageLoopHook*(self: wApp, hookProc: wMessageLoopHookProc) =
  ## Add hook procedure to app's message loop. The definition of wMessageLoopHookProc
  ## is in `wTypes <wTypes.html>`_.
  self.mMessageLoopHookProcs.insert(hookProc, 0)

proc removeMessageLoopHook*(self: wApp, hookProc: wMessageLoopHookProc) =
  ## Remove hook procedure to app's message loop.
  for index, hp in self.mMessageLoopHookProcs:
    if hp == hookProc:
      self.mMessageLoopHookProcs.delete(index)
      break

proc setMessageLoopWait*(self: wApp, flag = true) {.inline, property.} =
  ## If set to false, the message loop won't wait for next message. It means
  ## the hook procedure will be called very frequently. By default (flag = true),
  ## it only be called when a message is coming.
  self.mWaitMessage = flag

proc getMessageLoopWait*(self: wApp): bool {.inline, property.} =
  ## Gets the current setting.
  result = self.mWaitMessage

proc App*(dpiAware: wDpiAware = wNoDpiAware): wApp {.discardable.} =
  ## Constructor. Sets the default DPI awareness by *dpiAware*.
  if not wBaseApp.isNil:
    # "allow only one instance of wApp"
    return wBaseApp

  case dpiAware
  of wNoDpiAware: discard
  of wSystemDpiAware: setSystemDpiAware()
  of wPerMonitorDpiAware: setPerMonitorDpiAware()

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
  result.mMessageLoopHookProcs = newSeq[wMessageLoopHookProc]()
  result.mWinVersion = wGetWinVersionImpl()
  result.mUsingTheme = usingTheme()
  result.mWaitMessage = true

  # add last, run first
  try: {.gcsafe.}: # to avoid observable warning
    result.addMessageLoopHook(wAppProcessWindowUnregister)
    result.addMessageLoopHook(wAppProcessAcceleratorMessage)
    result.addMessageLoopHook(wAppProcessDialogMessage)
    result.addMessageLoopHook(wAppProcessQuitMessage)
  except: discard

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

proc wAppProcessDialogMessage(msg: var wMsg, modalHwnd: HWND = 0): int =
  # let system modeless dialog (find/replace) works.
  # find the top-level non-child window.
  var hwnd = GetAncestor(msg.hwnd, GA_ROOT)

  # if the window don't belong to wNim, call IsDialogMessage() for it.
  if hwnd != 0 and wAppWindowFindByHwnd(hwnd) == nil:
    # here we can use GetClassName() to check if the class name == "#32770",
    # but is it necessary?
    if IsDialogMessage(hwnd, msg) != 0:
      return wAppMainLoopContinue

proc wAppProcessAcceleratorMessage(msg: var wMsg, modalHwnd: HWND = 0): int {.shield.} =
  if wBaseApp.mAccelExists:
    var win = wAppWindowFindByHwnd(msg.hwnd)
    while win != nil:
      if win.mAcceleratorTable != nil:
        let hAccel = win.mAcceleratorTable.getHandle()
        if hAccel != 0 and TranslateAccelerator(win.mHwnd, hAccel, msg) != 0:
          return wAppMainLoopContinue

      win = win.mParent

proc wAppPostUnregisterMessage(win: wWindow) {.shield, inline.} =
  # we cannot call UnregisterClass in WM_NCDESTROY, so let the mainloop do it.
  wBaseApp.mClassAtomTable.withValue(win.mClassName, atom):
    PostMessage(0, wEvent_WindowUnregister, WPARAM atom[], 0)

proc wAppProcessWindowUnregister(msg: var wMsg, modalHwnd: HWND = 0): int =
  if msg.message == wEvent_WindowUnregister:
    result = wAppMainLoopContinue

    let atom = ATOM msg.wParam
    if UnregisterClass(cast[LPCTSTR](atom), wAppGetInstance()) != 0:
      for key, value in wBaseApp.mClassAtomTable:
        if value == atom:
          wBaseApp.mClassAtomTable.del(key)
          break

proc wAppProcessQuitMessage(msg: var wMsg, modalHwnd: HWND = 0): int =
  if msg.message == WM_QUIT or msg.message == wEvent_AppQuit:
    if not wAppHasTopLevelWindow() or
        (msg.message == wEvent_AppQuit and
          modalHwnd != 0 and modalHwnd == msg.lParam):
      return wAppMainLoopBreak

proc messageLoop(modalHwnd: HWND = 0): int {.shield.} =
  App()
  while true:
    var
      condition: int
      msg: wMsg

    let dispatch = if wBaseApp.mWaitMessage:
      GetMessage(msg, 0, 0, 0)
      true
    else:
      bool PeekMessage(msg, 0, 0, 0, PM_REMOVE)

    for hookProc in wBaseApp.mMessageLoopHookProcs:
      # > 0: continue(skip), < 0: break(exit), == 0: do nothing(default)
      let ret = hookProc(msg, modalHwnd)

      if likely(ret == 0):
        condition = 0

      elif ret > 0:
        condition = wAppMainLoopContinue
        break

      else: # ret < 0
        condition = wAppMainLoopBreak
        break

    if unlikely(condition == wAppMainLoopContinue):
      continue

    elif unlikely(condition == wAppMainLoopBreak):
      return int msg.wParam

    # we can use IsDialogMessage here to handle key navigation
    # however, it is not flexible enouth
    # so we handle all the navigation by ourself in wControl

    if dispatch:
      TranslateMessage(msg)
      DispatchMessage(msg)
    else:
      Sleep(1)

proc mainLoop*(self: wApp): int {.validate, discardable.}=
  ## Execute the main GUI event loop.
  ## The loop will exit after all top-level windows is deleted.
  if wAppHasTopLevelWindow():
    result = messageLoop()

proc run*(self: wApp) {.validate, inline.} =
  ## Alias for mainLoop.
  self.mainLoop()

proc broadcastTopLevelMessage*(self: wApp, msg: UINT, wParam: wWparam, lParam: wLparam) =
  ## Broadcast a event to all toplevel windows.
  for hWnd in self.mTopLevelWindowTable.keys:
    PostMessage(hWnd, msg, wParam, lParam)

proc broadcastMessage*(self: wApp,  msg: UINT, wParam: wWparam, lParam: wLparam) =
  ## Broadcast a event to all windows.
  for hWnd in self.mWindowTable.keys:
    PostMessage(hWnd, msg, wParam, lParam)
