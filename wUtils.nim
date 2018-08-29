proc wGetMousePosition*(): wPoint =
  ## Returns the mouse position in screen coordinates.
  var mousePos: POINT
  if GetCursorPos(&mousePos) != 0:
    result.x = mousePos.x
    result.y = mousePos.y

proc wGetMessagePosition*(): wPoint =
  ## Returns the mouse position in screen coordinates.
  var val = GetMessagePos()
  result.x = GET_X_LPARAM(val)
  result.y = GET_Y_LPARAM(val)

proc wGetKeyState*(key: int): bool =
  ## For normal keys, returns true if the specified key is currently down.
  ## For togglable keys (Caps Lock, Num Lock and Scroll Lock),
  ## returns true if the key is toggled such that its LED indicator is lit.
  case key:
  of VK_CAPITAL, VK_NUMLOCK, VK_SCROLL:
    result = (GetKeyState(key) and 1) != 0
  else:
    result = (GetAsyncKeyState(key) and 0x8000) != 0

proc wFindWindowAtPoint*(pos: wPoint = wDefaultPoint): wWindow =
  ## Find the deepest window at the given mouse position in screen coordinates,
  ## returning the window if found, or nil if not.
  var point: POINT
  if pos == wDefaultPoint:
    GetCursorPos(addr point)
  else:
    point.x = pos.x
    point.y = pos.y

  let hwnd = WindowFromPoint(point)
  if hwnd != 0:
    result = wAppWindowFindByHwnd(hwnd)

proc wxGetFocusWindow*(): wWindow =
  ## Gets the currently focus window.
  let hwnd = GetFocus()
  if hwnd != 0:
    result = wAppWindowFindByHwnd(hwnd)
