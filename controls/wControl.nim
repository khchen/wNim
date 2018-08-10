
# override this
method getDefaultSize*(self: wControl): wSize =
  result = (100, 80)

# override this
method getBestSize*(self: wControl): wSize =
  result = (100, 80)

proc useKey*(self: wControl, key: wUSE_KEY) =
  mKeyUsed.incl(key)

proc unuseKey*(self: wControl, key: wUSE_KEY) =
  mKeyUsed.excl(key)

proc useKey*(self: wControl, keys: set[wUSE_KEY]) =
  mKeyUsed = mKeyUsed + keys

proc unuseKey*(self: wControl, keys: set[wUSE_KEY]) =
  mKeyUsed = mKeyUsed - keys

proc wControlOnMenuCommand(event: wEvent) =
  # relay control's WM_MENUCOMMAND to any wFrame (for example, wToolBar or wButton's submenu)
  let self = event.mWindow
  var win = self.mParent
  while win != nil:
    if win of wFrame:
      var processed: bool
      discard win.mMessageHandler(win, WM_MENUCOMMAND, event.mWparam, event.mLparam, processed)
      break
    win = win.mParent

proc tabStop(self: wControl, forward = true): wControl =

  proc isTabStop(self: wControl): bool =
    # syslink control has some unexceptable weird behavior to change it's own WS_TABSTOP
    # so we always assume that wHyperlinkCtrl control has WS_TABSTOP flag

    if isFocusable() and ((GetWindowLongPtr(mHwnd, GWL_STYLE).DWORD and WS_TABSTOP) != 0 or self of wHyperlinkCtrl):
      result = true

  if mParent == nil or mParent.mChildren == nil: return

  let
    siblings = mParent.mChildren
    this = siblings.find(self)

  var index = this
  while true:
    if forward:
      index.inc
      if index >= siblings.len: index = 0
    else:
      index.dec
      if index < 0: index = siblings.len - 1

    if index == this: break

    if siblings[index] of wControl:
      let control = cast[wControl](siblings[index])
      if control.isTabStop():
        result = control
        break

proc groupStop(self: wControl, forward = true): wControl =
  if mParent == nil or mParent.mChildren == nil: return

  let
    siblings = mParent.mChildren
    this = siblings.find(self)

  var index = this
  while true:
    if not forward and (GetWindowLongPtr(siblings[index].mHwnd, GWL_STYLE).DWORD and WS_GROUP) != 0: break

    if forward:
      index.inc
      if index >= siblings.len: break
    else:
      index.dec
      if index < 0: break

    if siblings[index] of wControl:
      let control = cast[wControl](siblings[index])
      if forward and (GetWindowLongPtr(control.mHwnd, GWL_STYLE).DWORD and WS_GROUP) != 0:
        break

      if control.isFocusable():
        result = control
        break

  # focus parent control
  if result == nil and (index >= siblings.len or index <= 0):
    var parent = mParent
    while parent != nil:
      if parent of wControl:
        let control = cast[wControl](parent)
        if control.isFocusable():
          result = control
          break

      parent = parent.mParent

# return control with specified letter,
# however, click only there is one control with this letter
proc mnemonicStop(self: wControl, letter: char, click: var bool): wControl =
  if mParent == nil or mParent.mChildren == nil: return

  let
    siblings = mParent.mChildren
    this = siblings.find(self)

  var index = this
  while true:
    index.inc
    if index >= siblings.len: index = 0

    if siblings[index] of wControl:
      let control = wControl(siblings[index])
      if control.isFocusable():
        let text = toUpperAscii(control.getTitle())
        if text.find('&' & toUpperAscii(letter)) >= 0:
          if result == nil:
            result = control
            click = true
          else:
            click = false
            break

    if index == this: break

