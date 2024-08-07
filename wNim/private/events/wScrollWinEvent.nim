#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

## These events are generated by wWindow when the window is scrolling. Notice
## that these events are very similar to wScrollEvent but not derive from
## wCommandEvent. It means, these events won't propagate upwards by default.
#
## :Superclass:
##   `wEvent <wEvent.html>`_
#
## :Seealso:
##   `wWindow <wWindow.html>`_
#
## :Events:
##   ==============================  =============================================================
##   wScrollWinEvent                 Description
##   ==============================  =============================================================
##   wEvent_ScrollWin                Sent to window before all of following event.
##                                   Use getKind() to know what kind of type it is.
##   wEvent_ScrollWinTop             Scroll to top or leftmost.
##   wEvent_ScrollWinBottom          Scroll to bottom or rightmost.
##   wEvent_ScrollWinLineUp          Scroll line up or left
##   wEvent_ScrollWinLineDown        Scroll line down or right.
##   wEvent_ScrollWinPageUp          Scroll page up or left.
##   wEvent_ScrollWinPageDown        Scroll page down or right.
##   wEvent_ScrollWinThumbTrack      Frequent events sent as the user drags the thumbtrack.
##   wEvent_ScrollWinThumbRelease    Thumb release events.
##   wEvent_ScrollWinChanged         End of scrolling events
##   ==============================  =============================================================

# forward declaration
# proc getScrollPos*(self: wWindow, orientation: int): int {.inline.}

include ../pragma
import ../wBase

wEventRegister(wScrollWinEvent):
  wEvent_ScrollWinFirst
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

method getKind*(self: wScrollWinEvent): int {.property, inline.} =
  ## Returns what kind of event type this is. Basically used in wEvent_ScrollWin.
  let dataPtr = cast[ptr wScrollData](self.mLparam)
  result = dataPtr.kind

method getOrientation*(self: wScrollWinEvent): int {.property, inline.} =
  ## Returns wHorizontal or wVertical
  let dataPtr = cast[ptr wScrollData](self.mLparam)
  result = dataPtr.orientation

method getScrollPos*(self: wScrollWinEvent): int {.property.} =
  ## Returns the position of the scrollbar.
  result = self.mScrollPos
