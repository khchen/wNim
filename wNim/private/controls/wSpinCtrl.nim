#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## wSpinCtrl combines wTextCtrl and wSpinButton in one control.
#
## :Appearance:
##   .. image:: images/wSpinCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wSpReadOnly                     The value will not be user-editable.
##   wSpLeft                         The text is left aligned (this is the default).
##   wSpCenter                       The text is centered.
##   wSpRight                        The text is right aligned.
##   wSpArrowKeys                    The value wraps at the minimum and maximum.
##   wSpWrap                         The user can use arrow keys to change the value.
##   ==============================  =============================================================
#
## :Events:
##   `wSpinEvent <wSpinEvent.html>`_
##   `wCommandEvent <wCommandEvent.html>`_
##   ===============================  =============================================================
##   wSpinEvent                       Description
##   ===============================  =============================================================
##   wEvent_Spin                      Pressing an arrow changed the spin button value. This event can be vetoed.
##   wEvent_SpinUp                    Pressing up/right arrow changed the spin button value. This event can be vetoed.
##   wEvent_SpinDown                  Pressing down/left arrow changed the spin button value. This event can be vetoed.
##
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_Text                      When the text changes.
##   wEvent_TextEnter                 When pressing Enter key.
##   ===============================  =============================================================

include ../pragma
import ../wBase, wControl
export wControl

const
  # SpinCtrl styles
  wSpReadOnly* = ES_READONLY
  wSpLeft* = ES_LEFT
  wSpCenter* = ES_CENTER
  wSpRight* = ES_RIGHT
  # avoid style clash
  wSpArrowKeys* = 0x10000000.int64 shl 32
  wSpWrap* = 0x20000000.int64 shl 32

method getWindowRect(self: wSpinCtrl, sizeOnly = false): wRect =
  result = procCall wWindow(self).getWindowRect()
  result.width += self.mUpdownWidth

method setWindowRect(self: wSpinCtrl, x = 0, y = 0, width = 0, height = 0, flag = 0)
    {.shield.} =

  var
    width = width
    height = height
    flag = flag
    noSize = false

  if self.mUpdownHwnd != 0:
    if (flag and SWP_NOSIZE) != 0:
      # move only, but we must set size so that UDM_SETBUDDY works
      let rect = self.getWindowRect(sizeOnly=true)
      width = rect.width
      height = rect.height
      flag = flag and (not SWP_NOSIZE)
      noSize = true

  # cache the event and resent them after UDM_SETBUDDY
  var cacheSizeEvent, cacheMoveEvent: wEvent
  self.connect(WM_SIZE) do (event: wEvent):
    cacheSizeEvent = wEvent(mWparam: event.mWparam, mLparam: event.mLparam)

  self.connect(WM_MOVE) do (event: wEvent):
    cacheMoveEvent = wEvent(mWparam: event.mWparam, mLparam: event.mLparam)

  procCall wWindow(self).setWindowRect(x, y, width, height, flag)

  if self.mUpdownHwnd != 0:
    # reset buddy control, edit control size will be modified by UDM_SETBUDDY
    SendMessage(self.mUpdownHwnd, UDM_SETBUDDY, self.mHwnd, 0)

  self.disconnect(WM_SIZE, 1)
  self.disconnect(WM_MOVE, 1)

  if cacheMoveEvent != nil:
    SendMessage(self.mHwnd, WM_MOVE, cacheMoveEvent.mWparam, cacheMoveEvent.mLparam)

  if cacheSizeEvent != nil and not noSize:
    SendMessage(self.mHwnd, WM_SIZE, cacheSizeEvent.mWparam, cacheSizeEvent.mLparam)

method show*(self: wSpinCtrl, flag = true) {.inline.} =
  ## Shows or hides the control.
  procCall wWindow(self).show(flag)
  ShowWindow(self.mUpdownHwnd, if flag: SW_SHOWNORMAL else: SW_HIDE)

method getDefaultSize*(self: wSpinCtrl): wSize {.property.} =
  ## Returns the default size for the control.
  result.width = 120
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)

method getBestSize*(self: wSpinCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getTextFontSize("0000  ", self.mFont.mHandle, self.mHwnd)
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)
  result.width += self.mUpdownWidth

proc getBase*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Returns the numerical base being currently used, 10 by default.
  result = int SendMessage(self.mUpdownHwnd, UDM_GETBASE, 0, 0)

proc setBase*(self: wSpinCtrl, base: int) {.validate, property, inline.} =
  ## Sets the base to use for the numbers in this control, 10 or 16.
  SendMessage(self.mUpdownHwnd, UDM_SETBASE, base, 0)

proc getRange*(self: wSpinCtrl): Slice[int] {.validate, property, inline.} =
  ## Gets range of allowable value.
  var range: Slice[DWORD]
  SendMessage(self.mUpdownHwnd, UDM_GETRANGE32, &range.a, &range.b)
  result.a = range.a
  result.b = range.b

proc setRange*(self: wSpinCtrl, min: int, max: int) {.validate, property, inline.} =
  ## Sets range of allowable values.
  SendMessage(self.mUpdownHwnd, UDM_SETRANGE32, min, max)

proc setRange*(self: wSpinCtrl, range: Slice[int]) {.validate, property, inline.} =
  ## Sets range of allowable values.
  SendMessage(self.mUpdownHwnd, UDM_SETRANGE32, range.a, range.b)

proc getMin*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Gets minimal allowable value.
  result = self.getRange().a

proc getMax*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Gets maximal allowable value.
  result = self.getRange().b

