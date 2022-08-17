#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

include pragma
import lists, times, tables, memlib/rtlib
import winim/[winstr, utils], winim/inc/[windef, winbase], winimx
import wTypes, wMacros

converter IntToDWORD*(x: int): DWORD = DWORD x
converter PtrPtrObjectToPtrPointer*(x: ptr ptr object): ptr pointer = cast[ptr pointer](x)
converter GpImageToGpBitmap*(x: ptr GpBitmap): ptr GpImage = cast[ptr GpImage](x)

proc `-`*(a, b: wPoint): wPoint =
  result = (a.x - b.x, a.y - b.y)

proc `+`*(a, b: wPoint): wPoint =
  result = (a.x + b.x, a.y + b.y)

# gc:arc let program crash for ref, but works of for ptr. bug or not?
template ref2ptr(x: ref): ptr = cast[ptr type(x[])](x)
template ptr2ref(x: ptr): ref = cast[ref type(x[])](x)

iterator rnodes*[T](L: SomeLinkedList[T]): SomeLinkedNode[T] =
  var it = ref2ptr(L.tail)
  while it != nil:
    var prv = ref2ptr(it.prev)
    yield ptr2ref(it)
    it = prv

# std CountTable is not reliable, see https://github.com/nim-lang/Nim/issues/12200.
proc inc*(table: var Table[UINT, int], key: UINT, n = 1) =
  table.withValue(key, value) do:
    value[].inc n
    if value[] == 0:
      table.del key
  do:
    if n != 0:
      table[key] = n

proc dec*(table: var Table[UINT, int], key: UINT, n = 1) {.inline.} =
  table.inc(key, -n)

template postDefaultHandler*(event: wEvent, body: untyped): untyped =
  when not defined(Nimdoc):
    var runDefault {.threadvar.}: bool
    if runDefault:
      event.skip

    else:
      runDefault = true
      event.result = SendMessage(event.window.handle, event.eventMessage, event.wParam, event.lParam)
      runDefault = false
      body

proc toRect*(r: wRect): RECT =
  result.left = r.x
  result.top = r.y
  result.right = r.x + r.width
  result.bottom = r.y + r.height

proc toWRect*(r: RECT): wRect =
  result.x = r.left
  result.y = r.top
  result.width = r.right - r.left
  result.height = r.bottom - r.top

template SendMessage*(hwnd, msg, wparam, lparam: typed): untyped =
  SendMessage(hwnd, msg, cast[WPARAM](wparam), cast[LPARAM](lparam))

template objectOffset*(Typ, member): int =
  when declared(offsetOf):
    offsetOf(Typ, member)
  else:
    var dummy: Typ
    cast[int](dummy.member.addr) -% cast[int](dummy.addr)

proc toWStyle*(style, exstyle: DWORD): wStyle {.inline.} =
  result = exstyle.wStyle shl 32 or style.wStyle

proc toolBarDirection*(hwnd: HWND): int =
  case SendMessage(hwnd, TB_GETSTYLE, 0, 0) and CCS_RIGHT
  of CCS_RIGHT: result = wRight
  of CCS_LEFT: result = wLeft
  of CCS_BOTTOM: result = wBottom
  else: result = wTop

proc centerWindow*(hwnd: HWND, inScreen = false, direction = wBoth) =
  # this works on top level window only
  var rect: RECT
  var rectOwner: RECT

  GetWindowRect(hwnd, rect)
  let owner = GetParent(hwnd)
  if owner == 0 or inScreen:
    GetClientRect(GetDesktopWindow(), &rectOwner)
  else:
    GetWindowRect(owner, &rectOwner)

  let width = rect.right - rect.left
  let height = rect.bottom - rect.top
  let ownerWidth = rectOwner.right - rectOwner.left
  let ownerHeight = rectOwner.bottom - rectOwner.top

  if (direction and wHorizontal) != 0:
    rect.left = (rectOwner.left + (ownerWidth - width) div 2)
      .clamp(0, GetSystemMetrics(SM_CXSCREEN) - width)

  if (direction and wVertical) != 0:
    rect.top = (rectOwner.top + (ownerHeight - height) div 2)
      .clamp(0, GetSystemMetrics(SM_CYSCREEN) - height)

  SetWindowPos(hwnd, 0, rect.left, rect.top, 0, 0,
    SWP_NOSIZE or SWP_NOZORDER or SWP_NOREPOSITION or SWP_NOACTIVATE)