# by default, control process following key and set processed = true to "EAT" the event
proc eatKey(self: wControl, keyCode: WPARAM, processed: var bool): wUSE_KEY =
  result = wUSE_NIL
  var isCtrl, isShift, isAlt: bool
  wGetModifier(isCtrl, isShift, isAlt)

  if keyCode == VK_TAB and not (isAlt or isCtrl or isShift) and wUSE_TAB notin mKeyUsed:
    processed = true
    result = wUSE_TAB

  elif keyCode == VK_TAB and not (isAlt or isCtrl) and isShift and wUSE_SHIFT_TAB notin mKeyUsed:
    processed = true
    result = wUSE_SHIFT_TAB

  elif keyCode == VK_TAB and not (isAlt or isShift) and isCtrl and wUSE_SHIFT_TAB notin mKeyUsed:
    processed = true
    result = wUSE_CTRL_TAB

  elif not (isAlt or isCtrl or isShift):

    if keyCode == VK_RETURN and wUSE_ENTER notin mKeyUsed:
      processed = true
      result = wUSE_ENTER

    elif keyCode == VK_UP and wUSE_UP notin mKeyUsed:
      processed = true
      result = wUSE_UP

    elif keyCode == VK_DOWN and wUSE_DOWN notin mKeyUsed:
      processed = true
      result = wUSE_DOWN

    elif keyCode == VK_LEFT and wUSE_LEFT notin mKeyUsed:
      processed = true
      result = wUSE_LEFT

    elif keyCode == VK_RIGHT and wUSE_RIGHT notin mKeyUsed:
      processed = true
      result = wUSE_RIGHT

proc drawDefaultButton(hwnd: HWND, flag = true) =
  let style = GetWindowLongPtr(hwnd, GWL_STYLE)
  if flag and (style and BS_DEFPUSHBUTTON) == 0:
    SetWindowLongPtr(hwnd, GWL_STYLE, style or BS_DEFPUSHBUTTON)
    InvalidateRect(hwnd, nil, false)

  elif not flag and (style and BS_DEFPUSHBUTTON) != 0:
    SetWindowLongPtr(hwnd, GWL_STYLE, style and (not BS_DEFPUSHBUTTON))
    InvalidateRect(hwnd, nil, false)

proc drawSiblingButtons(self: wControl, fun: proc(win: wWindow): bool) =
  for win in self.mParent.mChildren:
    if win of wButton:
      drawDefaultButton(win.mHwnd, fun(win))

