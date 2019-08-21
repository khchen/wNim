#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A hotkey control enables the user to enter a combination of keystrokes to be
## used as a hotkey. The returned hotkey tuple can be used directly in
## wWindow.registerHotKey().
#
## :Appearance:
##   .. image:: images/wHotkeyCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wHkProcessTab                   With this style, press TAB key to set TAB as hotkey instead
##                                   of switches focus to the next control.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_HotkeyChanging            The hotkey is about to be changed. This event can be vetoed.
##   wEvent_HotkeyChanged             The hotkey was changed.
##   ===============================  =============================================================

const
  wHkProcessTab* = 1
  wHotkeyCtrlClassName = "wHotkeyCtrlClass"

  keyTable = {
    wKey_Cancel: "Cancel",
    wKey_Back: "Backspace",
    wKey_Tab: "Tab",
    wKey_Clear: "Clear",
    wKey_Enter: "Enter",
    wKey_Pause: "Pause",
    wKey_Capital: "CapsLock",
    wKey_Esc: "Esc",
    wKey_Space: "Space",
    wKey_PgUp: "PageUp",
    wKey_PgDn: "PageDown",
    wKey_End: "End",
    wKey_Home: "Home",
    wKey_Left: "Left",
    wKey_Up: "Up",
    wKey_Right: "Right",
    wKey_Down: "Down",
    wKey_Select: "Select",
    wKey_Print: "Print",
    wKey_Execute: "Execute",
    wKey_Snapshot: "PrintScreen",
    wKey_Insert: "Insert",
    wKey_Delete: "Delete",
    wKey_Help: "Help",
    wKey_0: "0",
    wKey_1: "1",
    wKey_2: "2",
    wKey_3: "3",
    wKey_4: "4",
    wKey_5: "5",
    wKey_6: "6",
    wKey_7: "7",
    wKey_8: "8",
    wKey_9: "9",
    wKey_A: "A",
    wKey_B: "B",
    wKey_C: "C",
    wKey_D: "D",
    wKey_E: "E",
    wKey_F: "F",
    wKey_G: "G",
    wKey_H: "H",
    wKey_I: "I",
    wKey_J: "J",
    wKey_K: "K",
    wKey_L: "L",
    wKey_M: "M",
    wKey_N: "N",
    wKey_O: "O",
    wKey_P: "P",
    wKey_Q: "Q",
    wKey_R: "R",
    wKey_S: "S",
    wKey_T: "T",
    wKey_U: "U",
    wKey_V: "V",
    wKey_W: "W",
    wKey_X: "X",
    wKey_Y: "Y",
    wKey_Z: "Z",
    wKey_Apps: "Apps",
    wKey_Sleep: "Sleep",
    wKey_Numpad0: "Num 0",
    wKey_Numpad1: "Num 1",
    wKey_Numpad2: "Num 2",
    wKey_Numpad3: "Num 3",
    wKey_Numpad4: "Num 4",
    wKey_Numpad5: "Num 5",
    wKey_Numpad6: "Num 6",
    wKey_Numpad7: "Num 7",
    wKey_Numpad8: "Num 8",
    wKey_Numpad9: "Num 9",
    wKey_Multiply: "Num *",
    wKey_Add: "Num +",
    wKey_Separator: "Separator",
    wKey_Subtract: "Num -",
    wKey_Decimal: "Num .",
    wKey_Divide: "Num /",
    wKey_F1: "F1",
    wKey_F2: "F2",
    wKey_F3: "F3",
    wKey_F4: "F4",
    wKey_F5: "F5",
    wKey_F6: "F6",
    wKey_F7: "F7",
    wKey_F8: "F8",
    wKey_F9: "F9",
    wKey_F10: "F10",
    wKey_F11: "F11",
    wKey_F12: "F12",
    wKey_F13: "F13",
    wKey_F14: "F14",
    wKey_F15: "F15",
    wKey_F16: "F16",
    wKey_F17: "F17",
    wKey_F18: "F18",
    wKey_F19: "F19",
    wKey_F20: "F20",
    wKey_F21: "F21",
    wKey_F22: "F22",
    wKey_F23: "F23",
    wKey_F24: "F24",
    wKey_Numlock: "NumLock",
    wKey_Scroll: "ScrollLock",
    wKey_BrowserBack: "BrowserBack",
    wKey_BrowserForward: "BrowserForward",
    wKey_BrowserRefresh: "BrowserRefresh",
    wKey_BrowserStop: "BrowserStop",
    wKey_BrowserSearch: "BrowserSearch",
    wKey_BrowserFavorites: "BrowserFavorites",
    wKey_BrowserHome: "BrowserHome",
    wKey_VolumeMute: "VolumeMute",
    wKey_VolumeDown: "VolumeDown",
    wKey_VolumeUp: "VolumeUp",
    wKey_MediaNextTrack: "MediaNext",
    wKey_MediaPrevTrack: "MediaPrev",
    wKey_MediaStop: "MediaStop",
    wKey_MediaPlayPause: "MediaPlay",
    wKey_LaunchMail: "LaunchMail",
    wKey_LaunchMediaSelect: "LaunchMedia",
    wKey_LaunchApp1: "LaunchApp1",
    wKey_LaunchApp2: "LaunchApp2",
    wKey_Oem1: ";",
    wKey_Oem1: "=",
    wKey_Oem1: ",",
    wKey_OemMinus: "-",
    wKey_OemPeriod: ".",
    wKey_Oem2: "/",
    wKey_Oem3: "`",
    wKey_Oem4: "[",
    wKey_Oem5: "\\",
    wKey_Oem6: "]",
    wKey_Oem7: "'",
  }.toTable