proc toBar*(orientation: int): int {.inline.} =
  # wHorizontal/wVertical for wWindow
  # other value for wScrollBar control
  result = case orientation
  of wHorizontal: SB_HORZ
  of wVertical: SB_VERT
  else: SB_CTL

proc getScrollInfo*(self: wWindow, orientation: int = 0): SCROLLINFO =
  result = SCROLLINFO(
    cbSize: sizeof(SCROLLINFO),
    fMask: SIF_ALL)
  GetScrollInfo(self.mHwnd, orientation.toBar, &result)

proc isVaildPath*(str: string): bool =
  if str.len <= MAX_PATH and PathFileExists(str) != 0:
    result = true

proc getTextFontSize*(text: string, hFont: HANDLE, hwnd: HWND): wSize =
  var
    text = T(text)
    hdc = GetDC(hwnd)
    prev = SelectObject(hdc, hFont)
    rect: RECT

  DrawText(hdc, text, text.len, &rect, DT_CALCRECT)
  SelectObject(hdc, prev)
  ReleaseDC(hwnd, hdc)

  result.width = rect.right
  result.height = rect.bottom

proc getAverageASCIILetterSize*(hFont: HANDLE, hwnd: HWND): wSize =
  result = getTextFontSize("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
    hFont, hWnd)
  result.width = (result.width div 26 + 1) div 2

var hwndComboBoxForCountSize {.threadvar.}: HWND

proc getLineControlDefaultHeight*(hFont: HANDLE): int =
  # a hack way to get default height from autosize combobox
  # is there a correct way to calculate it?
  if hwndComboBoxForCountSize == 0:
    hwndComboBoxForCountSize = CreateWindowEx(0, WC_COMBOBOX, "", CBS_DROPDOWN,
      0, 0, 0, 0, 0, 0, 0, nil)

  var r: RECT
  SendMessage(hwndComboBoxForCountSize, WM_SETFONT, hFont, 0)
  GetWindowRect(hwndComboBoxForCountSize, r)
  result = r.bottom - r.top

proc getTextFontSizeWithCheckMark*(text: string, hFont: HANDLE, hwnd: HWND): wSize =
  let
    hdc = GetDC(hwnd)
    prev = SelectObject(hdc, hFont)
    checkWidth = 12 * GetDeviceCaps(hdc, LOGPIXELSX).int div 96 + 1
    checkHeight = 12 * GetDeviceCaps(hdc, LOGPIXELSY).int div 96 + 1
  var textOffset: INT
  GetCharWidth(hdc, '0'.UINT, '0'.UINT, addr textOffset)
  SelectObject(hdc, prev)
  ReleaseDC(hwnd, hdc)

  result = getTextFontSize(text & " ", hFont, hwnd)
  result.width += checkWidth + textOffset.int div 2
  if result.width < checkHeight: result.width = checkHeight

proc toDateTime*(st: SYSTEMTIME): DateTime =
  when compiles(dateTime(st.wYear.int, Month st.wMonth, st.wDay)):
    dateTime(st.wYear.int, Month st.wMonth, st.wDay, st.wHour, st.wMinute,
      st.wSecond)
  else:
    initDateTime(st.wDay, Month st.wMonth, st.wYear.int, st.wHour, st.wMinute,
      st.wSecond)

