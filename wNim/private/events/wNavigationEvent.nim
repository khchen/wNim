#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

const
  wEvent_Navigation* = WM_APP + 2

proc isNavigationEvent(msg: UINT): bool {.inline.} =
  msg == wEvent_Navigation

method shouldPropagate*(event: wNavigationEvent): bool =
  ## A navigation event should be never propagated.
  result = false

method getKeyCode*(self: wNavigationEvent): int {.property, inline.} =
  ## Returns the key code of the key that generated this event.
  result = int mWparam

