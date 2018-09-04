#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

converter DWORDToInt(x: DWORD): int = int x
converter IntToDWORD(x: int): DWORD = DWORD x

proc `-`(a, b: wPoint): wPoint =
  result = (a.x - b.x, a.y - b.y)

proc `+`(a, b: wPoint): wPoint =
  result = (a.x + b.x, a.y + b.y)

iterator rnodes[T](L: SomeLinkedList[T]): SomeLinkedNode[T] =
  var it = L.tail
  while it != nil:
    var prv = it.prev
    yield it
    it = prv

proc toRect(r: wRect): RECT =
  result.left = r.x
  result.top = r.y
  result.right = r.x + r.width
  result.bottom = r.y + r.height

proc toWRect(r: RECT): wRect =
  result.x = r.left
  result.y = r.top
  result.width = r.right - r.left
  result.height = r.bottom - r.top

template SendMessage(hwnd, msg, wparam, lparam: typed): untyped =
  SendMessage(hwnd, msg, cast[WPARAM](wparam), cast[LPARAM](lparam))

proc wGetDPI(): int =
  var hdc = GetDC(0)
  result = GetDeviceCaps(hdc, LOGPIXELSY)
  ReleaseDC(0, hdc)

proc toWStyle(style, exstyle: DWORD): wStyle {.inline.} =
  result = exstyle.wStyle shl 32 or style.wStyle

proc toolBarDirection(hwnd: HWND): int =
  case SendMessage(hwnd, TB_GETSTYLE, 0, 0) and CCS_RIGHT
  of CCS_RIGHT: result = wRight
  of CCS_LEFT: result = wLeft
  of CCS_BOTTOM: result = wBottom
  else: result = wTop

proc wGetWinVersion(): float =
  var osv = OSVERSIONINFO(dwOSVersionInfoSize: sizeof(OSVERSIONINFO).DWORD)
  GetVersionEx(osv)
  result = osv.dwMajorVersion.float + osv.dwMinorVersion.float / 10

proc centerWindow(hwnd: HWND, inScreen = false, direction = wBoth) =
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

proc isVaildPath(str: string): bool =
  if str.len <= MAX_PATH and PathFileExists(str) != 0:
    result = true

proc getTextFontSize(text: string, hFont: HANDLE): wSize =
  var
    hdc = GetDC(0)
    prev = SelectObject(hdc, hFont)
    size: SIZE

  GetTextExtentPoint32(hdc, text, text.len, size)
  SelectObject(hdc, prev)
  ReleaseDC(0, hdc)

  result.height = size.cy
  result.width = size.cx

proc getAverageASCIILetterSize(hFont: HANDLE): wSize =
  result = getTextFontSize("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
    hFont)
  result.width = (result.width div 26 + 1) div 2

var hwndComboBoxForCountSize {.threadvar.}: HWND

proc getLineControlDefaultHeight(hFont: HANDLE): int =
  # a hack way to get default height from autosize combobox
  # is there a correct way to calculate it?
  if hwndComboBoxForCountSize == 0:
    hwndComboBoxForCountSize = CreateWindowEx(0, WC_COMBOBOX, "", CBS_DROPDOWN,
      0, 0, 0, 0, 0, 0, 0, nil)

  var r: RECT
  SendMessage(hwndComboBoxForCountSize, WM_SETFONT, hFont, 0)
  GetWindowRect(hwndComboBoxForCountSize, r)
  result = r.bottom - r.top

proc getTextFontSizeWithCheckMark(text: string, hFont: HANDLE): wSize =
  let
    hdc = GetDC(0)
    prev = SelectObject(hdc, hFont)
    checkWidth = 12 * GetDeviceCaps(hdc, LOGPIXELSX).int div 96 + 1
    checkHeight = 12 * GetDeviceCaps(hdc, LOGPIXELSY).int div 96 + 1
  var textOffset: INT
  GetCharWidth(hdc, '0'.UINT, '0'.UINT, addr textOffset)
  SelectObject(hdc, prev)
  ReleaseDC(0, hdc)

  result = getTextFontSize(text & " ", hFont)
  result.width += checkWidth + textOffset.int div 2
  if result.width < checkHeight: result.width = checkHeight