proc toSystemTime*(dateTime: DateTime): SYSTEMTIME =
  result.wSecond = WORD dateTime.second
  result.wMinute = WORD dateTime.minute
  result.wHour = WORD dateTime.hour
  result.wYear = WORD dateTime.year
  result.wMonth = WORD dateTime.month
  result.wDay = WORD dateTime.monthday

proc toTime*(st: SYSTEMTIME): wTime =
  st.toDateTime().toTime()

proc toSystemTime*(time: wTime): SYSTEMTIME =
  result = time.inZone(local()).toSystemTime()


proc wGetMenuItemInfo*(hmenu: HMENU, pos: int, fMask = MIIM_STATE): MENUITEMINFO =
  result = MENUITEMINFO(cbSize: sizeof(MENUITEMINFO), fMask: fMask)
  GetMenuItemInfo(hmenu, pos, true, result)

proc wGetMenuItemString*(hmenu: HMENU, pos: int, buffer: var TString): int =
  var menuItemInfo = MENUITEMINFO(
    cbSize: sizeof(MENUITEMINFO),
    fMask: MIIM_STRING,
    dwTypeData: &buffer,
    cch: buffer.high)

  if GetMenuItemInfo(hmenu, pos, true, menuItemInfo) != 0:
    result = menuItemInfo.cch

proc wEnableMenu*(hmenu: HMENU, pos: int, flag: bool) =
  var menuItemInfo = wGetMenuItemInfo(hmenu, pos)
  if flag:
    menuItemInfo.fState = menuItemInfo.fState and (not MFS_DISABLED)
  else:
    menuItemInfo.fState = menuItemInfo.fState or MFS_DISABLED
  SetMenuItemInfo(hmenu, pos, true, menuItemInfo)

proc wIsMenuEnabled*(hmenu: HMENU, pos: int): bool =
  var menuItemInfo = wGetMenuItemInfo(hmenu, pos)
  result = (menuItemInfo.fState and MFS_DISABLED) == 0

proc wCheckMenuItem*(hmenu: HMENU, pos: int, flag: bool) =
  var menuItemInfo = wGetMenuItemInfo(hmenu, pos)
  if flag:
    menuItemInfo.fState = menuItemInfo.fState or MFS_CHECKED
  else:
    menuItemInfo.fState = menuItemInfo.fState and (not MFS_CHECKED)
  SetMenuItemInfo(hmenu, pos, true, menuItemInfo)

proc wMenuCheck*(self: wMenu, pos: int, flag = true) {.validate.} =
  # Used internally.
  # To avoid recursive module dependencies problem, move this from
  # wMenu.nim to here.
  if pos >= 0 and pos < self.mItemList.len:
    if flag and self.mItemList[pos].mKind == wMenuItemRadio:
      var first, last: int
      for i in pos..<self.mItemList.len:
        if self.mItemList[i].mKind != wMenuItemRadio: break
        last = i

      for i in countdown(pos, 0):
        if self.mItemList[i].mKind != wMenuItemRadio: break
        first = i

      CheckMenuRadioItem(self.mHmenu, first, last, pos, MF_BYPOSITION)

    else:
      wCheckMenuItem(self.mHmenu, pos, flag)

proc wMenuToggle*(self: wMenu, pos: int) {.validate.} =
  # Used internally.
  # To avoid recursive module dependencies problem, move this from
  # wMenu.nim to here.
  if pos >= 0 and pos < self.mItemList.len:
    var menuItemInfo = wGetMenuItemInfo(self.mHmenu, pos)
    menuItemInfo.fState = menuItemInfo.fState xor MFS_CHECKED
    SetMenuItemInfo(self.mHmenu, pos, true, menuItemInfo)

proc loadRichDll*(): bool =
  var richDllLoaded {.threadvar.}: bool
  if not richDllLoaded:
    richDllLoaded = LoadLibrary("msftedit.dll") != 0
  result = richDllLoaded

