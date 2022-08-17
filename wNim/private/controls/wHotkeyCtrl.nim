#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A hotkey control enables the user to enter a combination of keystrokes to be
## used as a hotkey. The returned hotkey tuple can be used directly in
## wWindow.registerHotKey(). The default key to clear current content is Esc.
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
##   wHkLeft                         The text in the control will be left-justified (default).
##   wHkCentre                       The text in the control will be centered.
##   wHkCenter                       The text in the control will be centered.
##   wHkRight                        The text in the control will be right-justified.
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

include ../pragma
import tables, strutils
import ../wBase, wControl
export wControl

const
  wHkLeft* = ES_LEFT
  wHkCentre* = ES_CENTER
  wHkCenter* = ES_CENTER
  wHkRight* = ES_RIGHT
  wHkProcessTab* = 0x4000 # not used in ES_XXXX

  keyTable = {
    wKey_Cancel: "Cancel", wKey_Back: "Backspace", wKey_Tab: "Tab",
    wKey_Clear: "Clear", wKey_Enter: "Enter", wKey_Pause: "Pause",
    wKey_Capital: "CapsLock", wKey_Esc: "Esc", wKey_Space: "Space",
    wKey_PgUp: "PageUp", wKey_PgDn: "PageDown",
    wKey_End: "End", wKey_Home: "Home",
    wKey_Left: "Left", wKey_Up: "Up", wKey_Right: "Right", wKey_Down: "Down",
    wKey_Select: "Select", wKey_Print: "Print",
    wKey_Execute: "Execute", wKey_Snapshot: "PrintScreen",
    wKey_Insert: "Insert", wKey_Delete: "Delete", wKey_Help: "Help",
    wKey_0: "0", wKey_1: "1", wKey_2: "2", wKey_3: "3", wKey_4: "4",
    wKey_5: "5", wKey_6: "6", wKey_7: "7", wKey_8: "8", wKey_9: "9",
    wKey_A: "A", wKey_B: "B", wKey_C: "C", wKey_D: "D", wKey_E: "E",
    wKey_F: "F", wKey_G: "G", wKey_H: "H", wKey_I: "I", wKey_J: "J",
    wKey_K: "K", wKey_L: "L", wKey_M: "M", wKey_N: "N", wKey_O: "O",
    wKey_P: "P", wKey_Q: "Q", wKey_R: "R", wKey_S: "S", wKey_T: "T",
    wKey_U: "U", wKey_V: "V", wKey_W: "W", wKey_X: "X", wKey_Y: "Y",
    wKey_Z: "Z", wKey_Apps: "Apps", wKey_Sleep: "Sleep",
    wKey_Numpad0: "Num 0", wKey_Numpad1: "Num 1", wKey_Numpad2: "Num 2",
    wKey_Numpad3: "Num 3", wKey_Numpad4: "Num 4", wKey_Numpad5: "Num 5",
    wKey_Numpad6: "Num 6", wKey_Numpad7: "Num 7", wKey_Numpad8: "Num 8",
    wKey_Numpad9: "Num 9", wKey_Multiply: "Num *", wKey_Add: "Num +",
    wKey_Separator: "Separator",
    wKey_Subtract: "Num -", wKey_Decimal: "Num .", wKey_Divide: "Num /",
    wKey_F1: "F1", wKey_F2: "F2", wKey_F3: "F3", wKey_F4: "F4", wKey_F5: "F5",
    wKey_F6: "F6", wKey_F7: "F7", wKey_F8: "F8", wKey_F9: "F9", wKey_F10: "F10",
    wKey_F11: "F11", wKey_F12: "F12", wKey_F13: "F13", wKey_F14: "F14",
    wKey_F15: "F15", wKey_F16: "F16", wKey_F17: "F17", wKey_F18: "F18",
    wKey_F19: "F19", wKey_F20: "F20", wKey_F21: "F21", wKey_F22: "F22",
    wKey_F23: "F23", wKey_F24: "F24",
    wKey_Numlock: "NumLock", wKey_Scroll: "ScrollLock",
    wKey_BrowserBack: "BrowserBack", wKey_BrowserForward: "BrowserForward",
    wKey_BrowserRefresh: "BrowserRefresh", wKey_BrowserStop: "BrowserStop",
    wKey_BrowserSearch: "BrowserSearch", wKey_BrowserFavorites: "BrowserFavorites",
    wKey_BrowserHome: "BrowserHome", wKey_VolumeMute: "VolumeMute",
    wKey_VolumeDown: "VolumeDown", wKey_VolumeUp: "VolumeUp",
    wKey_MediaNextTrack: "MediaNext", wKey_MediaPrevTrack: "MediaPrev",
    wKey_MediaStop: "MediaStop", wKey_MediaPlayPause: "MediaPlay",
    wKey_LaunchMail: "LaunchMail", wKey_LaunchMediaSelect: "LaunchMedia",
    wKey_LaunchApp1: "LaunchApp1", wKey_LaunchApp2: "LaunchApp2",
    wKey_Oem1: ";", wKey_Oem1: "=", wKey_Oem1: ",", wKey_OemMinus: "-",
    wKey_OemPeriod: ".", wKey_Oem2: "/", wKey_Oem3: "`", wKey_Oem4: "[",
    wKey_Oem5: "\\", wKey_Oem6: "]", wKey_Oem7: "'",
  }.toTable

