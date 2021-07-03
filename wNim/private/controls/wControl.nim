#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This is the base class for a GUI controls.
#
## :Superclass:
##   `wWindow <wWindow.html>`_
#
## :Subclasses:
##   `wStatusBar <wStatusBar.html>`_
##   `wToolBar <wToolBar.html>`_
##   `wButton <wButton.html>`_
##   `wCheckBox <wCheckBox.html>`_
##   `wRadioButton <wRadioButton.html>`_
##   `wStaticBox <wStaticBox.html>`_
##   `wListBox <wListBox.html>`_
##   `wTextCtrl <wTextCtrl.html>`_
##   `wComboBox <wComboBox.html>`_
##   `wCheckComboBox <wCheckComboBox.html>`_
##   `wStaticText <wStaticText.html>`_
##   `wStaticBitmap <wStaticBitmap.html>`_
##   `wStaticLine <wStaticLine.html>`_
##   `wNoteBook <wNoteBook.html>`_
##   `wSpinCtrl <wSpinCtrl.html>`_
##   `wSpinButton <wSpinButton.html>`_
##   `wSlider <wSlider.html>`_
##   `wScrollBar <wScrollBar.html>`_
##   `wGauge <wGauge.html>`_
##   `wCalendarCtrl <wCalendarCtrl.html>`_
##   `wDatePickerCtrl <wDatePickerCtrl.html>`_
##   `wTimePickerCtrl <wTimePickerCtrl.html>`_
##   `wListCtrl <wListCtrl.html>`_
##   `wTreeCtrl <wTreeCtrl.html>`_
##   `wHyperlinkCtrl <wHyperlinkCtrl.html>`_
##   `wSplitter <wSplitter.html>`_
##   `wIpCtrl <wIpCtrl.html>`_
##   `wWebView <wWebView.html>`_
##   `wHotkeyCtrl <wHotkeyCtrl.html>`_
##   `wRebar <wRebar.html>`_
##   `wMenuBarCtrl <wMenuBarCtrl.html>`_

include ../pragma
import strutils
import ../wBase, ../wWindow, ../wEvent
export wWindow, wEvent

# GUI controls by default don't apply the window margin setting,
# (except wStaticBox and wNoteBook, however they have their own override)
method getClientSize*(self: wControl): wSize {.property.} =
  ## Returns the size of the control 'client area' in pixels.
  var r: RECT
  GetClientRect(self.mHwnd, r)
  result.width = r.right - r.left
  result.height = r.bottom - r.top

method getClientAreaOrigin*(self: wControl): wPoint {.property.} =
  ## Gets the origin of the client area of the control.
  result = (0, 0)

