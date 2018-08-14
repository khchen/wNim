
# forward declaration
proc click*(self: wButton) {.inline.}

method getDefaultSize*(self: wControl): wSize =
  # override this
  result = (100, 80)

method getBestSize*(self: wControl): wSize =
  # override this
  result = (100, 80)

proc wControl_DoMenuCommand(event: wEvent) =
  # relay control's WM_MENUCOMMAND to any wFrame (for example, wToolBar or wButton's submenu)
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


proc tabStop(self: wControl, forward = true): wControl =

  proc isTabStop(self: wControl): bool =
    # syslink control has some unexceptable weird behavior to change it's own WS_TABSTOP
    # so we always assume that wHyperLinkCtrl control has WS_TABSTOP flag

    if isFocusable() and ((GetWindowLongPtr(mHwnd, GWL_STYLE).DWORD and WS_TABSTOP) != 0 or self of wHyperLinkCtrl):
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
proc mnemonicStop(self: wControl, letter: char, onlyone: var bool): wControl =
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
    # let the control have a change to deny the navigation action
    let naviEvent = Event(window=self, msg=wEvent_Navigation, wParam=event.wParam, lParam=event.lParam)
    if self.processEvent(naviEvent) and not naviEvent.isAllowed:
      return false
    else:
      return true

  proc trySetFocus(control: wControl): bool {.discardable.} =
    if control != nil:
      control.setFocus()
      processed = true
      result = true

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
        trySetFocus(self.getNextTab(previous=if event.shiftDown: true else: false))

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
        let control = self.mnemonicStop(ch, onlyone)
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

proc init(self: wControl, className: string, parent: wWindow, id: wCommandID = -1, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0, callback: proc(self: wWindow) = nil) =

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

  self.wWindow.init(title=label, className=className, parent=parent, pos=pos, size=size,
    style=style or WS_CHILD, fgColor=parent.mForegroundColor, bgColor=parent.mBackgroundColor,
    id=HMENU(id), regist=false, callback=callback)

  SetWindowSubclass(mHwnd, wSubProc, cast[UINT_PTR](self), cast[DWORD_PTR](self))

  mFocusable = true # by default, all control can has focus, modify this by subclass

  systemConnect(WM_KILLFOCUS, wControl_DoKillFocus)
  systemConnect(WM_SETFOCUS, wControl_DoSetFocus)
  hardConnect(WM_CHAR, wControl_OnNavigation)
  hardConnect(WM_KEYDOWN, wControl_OnNavigation)
  hardConnect(WM_SYSCHAR, wControl_OnNavigation)
  # wAppDialogAdd(parent)

