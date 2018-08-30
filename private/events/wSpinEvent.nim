DefineIncrement(wEvent_SpinFirst):
  wEvent_Spin
  wEvent_SpinUp
  wEvent_SpinDown
  wEvent_SpinLeft
  wEvent_SpinRight
  wEvent_SpinLast

proc isSpinEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_SpinFirst..wEvent_SpinLast

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
