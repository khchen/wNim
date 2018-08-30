const
  wEvent_SetCursor* = WM_APP + 3

proc isSetCursorEvent(msg: UINT): bool {.inline.} =
  msg == wEvent_SetCursor

method getCursor*(self: wSetCursorEvent): wCursor {.property, inline.} =
  ## Returns a reference to the cursor specified by this event.
  result = cast[wCursor](mLparam)

method setCursor*(self: wSetCursorEvent, cursor: wCursor) {.property, inline.} =
  ## Sets the cursor associated with this event.
  wValidate(cursor)
  mLparam = cast[LPARAM](cursor)