proc toDateTime(st: SYSTEMTIME): DateTime =
  initDateTime(st.wDay, Month st.wMonth, st.wYear.int, st.wHour, st.wMinute,
    st.wSecond)

proc toSystemTime(dateTime: DateTime): SYSTEMTIME =
  result.wSecond = WORD dateTime.second
  result.wMinute = WORD dateTime.minute
  result.wHour = WORD dateTime.hour
  result.wYear = WORD dateTime.year
  result.wMonth = WORD dateTime.month
  result.wDay = WORD dateTime.monthday

proc toTime(st: SYSTEMTIME): wTime =
  st.toDateTime().toTime()

proc toSystemTime(time: wTime): SYSTEMTIME =
  result = time.inZone(local()).toSystemTime()


proc wGetMenuItemInfo(hmenu: HMENU, pos: int, fMask = MIIM_STATE): MENUITEMINFO =
  result = MENUITEMINFO(cbSize: sizeof(MENUITEMINFO), fMask: fMask)
  GetMenuItemInfo(hmenu, pos, true, result)

proc wGetMenuItemString(hmenu: HMENU, pos: int, buffer: var TString): int =
  var menuItemInfo = MENUITEMINFO(
    cbSize: sizeof(MENUITEMINFO),
    fMask: MIIM_STRING,
    dwTypeData: &buffer,
    cch: buffer.high)

  if GetMenuItemInfo(hmenu, pos, true, menuItemInfo) != 0:
    result = menuItemInfo.cch

proc wEnableMenu(hmenu: HMENU, pos: int, flag: bool) =
  var menuItemInfo = wGetMenuItemInfo(hmenu, pos)
  if flag:
    menuItemInfo.fState = menuItemInfo.fState and (not MFS_DISABLED)
  else:
    menuItemInfo.fState = menuItemInfo.fState or MFS_DISABLED
  SetMenuItemInfo(hmenu, pos, true, menuItemInfo)

proc wIsMenuEnabled(hmenu: HMENU, pos: int): bool =
  var menuItemInfo = wGetMenuItemInfo(hmenu, pos)
  result = (menuItemInfo.fState and MFS_DISABLED) == 0

proc wCheckMenuItem(hmenu: HMENU, pos: int, flag: bool) =
  var menuItemInfo = wGetMenuItemInfo(hmenu, pos)
  if flag:
    menuItemInfo.fState = menuItemInfo.fState or MFS_CHECKED
  else:
    menuItemInfo.fState = menuItemInfo.fState and (not MFS_CHECKED)
  SetMenuItemInfo(hmenu, pos, true, menuItemInfo)

proc isMouseInWindow(mHwnd: HWND): bool =
  var mousePos: POINT
  GetCursorPos(mousePos)

  var hwnd = WindowFromPoint(mousePos)
  while hwnd != 0 and hwnd != mHwnd:
    hwnd = GetParent(hwnd)

  result = hwnd != 0

proc loadRichDll(): bool =
  var richDllLoaded {.global, threadvar.}: bool
  if not richDllLoaded:
    if LoadLibrary("msftedit.dll") != 0:
      richDllLoaded = true
  result = richDllLoaded