proc wControlMessageHandler(self: wControl, msg: UINT, wparam: WPARAM, lparam: LPARAM, processed: var bool): LRESULT =
  # if msg == WM_SYSCHAR:
  #   echo "here"
  #   processed = true
  #   return 1

  if msg == WM_KILLFOCUS:
    # always save current focus to top level window
    # if top level window get focus after window switch, the control can get focus again
    getTopParent().mSaveFocus = self

    # who will get focus is not siblings => clear all default button
    let winGotFocus = wAppWindowFindByHwnd(wParam.HWND)
    if winGotFocus == nil or winGotFocus.mParent != mParent:
      drawSiblingButtons() do (win: wWindow) -> bool: false

  elif msg == WM_SETFOCUS:
    # some button get focus => set itself and clear all others
    if self of wButton:
      drawSiblingButtons() do (win: wWindow) -> bool: win == self

    # some other control get focus => set by button's setting
    else:
      drawSiblingButtons() do (win: wWindow) -> bool: wButton(win).mDefault

  result = wWindowMessageHandler(self, msg, wparam, lparam, processed)

  if not processed and msg in {WM_CHAR, WM_KEYDOWN, WM_SYSKEYDOWN, WM_SYSCHAR}:
    let keyCode = wparam

    case msg
    of WM_CHAR:
      case eatKey(keyCode, processed)
      of wUSE_TAB:
        # by default, tab/shift+tab key pass focus to next/prev control
        let control = tabStop(forward=true)
        if control != nil: control.setFocus()

      of wUSE_SHIFT_TAB:
        let control = tabStop(forward=false)
        if control != nil: control.setFocus()

      of wUSE_ENTER:
        if self of wButton:
          SendMessage(mHwnd, BM_CLICK, 0, 0)

        else:
          for win in self.siblings:
            if win of wButton and cast[wButton](win).mDefault:
              SendMessage(win.mHwnd, BM_CLICK, 0, 0)

      else: discard

      # always generate wEvent_TextEnter event
      if keyCode == VK_RETURN:
        var enterProcessed: bool
        discard wWindowMessageHandler(self, wEvent_TextEnter, wparam, lparam, enterProcessed)

    of WM_KEYDOWN:
      case eatKey(keyCode, processed)
      of wUSE_CTRL_TAB:
        let control = tabStop(forward=true)
        if control != nil: control.setFocus()

      of wUSE_DOWN, wUSE_RIGHT:
        let control = self.groupStop(forward=true)
        if control != nil: control.setFocus()

      of wUSE_UP, wUSE_LEFT:
        let control = self.groupStop(forward=false)
        if control != nil: control.setFocus()

      else: discard

    of WM_SYSCHAR:
      # handle WM_SYSCHAR instead of WM_SYSKEYDOWN, there won't a beep sound.
      # WM_SYSKEYDOWN -> TranslateMessage -> WM_SYSCHAR
      # and system handle WM_SYSCHAR for menu select
      # now, we only hand the control that has mnemonic leter
      # try to handle focus across control and menu?

      var ch = char keyCode
      case ch:
      of 'A'..'Z', 'a'..'z', '0'..'9':
        var click: bool
        let control = mnemonicStop(ch, click)

        if control != nil:
          control.setFocus()
          if click: SendMessage(control.mHwnd, BM_CLICK, 0, 0)
          processed = true
      else: discard

    else: discard

proc wControlNotifyHandler(self: wControl, code: INT, id: UINT_PTR, lparam: LPARAM, processed: var bool): LRESULT =
  var eventType: UINT
  case code
  of NM_CLICK: eventType = wEvent_CommandLeftClick
  of NM_DBLCLK: eventType = wEvent_CommandLeftDoubleClick
  of NM_RCLICK: eventType = wEvent_CommandRightClick
  of NM_RDBLCLK: eventType = wEvent_CommandRightDoubleClick
  of NM_SETFOCUS: eventType = wEvent_CommandSetFocus
  of NM_KILLFOCUS: eventType = wEvent_CommandKillFocus
  of NM_RETURN: eventType = wEvent_CommandEnter
  else: return
  result = self.mMessageHandler(self, eventType, cast[WPARAM](id), lparam, processed)

proc init(self: wControl, className: string, parent: wWindow, id: wCommandID = -1, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0, callback: proc(self: wWindow) = nil) =

  assert parent != nil
  var
    size = size
    style = style

  if parent != nil:
    var lastControl: wWindow = nil

    for i in countdown(parent.mChildren.len-1, 0):
      let child = parent.mChildren[i]
      if child of wControl:
        lastControl = child
        break

    if lastControl == nil or (self of wRadioButton) != (lastControl of wRadioButton):
      style = style or WS_GROUP

  self.wWindow.init(title=label, className=className, parent=parent, pos=pos, size=size,
    style=style or WS_CHILD, fgColor=parent.mForegroundColor, bgColor=parent.mBackgroundColor,
    id=HMENU(id), regist=false, callback=callback)

  wControl.setMessageHandler(wControlMessageHandler)
  wControl.setNotifyHandler(wControlNotifyHandler)

  mSubclassedOldProc = cast[WNDPROC](SetWindowLongPtr(mHwnd, GWL_WNDPROC, cast[LONG_PTR](wWndProc)))
  mFocusable = true # by default, all control can has focus, modify this by subclass
  mKeyUsed = {} # by default, a control don't use anykey, modify this by subclass