proc setBuddy*(self: wControl, buddy: wControl, direction: int = wRight,
    length = wDefault, indent = 0) {.validate.} =
  ## Sets a control as the *buddy* to this control. The *buddy* control will be
  ## attached to the border specified by *direction* (wUp, wDown, wLeft, wRight),
  ## and occupies part of non-client area in *length*. *buddy* can be nil to cancel
  ## the relationship. Notice: *buddy* control should be a sibling, not a child.
  ##
  ## For example, a text control with a "Browse" button as a buddy:
  ##
  ## .. code-block:: Nim
  ##   let textctrl = TextCtrl(panel, style=wBorderSunken, pos=(10, 10))
  ##   let button = Button(panel, label="...")
  ##   textctrl.setBuddy(button, wRight, length=25)

  var
    bEdge: RECT
    buddyWidth: int
    buddyHeight: int

  proc getBuddyRect(rect: var RECT) =
    case direction
    of wLeft:
      rect.top += bEdge.top
      rect.bottom -= bEdge.bottom
      rect.left = rect.left + bEdge.left
      rect.right = rect.left + buddyWidth

    of wRight:
      rect.top += bEdge.top
      rect.bottom -= bEdge.bottom
      rect.right -= bEdge.right
      rect.left = rect.right - buddyWidth

      if bEdge.right > bEdge.left: # scrollbars here
        OffsetRect(rect, bEdge.right - bEdge.left, 0)

    of wUp, wDown:
      rect.left = rect.left + bEdge.left
      rect.right -= bEdge.right
      if direction == wUp:
        rect.top += bEdge.top
        rect.bottom = rect.top + buddyHeight
      else:
        rect.bottom -= bEdge.bottom
        rect.top = rect.bottom - buddyHeight

      if bEdge.right > bEdge.left: # scrollbars here
        rect.right += bEdge.right - bEdge.left

    else:
      rect.reset()

  proc onNcCalcSize(event: wEvent) =
    let prect = cast[ptr RECT](event.mLparam)
    var oldRect: RECT = prect[]

    event.postDefaultHandler:
      bEdge.left = prect.left - oldrect.left + indent
      bEdge.right = oldrect.right - prect.right + indent
      bEdge.top = prect.top - oldrect.top + indent
      bEdge.bottom = oldrect.bottom - prect.bottom + indent

      case direction
      of wRight: prect[].right -= buddyWidth
      of wLeft: prect[].left += buddyWidth
      of wUp: prect[].top += buddyHeight
      of wDown: prect[].bottom -= buddyHeight
      else: discard

  proc onSize(event: wEvent) =
    event.skip
    var rc: RECT
    GetWindowRect(self.mHwnd, rc)
    getBuddyRect(rc)

    MapWindowPoints(0, self.mParent.mHwnd, cast[LPPOINT](&rc), 2)
    SetWindowPos(buddy.mHwnd, 0, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top,
      SWP_NOZORDER or SWP_NOREPOSITION or SWP_NOACTIVATE)

  proc onNcHitTest(event: wEvent) =
    var pt = POINT(x: GET_X_LPARAM(event.mLparam), y: GET_Y_LPARAM(event.mLparam))
    var rc: RECT
    GetWindowRect(self.mHwnd, rc)
    getBuddyRect(rc)

    when not defined(Nimdoc):
      if PtInRect(rc, pt):
        event.result = HTTRANSPARENT
      else:
        event.skip

  self.disconnect(WM_NCHITTEST, onNcHitTest)
  self.disconnect(WM_NCCALCSIZE, onNcCalcSize)
  self.disconnect(wEvent_Size, onSize)

  if not buddy.isNil and direction in {wLeft, wUp, wRight, wDown}:
    if self.mParent != buddy.mParent:
      raise newException(wError, "buddy control must have the same parent")

    (buddyWidth, buddyHeight) = if length == wDefault: buddy.getSize() else: (length, length)
    self.connect(WM_NCHITTEST, onNcHitTest)
    self.connect(WM_NCCALCSIZE, onNcCalcSize)
    self.connect(wEvent_Size, onSize)

    # SetWindowPos(buddy.mHwnd, self.mHwnd, 0, 0, 0, 0,
    #   SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE)

  SetWindowPos(self.mHwnd, 0, 0, 0, 0, 0,
    SWP_FRAMECHANGED or SWP_DRAWFRAME or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOZORDER)

  self.processMessage(wEvent_Size)

proc showAndNotifyParent(self: wControl, flag = true) {.shield.} =
  let shown = self.isShownOnScreen()
  procCall wBase.wWindow(self).show(flag)
  if shown != self.isShownOnScreen():
    # parent's client size changed
    let rect = self.mParent.getWindowRect(sizeOnly=true)
    self.mParent.processMessage(wEvent_Size, SIZE_RESTORED,
      MAKELPARAM(rect.width, rect.height))

proc getNextGroup(self: wControl, previous: bool): wControl =
  var hWnd = self.mHwnd
  while true:
    hWnd = GetNextDlgGroupItem(self.mParent.mHwnd, hWnd, previous)
    if hWnd == 0 or hWnd == self.mHwnd:
      break

    let win = wAppWindowFindByHwnd(hWnd)
    if win != nil and win of wBase.wControl and win.isFocusable():
      return wBase.wControl(win)

proc getNextTab(self: wControl, previous: bool): wControl =
  var hWnd = self.mHwnd
  while true:
    hWnd = GetNextDlgTabItem(self.mParent.mHwnd, hWnd, previous)
    if hWnd == 0 or hWnd == self.mHwnd:
      break

    let win = wAppWindowFindByHwnd(hWnd)
    if win != nil and win of wBase.wControl and win.isFocusable():
      return wBase.wControl(win)

proc getNextMnemonic(self: wControl, letter: char, onlyone: var bool): wControl =
  # return control with specified letter,
  # however, click only there is one control with this letter
  if self.mParent == nil or self.mParent.mChildren.len == 0: return

  let
    siblings = self.mParent.mChildren
    this = siblings.find(self)

  var index = this
  while true:
    index.inc
    if index >= siblings.len: index = 0

    if siblings[index] of wBase.wControl:
      let control = wBase.wControl(siblings[index])
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
  if not (event.mWindow of wBase.wControl):
    event.skip
    return true