proc getThemeBackgroundColor*(hWnd: HWND): wColor =
  var gResult {.global.}: wColor = wDefaultColor
  if gResult != wDefaultColor:
    return gResult

  type
    GetCurrentThemeName = proc (pszThemeFileName: LPWSTR, dwMaxNameChars: int32,
      pszColorBuff: LPWSTR, cchMaxColorChars: int32, pszSizeBuff: LPWSTR,
      cchMaxSizeChars: int32): HRESULT {.stdcall.}
    OpenThemeData = proc (hwnd: HWND, pszClassList: LPCWSTR): HANDLE {.stdcall.}
    CloseThemeData = proc (hTheme: HANDLE): HRESULT {.stdcall.}
    GetThemeColor = proc (hTheme: HANDLE, iPartId, iStateId, iPropId: int32,
      pColor: ptr wColor): HRESULT {.stdcall.}
    IsAppThemed = proc (): BOOL {.stdcall.}
    IsThemeActive = proc (): BOOL {.stdcall.}

  let
    comctl32Lib = loadLib("comctl32.dll")
    themeLib = loadLib("uxtheme.dll")

  if themeLib != nil:
    # if aero theme is active: use white color
    try:
      if comctl32Lib == nil: raise
      defer: comctl32Lib.unloadLib()

      let
        isAppThemed = cast[IsAppThemed](themeLib.checkedSymAddr("IsThemeActive"))
        isThemeActive = cast[IsThemeActive](themeLib.checkedSymAddr("IsThemeActive"))
        getCurrentThemeName = cast[GetCurrentThemeName](themeLib.checkedSymAddr("GetCurrentThemeName"))

      if isAppThemed() == 0 or isThemeActive() == 0: raise

      var
        themeFile = newWString(1024)
        themeColor = newWString(256)

      if getCurrentThemeName(themeFile, 1024, themeColor, 256, nil, 0).FAILED or
        "Aero" notin $themeFile or "NormalColor" notin $themeColor: raise

      let dllGetVersion = cast[DLLGETVERSIONPROC](comctl32Lib.checkedSymAddr("DllGetVersion"))
      var dvi = DLLVERSIONINFO(cbSize: sizeof(DLLVERSIONINFO).DWORD)
      if dllGetVersion(dvi).FAILED or dvi.dwMajorVersion < 6.DWORD: raise

      gResult = wWHITE
      return gResult

    except: discard

    # check theme color
    try:
      const
        TABP_BODY = 10
        NORMAL = 1
        FILLCOLORHINT = 3821
        FILLCOLOR = 3802

      let
        openThemeData = cast[OpenThemeData](themeLib.checkedSymAddr("OpenThemeData"))
        closeThemeData = cast[CloseThemeData](themeLib.checkedSymAddr("CloseThemeData"))
        getThemeColor = cast[GetThemeColor](themeLib.checkedSymAddr("GetThemeColor"))
        hTheme = openThemeData(hWnd, "TAB")

      if hTheme == 0: raise
      defer: discard closeThemeData(hTheme)

      var color: wColor
      if getThemeColor(hTheme, TABP_BODY, NORMAL, FILLCOLORHINT, addr color).SUCCEEDED and color != 1:
        gResult = color
        return gResult

      if getThemeColor(hTheme, TABP_BODY, NORMAL, FILLCOLOR, addr color).SUCCEEDED:
        gResult = color
        return gResult

    except: discard

  return gResult

proc getIconSize(icon: HICON): wSize =
  var iconInfo: ICONINFO
  var bitmapInfo: BITMAP
  if GetIconInfo(icon, iconInfo) != 0:
    if GetObject(iconInfo.hbmColor, sizeof(bitmapInfo), cast[LPVOID](&bitmapInfo)) != 0:
      result = (int bitmapInfo.bmWidth, int bitmapInfo.bmHeight)