var currentHookedHotkeyCtrl {.threadvar.}: wHotkeyCtrl

proc caret(self: wHotkeyCtrl) =
  let rect = self.rect
  if self.mValue.len == 0:
    let size = getTextFontSize("I", self.mFont.mHandle, self.mHwnd)
    CreateCaret(self.mHwnd, 0, 1, size.height)
    SetCaretPos(2, (rect.height - size.height) div 2)
  else:
    let size = getTextFontSize(self.mValue, self.mFont.mHandle, self.mHwnd)
    CreateCaret(self.mHwnd, 0, 1, size.height)
    var x = size.width + 2
    if x >= rect.width: x = 1
    SetCaretPos(x, (rect.height - size.height) div 2)
  ShowCaret(self.mHwnd)

proc keyProc(nCode: int32, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  var processed = false
  let
    kbd = cast[LPKBDLLHOOKSTRUCT](lParam)
    self = currentHookedHotkeyCtrl

  defer:
    result = if processed: LRESULT 1 else: CallNextHookEx(0, nCode, wParam, lParam)

  if self.isNil:
    return

  case int wParam
  of WM_KEYUP, WM_SYSKEYUP:
    case int kbd.vkCode
    of VK_LCONTROL, VK_RCONTROL: self.mCtrl = false
    of VK_LMENU, VK_RMENU: self.mAlt = false
    of VK_LSHIFT, VK_RSHIFT: self.mShift = false
    of VK_LWIN, VK_RWIN: self.mWin = false
    else: discard

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    case int kbd.vkCode
    of VK_LCONTROL, VK_RCONTROL: self.mCtrl = true
    of VK_LMENU, VK_RMENU: self.mAlt = true
    of VK_LSHIFT, VK_RSHIFT: self.mShift = true
    of VK_LWIN, VK_RWIN: self.mWin = true
    else:
      if kbd.vkCode notin keyTable:
        return

      var value = ""
      var modifiers = 0
      var keyCode = 0

      if self.mCtrl: value.add "Ctrl + "; modifiers = modifiers or wModCtrl
      if self.mAlt: value.add "Alt + "; modifiers = modifiers or wModAlt
      if self.mShift: value.add "Shift + "; modifiers = modifiers or wModShift
      if self.mWin: value.add "Win + "; modifiers = modifiers or wModWin
      value.add keyTable[kbd.vkCode]

      if value == "NumLock" or
          (not self.mProcessTab and (value == "Tab" or value == "Shift + Tab")):
        return

      elif value == "Backspace":
        value = ""
        modifiers = 0
        keyCode = 0
      else:
        keyCode = kbd.vkCode

      let event = Event(window=self, msg=wEvent_HotkeyChanging,
        lParam=MAKELPARAM(modifiers, keyCode))

      if self.processEvent(event) and not event.isAllowed:
        return

      self.mValue = value
      self.mKeyCode = keyCode
      self.mModifiers = modifiers

      self.refresh()
      self.caret()
      self.processMessage(wEvent_HotkeyChanged, lParam=MAKELPARAM(modifiers, keyCode))
      processed = true

  else: discard

proc wHotkeyProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if msg in WM_LBUTTONDOWN..WM_MOUSELAST: SetFocus(hwnd)
  return DefWindowProc(hwnd, msg, wParam, lParam)

proc wHotKeyClassInit(className: string) =
  var wc: WNDCLASSEX
  wc.cbSize = sizeof(wc)
  wc.style = CS_HREDRAW or CS_VREDRAW
  wc.lpfnWndProc = wHotkeyProc
  wc.hInstance = wAppGetInstance()
  wc.lpszClassName = className
  wc.hCursor = LoadCursor(0, IDC_ARROW)
  RegisterClassEx(wc)

method getDefaultSize*(self: wHotkeyCtrl): wSize {.property.} =
  ## Returns the default size for the control.
  result = getTextFontSize("Ctrl + Alt + Shift + Win + PrintScreen",
    self.mFont.mHandle, self.mHwnd)
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)
  result.width += 6

method getBestSize*(self: wHotkeyCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getTextFontSize(self.mValue, self.mFont.mHandle, self.mHwnd)
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)
  result.width += 6

