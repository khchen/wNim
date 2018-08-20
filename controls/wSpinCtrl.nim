## wSpinCtrl combines wTextCtrl and wSpinButton in one control.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wSpReadOnly                     The value will not be user-editable.
##    wSpLeft                         The text is left aligned (this is the default).
##    wSpCenter                       The text is centered.
##    wSpRight                        The text is right aligned.
##    wSpArrowKeys                    The value wraps at the minimum and maximum.
##    wSpWrap                         The user can use arrow keys to change the value.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wSpinEvent                      Description
##    ==============================  =============================================================
##    wEvent_Spin                     Pressing an arrow changed the spin button value. This event can be vetoed.
##    wEvent_SpinUp                   Pressing up/right arrow changed the spin button value. This event can be vetoed.
##    wEvent_SpinDown                 Pressing down/left arrow changed the spin button value. This event can be vetoed.
##    ==============================  =============================================================

const
  # SpinCtrl styles
  wSpReadOnly* = ES_READONLY
  wSpLeft* = ES_LEFT
  wSpCenter* = ES_CENTER
  wSpRight* = ES_RIGHT
  # avoid style clash
  wSpArrowKeys* = 0x10000000 shl 32
  wSpWrap* = 0x20000000 shl 32

method getWindowRect(self: wSpinCtrl, sizeOnly = false): wRect =
  result = procCall wWindow(self).getWindowRect()
  result.width += mUpdownWidth

method setWindowRect(self: wSpinCtrl, x, y, width, height, flag = 0) =
  var
    width = width
    height = height
    flag = flag
    noSize = false

  if mUpdownHwnd != 0:
    if (flag and SWP_NOSIZE) != 0:
      # move only, but we must set size so that UDM_SETBUDDY works
      let rect = getWindowRect(sizeOnly=true)
      width = rect.width
      height = rect.height
      flag = flag and (not SWP_NOSIZE)
      noSize = true

  # cache the event and resent them after UDM_SETBUDDY
  var cacheSizeEvent, cacheMoveEvent: wEvent
  connect(WM_SIZE) do (event: wEvent):
    cacheSizeEvent = wEvent(mWparam: event.mWparam, mLparam: event.mLparam)

  connect(WM_MOVE) do (event: wEvent):
    cacheMoveEvent = wEvent(mWparam: event.mWparam, mLparam: event.mLparam)

  procCall wWindow(self).setWindowRect(x, y, width, height, flag)

  if mUpdownHwnd != 0:
    # reset buddy control, edit control size will be modified by UDM_SETBUDDY
    SendMessage(mUpdownHwnd, UDM_SETBUDDY, mHwnd, 0)

  disconnect(WM_SIZE, 1)
  disconnect(WM_MOVE, 1)

  if cacheMoveEvent != nil:
    SendMessage(mHwnd, WM_MOVE, cacheMoveEvent.mWparam, cacheMoveEvent.mLparam)

  if cacheSizeEvent != nil and not noSize:
    SendMessage(mHwnd, WM_SIZE, cacheSizeEvent.mWparam, cacheSizeEvent.mLparam)

method show*(self: wSpinCtrl, flag = true) {.inline.} =
  ## Shows or hides the control.
  procCall wWindow(self).show(flag)
  ShowWindow(mUpdownHwnd, if flag: SW_SHOWNORMAL else: SW_HIDE)

method getDefaultSize*(self: wSpinCtrl): wSize {.property.} =
  ## Returns the default size for the control.
  result.width = 120
  result.height = getLineControlDefaultHeight(mFont.mHandle)