proc createIconFromMemory(data: ptr byte, length: int, width = -1, height = -1,
    isIcon = true): HICON =
  type
    ICONDIRENTRY {.pure, packed.} = object
      bWidth: BYTE
      bHeight: BYTE
      bColorCount: BYTE
      bReserved: BYTE
      wPlanes: WORD
      wBitCount: WORD
      dwBytesInRes: DWORD
      dwImageOffset: DWORD
    ICONDIR {.pure, packed.} = object
      idReserved: WORD
      idType: WORD
      idCount: WORD
      idEntries: UncheckedArray[ICONDIRENTRY]
    GRPICONDIRENTRY {.pure, packed.} = object
      bWidth: BYTE
      bHeight: BYTE
      bColorCount: BYTE
      bReserved: BYTE
      wPlanes: WORD
      wBitCount: WORD
      dwBytesInRes: DWORD
      nID: WORD
    GRPICONDIR {.pure, packed.} = object
      idReserved: WORD
      idType: WORD
      idCount: WORD
      idEntries: UncheckedArray[GRPICONDIRENTRY]

  var width = width
  var height = height
  if width < 0:
    width = GetSystemMetrics(if isIcon: SM_CXICON else: SM_CXCURSOR)

  if height < 0:
    height = GetSystemMetrics(if isIcon: SM_CYICON else: SM_CYCURSOR)

  var buffer = alloc0(length + 8)
  copyMem(buffer, data, length)
  defer: dealloc(buffer)

  # Don't use LR_SHARED in following CreateIconFromResourceEx
  # so all hande returned need to destroy

  # .png format
  #
  # Don't use this part!!
  # Because even Vista or Windows 7 handle system PNG icon with some error.
  # It is better to let wImage (gdiplus) deal with the png file.
  #
  # if cast[ptr int64](data)[] == 0x0a1a0a0d474e5089:
  #   # in this case, even isIcon set to false, return handle is still HICON
  #   # however, system don't care about it in most case
  #   return CreateIconFromResourceEx(cast[PBYTE](buffer), length, TRUE, 0x30000, width, height, 0)

  # .ani format
  if cast[ptr int32](data)[] == 0x46464952:
    # in this case, even isIcon set to true, return handle is still HCURSOR
    # https://stackoverflow.com/questions/11745851/load-an-animated-cursor-at-runtime-from-memory
    # add 8 zero?
    return CreateIconFromResourceEx(cast[PBYTE](buffer), length, FALSE, 0x30000, width, height, 0)

  # .ico or .cur format
  else:
    let pIconDir = cast[ptr ICONDIR](data)
    if pIconDir.idReserved != 0 or pIconDir.idType notin {1, 2} or pIconDir.idCount == 0:
      # other format? not support for now. Try use wImage?
      return 0

    # Here is the trick. fill GRPICONDIR by copy ICONDIR and let LookupIconIdFromDirectoryEx
    # choose the best fits nID
    let pGrpIconDir = cast[ptr GRPICONDIR](buffer)

    for i in 0..<int pIconDir.idCount:
      copyMem(&pGrpIconDir.idEntries[i], &pIconDir.idEntries[i], sizeof(GRPICONDIRENTRY))
      pGrpIconDir.idEntries[i].nID = WORD(i + 1)

    # use the nID it chooses, or use the first image.
    var index = int LookupIconIdFromDirectoryEx(cast[PBYTE](buffer), isIcon, width, height, 0)
    if index != 0:
      index.dec

    var size = int pIconDir.idEntries[index].dwBytesInRes
    var offset = int pIconDir.idEntries[index].dwImageOffset + cast[int](buffer)
    if not isIcon:
      # to create cursor from icon, just add 2 words of hot spot data before the icon data.
      size += 4
      offset -= 4
      let hotSpot = cast[ptr UncheckedArray[WORD]](offset)
      if pIconDir.idType == 2:
        # for .cur, these two members are in fact hot spot.
        hotSpot[0] = pIconDir.idEntries[index].wPlanes
        hotSpot[1] = pIconDir.idEntries[index].wBitCount
      else:
        # .ico without hotpost data, just assume in center.
        hotSpot[0] = pIconDir.idEntries[index].bWidth div 2
        hotSpot[1] = pIconDir.idEntries[index].bHeight div 2

    result = CreateIconFromResourceEx(cast[PBYTE](offset), size, isIcon, 0x30000,
      width, height, 0)

proc createIconFromHIcon(icon: HICON, isIcon = true, hotSpot = wDefaultPoint): HICON =
  var iconInfo: ICONINFO
  if GetIconInfo(icon, iconInfo) != 0:
    iconInfo.fIcon = BOOL isIcon
    if hotSpot.x >= 0: iconInfo.xHotspot = hotSpot.x
    if hotSpot.y >= 0: iconInfo.yHotspot = hotSpot.y
    return CreateIconIndirect(iconInfo)

