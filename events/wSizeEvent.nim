## A size event holds information about size change events.
## :Superclass:
##    wEvent
## :Events:
##    ==============================  =============================================================
##    Events                          Description
##    ==============================  =============================================================
##    wEvent_Size                     Window size has changed.

const
  wEvent_Size* = WM_APP + 52
  wEvent_Iconize* = WM_APP + 53
  wEvent_Minimize* = WM_APP + 53
  wEvent_Maximize* = WM_APP + 54
  wEvent_Sizing* = WM_APP + 55

proc isSizeEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_Size..wEvent_Sizing

method getSize*(self: wSizeEvent): wSize {.property.} =
  ## Returns the entire size of the window generating the size change event.
  result.width = GET_X_LPARAM(mLparam)
  result.height = GET_Y_LPARAM(mLparam)
