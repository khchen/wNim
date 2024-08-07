#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

## These events are generated by wSpinButton and wSpinCtrl.
#
## :Superclass:
##   `wCommandEvent <wCommandEvent.html>`_
#
## :Seealso:
##   `wSpinButton <wSpinButton.html>`_
##   `wSpinCtrl <wSpinCtrl.html>`_
#
## :Events:
##   ==============================  =============================================================
##   wSpinEvent                      Description
##   ==============================  =============================================================
##   wEvent_Spin                     Pressing an arrow. This event can be vetoed in wSpinCtrl.
##   wEvent_SpinUp                   Pressing up arrow. This event can be vetoed in wSpinCtrl.
##   wEvent_SpinDown                 Pressing down arrow. This event can be vetoed in wSpinCtrl.
##   wEvent_SpinLeft                 Pressing left arrow.
##   wEvent_SpinRight                Pressing right arrow.
##   ==============================  =============================================================

include ../pragma
import ../wBase

wEventRegister(wSpinEvent):
  wEvent_SpinFirst
  wEvent_Spin
  wEvent_SpinUp
  wEvent_SpinDown
  wEvent_SpinLeft
  wEvent_SpinRight
  wEvent_SpinLast

method getSpinPos*(self: wSpinEvent): int {.property, inline.} =
  ## Gets the current value (before change).
  let lpnmud = cast[LPNMUPDOWN](self.mLparam)
  result = lpnmud.iPos

method setSpinPos*(self: wSpinEvent, pos: int) {.property, inline.} =
  ## Set the value associated with the event.
  let lpnmud = cast[LPNMUPDOWN](self.mLparam)
  lpnmud.iPos = pos

method getSpinDelta*(self: wSpinEvent): int {.property, inline.} =
  ## Gets the delta value.
  let lpnmud = cast[LPNMUPDOWN](self.mLparam)
  result = lpnmud.iDelta

method setSpinDelta*(self: wSpinEvent, delta: int) {.property, inline.} =
  ## Set the value associated with the event.
  let lpnmud = cast[LPNMUPDOWN](self.mLparam)
  lpnmud.iDelta = delta