proc createIconFromPE(filename: string, index = 0, width = -1, height = -1): HICON =
  type
    EnumInfo = object
      index: int
      width: int
      height: int
      handle: HCURSOR

  proc fromGroupId(module: HMODULE, name: LPTSTR, width, height: int): HICON =
    var resource = FindResource(module, name, RT_GROUP_ICON)
    var handle = LoadResource(module, resource)
    var resourcePtr = LockResource(handle)
    if resource != 0 and handle != 0 and resourcePtr != nil:
      let id = LookupIconIdFromDirectoryEx(cast[PBYTE](resourcePtr), TRUE,
        width, height, 0)
      var resource = FindResource(module, MAKEINTRESOURCE(id), RT_ICON)
      var handle = LoadResource(module, resource)
      var resourcePtr = LockResource(handle)
      var size = SizeofResource(module, resource)
      result = CreateIconFromResourceEx(cast[PBYTE](resourcePtr), size, TRUE,
        0x30000, width, height, 0)

  proc enumFunc(module: HMODULE, typ: LPTSTR, name: LPTSTR, lParam: LONG_PTR): WINBOOL
      {.stdcall.} =
    let pInfo = cast[ptr EnumInfo](lParam)
    if pInfo.index == 0:
      pInfo.handle = fromGroupId(module, name, pInfo.width, pInfo.height)
      return 0
    else:
      pInfo.index.dec
      return 1

  let width = if width < 0: GetSystemMetrics(SM_CXICON) else: width
  let height = if height < 0: GetSystemMetrics(SM_CYICON) else: height

  var module: HMODULE
  if filename.len == 0:
    module = 0 # for current process.
  else:
    module = LoadLibraryEx(filename, 0, LOAD_LIBRARY_AS_DATAFILE)
    if module == 0: return
  defer:
    if module != 0:
      FreeLibrary(module)

  if index >= 0:
    var info = EnumInfo(index: index, width: width, height: height)
    EnumResourceNames(module, MAKEINTRESOURCE(14), enumFunc, cast[LONG_PTR](&info))
    return info.handle

  else:
    return fromGroupId(module, cast[LPTSTR](-index), width, height)

# todo
# try to fix windows 10 SetWindowPos problem
# https://blog.forrestthewoods.com/building-a-better-aero-snap-757f68a1305f
# https://stackoverflow.com/questions/32752728/window-positioning-results-in-space-around-windows-on-windows-10
# no lucky for now, DwmAdjust seems works, but only work for showed window

# proc GetSystemMargin(hwnd: HWND): RECT =
#   const DWMWA_EXTENDED_FRAME_BOUNDS = 9
#   var DwmGetWindowAttribute: proc(hwnd: HWND, dwAttribute: DWORD, pvAttribute: PVOID, cbAttribute: DWORD): HRESULT {.stdcall.}
#   let dwmapi = loadLib("dwmapi")
#   if not dwmapi.isNil:
#     let p = dwmapi.symAddr("DwmGetWindowAttribute")
#     if not p.isNil:
#       var DwmGetWindowAttribute = cast[DwmGetWindowAttribute.type](p)
#       if DwmGetWindowAttribute(hwnd, DWMWA_EXTENDED_FRAME_BOUNDS, addr result, DWORD sizeof(RECT)) == S_OK:
#         echo result

# proc DwmAdjust(hwnd: HWND, x, y, width, height: var int) =
#   const DWMWA_EXTENDED_FRAME_BOUNDS = 9
#   var DwmGetWindowAttribute: proc(hwnd: HWND, dwAttribute: DWORD, pvAttribute: PVOID, cbAttribute: DWORD): HRESULT {.stdcall.}
#   let dwmapi = loadLib("dwmapi")
#   if not dwmapi.isNil:
#     let p = dwmapi.symAddr("DwmGetWindowAttribute")
#     if not p.isNil:
#       var DwmGetWindowAttribute = cast[DwmGetWindowAttribute.type](p)
#       var withMargin, noMargin: RECT
#       if DwmGetWindowAttribute(hwnd, DWMWA_EXTENDED_FRAME_BOUNDS, addr withMargin, DWORD sizeof(RECT)) == S_OK:
#         GetWindowRect(hwnd, addr noMargin)

#         x -= withMargin.left - noMargin.left
#         y -= withMargin.top - noMargin.top
#         width += (withMargin.left - noMargin.left) + (noMargin.right - withMargin.right)
#         height += (withMargin.top - noMargin.top) + (noMargin.bottom - withMargin.bottom)