var currentHookedHotkeyCtrl {.threadvar.}: wHotkeyCtrl

proc wHotkeyToString*(hotkey: tuple[modifiers: int, keyCode: int]): string =
  ## Helper function to convert from hotkey to string. Returns "" if failed.
  if hotkey.keyCode in keyTable:
    if (wModCtrl and hotkey.modifiers) != 0: result.add "Ctrl + "
    if (wModAlt and hotkey.modifiers) != 0: result.add "Alt + "
    if (wModShift and hotkey.modifiers) != 0: result.add "Shift + "
    if (wModWin and hotkey.modifiers) != 0: result.add "Win + "

    result.add keyTable[hotkey.keyCode]

proc wStringToHotkey*(value: string): tuple[modifiers: int, keyCode: int] =
  ## Helper function to convert from string to hotkey. Returns (0, 0) if failed.
  if value.len == 0:
    return

  proc removePrefix(s: var string, prefix: string): bool =
    if s.startsWith(prefix):
      when compiles(s.delete(0..prefix.len - 1)):
        s.delete(0..prefix.len - 1)
      else:
        s.delete(0, prefix.len - 1)
      result = true

  var value = value.toLowerAscii.replace(" ")
  var modifiers = 0
  while true:
    if value.removePrefix("ctrl+"):
      modifiers = modifiers or wModCtrl
      continue

    if value.removePrefix("alt+"):
      modifiers = modifiers or wModAlt
      continue

    if value.removePrefix("shift+"):
      modifiers = modifiers or wModShift
      continue

    if value.removePrefix("win+"):
      modifiers = modifiers or wModWin
      continue
    break

  for code, name in keyTable:
    if value == name.toLowerAscii.replace(" "):
      return (modifiers, code)

proc update(self: wHotkeyCtrl) =
  self.setLabel(self.mValue)
  let l = SendMessage(self.mHwnd, EM_LINELENGTH, 0, 0)
  SendMessage(self.mHwnd, EM_SETSEL, l, l)

method getDefaultSize*(self: wHotkeyCtrl): wSize {.property.} =
  ## Returns the default size for the control.
  result = getTextFontSize("Ctrl + Alt + Shift + Win + PrintScreen",
    self.mFont.mHandle, self.mHwnd)
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)
  result.width += 10

method getBestSize*(self: wHotkeyCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getTextFontSize(self.mValue, self.mFont.mHandle, self.mHwnd)
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)
  result.width += 10

proc getHotkey*(self: wHotkeyCtrl): tuple[modifiers: int, keyCode: int]
    {.validate, property, inline.} =
  ## Gets the modifiers and keyCode of the current hotkey.
  ## Modifiers is a bitwise combination of wModShift, wModCtrl, wModAlt, wModWin.
  result.keyCode = self.mKeyCode
  result.modifiers = self.mModifiers

proc getValue*(self: wHotkeyCtrl): string {.validate, property, inline.} =
  ## Gets the text of current hotkey.
  result = self.mValue

proc getClearKey*(self: wHotkeyCtrl): int {.validate, property, inline.} =
  ## Gets the key code that clears current content. The default key is Esc.
  result = self.mClearKeyCode

proc changeHotkey*(self: wHotkeyCtrl, modifiers: int, keyCode: int)
    {.validate, property.} =
  ## Sets current hotkey by given modifiers and keyCode. This functions does not
  ## generate the wEvent_HotkeyChanged event.
  self.mValue = wHotkeyToString((modifiers, keyCode))
  if self.mValue.len == 0:
    self.mModifiers = 0
    self.mKeyCode = 0
  else:
    self.mModifiers = modifiers and (wModCtrl or wModAlt or wModShift or wModWin)
    self.mKeyCode = keyCode

  self.update()

proc changeHotkey*(self: wHotkeyCtrl, hotkey: tuple[modifiers: int, keyCode: int])
    {.validate, property, inline.} =
  ## Sets current hotkey. This functions does not generate the wEvent_HotkeyChanged
  ## event.
  self.changeHotkey(hotkey.modifiers, hotkey.keyCode)

proc setHotkey*(self: wHotkeyCtrl, modifiers: int, keyCode: int)
    {.validate, property.} =
  ## Sets current hotkey by given modifiers and keyCode. This function generates
  ## a wEvent_HotkeyChanged event. To avoid this you can use changeHotkey() instead.
  let oldHotkey = self.getHotkey()
  self.changeHotkey(modifiers, keyCode)
  if oldHotkey != self.getHotkey():
    self.processMessage(wEvent_HotkeyChanged, lParam=MAKELPARAM(modifiers, keyCode))

