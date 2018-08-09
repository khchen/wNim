DefineIncrement(wEvent_ScrollFirst):
  wEvent_ScrollTop
  wEvent_ScrollBottom
  wEvent_ScrollLineUp
  wEvent_ScrollLineDown
  wEvent_ScrollPageUp
  wEvent_ScrollPageDown
  wEvent_ScrollThumbTrack
  wEvent_ScrollThumbRelease
  wEvent_ScrollChanged
  wEvent_Slider
  wEvent_ScrollLast

proc isScrollEvent(msg: UINT): bool {.inline.} =
  msg.isBetween(wEvent_ScrollFirst, wEvent_ScrollLast)

method getOrientation*(self: wScrollEvent): int {.property.} =
  ## Returns wHORIZONTAL or wVERTICAL
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.orientation

method getScrollPos*(self: wScrollEvent): int {.property.} =
  ## Returns the position of the scrollbar.
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.scrollPos

#   ## Returns the position of the scrollbar
#   if mWindow of wScrollBar:
#     result = mWindow.getPosition
#   elif mLparam == 0: # means the standard scroll bar
#     mWindow.getScrollPos(orientation)