proc getHotkey*(self: wHotkeyCtrl): tuple[modifiers: int, keyCode: int]
    {.validate, property, inline.} =
  ## Gets the modifiers and keyCode of the current hotkey.
  ## Modifiers is a bitwise combination of wModShift, wModCtrl, wModAlt, wModWin.
  result.keyCode = self.mKeyCode
  result.modifiers = self.mModifiers

proc setHotkey*(self: wHotkeyCtrl, modifiers: int, keyCode: int) {.validate, property.} =
  ## Sets current hotkey by given modifiers and keyCode.
  if keyCode in keyTable:
    self.mValue = ""
    self.mModifiers = 0

    if (wModCtrl and modifiers) != 0:
      self.mValue.add "Ctrl + "
      self.mModifiers = self.mModifiers or wModCtrl

    if (wModAlt and modifiers) != 0:
      self.mValue.add "Alt + "
      self.mModifiers = self.mModifiers or wModAlt

    if (wModShift and modifiers) != 0:
      self.mValue.add "Shift + "
      self.mModifiers = self.mModifiers or wModShift

    if (wModWin and modifiers) != 0:
      self.mValue.add "Win + "
      self.mModifiers = self.mModifiers or wModWin

    self.mValue.add keyTable[keyCode]
    self.mKeyCode = keyCode
    self.refresh()
    self.caret()

proc setHotkey*(self: wHotkeyCtrl, hotkey: tuple[modifiers: int, keyCode: int])
    {.validate, property, inline.} =
  ## Sets current hotkey by given modifiers and keyCode in tuple.
  self.setHotkey(hotkey.modifiers, hotkey.keyCode)

proc getValue*(self: wHotkeyCtrl): string {.validate, property, inline.} =
  ## Gets the text of current hotkey.
  result = self.mValue

proc setValue*(self: wHotkeyCtrl, value: string) {.validate, property.} =
  ## Sets current hotkey by given text (case-insensitive and ignored spaces).
  var value = value.toLowerAscii.replace(" ")
  var modifiers = 0
  while true:
    if value.startsWith("ctrl+"):
      value.removePrefix("ctrl+")
      modifiers = modifiers or wModCtrl
      continue

    if value.startsWith("alt+"):
      value.removePrefix("alt+")
      modifiers = modifiers or wModAlt
      continue

    if value.startsWith("shift+"):
      value.removePrefix("shift+")
      modifiers = modifiers or wModShift
      continue

    if value.startsWith("win+"):
      value.removePrefix("win+")
      modifiers = modifiers or wModWin
      continue

    for code, name in keyTable:
      if value == name.toLowerAscii.replace(" "):
        self.setHotkey(modifiers, code)
        return

    break

proc final*(self: wHotkeyCtrl) =
  ## Default finalizer for wHotkeyCtrl.
  if currentHookedHotkeyCtrl == self:
    currentHookedHotkeyCtrl = nil

  if self.mHook != 0:
    UnhookWindowsHookEx(self.mHook)
    self.mHook = 0

proc init*(self: wHotkeyCtrl, parent: wWindow, id = wDefaultID,
    value: string = "", pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wTeLeft) {.validate.} =
  ## Initializer.
  wValidate(parent)

  wHotKeyClassInit(wHotkeyCtrlClassName)

  self.wControl.init(className=wHotkeyCtrlClassName, parent=parent, id=id,
    pos=pos, size=size, style=style or WS_CHILD or WS_TABSTOP or WS_VISIBLE)

  self.setBackgroundColor(wWhite)
  self.mProcessTab = ((style and wHkProcessTab) != 0)

  self.systemConnect(wEvent_SetFocus) do (event: wEvent):
    let self = wHotkeyCtrl event.window
    self.caret()
    self.mHook = SetWindowsHookEx(WH_KEYBOARD_LL, keyProc, wAppGetInstance(), 0)
    currentHookedHotkeyCtrl = self

  self.systemConnect(wEvent_KillFocus) do (event: wEvent):
    let self = wHotkeyCtrl event.window
    if currentHookedHotkeyCtrl == self:
      currentHookedHotkeyCtrl = nil

    if self.mHook != 0:
      UnhookWindowsHookEx(self.mHook)
      self.mHook = 0

  self.systemConnect(wEvent_Paint) do (event: wEvent):
    let self = wHotkeyCtrl event.window
    let size = self.size
    var rect: wRect
    rect.x = 2
    rect.width = size.width
    rect.height = size.height

    var dc = PaintDC(event.window)
    dc.drawLabel(self.mValue, rect, wLeft or wMiddle)

  self.systemConnect(wEvent_Size) do (event: wEvent):
    self.caret()

proc HotkeyCtrl*(parent: wWindow, id = wDefaultID,
    value: string = "", pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wTeLeft): wHotkeyCtrl {.inline, discardable.} =
  ##　Constructor, creating a hotkey control.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, value, pos, size, style)
