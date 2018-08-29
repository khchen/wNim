## The event class used by wTrayIcon
##
## :Superclass:
##    wEvent
##
## :Events:
##    ==============================  =============================================================
##    Events                          Description
##    ==============================  =============================================================
##    ==============================  =============================================================

DefineIncrement(wEvent_TrayFirst):
  wEvent_TrayIcon
  wEvent_TrayLeftDown
  wEvent_TrayLeftUp
  wEvent_TrayRightDown
  wEvent_TrayRightUp
  wEvent_TrayLeftDoubleClick
  wEvent_TrayRightDoubleClick
  wEvent_TrayMove
  wEvent_TrayBalloonTimeout
  wEvent_TrayBalloonClick
  wEvent_TrayLast

proc isTrayEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_TrayFirst..wEvent_TrayLast
