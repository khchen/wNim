# forward declaration
proc getScrollPos*(self: wScrollBar): int {.inline.}
proc getValue*(self: wSlider): int {.inline.}

DefineIncrement(wEvent_ScrollFirst):
  wEvent_Slider
  wEvent_ScrollBar
  wEvent_ScrollTop
  wEvent_ScrollBottom
  wEvent_ScrollLineUp
  wEvent_ScrollLineDown
  wEvent_ScrollPageUp
  wEvent_ScrollPageDown
  wEvent_ScrollThumbTrack
  wEvent_ScrollThumbRelease
  wEvent_ScrollChanged
  wEvent_ScrollLast

proc isScrollEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_ScrollFirst..wEvent_ScrollLast

method getKind*(self: wScrollEvent): int {.property, inline.} =
  ## Returns what kind of event type this is. Basically used in wEvent_ScrollBar
  ## or wEvent_Slider.
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.kind

method getOrientation*(self: wScrollEvent): int {.property, inline.} =
  ## Returns wHORIZONTAL or wVERTICAL
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.orientation

method getScrollPos*(self: wScrollEvent): int {.property.} =
  ## Returns the position of the scrollbar.
  if self.mWindow of wScrollBar:
    result = wScrollBar(self.mWindow).getScrollPos()
  elif self.mWindow of wSlider:
    result = wSlider(self.mWindow).getValue()