proc setHotkey*(self: wHotkeyCtrl, hotkey: tuple[modifiers: int, keyCode: int])
    {.validate, property, inline.} =
  ## Sets current hotkey. This function generates a wEvent_HotkeyChanged event.
  ## To avoid this you can use changeHotkey() instead.
  self.setHotkey(hotkey.modifiers, hotkey.keyCode)

proc changeValue*(self: wHotkeyCtrl, value: string) {.validate, property, inline.} =
  ## Sets current hotkey by given text (case-insensitive and ignored spaces).
  ## This functions does not generate the wEvent_HotkeyChanged event.
  self.changeHotkey(wStringToHotkey(value))

proc setValue*(self: wHotkeyCtrl, value: string) {.validate, property, inline.} =
  ## Sets current hotkey by given text (case-insensitive and ignored spaces).
  ## This function generates a wEvent_HotkeyChanged event. To avoid this you can
  ## use changeValue() instead.
  self.setHotkey(wStringToHotkey(value))

proc setClearKey*(self: wHotkeyCtrl, clearKey: int) {.validate, property, inline.} =
  ## Sets a key to clear current content. The default key is Esc.
  ## If more keys are needed, you can do it by handling
  ## wEvent_HotkeyChanging. For example:
  ##
  ## .. code-block:: Nim
  ##   hotkeyCtrl.wEvent_HotkeyChanging do (event: wEvent):
  ##     let hotkey = event.getHotkey()
  ##     if hotkey.modifiers == 0 and hotkey.keyCode in {wKey_Esc, wKey_Delete, wKey_Back}:
  ##       hotkeyCtrl.hotkey = (0, 0)
  ##       event.veto
  self.mClearKeyCode = if clearKey in keyTable: clearKey else: 0

proc wHotKeyHookProc(self: wWindow, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool =
  if msg in WM_LBUTTONDOWN..WM_MOUSELAST:
    SetFocus(self.mHwnd)
    return true

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

      var modifiers = 0
      var keyCode = int kbd.vkCode

      if self.mCtrl: modifiers = modifiers or wModCtrl
      if self.mAlt: modifiers = modifiers or wModAlt
      if self.mShift: modifiers = modifiers or wModShift
      if self.mWin: modifiers = modifiers or wModWin

      if modifiers == 0 and keyCode == wKey_Numlock:
        return

      elif keyCode == wKey_Tab and (not self.mProcessTab) and
          (modifiers and (not wModShift)) == 0:
        self.mShift = false
        return

      elif modifiers == 0 and keyCode == self.mClearKeyCode:
        keyCode = 0

      # discard any key input for edit control, even we don't handle it
      processed = true

      if self.mKeyCode == keyCode and self.mModifiers == modifiers:
        # no change, nothing to do
        return

      let event = Event(window=self, msg=wEvent_HotkeyChanging,
        lParam=MAKELPARAM(modifiers, keyCode))

      if self.processEvent(event) and not event.isAllowed:
        return

      self.setHotkey(modifiers, keyCode)

  else: discard

proc unhook(self: wHotkeyCtrl) =
  if currentHookedHotkeyCtrl == self:
    currentHookedHotkeyCtrl = nil

  if self.mHook != 0:
    UnhookWindowsHookEx(self.mHook)
    self.mHook = 0

wClass(wHotkeyCtrl of wControl):

  method release*(self: wHotkeyCtrl) =
    ## Release all the resources during destroying. Used internally.
    self.unhook()
    free(self[])

  proc init*(self: wHotkeyCtrl, parent: wWindow, id = wDefaultID,
      value: string = "", pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = wHkLeft) {.validate.} =
    ## Initializes a hotkey control.
    wValidate(parent)

    self.mProcessTab = ((style and wHkProcessTab) != 0)
    self.mHookProc = wHotKeyHookProc
    self.mClearKeyCode = wKey_Esc

    var style = style and (not wHkProcessTab)
    if (style and wHkRight) != 0:
      style = style or ES_AUTOHSCROLL

    self.wControl.init(className=WC_EDIT, parent=parent, id=id,
      pos=pos, size=size, style=style or WS_CHILD or WS_TABSTOP or WS_VISIBLE)

    self.setBackgroundColor(wWhite)
    self.setValue(value)

    self.systemConnect(wEvent_SetFocus) do (event: wEvent):
      let self = wBase.wHotkeyCtrl event.mWindow
      self.mHook = SetWindowsHookEx(WH_KEYBOARD_LL, keyProc, wAppGetInstance(), 0)
      currentHookedHotkeyCtrl = self

    self.systemConnect(wEvent_KillFocus) do (event: wEvent):
      let self = wBase.wHotkeyCtrl event.mWindow
      self.unhook()
