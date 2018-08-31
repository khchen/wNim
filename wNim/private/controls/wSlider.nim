#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

## A slider is a control with a handle which can be pulled back and forth to change the value.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wSlHorizontal                   Displays the slider horizontally (this is the default).
##    wSlVertical                     Displays the slider vertically.
##    wSlAutoTicks                    Displays tick marks.
##    wSlLeft                         Displays ticks on the left and forces the slider to be vertical.
##    wSlRight                        Displays ticks on the right and forces the slider to be vertical.
##    wSlTop                          Displays ticks on the top.
##    wSlBottom                       Displays ticks on the bottom
##    wSlSelRange                     Allows the user to select a range on the slider.
##    wSlNoTicks                      Does not display any tick marks.
##    wSlNoThumb                      Does not display a thumb.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wScrollEvent                    Description
##    ==============================  =============================================================
##    wEvent_Slider                   Sent before all of following event. Use event.getKind to know what kind of type it is.
##    wEvent_ScrollTop                Scroll to top or leftmost.
##    wEvent_ScrollBottom             Scroll to bottom or rightmost.
##    wEvent_ScrollLineUp             Scroll line up or left
##    wEvent_ScrollLineDown           Scroll line down or right.
##    wEvent_ScrollPageUp             Scroll page up or left.
##    wEvent_ScrollPageDown           Scroll page down or right.
##    wEvent_ScrollThumbTrack         Frequent events sent as the user drags the thumbtrack.
##    wEvent_ScrollThumbRelease       Thumb release events.
##    wEvent_ScrollChanged            End of scrolling events
##    ==============================  =============================================================

const
  # Slider styles
  wSlHorizontal* = TBS_HORZ
  wSlVertical* = TBS_VERT
  wSlAutoTicks* = TBS_AUTOTICKS
  wSlLeft* = TBS_LEFT or TBS_VERT
  wSlRight* = TBS_RIGHT or TBS_VERT
  wSlTop* = TBS_TOP or TBS_HORZ
  wSlBottom* = TBS_BOTTOM or TBS_HORZ
  wSlSelRange* = TBS_ENABLESELRANGE
  wSlNoTicks* = TBS_NOTICKS
  wSlNoThumb* = TBS_NOTHUMB

proc isVertical*(self: wSlider): bool {.validate, inline.} =
  ## Returns true for slider that have the vertical style set.
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and TBS_VERT) != 0

method getDefaultSize*(self: wSlider): wSize {.property.} =
  ## Returns the default size for the control.
  result = getAverageASCIILetterSize(mFont.mHandle)
  var x, y: int32
  if isVertical():
    x = 15
    y = 107
  else:
    x = 107
    y = 15

  result.width = MulDiv(result.width, x, 4)
  result.height = MulDiv(result.height, y, 8)

method getBestSize*(self: wSlider): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = getDefaultSize()

proc valueInvert(self: wSlider, value: int): int =
  if mReversed:
    result = mMax + mMin - value
  else:
    result = value

proc getValue*(self: wSlider): int {.validate, property, inline.} =
  ## Gets the current slider value.
  result = SendMessage(mHwnd, TBM_GETPOS, 0, 0).int.valueInvert

proc setValue*(self: wSlider, value: int) {.validate, property, inline.} =
  ## Sets the slider position.
  SendMessage(mHwnd, TBM_SETPOS, TRUE, value.valueInvert)

proc setRange*(self: wSlider, range: Slice[int]) {.validate, property.} =
  ## Sets the minimum and maximum slider values.
  var range = range
  if range.a > range.b:
    mReversed = true
    swap(range.a, range.b)
  else:
    mReversed = false

  mMin = range.a
  mMax = range.b
  SendMessage(mHwnd, TBM_SETRANGEMIN, TRUE, range.a)
  SendMessage(mHwnd, TBM_SETRANGEMAX, TRUE, range.b)

proc setMin*(self: wSlider, min: int) {.validate, property, inline.} =
  ## Sets the minimum slider value.
  setRange(min..mMax)

proc setMax*(self: wSlider, max: int) {.validate, property, inline.} =
  ## Sets the maximum slider value.
  setRange(mMin..max)

proc setRange*(self: wSlider, min: int, max: int) {.validate, property, inline.} =
  setRange(min..max)

proc getMax*(self: wSlider): int {.validate, property, inline.} =
  ## Gets the maximum slider value.
  result = mMax

proc getMin*(self: wSlider): int {.validate, property, inline.} =
  ## Gets the minimum slider value.
  result = mMin

proc getPageSize*(self: wSlider): int {.validate, property, inline.} =
  ## Returns the page size.
  result = int SendMessage(mHwnd, TBM_GETPAGESIZE, 0, 0)

proc setPageSize*(self: wSlider, pageSize: int) {.validate, property, inline.} =
  ## Sets the page size for the slider.
  SendMessage(mHwnd, TBM_SETPAGESIZE, 0, pageSize)

proc getLineSize*(self: wSlider): int {.validate, property, inline.} =
  ## Returns the line size.
  result = int SendMessage(mHwnd, TBM_GETLINESIZE, 0, 0)

proc setLineSize*(self: wSlider, lineSize: int) {.validate, property, inline.} =
  ## Sets the line size for the slider.
  SendMessage(mHwnd, TBM_SETLINESIZE, 0, lineSize)

