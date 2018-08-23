## This is the base class for a GUI controls.
## Here have no any public proc or method.

# forward declaration
proc click*(self: wButton) {.inline.}
proc focusNext(self: wNoteBook): bool
proc focusPrev(self: wNoteBook): bool

proc wControl_DoMenuCommand(event: wEvent) =
  # relay control's WM_MENUCOMMAND to any wFrame
  # for example, wToolBar or wButton's submenu
  # or any popup menu from control
  let self = event.mWindow

  var win = self.mParent
  while win != nil:
    if win of wFrame:
      win.processMessage(WM_MENUCOMMAND, event.mWparam, event.mLparam)
      break
    win = win.mParent

proc getNextGroup(self: wControl, previous: bool): wControl =
  var hWnd = mHwnd
  while true:
    hWnd = GetNextDlgGroupItem(mParent.mHwnd, hWnd, previous)
    if hWnd == 0 or hWnd == mHwnd:
      break

    let win = wAppWindowFindByHwnd(hWnd)
    if win != nil and win of wControl and win.isFocusable():
      return wControl(win)

proc getNextTab(self: wControl, previous: bool): wControl =
  var hWnd = mHwnd
  while true:
    hWnd = GetNextDlgTabItem(mParent.mHwnd, hWnd, previous)
    if hWnd == 0 or hWnd == mHwnd:
      break

    let win = wAppWindowFindByHwnd(hWnd)
    if win != nil and win of wControl and win.isFocusable():
      return wControl(win)

proc getNextMnemonic(self: wControl, letter: char, onlyone: var bool): wControl =
  # return control with specified letter,
  # however, click only there is one control with this letter
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
            onlyone = true
          else:
            onlyone = false
            break

    if index == this: break

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

proc notControl(event: wEvent): bool {.inline.} =
  # only handle if the event is really from a control
  # it's false when the event is propagated from a subclassed window for controls
  # for example, edit of ComboBox, and let wKeyEvent propagate
  if not (event.window of wControl):
    event.skip
    return true

proc wControl_DoKillFocus(event: wEvent) =
  if event.notControl(): return

  let self = wControl(event.mWindow)
  # always save current focus to top level window
  # if top level window get focus after window switch, the control can get focus again
  self.getTopParent().mSaveFocus = self

  # who will get focus is not siblings => clear all default button
  let winGotFocus = wAppWindowFindByHwnd(event.mWparam.HWND)
  if winGotFocus == nil or winGotFocus.mParent != self.mParent:
    self.drawSiblingButtons() do (win: wWindow) -> bool: false

proc wControl_DoSetFocus(event: wEvent) =
  if event.notControl(): return

  let self = wControl(event.mWindow)
  # some button get focus => set itself and clear all others
  if self of wButton:
    self.drawSiblingButtons() do (win: wWindow) -> bool: win == self

  # some other control get focus => set by button's setting
  else:
    self.drawSiblingButtons() do (win: wWindow) -> bool: wButton(win).mDefault


