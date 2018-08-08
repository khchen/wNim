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
  wEvent_ScrollBar
  wEvent_Slider
  wEvent_ScrollLast

proc isScrollEvent(msg: UINT): bool {.inline.} =
  msg.isBetween(wEvent_ScrollFirst, wEvent_ScrollLast)