proc getThumbLength*(self: wSlider): int {.validate, property, inline.} =
  ## Sets the slider thumb length.
  result = int SendMessage(mHwnd, TBM_GETTHUMBLENGTH, 0, 0)

proc setThumbLength*(self: wSlider, length: int) {.validate, property, inline.} =
  ## Sets the slider thumb length.
  SendMessage(mHwnd, TBM_SETTHUMBLENGTH, length, 0)

proc getSelEnd*(self: wSlider): int {.validate, property, inline.} =
  ## Returns the selection end point.
  result = int SendMessage(mHwnd, TBM_GETSELEND, 0, 0)

proc getSelStart*(self: wSlider): int {.validate, property, inline.} =
  ## Returns the selection start point.
  result = int SendMessage(mHwnd, TBM_GETSELSTART, 0, 0)

proc getSelection*(self: wSlider): Slice[int] {.validate, property, inline.} =
  ## Returns the selection start and end point.
  result.a = getSelStart()
  result.b = getSelEnd()

proc setSelection*(self: wSlider, min: int, max: int) {.validate, property, inline.} =
  ## Sets the selection.
  SendMessage(mHwnd, TBM_SETSEL, TRUE, MAKELONG(min, max))

proc setSelection*(self: wSlider, range: Slice[int]) {.validate, property, inline.} =
  ## Sets the selection.
  setSelection(range.a, range.b)

proc setTickFreq*(self: wSlider, n: int) {.validate, property, inline.} =
  ## Sets the tick mark frequency and position, for a slider with the wSlAutoTicks style.
  SendMessage(mHwnd, TBM_SETTICFREQ, n, 0)

proc setTick*(self: wSlider, tick: int) {.validate, property, inline.} =
  ## Sets a tick position.
  SendMessage(mHwnd, TBM_SETTIC, 0, tick)

proc setTicks*(self: wSlider, ticks: openarray[int]) {.validate, property, inline.} =
  ## Sets mulpitle ticks at the same time.
  for tick in ticks: setTick(tick)

proc clearSel*(self: wSlider) {.validate, property, inline.} =
  ## Clears the selection, for a slider with the wSlSelRange style.
  SendMessage(mHwnd, TBM_CLEARSEL, TRUE, 0)

proc clearTicks*(self: wSlider, ) {.validate, property, inline.} =
  ## Clears the ticks.
  SendMessage(mHwnd, TBM_CLEARTICS, TRUE, 0)

proc final*(self: wSlider) =
  ## Default finalizer for wSlider.
  discard

proc init*(self: wSlider, parent: wWindow, id = wDefaultID,
    value = 0, range: Slice[int] = 0..100, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = wSlHorizontal) {.validate.} =

  wValidate(parent)
  self.wControl.init(className=TRACKBAR_CLASS, parent=parent, id=id, pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or TBS_FIXEDLENGTH)
  # TBS_FIXEDLENGTH is need so that TBM_SETTHUMBLENGTH works

  setValue(value)
  setRange(range)

  proc scrollEventHandler(event: wEvent) =
    if event.mLparam != self.mHwnd: return
    let eventKind = case LOWORD(event.mWparam)
      of SB_TOP: wEvent_ScrollTop
      of SB_BOTTOM: wEvent_ScrollBottom
      of SB_LINEUP: wEvent_ScrollLineUp
      of SB_LINEDOWN: wEvent_ScrollLineDown
      of SB_PAGEUP: wEvent_ScrollPageUp
      of SB_PAGEDOWN: wEvent_ScrollPageDown
      of SB_THUMBTRACK:
        mDragging = true
        wEvent_ScrollThumbTrack
      of SB_THUMBPOSITION:
        # this hack is because when mosue wheel is used, there won't
        # be a SB_ENDSCROLL but only SB_THUMBPOSITION.
        # However, we always want a wEvent_ScrollChanged if the value was changed.
        # So, in non-dragging situation, we sent a wEvent_ScrollChanged
        # instead of wEvent_ScrollThumbRelease.
        if mDragging:
          mDragging = false
          wEvent_ScrollThumbRelease
        else:
          wEvent_ScrollChanged
      of SB_ENDSCROLL: wEvent_ScrollChanged
      else: 0

    if eventKind != 0:
      var
        orientation = if self.isVertical(): wVertical else: wHorizontal
        scrollData = wScrollData(kind: eventKind, orientation: orientation)
        dataPtr = cast[LPARAM](&scrollData)

      # sent wEvent_Slider first, if this is processed, skip other event
      if not self.processMessage(wEvent_Slider, event.mWparam, dataPtr):
        self.processMessage(eventKind, event.mWparam, dataPtr)

  parent.systemConnect(WM_HSCROLL, scrollEventHandler)
  parent.systemConnect(WM_VSCROLL, scrollEventHandler)

  hardConnect(wEvent_Navigation) do (event: wEvent):
    if self.isVertical():
      if event.keyCode in {wKey_Up, wKey_Down}:
        event.veto
    else:
      if event.keyCode in {wKey_Right, wKey_Left}:
        event.veto

proc Slider*(parent: wWindow, id = wDefaultID, value = 0,
    range: Slice[int] = 0..100, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wSlHorizontal): wSlider {.inline, discardable.} =
  ## Constructor, creating and showing a slider.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, value, range, pos, size, style)