proc wControl_DoKillFocus(event: wEvent) =
  if event.notControl(): return

  let self = wBase.wControl(event.mWindow)
  if not self.isFocusable(): return

  # always save current focus to top level window
  # if top level window get focus after window switch, the control can get focus again
  self.getTopParent().mSaveFocusHwnd = self.mHwnd

  # who will get focus is not siblings => clear all default button
  let winGotFocus = wAppWindowFindByHwnd(HWND event.mWparam)
  if winGotFocus == nil or winGotFocus.mParent != self.mParent:
    self.drawSiblingButtons() do (win: wWindow) -> bool: false

proc wControl_DoSetFocus(event: wEvent) {.shield.} =
  if event.notControl(): return

  let self = wBase.wControl(event.mWindow)
  if not self.isFocusable(): return

  # some button get focus => set itself and clear all others
  if self of wButton:
    self.drawSiblingButtons() do (win: wWindow) -> bool: win == self

  # some other control get focus => set by button's setting
  else:
    self.drawSiblingButtons() do (win: wWindow) -> bool: wButton(win).mDefault

proc wControl_OnNavigation(event: wEvent) =
  if event.notControl(): return
  let self = wBase.wControl(event.mWindow)
  var processed = false
  defer: event.skip(if processed: false else: true)

  proc isAllowed(): bool =
    # let the control have a change to veto the navigation action
    let naviEvent = Event(window=self, msg=wEvent_Navigation, wParam=event.mWparam, lParam=event.mLparam)
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
    # todo: isAllowed for notebook?

    proc focusNext(self: wNoteBook): bool =
      if self.mPages.len >= 1:
        var index = self.mSelection + 1
        if index >= self.mPages.len: index = 0
        self.setFocus()
        # MSDN: Changing the focus also changes the selected tab.
        # In this case, the tab control sends the TCN_SELCHANGING and TCN_SELCHANGE
        # notification codes to its parent window.
        SendMessage(self.mHwnd, TCM_SETCURFOCUS, index, 0)
        return true

    proc focusPrev(self: wNoteBook): bool =
      if self.mPages.len >= 1:
        var index = self.mSelection - 1
        if index < 0: index = self.mPages.len - 1
        self.setFocus()
        SendMessage(self.mHwnd, TCM_SETCURFOCUS, index, 0)
        return true

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


  let keyCode = event.getKeyCode()
  case event.getEventMessage()
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
          SendMessage(self.mHwnd, BM_CLICK, 0, 0)
          processed = true

        else:
          for win in self.siblings:
            if win of wButton and wButton(win).mDefault:
              SendMessage(win.mHwnd, BM_CLICK, 0, 0)
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
        notebookChangeTab(keyCode==VK_PRIOR)

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

method processNotify(self: wControl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool {.shield.} =

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

wClass(wControl of wWindow):

  method release*(self: wControl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wControl, className: string, parent: wWindow,
      id: wCommandID = -1, label: string = "", pos = wDefaultPoint,
      size = wDefaultSize, style: wStyle = 0) {.validate.} =
    ## Initializes a GUI control by given window class name. Only useful to
    ## implement a custom wNim GUI control.
    wValidate(parent)
    var
      size = size
      style = style

    var lastControl: wWindow = nil
    for i in countdown(parent.mChildren.len - 1, 0):
      let child = parent.mChildren[i]
      if child of wBase.wControl:
        lastControl = child
        break

    # By default, first non radiobutton (include first of all) or last radiobutton
    # must has WS_GROUP style

    if lastControl == nil or (self of wRadioButton) != (lastControl of wRadioButton):
      style = style or WS_GROUP

    self.wWindow.initVerbosely(title=label, className=className, parent=parent, pos=pos, size=size,
      style=style or WS_CHILD, fgColor=parent.mForegroundColor, bgColor=parent.mBackgroundColor,
      id=HMENU(id), regist=false)

    SetWindowSubclass(self.mHwnd, wSubProc, cast[UINT_PTR](self), cast[DWORD_PTR](self))

    self.mFocusable = true # by default, all control can has focus, modify this by subclass

    self.systemConnect(WM_KILLFOCUS, wControl_DoKillFocus)
    self.systemConnect(WM_SETFOCUS, wControl_DoSetFocus)
    self.hardConnect(WM_CHAR, wControl_OnNavigation)
    self.hardConnect(WM_KEYDOWN, wControl_OnNavigation)
    self.hardConnect(WM_SYSCHAR, wControl_OnNavigation)
