
proc isVertical*(self: wScrollBar): bool =
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and SBS_VERT) != 0

method getDefaultSize*(self: wScrollBar): wSize =
  result = getAverageASCIILetterSize(mFont.mHandle)

  if isVertical():
    result.width = GetSystemMetrics(SM_CXVSCROLL).int
    result.height = MulDiv(result.height.int32, 107, 8).int
  else:
    result.height = GetSystemMetrics(SM_CXHSCROLL).int
    result.width = MulDiv(result.width.int32, 107, 4).int

method getBestSize*(self: wScrollBar): wSize =
  result = getDefaultSize()

proc setScrollbar*(self: wScrollBar, position = 0, thumbSize = 1, range = 2, pageSize = 1) =
  assert position >= 0 and thumbSize >= 1 and pageSize >= 1 and range >= 0
  assert range - pageSize >= 0

  mPageSize = pageSize
  mRange = range

  var max = max(range - pageSize, 0)
  if pageSize > 1:
    max += pageSize - 1

  var info = SCROLLINFO(cbSize: sizeof(SCROLLINFO).int32)
  info.fMask = SIF_POS or SIF_PAGE or SIF_RANGE
  info.nPos = position.int32
  info.nPage = thumbSize.int32
  info.nMin = 0
  info.nMax = max.int32
  SetScrollInfo(mHwnd, SB_CTL, addr info, true)

proc setThumbPosition*(self: wScrollBar, position: int) =
  var info = SCROLLINFO(cbSize: sizeof(SCROLLINFO).int32)
  info.fMask = SIF_POS
  info.nPos = position.int32
  SetScrollInfo(mHwnd, SB_CTL, addr info, true)

proc getScrollInfo(self: wScrollBar): SCROLLINFO =
  result = SCROLLINFO(cbSize: sizeof(SCROLLINFO).int32)
  result.fMask = SIF_ALL
  GetScrollInfo(mHwnd, SB_CTL, addr result)

proc getPageSize*(self: wScrollBar): int =
  result = mPageSize

proc getRange*(self: wScrollBar): int =
  result = mRange

proc getThumbSize*(self: wScrollBar): int =
  let info = getScrollInfo()
  result = info.nPage.int

proc getThumbPosition*(self: wScrollBar): int =
  let info = getScrollInfo()
  result = info.nPos.int

proc wScrollBarInit*(self: wScrollBar, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  self.wControl.init(className=WC_SCROLLBAR, parent=parent, id=id, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)
  setScrollbar(0, 1, 2, 1)

  if isVertical():
    mKeyUsed = {wUSE_UP, wUSE_DOWN}
  else:
    mKeyUsed = {wUSE_RIGHT, wUSE_LEFT}

  proc scrollEventHandler(event: wEvent) =
    let info = self.getScrollInfo()
    var
      position = info.nPos.int
      maxPos = info.nMax.int

    if mPageSize > 1:
      maxPos -= mPageSize - 1

    var processed: bool
    let eventType = case LOWORD(event.mWparam)
      of SB_TOP:
        position = 0
        wEvent_ScrollTop
      of SB_BOTTOM:
        position = maxPos
        wEvent_ScrollBottom
      of SB_LINEUP:
        position.dec
        wEvent_ScrollLineUp
      of SB_LINEDOWN:
        position.inc
        wEvent_ScrollLineDown
      of SB_PAGEUP:
        position.dec(mPageSize)
        wEvent_ScrollPageUp
      of SB_PAGEDOWN:
        position.inc(mPageSize)
        wEvent_ScrollPageDown
      of SB_THUMBPOSITION:
        position = info.nTrackPos
        wEvent_ScrollThumbRelease
      of SB_THUMBTRACK:
        position = info.nTrackPos
        wEvent_ScrollThumbTrack
      of SB_ENDSCROLL:
        wEvent_ScrollChanged
      else: 0

    if position != info.nPos.int:
      if position < 0: position = 0
      if position > maxPos: position = maxPos

      self.setThumbPosition(position)

    elif eventType != wEvent_ScrollThumbRelease and eventType != wEvent_ScrollChanged:
      return

    if eventType != 0:
      discard self.mMessageHandler(self, eventType, event.mWparam, event.mLparam, processed)

      processed = false
      event.mResult = self.mMessageHandler(self, wEvent_ScrollBar, event.mWparam, event.mLparam, processed)

  parent.systemConnect(WM_HSCROLL, scrollEventHandler)
  parent.systemConnect(WM_VSCROLL, scrollEventHandler)

proc ScrollBar*(parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wScrollBar =
  new(result)
  result.wScrollBarInit(parent=parent, id=id, pos=pos, size=size, style=style)

# for wScrollEvent

proc getPosition*(self: wScrollEvent): int =
  if mWindow of wScrollBar:
    let scrollbar = cast[wScrollBar](mWindow)
    result = scrollbar.getThumbPosition()
  elif mWindow of wSlider:
    let slider = cast[wSlider](mWindow)
    result = slider.getValue()

proc getOrientation*(self: wScrollEvent): int =
  if self.mMsg == WM_HSCROLL:
    result = wHorizontal
  elif self.mMsg == WM_VSCROLL:
    result = wVertical

# nim style getter/setter

proc pageSize*(self: wScrollBar): int = getPageSize()
proc range*(self: wScrollBar): int = getRange()
proc thumbSize*(self: wScrollBar): int = getThumbSize()
proc thumbPosition*(self: wScrollBar): int = getThumbPosition()
proc `thumbPosition=`*(self: wScrollBar, position: int) = setThumbPosition(position)
