#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## wNim's utilities and convenience functions.

include pragma
import wBase, wDataObject, wApp, wHelper

const
  wSysBorderX* = SM_CXBORDER ## Width of single border.
  wSysBorderY* = SM_CYBORDER ## Height of single border.
  wSysCursorX* = SM_CXCURSOR ## Width of cursor.
  wSysCursorY* = SM_CYCURSOR ## Height of cursor.
  wSysDclickX* = SM_CXDOUBLECLK ## Width in pixels of rectangle within which two successive mouse clicks must fall to generate a double-click.
  wSysDclickY* = SM_CYDOUBLECLK ## Height in pixels of rectangle within which two successive mouse clicks must fall to generate a double-click.
  wSysDragX* = SM_CXDRAG ## Width in pixels of a rectangle centered on a drag point to allow for limited movement of the mouse pointer before a drag operation begins.
  wSysDragY* = SM_CYDRAG ## Height in pixels of a rectangle centered on a drag point to allow for limited movement of the mouse pointer before a drag operation begins.
  wSysEdgeX* = SM_CXEDGE ## Width of a 3D border, in pixels.
  wSysEdgeY* = SM_CYEDGE ## Height of a 3D border, in pixels.
  wSysVThumbY* = SM_CYVTHUMB ## Height of vertical scrollbar thumb.
  wSysHThumbX* = SM_CXHTHUMB ## Width of horizontal scrollbar thumb.
  wSysIconX* = SM_CXICON ## The default width of an icon.
  wSysIconY* = SM_CYICON ## The default height of an icon.
  wSysIconSpacingX* = SM_CXICONSPACING ## Width of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of this size when arranged.
  wSysIconSpacingY* = SM_CYICONSPACING ## Height of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of this size when arranged.
  wSysWindowMinX* = SM_CXMIN ## Minimum width of a window.
  wSysWindowMinY* = SM_CYMIN ## Minimum height of a window.
  wSysScreenX* = SM_CXSCREEN ## Width of the screen in pixels.
  wSysScreenY* = SM_CYSCREEN ## Height of the screen in pixels.
  wSysFrameSizeX* = SM_CXSIZEFRAME ## Width of the window frame for a wResizeBorder window.
  wSysFrameSizeY* = SM_CYSIZEFRAME ## Height of the window frame for a wResizeBorder window.
  wSysSmallIconX* = SM_CXSMICON ## Recommended width of a small icon (in window captions, and small icon view).
  wSysSmallIconY* = SM_CYSMICON ## Recommended height of a small icon (in window captions, and small icon view).
  wSysHScrollY* = SM_CYHSCROLL ## The height of a horizontal scroll bar, in pixels.
  wSysVScrollX* = SM_CXVSCROLL ## The width of a vertical scroll bar, in pixels.
  wSysHScrollArrowX* = SM_CXHSCROLL ## The width of the arrow bitmap on a horizontal scroll bar, in pixels.
  wSysVScrollArrowY* = SM_CYVSCROLL ## The height of the arrow bitmap on a vertical scroll bar, in pixels.
  wSysCaptionY* = SM_CYCAPTION ## Height of normal caption area.
  wSysMenuY* = SM_CYMENU  ## Height of single-line menu bar.
  wSysNetworkPresent* = SM_NETWORK ## 1 if there is a network present, 0 otherwise.
  wSysPenWindowsPresent* = SM_PENWINDOWS ## 1 if PenWindows is installed, 0 otherwise.
  wSysShowSounds* = SM_SHOWSOUNDS ## Non-zero if the user requires an application to present information visually in situations where it would otherwise present the information only in audible form; zero otherwise.
  wSysSwapButtons* = SM_SWAPBUTTON  ## Non-zero if the meanings of the left and right mouse buttons are swapped; zero otherwise.

proc wGetMousePosition*(): wPoint =
  ## Returns the mouse position in screen coordinates.
  var mousePos: POINT
  if GetCursorPos(&mousePos) != 0:
    result.x = mousePos.x
    result.y = mousePos.y

proc wSetMousePosition*(pos: wPoint) =
  ## Sets the mouse position
  SetCursorPos(int32 pos.x, int32 pos.y)

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
  App()
  result = OleSetClipboard(dataObject.mObj) == S_OK

proc wGetClipboard*(): wDataObject =
  ## Retrieves a data object that you can use to access the contents of the
  ## clipboard.
  App()
  var pDataObj: ptr IDataObject
  if OleGetClipboard(&pDataObj) == S_OK:
    result = DataObject(pDataObj)

proc wClearClipboard*() =
  ## Clears the clipboard.
  App()
  OleSetClipboard(nil)

proc wFlushClipboard*() =
  ## Flushes the clipboard: this means that the data which is currently on
  ## clipboard will stay available even after the application exits.
  App()
  OleFlushClipboard()

proc wGetSystemMetric*(index: int): int {.inline.} =
  ## Returns the value of a system metric. Possible value for index listed in consts.
  result = int GetSystemMetrics(index)

proc wGetDefaultPrinter*(): string =
  ## Returns the printer name of the default printer for the current user.
  var needed: DWORD
  GetDefaultPrinter(nil, &needed)
  if needed != 0:
    var buffer = T(needed)
    if GetDefaultPrinter(&buffer, &needed) != 0:
      result = $buffer

proc wSetDefaultPrinter*(device: string) {.inline.} =
  ## Sets the printer name of the default printer for the current user
  SetDefaultPrinter(device)

proc wGetPrinters*(): seq[string] =
  ## Returns available printers.
  var needed, returned: DWORD
  EnumPrinters(PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL, "", 1, nil, 0, &needed, &returned)

  let buffer = cast[LPBYTE](alloc(needed))
  defer: dealloc(buffer)
  EnumPrinters(PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL, "", 1, buffer, needed, &needed, &returned)

  let printers = cast[ptr UncheckedArray[PRINTER_INFO_1]](buffer)
  for i in 0..<returned:
    result.add $printers[i].pName

proc wSetSystemDpiAware*(): bool {.discardable.} =
  ## Sets the default DPI awareness to system aware (Windows Vista later).
  ## Return true if the function succeeds.
  result = setSystemDpiAware()

proc wSetPerMonitorDpiAware*(): bool {.discardable.} =
  ## Sets the default DPI awareness to per monitor aware v2 (Windows 10 version 1607 later),
  ## or per monitor aware (Windows 8.1 later).
  ## Return true if the function succeeds.
  result = setPerMonitorDpiAware()

proc wGetWinVersion*(): float =
  ## Get Windows release version number.
  ## ================================  =============================================================
  ## Windows Version                   Release Version
  ## ================================  =============================================================
  ## Windows 10                        10.0
  ## Windows 8.1                       6.3
  ## Windows 8                         6.2
  ## Windows 7                         6.1
  ## Windows Vista                     6.0
  ## Windows XP                        5.1
  ## ================================  =============================================================
  result = wGetWinVersionImpl()
