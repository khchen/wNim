#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

## This event is generated by wWindow when the user requests to show a
## context (popup) menu.
#
## :Superclass:
##   `wEvent <wEvent.html>`_
#
## :Seealso:
##   `wWindow <wWindow.html>`_
#
## :Events:
##   ==============================  =============================================================
##   wContextMenuEvent               Description
##   ==============================  =============================================================
##   wEvent_ContextMenu              Notifies a window that the user clicked the right mouse button.
##   ==============================  =============================================================

include ../pragma
import ../wBase

wEventRegister(wContextMenuEvent):
  wEvent_ContextMenu = WM_CONTEXTMENU

method getPosition*(self: wContextMenuEvent): wPoint {.property.} =
  ## Returns the position in screen coordinates at which the menu should be shown.
  ## If the event originated from a keyboard event, the value returned from this
  ## function will be wDefaultPosition.

  result.x = GET_X_LPARAM(self.mLparam)
  result.y = GET_Y_LPARAM(self.mLparam)
  if result.x == -1 and result.y == -1:
    result = wDefaultPoint