method getBestSize*(self: wSpinCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getTextFontSize("0000  ", mFont.mHandle)
  result.height = getLineControlDefaultHeight(mFont.mHandle)
  result.width += mUpdownWidth

proc getBase*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Returns the numerical base being currently used, 10 by default.
  result = int SendMessage(mUpdownHwnd, UDM_GETBASE, 0, 0)

proc setBase*(self: wSpinCtrl, base: int) {.validate, property, inline.} =
  ## Sets the base to use for the numbers in this control, 10 or 16.
  SendMessage(mUpdownHwnd, UDM_SETBASE, base, 0)

proc getRange*(self: wSpinCtrl): Slice[int] {.validate, property, inline.} =
  ## Gets range of allowable value.
  var range: Slice[DWORD]
  SendMessage(mUpdownHwnd, UDM_GETRANGE32, &range.a, &range.b)
  result.a = range.a
  result.b = range.b

proc setRange*(self: wSpinCtrl, min: int, max: int) {.validate, property, inline.} =
  ## Sets range of allowable values.
  SendMessage(mUpdownHwnd, UDM_SETRANGE32, min, max)

proc setRange*(self: wSpinCtrl, range: Slice[int]) {.validate, property, inline.} =
  ## Sets range of allowable values.
  SendMessage(mUpdownHwnd, UDM_SETRANGE32, range.a, range.b)

proc getMin*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Gets minimal allowable value.
  result = getRange().a

proc getMax*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Gets maximal allowable value.
  result = getRange().b

proc getValue*(self: wSpinCtrl): int {.validate, property, inline.} =
  ## Gets the value of the spin control.
  var flag: BOOL
  result = int SendMessage(mUpdownHwnd, UDM_GETPOS32, 0, &flag)
  if flag != 0:
    result = getMin()

proc getText*(self: wSpinCtrl): string {.validate, property, inline.} =
  ## Gets the text of the spin control.
  result = getTitle()

proc setValue*(self: wSpinCtrl, value: int) =
  ## Sets the value of the spin control.
  SendMessage(mUpdownHwnd, UDM_SETPOS32, 0, value)

proc setValue*(self: wSpinCtrl, text: string) {.validate, property, inline.} =
  ## Sets the value of the spin control.
  wValidate(text)
  setTitle(text)

proc setText*(self: wSpinCtrl, text: string) {.validate, property, inline.} =
  ## Sets the text of the spin control. The same as setValue().
  wValidate(text)
  setValue(text)

proc setSelection*(self: wSpinCtrl, range: Slice[int]) {.validate, property, inline.} =
  ## Select the text in the text part of the control.
  SendMessage(mHwnd, EM_SETSEL, range.a, range.b + 1)

proc getUpdownHandle*(self: wSpinCtrl): HANDLE {.validate, property, inline.} =
  ## Gets the system handle of the updown control.
  result = mUpdownHwnd

proc wSpinCtrl_OnNotify(self: wSpinCtrl, event: wEvent) =
  var processed = false
  defer: event.skip(if processed: false else: true)

  let lpnmud = cast[LPNMUPDOWN](event.lParam)
  if lpnmud.hdr.hwndFrom == mUpdownHwnd and lpnmud.hdr.code == UDN_DELTAPOS:
    var spinEvent = Event(window=self, msg=wEvent_Spin, wParam=event.wParam, lParam=event.lParam)

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
      event.result = spinEvent.result

proc init(self: wSpinCtrl, parent: wWindow, id: wCommandID = -1, value: string = "0",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =
  var
    textStyle = style and (not (wSpArrowKeys or wSpWrap)) or ES_AUTOHSCROLL or wBorderSunken
    updownStyle = UDS_ALIGNRIGHT or UDS_SETBUDDYINT or UDS_HOTTRACK
    useArrowKeys = false

  if (style and wSpArrowKeys) != 0:
    updownStyle = updownStyle or UDS_ARROWKEYS
    useArrowKeys = true

  if (style and wSpWrap) != 0:
    updownStyle = updownStyle or UDS_WRAP

  self.wControl.init(className=WC_EDIT, parent=parent, id=id, label=value, pos=pos, size=size,
    style=textStyle or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  mUpdownHwnd = CreateWindowEx(0, UPDOWN_CLASS, nil, updownStyle or WS_CHILD or WS_VISIBLE,
    0, 0, 0, 0, parent.mHwnd, 0, wAppGetInstance(), nil)

  # UDM_SETBUDDY will shorten the edit control, so we can count mUpdownWidth
  var rect1, rect2: RECT
  GetWindowRect(mHwnd, rect1)
  SendMessage(mUpdownHwnd, UDM_SETBUDDY, mHwnd, 0)
  GetWindowRect(mHwnd, rect2)
  mUpdownWidth = int(rect1.right - rect2.right)

  # a spin control by default have white background, not parent's background
  setBackgroundColor(wWhite)
  setRange(0, 100) # the default value is 100~0 ?

  systemConnect(WM_NCDESTROY) do (event: wEvent):
    DestroyWindow(mUpdownHwnd)
    mUpdownHwnd = 0

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.lParam == mHwnd and HIWORD(event.wParam) == EN_CHANGE:
      self.processMessage(wEvent_Text, 0, 0)

    # cannot use processNotify method becasue the notify sent to updown's parent
  parent.hardConnect(WM_NOTIFY) do (event: wEvent):
    wSpinCtrl_OnNotify(self, event)

  hardConnect(wEvent_Navigation) do (event: wEvent):
    if useArrowKeys:
      if event.keyCode in {wKey_Left, wKey_Right, wKey_Up, wKey_Down}:
        event.veto
    else:
      # we always need left and right for text input
      if event.keyCode in {wKey_Left, wKey_Right}:
        event.veto

proc SpinCtrl*(parent: wWindow, id: wCommandID = wDefaultID, value: string = "0",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wSpLeft): wSpinCtrl {.discardable.} =
  ## Constructor, creating and showing a spin control. Value as text.
  wValidate(parent)
  new(result)
  result.init(parent=parent, id=id, value=value, pos=pos, size=size, style=style)

proc SpinCtrl*(parent: wWindow, id: wCommandID = wDefaultID, value: int,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wSpLeft): wSpinCtrl {.discardable.} =
  ## Constructor, creating and showing a spin control. Value as int.
  wValidate(parent)
  new(result)
  result.init(parent=parent, id=id, value=($value), pos=pos, size=size, style=style)
