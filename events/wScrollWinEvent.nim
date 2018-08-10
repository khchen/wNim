## A scroll event holds information about events sent from scrolling windows.
## Note that these events are very similar to wScrollEvent but not derive from wCommandEvent.
## It means, these events won't propagate upwards by default.

DefineIncrement(wEvent_ScrollWinFirst):
  wEvent_ScrollWin
  wEvent_ScrollWinTop
  wEvent_ScrollWinBottom
  wEvent_ScrollWinLineUp
  wEvent_ScrollWinLineDown
  wEvent_ScrollWinPageUp
  wEvent_ScrollWinPageDown
  wEvent_ScrollWinThumbTrack
  wEvent_ScrollWinThumbRelease
  wEvent_ScrollWinChanged
  wEvent_ScrollWinLast

proc isScrollWinEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_ScrollWinFirst..wEvent_ScrollWinLast

method getKind*(self: wScrollWinEvent): int {.property, inline.} =
  ## Returns what kind of event type this is. Basically used in wEvent_ScrollWin.
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.kind

method getOrientation*(self: wScrollWinEvent): int {.property, inline.} =
  ## Returns wHORIZONTAL or wVERTICAL
  let dataPtr = cast[ptr wScrollData](mLparam)
  result = dataPtr.orientation

proc getScrollPos*(self: wWindow, orientation: int): int {.inline.}

method getScrollPos*(self: wScrollWinEvent): int {.property.} =
  ## Returns the position of the scrollbar.
  result = self.mWindow.getScrollPos(getOrientation())
