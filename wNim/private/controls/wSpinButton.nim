#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wSpinButton has two small up and down (or left and right) arrow buttons.
#
## :Appearance:
##   .. image:: images/wSpinButton.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wSpVertical                     Specifies a vertical spin button.
##   wSpHorizontal                   Specifies a horizontal spin button.
##   ==============================  =============================================================
#
## :Events:
##   `wSpinEvent <wSpinEvent.html>`_

include ../pragma
import ../wBase, wControl
export wControl

const
  wSpVertical* = 0
  wSpHorizontal* = UDS_HORZ

proc isVertical*(self: wSpinButton): bool {.validate, inline.} =
  ## Returns true if the spin button is vertical and false otherwise.
  result = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and UDS_HORZ) == 0

method getDefaultSize*(self: wSpinButton): wSize {.property.} =
  ## Returns the default size for the control.
  let isVert = self.isVertical()
  result.width = GetSystemMetrics(if isVert: SM_CXVSCROLL else: SM_CXHSCROLL)
  result.height = GetSystemMetrics(if isVert: SM_CYVSCROLL else: SM_CYHSCROLL)
  if isVert:
      result.height *= 2
  else:
      result.width *= 2

method getBestSize*(self: wSpinButton): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = self.getDefaultSize()

proc wSpinButton_OnNotify(self: wSpinButton, event: wEvent) =
  var processed = false
  defer: event.skip(if processed: false else: true)

  let lpnmud = cast[LPNMUPDOWN](event.mLparam)
  if lpnmud.hdr.hwndFrom == self.mHwnd and lpnmud.hdr.code == UDN_DELTAPOS:
    var
      spinEvent = Event(window=self, msg=wEvent_Spin, wParam=event.mWparam, lParam=event.mLparam)
      directionMsg = 0

    if self.isVertical():
      if lpnmud.iDelta > 0: directionMsg = wEvent_SpinDown
      elif lpnmud.iDelta < 0: directionMsg = wEvent_SpinUp
    else:
      if lpnmud.iDelta > 0: directionMsg = wEvent_SpinLeft
      elif lpnmud.iDelta < 0: directionMsg = wEvent_SpinRight

    if directionMsg != 0:
      spinEvent.mMsg = directionMsg
      processed = self.processEvent(spinEvent)

    if not processed:
      spinEvent.mMsg = wEvent_Spin
      processed = self.processEvent(spinEvent)

    if processed:
      event.mResult = spinEvent.mResult

wClass(wSpinButton of wControl):

  method release*(self: wSpinButton) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.disconnect(self.mNotifyConn)
    free(self[])

  proc init*(self: wSpinButton, parent: wWindow, id = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wSpVertical) {.validate.} =
    ## Initializes a spin button.
    wValidate(parent)
    # up-down control without buddy window cannot have a focus
    # (in fact, it do have a focus but without any visual change)
    # so UDS_ARROWKEYS have no use here. How to fix?
    # since that, just don't add WS_TAB

    self.wControl.init(className=UPDOWN_CLASS, parent=parent, id=id, pos=pos, size=size,
      style=style or UDS_HOTTRACK or WS_CHILD or WS_VISIBLE)

    self.mNotifyConn = parent.hardConnect(WM_NOTIFY) do (event: wEvent):
      wSpinButton_OnNotify(self, event)