proc wControl_OnNavigation(event: wEvent) =
  if event.notControl(): return
  let self = wControl(event.window)
  var processed = false
  defer: event.skip(if processed: false else: true)

  proc isAllowed(): bool =
    # let the control have a change to veto the navigation action
    let naviEvent = Event(window=self, msg=wEvent_Navigation, wParam=event.wParam, lParam=event.lParam)
    if self.processEvent(naviEvent) and not naviEvent.isAllowed:
      return false
    else:
      return true

  proc trySetFocus(control: wControl): bool {.discardable.} =
    # set focus and return true only if control in not nil
    if control != nil:
      control.setFocus()
      processed = true
      result = true

  proc notebookChangeTab(previous: bool) =
    # if self or any parent is a wNoteBook control, try to switch the tab
    var control: wWindow = self
    while control != nil:
      if control of wNoteBook:
        if previous:
          processed = wNoteBook(control).focusPrev()
        else:
          processed = wNoteBook(control).focusNext()
        break
      control = control.mParent


  let keyCode = event.keyCode
  case event.eventMessage
  of WM_CHAR:
    if keyCode == VK_TAB:
      # tab, shift+tab
      if isAllowed():
        trySetFocus(self.getNextTab(previous=if event.shiftDown: true else: false))

    elif keyCode == VK_RETURN and not event.shiftDown:
      # enter
      # the behavior of the default button: click the default button when press enter,
      # except the focused control itself is a button
      if isAllowed():
        if self of wButton:
          wButton(self).click
          processed = true

        else:
          for win in self.siblings:
            if win of wButton and wButton(win).mDefault:
              wButton(win).click
              processed = true
              break

          if not processed:
            # not button, no default button, so let enter as click on checkbox and radiobox?
            if self of wCheckBox or self of wRadioButton:
              SendMessage(self.mHwnd, BM_CLICK, 0, 0)
              processed = true

  of WM_KEYDOWN:
    if keyCode == VK_TAB and event.ctrlDown:
      # ctrl+tab, ctrl+shift+tab
      if isAllowed():
        # ctrl+tab under notebook can change the tab
        notebookChangeTab(previous=event.shiftDown)

        if not processed:
          trySetFocus(self.getNextTab(previous=if event.shiftDown: true else: false))

    elif keyCode in {VK_NEXT, VK_PRIOR} and event.ctrlDown:
      # ctrl+pgup, ctrl+pgdn
      if isAllowed():
        # only works if there is a wNoteBook control
        notebookChangeTab(previous=event.shiftDown)

    elif keyCode in {VK_LEFT, VK_UP}:
      # left, up
      if isAllowed():
        trySetFocus(self.getNextGroup(previous=true))

    elif keyCode in {VK_RIGHT, VK_DOWN}:
      # right, down
      if isAllowed():
        trySetFocus(self.getNextGroup(previous=false))

  of WM_SYSCHAR:
    # handle WM_SYSCHAR instead of WM_SYSKEYDOWN, there won't a beep sound.
    # WM_SYSKEYDOWN -> TranslateMessage -> WM_SYSCHAR
    # and then windows system handle WM_SYSCHAR for menu select
    # now, we only handle the control that has mnemonic leter
    # try to handle focus across control and menu?
    if isAllowed():
      var ch = char keyCode
      if ch in 'A'..'Z' or ch in 'a'..'z' or ch in '0'..'9':
        var onlyone: bool
        let control = self.getNextMnemonic(ch, onlyone)
        if trySetFocus(control) and onlyone:
          if control of wButton or control of wCheckBox or control of wRadioButton:
            SendMessage(control.mHwnd, BM_CLICK, 0, 0)

  else: discard


method processNotify(self: wControl, code: INT, id: UINT_PTR, lParam: LPARAM, ret: var LRESULT): bool =
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
  return self.processMessage(eventType, cast[WPARAM](id), lparam, ret)

proc init(self: wControl, className: string, parent: wWindow,
    id: wCommandID = -1, label: string = "", pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = 0) =
  # a global init for GUI controls, is this need to be public?

  var
    size = size
    style = style

  var lastControl: wWindow = nil
  for i in countdown(parent.mChildren.len - 1, 0):
    let child = parent.mChildren[i]
    if child of wControl:
      lastControl = child
      break

  # by default, first not radiobutton (include first of all) or last radiobutton
  # must has WS_GROUP style

  if lastControl == nil or (self of wRadioButton) != (lastControl of wRadioButton):
    style = style or WS_GROUP

  self.wWindow.initVerbosely(title=label, className=className, parent=parent, pos=pos, size=size,
    style=style or WS_CHILD, fgColor=parent.mForegroundColor, bgColor=parent.mBackgroundColor,
    id=HMENU(id), regist=false)

  SetWindowSubclass(mHwnd, wSubProc, cast[UINT_PTR](self), cast[DWORD_PTR](self))

  mFocusable = true # by default, all control can has focus, modify this by subclass

  systemConnect(WM_KILLFOCUS, wControl_DoKillFocus)
  systemConnect(WM_SETFOCUS, wControl_DoSetFocus)
  systemConnect(WM_MENUCOMMAND, wControl_DoMenuCommand)
  hardConnect(WM_CHAR, wControl_OnNavigation)
  hardConnect(WM_KEYDOWN, wControl_OnNavigation)
  hardConnect(WM_SYSCHAR, wControl_OnNavigation)
