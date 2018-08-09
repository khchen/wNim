## A wScrollBar is a control that represents a horizontal or vertical scrollbar.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wSbHorizontal                   Specifies a horizontal scrollbar.
##    wSbVertical                     Specifies a vertical scrollbar.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wScrollEvent                    Description
##    ==============================  =============================================================
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
  # ScrollBar styles
  wSbHorizontal* = SBS_HORZ
  wSbVertical* = SBS_VERT

proc isVertical*(self: wScrollBar): bool {.validate, inline.} =
  ## Returns true for scrollbars that have the vertical style set.
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and SBS_VERT) != 0

method getDefaultSize*(self: wScrollBar): wSize {.property.} =
  ## Returns the default size for the control.
  result = getAverageASCIILetterSize(mFont.mHandle)

  if isVertical():
    result.width = GetSystemMetrics(SM_CXVSCROLL)
    result.height = MulDiv(result.height, 107, 8)
  else:
    result.height = GetSystemMetrics(SM_CXHSCROLL)
    result.width = MulDiv(result.width, 107, 4)

method getBestSize*(self: wScrollBar): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getDefaultSize()

proc setScrollbar*(self: wScrollBar, position: Natural, pageSize: Positive,
    range: Positive) {.validate, property.} =
  ## Sets the scrollbar properties.
  var info = SCROLLINFO(
    cbSize: sizeof(SCROLLINFO),
    fMask: SIF_POS or SIF_PAGE or SIF_RANGE,
    nPos: int32 position,
    nPage: int32 pageSize,
    nMin: 0,
    nMax: int32 range)
  SetScrollInfo(mHwnd, SB_CTL, &info, true) # true for redraw

proc setScrollPos*(self: wScrollBar, position: Natural) {.validate, property.} =
  ## Sets the position of the scrollbar.
  var info = SCROLLINFO(
    cbSize: sizeof(SCROLLINFO),
    fMask: SIF_POS,
    nPos: int32 position)
  SetScrollInfo(mHwnd, SB_CTL, &info, true)

proc getScrollInfo(self: wScrollBar): SCROLLINFO {.validate, property.} =
  result = SCROLLINFO(
    cbSize: sizeof(SCROLLINFO),
    fMask: SIF_ALL)
  GetScrollInfo(mHwnd, SB_CTL, &result)

proc getPageSize*(self: wScrollBar): int {.validate, property, inline.} =
  ## Returns the page size.
  let info = getScrollInfo()
  result = info.nPage

proc getRange*(self: wScrollBar): int {.validate, property, inline.} =
  ## Returns the length of the scrollbar.
  let info = getScrollInfo()
  result = info.nMax

proc getScrollPos*(self: wScrollBar): int {.validate, property, inline.} =
  ## Returns the current position of the scrollbar.
  let info = getScrollInfo()
  result = info.nPos

proc init(self: wScrollBar, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = 0) =

  self.wControl.init(className=WC_SCROLLBAR, parent=parent, id=id, pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  setScrollbar(0, 1, 2)

  if isVertical():
    mKeyUsed = {wUSE_UP, wUSE_DOWN}
  else:
    mKeyUsed = {wUSE_RIGHT, wUSE_LEFT}

  proc scrollEventHandler(event: wEvent) =
    if event.mLparam == self.mHwnd:
      let orientation = if self.isVertical(): wVertical else: wHorizontal
      event.mResult = self.scrollEventHandlerImpl(orientation, event.mWparam, isControl=true)

  parent.systemConnect(WM_HSCROLL, scrollEventHandler)
  parent.systemConnect(WM_VSCROLL, scrollEventHandler)

proc ScrollBar*(parent: wWindow, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0): wScrollBar {.discardable.} =
  ## Constructor, creating and showing a scrollbar.
  wValidate(parent)
  new(result)
  result.init(parent=parent, pos=pos, size=size, style=style)
