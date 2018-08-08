## A size event holds information about size change events.
## :Superclass:
##    wEvent
## :Events:
##    ==============================  =============================================================
##    Events                          Description
##    ==============================  =============================================================
##    wEvent_Size                     Window size has changed.

const
  wEvent_Size* = WM_SIZE

proc isSizeEvent(msg: UINT): bool {.inline.} =
  msg == wEvent_Size

method getSize*(self: wSizeEvent): wSize {.property.} =
  ## Returns the entire size of the window generating the size change event.
  result.width = GET_X_LPARAM(mLparam)
  result.height = GET_Y_LPARAM(mLparam)