proc getValue*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Gets the value of the spin control.
  var flag: BOOL
  result = int SendMessage(self.mUpdownHwnd, UDM_GETPOS32, 0, &flag)
  if flag != 0:
    result = self.getMin()

proc getText*(self: wSpinCtrl): string {.validate, property, inline.} =
  ## Gets the text of the spin control.
  result = self.getTitle()

proc setValue*(self: wSpinCtrl, value: int) =
  ## Sets the value of the spin control.
  SendMessage(self.mUpdownHwnd, UDM_SETPOS32, 0, value)

proc setValue*(self: wSpinCtrl, text: string) {.validate, property, inline.} =
  ## Sets the value of the spin control.
  self.setTitle(text)

proc setText*(self: wSpinCtrl, text: string) {.validate, property, inline.} =
  ## Sets the text of the spin control. The same as setValue().
  self.setValue(text)

proc setSelection*(self: wSpinCtrl, range: Slice[int]) {.validate, property, inline.} =
  ## Select the text in the text part of the control.
  SendMessage(self.mHwnd, EM_SETSEL, range.a, range.b + 1)

proc getUpdownHandle*(self: wSpinCtrl): HANDLE {.validate, property, inline.} =
  ## Gets the system handle of the updown control.
  result = self.mUpdownHwnd

proc wSpinCtrl_OnNotify(self: wSpinCtrl, event: wEvent) =
  var processed = false
  defer: event.skip(if processed: false else: true)

  let lpnmud = cast[LPNMUPDOWN](event.mLparam)
  if lpnmud.hdr.hwndFrom == self.mUpdownHwnd and lpnmud.hdr.code == UDN_DELTAPOS:
    var spinEvent = Event(window=self, msg=wEvent_Spin, wParam=event.mWparam,
      lParam=event.mLparam)

    if lpnmud.iDelta > 0:
      spinEvent.mMsg = wEvent_SpinUp
      processed = self.processEvent(spinEvent)

    elif lpnmud.iDelta < 0:
      spinEvent.mMsg = wEvent_SpinDown
      processed = self.processEvent(spinEvent)

    if not processed: # if not processed, always assume it is allowed
      spinEvent.mMsg = wEvent_Spin
      spinEvent.mResult = 0
      processed = self.processEvent(spinEvent)

    if processed:
      # Return nonzero to prevent the change, or zero to allow the change, same as our mResult
      event.mResult = spinEvent.mResult

wClass(wSpinCtrl of wControl):

  method release*(self: wSpinCtrl) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mCommandConn)
    self.mParent.disconnect(self.mNotifyConn)
    if self.mUpdownHwnd != 0:
      DestroyWindow(self.mUpdownHwnd)
      self.mUpdownHwnd = 0
    free(self[])

  proc init*(self: wSpinCtrl, parent: wWindow, id = wDefaultID,
      value: string = "0", pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = wSpLeft) {.validate.} =
    ## Initializes a spin control. Value as text.
    wValidate(parent)
    var
      textStyle = style and (not (wSpArrowKeys or wSpWrap)) or ES_AUTOHSCROLL or wBorderSunken
      updownStyle = UDS_ALIGNRIGHT or UDS_SETBUDDYINT or UDS_HOTTRACK
      useArrowKeys = false

    if (style and wSpArrowKeys) != 0:
      updownStyle = updownStyle or UDS_ARROWKEYS
      useArrowKeys = true

    if (style and wSpWrap) != 0:
      updownStyle = updownStyle or UDS_WRAP

    self.wControl.init(className=WC_EDIT, parent=parent, id=id, label=value,
      pos=pos, size=size, style=textStyle or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    self.mUpdownHwnd = CreateWindowEx(0, UPDOWN_CLASS, nil, updownStyle or
      WS_CHILD or WS_VISIBLE, 0, 0, 0, 0, parent.mHwnd, 0, wAppGetInstance(), nil)

    # UDM_SETBUDDY will shorten the edit control, so we can count mUpdownWidth
    var rect1, rect2: RECT
    GetWindowRect(self.mHwnd, rect1)
    SendMessage(self.mUpdownHwnd, UDM_SETBUDDY, self.mHwnd, 0)
    GetWindowRect(self.mHwnd, rect2)
    self.mUpdownWidth = int(rect1.right - rect2.right)

    # a spin control by default have white background, not parent's background
    self.setBackgroundColor(wWhite)
    self.setRange(0, 100) # the default value is 100~0 ?

    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      if event.mLparam == self.mHwnd and HIWORD(event.mWparam) == EN_CHANGE:
        self.processMessage(wEvent_Text, 0, 0)

    # cannot use processNotify method becasue the notify sent to updown's parent
    self.mNotifyConn = parent.hardConnect(WM_NOTIFY) do (event: wEvent):
      wSpinCtrl_OnNotify(self, event)

    self.hardConnect(WM_CHAR) do (event: wEvent):
      var processed = false
      defer: event.skip(if processed: false else: true)

      if event.getKeyCode() == VK_RETURN:
        processed = self.processMessage(wEvent_TextEnter, 0, 0)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if useArrowKeys:
        if event.getKeyCode() in {wKey_Left, wKey_Right, wKey_Up, wKey_Down}:
          event.veto
      else:
        # we always need left and right for text input
        if event.getKeyCode() in {wKey_Left, wKey_Right}:
          event.veto

  proc init*(self: wSpinCtrl, parent: wWindow, id = wDefaultID,
      value: int, pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = wSpLeft) {.validate.} =
    ## Initializes a spin control. Value as int.
    wValidate(parent)
    self.init(parent, id, $value, pos, size, style)
