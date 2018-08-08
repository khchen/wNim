## A move event object holds information about window moving.
## :Superclass:
##    wEvent
## :Events:
##    ==============================  =============================================================
##    Events                          Description
##    ==============================  =============================================================
##    wEvent_Move                     Window is moved.
##    wEvent_Moving                   Window is moving.

const
  wEvent_Move* = WM_MOVE
  wEvent_Moving* = WM_MOVING

proc isMoveEvent(msg: UINT): bool {.inline.} =
  msg == wEvent_Move or msg == wEvent_Moving

method getPosition*(self: wMoveEvent): wPoint {.property.} =
  ## Returns the entire size of the window generating the size change event.
  if mMsg == WM_MOVE:
    result.x = GET_X_LPARAM(mLparam)
    result.y = GET_Y_LPARAM(mLparam)
  elif mMsg == WM_MOVING:
    var rect = toWRect(cast[PRECT](mLparam)[])
    result.x = rect.x
    result.y = rect.y

method setPosition*(self: wMoveEvent, x: int, y: int) {.property.} =
  if mMsg == WM_MOVING:
    var rect = toWRect(cast[PRECT](mLparam)[])
    rect.x = x
    rect.y = y
    cast[PRECT](mLparam)[] = toRect(rect)

method setPosition*(self: wMoveEvent, pos: wPoint) {.property.} =
  self.setPosition(pos.x, pos.y)
