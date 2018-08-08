
proc isVertical*(self: wSlider): bool =
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and TBS_VERT) != 0

method getDefaultSize*(self: wSlider): wSize =
  result = getAverageASCIILetterSize(mFont.mHandle)
  var x, y: int32

  if isVertical():
    x = 15
    y = 107
  else:
    x = 107
    y = 15

  result.width = MulDiv(result.width.int32, x, 4).int
  result.height = MulDiv(result.height.int32, y, 8).int

method getBestSize*(self: wSlider): wSize =
  result = getDefaultSize()

proc valueInvert(self: wSlider, value: int): int =
  if mReversed:
    result = mMax + mMin - value
  else:
    result = value

proc getValue*(self: wSlider): int =
  result = SendMessage(mHwnd, TBM_GETPOS, 0, 0).int.valueInvert

proc setValue*(self: wSlider, value: int) =
  SendMessage(mHwnd, TBM_SETPOS, TRUE, value.valueInvert)

proc setRange*(self: wSlider, range: Slice[int]) =
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

proc setMin*(self: wSlider, min: int) =
  setRange(min..mMax)

proc setMax*(self: wSlider, max: int) =
  setRange(mMin..max)

proc setRange*(self: wSlider, min, max: int) =
  setRange(min..max)

proc getMax*(self: wSlider): int =
  result = mMax

proc getMin*(self: wSlider): int =
  result = mMin

proc getPageSize*(self: wSlider): int =
  result = SendMessage(mHwnd, TBM_GETPAGESIZE, 0, 0).int

proc setPageSize*(self: wSlider, pageSize: int) =
  SendMessage(mHwnd, TBM_SETPAGESIZE, 0, pageSize)

proc getLineSize*(self: wSlider): int =
  result = SendMessage(mHwnd, TBM_GETLINESIZE, 0, 0).int

proc setLineSize*(self: wSlider, lineSize: int) =
  SendMessage(mHwnd, TBM_SETLINESIZE, 0, lineSize)

proc getThumbLength*(self: wSlider): int =
  result = SendMessage(mHwnd, TBM_GETTHUMBLENGTH, 0, 0).int

proc setThumbLength*(self: wSlider, length: int) =
  SendMessage(mHwnd, TBM_SETTHUMBLENGTH, length, 0)

proc getSelEnd*(self: wSlider): int =
  result = SendMessage(mHwnd, TBM_GETSELEND, 0, 0).int

proc getSelStart*(self: wSlider): int =
  result = SendMessage(mHwnd, TBM_GETSELSTART, 0, 0).int

proc getSelection*(self: wSlider): Slice[int] =
  result.a = getSelStart()
  result.b = getSelEnd()

proc setSelection*(self: wSlider, min, max: int) =
  SendMessage(mHwnd, TBM_SETSEL, TRUE, MAKELONG(min, max))

proc setSelection*(self: wSlider, range: Slice[int]) =
  setSelection(range.a, range.b)

proc setTickFreq*(self: wSlider, n: int) =
  SendMessage(mHwnd, TBM_SETTICFREQ, n, 0)

proc setTick*(self: wSlider, tick: int) =
  SendMessage(mHwnd, TBM_SETTIC, 0, tick)

proc clearSel*(self: wSlider) =
  SendMessage(mHwnd, TBM_CLEARSEL, TRUE, 0)

proc clearTicks*(self: wSlider, ) =
  SendMessage(mHwnd, TBM_CLEARTICS, TRUE, 0)


proc wSliderInit*(self: wSlider, parent: wWindow, id: wCommandID = -1, value = 0, range: Slice[int] = 0..100, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  self.wControl.init(className=TRACKBAR_CLASS, parent=parent, id=id, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)
  setValue(value)
  setRange(range)

  if isVertical():
    mKeyUsed = {wUSE_UP, wUSE_DOWN}
  else:
    mKeyUsed = {wUSE_RIGHT, wUSE_LEFT}

  proc scrollEventHandler(event: wEvent) =
    var processed: bool
    let eventType = case LOWORD(event.mWparam)
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
        if mDragging:
          mDragging = false
          wEvent_ScrollThumbRelease
        else:
          wEvent_ScrollChanged
      of SB_ENDSCROLL:
        wEvent_ScrollChanged
      else: 0

    if eventType != 0:
      discard self.mMessageHandler(self, eventType, event.mWparam, event.mLparam, processed)

      processed = false
      event.mResult = self.mMessageHandler(self, wEvent_Slider, event.mWparam, event.mLparam, processed)

  parent.systemConnect(WM_HSCROLL, scrollEventHandler)
  parent.systemConnect(WM_VSCROLL, scrollEventHandler)


proc Slider*(parent: wWindow, id: wCommandID = -1, value = 0, range: Slice[int] = 0..100, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wSlider =
  new(result)
  result.wSliderInit(parent=parent, value=value, range=range, id=id, pos=pos, size=size, style=style)

# nim style getter/setter

proc value*(self: wSlider): int = getValue()
proc max*(self: wSlider): int = getMax()
proc min*(self: wSlider): int = getMin()
proc pageSize*(self: wSlider): int = getPageSize()
proc lineSize*(self: wSlider): int = getLineSize()
proc thumbLength*(self: wSlider): int = getThumbLength()
proc selEnd*(self: wSlider): int = getSelEnd()
proc selStart*(self: wSlider): int = getSelStart()
proc selection*(self: wSlider): Slice[int] = getSelection()
proc `value=`*(self: wSlider, value: int) = setValue(value)
proc `range=`*(self: wSlider, range: Slice[int]) = setRange(range)
proc `min=`*(self: wSlider, min: int) = setMin(min)
proc `max=`*(self: wSlider, max: int) = setMax(max)
proc `pageSize=`*(self: wSlider, pageSize: int) = setPageSize(pageSize)
proc `lineSize=`*(self: wSlider, lineSize: int) = setLineSize(lineSize)
proc `thumbLength=`*(self: wSlider, length: int) = setThumbLength(length)
proc `selection=`*(self: wSlider, range: Slice[int]) = setSelection(range)
proc `tickFreq=`*(self: wSlider, n: int) = setTickFreq(n)
proc `tick=`*(self: wSlider, tick: int) = setTick(tick)
