DefineIncrement(wEvent_SpinFirst):
  wEvent_Spin
  wEvent_SpinUp
  wEvent_SpinDown
  wEvent_SpinLeft
  wEvent_SpinRight

proc isSpinEvent(msg: UINT): bool {.inline.} =
  msg == wEvent_Spin

method getSpinPos*(self: wSpinEvent): int {.property, inline.} =
  ## Gets the current value (before change).
  let lpnmud = cast[LPNMUPDOWN](mLparam)
  result = lpnmud.iPos

method setSpinPos*(self: wSpinEvent, pos: int) {.property, inline.} =
  ## Set the value associated with the event.
  let lpnmud = cast[LPNMUPDOWN](mLparam)
  lpnmud.iPos = pos

method getSpinDelta*(self: wSpinEvent): int {.property, inline.} =
  ## Gets the delta value.
  let lpnmud = cast[LPNMUPDOWN](mLparam)
  result = lpnmud.iDelta

method setSpinDelta*(self: wSpinEvent, delta: int) {.property, inline.} =
  ## Set the value associated with the event.
  let lpnmud = cast[LPNMUPDOWN](mLparam)
  lpnmud.iDelta = delta