proc DllGetVersion(vi: ptr DLLVERSIONINFO) {.checkedRtlib: "comctl32", stdcall, importc.}

proc usingTheme*(): bool =
  try:
    var vi = DLLVERSIONINFO(cbSize: sizeof(DLLVERSIONINFO))
    DllGetVersion(&vi)
    result = vi.dwMajorVersion >= 6

  except LibraryError: discard

proc getSize*(iconInfo: ICONINFO): wSize =
  var bitmapInfo: BITMAP
  if iconInfo.hbmColor != 0:
    let hbm = iconInfo.hbmColor
    if GetObject(hbm, sizeof(bitmapInfo), cast[LPVOID](&bitmapInfo)) != 0:
      result.width = int bitmapInfo.bmWidth
      result.height = int bitmapInfo.bmHeight

  elif iconInfo.hbmMask != 0:
    let hbm = iconInfo.hbmMask
    if GetObject(hbm, sizeof(bitmapInfo), cast[LPVOID](&bitmapInfo)) != 0:
      result.width = int bitmapInfo.bmWidth
      result.height = int bitmapInfo.bmHeight div 2

proc getHandle*(self: wAcceleratorTable): HACCEL =
  # Used internally, generate the accelerator table on the fly.
  # To avoid recursive module dependencies problem, move this from
  # wAcceleratorTable.nim to here.
  if self.mModified:
    if self.mHandle != 0:
      DestroyAcceleratorTable(self.mHandle)

    if self.mAccels.len != 0:
      self.mHandle = CreateAcceleratorTable(addr self.mAccels[0], self.mAccels.len)
    else:
      self.mHandle = 0
    self.mModified = false

  result = self.mHandle

proc RtlGetVersion(lp: ptr OSVERSIONINFO) {.checkedRtlib: "ntdll", stdcall, importc.}

proc wGetWinVersionImpl*(): float =
  var osv = OSVERSIONINFO(dwOSVersionInfoSize: sizeof(OSVERSIONINFO))
  try:
    RtlGetVersion(osv)

  except LibraryError:
    GetVersionEx(osv)

  finally:
    result = osv.dwMajorVersion.float + osv.dwMinorVersion.float / 10

proc wGetMessagePosition*(): wPoint =
  # Returns the mouse position in screen coordinates.
  var val = GetMessagePos()
  result.x = GET_X_LPARAM(val)
  result.y = GET_Y_LPARAM(val)

proc forceForegroundWindow*(hWnd: HWND) =
  let foreId = GetWindowThreadProcessId(GetForegroundWindow(), nil)
  let curId = GetCurrentThreadId()
  AttachThreadInput(curId, foreId, TRUE)
  SetForegroundWindow(hWnd)
  AttachThreadInput(curId, foreId, FALSE)

  SetWindowPos(hWnd, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW)
  BringWindowToTop(hWnd)

proc isToolbarFloating*(self: wToolBar): bool =
  result = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and (CCS_NOPARENTALIGN or CCS_NORESIZE)) != 0

proc setSystemDpiAware*(): bool {.discardable.} =
  proc SetProcessDPIAware(): BOOL {.checkedRtlib: "user32", stdcall, importc.}

  try:
    if SetProcessDPIAware() != 0:
      return true
  except LibraryError: discard

proc setPerMonitorDpiAware*(): bool {.discardable.} =
  const DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = -4
  const PROCESS_PER_MONITOR_DPI_AWARE = 2
  proc SetProcessDpiAwarenessContext(value: HANDLE): BOOL {.checkedRtlib: "user32", stdcall, importc.}
  proc SetProcessDpiAwareness(value: cint): HRESULT {.checkedRtlib: "shcore", stdcall, importc.}

  try:
    if SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2) != 0:
      return true
  except LibraryError: discard

  try:
    if SetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE) == S_OK:
      return true
  except LibraryError: discard
