#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## wNim's utilities and convenience functions.

# forward declaration
proc DataObject*(dataObj: ptr IDataObject): wDataObject {.inline.}

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

proc wGetFocusWindow*(): wWindow =
  ## Gets the currently focus window.
  let hwnd = GetFocus()
  if hwnd != 0:
    result = wAppWindowFindByHwnd(hwnd)

proc wGetScreenSize*(): wSize =
  ## Gets the screen size.
  result.width = GetSystemMetrics(SM_CXSCREEN)
  result.height = GetSystemMetrics(SM_CYSCREEN)

proc wSetClipboard*(dataObject: wDataObject): bool {.discardable.} =
  ## Places a specific data object onto the clipboard.
  wValidate(dataObject)
  OleSetClipboard(dataObject.mObj)

proc wGetClipboard*(): wDataObject =
  ## Retrieves a data object that you can use to access the contents of the
  ## clipboard.
  var pDataObj: ptr IDataObject
  if OleGetClipboard(&pDataObj) == S_OK:
    result = DataObject(pDataObj)

proc wClearClipboard*() =
  ## Clears the clipboard.
  OleSetClipboard(nil)

proc wFlushClipboard*() =
  ## Flushes the clipboard: this means that the data which is currently on
  ## clipboard will stay available even after the application exits.
  OleFlushClipboard()
