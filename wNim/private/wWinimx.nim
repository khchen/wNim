#====================================================================
#
#               Winim - Nim's Windows API Module
#                 (c) Copyright 2016-2019 Ward
#
#====================================================================

import winim/inc/winimbase
type
  UINT32* = int32
  LONG32* = int32
  PVOID* = pointer
  CHAR* = char
  LONG* = int32
  INT* = int32
  USHORT* = uint16
  ULONG* = int32
  WINBOOL* = int32
  BOOL* = int32
  LONGLONG* = int64
  ULONGLONG* = uint64
  LPSTR* = cstring
  LPCSTR* = cstring
  PCSTR* = cstring
  WCHAR* = uint16
  BYTE* = uint8
  WORD* = uint16
  DWORD* = int32
  LPINT* = ptr int32
  LPVOID* = pointer
  UINT* = int32
  PUINT* = ptr int32
  HANDLE* = int
  VOID* = void
  FARPROC* = pointer
when winimCpu64:
  type
    INT_PTR* = int64
    UINT_PTR* = uint64
    LONG_PTR* = int64
    ULONG_PTR* = uint64
when winimCpu32:
  type
    INT_PTR* = int32
    UINT_PTR* = int32
    LONG_PTR* = int32
    ULONG_PTR* = int32
type
  SIZE_T* = ULONG_PTR
  DWORD_PTR* = ULONG_PTR
  SHORT* = int16
  HRESULT* = LONG
  LPWSTR* = ptr WCHAR
  PWSTR* = ptr WCHAR
  LPCWSTR* = ptr WCHAR
  PCWSTR* = ptr WCHAR
  LCID* = ULONG
  PBYTE* = ptr BYTE
  LPDWORD* = ptr DWORD
  WPARAM* = UINT_PTR
  LPARAM* = LONG_PTR
  LRESULT* = LONG_PTR
  HGLOBAL* = HANDLE
  ATOM* = WORD
  HINSTANCE* = HANDLE
  HMODULE* = HINSTANCE
  HRGN* = HANDLE
  HRSRC* = HANDLE
  HWND* = HANDLE
  HHOOK* = HANDLE
  HACCEL* = HANDLE
  HBITMAP* = HANDLE
  HBRUSH* = HANDLE
  HDC* = HANDLE
  HENHMETAFILE* = HANDLE
  HFONT* = HANDLE
  HICON* = HANDLE
  HMENU* = HANDLE
  HPALETTE* = HANDLE
  HPEN* = HANDLE
  HCURSOR* = HICON
  COLORREF* = DWORD
  HGDIOBJ* = HANDLE
  OLECHAR* = WCHAR
when winimUnicode:
  type
    LPTSTR* = LPWSTR
when winimAnsi:
  type
    LPTSTR* = LPSTR
type
  LARGE_INTEGER_STRUCT1* {.pure.} = object
    LowPart*: ULONG
    HighPart*: LONG
  LARGE_INTEGER_u* {.pure.} = object
    LowPart*: ULONG
    HighPart*: LONG
  LARGE_INTEGER* {.pure, union.} = object
    struct1*: LARGE_INTEGER_STRUCT1
    u*: LARGE_INTEGER_u
    QuadPart*: LONGLONG
  ULARGE_INTEGER_STRUCT1* {.pure.} = object
    LowPart*: ULONG
    HighPart*: ULONG
  ULARGE_INTEGER_u* {.pure.} = object
    LowPart*: ULONG
    HighPart*: ULONG
  ULARGE_INTEGER* {.pure, union.} = object
    struct1*: ULARGE_INTEGER_STRUCT1
    u*: ULARGE_INTEGER_u
    QuadPart*: ULONGLONG
  GUID* {.pure.} = object
    Data1*: int32
    Data2*: uint16
    Data3*: uint16
    Data4*: array[8, uint8]
  IID* = GUID
  CLSID* = GUID
  REFGUID* = ptr GUID
  REFIID* = ptr IID
  REFCLSID* = ptr IID
  OSVERSIONINFOA* {.pure.} = object
    dwOSVersionInfoSize*: DWORD
    dwMajorVersion*: DWORD
    dwMinorVersion*: DWORD
    dwBuildNumber*: DWORD
    dwPlatformId*: DWORD
    szCSDVersion*: array[128, CHAR]
  LPOSVERSIONINFOA* = ptr OSVERSIONINFOA
  OSVERSIONINFOW* {.pure.} = object
    dwOSVersionInfoSize*: DWORD
    dwMajorVersion*: DWORD
    dwMinorVersion*: DWORD
    dwBuildNumber*: DWORD
    dwPlatformId*: DWORD
    szCSDVersion*: array[128, WCHAR]
  LPOSVERSIONINFOW* = ptr OSVERSIONINFOW
  FILETIME* {.pure.} = object
    dwLowDateTime*: DWORD
    dwHighDateTime*: DWORD
  RECT* {.pure.} = object
    left*: LONG
    top*: LONG
    right*: LONG
    bottom*: LONG
  PRECT* = ptr RECT
  LPRECT* = ptr RECT
  POINT* {.pure.} = object
    x*: LONG
    y*: LONG
  LPPOINT* = ptr POINT
  POINTL* {.pure.} = object
    x*: LONG
    y*: LONG
  SIZE* {.pure.} = object
    cx*: LONG
    cy*: LONG
  LPSIZE* = ptr SIZE
const
  FALSE* = 0
  TRUE* = 1
  MAX_PATH* = 260
template DEFINE_GUID*(data1: int32, data2: uint16, data3: uint16, data4: array[8, uint8]): GUID = GUID(Data1: data1, Data2: data2, Data3: data3, Data4: data4)
const
  NULL* = nil
proc IsEqualIID*(rguid1: REFIID, rguid2: REFIID): BOOL {.winapi, stdcall, dynlib: "ole32", importc: "IsEqualGUID".}
template MAKELONG*(a: untyped, b: untyped): DWORD = cast[DWORD](b shl 16) or DWORD(a and 0xffff)
template LOWORD*(l: untyped): WORD = WORD(l and 0xffff)
template HIWORD*(l: untyped): WORD = WORD((l shr 16) and 0xffff)
template GET_X_LPARAM*(x: untyped): int = int cast[int16](LOWORD(x))
template GET_Y_LPARAM*(x: untyped): int = int cast[int16](HIWORD(x))
proc `LowPart=`*(self: var LARGE_INTEGER, x: ULONG) {.inline.} = self.struct1.LowPart = x
proc LowPart*(self: LARGE_INTEGER): ULONG {.inline.} = self.struct1.LowPart
proc LowPart*(self: var LARGE_INTEGER): var ULONG {.inline.} = self.struct1.LowPart
proc `HighPart=`*(self: var LARGE_INTEGER, x: LONG) {.inline.} = self.struct1.HighPart = x
proc HighPart*(self: LARGE_INTEGER): LONG {.inline.} = self.struct1.HighPart
proc HighPart*(self: var LARGE_INTEGER): var LONG {.inline.} = self.struct1.HighPart
proc `LowPart=`*(self: var ULARGE_INTEGER, x: ULONG) {.inline.} = self.struct1.LowPart = x
proc LowPart*(self: ULARGE_INTEGER): ULONG {.inline.} = self.struct1.LowPart
proc LowPart*(self: var ULARGE_INTEGER): var ULONG {.inline.} = self.struct1.LowPart
proc `HighPart=`*(self: var ULARGE_INTEGER, x: ULONG) {.inline.} = self.struct1.HighPart = x
proc HighPart*(self: ULARGE_INTEGER): ULONG {.inline.} = self.struct1.HighPart
proc HighPart*(self: var ULARGE_INTEGER): var ULONG {.inline.} = self.struct1.HighPart
when winimUnicode:
  type
    OSVERSIONINFO* = OSVERSIONINFOW
when winimAnsi:
  type
    OSVERSIONINFO* = OSVERSIONINFOA
const
  FACILITY_WIN32* = 7
  ERROR_CANCELLED* = 1223
  E_NOTIMPL* = HRESULT 0x80004001'i32
  E_NOINTERFACE* = HRESULT 0x80004002'i32
  E_FAIL* = HRESULT 0x80004005'i32
template HRESULT_FROM_WIN32*(x: untyped): HRESULT = (if x <= 0: HRESULT x else: HRESULT(x and 0x0000ffff) or HRESULT(FACILITY_WIN32 shl 16) or HRESULT(0x80000000))
const
  S_OK* = HRESULT 0x00000000
  DRAGDROP_S_DROP* = HRESULT 0x00040100
  DRAGDROP_S_CANCEL* = HRESULT 0x00040101
template SUCCEEDED*(hr: untyped): bool = hr.HRESULT >= 0
template FAILED*(hr: untyped): bool = hr.HRESULT < 0
type
  SECURITY_ATTRIBUTES* {.pure.} = object
    nLength*: DWORD
    lpSecurityDescriptor*: LPVOID
    bInheritHandle*: WINBOOL
  LPSECURITY_ATTRIBUTES* = ptr SECURITY_ATTRIBUTES
  SYSTEMTIME* {.pure.} = object
    wYear*: WORD
    wMonth*: WORD
    wDayOfWeek*: WORD
    wDay*: WORD
    wHour*: WORD
    wMinute*: WORD
    wSecond*: WORD
    wMilliseconds*: WORD
  LPSYSTEMTIME* = ptr SYSTEMTIME
const
  LOAD_LIBRARY_AS_DATAFILE* = 0x2
  GMEM_FIXED* = 0x0
  GMEM_ZEROINIT* = 0x40
  GPTR* = GMEM_FIXED or GMEM_ZEROINIT
type
  ENUMRESNAMEPROCA* = proc (hModule: HMODULE, lpType: LPCSTR, lpName: LPSTR, lParam: LONG_PTR): WINBOOL {.stdcall.}
  ENUMRESNAMEPROCW* = proc (hModule: HMODULE, lpType: LPCWSTR, lpName: LPWSTR, lParam: LONG_PTR): WINBOOL {.stdcall.}
proc LoadResource*(hModule: HMODULE, hResInfo: HRSRC): HGLOBAL {.winapi, stdcall, dynlib: "kernel32", importc.}
proc LockResource*(hResData: HGLOBAL): LPVOID {.winapi, stdcall, dynlib: "kernel32", importc.}
proc SizeofResource*(hModule: HMODULE, hResInfo: HRSRC): DWORD {.winapi, stdcall, dynlib: "kernel32", importc.}
proc FreeLibrary*(hLibModule: HMODULE): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc.}
proc GetProcAddress*(hModule: HMODULE, lpProcName: LPCSTR): FARPROC {.winapi, stdcall, dynlib: "kernel32", importc.}
proc GetCurrentThreadId*(): DWORD {.winapi, stdcall, dynlib: "kernel32", importc.}
proc GetLocalTime*(lpSystemTime: LPSYSTEMTIME): VOID {.winapi, stdcall, dynlib: "kernel32", importc.}
proc GlobalAlloc*(uFlags: UINT, dwBytes: SIZE_T): HGLOBAL {.winapi, stdcall, dynlib: "kernel32", importc.}
proc GlobalLock*(hMem: HGLOBAL): LPVOID {.winapi, stdcall, dynlib: "kernel32", importc.}
proc GlobalUnlock*(hMem: HGLOBAL): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc.}
proc MulDiv*(nNumber: int32, nNumerator: int32, nDenominator: int32): int32 {.winapi, stdcall, dynlib: "kernel32", importc.}
proc InterlockedIncrement*(Addend: ptr LONG): LONG {.importc: "InterlockedIncrement", header: "<windows.h>".}
proc InterlockedDecrement*(Addend: ptr LONG): LONG {.importc: "InterlockedDecrement", header: "<windows.h>".}
when winimUnicode:
  proc GetFullPathName*(lpFileName: LPCWSTR, nBufferLength: DWORD, lpBuffer: LPWSTR, lpFilePart: ptr LPWSTR): DWORD {.winapi, stdcall, dynlib: "kernel32", importc: "GetFullPathNameW".}
  proc GetModuleHandle*(lpModuleName: LPCWSTR): HMODULE {.winapi, stdcall, dynlib: "kernel32", importc: "GetModuleHandleW".}
  proc LoadLibraryEx*(lpLibFileName: LPCWSTR, hFile: HANDLE, dwFlags: DWORD): HMODULE {.winapi, stdcall, dynlib: "kernel32", importc: "LoadLibraryExW".}
  proc SetCurrentDirectory*(lpPathName: LPCWSTR): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc: "SetCurrentDirectoryW".}
  proc CreateEvent*(lpEventAttributes: LPSECURITY_ATTRIBUTES, bManualReset: WINBOOL, bInitialState: WINBOOL, lpName: LPCWSTR): HANDLE {.winapi, stdcall, dynlib: "kernel32", importc: "CreateEventW".}
  proc GetVersionEx*(lpVersionInformation: LPOSVERSIONINFOW): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc: "GetVersionExW".}
  proc LoadLibrary*(lpLibFileName: LPCWSTR): HMODULE {.winapi, stdcall, dynlib: "kernel32", importc: "LoadLibraryW".}
  proc FindResource*(hModule: HMODULE, lpName: LPCWSTR, lpType: LPCWSTR): HRSRC {.winapi, stdcall, dynlib: "kernel32", importc: "FindResourceW".}
  proc EnumResourceNames*(hModule: HMODULE, lpType: LPCWSTR, lpEnumFunc: ENUMRESNAMEPROCW, lParam: LONG_PTR): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc: "EnumResourceNamesW".}
when winimAnsi:
  proc GetFullPathName*(lpFileName: LPCSTR, nBufferLength: DWORD, lpBuffer: LPSTR, lpFilePart: ptr LPSTR): DWORD {.winapi, stdcall, dynlib: "kernel32", importc: "GetFullPathNameA".}
  proc GetModuleHandle*(lpModuleName: LPCSTR): HMODULE {.winapi, stdcall, dynlib: "kernel32", importc: "GetModuleHandleA".}
  proc LoadLibraryEx*(lpLibFileName: LPCSTR, hFile: HANDLE, dwFlags: DWORD): HMODULE {.winapi, stdcall, dynlib: "kernel32", importc: "LoadLibraryExA".}
  proc SetCurrentDirectory*(lpPathName: LPCSTR): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc: "SetCurrentDirectoryA".}
  proc CreateEvent*(lpEventAttributes: LPSECURITY_ATTRIBUTES, bManualReset: WINBOOL, bInitialState: WINBOOL, lpName: LPCSTR): HANDLE {.winapi, stdcall, dynlib: "kernel32", importc: "CreateEventA".}
  proc GetVersionEx*(lpVersionInformation: LPOSVERSIONINFOA): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc: "GetVersionExA".}
  proc LoadLibrary*(lpLibFileName: LPCSTR): HMODULE {.winapi, stdcall, dynlib: "kernel32", importc: "LoadLibraryA".}
  proc FindResource*(hModule: HMODULE, lpName: LPCSTR, lpType: LPCSTR): HRSRC {.winapi, stdcall, dynlib: "kernel32", importc: "FindResourceA".}
  proc EnumResourceNames*(hModule: HMODULE, lpType: LPCSTR, lpEnumFunc: ENUMRESNAMEPROCA, lParam: LONG_PTR): WINBOOL {.winapi, stdcall, dynlib: "kernel32", importc: "EnumResourceNamesA".}
type
  BITMAP* {.pure.} = object
    bmType*: LONG
    bmWidth*: LONG
    bmHeight*: LONG
    bmWidthBytes*: LONG
    bmPlanes*: WORD
    bmBitsPixel*: WORD
    bmBits*: LPVOID
  RGBQUAD* {.pure.} = object
    rgbBlue*: BYTE
    rgbGreen*: BYTE
    rgbRed*: BYTE
    rgbReserved*: BYTE
  BITMAPINFOHEADER* {.pure.} = object
    biSize*: DWORD
    biWidth*: LONG
    biHeight*: LONG
    biPlanes*: WORD
    biBitCount*: WORD
    biCompression*: DWORD
    biSizeImage*: DWORD
    biXPelsPerMeter*: LONG
    biYPelsPerMeter*: LONG
    biClrUsed*: DWORD
    biClrImportant*: DWORD
  BITMAPINFO* {.pure.} = object
    bmiHeader*: BITMAPINFOHEADER
    bmiColors*: array[1, RGBQUAD]
  LOGBRUSH* {.pure.} = object
    lbStyle*: UINT
    lbColor*: COLORREF
    lbHatch*: ULONG_PTR
  EXTLOGPEN* {.pure.} = object
    elpPenStyle*: DWORD
    elpWidth*: DWORD
    elpBrushStyle*: UINT
    elpColor*: COLORREF
    elpHatch*: ULONG_PTR
    elpNumEntries*: DWORD
    elpStyleEntry*: array[1, DWORD]
const
  LF_FACESIZE* = 32
type
  LOGFONTA* {.pure.} = object
    lfHeight*: LONG
    lfWidth*: LONG
    lfEscapement*: LONG
    lfOrientation*: LONG
    lfWeight*: LONG
    lfItalic*: BYTE
    lfUnderline*: BYTE
    lfStrikeOut*: BYTE
    lfCharSet*: BYTE
    lfOutPrecision*: BYTE
    lfClipPrecision*: BYTE
    lfQuality*: BYTE
    lfPitchAndFamily*: BYTE
    lfFaceName*: array[LF_FACESIZE, CHAR]
  LOGFONTW* {.pure.} = object
    lfHeight*: LONG
    lfWidth*: LONG
    lfEscapement*: LONG
    lfOrientation*: LONG
    lfWeight*: LONG
    lfItalic*: BYTE
    lfUnderline*: BYTE
    lfStrikeOut*: BYTE
    lfCharSet*: BYTE
    lfOutPrecision*: BYTE
    lfClipPrecision*: BYTE
    lfQuality*: BYTE
    lfPitchAndFamily*: BYTE
    lfFaceName*: array[LF_FACESIZE, WCHAR]
  BLENDFUNCTION* {.pure.} = object
    BlendOp*: BYTE
    BlendFlags*: BYTE
    SourceConstantAlpha*: BYTE
    AlphaFormat*: BYTE
  DIBSECTION* {.pure.} = object
    dsBm*: BITMAP
    dsBmih*: BITMAPINFOHEADER
    dsBitfields*: array[3, DWORD]
    dshSection*: HANDLE
    dsOffset*: DWORD
const
  R2_BLACK* = 1
  R2_NOTMERGEPEN* = 2
  R2_MASKNOTPEN* = 3
  R2_NOTCOPYPEN* = 4
  R2_MASKPENNOT* = 5
  R2_NOT* = 6
  R2_XORPEN* = 7
  R2_NOTMASKPEN* = 8
  R2_MASKPEN* = 9
  R2_NOTXORPEN* = 10
  R2_NOP* = 11
  R2_MERGENOTPEN* = 12
  R2_COPYPEN* = 13
  R2_MERGEPENNOT* = 14
  R2_MERGEPEN* = 15
  R2_WHITE* = 16
  SRCCOPY* = DWORD 0x00CC0020
  SRCPAINT* = DWORD 0x00EE0086
  SRCAND* = DWORD 0x008800C6
  SRCINVERT* = DWORD 0x00660046
  SRCERASE* = DWORD 0x00440328
  NOTSRCCOPY* = DWORD 0x00330008
  MERGECOPY* = DWORD 0x00C000CA
  MERGEPAINT* = DWORD 0x00BB0226
  DSTINVERT* = DWORD 0x00550009
  BLACKNESS* = DWORD 0x00000042
  WHITENESS* = DWORD 0x00FF0062
  ALTERNATE* = 1
  WINDING* = 2
  DEFAULT_PITCH* = 0
  ANSI_CHARSET* = 0
  DEFAULT_CHARSET* = 1
  SHIFTJIS_CHARSET* = 128
  HANGUL_CHARSET* = 129
  GB2312_CHARSET* = 134
  CHINESEBIG5_CHARSET* = 136
  OEM_CHARSET* = 255
  JOHAB_CHARSET* = 130
  HEBREW_CHARSET* = 177
  ARABIC_CHARSET* = 178
  GREEK_CHARSET* = 161
  VIETNAMESE_CHARSET* = 163
  THAI_CHARSET* = 222
  EASTEUROPE_CHARSET* = 238
  RUSSIAN_CHARSET* = 204
  BALTIC_CHARSET* = 186
  FF_DONTCARE* = 0 shl 4
  FF_ROMAN* = 1 shl 4
  FF_SWISS* = 2 shl 4
  FF_MODERN* = 3 shl 4
  FF_SCRIPT* = 4 shl 4
  FF_DECORATIVE* = 5 shl 4
  FW_THIN* = 100
  FW_EXTRALIGHT* = 200
  FW_LIGHT* = 300
  FW_NORMAL* = 400
  FW_MEDIUM* = 500
  FW_SEMIBOLD* = 600
  FW_BOLD* = 700
  FW_EXTRABOLD* = 800
  FW_HEAVY* = 900
  TRANSPARENT* = 1
  OPAQUE* = 2
  MM_TEXT* = 1
  MM_ANISOTROPIC* = 8
  DEFAULT_GUI_FONT* = 17
  BS_SOLID* = 0
  BS_NULL* = 1
  BS_HOLLOW* = BS_NULL
  BS_HATCHED* = 2
  HS_HORIZONTAL* = 0
  HS_VERTICAL* = 1
  HS_FDIAGONAL* = 2
  HS_BDIAGONAL* = 3
  HS_CROSS* = 4
  HS_DIAGCROSS* = 5
  PS_SOLID* = 0
  PS_DASH* = 1
  PS_DOT* = 2
  PS_DASHDOT* = 3
  PS_NULL* = 5
  PS_STYLE_MASK* = 0x0000000F
  PS_ENDCAP_ROUND* = 0x00000000
  PS_ENDCAP_SQUARE* = 0x00000100
  PS_ENDCAP_FLAT* = 0x00000200
  PS_ENDCAP_MASK* = 0x00000F00
  PS_JOIN_ROUND* = 0x00000000
  PS_JOIN_BEVEL* = 0x00001000
  PS_JOIN_MITER* = 0x00002000
  PS_JOIN_MASK* = 0x0000F000
  PS_GEOMETRIC* = 0x00010000
  HORZRES* = 8
  VERTRES* = 10
  BITSPIXEL* = 12
  PLANES* = 14
  LOGPIXELSX* = 88
  LOGPIXELSY* = 90
  AC_SRC_OVER* = 0x00
  AC_SRC_ALPHA* = 0x01
proc Arc*(hdc: HDC, x1: int32, y1: int32, x2: int32, y2: int32, x3: int32, y3: int32, x4: int32, y4: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc BitBlt*(hdc: HDC, x: int32, y: int32, cx: int32, cy: int32, hdcSrc: HDC, x1: int32, y1: int32, rop: DWORD): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateBitmap*(nWidth: int32, nHeight: int32, nPlanes: UINT, nBitCount: UINT, lpBits: pointer): HBITMAP {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateBrushIndirect*(plbrush: ptr LOGBRUSH): HBRUSH {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateCompatibleBitmap*(hdc: HDC, cx: int32, cy: int32): HBITMAP {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateCompatibleDC*(hdc: HDC): HDC {.winapi, stdcall, dynlib: "gdi32", importc.}
proc DeleteDC*(hdc: HDC): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc DeleteObject*(ho: HGDIOBJ): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Ellipse*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetROP2*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetBkMode*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetDeviceCaps*(hdc: HDC, index: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetObjectType*(h: HGDIOBJ): DWORD {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetPixel*(hdc: HDC, x: int32, y: int32): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetStockObject*(i: int32): HGDIOBJ {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetViewportOrgEx*(hdc: HDC, lppoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc LineTo*(hdc: HDC, x: int32, y: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Pie*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32, xr1: int32, yr1: int32, xr2: int32, yr2: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc PolyPolygon*(hdc: HDC, apt: ptr POINT, asz: ptr INT, csz: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Rectangle*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc RoundRect*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32, width: int32, height: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SelectObject*(hdc: HDC, h: HGDIOBJ): HGDIOBJ {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBkColor*(hdc: HDC, color: COLORREF): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBkMode*(hdc: HDC, mode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBitmapBits*(hbm: HBITMAP, cb: DWORD, pvBits: pointer): LONG {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetMapMode*(hdc: HDC, iMode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetPixel*(hdc: HDC, x: int32, y: int32, color: COLORREF): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetPolyFillMode*(hdc: HDC, mode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc StretchBlt*(hdcDest: HDC, xDest: int32, yDest: int32, wDest: int32, hDest: int32, hdcSrc: HDC, xSrc: int32, ySrc: int32, wSrc: int32, hSrc: int32, rop: DWORD): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetROP2*(hdc: HDC, rop2: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetTextColor*(hdc: HDC, color: COLORREF): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc AlphaBlend*(hdcDest: HDC, xoriginDest: int32, yoriginDest: int32, wDest: int32, hDest: int32, hdcSrc: HDC, xoriginSrc: int32, yoriginSrc: int32, wSrc: int32, hSrc: int32, ftn: BLENDFUNCTION): WINBOOL {.winapi, stdcall, dynlib: "msimg32", importc.}
proc TransparentBlt*(hdcDest: HDC, xoriginDest: int32, yoriginDest: int32, wDest: int32, hDest: int32, hdcSrc: HDC, xoriginSrc: int32, yoriginSrc: int32, wSrc: int32, hSrc: int32, crTransparent: UINT): WINBOOL {.winapi, stdcall, dynlib: "msimg32", importc.}
proc CreateDIBSection*(hdc: HDC, lpbmi: ptr BITMAPINFO, usage: UINT, ppvBits: ptr pointer, hSection: HANDLE, offset: DWORD): HBITMAP {.winapi, stdcall, dynlib: "gdi32", importc.}
proc ExtCreatePen*(iPenStyle: DWORD, cWidth: DWORD, plbrush: ptr LOGBRUSH, cStyle: DWORD, pstyle: ptr DWORD): HPEN {.winapi, stdcall, dynlib: "gdi32", importc.}
proc MoveToEx*(hdc: HDC, x: int32, y: int32, lppt: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Polygon*(hdc: HDC, apt: ptr POINT, cpt: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Polyline*(hdc: HDC, apt: ptr POINT, cpt: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc PolyBezier*(hdc: HDC, apt: ptr POINT, cpt: DWORD): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetViewportExtEx*(hdc: HDC, x: int32, y: int32, lpsz: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetViewportOrgEx*(hdc: HDC, x: int32, y: int32, lppt: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetWindowExtEx*(hdc: HDC, x: int32, y: int32, lpsz: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
template RGB*(r: untyped, g: untyped, b: untyped): COLORREF = COLORREF(COLORREF(r and 0xff) or (COLORREF(g and 0xff) shl 8) or (COLORREF(b and 0xff) shl 16))
template GetRValue*(c: untyped): BYTE = BYTE((c) and 0xff)
template GetGValue*(c: untyped): BYTE = BYTE((c shr 8) and 0xff)
template GetBValue*(c: untyped): BYTE = BYTE((c shr 16) and 0xff)
when winimUnicode:
  type
    LOGFONT* = LOGFONTW
  proc CreateFontIndirect*(lplf: ptr LOGFONTW): HFONT {.winapi, stdcall, dynlib: "gdi32", importc: "CreateFontIndirectW".}
  proc GetCharWidth*(hdc: HDC, iFirst: UINT, iLast: UINT, lpBuffer: LPINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetCharWidthW".}
  proc GetTextExtentPoint32*(hdc: HDC, lpString: LPCWSTR, c: int32, psizl: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetTextExtentPoint32W".}
  proc GetObject*(h: HANDLE, c: int32, pv: LPVOID): int32 {.winapi, stdcall, dynlib: "gdi32", importc: "GetObjectW".}
  proc TextOut*(hdc: HDC, x: int32, y: int32, lpString: LPCWSTR, c: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "TextOutW".}
when winimAnsi:
  type
    LOGFONT* = LOGFONTA
  proc CreateFontIndirect*(lplf: ptr LOGFONTA): HFONT {.winapi, stdcall, dynlib: "gdi32", importc: "CreateFontIndirectA".}
  proc GetCharWidth*(hdc: HDC, iFirst: UINT, iLast: UINT, lpBuffer: LPINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetCharWidthA".}
  proc GetTextExtentPoint32*(hdc: HDC, lpString: LPCSTR, c: int32, psizl: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetTextExtentPoint32A".}
  proc GetObject*(h: HANDLE, c: int32, pv: LPVOID): int32 {.winapi, stdcall, dynlib: "gdi32", importc: "GetObjectA".}
  proc TextOut*(hdc: HDC, x: int32, y: int32, lpString: LPCSTR, c: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "TextOutA".}
type
  WNDPROC* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): LRESULT {.stdcall.}
  WNDCLASSEXA* {.pure.} = object
    cbSize*: UINT
    style*: UINT
    lpfnWndProc*: WNDPROC
    cbClsExtra*: int32
    cbWndExtra*: int32
    hInstance*: HINSTANCE
    hIcon*: HICON
    hCursor*: HCURSOR
    hbrBackground*: HBRUSH
    lpszMenuName*: LPCSTR
    lpszClassName*: LPCSTR
    hIconSm*: HICON
  LPWNDCLASSEXA* = ptr WNDCLASSEXA
  WNDCLASSEXW* {.pure.} = object
    cbSize*: UINT
    style*: UINT
    lpfnWndProc*: WNDPROC
    cbClsExtra*: int32
    cbWndExtra*: int32
    hInstance*: HINSTANCE
    hIcon*: HICON
    hCursor*: HCURSOR
    hbrBackground*: HBRUSH
    lpszMenuName*: LPCWSTR
    lpszClassName*: LPCWSTR
    hIconSm*: HICON
  LPWNDCLASSEXW* = ptr WNDCLASSEXW
  MSG* {.pure.} = object
    hwnd*: HWND
    message*: UINT
    wParam*: WPARAM
    lParam*: LPARAM
    time*: DWORD
    pt*: POINT
  LPMSG* = ptr MSG
  MINMAXINFO* {.pure.} = object
    ptReserved*: POINT
    ptMaxSize*: POINT
    ptMaxPosition*: POINT
    ptMinTrackSize*: POINT
    ptMaxTrackSize*: POINT
  PMINMAXINFO* = ptr MINMAXINFO
  WINDOWPOS* {.pure.} = object
    hwnd*: HWND
    hwndInsertAfter*: HWND
    x*: int32
    y*: int32
    cx*: int32
    cy*: int32
    flags*: UINT
  LPWINDOWPOS* = ptr WINDOWPOS
  TTRACKMOUSEEVENT* {.pure.} = object
    cbSize*: DWORD
    dwFlags*: DWORD
    hwndTrack*: HWND
    dwHoverTime*: DWORD
  LPTRACKMOUSEEVENT* = ptr TTRACKMOUSEEVENT
  ACCEL* {.pure.} = object
    fVirt*: BYTE
    key*: WORD
    cmd*: WORD
  LPACCEL* = ptr ACCEL
  PAINTSTRUCT* {.pure.} = object
    hdc*: HDC
    fErase*: WINBOOL
    rcPaint*: RECT
    fRestore*: WINBOOL
    fIncUpdate*: WINBOOL
    rgbReserved*: array[32, BYTE]
  LPPAINTSTRUCT* = ptr PAINTSTRUCT
  NMHDR* {.pure.} = object
    hwndFrom*: HWND
    idFrom*: UINT_PTR
    code*: UINT
  LPNMHDR* = ptr NMHDR
  MEASUREITEMSTRUCT* {.pure.} = object
    CtlType*: UINT
    CtlID*: UINT
    itemID*: UINT
    itemWidth*: UINT
    itemHeight*: UINT
    itemData*: ULONG_PTR
  LPMEASUREITEMSTRUCT* = ptr MEASUREITEMSTRUCT
  DRAWITEMSTRUCT* {.pure.} = object
    CtlType*: UINT
    CtlID*: UINT
    itemID*: UINT
    itemAction*: UINT
    itemState*: UINT
    hwndItem*: HWND
    hDC*: HDC
    rcItem*: RECT
    itemData*: ULONG_PTR
  LPDRAWITEMSTRUCT* = ptr DRAWITEMSTRUCT
  MENUINFO* {.pure.} = object
    cbSize*: DWORD
    fMask*: DWORD
    dwStyle*: DWORD
    cyMax*: UINT
    hbrBack*: HBRUSH
    dwContextHelpID*: DWORD
    dwMenuData*: ULONG_PTR
  LPMENUINFO* = ptr MENUINFO
  LPCMENUINFO* = ptr MENUINFO
  MENUITEMINFOA* {.pure.} = object
    cbSize*: UINT
    fMask*: UINT
    fType*: UINT
    fState*: UINT
    wID*: UINT
    hSubMenu*: HMENU
    hbmpChecked*: HBITMAP
    hbmpUnchecked*: HBITMAP
    dwItemData*: ULONG_PTR
    dwTypeData*: LPSTR
    cch*: UINT
    hbmpItem*: HBITMAP
  LPMENUITEMINFOA* = ptr MENUITEMINFOA
  MENUITEMINFOW* {.pure.} = object
    cbSize*: UINT
    fMask*: UINT
    fType*: UINT
    fState*: UINT
    wID*: UINT
    hSubMenu*: HMENU
    hbmpChecked*: HBITMAP
    hbmpUnchecked*: HBITMAP
    dwItemData*: ULONG_PTR
    dwTypeData*: LPWSTR
    cch*: UINT
    hbmpItem*: HBITMAP
  LPMENUITEMINFOW* = ptr MENUITEMINFOW
  LPCMENUITEMINFOA* = ptr MENUITEMINFOA
  LPCMENUITEMINFOW* = ptr MENUITEMINFOW
  ICONINFO* {.pure.} = object
    fIcon*: WINBOOL
    xHotspot*: DWORD
    yHotspot*: DWORD
    hbmMask*: HBITMAP
    hbmColor*: HBITMAP
  PICONINFO* = ptr ICONINFO
  SCROLLINFO* {.pure.} = object
    cbSize*: UINT
    fMask*: UINT
    nMin*: int32
    nMax*: int32
    nPage*: UINT
    nPos*: int32
    nTrackPos*: int32
  LPSCROLLINFO* = ptr SCROLLINFO
  LPCSCROLLINFO* = ptr SCROLLINFO
  NONCLIENTMETRICSA* {.pure.} = object
    cbSize*: UINT
    iBorderWidth*: int32
    iScrollWidth*: int32
    iScrollHeight*: int32
    iCaptionWidth*: int32
    iCaptionHeight*: int32
    lfCaptionFont*: LOGFONTA
    iSmCaptionWidth*: int32
    iSmCaptionHeight*: int32
    lfSmCaptionFont*: LOGFONTA
    iMenuWidth*: int32
    iMenuHeight*: int32
    lfMenuFont*: LOGFONTA
    lfStatusFont*: LOGFONTA
    lfMessageFont*: LOGFONTA
    iPaddedBorderWidth*: int32
  NONCLIENTMETRICSW* {.pure.} = object
    cbSize*: UINT
    iBorderWidth*: int32
    iScrollWidth*: int32
    iScrollHeight*: int32
    iCaptionWidth*: int32
    iCaptionHeight*: int32
    lfCaptionFont*: LOGFONTW
    iSmCaptionWidth*: int32
    iSmCaptionHeight*: int32
    lfSmCaptionFont*: LOGFONTW
    iMenuWidth*: int32
    iMenuHeight*: int32
    lfMenuFont*: LOGFONTW
    lfStatusFont*: LOGFONTW
    lfMessageFont*: LOGFONTW
    iPaddedBorderWidth*: int32
const
  CCHILDREN_SCROLLBAR* = 5
type
  SCROLLBARINFO* {.pure.} = object
    cbSize*: DWORD
    rcScrollBar*: RECT
    dxyLineButton*: int32
    xyThumbTop*: int32
    xyThumbBottom*: int32
    reserved*: int32
    rgstate*: array[CCHILDREN_SCROLLBAR + 1, DWORD]
  PSCROLLBARINFO* = ptr SCROLLBARINFO
  COMBOBOXINFO* {.pure.} = object
    cbSize*: DWORD
    rcItem*: RECT
    rcButton*: RECT
    stateButton*: DWORD
    hwndCombo*: HWND
    hwndItem*: HWND
    hwndList*: HWND
  PCOMBOBOXINFO* = ptr COMBOBOXINFO
template MAKEINTRESOURCE*(i: untyped): untyped = cast[LPTSTR](i and 0xffff)
const
  RT_CURSOR* = MAKEINTRESOURCE(1)
  RT_ICON* = MAKEINTRESOURCE(3)
  DIFFERENCE* = 11
  SB_HORZ* = 0
  SB_VERT* = 1
  SB_CTL* = 2
  SB_LINEUP* = 0
  SB_LINEDOWN* = 1
  SB_PAGEUP* = 2
  SB_PAGEDOWN* = 3
  SB_THUMBPOSITION* = 4
  SB_THUMBTRACK* = 5
  SB_TOP* = 6
  SB_BOTTOM* = 7
  SB_ENDSCROLL* = 8
  SW_HIDE* = 0
  SW_SHOWNORMAL* = 1
  SW_MAXIMIZE* = 3
  SW_MINIMIZE* = 6
  SW_RESTORE* = 9
  VK_LBUTTON* = 0x01
  VK_RBUTTON* = 0x02
  VK_CANCEL* = 0x03
  VK_MBUTTON* = 0x04
  VK_XBUTTON1* = 0x05
  VK_XBUTTON2* = 0x06
  VK_BACK* = 0x08
  VK_TAB* = 0x09
  VK_CLEAR* = 0x0C
  VK_RETURN* = 0x0D
  VK_SHIFT* = 0x10
  VK_CONTROL* = 0x11
  VK_MENU* = 0x12
  VK_PAUSE* = 0x13
  VK_CAPITAL* = 0x14
  VK_KANA* = 0x15
  VK_HANGEUL* = 0x15
  VK_HANGUL* = 0x15
  VK_JUNJA* = 0x17
  VK_FINAL* = 0x18
  VK_HANJA* = 0x19
  VK_KANJI* = 0x19
  VK_ESCAPE* = 0x1B
  VK_CONVERT* = 0x1C
  VK_NONCONVERT* = 0x1D
  VK_ACCEPT* = 0x1E
  VK_MODECHANGE* = 0x1F
  VK_SPACE* = 0x20
  VK_PRIOR* = 0x21
  VK_NEXT* = 0x22
  VK_END* = 0x23
  VK_HOME* = 0x24
  VK_LEFT* = 0x25
  VK_UP* = 0x26
  VK_RIGHT* = 0x27
  VK_DOWN* = 0x28
  VK_SELECT* = 0x29
  VK_PRINT* = 0x2A
  VK_EXECUTE* = 0x2B
  VK_SNAPSHOT* = 0x2C
  VK_INSERT* = 0x2D
  VK_DELETE* = 0x2E
  VK_HELP* = 0x2F
  VK_LWIN* = 0x5B
  VK_RWIN* = 0x5C
  VK_APPS* = 0x5D
  VK_SLEEP* = 0x5F
  VK_NUMPAD0* = 0x60
  VK_NUMPAD1* = 0x61
  VK_NUMPAD2* = 0x62
  VK_NUMPAD3* = 0x63
  VK_NUMPAD4* = 0x64
  VK_NUMPAD5* = 0x65
  VK_NUMPAD6* = 0x66
  VK_NUMPAD7* = 0x67
  VK_NUMPAD8* = 0x68
  VK_NUMPAD9* = 0x69
  VK_MULTIPLY* = 0x6A
  VK_ADD* = 0x6B
  VK_SEPARATOR* = 0x6C
  VK_SUBTRACT* = 0x6D
  VK_DECIMAL* = 0x6E
  VK_DIVIDE* = 0x6F
  VK_F1* = 0x70
  VK_F2* = 0x71
  VK_F3* = 0x72
  VK_F4* = 0x73
  VK_F5* = 0x74
  VK_F6* = 0x75
  VK_F7* = 0x76
  VK_F8* = 0x77
  VK_F9* = 0x78
  VK_F10* = 0x79
  VK_F11* = 0x7A
  VK_F12* = 0x7B
  VK_F13* = 0x7C
  VK_F14* = 0x7D
  VK_F15* = 0x7E
  VK_F16* = 0x7F
  VK_F17* = 0x80
  VK_F18* = 0x81
  VK_F19* = 0x82
  VK_F20* = 0x83
  VK_F21* = 0x84
  VK_F22* = 0x85
  VK_F23* = 0x86
  VK_F24* = 0x87
  VK_NUMLOCK* = 0x90
  VK_SCROLL* = 0x91
  VK_OEM_NEC_EQUAL* = 0x92
  VK_OEM_FJ_JISHO* = 0x92
  VK_OEM_FJ_MASSHOU* = 0x93
  VK_OEM_FJ_TOUROKU* = 0x94
  VK_OEM_FJ_LOYA* = 0x95
  VK_OEM_FJ_ROYA* = 0x96
  VK_LSHIFT* = 0xA0
  VK_RSHIFT* = 0xA1
  VK_LCONTROL* = 0xA2
  VK_RCONTROL* = 0xA3
  VK_LMENU* = 0xA4
  VK_RMENU* = 0xA5
  VK_BROWSER_BACK* = 0xA6
  VK_BROWSER_FORWARD* = 0xA7
  VK_BROWSER_REFRESH* = 0xA8
  VK_BROWSER_STOP* = 0xA9
  VK_BROWSER_SEARCH* = 0xAA
  VK_BROWSER_FAVORITES* = 0xAB
  VK_BROWSER_HOME* = 0xAC
  VK_VOLUME_MUTE* = 0xAD
  VK_VOLUME_DOWN* = 0xAE
  VK_VOLUME_UP* = 0xAF
  VK_MEDIA_NEXT_TRACK* = 0xB0
  VK_MEDIA_PREV_TRACK* = 0xB1
  VK_MEDIA_STOP* = 0xB2
  VK_MEDIA_PLAY_PAUSE* = 0xB3
  VK_LAUNCH_MAIL* = 0xB4
  VK_LAUNCH_MEDIA_SELECT* = 0xB5
  VK_LAUNCH_APP1* = 0xB6
  VK_LAUNCH_APP2* = 0xB7
  VK_OEM_1* = 0xBA
  VK_OEM_PLUS* = 0xBB
  VK_OEM_COMMA* = 0xBC
  VK_OEM_MINUS* = 0xBD
  VK_OEM_PERIOD* = 0xBE
  VK_OEM_2* = 0xBF
  VK_OEM_3* = 0xC0
  VK_OEM_4* = 0xDB
  VK_OEM_5* = 0xDC
  VK_OEM_6* = 0xDD
  VK_OEM_7* = 0xDE
  VK_OEM_8* = 0xDF
  VK_OEM_AX* = 0xE1
  VK_OEM_102* = 0xE2
  VK_ICO_HELP* = 0xE3
  VK_ICO_00* = 0xE4
  VK_PROCESSKEY* = 0xE5
  VK_ICO_CLEAR* = 0xE6
  VK_PACKET* = 0xE7
  VK_OEM_RESET* = 0xE9
  VK_OEM_JUMP* = 0xEA
  VK_OEM_PA1* = 0xEB
  VK_OEM_PA2* = 0xEC
  VK_OEM_PA3* = 0xED
  VK_OEM_WSCTRL* = 0xEE
  VK_OEM_CUSEL* = 0xEF
  VK_OEM_ATTN* = 0xF0
  VK_OEM_FINISH* = 0xF1
  VK_OEM_COPY* = 0xF2
  VK_OEM_AUTO* = 0xF3
  VK_OEM_ENLW* = 0xF4
  VK_OEM_BACKTAB* = 0xF5
  VK_ATTN* = 0xF6
  VK_CRSEL* = 0xF7
  VK_EXSEL* = 0xF8
  VK_EREOF* = 0xF9
  VK_PLAY* = 0xFA
  VK_ZOOM* = 0xFB
  VK_NONAME* = 0xFC
  VK_PA1* = 0xFD
  VK_OEM_CLEAR* = 0xFE
  WH_CBT* = 5
  HCBT_ACTIVATE* = 5
  GWL_STYLE* = -16
  GWL_EXSTYLE* = -20
  GWLP_ID* = -12
  GCL_HBRBACKGROUND* = -10
  WM_NULL* = 0x0000
  WM_CREATE* = 0x0001
  WM_DESTROY* = 0x0002
  WM_MOVE* = 0x0003
  WM_SIZE* = 0x0005
  WM_ACTIVATE* = 0x0006
  WM_SETFOCUS* = 0x0007
  WM_KILLFOCUS* = 0x0008
  WM_SETREDRAW* = 0x000B
  WM_SETTEXT* = 0x000C
  WM_PAINT* = 0x000F
  WM_CLOSE* = 0x0010
  WM_QUIT* = 0x0012
  WM_SHOWWINDOW* = 0x0018
  WM_SETCURSOR* = 0x0020
  WM_GETMINMAXINFO* = 0x0024
  WM_DRAWITEM* = 0x002B
  WM_MEASUREITEM* = 0x002C
  WM_SETFONT* = 0x0030
  WM_GETFONT* = 0x0031
  WM_WINDOWPOSCHANGED* = 0x0047
  WM_NOTIFY* = 0x004E
  WM_CONTEXTMENU* = 0x007B
  WM_SETICON* = 0x0080
  WM_NCDESTROY* = 0x0082
  WM_NCPAINT* = 0x0085
  WM_NCMOUSEMOVE* = 0x00A0
  WM_NCLBUTTONDOWN* = 0x00A1
  WM_NCLBUTTONUP* = 0x00A2
  WM_NCLBUTTONDBLCLK* = 0x00A3
  WM_NCRBUTTONDOWN* = 0x00A4
  WM_NCRBUTTONUP* = 0x00A5
  WM_NCRBUTTONDBLCLK* = 0x00A6
  WM_NCMBUTTONDOWN* = 0x00A7
  WM_NCMBUTTONUP* = 0x00A8
  WM_NCMBUTTONDBLCLK* = 0x00A9
  WM_NCXBUTTONDBLCLK* = 0x00AD
  WM_KEYFIRST* = 0x0100
  WM_KEYDOWN* = 0x0100
  WM_KEYUP* = 0x0101
  WM_CHAR* = 0x0102
  WM_SYSKEYDOWN* = 0x0104
  WM_SYSKEYUP* = 0x0105
  WM_SYSCHAR* = 0x0106
  WM_KEYLAST* = 0x0109
  WM_INITDIALOG* = 0x0110
  WM_COMMAND* = 0x0111
  WM_TIMER* = 0x0113
  WM_HSCROLL* = 0x0114
  WM_VSCROLL* = 0x0115
  WM_MENUSELECT* = 0x011F
  WM_MENUCOMMAND* = 0x0126
  WM_UPDATEUISTATE* = 0x0128
  UIS_CLEAR* = 2
  UISF_HIDEFOCUS* = 0x1
  WM_CTLCOLOREDIT* = 0x0133
  WM_CTLCOLORLISTBOX* = 0x0134
  WM_CTLCOLORBTN* = 0x0135
  WM_CTLCOLORSTATIC* = 0x0138
  WM_MOUSEFIRST* = 0x0200
  WM_MOUSEMOVE* = 0x0200
  WM_LBUTTONDOWN* = 0x0201
  WM_LBUTTONUP* = 0x0202
  WM_LBUTTONDBLCLK* = 0x0203
  WM_RBUTTONDOWN* = 0x0204
  WM_RBUTTONUP* = 0x0205
  WM_RBUTTONDBLCLK* = 0x0206
  WM_MBUTTONDOWN* = 0x0207
  WM_MBUTTONUP* = 0x0208
  WM_MBUTTONDBLCLK* = 0x0209
  WM_MOUSEWHEEL* = 0x020A
  WM_MOUSEHWHEEL* = 0x020e
  WM_MOUSELAST* = 0x020e
  WM_MOVING* = 0x0216
  WM_MOUSEHOVER* = 0x02A1
  WM_MOUSELEAVE* = 0x02A3
  WM_CUT* = 0x0300
  WM_COPY* = 0x0301
  WM_HOTKEY* = 0x0312
  WM_APP* = 0x8000
  WM_USER* = 0x0400
  HTCLIENT* = 1
  ICON_SMALL* = 0
  SIZE_RESTORED* = 0
  SIZE_MINIMIZED* = 1
  SIZE_MAXIMIZED* = 2
  SIZE_MAXSHOW* = 3
  SIZE_MAXHIDE* = 4
  TME_LEAVE* = 0x00000002
  HOVER_DEFAULT* = 0xFFFFFFFF'i32
  WS_POPUP* = 0x80000000'i32
  WS_CHILD* = 0x40000000
  WS_MINIMIZE* = 0x20000000
  WS_VISIBLE* = 0x10000000
  WS_CLIPSIBLINGS* = 0x04000000
  WS_CLIPCHILDREN* = 0x02000000
  WS_MAXIMIZE* = 0x01000000
  WS_CAPTION* = 0x00C00000
  WS_BORDER* = 0x00800000
  WS_VSCROLL* = 0x00200000
  WS_HSCROLL* = 0x00100000
  WS_SYSMENU* = 0x00080000
  WS_THICKFRAME* = 0x00040000
  WS_GROUP* = 0x00020000
  WS_TABSTOP* = 0x00010000
  WS_MINIMIZEBOX* = 0x00020000
  WS_MAXIMIZEBOX* = 0x00010000
  WS_ICONIC* = WS_MINIMIZE
  WS_SIZEBOX* = WS_THICKFRAME
  WS_POPUPWINDOW* = WS_POPUP or WS_BORDER or WS_SYSMENU
  WS_EX_DLGMODALFRAME* = 0x00000001
  WS_EX_TOPMOST* = 0x00000008
  WS_EX_TRANSPARENT* = 0x00000020
  WS_EX_TOOLWINDOW* = 0x00000080
  WS_EX_WINDOWEDGE* = 0x00000100
  WS_EX_CLIENTEDGE* = 0x00000200
  WS_EX_STATICEDGE* = 0x00020000
  WS_EX_LAYERED* = 0x00080000
  WS_EX_COMPOSITED* = 0x02000000
  CS_VREDRAW* = 0x0001
  CS_HREDRAW* = 0x0002
  CS_DBLCLKS* = 0x0008
  DFC_MENU* = 2
  DFCS_MENUCHECK* = 0x0001
  CF_TEXT* = 1
  CF_BITMAP* = 2
  CF_UNICODETEXT* = 13
  CF_HDROP* = 15
  FVIRTKEY* = TRUE
  FSHIFT* = 0x04
  FCONTROL* = 0x08
  FALT* = 0x10
  ODT_MENU* = 1
  MOD_ALT* = 0x0001
  MOD_CONTROL* = 0x0002
  MOD_SHIFT* = 0x0004
  MOD_WIN* = 0x0008
  CW_USEDEFAULT* = int32 0x80000000'i32
  LWA_ALPHA* = 0x00000002
  SWP_NOSIZE* = 0x0001
  SWP_NOMOVE* = 0x0002
  SWP_NOZORDER* = 0x0004
  SWP_NOACTIVATE* = 0x0010
  SWP_NOOWNERZORDER* = 0x0200
  SWP_NOREPOSITION* = SWP_NOOWNERZORDER
  HWND_TOPMOST* = HWND(-1)
  HWND_NOTOPMOST* = HWND(-2)
  SM_CXSCREEN* = 0
  SM_CYSCREEN* = 1
  SM_CXVSCROLL* = 2
  SM_CYHSCROLL* = 3
  SM_CXICON* = 11
  SM_CYICON* = 12
  SM_CXCURSOR* = 13
  SM_CYCURSOR* = 14
  SM_CYVSCROLL* = 20
  SM_CXHSCROLL* = 21
  SM_CXSMICON* = 49
  SM_CYSMICON* = 50
  SM_CXMENUSIZE* = 54
  SM_CYMENUSIZE* = 55
  SM_CXDRAG* = 68
  SM_CYDRAG* = 69
  MNS_NOTIFYBYPOS* = 0x08000000
  MNS_CHECKORBMP* = 0x04000000
  MIM_MENUDATA* = 0x00000008
  MIM_STYLE* = 0x00000010
  MIIM_STATE* = 0x00000001
  MIIM_ID* = 0x00000002
  MIIM_SUBMENU* = 0x00000004
  MIIM_DATA* = 0x00000020
  MIIM_STRING* = 0x00000040
  MIIM_BITMAP* = 0x00000080
  MIIM_FTYPE* = 0x00000100
  HBMMENU_CALLBACK* = HBITMAP(-1)
  TPM_RIGHTBUTTON* = 0x0002
  TPM_RECURSE* = 0x0001
  RDW_INVALIDATE* = 0x0001
  RDW_ERASE* = 0x0004
  RDW_ALLCHILDREN* = 0x0080
  RDW_UPDATENOW* = 0x0100
  ESB_ENABLE_BOTH* = 0x0000
  ESB_DISABLE_BOTH* = 0x0003
  MB_OK* = 0x00000000
  MB_OKCANCEL* = 0x00000001
  MB_ABORTRETRYIGNORE* = 0x00000002
  MB_YESNOCANCEL* = 0x00000003
  MB_YESNO* = 0x00000004
  MB_RETRYCANCEL* = 0x00000005
  MB_CANCELTRYCONTINUE* = 0x00000006
  MB_ICONHAND* = 0x00000010
  MB_ICONQUESTION* = 0x00000020
  MB_ICONEXCLAMATION* = 0x00000030
  MB_ICONASTERISK* = 0x00000040
  MB_ICONWARNING* = MB_ICONEXCLAMATION
  MB_ICONERROR* = MB_ICONHAND
  MB_ICONINFORMATION* = MB_ICONASTERISK
  MB_ICONSTOP* = MB_ICONHAND
  MB_DEFBUTTON1* = 0x00000000
  MB_DEFBUTTON2* = 0x00000100
  MB_DEFBUTTON3* = 0x00000200
  MB_DEFBUTTON4* = 0x00000300
  MB_APPLMODAL* = 0x00000000
  MB_TASKMODAL* = 0x00002000
  MB_TOPMOST* = 0x00040000
  COLOR_ACTIVEBORDER* = 10
  COLOR_APPWORKSPACE* = 12
  COLOR_BTNFACE* = 15
  GW_OWNER* = 4
  MF_BYCOMMAND* = 0x00000000
  MF_BYPOSITION* = 0x00000400
  MF_SEPARATOR* = 0x00000800
  MF_ENABLED* = 0x00000000
  MF_GRAYED* = 0x00000001
  MF_CHECKED* = 0x00000008
  MF_STRING* = 0x00000000
  MF_POPUP* = 0x00000010
  MFT_STRING* = MF_STRING
  MFT_SEPARATOR* = MF_SEPARATOR
  MFS_GRAYED* = 0x00000003
  MFS_DISABLED* = MFS_GRAYED
  MFS_CHECKED* = MF_CHECKED
  SC_CLOSE* = 0xF060
  IDC_ARROW* = MAKEINTRESOURCE(32512)
  IMAGE_BITMAP* = 0
  LR_COPYDELETEORG* = 0x0008
  LR_DEFAULTSIZE* = 0x0040
  LR_CREATEDIBSECTION* = 0x2000
  DI_NORMAL* = 0x0003
  IDOK* = 1
  IDCANCEL* = 2
  IDABORT* = 3
  IDRETRY* = 4
  IDIGNORE* = 5
  IDYES* = 6
  IDNO* = 7
  IDTRYAGAIN* = 10
  IDCONTINUE* = 11
  ES_LEFT* = 0x0000
  ES_CENTER* = 0x0001
  ES_RIGHT* = 0x0002
  ES_MULTILINE* = 0x0004
  ES_PASSWORD* = 0x0020
  ES_AUTOHSCROLL* = 0x0080
  ES_NOHIDESEL* = 0x0100
  ES_READONLY* = 0x0800
  EN_CHANGE* = 0x0300
  EN_UPDATE* = 0x0400
  EN_MAXTEXT* = 0x0501
  EC_LEFTMARGIN* = 0x0001
  EC_RIGHTMARGIN* = 0x0002
  EM_GETSEL* = 0x00B0
  EM_SETSEL* = 0x00B1
  EM_LINESCROLL* = 0x00B6
  EM_GETMODIFY* = 0x00B8
  EM_SETMODIFY* = 0x00B9
  EM_GETLINECOUNT* = 0x00BA
  EM_LINEINDEX* = 0x00BB
  EM_LINELENGTH* = 0x00C1
  EM_REPLACESEL* = 0x00C2
  EM_GETLINE* = 0x00C4
  EM_LIMITTEXT* = 0x00C5
  EM_CANUNDO* = 0x00C6
  EM_UNDO* = 0x00C7
  EM_LINEFROMCHAR* = 0x00C9
  EM_GETFIRSTVISIBLELINE* = 0x00CE
  EM_SETREADONLY* = 0x00CF
  EM_SETMARGINS* = 0x00D3
  EM_GETMARGINS* = 0x00D4
  BS_PUSHBUTTON* = 0x00000000
  BS_DEFPUSHBUTTON* = 0x00000001
  BS_AUTOCHECKBOX* = 0x00000003
  BS_3STATE* = 0x00000005
  BS_AUTO3STATE* = 0x00000006
  BS_GROUPBOX* = 0x00000007
  BS_AUTORADIOBUTTON* = 0x00000009
  BS_LEFTTEXT* = 0x00000020
  BS_LEFT* = 0x00000100
  BS_RIGHT* = 0x00000200
  BS_TOP* = 0x00000400
  BS_BOTTOM* = 0x00000800
  BS_FLAT* = 0x00008000
  BN_CLICKED* = 0
  BM_GETCHECK* = 0x00F0
  BM_SETCHECK* = 0x00F1
  BM_CLICK* = 0x00F5
  BST_UNCHECKED* = 0x0000
  BST_CHECKED* = 0x0001
  BST_INDETERMINATE* = 0x0002
  SS_LEFT* = 0x00000000
  SS_CENTER* = 0x00000001
  SS_RIGHT* = 0x00000002
  SS_LEFTNOWORDWRAP* = 0x0000000C
  SS_BITMAP* = 0x0000000E
  SS_REALSIZECONTROL* = 0x00000040
  SS_NOTIFY* = 0x00000100
  SS_CENTERIMAGE* = 0x00000200
  SS_SUNKEN* = 0x00001000
  STM_SETIMAGE* = 0x0172
  STN_CLICKED* = 0
  STN_DBLCLK* = 1
  DS_MODALFRAME* = 0x80
  LB_ERR* = -1
  LBN_SELCHANGE* = 1
  LBN_DBLCLK* = 2
  LB_ADDSTRING* = 0x0180
  LB_INSERTSTRING* = 0x0181
  LB_DELETESTRING* = 0x0182
  LB_RESETCONTENT* = 0x0184
  LB_SETSEL* = 0x0185
  LB_SETCURSEL* = 0x0186
  LB_GETSEL* = 0x0187
  LB_GETCURSEL* = 0x0188
  LB_GETTEXT* = 0x0189
  LB_GETTEXTLEN* = 0x018A
  LB_GETCOUNT* = 0x018B
  LB_GETTOPINDEX* = 0x018E
  LB_GETSELITEMS* = 0x0191
  LB_SETTOPINDEX* = 0x0197
  LB_GETITEMRECT* = 0x0198
  LB_GETITEMHEIGHT* = 0x01A1
  LB_ITEMFROMPOINT* = 0x01A9
  LBS_NOTIFY* = 0x0001
  LBS_SORT* = 0x0002
  LBS_MULTIPLESEL* = 0x0008
  LBS_NOINTEGRALHEIGHT* = 0x0100
  LBS_EXTENDEDSEL* = 0x0800
  LBS_DISABLENOSCROLL* = 0x1000
  LBS_NOSEL* = 0x4000
  CB_ERR* = -1
  CBN_DBLCLK* = 2
  CBN_SETFOCUS* = 3
  CBN_KILLFOCUS* = 4
  CBN_DROPDOWN* = 7
  CBN_CLOSEUP* = 8
  CBN_SELENDOK* = 9
  CBS_SIMPLE* = 0x0001
  CBS_DROPDOWN* = 0x0002
  CBS_DROPDOWNLIST* = 0x0003
  CBS_AUTOHSCROLL* = 0x0040
  CBS_SORT* = 0x0100
  CBS_NOINTEGRALHEIGHT* = 0x0400
  CBS_DISABLENOSCROLL* = 0x0800
  CB_ADDSTRING* = 0x0143
  CB_DELETESTRING* = 0x0144
  CB_GETCOUNT* = 0x0146
  CB_GETCURSEL* = 0x0147
  CB_GETLBTEXT* = 0x0148
  CB_GETLBTEXTLEN* = 0x0149
  CB_INSERTSTRING* = 0x014A
  CB_RESETCONTENT* = 0x014B
  CB_SETCURSEL* = 0x014E
  CB_SHOWDROPDOWN* = 0x014F
  CB_GETITEMHEIGHT* = 0x0154
  SBS_HORZ* = 0x0000
  SBS_VERT* = 0x0001
  SIF_RANGE* = 0x0001
  SIF_PAGE* = 0x0002
  SIF_POS* = 0x0004
  SIF_TRACKPOS* = 0x0010
  SIF_ALL* = SIF_RANGE or SIF_PAGE or SIF_POS or SIF_TRACKPOS
  SPI_GETNONCLIENTMETRICS* = 0x0029
  OBJID_VSCROLL* = LONG 0xFFFFFFFB'i32
  OBJID_HSCROLL* = LONG 0xFFFFFFFA'i32
  RT_GROUP_CURSOR* = MAKEINTRESOURCE(1+DIFFERENCE)
  RT_GROUP_ICON* = MAKEINTRESOURCE(3+DIFFERENCE)
type
  TIMERPROC* = proc (P1: HWND, P2: UINT, P3: UINT_PTR, P4: DWORD): VOID {.stdcall.}
  WNDENUMPROC* = proc (P1: HWND, P2: LPARAM): WINBOOL {.stdcall.}
  HOOKPROC* = proc (code: int32, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}
proc TrackMouseEvent*(lpEventTrack: LPTRACKMOUSEEVENT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DrawFrameControl*(P1: HDC, P2: LPRECT, P3: UINT, P4: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc TranslateMessage*(lpMsg: ptr MSG): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc RegisterHotKey*(hWnd: HWND, id: int32, fsModifiers: UINT, vk: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc UnregisterHotKey*(hWnd: HWND, id: int32): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMessagePos*(): DWORD {.winapi, stdcall, dynlib: "user32", importc.}
proc PostQuitMessage*(nExitCode: int32): VOID {.winapi, stdcall, dynlib: "user32", importc.}
proc IsWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsMenu*(hMenu: HMENU): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ShowWindow*(hWnd: HWND, nCmdShow: int32): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetLayeredWindowAttributes*(hwnd: HWND, pcrKey: ptr COLORREF, pbAlpha: ptr BYTE, pdwFlags: ptr DWORD): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetLayeredWindowAttributes*(hwnd: HWND, crKey: COLORREF, bAlpha: BYTE, dwFlags: DWORD): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetWindowPos*(hWnd: HWND, hWndInsertAfter: HWND, X: int32, Y: int32, cx: int32, cy: int32, uFlags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsWindowVisible*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsIconic*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsZoomed*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetDlgItem*(hDlg: HWND, nIDDlgItem: int32): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetNextDlgGroupItem*(hDlg: HWND, hCtl: HWND, bPrevious: WINBOOL): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetNextDlgTabItem*(hDlg: HWND, hCtl: HWND, bPrevious: WINBOOL): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetDialogBaseUnits*(): LONG32 {.winapi, stdcall, dynlib: "user32", importc.}
proc SetFocus*(hWnd: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetFocus*(): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetKeyState*(nVirtKey: int32): SHORT {.winapi, stdcall, dynlib: "user32", importc.}
proc GetAsyncKeyState*(vKey: int32): SHORT {.winapi, stdcall, dynlib: "user32", importc.}
proc GetKeyboardState*(lpKeyState: PBYTE): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetCapture*(): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc SetCapture*(hWnd: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc ReleaseCapture*(): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetTimer*(hWnd: HWND, nIDEvent: UINT_PTR, uElapse: UINT, lpTimerFunc: TIMERPROC): UINT_PTR {.winapi, stdcall, dynlib: "user32", importc.}
proc KillTimer*(hWnd: HWND, uIDEvent: UINT_PTR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc EnableWindow*(hWnd: HWND, bEnable: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsWindowEnabled*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyAcceleratorTable*(hAccel: HACCEL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSystemMetrics*(nIndex: int32): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc SetMenu*(hWnd: HWND, hMenu: HMENU): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DrawMenuBar*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSystemMenu*(hWnd: HWND, bRevert: WINBOOL): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc CreateMenu*(): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc CreatePopupMenu*(): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyMenu*(hMenu: HMENU): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc EnableMenuItem*(hMenu: HMENU, uIDEnableItem: UINT, uEnable: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSubMenu*(hMenu: HMENU, nPos: int32): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMenuItemCount*(hMenu: HMENU): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc RemoveMenu*(hMenu: HMENU, uPosition: UINT, uFlags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DeleteMenu*(hMenu: HMENU, uPosition: UINT, uFlags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc TrackPopupMenu*(hMenu: HMENU, uFlags: UINT, x: int32, y: int32, nReserved: int32, hWnd: HWND, prcRect: ptr RECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMenuInfo*(P1: HMENU, P2: LPMENUINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetMenuInfo*(P1: HMENU, P2: LPCMENUINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc UpdateWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetForegroundWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetDC*(hWnd: HWND): HDC {.winapi, stdcall, dynlib: "user32", importc.}
proc GetWindowDC*(hWnd: HWND): HDC {.winapi, stdcall, dynlib: "user32", importc.}
proc ReleaseDC*(hWnd: HWND, hDC: HDC): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc BeginPaint*(hWnd: HWND, lpPaint: LPPAINTSTRUCT): HDC {.winapi, stdcall, dynlib: "user32", importc.}
proc EndPaint*(hWnd: HWND, lpPaint: ptr PAINTSTRUCT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetUpdateRect*(hWnd: HWND, lpRect: LPRECT, bErase: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc InvalidateRect*(hWnd: HWND, lpRect: ptr RECT, bErase: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc RedrawWindow*(hWnd: HWND, lprcUpdate: ptr RECT, hrgnUpdate: HRGN, flags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ShowScrollBar*(hWnd: HWND, wBar: int32, bShow: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc EnableScrollBar*(hWnd: HWND, wSBflags: UINT, wArrows: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetClientRect*(hWnd: HWND, lpRect: LPRECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetWindowRect*(hWnd: HWND, lpRect: LPRECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetCursor*(hCursor: HCURSOR): HCURSOR {.winapi, stdcall, dynlib: "user32", importc.}
proc GetCursorPos*(lpPoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ClientToScreen*(hWnd: HWND, lpPoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ScreenToClient*(hWnd: HWND, lpPoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc WindowFromPoint*(Point: POINT): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSysColor*(nIndex: int32): DWORD {.winapi, stdcall, dynlib: "user32", importc.}
proc FillRect*(hDC: HDC, lprc: ptr RECT, hbr: HBRUSH): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc IntersectRect*(lprcDst: LPRECT, lprcSrc1: ptr RECT, lprcSrc2: ptr RECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetDesktopWindow*(): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetParent*(hWnd: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc SetParent*(hWndChild: HWND, hWndNewParent: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc EnumChildWindows*(hWndParent: HWND, lpEnumFunc: WNDENUMPROC, lParam: LPARAM): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetWindow*(hWnd: HWND, uCmd: UINT): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc UnhookWindowsHookEx*(hhk: HHOOK): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc CallNextHookEx*(hhk: HHOOK, nCode: int32, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc.}
proc CheckMenuRadioItem*(hmenu: HMENU, first: UINT, last: UINT, check: UINT, flags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyCursor*(hCursor: HCURSOR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyIcon*(hIcon: HICON): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc LookupIconIdFromDirectoryEx*(presbits: PBYTE, fIcon: WINBOOL, cxDesired: int32, cyDesired: int32, Flags: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc CreateIconFromResourceEx*(presbits: PBYTE, dwResSize: DWORD, fIcon: WINBOOL, dwVer: DWORD, cxDesired: int32, cyDesired: int32, Flags: UINT): HICON {.winapi, stdcall, dynlib: "user32", importc.}
proc CopyImage*(h: HANDLE, `type`: UINT, cx: int32, cy: int32, flags: UINT): HANDLE {.winapi, stdcall, dynlib: "user32", importc.}
proc DrawIconEx*(hdc: HDC, xLeft: int32, yTop: int32, hIcon: HICON, cxWidth: int32, cyWidth: int32, istepIfAniCur: UINT, hbrFlickerFreeDraw: HBRUSH, diFlags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc CreateIconIndirect*(piconinfo: PICONINFO): HICON {.winapi, stdcall, dynlib: "user32", importc.}
proc GetIconInfo*(hIcon: HICON, piconinfo: PICONINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetScrollInfo*(hwnd: HWND, nBar: int32, lpsi: LPCSCROLLINFO, redraw: WINBOOL): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc GetScrollInfo*(hwnd: HWND, nBar: int32, lpsi: LPSCROLLINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetScrollBarInfo*(hwnd: HWND, idObject: LONG, psbi: PSCROLLBARINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetComboBoxInfo*(hwndCombo: HWND, pcbi: PCOMBOBOXINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
template MAKEWPARAM*(l: untyped, h: untyped): WPARAM = WPARAM MAKELONG(l, h)
template MAKELPARAM*(l: untyped, h: untyped): LPARAM = LPARAM MAKELONG(l, h)
template GET_WHEEL_DELTA_WPARAM*(wParam: untyped): SHORT = cast[SHORT](HIWORD(wParam))
when winimAnsi:
  proc CreateWindowEx*(dwExStyle: DWORD, lpClassName: LPCSTR, lpWindowName: LPCSTR, dwStyle: DWORD, X: int32, Y: int32, nWidth: int32, nHeight: int32, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND {.winapi, stdcall, dynlib: "user32", importc: "CreateWindowExA".}
when winimUnicode:
  proc CreateWindowEx*(dwExStyle: DWORD, lpClassName: LPCWSTR, lpWindowName: LPCWSTR, dwStyle: DWORD, X: int32, Y: int32, nWidth: int32, nHeight: int32, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND {.winapi, stdcall, dynlib: "user32", importc: "CreateWindowExW".}
  type
    WNDCLASSEX* = WNDCLASSEXW
    MENUITEMINFO* = MENUITEMINFOW
    NONCLIENTMETRICS* = NONCLIENTMETRICSW
  proc RegisterWindowMessage*(lpString: LPCWSTR): UINT {.winapi, stdcall, dynlib: "user32", importc: "RegisterWindowMessageW".}
  proc GetMessage*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMessageW".}
  proc DispatchMessage*(lpMsg: ptr MSG): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DispatchMessageW".}
  proc SendMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "SendMessageW".}
  proc PostMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "PostMessageW".}
  proc DefWindowProc*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DefWindowProcW".}
  proc RegisterClassEx*(P1: ptr WNDCLASSEXW): ATOM {.winapi, stdcall, dynlib: "user32", importc: "RegisterClassExW".}
  proc GetClassInfoEx*(hInstance: HINSTANCE, lpszClass: LPCWSTR, lpwcx: LPWNDCLASSEXW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetClassInfoExW".}
  proc CreateAcceleratorTable*(paccel: LPACCEL, cAccel: int32): HACCEL {.winapi, stdcall, dynlib: "user32", importc: "CreateAcceleratorTableW".}
  proc TranslateAccelerator*(hWnd: HWND, hAccTable: HACCEL, lpMsg: LPMSG): int32 {.winapi, stdcall, dynlib: "user32", importc: "TranslateAcceleratorW".}
  proc InsertMenuItem*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmi: LPCMENUITEMINFOW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "InsertMenuItemW".}
  proc GetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmii: LPMENUITEMINFOW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMenuItemInfoW".}
  proc SetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPositon: WINBOOL, lpmii: LPCMENUITEMINFOW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetMenuItemInfoW".}
  proc SetWindowText*(hWnd: HWND, lpString: LPCWSTR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetWindowTextW".}
  proc GetWindowText*(hWnd: HWND, lpString: LPWSTR, nMaxCount: int32): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextW".}
  proc GetWindowTextLength*(hWnd: HWND): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextLengthW".}
  proc MessageBox*(hWnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc: "MessageBoxW".}
  proc SetWindowsHookEx*(idHook: int32, lpfn: HOOKPROC, hmod: HINSTANCE, dwThreadId: DWORD): HHOOK {.winapi, stdcall, dynlib: "user32", importc: "SetWindowsHookExW".}
  proc LoadCursor*(hInstance: HINSTANCE, lpCursorName: LPCWSTR): HCURSOR {.winapi, stdcall, dynlib: "user32", importc: "LoadCursorW".}
  proc IsDialogMessage*(hDlg: HWND, lpMsg: LPMSG): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "IsDialogMessageW".}
  proc SystemParametersInfo*(uiAction: UINT, uiParam: UINT, pvParam: PVOID, fWinIni: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SystemParametersInfoW".}
when winimAnsi:
  type
    WNDCLASSEX* = WNDCLASSEXA
    MENUITEMINFO* = MENUITEMINFOA
    NONCLIENTMETRICS* = NONCLIENTMETRICSA
  proc RegisterWindowMessage*(lpString: LPCSTR): UINT {.winapi, stdcall, dynlib: "user32", importc: "RegisterWindowMessageA".}
  proc GetMessage*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMessageA".}
  proc DispatchMessage*(lpMsg: ptr MSG): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DispatchMessageA".}
  proc SendMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "SendMessageA".}
  proc PostMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "PostMessageA".}
  proc DefWindowProc*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DefWindowProcA".}
  proc RegisterClassEx*(P1: ptr WNDCLASSEXA): ATOM {.winapi, stdcall, dynlib: "user32", importc: "RegisterClassExA".}
  proc GetClassInfoEx*(hInstance: HINSTANCE, lpszClass: LPCSTR, lpwcx: LPWNDCLASSEXA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetClassInfoExA".}
  proc CreateAcceleratorTable*(paccel: LPACCEL, cAccel: int32): HACCEL {.winapi, stdcall, dynlib: "user32", importc: "CreateAcceleratorTableA".}
  proc TranslateAccelerator*(hWnd: HWND, hAccTable: HACCEL, lpMsg: LPMSG): int32 {.winapi, stdcall, dynlib: "user32", importc: "TranslateAcceleratorA".}
  proc InsertMenuItem*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmi: LPCMENUITEMINFOA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "InsertMenuItemA".}
  proc GetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmii: LPMENUITEMINFOA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMenuItemInfoA".}
  proc SetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPositon: WINBOOL, lpmii: LPCMENUITEMINFOA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetMenuItemInfoA".}
  proc SetWindowText*(hWnd: HWND, lpString: LPCSTR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetWindowTextA".}
  proc GetWindowText*(hWnd: HWND, lpString: LPSTR, nMaxCount: int32): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextA".}
  proc GetWindowTextLength*(hWnd: HWND): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextLengthA".}
  proc MessageBox*(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc: "MessageBoxA".}
  proc SetWindowsHookEx*(idHook: int32, lpfn: HOOKPROC, hmod: HINSTANCE, dwThreadId: DWORD): HHOOK {.winapi, stdcall, dynlib: "user32", importc: "SetWindowsHookExA".}
  proc LoadCursor*(hInstance: HINSTANCE, lpCursorName: LPCSTR): HCURSOR {.winapi, stdcall, dynlib: "user32", importc: "LoadCursorA".}
  proc IsDialogMessage*(hDlg: HWND, lpMsg: LPMSG): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "IsDialogMessageA".}
  proc SystemParametersInfo*(uiAction: UINT, uiParam: UINT, pvParam: PVOID, fWinIni: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SystemParametersInfoA".}
when winimUnicode and winimCpu64:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongPtrW".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongPtrW".}
  proc SetClassLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): ULONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "SetClassLongPtrW".}
when winimAnsi and winimCpu64:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongPtrA".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongPtrA".}
  proc SetClassLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): ULONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "SetClassLongPtrA".}
when winimUnicode and winimCpu32:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongW".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG): LONG {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongW".}
  proc SetClassLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG): DWORD {.winapi, stdcall, dynlib: "user32", importc: "SetClassLongW".}
when winimAnsi and winimCpu32:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongA".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG): LONG {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongA".}
  proc SetClassLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG): DWORD {.winapi, stdcall, dynlib: "user32", importc: "SetClassLongA".}
const
  CP_ACP* = 0
type
  SOCKET* = int
const
  FD_SETSIZE* = 64
type
  fd_set* {.pure.} = object
    fd_count*: int32
    fd_array*: array[FD_SETSIZE, SOCKET]
  sockaddr* {.pure.} = object
    sa_family*: uint16
    sa_data*: array[14, char]
  timeval* {.pure.} = object
    tv_sec*: int32
    tv_usec*: int32
  PTIMEVAL* = ptr timeval
proc accept*(s: SOCKET, `addr`: ptr sockaddr, addrlen: ptr int32): SOCKET {.winapi, stdcall, dynlib: "ws2_32", importc.}
proc connect*(s: SOCKET, name: ptr sockaddr, namelen: int32): int32 {.winapi, stdcall, dynlib: "ws2_32", importc.}
proc select*(nfds: int32, readfds: ptr fd_set, writefds: ptr fd_set, exceptfds: ptr fd_set, timeout: PTIMEVAL): int32 {.winapi, stdcall, dynlib: "ws2_32", importc.}
proc send*(s: SOCKET, buf: cstring, len: int32, flags: int32): int32 {.winapi, stdcall, dynlib: "ws2_32", importc.}
type
  GETPROPERTYSTOREFLAGS* = int32
  CLIPFORMAT* = WORD
  HMETAFILEPICT* = HANDLE
  IUnknown* {.pure.} = object
    lpVtbl*: ptr IUnknownVtbl
  IUnknownVtbl* {.pure, inheritable.} = object
    QueryInterface*: proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.}
    AddRef*: proc(self: ptr IUnknown): ULONG {.stdcall.}
    Release*: proc(self: ptr IUnknown): ULONG {.stdcall.}
  LPUNKNOWN* = ptr IUnknown
  ISequentialStream* {.pure.} = object
    lpVtbl*: ptr ISequentialStreamVtbl
  ISequentialStreamVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Read*: proc(self: ptr ISequentialStream, pv: pointer, cb: ULONG, pcbRead: ptr ULONG): HRESULT {.stdcall.}
    Write*: proc(self: ptr ISequentialStream, pv: pointer, cb: ULONG, pcbWritten: ptr ULONG): HRESULT {.stdcall.}
  LPOLESTR* = ptr OLECHAR
  STATSTG* {.pure.} = object
    pwcsName*: LPOLESTR
    `type`*: DWORD
    cbSize*: ULARGE_INTEGER
    mtime*: FILETIME
    ctime*: FILETIME
    atime*: FILETIME
    grfMode*: DWORD
    grfLocksSupported*: DWORD
    clsid*: CLSID
    grfStateBits*: DWORD
    reserved*: DWORD
  IStream* {.pure.} = object
    lpVtbl*: ptr IStreamVtbl
  IStreamVtbl* {.pure, inheritable.} = object of ISequentialStreamVtbl
    Seek*: proc(self: ptr IStream, dlibMove: LARGE_INTEGER, dwOrigin: DWORD, plibNewPosition: ptr ULARGE_INTEGER): HRESULT {.stdcall.}
    SetSize*: proc(self: ptr IStream, libNewSize: ULARGE_INTEGER): HRESULT {.stdcall.}
    CopyTo*: proc(self: ptr IStream, pstm: ptr IStream, cb: ULARGE_INTEGER, pcbRead: ptr ULARGE_INTEGER, pcbWritten: ptr ULARGE_INTEGER): HRESULT {.stdcall.}
    Commit*: proc(self: ptr IStream, grfCommitFlags: DWORD): HRESULT {.stdcall.}
    Revert*: proc(self: ptr IStream): HRESULT {.stdcall.}
    LockRegion*: proc(self: ptr IStream, libOffset: ULARGE_INTEGER, cb: ULARGE_INTEGER, dwLockType: DWORD): HRESULT {.stdcall.}
    UnlockRegion*: proc(self: ptr IStream, libOffset: ULARGE_INTEGER, cb: ULARGE_INTEGER, dwLockType: DWORD): HRESULT {.stdcall.}
    Stat*: proc(self: ptr IStream, pstatstg: ptr STATSTG, grfStatFlag: DWORD): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IStream, ppstm: ptr ptr IStream): HRESULT {.stdcall.}
  IEnumString* {.pure.} = object
    lpVtbl*: ptr IEnumStringVtbl
  IEnumStringVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumString, celt: ULONG, rgelt: ptr LPOLESTR, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumString, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumString): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumString, ppenum: ptr ptr IEnumString): HRESULT {.stdcall.}
  BIND_OPTS* {.pure.} = object
    cbStruct*: DWORD
    grfFlags*: DWORD
    grfMode*: DWORD
    dwTickCountDeadline*: DWORD
  IPersist* {.pure.} = object
    lpVtbl*: ptr IPersistVtbl
  IPersistVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetClassID*: proc(self: ptr IPersist, pClassID: ptr CLSID): HRESULT {.stdcall.}
  IPersistStream* {.pure.} = object
    lpVtbl*: ptr IPersistStreamVtbl
  IPersistStreamVtbl* {.pure, inheritable.} = object of IPersistVtbl
    IsDirty*: proc(self: ptr IPersistStream): HRESULT {.stdcall.}
    Load*: proc(self: ptr IPersistStream, pStm: ptr IStream): HRESULT {.stdcall.}
    Save*: proc(self: ptr IPersistStream, pStm: ptr IStream, fClearDirty: WINBOOL): HRESULT {.stdcall.}
    GetSizeMax*: proc(self: ptr IPersistStream, pcbSize: ptr ULARGE_INTEGER): HRESULT {.stdcall.}
  IEnumMoniker* {.pure.} = object
    lpVtbl*: ptr IEnumMonikerVtbl
  IEnumMonikerVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumMoniker, celt: ULONG, rgelt: ptr ptr IMoniker, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumMoniker, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumMoniker): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumMoniker, ppenum: ptr ptr IEnumMoniker): HRESULT {.stdcall.}
  IMoniker* {.pure.} = object
    lpVtbl*: ptr IMonikerVtbl
  IMonikerVtbl* {.pure, inheritable.} = object of IPersistStreamVtbl
    BindToObject*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, riidResult: REFIID, ppvResult: ptr pointer): HRESULT {.stdcall.}
    BindToStorage*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, riid: REFIID, ppvObj: ptr pointer): HRESULT {.stdcall.}
    Reduce*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, dwReduceHowFar: DWORD, ppmkToLeft: ptr ptr IMoniker, ppmkReduced: ptr ptr IMoniker): HRESULT {.stdcall.}
    ComposeWith*: proc(self: ptr IMoniker, pmkRight: ptr IMoniker, fOnlyIfNotGeneric: WINBOOL, ppmkComposite: ptr ptr IMoniker): HRESULT {.stdcall.}
    Enum*: proc(self: ptr IMoniker, fForward: WINBOOL, ppenumMoniker: ptr ptr IEnumMoniker): HRESULT {.stdcall.}
    IsEqual*: proc(self: ptr IMoniker, pmkOtherMoniker: ptr IMoniker): HRESULT {.stdcall.}
    Hash*: proc(self: ptr IMoniker, pdwHash: ptr DWORD): HRESULT {.stdcall.}
    IsRunning*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pmkNewlyRunning: ptr IMoniker): HRESULT {.stdcall.}
    GetTimeOfLastChange*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pFileTime: ptr FILETIME): HRESULT {.stdcall.}
    Inverse*: proc(self: ptr IMoniker, ppmk: ptr ptr IMoniker): HRESULT {.stdcall.}
    CommonPrefixWith*: proc(self: ptr IMoniker, pmkOther: ptr IMoniker, ppmkPrefix: ptr ptr IMoniker): HRESULT {.stdcall.}
    RelativePathTo*: proc(self: ptr IMoniker, pmkOther: ptr IMoniker, ppmkRelPath: ptr ptr IMoniker): HRESULT {.stdcall.}
    GetDisplayName*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, ppszDisplayName: ptr LPOLESTR): HRESULT {.stdcall.}
    ParseDisplayName*: proc(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pszDisplayName: LPOLESTR, pchEaten: ptr ULONG, ppmkOut: ptr ptr IMoniker): HRESULT {.stdcall.}
    IsSystemMoniker*: proc(self: ptr IMoniker, pdwMksys: ptr DWORD): HRESULT {.stdcall.}
  IRunningObjectTable* {.pure.} = object
    lpVtbl*: ptr IRunningObjectTableVtbl
  IRunningObjectTableVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Register*: proc(self: ptr IRunningObjectTable, grfFlags: DWORD, punkObject: ptr IUnknown, pmkObjectName: ptr IMoniker, pdwRegister: ptr DWORD): HRESULT {.stdcall.}
    Revoke*: proc(self: ptr IRunningObjectTable, dwRegister: DWORD): HRESULT {.stdcall.}
    IsRunning*: proc(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker): HRESULT {.stdcall.}
    GetObject*: proc(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker, ppunkObject: ptr ptr IUnknown): HRESULT {.stdcall.}
    NoteChangeTime*: proc(self: ptr IRunningObjectTable, dwRegister: DWORD, pfiletime: ptr FILETIME): HRESULT {.stdcall.}
    GetTimeOfLastChange*: proc(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker, pfiletime: ptr FILETIME): HRESULT {.stdcall.}
    EnumRunning*: proc(self: ptr IRunningObjectTable, ppenumMoniker: ptr ptr IEnumMoniker): HRESULT {.stdcall.}
  IBindCtx* {.pure.} = object
    lpVtbl*: ptr IBindCtxVtbl
  IBindCtxVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    RegisterObjectBound*: proc(self: ptr IBindCtx, punk: ptr IUnknown): HRESULT {.stdcall.}
    RevokeObjectBound*: proc(self: ptr IBindCtx, punk: ptr IUnknown): HRESULT {.stdcall.}
    ReleaseBoundObjects*: proc(self: ptr IBindCtx): HRESULT {.stdcall.}
    SetBindOptions*: proc(self: ptr IBindCtx, pbindopts: ptr BIND_OPTS): HRESULT {.stdcall.}
    GetBindOptions*: proc(self: ptr IBindCtx, pbindopts: ptr BIND_OPTS): HRESULT {.stdcall.}
    GetRunningObjectTable*: proc(self: ptr IBindCtx, pprot: ptr ptr IRunningObjectTable): HRESULT {.stdcall.}
    RegisterObjectParam*: proc(self: ptr IBindCtx, pszKey: LPOLESTR, punk: ptr IUnknown): HRESULT {.stdcall.}
    GetObjectParam*: proc(self: ptr IBindCtx, pszKey: LPOLESTR, ppunk: ptr ptr IUnknown): HRESULT {.stdcall.}
    EnumObjectParam*: proc(self: ptr IBindCtx, ppenum: ptr ptr IEnumString): HRESULT {.stdcall.}
    RevokeObjectParam*: proc(self: ptr IBindCtx, pszKey: LPOLESTR): HRESULT {.stdcall.}
  IEnumSTATSTG* {.pure.} = object
    lpVtbl*: ptr IEnumSTATSTGVtbl
  IEnumSTATSTGVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumSTATSTG, celt: ULONG, rgelt: ptr STATSTG, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumSTATSTG, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumSTATSTG): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumSTATSTG, ppenum: ptr ptr IEnumSTATSTG): HRESULT {.stdcall.}
  SNB* = ptr LPOLESTR
  IStorage* {.pure.} = object
    lpVtbl*: ptr IStorageVtbl
  IStorageVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    CreateStream*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR, grfMode: DWORD, reserved1: DWORD, reserved2: DWORD, ppstm: ptr ptr IStream): HRESULT {.stdcall.}
    OpenStream*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR, reserved1: pointer, grfMode: DWORD, reserved2: DWORD, ppstm: ptr ptr IStream): HRESULT {.stdcall.}
    CreateStorage*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR, grfMode: DWORD, reserved1: DWORD, reserved2: DWORD, ppstg: ptr ptr IStorage): HRESULT {.stdcall.}
    OpenStorage*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR, pstgPriority: ptr IStorage, grfMode: DWORD, snbExclude: SNB, reserved: DWORD, ppstg: ptr ptr IStorage): HRESULT {.stdcall.}
    CopyTo*: proc(self: ptr IStorage, ciidExclude: DWORD, rgiidExclude: ptr IID, snbExclude: SNB, pstgDest: ptr IStorage): HRESULT {.stdcall.}
    MoveElementTo*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR, pstgDest: ptr IStorage, pwcsNewName: ptr OLECHAR, grfFlags: DWORD): HRESULT {.stdcall.}
    Commit*: proc(self: ptr IStorage, grfCommitFlags: DWORD): HRESULT {.stdcall.}
    Revert*: proc(self: ptr IStorage): HRESULT {.stdcall.}
    EnumElements*: proc(self: ptr IStorage, reserved1: DWORD, reserved2: pointer, reserved3: DWORD, ppenum: ptr ptr IEnumSTATSTG): HRESULT {.stdcall.}
    DestroyElement*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR): HRESULT {.stdcall.}
    RenameElement*: proc(self: ptr IStorage, pwcsOldName: ptr OLECHAR, pwcsNewName: ptr OLECHAR): HRESULT {.stdcall.}
    SetElementTimes*: proc(self: ptr IStorage, pwcsName: ptr OLECHAR, pctime: ptr FILETIME, patime: ptr FILETIME, pmtime: ptr FILETIME): HRESULT {.stdcall.}
    SetClass*: proc(self: ptr IStorage, clsid: REFCLSID): HRESULT {.stdcall.}
    SetStateBits*: proc(self: ptr IStorage, grfStateBits: DWORD, grfMask: DWORD): HRESULT {.stdcall.}
    Stat*: proc(self: ptr IStorage, pstatstg: ptr STATSTG, grfStatFlag: DWORD): HRESULT {.stdcall.}
  DVTARGETDEVICE* {.pure.} = object
    tdSize*: DWORD
    tdDriverNameOffset*: WORD
    tdDeviceNameOffset*: WORD
    tdPortNameOffset*: WORD
    tdExtDevmodeOffset*: WORD
    tdData*: array[1, BYTE]
  FORMATETC* {.pure.} = object
    cfFormat*: CLIPFORMAT
    ptd*: ptr DVTARGETDEVICE
    dwAspect*: DWORD
    lindex*: LONG
    tymed*: DWORD
  IEnumFORMATETC* {.pure.} = object
    lpVtbl*: ptr IEnumFORMATETCVtbl
  IEnumFORMATETCVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumFORMATETC, celt: ULONG, rgelt: ptr FORMATETC, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumFORMATETC, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumFORMATETC): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumFORMATETC, ppenum: ptr ptr IEnumFORMATETC): HRESULT {.stdcall.}
  uSTGMEDIUM_u* {.pure, union.} = object
    hBitmap*: HBITMAP
    hMetaFilePict*: HMETAFILEPICT
    hEnhMetaFile*: HENHMETAFILE
    hGlobal*: HGLOBAL
    lpszFileName*: LPOLESTR
    pstm*: ptr IStream
    pstg*: ptr IStorage
  uSTGMEDIUM* {.pure.} = object
    tymed*: DWORD
    u*: uSTGMEDIUM_u
    pUnkForRelease*: ptr IUnknown
  STGMEDIUM* = uSTGMEDIUM
  IAdviseSink* {.pure.} = object
    lpVtbl*: ptr IAdviseSinkVtbl
  IAdviseSinkVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    OnDataChange*: proc(self: ptr IAdviseSink, pFormatetc: ptr FORMATETC, pStgmed: ptr STGMEDIUM): void {.stdcall.}
    OnViewChange*: proc(self: ptr IAdviseSink, dwAspect: DWORD, lindex: LONG): void {.stdcall.}
    OnRename*: proc(self: ptr IAdviseSink, pmk: ptr IMoniker): void {.stdcall.}
    OnSave*: proc(self: ptr IAdviseSink): void {.stdcall.}
    OnClose*: proc(self: ptr IAdviseSink): void {.stdcall.}
  STATDATA* {.pure.} = object
    formatetc*: FORMATETC
    advf*: DWORD
    pAdvSink*: ptr IAdviseSink
    dwConnection*: DWORD
  IEnumSTATDATA* {.pure.} = object
    lpVtbl*: ptr IEnumSTATDATAVtbl
  IEnumSTATDATAVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumSTATDATA, celt: ULONG, rgelt: ptr STATDATA, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumSTATDATA, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumSTATDATA): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumSTATDATA, ppenum: ptr ptr IEnumSTATDATA): HRESULT {.stdcall.}
  LPSTGMEDIUM* = ptr STGMEDIUM
  IDataObject* {.pure.} = object
    lpVtbl*: ptr IDataObjectVtbl
  IDataObjectVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetData*: proc(self: ptr IDataObject, pformatetcIn: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.stdcall.}
    GetDataHere*: proc(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.stdcall.}
    QueryGetData*: proc(self: ptr IDataObject, pformatetc: ptr FORMATETC): HRESULT {.stdcall.}
    GetCanonicalFormatEtc*: proc(self: ptr IDataObject, pformatectIn: ptr FORMATETC, pformatetcOut: ptr FORMATETC): HRESULT {.stdcall.}
    SetData*: proc(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM, fRelease: WINBOOL): HRESULT {.stdcall.}
    EnumFormatEtc*: proc(self: ptr IDataObject, dwDirection: DWORD, ppenumFormatEtc: ptr ptr IEnumFORMATETC): HRESULT {.stdcall.}
    DAdvise*: proc(self: ptr IDataObject, pformatetc: ptr FORMATETC, advf: DWORD, pAdvSink: ptr IAdviseSink, pdwConnection: ptr DWORD): HRESULT {.stdcall.}
    DUnadvise*: proc(self: ptr IDataObject, dwConnection: DWORD): HRESULT {.stdcall.}
    EnumDAdvise*: proc(self: ptr IDataObject, ppenumAdvise: ptr ptr IEnumSTATDATA): HRESULT {.stdcall.}
  LPDATAOBJECT* = ptr IDataObject
  IDropSource* {.pure.} = object
    lpVtbl*: ptr IDropSourceVtbl
  IDropSourceVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    QueryContinueDrag*: proc(self: ptr IDropSource, fEscapePressed: WINBOOL, grfKeyState: DWORD): HRESULT {.stdcall.}
    GiveFeedback*: proc(self: ptr IDropSource, dwEffect: DWORD): HRESULT {.stdcall.}
  LPDROPSOURCE* = ptr IDropSource
  IDropTarget* {.pure.} = object
    lpVtbl*: ptr IDropTargetVtbl
  IDropTargetVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    DragEnter*: proc(self: ptr IDropTarget, pDataObj: ptr IDataObject, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.stdcall.}
    DragOver*: proc(self: ptr IDropTarget, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.stdcall.}
    DragLeave*: proc(self: ptr IDropTarget): HRESULT {.stdcall.}
    Drop*: proc(self: ptr IDropTarget, pDataObj: ptr IDataObject, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.stdcall.}
  LPDROPTARGET* = ptr IDropTarget
  SHITEMID* {.pure.} = object
    cb*: USHORT
    abID*: array[1, BYTE]
  ITEMIDLIST* {.pure.} = object
    mkid*: SHITEMID
  ITEMIDLIST_RELATIVE* = ITEMIDLIST
  ITEMID_CHILD* = ITEMIDLIST
  ITEMIDLIST_ABSOLUTE* = ITEMIDLIST
  PIDLIST_ABSOLUTE* = ptr ITEMIDLIST_ABSOLUTE
  PCIDLIST_ABSOLUTE* = ptr ITEMIDLIST_ABSOLUTE
  PIDLIST_RELATIVE* = ptr ITEMIDLIST_RELATIVE
  PCUITEMID_CHILD* = ptr ITEMID_CHILD
  PCUITEMID_CHILD_ARRAY* = ptr PCUITEMID_CHILD
  PROPERTYKEY* {.pure.} = object
    fmtid*: GUID
    pid*: DWORD
  REFPROPERTYKEY* = ptr PROPERTYKEY
const
  CLSCTX_INPROC_SERVER* = 0x1
  CLSCTX_INPROC_HANDLER* = 0x2
  CLSCTX_LOCAL_SERVER* = 0x4
  CLSCTX_REMOTE_SERVER* = 0x10
  CLSCTX_ALL* = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER or CLSCTX_LOCAL_SERVER or CLSCTX_REMOTE_SERVER
  DVASPECT_CONTENT* = 1
  STATFLAG_NONAME* = 1
  IID_IUnknown* = DEFINE_GUID(0x00000000'i32, 0x0000, 0x0000, [0xc0'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46])
  STREAM_SEEK_SET* = 0
  TYMED_HGLOBAL* = 1
  TYMED_GDI* = 16
  DATADIR_GET* = 1
  IID_IDataObject* = DEFINE_GUID(0x0000010e'i32, 0x0000, 0x0000, [0xc0'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46])
  DROPEFFECT_NONE* = 0
  DROPEFFECT_COPY* = 1
  DROPEFFECT_MOVE* = 2
  DROPEFFECT_LINK* = 4
type
  COMDLG_FILTERSPEC* {.pure.} = object
    pszName*: LPCWSTR
    pszSpec*: LPCWSTR
proc OleInitialize*(pvReserved: LPVOID): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc RegisterDragDrop*(hwnd: HWND, pDropTarget: LPDROPTARGET): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc RevokeDragDrop*(hwnd: HWND): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc DoDragDrop*(pDataObj: LPDATAOBJECT, pDropSource: LPDROPSOURCE, dwOKEffects: DWORD, pdwEffect: LPDWORD): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleSetClipboard*(pDataObj: LPDATAOBJECT): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleGetClipboard*(ppDataObj: ptr LPDATAOBJECT): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleFlushClipboard*(): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleIsCurrentClipboard*(pDataObj: LPDATAOBJECT): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc ReleaseStgMedium*(P1: LPSTGMEDIUM): void {.winapi, stdcall, dynlib: "ole32", importc.}
proc CoCreateInstance*(rclsid: REFCLSID, pUnkOuter: LPUNKNOWN, dwClsContext: DWORD, riid: REFIID, ppv: ptr LPVOID): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc CoTaskMemFree*(pv: LPVOID): void {.winapi, stdcall, dynlib: "ole32", importc.}
proc QueryInterface*(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.QueryInterface(self, riid, ppvObject)
proc AddRef*(self: ptr IUnknown): ULONG {.winapi, inline.} = self.lpVtbl.AddRef(self)
proc Release*(self: ptr IUnknown): ULONG {.winapi, inline.} = self.lpVtbl.Release(self)
proc Next*(self: ptr IEnumString, celt: ULONG, rgelt: ptr LPOLESTR, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumString, celt: ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumString): HRESULT {.winapi, inline.} = self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumString, ppenum: ptr ptr IEnumString): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppenum)
proc Read*(self: ptr ISequentialStream, pv: pointer, cb: ULONG, pcbRead: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Read(self, pv, cb, pcbRead)
proc Write*(self: ptr ISequentialStream, pv: pointer, cb: ULONG, pcbWritten: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Write(self, pv, cb, pcbWritten)
proc Seek*(self: ptr IStream, dlibMove: LARGE_INTEGER, dwOrigin: DWORD, plibNewPosition: ptr ULARGE_INTEGER): HRESULT {.winapi, inline.} = self.lpVtbl.Seek(self, dlibMove, dwOrigin, plibNewPosition)
proc SetSize*(self: ptr IStream, libNewSize: ULARGE_INTEGER): HRESULT {.winapi, inline.} = self.lpVtbl.SetSize(self, libNewSize)
proc CopyTo*(self: ptr IStream, pstm: ptr IStream, cb: ULARGE_INTEGER, pcbRead: ptr ULARGE_INTEGER, pcbWritten: ptr ULARGE_INTEGER): HRESULT {.winapi, inline.} = self.lpVtbl.CopyTo(self, pstm, cb, pcbRead, pcbWritten)
proc Commit*(self: ptr IStream, grfCommitFlags: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Commit(self, grfCommitFlags)
proc Revert*(self: ptr IStream): HRESULT {.winapi, inline.} = self.lpVtbl.Revert(self)
proc LockRegion*(self: ptr IStream, libOffset: ULARGE_INTEGER, cb: ULARGE_INTEGER, dwLockType: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.LockRegion(self, libOffset, cb, dwLockType)
proc UnlockRegion*(self: ptr IStream, libOffset: ULARGE_INTEGER, cb: ULARGE_INTEGER, dwLockType: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.UnlockRegion(self, libOffset, cb, dwLockType)
proc Stat*(self: ptr IStream, pstatstg: ptr STATSTG, grfStatFlag: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Stat(self, pstatstg, grfStatFlag)
proc Clone*(self: ptr IStream, ppstm: ptr ptr IStream): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppstm)
proc RegisterObjectBound*(self: ptr IBindCtx, punk: ptr IUnknown): HRESULT {.winapi, inline.} = self.lpVtbl.RegisterObjectBound(self, punk)
proc RevokeObjectBound*(self: ptr IBindCtx, punk: ptr IUnknown): HRESULT {.winapi, inline.} = self.lpVtbl.RevokeObjectBound(self, punk)
proc ReleaseBoundObjects*(self: ptr IBindCtx): HRESULT {.winapi, inline.} = self.lpVtbl.ReleaseBoundObjects(self)
proc SetBindOptions*(self: ptr IBindCtx, pbindopts: ptr BIND_OPTS): HRESULT {.winapi, inline.} = self.lpVtbl.SetBindOptions(self, pbindopts)
proc GetBindOptions*(self: ptr IBindCtx, pbindopts: ptr BIND_OPTS): HRESULT {.winapi, inline.} = self.lpVtbl.GetBindOptions(self, pbindopts)
proc GetRunningObjectTable*(self: ptr IBindCtx, pprot: ptr ptr IRunningObjectTable): HRESULT {.winapi, inline.} = self.lpVtbl.GetRunningObjectTable(self, pprot)
proc RegisterObjectParam*(self: ptr IBindCtx, pszKey: LPOLESTR, punk: ptr IUnknown): HRESULT {.winapi, inline.} = self.lpVtbl.RegisterObjectParam(self, pszKey, punk)
proc GetObjectParam*(self: ptr IBindCtx, pszKey: LPOLESTR, ppunk: ptr ptr IUnknown): HRESULT {.winapi, inline.} = self.lpVtbl.GetObjectParam(self, pszKey, ppunk)
proc EnumObjectParam*(self: ptr IBindCtx, ppenum: ptr ptr IEnumString): HRESULT {.winapi, inline.} = self.lpVtbl.EnumObjectParam(self, ppenum)
proc RevokeObjectParam*(self: ptr IBindCtx, pszKey: LPOLESTR): HRESULT {.winapi, inline.} = self.lpVtbl.RevokeObjectParam(self, pszKey)
proc Next*(self: ptr IEnumMoniker, celt: ULONG, rgelt: ptr ptr IMoniker, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumMoniker, celt: ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumMoniker, ppenum: ptr ptr IEnumMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppenum)
proc Register*(self: ptr IRunningObjectTable, grfFlags: DWORD, punkObject: ptr IUnknown, pmkObjectName: ptr IMoniker, pdwRegister: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Register(self, grfFlags, punkObject, pmkObjectName, pdwRegister)
proc Revoke*(self: ptr IRunningObjectTable, dwRegister: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Revoke(self, dwRegister)
proc IsRunning*(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.IsRunning(self, pmkObjectName)
proc GetObject*(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker, ppunkObject: ptr ptr IUnknown): HRESULT {.winapi, inline.} = self.lpVtbl.GetObject(self, pmkObjectName, ppunkObject)
proc NoteChangeTime*(self: ptr IRunningObjectTable, dwRegister: DWORD, pfiletime: ptr FILETIME): HRESULT {.winapi, inline.} = self.lpVtbl.NoteChangeTime(self, dwRegister, pfiletime)
proc GetTimeOfLastChange*(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker, pfiletime: ptr FILETIME): HRESULT {.winapi, inline.} = self.lpVtbl.GetTimeOfLastChange(self, pmkObjectName, pfiletime)
proc EnumRunning*(self: ptr IRunningObjectTable, ppenumMoniker: ptr ptr IEnumMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.EnumRunning(self, ppenumMoniker)
proc GetClassID*(self: ptr IPersist, pClassID: ptr CLSID): HRESULT {.winapi, inline.} = self.lpVtbl.GetClassID(self, pClassID)
proc IsDirty*(self: ptr IPersistStream): HRESULT {.winapi, inline.} = self.lpVtbl.IsDirty(self)
proc Load*(self: ptr IPersistStream, pStm: ptr IStream): HRESULT {.winapi, inline.} = self.lpVtbl.Load(self, pStm)
proc Save*(self: ptr IPersistStream, pStm: ptr IStream, fClearDirty: WINBOOL): HRESULT {.winapi, inline.} = self.lpVtbl.Save(self, pStm, fClearDirty)
proc GetSizeMax*(self: ptr IPersistStream, pcbSize: ptr ULARGE_INTEGER): HRESULT {.winapi, inline.} = self.lpVtbl.GetSizeMax(self, pcbSize)
proc BindToObject*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, riidResult: REFIID, ppvResult: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.BindToObject(self, pbc, pmkToLeft, riidResult, ppvResult)
proc BindToStorage*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, riid: REFIID, ppvObj: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.BindToStorage(self, pbc, pmkToLeft, riid, ppvObj)
proc Reduce*(self: ptr IMoniker, pbc: ptr IBindCtx, dwReduceHowFar: DWORD, ppmkToLeft: ptr ptr IMoniker, ppmkReduced: ptr ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.Reduce(self, pbc, dwReduceHowFar, ppmkToLeft, ppmkReduced)
proc ComposeWith*(self: ptr IMoniker, pmkRight: ptr IMoniker, fOnlyIfNotGeneric: WINBOOL, ppmkComposite: ptr ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.ComposeWith(self, pmkRight, fOnlyIfNotGeneric, ppmkComposite)
proc Enum*(self: ptr IMoniker, fForward: WINBOOL, ppenumMoniker: ptr ptr IEnumMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.Enum(self, fForward, ppenumMoniker)
proc IsEqual*(self: ptr IMoniker, pmkOtherMoniker: ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.IsEqual(self, pmkOtherMoniker)
proc Hash*(self: ptr IMoniker, pdwHash: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Hash(self, pdwHash)
proc IsRunning*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pmkNewlyRunning: ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.IsRunning(self, pbc, pmkToLeft, pmkNewlyRunning)
proc GetTimeOfLastChange*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pFileTime: ptr FILETIME): HRESULT {.winapi, inline.} = self.lpVtbl.GetTimeOfLastChange(self, pbc, pmkToLeft, pFileTime)
proc Inverse*(self: ptr IMoniker, ppmk: ptr ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.Inverse(self, ppmk)
proc CommonPrefixWith*(self: ptr IMoniker, pmkOther: ptr IMoniker, ppmkPrefix: ptr ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.CommonPrefixWith(self, pmkOther, ppmkPrefix)
proc RelativePathTo*(self: ptr IMoniker, pmkOther: ptr IMoniker, ppmkRelPath: ptr ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.RelativePathTo(self, pmkOther, ppmkRelPath)
proc GetDisplayName*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, ppszDisplayName: ptr LPOLESTR): HRESULT {.winapi, inline.} = self.lpVtbl.GetDisplayName(self, pbc, pmkToLeft, ppszDisplayName)
proc ParseDisplayName*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pszDisplayName: LPOLESTR, pchEaten: ptr ULONG, ppmkOut: ptr ptr IMoniker): HRESULT {.winapi, inline.} = self.lpVtbl.ParseDisplayName(self, pbc, pmkToLeft, pszDisplayName, pchEaten, ppmkOut)
proc IsSystemMoniker*(self: ptr IMoniker, pdwMksys: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.IsSystemMoniker(self, pdwMksys)
proc Next*(self: ptr IEnumSTATSTG, celt: ULONG, rgelt: ptr STATSTG, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumSTATSTG, celt: ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumSTATSTG): HRESULT {.winapi, inline.} = self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumSTATSTG, ppenum: ptr ptr IEnumSTATSTG): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppenum)
proc CreateStream*(self: ptr IStorage, pwcsName: ptr OLECHAR, grfMode: DWORD, reserved1: DWORD, reserved2: DWORD, ppstm: ptr ptr IStream): HRESULT {.winapi, inline.} = self.lpVtbl.CreateStream(self, pwcsName, grfMode, reserved1, reserved2, ppstm)
proc OpenStream*(self: ptr IStorage, pwcsName: ptr OLECHAR, reserved1: pointer, grfMode: DWORD, reserved2: DWORD, ppstm: ptr ptr IStream): HRESULT {.winapi, inline.} = self.lpVtbl.OpenStream(self, pwcsName, reserved1, grfMode, reserved2, ppstm)
proc CreateStorage*(self: ptr IStorage, pwcsName: ptr OLECHAR, grfMode: DWORD, reserved1: DWORD, reserved2: DWORD, ppstg: ptr ptr IStorage): HRESULT {.winapi, inline.} = self.lpVtbl.CreateStorage(self, pwcsName, grfMode, reserved1, reserved2, ppstg)
proc OpenStorage*(self: ptr IStorage, pwcsName: ptr OLECHAR, pstgPriority: ptr IStorage, grfMode: DWORD, snbExclude: SNB, reserved: DWORD, ppstg: ptr ptr IStorage): HRESULT {.winapi, inline.} = self.lpVtbl.OpenStorage(self, pwcsName, pstgPriority, grfMode, snbExclude, reserved, ppstg)
proc CopyTo*(self: ptr IStorage, ciidExclude: DWORD, rgiidExclude: ptr IID, snbExclude: SNB, pstgDest: ptr IStorage): HRESULT {.winapi, inline.} = self.lpVtbl.CopyTo(self, ciidExclude, rgiidExclude, snbExclude, pstgDest)
proc MoveElementTo*(self: ptr IStorage, pwcsName: ptr OLECHAR, pstgDest: ptr IStorage, pwcsNewName: ptr OLECHAR, grfFlags: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.MoveElementTo(self, pwcsName, pstgDest, pwcsNewName, grfFlags)
proc Commit*(self: ptr IStorage, grfCommitFlags: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Commit(self, grfCommitFlags)
proc Revert*(self: ptr IStorage): HRESULT {.winapi, inline.} = self.lpVtbl.Revert(self)
proc EnumElements*(self: ptr IStorage, reserved1: DWORD, reserved2: pointer, reserved3: DWORD, ppenum: ptr ptr IEnumSTATSTG): HRESULT {.winapi, inline.} = self.lpVtbl.EnumElements(self, reserved1, reserved2, reserved3, ppenum)
proc DestroyElement*(self: ptr IStorage, pwcsName: ptr OLECHAR): HRESULT {.winapi, inline.} = self.lpVtbl.DestroyElement(self, pwcsName)
proc RenameElement*(self: ptr IStorage, pwcsOldName: ptr OLECHAR, pwcsNewName: ptr OLECHAR): HRESULT {.winapi, inline.} = self.lpVtbl.RenameElement(self, pwcsOldName, pwcsNewName)
proc SetElementTimes*(self: ptr IStorage, pwcsName: ptr OLECHAR, pctime: ptr FILETIME, patime: ptr FILETIME, pmtime: ptr FILETIME): HRESULT {.winapi, inline.} = self.lpVtbl.SetElementTimes(self, pwcsName, pctime, patime, pmtime)
proc SetClass*(self: ptr IStorage, clsid: REFCLSID): HRESULT {.winapi, inline.} = self.lpVtbl.SetClass(self, clsid)
proc SetStateBits*(self: ptr IStorage, grfStateBits: DWORD, grfMask: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.SetStateBits(self, grfStateBits, grfMask)
proc Stat*(self: ptr IStorage, pstatstg: ptr STATSTG, grfStatFlag: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Stat(self, pstatstg, grfStatFlag)
proc Next*(self: ptr IEnumFORMATETC, celt: ULONG, rgelt: ptr FORMATETC, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumFORMATETC, celt: ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumFORMATETC): HRESULT {.winapi, inline.} = self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumFORMATETC, ppenum: ptr ptr IEnumFORMATETC): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppenum)
proc Next*(self: ptr IEnumSTATDATA, celt: ULONG, rgelt: ptr STATDATA, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumSTATDATA, celt: ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumSTATDATA, ppenum: ptr ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppenum)
proc OnDataChange*(self: ptr IAdviseSink, pFormatetc: ptr FORMATETC, pStgmed: ptr STGMEDIUM): void {.winapi, inline.} = self.lpVtbl.OnDataChange(self, pFormatetc, pStgmed)
proc OnViewChange*(self: ptr IAdviseSink, dwAspect: DWORD, lindex: LONG): void {.winapi, inline.} = self.lpVtbl.OnViewChange(self, dwAspect, lindex)
proc OnRename*(self: ptr IAdviseSink, pmk: ptr IMoniker): void {.winapi, inline.} = self.lpVtbl.OnRename(self, pmk)
proc OnSave*(self: ptr IAdviseSink): void {.winapi, inline.} = self.lpVtbl.OnSave(self)
proc OnClose*(self: ptr IAdviseSink): void {.winapi, inline.} = self.lpVtbl.OnClose(self)
proc GetData*(self: ptr IDataObject, pformatetcIn: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.winapi, inline.} = self.lpVtbl.GetData(self, pformatetcIn, pmedium)
proc GetDataHere*(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.winapi, inline.} = self.lpVtbl.GetDataHere(self, pformatetc, pmedium)
proc QueryGetData*(self: ptr IDataObject, pformatetc: ptr FORMATETC): HRESULT {.winapi, inline.} = self.lpVtbl.QueryGetData(self, pformatetc)
proc GetCanonicalFormatEtc*(self: ptr IDataObject, pformatectIn: ptr FORMATETC, pformatetcOut: ptr FORMATETC): HRESULT {.winapi, inline.} = self.lpVtbl.GetCanonicalFormatEtc(self, pformatectIn, pformatetcOut)
proc SetData*(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM, fRelease: WINBOOL): HRESULT {.winapi, inline.} = self.lpVtbl.SetData(self, pformatetc, pmedium, fRelease)
proc EnumFormatEtc*(self: ptr IDataObject, dwDirection: DWORD, ppenumFormatEtc: ptr ptr IEnumFORMATETC): HRESULT {.winapi, inline.} = self.lpVtbl.EnumFormatEtc(self, dwDirection, ppenumFormatEtc)
proc DAdvise*(self: ptr IDataObject, pformatetc: ptr FORMATETC, advf: DWORD, pAdvSink: ptr IAdviseSink, pdwConnection: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.DAdvise(self, pformatetc, advf, pAdvSink, pdwConnection)
proc DUnadvise*(self: ptr IDataObject, dwConnection: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.DUnadvise(self, dwConnection)
proc EnumDAdvise*(self: ptr IDataObject, ppenumAdvise: ptr ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = self.lpVtbl.EnumDAdvise(self, ppenumAdvise)
proc QueryContinueDrag*(self: ptr IDropSource, fEscapePressed: WINBOOL, grfKeyState: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.QueryContinueDrag(self, fEscapePressed, grfKeyState)
proc GiveFeedback*(self: ptr IDropSource, dwEffect: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.GiveFeedback(self, dwEffect)
proc DragEnter*(self: ptr IDropTarget, pDataObj: ptr IDataObject, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.DragEnter(self, pDataObj, grfKeyState, pt, pdwEffect)
proc DragOver*(self: ptr IDropTarget, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.DragOver(self, grfKeyState, pt, pdwEffect)
proc DragLeave*(self: ptr IDropTarget): HRESULT {.winapi, inline.} = self.lpVtbl.DragLeave(self)
proc Drop*(self: ptr IDropTarget, pDataObj: ptr IDataObject, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Drop(self, pDataObj, grfKeyState, pt, pdwEffect)
converter winimConverterIEnumStringToIUnknown*(x: ptr IEnumString): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterISequentialStreamToIUnknown*(x: ptr ISequentialStream): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIStreamToISequentialStream*(x: ptr IStream): ptr ISequentialStream = cast[ptr ISequentialStream](x)
converter winimConverterIStreamToIUnknown*(x: ptr IStream): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIBindCtxToIUnknown*(x: ptr IBindCtx): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumMonikerToIUnknown*(x: ptr IEnumMoniker): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIRunningObjectTableToIUnknown*(x: ptr IRunningObjectTable): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIPersistToIUnknown*(x: ptr IPersist): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIPersistStreamToIPersist*(x: ptr IPersistStream): ptr IPersist = cast[ptr IPersist](x)
converter winimConverterIPersistStreamToIUnknown*(x: ptr IPersistStream): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIMonikerToIPersistStream*(x: ptr IMoniker): ptr IPersistStream = cast[ptr IPersistStream](x)
converter winimConverterIMonikerToIPersist*(x: ptr IMoniker): ptr IPersist = cast[ptr IPersist](x)
converter winimConverterIMonikerToIUnknown*(x: ptr IMoniker): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumSTATSTGToIUnknown*(x: ptr IEnumSTATSTG): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIStorageToIUnknown*(x: ptr IStorage): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumFORMATETCToIUnknown*(x: ptr IEnumFORMATETC): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumSTATDATAToIUnknown*(x: ptr IEnumSTATDATA): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIAdviseSinkToIUnknown*(x: ptr IAdviseSink): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIDataObjectToIUnknown*(x: ptr IDataObject): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIDropSourceToIUnknown*(x: ptr IDropSource): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIDropTargetToIUnknown*(x: ptr IDropTarget): ptr IUnknown = cast[ptr IUnknown](x)
type
  HIMAGELIST* = HANDLE
  HTREEITEM* = HANDLE
  TINITCOMMONCONTROLSEX* {.pure.} = object
    dwSize*: DWORD
    dwICC*: DWORD
  NMMOUSE* {.pure.} = object
    hdr*: NMHDR
    dwItemSpec*: DWORD_PTR
    dwItemData*: DWORD_PTR
    pt*: POINT
    dwHitInfo*: LPARAM
  LPNMMOUSE* = ptr NMMOUSE
  IMAGEINFO* {.pure.} = object
    hbmImage*: HBITMAP
    hbmMask*: HBITMAP
    Unused1*: int32
    Unused2*: int32
    rcImage*: RECT
  HDITEMA* {.pure.} = object
    mask*: UINT
    cxy*: int32
    pszText*: LPSTR
    hbm*: HBITMAP
    cchTextMax*: int32
    fmt*: int32
    lParam*: LPARAM
    iImage*: int32
    iOrder*: int32
    `type`*: UINT
    pvFilter*: pointer
    state*: UINT
  HDITEMW* {.pure.} = object
    mask*: UINT
    cxy*: int32
    pszText*: LPWSTR
    hbm*: HBITMAP
    cchTextMax*: int32
    fmt*: int32
    lParam*: LPARAM
    iImage*: int32
    iOrder*: int32
    `type`*: UINT
    pvFilter*: pointer
    state*: UINT
  HDHITTESTINFO* {.pure.} = object
    pt*: POINT
    flags*: UINT
    iItem*: int32
  NMHEADERA* {.pure.} = object
    hdr*: NMHDR
    iItem*: int32
    iButton*: int32
    pitem*: ptr HDITEMA
  NMHEADERW* {.pure.} = object
    hdr*: NMHDR
    iItem*: int32
    iButton*: int32
    pitem*: ptr HDITEMW
  LPNMHEADERA* = ptr NMHEADERA
  LPNMHEADERW* = ptr NMHEADERW
when winimCpu64:
  type
    TBBUTTON* {.pure.} = object
      iBitmap*: int32
      idCommand*: int32
      fsState*: BYTE
      fsStyle*: BYTE
      bReserved*: array[6, BYTE]
      dwData*: DWORD_PTR
      iString*: INT_PTR
when winimCpu32:
  type
    TBBUTTON* {.pure.} = object
      iBitmap*: int32
      idCommand*: int32
      fsState*: BYTE
      fsStyle*: BYTE
      bReserved*: array[2, BYTE]
      dwData*: DWORD_PTR
      iString*: INT_PTR
type
  TTBADDBITMAP* {.pure.} = object
    hInst*: HINSTANCE
    nID*: UINT_PTR
  TBBUTTONINFOA* {.pure.} = object
    cbSize*: UINT
    dwMask*: DWORD
    idCommand*: int32
    iImage*: int32
    fsState*: BYTE
    fsStyle*: BYTE
    cx*: WORD
    lParam*: DWORD_PTR
    pszText*: LPSTR
    cchText*: int32
  TBBUTTONINFOW* {.pure.} = object
    cbSize*: UINT
    dwMask*: DWORD
    idCommand*: int32
    iImage*: int32
    fsState*: BYTE
    fsStyle*: BYTE
    cx*: WORD
    lParam*: DWORD_PTR
    pszText*: LPWSTR
    cchText*: int32
  NMTBHOTITEM* {.pure.} = object
    hdr*: NMHDR
    idOld*: int32
    idNew*: int32
    dwFlags*: DWORD
  LPNMTBHOTITEM* = ptr NMTBHOTITEM
  NMTOOLBARA* {.pure.} = object
    hdr*: NMHDR
    iItem*: int32
    tbButton*: TBBUTTON
    cchText*: int32
    pszText*: LPSTR
    rcButton*: RECT
  NMTOOLBARW* {.pure.} = object
    hdr*: NMHDR
    iItem*: int32
    tbButton*: TBBUTTON
    cchText*: int32
    pszText*: LPWSTR
    rcButton*: RECT
  LPNMTOOLBARA* = ptr NMTOOLBARA
  LPNMTOOLBARW* = ptr NMTOOLBARW
when winimUnicode:
  type
    LPNMTOOLBAR* = LPNMTOOLBARW
when winimAnsi:
  type
    LPNMTOOLBAR* = LPNMTOOLBARA
type
  REBARINFO* {.pure.} = object
    cbSize*: UINT
    fMask*: UINT
    himl*: HIMAGELIST
  REBARBANDINFOA* {.pure.} = object
    cbSize*: UINT
    fMask*: UINT
    fStyle*: UINT
    clrFore*: COLORREF
    clrBack*: COLORREF
    lpText*: LPSTR
    cch*: UINT
    iImage*: int32
    hwndChild*: HWND
    cxMinChild*: UINT
    cyMinChild*: UINT
    cx*: UINT
    hbmBack*: HBITMAP
    wID*: UINT
    cyChild*: UINT
    cyMaxChild*: UINT
    cyIntegral*: UINT
    cxIdeal*: UINT
    lParam*: LPARAM
    cxHeader*: UINT
    rcChevronLocation*: RECT
    uChevronState*: UINT
  REBARBANDINFOW* {.pure.} = object
    cbSize*: UINT
    fMask*: UINT
    fStyle*: UINT
    clrFore*: COLORREF
    clrBack*: COLORREF
    lpText*: LPWSTR
    cch*: UINT
    iImage*: int32
    hwndChild*: HWND
    cxMinChild*: UINT
    cyMinChild*: UINT
    cx*: UINT
    hbmBack*: HBITMAP
    wID*: UINT
    cyChild*: UINT
    cyMaxChild*: UINT
    cyIntegral*: UINT
    cxIdeal*: UINT
    lParam*: LPARAM
    cxHeader*: UINT
    rcChevronLocation*: RECT
    uChevronState*: UINT
  TTTOOLINFOA* {.pure.} = object
    cbSize*: UINT
    uFlags*: UINT
    hwnd*: HWND
    uId*: UINT_PTR
    rect*: RECT
    hinst*: HINSTANCE
    lpszText*: LPSTR
    lParam*: LPARAM
    lpReserved*: pointer
  TTTOOLINFOW* {.pure.} = object
    cbSize*: UINT
    uFlags*: UINT
    hwnd*: HWND
    uId*: UINT_PTR
    rect*: RECT
    hinst*: HINSTANCE
    lpszText*: LPWSTR
    lParam*: LPARAM
    lpReserved*: pointer
  NMTTDISPINFOW* {.pure.} = object
    hdr*: NMHDR
    lpszText*: LPWSTR
    szText*: array[80, WCHAR]
    hinst*: HINSTANCE
    uFlags*: UINT
    lParam*: LPARAM
  NMTTDISPINFOA* {.pure.} = object
    hdr*: NMHDR
    lpszText*: LPSTR
    szText*: array[80, char]
    hinst*: HINSTANCE
    uFlags*: UINT
    lParam*: LPARAM
  LPNMTTDISPINFOA* = ptr NMTTDISPINFOA
  LPNMTTDISPINFOW* = ptr NMTTDISPINFOW
when winimUnicode:
  type
    LPNMTTDISPINFO* = LPNMTTDISPINFOW
when winimAnsi:
  type
    LPNMTTDISPINFO* = LPNMTTDISPINFOA
type
  NMUPDOWN* {.pure.} = object
    hdr*: NMHDR
    iPos*: int32
    iDelta*: int32
  LPNMUPDOWN* = ptr NMUPDOWN
const
  MAX_LINKID_TEXT* = 48
  L_MAX_URL_LENGTH* = 2084
type
  LITEM* {.pure.} = object
    mask*: UINT
    iLink*: int32
    state*: UINT
    stateMask*: UINT
    szID*: array[MAX_LINKID_TEXT, WCHAR]
    szUrl*: array[L_MAX_URL_LENGTH, WCHAR]
  NMLINK* {.pure.} = object
    hdr*: NMHDR
    item*: LITEM
  PNMLINK* = ptr NMLINK
  LVITEMA* {.pure.} = object
    mask*: UINT
    iItem*: int32
    iSubItem*: int32
    state*: UINT
    stateMask*: UINT
    pszText*: LPSTR
    cchTextMax*: int32
    iImage*: int32
    lParam*: LPARAM
    iIndent*: int32
    iGroupId*: int32
    cColumns*: UINT
    puColumns*: PUINT
    piColFmt*: ptr int32
    iGroup*: int32
  LVITEMW* {.pure.} = object
    mask*: UINT
    iItem*: int32
    iSubItem*: int32
    state*: UINT
    stateMask*: UINT
    pszText*: LPWSTR
    cchTextMax*: int32
    iImage*: int32
    lParam*: LPARAM
    iIndent*: int32
    iGroupId*: int32
    cColumns*: UINT
    puColumns*: PUINT
    piColFmt*: ptr int32
    iGroup*: int32
  LVFINDINFOA* {.pure.} = object
    flags*: UINT
    psz*: LPCSTR
    lParam*: LPARAM
    pt*: POINT
    vkDirection*: UINT
  LVFINDINFOW* {.pure.} = object
    flags*: UINT
    psz*: LPCWSTR
    lParam*: LPARAM
    pt*: POINT
    vkDirection*: UINT
  LVHITTESTINFO* {.pure.} = object
    pt*: POINT
    flags*: UINT
    iItem*: int32
    iSubItem*: int32
    iGroup*: int32
  LVCOLUMNA* {.pure.} = object
    mask*: UINT
    fmt*: int32
    cx*: int32
    pszText*: LPSTR
    cchTextMax*: int32
    iSubItem*: int32
    iImage*: int32
    iOrder*: int32
    cxMin*: int32
    cxDefault*: int32
    cxIdeal*: int32
  LVCOLUMNW* {.pure.} = object
    mask*: UINT
    fmt*: int32
    cx*: int32
    pszText*: LPWSTR
    cchTextMax*: int32
    iSubItem*: int32
    iImage*: int32
    iOrder*: int32
    cxMin*: int32
    cxDefault*: int32
    cxIdeal*: int32
  NMLISTVIEW* {.pure.} = object
    hdr*: NMHDR
    iItem*: int32
    iSubItem*: int32
    uNewState*: UINT
    uOldState*: UINT
    uChanged*: UINT
    ptAction*: POINT
    lParam*: LPARAM
  LPNMLISTVIEW* = ptr NMLISTVIEW
  NMITEMACTIVATE* {.pure.} = object
    hdr*: NMHDR
    iItem*: int32
    iSubItem*: int32
    uNewState*: UINT
    uOldState*: UINT
    uChanged*: UINT
    ptAction*: POINT
    lParam*: LPARAM
    uKeyFlags*: UINT
  LPNMITEMACTIVATE* = ptr NMITEMACTIVATE
  NMLVDISPINFOA* {.pure.} = object
    hdr*: NMHDR
    item*: LVITEMA
  NMLVDISPINFOW* {.pure.} = object
    hdr*: NMHDR
    item*: LVITEMW
  LPNMLVDISPINFOA* = ptr NMLVDISPINFOA
  LPNMLVDISPINFOW* = ptr NMLVDISPINFOW
  TVITEMA* {.pure.} = object
    mask*: UINT
    hItem*: HTREEITEM
    state*: UINT
    stateMask*: UINT
    pszText*: LPSTR
    cchTextMax*: int32
    iImage*: int32
    iSelectedImage*: int32
    cChildren*: int32
    lParam*: LPARAM
  LPTVITEMA* = ptr TVITEMA
  TVITEMW* {.pure.} = object
    mask*: UINT
    hItem*: HTREEITEM
    state*: UINT
    stateMask*: UINT
    pszText*: LPWSTR
    cchTextMax*: int32
    iImage*: int32
    iSelectedImage*: int32
    cChildren*: int32
    lParam*: LPARAM
  LPTVITEMW* = ptr TVITEMW
  TVITEMEXA* {.pure.} = object
    mask*: UINT
    hItem*: HTREEITEM
    state*: UINT
    stateMask*: UINT
    pszText*: LPSTR
    cchTextMax*: int32
    iImage*: int32
    iSelectedImage*: int32
    cChildren*: int32
    lParam*: LPARAM
    iIntegral*: int32
    uStateEx*: UINT
    hwnd*: HWND
    iExpandedImage*: int32
  TVITEMEXW* {.pure.} = object
    mask*: UINT
    hItem*: HTREEITEM
    state*: UINT
    stateMask*: UINT
    pszText*: LPWSTR
    cchTextMax*: int32
    iImage*: int32
    iSelectedImage*: int32
    cChildren*: int32
    lParam*: LPARAM
    iIntegral*: int32
    uStateEx*: UINT
    hwnd*: HWND
    iExpandedImage*: int32
  TVINSERTSTRUCTA_UNION1* {.pure, union.} = object
    itemex*: TVITEMEXA
    item*: TV_ITEMA
  TVINSERTSTRUCTA* {.pure.} = object
    hParent*: HTREEITEM
    hInsertAfter*: HTREEITEM
    union1*: TVINSERTSTRUCTA_UNION1
  TVINSERTSTRUCTW_UNION1* {.pure, union.} = object
    itemex*: TVITEMEXW
    item*: TV_ITEMW
  TVINSERTSTRUCTW* {.pure.} = object
    hParent*: HTREEITEM
    hInsertAfter*: HTREEITEM
    union1*: TVINSERTSTRUCTW_UNION1
  TVHITTESTINFO* {.pure.} = object
    pt*: POINT
    flags*: UINT
    hItem*: HTREEITEM
  LPTVHITTESTINFO* = ptr TVHITTESTINFO
  PFNTVCOMPARE* = proc (lParam1: LPARAM, lParam2: LPARAM, lParamSort: LPARAM): int32 {.stdcall.}
  TVSORTCB* {.pure.} = object
    hParent*: HTREEITEM
    lpfnCompare*: PFNTVCOMPARE
    lParam*: LPARAM
  LPTVSORTCB* = ptr TVSORTCB
  NMTREEVIEWA* {.pure.} = object
    hdr*: NMHDR
    action*: UINT
    itemOld*: TVITEMA
    itemNew*: TVITEMA
    ptDrag*: POINT
  LPNMTREEVIEWA* = ptr NMTREEVIEWA
  NMTREEVIEWW* {.pure.} = object
    hdr*: NMHDR
    action*: UINT
    itemOld*: TVITEMW
    itemNew*: TVITEMW
    ptDrag*: POINT
  LPNMTREEVIEWW* = ptr NMTREEVIEWW
  NMTVDISPINFOA* {.pure.} = object
    hdr*: NMHDR
    item*: TVITEMA
  NMTVDISPINFOW* {.pure.} = object
    hdr*: NMHDR
    item*: TVITEMW
  LPNMTVDISPINFOA* = ptr NMTVDISPINFOA
  LPNMTVDISPINFOW* = ptr NMTVDISPINFOW
  TCITEMA* {.pure.} = object
    mask*: UINT
    dwState*: DWORD
    dwStateMask*: DWORD
    pszText*: LPSTR
    cchTextMax*: int32
    iImage*: int32
    lParam*: LPARAM
  TCITEMW* {.pure.} = object
    mask*: UINT
    dwState*: DWORD
    dwStateMask*: DWORD
    pszText*: LPWSTR
    cchTextMax*: int32
    iImage*: int32
    lParam*: LPARAM
  NMIPADDRESS* {.pure.} = object
    hdr*: NMHDR
    iField*: int32
    iValue*: int32
  LPNMIPADDRESS* = ptr NMIPADDRESS
  BUTTON_IMAGELIST* {.pure.} = object
    himl*: HIMAGELIST
    margin*: RECT
    uAlign*: UINT
  NMBCHOTITEM* {.pure.} = object
    hdr*: NMHDR
    dwFlags*: DWORD
  LPNMBCHOTITEM* = ptr NMBCHOTITEM
  NMBCDROPDOWN* {.pure.} = object
    hdr*: NMHDR
    rcButton*: RECT
  LPNMBCDROPDOWN* = ptr NMBCDROPDOWN
when winimUnicode:
  type
    TTTOOLINFO* = TTTOOLINFOW
when winimAnsi:
  type
    TTTOOLINFO* = TTTOOLINFOA
type
  TOOLINFO* = TTTOOLINFO
const
  ICC_LISTVIEW_CLASSES* = 0x1
  ICC_BAR_CLASSES* = 0x4
  ICC_DATE_CLASSES* = 0x100
  ICC_COOL_CLASSES* = 0x400
  ICC_INTERNET_CLASSES* = 0x800
  ICC_LINK_CLASS* = 0x8000
  LVM_FIRST* = 0x1000
  TV_FIRST* = 0x1100
  HDM_FIRST* = 0x1200
  TCM_FIRST* = 0x1300
  BCM_FIRST* = 0x1600
  NM_FIRST* = 0-0
  NM_CLICK* = NM_FIRST-2
  NM_DBLCLK* = NM_FIRST-3
  NM_RETURN* = NM_FIRST-4
  NM_RCLICK* = NM_FIRST-5
  NM_RDBLCLK* = NM_FIRST-6
  NM_SETFOCUS* = NM_FIRST-7
  NM_KILLFOCUS* = NM_FIRST-8
  LVN_FIRST* = 0-100
  HDN_FIRST* = 0-300
  TVN_FIRST* = 0-400
  TTN_FIRST* = 0-520
  TCN_FIRST* = 0-550
  TBN_FIRST* = 0-700
  UDN_FIRST* = 0-721
  MCN_FIRST* = 0-746
  DTN_FIRST2* = 0-753
  RBN_FIRST* = 0-831
  IPN_FIRST* = 0-860
  BCN_FIRST* = 0-1250
  ILC_MASK* = 0x1
  ILC_COLOR32* = 0x20
  ILD_TRANSPARENT* = 0x1
  HDI_WIDTH* = 0x1
  HDM_HITTEST* = HDM_FIRST+6
  HDN_ITEMCHANGINGA* = HDN_FIRST-0
  HDN_ITEMCHANGINGW* = HDN_FIRST-20
  HDN_BEGINTRACKA* = HDN_FIRST-6
  HDN_BEGINTRACKW* = HDN_FIRST-26
  HDN_ENDTRACKA* = HDN_FIRST-7
  HDN_ENDTRACKW* = HDN_FIRST-27
  HDN_BEGINDRAG* = HDN_FIRST-10
  HDN_ENDDRAG* = HDN_FIRST-11
  TOOLBARCLASSNAMEW* = "ToolbarWindow32"
  TOOLBARCLASSNAMEA* = "ToolbarWindow32"
  TBSTATE_CHECKED* = 0x1
  TBSTATE_ENABLED* = 0x4
  TBSTYLE_BUTTON* = 0x0
  TBSTYLE_SEP* = 0x1
  TBSTYLE_CHECK* = 0x2
  TBSTYLE_GROUP* = 0x4
  TBSTYLE_CHECKGROUP* = TBSTYLE_GROUP or TBSTYLE_CHECK
  TBSTYLE_TOOLTIPS* = 0x100
  TBSTYLE_FLAT* = 0x800
  TBSTYLE_EX_DRAWDDARROWS* = 0x1
  BTNS_WHOLEDROPDOWN* = 0x80
  TB_ENABLEBUTTON* = WM_USER+1
  TB_SETSTATE* = WM_USER+17
  TB_GETSTATE* = WM_USER+18
  TB_ADDBITMAP* = WM_USER+19
  TB_INSERTBUTTONA* = WM_USER+21
  TB_DELETEBUTTON* = WM_USER+22
  TB_GETBUTTON* = WM_USER+23
  TB_BUTTONCOUNT* = WM_USER+24
  TB_GETITEMRECT* = WM_USER+29
  TB_BUTTONSTRUCTSIZE* = WM_USER+30
  TB_SETBITMAPSIZE* = WM_USER+32
  TB_AUTOSIZE* = WM_USER+33
  TB_GETSTYLE* = WM_USER+57
  TB_GETBUTTONSIZE* = WM_USER+58
  TB_SETHOTITEM* = WM_USER+72
  TB_SETEXTENDEDSTYLE* = WM_USER+84
  TBIF_IMAGE* = 0x1
  TBIF_TEXT* = 0x2
  TBIF_STATE* = 0x4
  TBIF_STYLE* = 0x8
  TBIF_LPARAM* = 0x10
  TB_GETBUTTONINFOW* = WM_USER+63
  TB_GETBUTTONINFOA* = WM_USER+65
  TB_INSERTBUTTONW* = WM_USER+67
  TBN_DROPDOWN* = TBN_FIRST-10
  HICF_ENTERING* = 0x10
  HICF_LEAVING* = 0x20
  TBN_HOTITEMCHANGE* = TBN_FIRST-13
  REBARCLASSNAMEW* = "ReBarWindow32"
  REBARCLASSNAMEA* = "ReBarWindow32"
  RBIM_IMAGELIST* = 0x1
  RBS_VARHEIGHT* = 0x200
  RBS_BANDBORDERS* = 0x400
  RBS_AUTOSIZE* = 0x2000
  RBS_DBLCLKTOGGLE* = 0x8000
  RBBS_BREAK* = 0x1
  RBBS_CHILDEDGE* = 0x4
  RBBS_GRIPPERALWAYS* = 0x80
  RBBIM_STYLE* = 0x1
  RBBIM_TEXT* = 0x4
  RBBIM_IMAGE* = 0x8
  RBBIM_CHILD* = 0x10
  RBBIM_CHILDSIZE* = 0x20
  RBBIM_SIZE* = 0x40
  RB_INSERTBANDA* = WM_USER+1
  RB_SETBARINFO* = WM_USER+4
  RB_INSERTBANDW* = WM_USER+10
  RB_GETBANDCOUNT* = WM_USER+12
  RBN_LAYOUTCHANGED* = RBN_FIRST-2
  RBN_AUTOSIZE* = RBN_FIRST-3
  RBN_BEGINDRAG* = RBN_FIRST-4
  RBN_ENDDRAG* = RBN_FIRST-5
  TOOLTIPS_CLASSW* = "tooltips_class32"
  TOOLTIPS_CLASSA* = "tooltips_class32"
  TTS_ALWAYSTIP* = 0x1
  TTS_NOPREFIX* = 0x2
  TTF_IDISHWND* = 0x1
  TTF_SUBCLASS* = 0x10
  TTDT_RESHOW* = 1
  TTDT_AUTOPOP* = 2
  TTDT_INITIAL* = 3
  TTM_ACTIVATE* = WM_USER+1
  TTM_SETDELAYTIME* = WM_USER+3
  TTM_ADDTOOLA* = WM_USER+4
  TTM_ADDTOOLW* = WM_USER+50
  TTM_GETTEXTA* = WM_USER+11
  TTM_GETTEXTW* = WM_USER+56
  TTM_SETMAXTIPWIDTH* = WM_USER+24
  TTN_GETDISPINFOA* = TTN_FIRST-0
  TTN_GETDISPINFOW* = TTN_FIRST-10
when winimUnicode:
  const
    TTN_GETDISPINFO* = TTN_GETDISPINFOW
when winimAnsi:
  const
    TTN_GETDISPINFO* = TTN_GETDISPINFOA
const
  STATUSCLASSNAMEW* = "msctls_statusbar32"
  STATUSCLASSNAMEA* = "msctls_statusbar32"
  SB_SETTEXTA* = WM_USER+1
  SB_SETTEXTW* = WM_USER+11
  SB_GETTEXTA* = WM_USER+2
  SB_GETTEXTW* = WM_USER+13
  SB_GETTEXTLENGTHA* = WM_USER+3
  SB_GETTEXTLENGTHW* = WM_USER+12
  SB_SETPARTS* = WM_USER+4
  SB_SETMINHEIGHT* = WM_USER+8
  SB_SETICON* = WM_USER+15
  TRACKBAR_CLASSA* = "msctls_trackbar32"
  TRACKBAR_CLASSW* = "msctls_trackbar32"
  TBS_AUTOTICKS* = 0x1
  TBS_VERT* = 0x2
  TBS_HORZ* = 0x0
  TBS_TOP* = 0x4
  TBS_BOTTOM* = 0x0
  TBS_LEFT* = 0x4
  TBS_RIGHT* = 0x0
  TBS_NOTICKS* = 0x10
  TBS_ENABLESELRANGE* = 0x20
  TBS_FIXEDLENGTH* = 0x40
  TBS_NOTHUMB* = 0x80
  TBM_GETPOS* = WM_USER
  TBM_SETTIC* = WM_USER+4
  TBM_SETPOS* = WM_USER+5
  TBM_SETRANGEMIN* = WM_USER+7
  TBM_SETRANGEMAX* = WM_USER+8
  TBM_CLEARTICS* = WM_USER+9
  TBM_SETSEL* = WM_USER+10
  TBM_GETSELSTART* = WM_USER+17
  TBM_GETSELEND* = WM_USER+18
  TBM_CLEARSEL* = WM_USER+19
  TBM_SETTICFREQ* = WM_USER+20
  TBM_SETPAGESIZE* = WM_USER+21
  TBM_GETPAGESIZE* = WM_USER+22
  TBM_SETLINESIZE* = WM_USER+23
  TBM_GETLINESIZE* = WM_USER+24
  TBM_SETTHUMBLENGTH* = WM_USER+27
  TBM_GETTHUMBLENGTH* = WM_USER+28
  UPDOWN_CLASSA* = "msctls_updown32"
  UPDOWN_CLASSW* = "msctls_updown32"
  UDS_WRAP* = 0x1
  UDS_SETBUDDYINT* = 0x2
  UDS_ALIGNRIGHT* = 0x4
  UDS_ARROWKEYS* = 0x20
  UDS_HORZ* = 0x40
  UDS_HOTTRACK* = 0x100
  UDM_SETBUDDY* = WM_USER+105
  UDM_SETBASE* = WM_USER+109
  UDM_GETBASE* = WM_USER+110
  UDM_SETRANGE32* = WM_USER+111
  UDM_GETRANGE32* = WM_USER+112
  UDM_SETPOS32* = WM_USER+113
  UDM_GETPOS32* = WM_USER+114
  UDN_DELTAPOS* = UDN_FIRST-1
  PROGRESS_CLASSA* = "msctls_progress32"
  PROGRESS_CLASSW* = "msctls_progress32"
  PBS_SMOOTH* = 0x1
  PBS_VERTICAL* = 0x4
  PBM_SETPOS* = WM_USER+2
  PBM_STEPIT* = WM_USER+5
  PBM_SETRANGE32* = WM_USER+6
  PBM_GETRANGE* = WM_USER+7
  PBM_GETPOS* = WM_USER+8
  PBS_MARQUEE* = 0x8
  PBM_SETMARQUEE* = WM_USER+10
  CCS_TOP* = 0x1
  CCS_BOTTOM* = 0x3
  CCS_NORESIZE* = 0x4
  CCS_NOPARENTALIGN* = 0x8
  CCS_NODIVIDER* = 0x40
  CCS_VERT* = 0x80
  CCS_LEFT* = CCS_VERT or CCS_TOP
  CCS_RIGHT* = CCS_VERT or CCS_BOTTOM
  WC_LINK* = "SysLink"
  WC_LISTVIEWA* = "SysListView32"
  WC_LISTVIEWW* = "SysListView32"
  LVS_ICON* = 0x0
  LVS_REPORT* = 0x1
  LVS_SMALLICON* = 0x2
  LVS_LIST* = 0x3
  LVS_SINGLESEL* = 0x4
  LVS_SHOWSELALWAYS* = 0x8
  LVS_SORTASCENDING* = 0x10
  LVS_SORTDESCENDING* = 0x20
  LVS_SHAREIMAGELISTS* = 0x40
  LVS_AUTOARRANGE* = 0x100
  LVS_EDITLABELS* = 0x200
  LVS_ALIGNTOP* = 0x0
  LVS_ALIGNLEFT* = 0x800
  LVS_NOCOLUMNHEADER* = 0x4000
  LVS_NOSORTHEADER* = 0x8000
  LVM_GETBKCOLOR* = LVM_FIRST+0
  LVM_SETBKCOLOR* = LVM_FIRST+1
  LVSIL_NORMAL* = 0
  LVSIL_SMALL* = 1
  LVSIL_STATE* = 2
  LVM_SETIMAGELIST* = LVM_FIRST+3
  LVM_GETITEMCOUNT* = LVM_FIRST+4
  LVIF_TEXT* = 0x1
  LVIF_IMAGE* = 0x2
  LVIF_PARAM* = 0x4
  LVIF_STATE* = 0x8
  LVIS_FOCUSED* = 0x1
  LVIS_SELECTED* = 0x2
  LVIS_CUT* = 0x4
  LVIS_DROPHILITED* = 0x8
  LVIS_STATEIMAGEMASK* = 0xF000
  I_IMAGECALLBACK* = -1
  I_IMAGENONE* = -2
  LVM_GETITEMA* = LVM_FIRST+5
  LVM_GETITEMW* = LVM_FIRST+75
  LVM_SETITEMA* = LVM_FIRST+6
  LVM_SETITEMW* = LVM_FIRST+76
  LVM_INSERTITEMA* = LVM_FIRST+7
  LVM_INSERTITEMW* = LVM_FIRST+77
  LVM_DELETEITEM* = LVM_FIRST+8
  LVM_DELETEALLITEMS* = LVM_FIRST+9
  LVNI_ALL* = 0x0
  LVNI_FOCUSED* = 0x1
  LVNI_SELECTED* = 0x2
  LVNI_CUT* = 0x4
  LVNI_DROPHILITED* = 0x8
  LVNI_PREVIOUS* = 0x20
  LVNI_ABOVE* = 0x100
  LVNI_BELOW* = 0x200
  LVNI_TOLEFT* = 0x400
  LVNI_TORIGHT* = 0x800
  LVM_GETNEXTITEM* = LVM_FIRST+12
  LVFI_PARAM* = 0x1
  LVFI_STRING* = 0x2
  LVFI_PARTIAL* = 0x8
  LVM_FINDITEMA* = LVM_FIRST+13
  LVM_FINDITEMW* = LVM_FIRST+83
  LVIR_BOUNDS* = 0
  LVIR_ICON* = 1
  LVIR_LABEL* = 2
  LVIR_SELECTBOUNDS* = 3
  LVM_GETITEMRECT* = LVM_FIRST+14
  LVM_GETITEMPOSITION* = LVM_FIRST+16
  LVHT_NOWHERE* = 0x1
  LVHT_ONITEMICON* = 0x2
  LVHT_ONITEMLABEL* = 0x4
  LVHT_ONITEMSTATEICON* = 0x8
  LVHT_ABOVE* = 0x8
  LVHT_BELOW* = 0x10
  LVHT_TORIGHT* = 0x20
  LVHT_TOLEFT* = 0x40
  LVM_ENSUREVISIBLE* = LVM_FIRST+19
  LVM_SCROLL* = LVM_FIRST+20
  LVM_REDRAWITEMS* = LVM_FIRST+21
  LVA_DEFAULT* = 0x0
  LVA_ALIGNLEFT* = 0x1
  LVA_ALIGNTOP* = 0x2
  LVA_SNAPTOGRID* = 0x5
  LVM_ARRANGE* = LVM_FIRST+22
  LVM_EDITLABELA* = LVM_FIRST+23
  LVM_EDITLABELW* = LVM_FIRST+118
  LVM_GETEDITCONTROL* = LVM_FIRST+24
  LVCF_FMT* = 0x1
  LVCF_WIDTH* = 0x2
  LVCF_TEXT* = 0x4
  LVCF_IMAGE* = 0x10
  LVCFMT_LEFT* = 0x0
  LVCFMT_RIGHT* = 0x1
  LVCFMT_CENTER* = 0x2
  LVM_GETCOLUMNA* = LVM_FIRST+25
  LVM_GETCOLUMNW* = LVM_FIRST+95
  LVM_SETCOLUMNA* = LVM_FIRST+26
  LVM_SETCOLUMNW* = LVM_FIRST+96
  LVM_INSERTCOLUMNA* = LVM_FIRST+27
  LVM_INSERTCOLUMNW* = LVM_FIRST+97
  LVM_DELETECOLUMN* = LVM_FIRST+28
  LVM_GETCOLUMNWIDTH* = LVM_FIRST+29
  LVSCW_AUTOSIZE* = -1
  LVSCW_AUTOSIZE_USEHEADER* = -2
  LVM_SETCOLUMNWIDTH* = LVM_FIRST+30
  LVM_GETVIEWRECT* = LVM_FIRST+34
  LVM_GETTEXTCOLOR* = LVM_FIRST+35
  LVM_SETTEXTCOLOR* = LVM_FIRST+36
  LVM_SETTEXTBKCOLOR* = LVM_FIRST+38
  LVM_GETTOPINDEX* = LVM_FIRST+39
  LVM_GETCOUNTPERPAGE* = LVM_FIRST+40
  LVM_SETITEMSTATE* = LVM_FIRST+43
  LVM_GETITEMSTATE* = LVM_FIRST+44
  LVM_SORTITEMS* = LVM_FIRST+48
  LVM_SETITEMPOSITION32* = LVM_FIRST+49
  LVM_GETSELECTEDCOUNT* = LVM_FIRST+50
  LVM_GETITEMSPACING* = LVM_FIRST+51
  LVM_SETICONSPACING* = LVM_FIRST+53
  LVM_SETEXTENDEDLISTVIEWSTYLE* = LVM_FIRST+54
  LVM_GETEXTENDEDLISTVIEWSTYLE* = LVM_FIRST+55
  LVS_EX_SUBITEMIMAGES* = 0x2
  LVS_EX_CHECKBOXES* = 0x4
  LVS_EX_HEADERDRAGDROP* = 0x10
  LVS_EX_FULLROWSELECT* = 0x20
  LVS_EX_LABELTIP* = 0x4000
  LVM_GETSUBITEMRECT* = LVM_FIRST+56
  LVM_SUBITEMHITTEST* = LVM_FIRST+57
  LVM_SETCOLUMNORDERARRAY* = LVM_FIRST+58
  LVM_GETCOLUMNORDERARRAY* = LVM_FIRST+59
  LVM_APPROXIMATEVIEWRECT* = LVM_FIRST+64
  LVM_SORTITEMSEX* = LVM_FIRST+81
  LVM_SETVIEW* = LVM_FIRST+142
  LVM_GETVIEW* = LVM_FIRST+143
  LVN_ITEMCHANGED* = LVN_FIRST-1
  LVN_INSERTITEM* = LVN_FIRST-2
  LVN_DELETEITEM* = LVN_FIRST-3
  LVN_DELETEALLITEMS* = LVN_FIRST-4
  LVN_BEGINLABELEDITA* = LVN_FIRST-5
  LVN_BEGINLABELEDITW* = LVN_FIRST-75
  LVN_ENDLABELEDITA* = LVN_FIRST-6
  LVN_ENDLABELEDITW* = LVN_FIRST-76
  LVN_COLUMNCLICK* = LVN_FIRST-8
  LVN_BEGINDRAG* = LVN_FIRST-9
  LVN_BEGINRDRAG* = LVN_FIRST-11
  LVN_ITEMACTIVATE* = LVN_FIRST-14
  WC_TREEVIEWA* = "SysTreeView32"
  WC_TREEVIEWW* = "SysTreeView32"
  TVS_HASBUTTONS* = 0x1
  TVS_HASLINES* = 0x2
  TVS_LINESATROOT* = 0x4
  TVS_EDITLABELS* = 0x8
  TVS_CHECKBOXES* = 0x100
  TVS_SINGLEEXPAND* = 0x400
  TVS_FULLROWSELECT* = 0x1000
  TVS_NOSCROLL* = 0x2000
  TVS_NOHSCROLL* = 0x8000
  TVIF_TEXT* = 0x1
  TVIF_IMAGE* = 0x2
  TVIF_PARAM* = 0x4
  TVIF_STATE* = 0x8
  TVIF_HANDLE* = 0x10
  TVIF_SELECTEDIMAGE* = 0x20
  TVIF_CHILDREN* = 0x40
  TVIS_SELECTED* = 0x2
  TVIS_CUT* = 0x4
  TVIS_DROPHILITED* = 0x8
  TVIS_BOLD* = 0x10
  TVIS_EXPANDED* = 0x20
  TVIS_STATEIMAGEMASK* = 0xF000
  TVM_INSERTITEMA* = TV_FIRST+0
  TVM_INSERTITEMW* = TV_FIRST+50
  TVM_DELETEITEM* = TV_FIRST+1
  TVM_EXPAND* = TV_FIRST+2
  TVE_COLLAPSE* = 0x1
  TVE_EXPAND* = 0x2
  TVE_TOGGLE* = 0x3
  TVE_COLLAPSERESET* = 0x8000
  TVM_GETITEMRECT* = TV_FIRST+4
  TVM_GETCOUNT* = TV_FIRST+5
  TVM_GETINDENT* = TV_FIRST+6
  TVM_SETINDENT* = TV_FIRST+7
  TVSIL_NORMAL* = 0
  TVSIL_STATE* = 2
  TVM_SETIMAGELIST* = TV_FIRST+9
  TVM_GETNEXTITEM* = TV_FIRST+10
  TVGN_ROOT* = 0x0
  TVGN_NEXT* = 0x1
  TVGN_PREVIOUS* = 0x2
  TVGN_PARENT* = 0x3
  TVGN_CHILD* = 0x4
  TVGN_FIRSTVISIBLE* = 0x5
  TVGN_NEXTVISIBLE* = 0x6
  TVGN_PREVIOUSVISIBLE* = 0x7
  TVGN_DROPHILITE* = 0x8
  TVGN_CARET* = 0x9
  TVM_SELECTITEM* = TV_FIRST+11
  TVM_GETITEMA* = TV_FIRST+12
  TVM_GETITEMW* = TV_FIRST+62
  TVM_SETITEMA* = TV_FIRST+13
  TVM_SETITEMW* = TV_FIRST+63
  TVM_EDITLABELA* = TV_FIRST+14
  TVM_EDITLABELW* = TV_FIRST+65
  TVM_GETEDITCONTROL* = TV_FIRST+15
  TVM_HITTEST* = TV_FIRST+17
  TVHT_NOWHERE* = 0x1
  TVHT_ONITEMICON* = 0x2
  TVHT_ONITEMLABEL* = 0x4
  TVHT_ONITEMSTATEICON* = 0x40
  TVHT_ONITEM* = TVHT_ONITEMICON or TVHT_ONITEMLABEL or TVHT_ONITEMSTATEICON
  TVHT_ONITEMINDENT* = 0x8
  TVHT_ONITEMBUTTON* = 0x10
  TVHT_ONITEMRIGHT* = 0x20
  TVHT_ABOVE* = 0x100
  TVHT_BELOW* = 0x200
  TVHT_TORIGHT* = 0x400
  TVHT_TOLEFT* = 0x800
  TVM_CREATEDRAGIMAGE* = TV_FIRST+18
  TVM_SORTCHILDREN* = TV_FIRST+19
  TVM_ENSUREVISIBLE* = TV_FIRST+20
  TVM_SORTCHILDRENCB* = TV_FIRST+21
  TVM_SETINSERTMARK* = TV_FIRST+26
  TVM_SETBKCOLOR* = TV_FIRST+29
  TVM_SETTEXTCOLOR* = TV_FIRST+30
  TVN_SELCHANGINGA* = TVN_FIRST-1
  TVN_SELCHANGINGW* = TVN_FIRST-50
  TVN_SELCHANGEDA* = TVN_FIRST-2
  TVN_SELCHANGEDW* = TVN_FIRST-51
  TVN_ITEMEXPANDINGA* = TVN_FIRST-5
  TVN_ITEMEXPANDINGW* = TVN_FIRST-54
  TVN_ITEMEXPANDEDA* = TVN_FIRST-6
  TVN_ITEMEXPANDEDW* = TVN_FIRST-55
  TVN_BEGINDRAGA* = TVN_FIRST-7
  TVN_BEGINDRAGW* = TVN_FIRST-56
  TVN_BEGINRDRAGA* = TVN_FIRST-8
  TVN_BEGINRDRAGW* = TVN_FIRST-57
  TVN_DELETEITEMA* = TVN_FIRST-9
  TVN_DELETEITEMW* = TVN_FIRST-58
  TVN_BEGINLABELEDITA* = TVN_FIRST-10
  TVN_BEGINLABELEDITW* = TVN_FIRST-59
  TVN_ENDLABELEDITA* = TVN_FIRST-11
  TVN_ENDLABELEDITW* = TVN_FIRST-60
  WC_TABCONTROLA* = "SysTabControl32"
  WC_TABCONTROLW* = "SysTabControl32"
  TCS_FORCEICONLEFT* = 0x10
  TCS_BUTTONS* = 0x100
  TCS_MULTILINE* = 0x200
  TCS_FIXEDWIDTH* = 0x400
  TCS_FOCUSONBUTTONDOWN* = 0x1000
  TCM_SETIMAGELIST* = TCM_FIRST+3
  TCM_GETITEMCOUNT* = TCM_FIRST+4
  TCIF_TEXT* = 0x1
  TCIF_IMAGE* = 0x2
  TCM_GETITEMA* = TCM_FIRST+5
  TCM_GETITEMW* = TCM_FIRST+60
  TCM_SETITEMA* = TCM_FIRST+6
  TCM_SETITEMW* = TCM_FIRST+61
  TCM_INSERTITEMA* = TCM_FIRST+7
  TCM_INSERTITEMW* = TCM_FIRST+62
  TCM_DELETEITEM* = TCM_FIRST+8
  TCM_DELETEALLITEMS* = TCM_FIRST+9
  TCM_GETCURSEL* = TCM_FIRST+11
  TCM_SETCURSEL* = TCM_FIRST+12
  TCM_ADJUSTRECT* = TCM_FIRST+40
  TCM_SETPADDING* = TCM_FIRST+43
  TCM_SETCURFOCUS* = TCM_FIRST+48
  TCN_SELCHANGE* = TCN_FIRST-1
  TCN_SELCHANGING* = TCN_FIRST-2
  MONTHCAL_CLASSW* = "SysMonthCal32"
  MONTHCAL_CLASSA* = "SysMonthCal32"
  MCM_FIRST* = 0x1000
  MCM_GETCURSEL* = MCM_FIRST+1
  MCM_SETCURSEL* = MCM_FIRST+2
  MCM_GETMAXSELCOUNT* = MCM_FIRST+3
  MCM_SETMAXSELCOUNT* = MCM_FIRST+4
  MCM_GETSELRANGE* = MCM_FIRST+5
  MCM_SETSELRANGE* = MCM_FIRST+6
  MCM_GETMINREQRECT* = MCM_FIRST+9
  MCM_SETTODAY* = MCM_FIRST+12
  MCM_GETTODAY* = MCM_FIRST+13
  MCM_SETFIRSTDAYOFWEEK* = MCM_FIRST+15
  MCM_GETRANGE* = MCM_FIRST+17
  MCM_SETRANGE* = MCM_FIRST+18
  MCM_GETMAXTODAYWIDTH* = MCM_FIRST+21
  MCN_SELCHANGE* = MCN_FIRST-3
  MCN_VIEWCHANGE* = MCN_FIRST-4
  MCS_MULTISELECT* = 0x2
  MCS_WEEKNUMBERS* = 0x4
  MCS_NOTODAY* = 0x10
  DATETIMEPICK_CLASSW* = "SysDateTimePick32"
  DATETIMEPICK_CLASSA* = "SysDateTimePick32"
  DTM_FIRST* = 0x1000
  DTM_GETSYSTEMTIME* = DTM_FIRST+1
  DTM_SETSYSTEMTIME* = DTM_FIRST+2
  DTM_GETRANGE* = DTM_FIRST+3
  DTM_SETRANGE* = DTM_FIRST+4
  DTM_GETIDEALSIZE* = DTM_FIRST+15
  DTS_UPDOWN* = 0x1
  DTS_SHOWNONE* = 0x2
  DTS_SHORTDATECENTURYFORMAT* = 0xc
  DTS_TIMEFORMAT* = 0x9
  DTN_DATETIMECHANGE* = DTN_FIRST2-6
  GDTR_MIN* = 0x1
  GDTR_MAX* = 0x2
  GDT_VALID* = 0
  IPM_CLEARADDRESS* = WM_USER+100
  IPM_SETADDRESS* = WM_USER+101
  IPM_GETADDRESS* = WM_USER+102
  IPM_SETFOCUS* = WM_USER+104
  WC_IPADDRESSW* = "SysIPAddress32"
  WC_IPADDRESSA* = "SysIPAddress32"
  IPN_FIELDCHANGED* = IPN_FIRST-0
  WC_BUTTONA* = "Button"
  WC_BUTTONW* = "Button"
  BUTTON_IMAGELIST_ALIGN_LEFT* = 0
  BUTTON_IMAGELIST_ALIGN_RIGHT* = 1
  BUTTON_IMAGELIST_ALIGN_TOP* = 2
  BUTTON_IMAGELIST_ALIGN_BOTTOM* = 3
  BUTTON_IMAGELIST_ALIGN_CENTER* = 4
  BCM_GETIDEALSIZE* = BCM_FIRST+0x1
  BCM_SETIMAGELIST* = BCM_FIRST+0x2
  BCN_HOTITEMCHANGE* = BCN_FIRST+0x1
  BS_SPLITBUTTON* = 0xc
  BCN_DROPDOWN* = BCN_FIRST+0x0002
  WC_STATICA* = "Static"
  WC_STATICW* = "Static"
  WC_EDITA* = "Edit"
  WC_EDITW* = "Edit"
  WC_LISTBOXA* = "ListBox"
  WC_LISTBOXW* = "ListBox"
  WC_COMBOBOXA* = "ComboBox"
  WC_COMBOBOXW* = "ComboBox"
  WC_SCROLLBARA* = "ScrollBar"
  WC_SCROLLBARW* = "ScrollBar"
  LWS_RIGHT* = 0x20
  LIF_ITEMINDEX* = 0x1
  LIF_STATE* = 0x2
  LIF_ITEMID* = 0x4
  LIF_URL* = 0x8
  LIS_FOCUSED* = 0x1
  LIS_ENABLED* = 0x2
  LIS_VISITED* = 0x4
  LIS_HOTTRACK* = 0x8
  LIS_DEFAULTCOLORS* = 0x10
  LM_GETIDEALHEIGHT* = WM_USER+0x301
  LM_SETITEM* = WM_USER+0x302
  LM_GETITEM* = WM_USER+0x303
  TVI_FIRST* = HTREEITEM(-0xffff)
  TVI_LAST* = HTREEITEM(-0xfffe)
  TVI_ROOT* = HTREEITEM(-0x10000)
  LM_GETIDEALSIZE* = LM_GETIDEALHEIGHT
type
  SUBCLASSPROC* = proc (hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM, uIdSubclass: UINT_PTR, dwRefData: DWORD_PTR): LRESULT {.stdcall.}
proc InitCommonControlsEx*(P1: ptr TINITCOMMONCONTROLSEX): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_Create*(cx: int32, cy: int32, flags: UINT, cInitial: int32, cGrow: int32): HIMAGELIST {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_Destroy*(himl: HIMAGELIST): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_GetImageCount*(himl: HIMAGELIST): int32 {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_Add*(himl: HIMAGELIST, hbmImage: HBITMAP, hbmMask: HBITMAP): int32 {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_ReplaceIcon*(himl: HIMAGELIST, i: int32, hicon: HICON): int32 {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_Draw*(himl: HIMAGELIST, i: int32, hdcDst: HDC, x: int32, y: int32, fStyle: UINT): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_Replace*(himl: HIMAGELIST, i: int32, hbmImage: HBITMAP, hbmMask: HBITMAP): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_AddMasked*(himl: HIMAGELIST, hbmImage: HBITMAP, crMask: COLORREF): int32 {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_Remove*(himl: HIMAGELIST, i: int32): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_GetIcon*(himl: HIMAGELIST, i: int32, flags: UINT): HICON {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_BeginDrag*(himlTrack: HIMAGELIST, iTrack: int32, dxHotspot: int32, dyHotspot: int32): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_EndDrag*(): void {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_DragEnter*(hwndLock: HWND, x: int32, y: int32): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_DragMove*(x: int32, y: int32): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_DragShowNolock*(fShow: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_GetIconSize*(himl: HIMAGELIST, cx: ptr int32, cy: ptr int32): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc ImageList_GetImageInfo*(himl: HIMAGELIST, i: int32, pImageInfo: ptr IMAGEINFO): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc SetWindowSubclass*(hWnd: HWND, pfnSubclass: SUBCLASSPROC, uIdSubclass: UINT_PTR, dwRefData: DWORD_PTR): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc RemoveWindowSubclass*(hWnd: HWND, pfnSubclass: SUBCLASSPROC, uIdSubclass: UINT_PTR): WINBOOL {.winapi, stdcall, dynlib: "comctl32", importc.}
proc DefSubclassProc*(hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "comctl32", importc.}
template INDEXTOSTATEIMAGEMASK*(i: untyped): untyped = i shl 12
template MAKEIPADDRESS*(b1: BYTE, b2: BYTE, b3: BYTE, b4: BYTE): LPARAM = (b1.LPARAM shl 24) + (b2.LPARAM shl 16) + (b3.LPARAM shl 8) + (b4.LPARAM)
template FIRST_IPADDRESS*(x: LPARAM): BYTE = cast[BYTE](x shr 24)
template SECOND_IPADDRESS*(x: LPARAM): BYTE = cast[BYTE](x shr 16)
template THIRD_IPADDRESS*(x: LPARAM): BYTE = cast[BYTE](x shr 8)
template FOURTH_IPADDRESS*(x: LPARAM): BYTE = cast[BYTE](x)
template ImageList_AddIcon*(himl: HIMAGELIST, hicon: HICON): int32 = ImageList_ReplaceIcon(himl, -1, hicon)
when winimUnicode:
  const
    LVM_EDITLABEL* = LVM_EDITLABELW
when winimAnsi:
  const
    LVM_EDITLABEL* = LVM_EDITLABELA
when winimUnicode:
  type
    LVFINDINFO* = LVFINDINFOW
when winimAnsi:
  type
    LVFINDINFO* = LVFINDINFOA
when winimUnicode:
  const
    LVM_FINDITEM* = LVM_FINDITEMW
when winimAnsi:
  const
    LVM_FINDITEM* = LVM_FINDITEMA
template ListView_GetCheckState*(hwnd: HWND, i: UINT): BOOL = discardable BOOL((SendMessage(hwnd, LVM_GETITEMSTATE, cast[WPARAM](i), LVIS_STATEIMAGEMASK) shr 12) - 1)
when winimUnicode:
  const
    LVM_GETCOLUMN* = LVM_GETCOLUMNW
when winimAnsi:
  const
    LVM_GETCOLUMN* = LVM_GETCOLUMNA
when winimUnicode:
  const
    LVM_GETITEM* = LVM_GETITEMW
when winimAnsi:
  const
    LVM_GETITEM* = LVM_GETITEMA
when winimUnicode:
  const
    LVM_INSERTCOLUMN* = LVM_INSERTCOLUMNW
when winimAnsi:
  const
    LVM_INSERTCOLUMN* = LVM_INSERTCOLUMNA
when winimUnicode:
  const
    LVM_INSERTITEM* = LVM_INSERTITEMW
when winimAnsi:
  const
    LVM_INSERTITEM* = LVM_INSERTITEMA
template ListView_SetItemState*(hwnd: HWND, i: int32, data: UINT, mask: UINT): void = (var lvi = LV_ITEM(stateMask: mask, state: data); SendMessage(hwnd, LVM_SETITEMSTATE, cast[WPARAM](i), cast[LPARAM](addr lvi)))
template ListView_SetCheckState*(hwnd: HWND, i: UINT, fCheck: BOOL) = ListView_SetItemState(hwnd, i, INDEXTOSTATEIMAGEMASK(if bool fCheck:2 else:1), LVIS_STATEIMAGEMASK)
when winimUnicode:
  const
    LVM_SETCOLUMN* = LVM_SETCOLUMNW
when winimAnsi:
  const
    LVM_SETCOLUMN* = LVM_SETCOLUMNA
when winimUnicode:
  const
    LVM_SETITEM* = LVM_SETITEMW
when winimAnsi:
  const
    LVM_SETITEM* = LVM_SETITEMA
when winimUnicode:
  const
    TCM_GETITEM* = TCM_GETITEMW
when winimAnsi:
  const
    TCM_GETITEM* = TCM_GETITEMA
when winimUnicode:
  const
    TCM_INSERTITEM* = TCM_INSERTITEMW
when winimAnsi:
  const
    TCM_INSERTITEM* = TCM_INSERTITEMA
when winimUnicode:
  const
    TCM_SETITEM* = TCM_SETITEMW
when winimAnsi:
  const
    TCM_SETITEM* = TCM_SETITEMA
template TreeView_CreateDragImage*(hwnd: HWND, hitem: HTREEITEM): HIMAGELIST = discardable HIMAGELIST SendMessage(hwnd, TVM_CREATEDRAGIMAGE, 0, cast[LPARAM](hitem))
template TreeView_DeleteItem*(hwnd: HWND, hitem: HTREEITEM): BOOL = discardable BOOL SendMessage(hwnd, TVM_DELETEITEM, 0, cast[LPARAM](hitem))
when winimUnicode:
  const
    TVM_EDITLABEL* = TVM_EDITLABELW
when winimAnsi:
  const
    TVM_EDITLABEL* = TVM_EDITLABELA
template TreeView_EditLabel*(hwnd: HWND, hitem: HTREEITEM): HWND = discardable HWND SendMessage(hwnd, TVM_EDITLABEL, 0, cast[LPARAM](hitem))
template TreeView_EnsureVisible*(hwnd: HWND, hitem: HTREEITEM): BOOL = discardable BOOL SendMessage(hwnd, TVM_ENSUREVISIBLE, 0, cast[LPARAM](hitem))
template TreeView_Expand*(hwnd: HWND, hitem: HTREEITEM, code: UINT): BOOL = discardable BOOL SendMessage(hwnd, TVM_EXPAND, cast[WPARAM](code), cast[LPARAM](hitem))
template TreeView_GetNextItem*(hwnd: HWND, hitem: HTREEITEM, code: UINT): HTREEITEM = discardable HTREEITEM SendMessage(hwnd, TVM_GETNEXTITEM, cast[WPARAM](code), cast[LPARAM](hitem))
template TreeView_GetCount*(hwnd: HWND): UINT = discardable UINT SendMessage(hwnd, TVM_GETCOUNT, 0, 0)
template TreeView_GetEditControl*(hwnd: HWND): HWND = discardable HWND SendMessage(hwnd, TVM_GETEDITCONTROL, 0, 0)
template TreeView_GetFirstVisible*(hwnd: HWND): HTREEITEM = TreeView_GetNextItem(hwnd, 0, TVGN_FIRSTVISIBLE)
template TreeView_GetIndent*(hwnd: HWND): UINT = discardable UINT SendMessage(hwnd, TVM_GETINDENT, 0, 0)
when winimUnicode:
  type
    LPTVITEM* = LPTVITEMW
when winimAnsi:
  type
    LPTVITEM* = LPTVITEMA
when winimUnicode:
  const
    TVM_GETITEM* = TVM_GETITEMW
when winimAnsi:
  const
    TVM_GETITEM* = TVM_GETITEMA
template TreeView_GetItem*(hwnd: HWND, pitem: LPTVITEM): BOOL = discardable BOOL SendMessage(hwnd, TVM_GETITEM, 0, cast[LPARAM](pitem))
template TreeView_GetItemRect*(hwnd: HWND, hitem: HTREEITEM, prc: LPRECT, fItemRect: BOOL): BOOL = (cast[ptr HTREEITEM](prc)[] = hitem; discardable BOOL SendMessage(hwnd, TVM_GETITEMRECT, cast[WPARAM](fItemRect), cast[LPARAM](prc)))
template TreeView_GetRoot*(hwnd: HWND): HTREEITEM = TreeView_GetNextItem(hwnd, 0, TVGN_ROOT)
template TreeView_GetSelection*(hwnd: HWND): HTREEITEM = TreeView_GetNextItem(hwnd, 0, TVGN_CARET)
template TreeView_HitTest*(hwnd: HWND, lpht: LPTVHITTESTINFO): HTREEITEM = discardable HTREEITEM SendMessage(hwnd, TVM_HITTEST, 0, cast[LPARAM](lpht))
when winimUnicode:
  const
    TVM_INSERTITEM* = TVM_INSERTITEMW
when winimAnsi:
  const
    TVM_INSERTITEM* = TVM_INSERTITEMA
template TreeView_Select*(hwnd: HWND, hitem: HTREEITEM, code: UINT): BOOL = discardable BOOL SendMessage(hwnd, TVM_SELECTITEM, cast[WPARAM](code), cast[LPARAM](hitem))
template TreeView_SelectDropTarget*(hwnd: HWND, hitem: HTREEITEM): BOOL = TreeView_Select(hwnd, hitem, TVGN_DROPHILITE)
template TreeView_SelectItem*(hwnd: HWND, hitem: HTREEITEM): BOOL = TreeView_Select(hwnd, hitem, TVGN_CARET)
template TreeView_SetBkColor*(hwnd: HWND, clr: COLORREF): COLORREF = discardable COLORREF SendMessage(hwnd, TVM_SETBKCOLOR, 0, cast[LPARAM](clr))
when winimUnicode:
  type
    TVITEM* = TVITEMW
when winimAnsi:
  type
    TVITEM* = TVITEMA
when winimUnicode:
  const
    TVM_SETITEM* = TVM_SETITEMW
when winimAnsi:
  const
    TVM_SETITEM* = TVM_SETITEMA
template TreeView_SetIndent*(hwnd: HWND, indent: INT): BOOL = discardable BOOL SendMessage(hwnd, TVM_SETINDENT, cast[WPARAM](indent), 0)
template TreeView_SetInsertMark*(hwnd: HWND, hItem: HTREEITEM, fAfter: BOOL): BOOL = discardable BOOL SendMessage(hwnd, TVM_SETINSERTMARK, cast[WPARAM](fAfter), cast[LPARAM](hItem))
template TreeView_SetItem*(hwnd: HWND, pitem: LPTVITEM): BOOL = discardable BOOL SendMessage(hwnd, TVM_SETITEM, 0, cast[LPARAM](pitem))
template TreeView_SetTextColor*(hwnd: HWND, clr: COLORREF): COLORREF = discardable COLORREF SendMessage(hwnd, TVM_SETTEXTCOLOR, 0, cast[LPARAM](clr))
template TreeView_SortChildren*(hwnd: HWND, hitem: HTREEITEM, recurse: BOOL): BOOL = discardable BOOL SendMessage(hwnd, TVM_SORTCHILDREN, cast[WPARAM](recurse), cast[LPARAM](hitem))
template TreeView_SortChildrenCB*(hwnd: HWND, psort: LPTVSORTCB, recurse: BOOL): BOOL = discardable BOOL SendMessage(hwnd, TVM_SORTCHILDRENCB, cast[WPARAM](recurse), cast[LPARAM](psort))
proc `itemex=`*(self: var TVINSERTSTRUCTA, x: TVITEMEXA) {.inline.} = self.union1.itemex = x
proc itemex*(self: TVINSERTSTRUCTA): TVITEMEXA {.inline.} = self.union1.itemex
proc itemex*(self: var TVINSERTSTRUCTA): var TVITEMEXA {.inline.} = self.union1.itemex
proc `item=`*(self: var TVINSERTSTRUCTA, x: TV_ITEMA) {.inline.} = self.union1.item = x
proc item*(self: TVINSERTSTRUCTA): TV_ITEMA {.inline.} = self.union1.item
proc item*(self: var TVINSERTSTRUCTA): var TV_ITEMA {.inline.} = self.union1.item
proc `itemex=`*(self: var TVINSERTSTRUCTW, x: TVITEMEXW) {.inline.} = self.union1.itemex = x
proc itemex*(self: TVINSERTSTRUCTW): TVITEMEXW {.inline.} = self.union1.itemex
proc itemex*(self: var TVINSERTSTRUCTW): var TVITEMEXW {.inline.} = self.union1.itemex
proc `item=`*(self: var TVINSERTSTRUCTW, x: TV_ITEMW) {.inline.} = self.union1.item = x
proc item*(self: TVINSERTSTRUCTW): TV_ITEMW {.inline.} = self.union1.item
proc item*(self: var TVINSERTSTRUCTW): var TV_ITEMW {.inline.} = self.union1.item
when winimUnicode:
  type
    LPNMLVDISPINFO* = LPNMLVDISPINFOW
    LPNMHEADER* = LPNMHEADERW
    TBBUTTONINFO* = TBBUTTONINFOW
    REBARBANDINFO* = REBARBANDINFOW
    LVITEM* = LVITEMW
    LVCOLUMN* = LVCOLUMNW
    TVINSERTSTRUCT* = TVINSERTSTRUCTW
    LPNMTREEVIEW* = LPNMTREEVIEWW
    LPNMTVDISPINFO* = LPNMTVDISPINFOW
    TCITEM* = TCITEMW
  const
    HDN_ITEMCHANGING* = HDN_ITEMCHANGINGW
    HDN_BEGINTRACK* = HDN_BEGINTRACKW
    HDN_ENDTRACK* = HDN_ENDTRACKW
    TOOLBARCLASSNAME* = TOOLBARCLASSNAMEW
    TB_GETBUTTONINFO* = TB_GETBUTTONINFOW
    TB_INSERTBUTTON* = TB_INSERTBUTTONW
    REBARCLASSNAME* = REBARCLASSNAMEW
    RB_INSERTBAND* = RB_INSERTBANDW
    TOOLTIPS_CLASS* = TOOLTIPS_CLASSW
    TTM_ADDTOOL* = TTM_ADDTOOLW
    TTM_GETTEXT* = TTM_GETTEXTW
    STATUSCLASSNAME* = STATUSCLASSNAMEW
    SB_GETTEXT* = SB_GETTEXTW
    SB_SETTEXT* = SB_SETTEXTW
    SB_GETTEXTLENGTH* = SB_GETTEXTLENGTHW
    TRACKBAR_CLASS* = TRACKBAR_CLASSW
    UPDOWN_CLASS* = UPDOWN_CLASSW
    PROGRESS_CLASS* = PROGRESS_CLASSW
    WC_LISTVIEW* = WC_LISTVIEWW
    LVN_BEGINLABELEDIT* = LVN_BEGINLABELEDITW
    LVN_ENDLABELEDIT* = LVN_ENDLABELEDITW
    WC_TREEVIEW* = WC_TREEVIEWW
    TVN_SELCHANGING* = TVN_SELCHANGINGW
    TVN_SELCHANGED* = TVN_SELCHANGEDW
    TVN_ITEMEXPANDING* = TVN_ITEMEXPANDINGW
    TVN_ITEMEXPANDED* = TVN_ITEMEXPANDEDW
    TVN_BEGINDRAG* = TVN_BEGINDRAGW
    TVN_BEGINRDRAG* = TVN_BEGINRDRAGW
    TVN_DELETEITEM* = TVN_DELETEITEMW
    TVN_BEGINLABELEDIT* = TVN_BEGINLABELEDITW
    TVN_ENDLABELEDIT* = TVN_ENDLABELEDITW
    WC_TABCONTROL* = WC_TABCONTROLW
    MONTHCAL_CLASS* = MONTHCAL_CLASSW
    DATETIMEPICK_CLASS* = DATETIMEPICK_CLASSW
    WC_IPADDRESS* = WC_IPADDRESSW
    WC_BUTTON* = WC_BUTTONW
    WC_STATIC* = WC_STATICW
    WC_EDIT* = WC_EDITW
    WC_LISTBOX* = WC_LISTBOXW
    WC_COMBOBOX* = WC_COMBOBOXW
    WC_SCROLLBAR* = WC_SCROLLBARW
when winimAnsi:
  type
    LPNMLVDISPINFO* = LPNMLVDISPINFOA
    LPNMHEADER* = LPNMHEADERA
    TBBUTTONINFO* = TBBUTTONINFOA
    REBARBANDINFO* = REBARBANDINFOA
    LVITEM* = LVITEMA
    LVCOLUMN* = LVCOLUMNA
    TVINSERTSTRUCT* = TVINSERTSTRUCTA
    LPNMTREEVIEW* = LPNMTREEVIEWA
    LPNMTVDISPINFO* = LPNMTVDISPINFOA
    TCITEM* = TCITEMA
  const
    HDN_ITEMCHANGING* = HDN_ITEMCHANGINGA
    HDN_BEGINTRACK* = HDN_BEGINTRACKA
    HDN_ENDTRACK* = HDN_ENDTRACKA
    TOOLBARCLASSNAME* = TOOLBARCLASSNAMEA
    TB_GETBUTTONINFO* = TB_GETBUTTONINFOA
    TB_INSERTBUTTON* = TB_INSERTBUTTONA
    REBARCLASSNAME* = REBARCLASSNAMEA
    RB_INSERTBAND* = RB_INSERTBANDA
    TOOLTIPS_CLASS* = TOOLTIPS_CLASSA
    TTM_ADDTOOL* = TTM_ADDTOOLA
    TTM_GETTEXT* = TTM_GETTEXTA
    STATUSCLASSNAME* = STATUSCLASSNAMEA
    SB_GETTEXT* = SB_GETTEXTA
    SB_SETTEXT* = SB_SETTEXTA
    SB_GETTEXTLENGTH* = SB_GETTEXTLENGTHA
    TRACKBAR_CLASS* = TRACKBAR_CLASSA
    UPDOWN_CLASS* = UPDOWN_CLASSA
    PROGRESS_CLASS* = PROGRESS_CLASSA
    WC_LISTVIEW* = WC_LISTVIEWA
    LVN_BEGINLABELEDIT* = LVN_BEGINLABELEDITA
    LVN_ENDLABELEDIT* = LVN_ENDLABELEDITA
    WC_TREEVIEW* = WC_TREEVIEWA
    TVN_SELCHANGING* = TVN_SELCHANGINGA
    TVN_SELCHANGED* = TVN_SELCHANGEDA
    TVN_ITEMEXPANDING* = TVN_ITEMEXPANDINGA
    TVN_ITEMEXPANDED* = TVN_ITEMEXPANDEDA
    TVN_BEGINDRAG* = TVN_BEGINDRAGA
    TVN_BEGINRDRAG* = TVN_BEGINRDRAGA
    TVN_DELETEITEM* = TVN_DELETEITEMA
    TVN_BEGINLABELEDIT* = TVN_BEGINLABELEDITA
    TVN_ENDLABELEDIT* = TVN_ENDLABELEDITA
    WC_TABCONTROL* = WC_TABCONTROLA
    MONTHCAL_CLASS* = MONTHCAL_CLASSA
    DATETIMEPICK_CLASS* = DATETIMEPICK_CLASSA
    WC_IPADDRESS* = WC_IPADDRESSA
    WC_BUTTON* = WC_BUTTONA
    WC_STATIC* = WC_STATICA
    WC_EDIT* = WC_EDITA
    WC_LISTBOX* = WC_LISTBOXA
    WC_COMBOBOX* = WC_COMBOBOXA
    WC_SCROLLBAR* = WC_SCROLLBARA
type
  LPOFNHOOKPROC* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): UINT_PTR {.stdcall.}
  OPENFILENAMEA* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hInstance*: HINSTANCE
    lpstrFilter*: LPCSTR
    lpstrCustomFilter*: LPSTR
    nMaxCustFilter*: DWORD
    nFilterIndex*: DWORD
    lpstrFile*: LPSTR
    nMaxFile*: DWORD
    lpstrFileTitle*: LPSTR
    nMaxFileTitle*: DWORD
    lpstrInitialDir*: LPCSTR
    lpstrTitle*: LPCSTR
    Flags*: DWORD
    nFileOffset*: WORD
    nFileExtension*: WORD
    lpstrDefExt*: LPCSTR
    lCustData*: LPARAM
    lpfnHook*: LPOFNHOOKPROC
    lpTemplateName*: LPCSTR
    pvReserved*: pointer
    dwReserved*: DWORD
    FlagsEx*: DWORD
  LPOPENFILENAMEA* = ptr OPENFILENAMEA
  OPENFILENAMEW* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hInstance*: HINSTANCE
    lpstrFilter*: LPCWSTR
    lpstrCustomFilter*: LPWSTR
    nMaxCustFilter*: DWORD
    nFilterIndex*: DWORD
    lpstrFile*: LPWSTR
    nMaxFile*: DWORD
    lpstrFileTitle*: LPWSTR
    nMaxFileTitle*: DWORD
    lpstrInitialDir*: LPCWSTR
    lpstrTitle*: LPCWSTR
    Flags*: DWORD
    nFileOffset*: WORD
    nFileExtension*: WORD
    lpstrDefExt*: LPCWSTR
    lCustData*: LPARAM
    lpfnHook*: LPOFNHOOKPROC
    lpTemplateName*: LPCWSTR
    pvReserved*: pointer
    dwReserved*: DWORD
    FlagsEx*: DWORD
  LPOPENFILENAMEW* = ptr OPENFILENAMEW
  LPCCHOOKPROC* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): UINT_PTR {.stdcall.}
  TCHOOSECOLORA* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hInstance*: HWND
    rgbResult*: COLORREF
    lpCustColors*: ptr COLORREF
    Flags*: DWORD
    lCustData*: LPARAM
    lpfnHook*: LPCCHOOKPROC
    lpTemplateName*: LPCSTR
  LPCHOOSECOLORA* = ptr TCHOOSECOLORA
  TCHOOSECOLORW* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hInstance*: HWND
    rgbResult*: COLORREF
    lpCustColors*: ptr COLORREF
    Flags*: DWORD
    lCustData*: LPARAM
    lpfnHook*: LPCCHOOKPROC
    lpTemplateName*: LPCWSTR
  LPCHOOSECOLORW* = ptr TCHOOSECOLORW
const
  OFN_OVERWRITEPROMPT* = 0x2
  OFN_ENABLEHOOK* = 0x20
  OFN_ALLOWMULTISELECT* = 0x200
  OFN_FILEMUSTEXIST* = 0x1000
  OFN_CREATEPROMPT* = 0x2000
  OFN_EXPLORER* = 0x80000
  OFN_NODEREFERENCELINKS* = 0x100000
  CC_RGBINIT* = 0x1
  CC_FULLOPEN* = 0x2
  CC_ENABLEHOOK* = 0x10
  CC_ANYCOLOR* = 0x100
when winimUnicode:
  type
    OPENFILENAME* = OPENFILENAMEW
    TCHOOSECOLOR* = TCHOOSECOLORW
  proc GetOpenFileName*(P1: LPOPENFILENAMEW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetOpenFileNameW".}
  proc GetSaveFileName*(P1: LPOPENFILENAMEW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetSaveFileNameW".}
  proc ChooseColor*(P1: LPCHOOSECOLORW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "ChooseColorW".}
when winimAnsi:
  type
    OPENFILENAME* = OPENFILENAMEA
    TCHOOSECOLOR* = TCHOOSECOLORA
  proc GetOpenFileName*(P1: LPOPENFILENAMEA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetOpenFileNameA".}
  proc GetSaveFileName*(P1: LPOPENFILENAMEA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetSaveFileNameA".}
  proc ChooseColor*(P1: LPCHOOSECOLORA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "ChooseColorA".}
type
  CHARRANGE* {.pure.} = object
    cpMin*: LONG
    cpMax*: LONG
const
  MSFTEDIT_CLASS* = "RICHEDIT50W"
  EM_EXLIMITTEXT* = WM_USER+53
  EM_EXLINEFROMCHAR* = WM_USER+54
  EM_SETBKGNDCOLOR* = WM_USER+67
  EM_SETCHARFORMAT* = WM_USER+68
  EM_SETEVENTMASK* = WM_USER+69
  EM_SETPARAFORMAT* = WM_USER+71
  EM_GETTEXTRANGE* = WM_USER+75
  EM_REDO* = WM_USER+84
  EM_CANREDO* = WM_USER+85
  EM_GETTEXTLENGTHEX* = WM_USER+95
  EN_REQUESTRESIZE* = 0x0701
  ENM_CHANGE* = 0x00000001
  ENM_UPDATE* = 0x00000002
  ENM_REQUESTRESIZE* = 0x00040000
  CFM_BOLD* = 0x00000001
  CFM_ITALIC* = 0x00000002
  CFM_UNDERLINE* = 0x00000004
  CFM_STRIKEOUT* = 0x00000008
  CFM_LINK* = 0x00000020
  CFM_SIZE* = 0x80000000'i32
  CFM_COLOR* = 0x40000000
  CFM_FACE* = 0x20000000
  CFM_CHARSET* = 0x08000000
  CFE_UNDERLINE* = 0x00000004
  CFE_PROTECTED* = 0x00000010
  CFM_WEIGHT* = 0x00400000
  CFM_EFFECTS* = CFM_BOLD or CFM_ITALIC or CFM_UNDERLINE or CFM_COLOR or CFM_STRIKEOUT or CFE_PROTECTED or CFM_LINK
  SCF_DEFAULT* = 0x0000
  MAX_TAB_STOPS* = 32
  PFM_LINESPACING* = 0x00000100
  GTL_DEFAULT* = 0
type
  CHARFORMAT2W_UNION1* {.pure, union.} = object
    dwReserved*: DWORD
    dwCookie*: DWORD
  CHARFORMAT2W* {.pure.} = object
    cbSize*: UINT
    dwMask*: DWORD
    dwEffects*: DWORD
    yHeight*: LONG
    yOffset*: LONG
    crTextColor*: COLORREF
    bCharSet*: BYTE
    bPitchAndFamily*: BYTE
    szFaceName*: array[LF_FACESIZE, WCHAR]
    wWeight*: WORD
    sSpacing*: SHORT
    crBackColor*: COLORREF
    lcid*: LCID
    union1*: CHARFORMAT2W_UNION1
    sStyle*: SHORT
    wKerning*: WORD
    bUnderlineType*: BYTE
    bAnimation*: BYTE
    bRevAuthor*: BYTE
    bUnderlineColor*: BYTE
  CHARFORMAT2A_UNION1* {.pure, union.} = object
    dwReserved*: DWORD
    dwCookie*: DWORD
  CHARFORMAT2A* {.pure.} = object
    cbSize*: UINT
    dwMask*: DWORD
    dwEffects*: DWORD
    yHeight*: LONG
    yOffset*: LONG
    crTextColor*: COLORREF
    bCharSet*: BYTE
    bPitchAndFamily*: BYTE
    szFaceName*: array[LF_FACESIZE, char]
    wWeight*: WORD
    sSpacing*: SHORT
    crBackColor*: COLORREF
    lcid*: LCID
    union1*: CHARFORMAT2A_UNION1
    sStyle*: SHORT
    wKerning*: WORD
    bUnderlineType*: BYTE
    bAnimation*: BYTE
    bRevAuthor*: BYTE
    bUnderlineColor*: BYTE
  TEXTRANGEA* {.pure.} = object
    chrg*: CHARRANGE
    lpstrText*: LPSTR
  TEXTRANGEW* {.pure.} = object
    chrg*: CHARRANGE
    lpstrText*: LPWSTR
  PARAFORMAT2_UNION1* {.pure, union.} = object
    wReserved*: WORD
    wEffects*: WORD
  PARAFORMAT2* {.pure.} = object
    cbSize*: UINT
    dwMask*: DWORD
    wNumbering*: WORD
    union1*: PARAFORMAT2_UNION1
    dxStartIndent*: LONG
    dxRightIndent*: LONG
    dxOffset*: LONG
    wAlignment*: WORD
    cTabCount*: SHORT
    rgxTabs*: array[MAX_TAB_STOPS, LONG]
    dySpaceBefore*: LONG
    dySpaceAfter*: LONG
    dyLineSpacing*: LONG
    sStyle*: SHORT
    bLineSpacingRule*: BYTE
    bOutlineLevel*: BYTE
    wShadingWeight*: WORD
    wShadingStyle*: WORD
    wNumberingStart*: WORD
    wNumberingStyle*: WORD
    wNumberingTab*: WORD
    wBorderSpace*: WORD
    wBorderWidth*: WORD
    wBorders*: WORD
  REQRESIZE* {.pure.} = object
    nmhdr*: NMHDR
    rc*: RECT
  GETTEXTLENGTHEX* {.pure.} = object
    flags*: DWORD
    codepage*: UINT
proc `dwReserved=`*(self: var CHARFORMAT2W, x: DWORD) {.inline.} = self.union1.dwReserved = x
proc dwReserved*(self: CHARFORMAT2W): DWORD {.inline.} = self.union1.dwReserved
proc dwReserved*(self: var CHARFORMAT2W): var DWORD {.inline.} = self.union1.dwReserved
proc `dwCookie=`*(self: var CHARFORMAT2W, x: DWORD) {.inline.} = self.union1.dwCookie = x
proc dwCookie*(self: CHARFORMAT2W): DWORD {.inline.} = self.union1.dwCookie
proc dwCookie*(self: var CHARFORMAT2W): var DWORD {.inline.} = self.union1.dwCookie
proc `dwReserved=`*(self: var CHARFORMAT2A, x: DWORD) {.inline.} = self.union1.dwReserved = x
proc dwReserved*(self: CHARFORMAT2A): DWORD {.inline.} = self.union1.dwReserved
proc dwReserved*(self: var CHARFORMAT2A): var DWORD {.inline.} = self.union1.dwReserved
proc `dwCookie=`*(self: var CHARFORMAT2A, x: DWORD) {.inline.} = self.union1.dwCookie = x
proc dwCookie*(self: CHARFORMAT2A): DWORD {.inline.} = self.union1.dwCookie
proc dwCookie*(self: var CHARFORMAT2A): var DWORD {.inline.} = self.union1.dwCookie
proc `wReserved=`*(self: var PARAFORMAT2, x: WORD) {.inline.} = self.union1.wReserved = x
proc wReserved*(self: PARAFORMAT2): WORD {.inline.} = self.union1.wReserved
proc wReserved*(self: var PARAFORMAT2): var WORD {.inline.} = self.union1.wReserved
proc `wEffects=`*(self: var PARAFORMAT2, x: WORD) {.inline.} = self.union1.wEffects = x
proc wEffects*(self: PARAFORMAT2): WORD {.inline.} = self.union1.wEffects
proc wEffects*(self: var PARAFORMAT2): var WORD {.inline.} = self.union1.wEffects
when winimUnicode:
  type
    CHARFORMAT2* = CHARFORMAT2W
    TEXTRANGE* = TEXTRANGEW
when winimAnsi:
  type
    CHARFORMAT2* = CHARFORMAT2A
    TEXTRANGE* = TEXTRANGEA
type
  SIGDN* = int32
  SIATTRIBFLAGS* = int32
  THUMBBUTTONFLAGS* = int32
  THUMBBUTTONMASK* = int32
  TBPFLAG* = int32
  FDE_OVERWRITE_RESPONSE* = int32
  FDE_SHAREVIOLATION_RESPONSE* = int32
  FDAP* = int32
  HDROP* = HANDLE
  SHCONTF* = DWORD
  SFGAOF* = ULONG
  SICHINTF* = DWORD
  FILEOPENDIALOGOPTIONS* = DWORD
  HTHEME* = HANDLE
  NOTIFYICONDATAA_UNION1* {.pure, union.} = object
    uTimeout*: UINT
    uVersion*: UINT
  NOTIFYICONDATAA* {.pure.} = object
    cbSize*: DWORD
    hWnd*: HWND
    uID*: UINT
    uFlags*: UINT
    uCallbackMessage*: UINT
    hIcon*: HICON
    szTip*: array[128, CHAR]
    dwState*: DWORD
    dwStateMask*: DWORD
    szInfo*: array[256, CHAR]
    union1*: NOTIFYICONDATAA_UNION1
    szInfoTitle*: array[64, CHAR]
    dwInfoFlags*: DWORD
    guidItem*: GUID
    hBalloonIcon*: HICON
  PNOTIFYICONDATAA* = ptr NOTIFYICONDATAA
  NOTIFYICONDATAW_UNION1* {.pure, union.} = object
    uTimeout*: UINT
    uVersion*: UINT
  NOTIFYICONDATAW* {.pure.} = object
    cbSize*: DWORD
    hWnd*: HWND
    uID*: UINT
    uFlags*: UINT
    uCallbackMessage*: UINT
    hIcon*: HICON
    szTip*: array[128, WCHAR]
    dwState*: DWORD
    dwStateMask*: DWORD
    szInfo*: array[256, WCHAR]
    union1*: NOTIFYICONDATAW_UNION1
    szInfoTitle*: array[64, WCHAR]
    dwInfoFlags*: DWORD
    guidItem*: GUID
    hBalloonIcon*: HICON
  PNOTIFYICONDATAW* = ptr NOTIFYICONDATAW
  THUMBBUTTON* {.pure.} = object
    dwMask*: THUMBBUTTONMASK
    iId*: UINT
    iBitmap*: UINT
    hIcon*: HICON
    szTip*: array[260, WCHAR]
    dwFlags*: THUMBBUTTONFLAGS
  LPTHUMBBUTTON* = ptr THUMBBUTTON
  BFFCALLBACK* = proc (hwnd: HWND, uMsg: UINT, lParam: LPARAM, lpData: LPARAM): int32 {.stdcall.}
  BROWSEINFOA* {.pure.} = object
    hwndOwner*: HWND
    pidlRoot*: PCIDLIST_ABSOLUTE
    pszDisplayName*: LPSTR
    lpszTitle*: LPCSTR
    ulFlags*: UINT
    lpfn*: BFFCALLBACK
    lParam*: LPARAM
    iImage*: int32
  LPBROWSEINFOA* = ptr BROWSEINFOA
  BROWSEINFOW* {.pure.} = object
    hwndOwner*: HWND
    pidlRoot*: PCIDLIST_ABSOLUTE
    pszDisplayName*: LPWSTR
    lpszTitle*: LPCWSTR
    ulFlags*: UINT
    lpfn*: BFFCALLBACK
    lParam*: LPARAM
    iImage*: int32
  LPBROWSEINFOW* = ptr BROWSEINFOW
const
  NIN_BALLOONTIMEOUT* = WM_USER+4
  NIN_BALLOONUSERCLICK* = WM_USER+5
  NIM_ADD* = 0x00000000
  NIM_MODIFY* = 0x00000001
  NIM_DELETE* = 0x00000002
  NIM_SETVERSION* = 0x00000004
  NIF_MESSAGE* = 0x00000001
  NIF_ICON* = 0x00000002
  NIF_TIP* = 0x00000004
  NIF_INFO* = 0x00000010
  NIIF_NONE* = 0x00000000
  NIIF_INFO* = 0x00000001
  NIIF_WARNING* = 0x00000002
  NIIF_ERROR* = 0x00000003
  SIGDN_FILESYSPATH* = int32 0x80058000'i32
  IID_IShellItem* = DEFINE_GUID(0x43826d1e'i32, 0xe718, 0x42ee, [0xbc'u8, 0x55, 0xa1, 0xe2, 0x61, 0xc3, 0x7b, 0xfe])
  TBPF_NOPROGRESS* = 0x0
  TBPF_INDETERMINATE* = 0x1
  TBPF_NORMAL* = 0x2
  TBPF_ERROR* = 0x4
  TBPF_PAUSED* = 0x8
  IID_ITaskbarList3* = DEFINE_GUID(0xea1afb91'i32, 0x9e28, 0x4b86, [0x90'u8, 0xe9, 0x9e, 0x9f, 0x8a, 0x5e, 0xef, 0xaf])
  FOS_PICKFOLDERS* = 0x20
  FOS_FORCEFILESYSTEM* = 0x40
  IID_IFileOpenDialog* = DEFINE_GUID(0xd57c7288'i32, 0xd4ad, 0x4768, [0xbe'u8, 0x02, 0x9d, 0x96, 0x95, 0x32, 0xd9, 0x60])
  CLSID_TaskbarList* = DEFINE_GUID(0x56fdf344'i32, 0xfd6d, 0x11d0, [0x95'u8, 0x8a, 0x00, 0x60, 0x97, 0xc9, 0xa0, 0x90])
  CLSID_FileOpenDialog* = DEFINE_GUID(0xdc1c5a9c'i32, 0xe88a, 0x4dde, [0xa5'u8, 0xa1, 0x60, 0xf8, 0x2a, 0x20, 0xae, 0xf7])
type
  Shell* {.pure.} = object
const
  CSIDL_DESKTOP* = 0x0000
  BIF_RETURNONLYFSDIRS* = 0x00000001
  BIF_EDITBOX* = 0x00000010
  BIF_NEWDIALOGSTYLE* = 0x00000040
  BIF_USENEWUI* = BIF_NEWDIALOGSTYLE or BIF_EDITBOX
  BIF_NONEWFOLDERBUTTON* = 0x00000200
  BFFM_INITIALIZED* = 1
  BFFM_SETSELECTIONA* = WM_USER+102
  BFFM_SETSELECTIONW* = WM_USER+103
type
  DLLVERSIONINFO* {.pure.} = object
    cbSize*: DWORD
    dwMajorVersion*: DWORD
    dwMinorVersion*: DWORD
    dwBuildNumber*: DWORD
    dwPlatformID*: DWORD
  DLLGETVERSIONPROC* = proc (P1: ptr DLLVERSIONINFO): HRESULT {.stdcall.}
  IShellItem* {.pure.} = object
    lpVtbl*: ptr IShellItemVtbl
  IShellItemVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    BindToHandler*: proc(self: ptr IShellItem, pbc: ptr IBindCtx, bhid: REFGUID, riid: REFIID, ppv: ptr pointer): HRESULT {.stdcall.}
    GetParent*: proc(self: ptr IShellItem, ppsi: ptr ptr IShellItem): HRESULT {.stdcall.}
    GetDisplayName*: proc(self: ptr IShellItem, sigdnName: SIGDN, ppszName: ptr LPWSTR): HRESULT {.stdcall.}
    GetAttributes*: proc(self: ptr IShellItem, sfgaoMask: SFGAOF, psfgaoAttribs: ptr SFGAOF): HRESULT {.stdcall.}
    Compare*: proc(self: ptr IShellItem, psi: ptr IShellItem, hint: SICHINTF, piOrder: ptr int32): HRESULT {.stdcall.}
  IEnumShellItems* {.pure.} = object
    lpVtbl*: ptr IEnumShellItemsVtbl
  IEnumShellItemsVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumShellItems, celt: ULONG, rgelt: ptr ptr IShellItem, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumShellItems, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumShellItems): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumShellItems, ppenum: ptr ptr IEnumShellItems): HRESULT {.stdcall.}
  IShellItemArray* {.pure.} = object
    lpVtbl*: ptr IShellItemArrayVtbl
  IShellItemArrayVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    BindToHandler*: proc(self: ptr IShellItemArray, pbc: ptr IBindCtx, bhid: REFGUID, riid: REFIID, ppvOut: ptr pointer): HRESULT {.stdcall.}
    GetPropertyStore*: proc(self: ptr IShellItemArray, flags: GETPROPERTYSTOREFLAGS, riid: REFIID, ppv: ptr pointer): HRESULT {.stdcall.}
    GetPropertyDescriptionList*: proc(self: ptr IShellItemArray, keyType: REFPROPERTYKEY, riid: REFIID, ppv: ptr pointer): HRESULT {.stdcall.}
    GetAttributes*: proc(self: ptr IShellItemArray, AttribFlags: SIATTRIBFLAGS, sfgaoMask: SFGAOF, psfgaoAttribs: ptr SFGAOF): HRESULT {.stdcall.}
    GetCount*: proc(self: ptr IShellItemArray, pdwNumItems: ptr DWORD): HRESULT {.stdcall.}
    GetItemAt*: proc(self: ptr IShellItemArray, dwIndex: DWORD, ppsi: ptr ptr IShellItem): HRESULT {.stdcall.}
    EnumItems*: proc(self: ptr IShellItemArray, ppenumShellItems: ptr ptr IEnumShellItems): HRESULT {.stdcall.}
  ITaskbarList* {.pure.} = object
    lpVtbl*: ptr ITaskbarListVtbl
  ITaskbarListVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    HrInit*: proc(self: ptr ITaskbarList): HRESULT {.stdcall.}
    AddTab*: proc(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.stdcall.}
    DeleteTab*: proc(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.stdcall.}
    ActivateTab*: proc(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.stdcall.}
    SetActiveAlt*: proc(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.stdcall.}
  ITaskbarList2* {.pure.} = object
    lpVtbl*: ptr ITaskbarList2Vtbl
  ITaskbarList2Vtbl* {.pure, inheritable.} = object of ITaskbarListVtbl
    MarkFullscreenWindow*: proc(self: ptr ITaskbarList2, hwnd: HWND, fFullscreen: WINBOOL): HRESULT {.stdcall.}
  ITaskbarList3* {.pure.} = object
    lpVtbl*: ptr ITaskbarList3Vtbl
  ITaskbarList3Vtbl* {.pure, inheritable.} = object of ITaskbarList2Vtbl
    SetProgressValue*: proc(self: ptr ITaskbarList3, hwnd: HWND, ullCompleted: ULONGLONG, ullTotal: ULONGLONG): HRESULT {.stdcall.}
    SetProgressState*: proc(self: ptr ITaskbarList3, hwnd: HWND, tbpFlags: TBPFLAG): HRESULT {.stdcall.}
    RegisterTab*: proc(self: ptr ITaskbarList3, hwndTab: HWND, hwndMDI: HWND): HRESULT {.stdcall.}
    UnregisterTab*: proc(self: ptr ITaskbarList3, hwndTab: HWND): HRESULT {.stdcall.}
    SetTabOrder*: proc(self: ptr ITaskbarList3, hwndTab: HWND, hwndInsertBefore: HWND): HRESULT {.stdcall.}
    SetTabActive*: proc(self: ptr ITaskbarList3, hwndTab: HWND, hwndMDI: HWND, dwReserved: DWORD): HRESULT {.stdcall.}
    ThumbBarAddButtons*: proc(self: ptr ITaskbarList3, hwnd: HWND, cButtons: UINT, pButton: LPTHUMBBUTTON): HRESULT {.stdcall.}
    ThumbBarUpdateButtons*: proc(self: ptr ITaskbarList3, hwnd: HWND, cButtons: UINT, pButton: LPTHUMBBUTTON): HRESULT {.stdcall.}
    ThumbBarSetImageList*: proc(self: ptr ITaskbarList3, hwnd: HWND, himl: HIMAGELIST): HRESULT {.stdcall.}
    SetOverlayIcon*: proc(self: ptr ITaskbarList3, hwnd: HWND, hIcon: HICON, pszDescription: LPCWSTR): HRESULT {.stdcall.}
    SetThumbnailTooltip*: proc(self: ptr ITaskbarList3, hwnd: HWND, pszTip: LPCWSTR): HRESULT {.stdcall.}
    SetThumbnailClip*: proc(self: ptr ITaskbarList3, hwnd: HWND, prcClip: ptr RECT): HRESULT {.stdcall.}
  IModalWindow* {.pure.} = object
    lpVtbl*: ptr IModalWindowVtbl
  IModalWindowVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Show*: proc(self: ptr IModalWindow, hwndOwner: HWND): HRESULT {.stdcall.}
  IShellItemFilter* {.pure.} = object
    lpVtbl*: ptr IShellItemFilterVtbl
  IShellItemFilterVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    IncludeItem*: proc(self: ptr IShellItemFilter, psi: ptr IShellItem): HRESULT {.stdcall.}
    GetEnumFlagsForItem*: proc(self: ptr IShellItemFilter, psi: ptr IShellItem, pgrfFlags: ptr SHCONTF): HRESULT {.stdcall.}
  IFileDialog* {.pure.} = object
    lpVtbl*: ptr IFileDialogVtbl
  IFileDialogVtbl* {.pure, inheritable.} = object of IModalWindowVtbl
    SetFileTypes*: proc(self: ptr IFileDialog, cFileTypes: UINT, rgFilterSpec: ptr COMDLG_FILTERSPEC): HRESULT {.stdcall.}
    SetFileTypeIndex*: proc(self: ptr IFileDialog, iFileType: UINT): HRESULT {.stdcall.}
    GetFileTypeIndex*: proc(self: ptr IFileDialog, piFileType: ptr UINT): HRESULT {.stdcall.}
    Advise*: proc(self: ptr IFileDialog, pfde: ptr IFileDialogEvents, pdwCookie: ptr DWORD): HRESULT {.stdcall.}
    Unadvise*: proc(self: ptr IFileDialog, dwCookie: DWORD): HRESULT {.stdcall.}
    SetOptions*: proc(self: ptr IFileDialog, fos: FILEOPENDIALOGOPTIONS): HRESULT {.stdcall.}
    GetOptions*: proc(self: ptr IFileDialog, pfos: ptr FILEOPENDIALOGOPTIONS): HRESULT {.stdcall.}
    SetDefaultFolder*: proc(self: ptr IFileDialog, psi: ptr IShellItem): HRESULT {.stdcall.}
    SetFolder*: proc(self: ptr IFileDialog, psi: ptr IShellItem): HRESULT {.stdcall.}
    GetFolder*: proc(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.stdcall.}
    GetCurrentSelection*: proc(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.stdcall.}
    SetFileName*: proc(self: ptr IFileDialog, pszName: LPCWSTR): HRESULT {.stdcall.}
    GetFileName*: proc(self: ptr IFileDialog, pszName: ptr LPWSTR): HRESULT {.stdcall.}
    SetTitle*: proc(self: ptr IFileDialog, pszTitle: LPCWSTR): HRESULT {.stdcall.}
    SetOkButtonLabel*: proc(self: ptr IFileDialog, pszText: LPCWSTR): HRESULT {.stdcall.}
    SetFileNameLabel*: proc(self: ptr IFileDialog, pszLabel: LPCWSTR): HRESULT {.stdcall.}
    GetResult*: proc(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.stdcall.}
    AddPlace*: proc(self: ptr IFileDialog, psi: ptr IShellItem, fdap: FDAP): HRESULT {.stdcall.}
    SetDefaultExtension*: proc(self: ptr IFileDialog, pszDefaultExtension: LPCWSTR): HRESULT {.stdcall.}
    Close*: proc(self: ptr IFileDialog, hr: HRESULT): HRESULT {.stdcall.}
    SetClientGuid*: proc(self: ptr IFileDialog, guid: REFGUID): HRESULT {.stdcall.}
    ClearClientData*: proc(self: ptr IFileDialog): HRESULT {.stdcall.}
    SetFilter*: proc(self: ptr IFileDialog, pFilter: ptr IShellItemFilter): HRESULT {.stdcall.}
  IFileDialogEvents* {.pure.} = object
    lpVtbl*: ptr IFileDialogEventsVtbl
  IFileDialogEventsVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    OnFileOk*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.stdcall.}
    OnFolderChanging*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psiFolder: ptr IShellItem): HRESULT {.stdcall.}
    OnFolderChange*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.stdcall.}
    OnSelectionChange*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.stdcall.}
    OnShareViolation*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psi: ptr IShellItem, pResponse: ptr FDE_SHAREVIOLATION_RESPONSE): HRESULT {.stdcall.}
    OnTypeChange*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.stdcall.}
    OnOverwrite*: proc(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psi: ptr IShellItem, pResponse: ptr FDE_OVERWRITE_RESPONSE): HRESULT {.stdcall.}
  IFileOpenDialog* {.pure.} = object
    lpVtbl*: ptr IFileOpenDialogVtbl
  IFileOpenDialogVtbl* {.pure, inheritable.} = object of IFileDialogVtbl
    GetResults*: proc(self: ptr IFileOpenDialog, ppenum: ptr ptr IShellItemArray): HRESULT {.stdcall.}
    GetSelectedItems*: proc(self: ptr IFileOpenDialog, ppsai: ptr ptr IShellItemArray): HRESULT {.stdcall.}
proc SHCreateItemFromParsingName*(pszPath: PCWSTR, pbc: ptr IBindCtx, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, stdcall, dynlib: "shell32", importc.}
proc ILFree*(pidl: PIDLIST_RELATIVE): void {.winapi, stdcall, dynlib: "shell32", importc.}
proc SHGetSpecialFolderLocation*(hwnd: HWND, csidl: int32, ppidl: ptr PIDLIST_ABSOLUTE): HRESULT {.winapi, stdcall, dynlib: "shell32", importc.}
proc SHCreateDataObject*(pidlFolder: PCIDLIST_ABSOLUTE, cidl: UINT, apidl: PCUITEMID_CHILD_ARRAY, pdtInner: ptr IDataObject, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, stdcall, dynlib: "shell32", importc.}
proc SHCreateStdEnumFmtEtc*(cfmt: UINT, afmt: ptr FORMATETC, ppenumFormatEtc: ptr ptr IEnumFORMATETC): HRESULT {.winapi, stdcall, dynlib: "shell32", importc.}
proc SHDoDragDrop*(hwnd: HWND, pdata: ptr IDataObject, pdsrc: ptr IDropSource, dwEffect: DWORD, pdwEffect: ptr DWORD): HRESULT {.winapi, stdcall, dynlib: "shell32", importc.}
proc `uTimeout=`*(self: var NOTIFYICONDATAA, x: UINT) {.inline.} = self.union1.uTimeout = x
proc uTimeout*(self: NOTIFYICONDATAA): UINT {.inline.} = self.union1.uTimeout
proc uTimeout*(self: var NOTIFYICONDATAA): var UINT {.inline.} = self.union1.uTimeout
proc `uVersion=`*(self: var NOTIFYICONDATAA, x: UINT) {.inline.} = self.union1.uVersion = x
proc uVersion*(self: NOTIFYICONDATAA): UINT {.inline.} = self.union1.uVersion
proc uVersion*(self: var NOTIFYICONDATAA): var UINT {.inline.} = self.union1.uVersion
proc `uTimeout=`*(self: var NOTIFYICONDATAW, x: UINT) {.inline.} = self.union1.uTimeout = x
proc uTimeout*(self: NOTIFYICONDATAW): UINT {.inline.} = self.union1.uTimeout
proc uTimeout*(self: var NOTIFYICONDATAW): var UINT {.inline.} = self.union1.uTimeout
proc `uVersion=`*(self: var NOTIFYICONDATAW, x: UINT) {.inline.} = self.union1.uVersion = x
proc uVersion*(self: NOTIFYICONDATAW): UINT {.inline.} = self.union1.uVersion
proc uVersion*(self: var NOTIFYICONDATAW): var UINT {.inline.} = self.union1.uVersion
proc BindToHandler*(self: ptr IShellItem, pbc: ptr IBindCtx, bhid: REFGUID, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.BindToHandler(self, pbc, bhid, riid, ppv)
proc GetParent*(self: ptr IShellItem, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.GetParent(self, ppsi)
proc GetDisplayName*(self: ptr IShellItem, sigdnName: SIGDN, ppszName: ptr LPWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.GetDisplayName(self, sigdnName, ppszName)
proc GetAttributes*(self: ptr IShellItem, sfgaoMask: SFGAOF, psfgaoAttribs: ptr SFGAOF): HRESULT {.winapi, inline.} = self.lpVtbl.GetAttributes(self, sfgaoMask, psfgaoAttribs)
proc Compare*(self: ptr IShellItem, psi: ptr IShellItem, hint: SICHINTF, piOrder: ptr int32): HRESULT {.winapi, inline.} = self.lpVtbl.Compare(self, psi, hint, piOrder)
proc Next*(self: ptr IEnumShellItems, celt: ULONG, rgelt: ptr ptr IShellItem, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumShellItems, celt: ULONG): HRESULT {.winapi, inline.} = self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumShellItems): HRESULT {.winapi, inline.} = self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumShellItems, ppenum: ptr ptr IEnumShellItems): HRESULT {.winapi, inline.} = self.lpVtbl.Clone(self, ppenum)
proc BindToHandler*(self: ptr IShellItemArray, pbc: ptr IBindCtx, bhid: REFGUID, riid: REFIID, ppvOut: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.BindToHandler(self, pbc, bhid, riid, ppvOut)
proc GetPropertyStore*(self: ptr IShellItemArray, flags: GETPROPERTYSTOREFLAGS, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.GetPropertyStore(self, flags, riid, ppv)
proc GetPropertyDescriptionList*(self: ptr IShellItemArray, keyType: REFPROPERTYKEY, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, inline.} = self.lpVtbl.GetPropertyDescriptionList(self, keyType, riid, ppv)
proc GetAttributes*(self: ptr IShellItemArray, AttribFlags: SIATTRIBFLAGS, sfgaoMask: SFGAOF, psfgaoAttribs: ptr SFGAOF): HRESULT {.winapi, inline.} = self.lpVtbl.GetAttributes(self, AttribFlags, sfgaoMask, psfgaoAttribs)
proc GetCount*(self: ptr IShellItemArray, pdwNumItems: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.GetCount(self, pdwNumItems)
proc GetItemAt*(self: ptr IShellItemArray, dwIndex: DWORD, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.GetItemAt(self, dwIndex, ppsi)
proc EnumItems*(self: ptr IShellItemArray, ppenumShellItems: ptr ptr IEnumShellItems): HRESULT {.winapi, inline.} = self.lpVtbl.EnumItems(self, ppenumShellItems)
proc HrInit*(self: ptr ITaskbarList): HRESULT {.winapi, inline.} = self.lpVtbl.HrInit(self)
proc AddTab*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.AddTab(self, hwnd)
proc DeleteTab*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.DeleteTab(self, hwnd)
proc ActivateTab*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.ActivateTab(self, hwnd)
proc SetActiveAlt*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.SetActiveAlt(self, hwnd)
proc MarkFullscreenWindow*(self: ptr ITaskbarList2, hwnd: HWND, fFullscreen: WINBOOL): HRESULT {.winapi, inline.} = self.lpVtbl.MarkFullscreenWindow(self, hwnd, fFullscreen)
proc SetProgressValue*(self: ptr ITaskbarList3, hwnd: HWND, ullCompleted: ULONGLONG, ullTotal: ULONGLONG): HRESULT {.winapi, inline.} = self.lpVtbl.SetProgressValue(self, hwnd, ullCompleted, ullTotal)
proc SetProgressState*(self: ptr ITaskbarList3, hwnd: HWND, tbpFlags: TBPFLAG): HRESULT {.winapi, inline.} = self.lpVtbl.SetProgressState(self, hwnd, tbpFlags)
proc RegisterTab*(self: ptr ITaskbarList3, hwndTab: HWND, hwndMDI: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.RegisterTab(self, hwndTab, hwndMDI)
proc UnregisterTab*(self: ptr ITaskbarList3, hwndTab: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.UnregisterTab(self, hwndTab)
proc SetTabOrder*(self: ptr ITaskbarList3, hwndTab: HWND, hwndInsertBefore: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.SetTabOrder(self, hwndTab, hwndInsertBefore)
proc SetTabActive*(self: ptr ITaskbarList3, hwndTab: HWND, hwndMDI: HWND, dwReserved: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.SetTabActive(self, hwndTab, hwndMDI, dwReserved)
proc ThumbBarAddButtons*(self: ptr ITaskbarList3, hwnd: HWND, cButtons: UINT, pButton: LPTHUMBBUTTON): HRESULT {.winapi, inline.} = self.lpVtbl.ThumbBarAddButtons(self, hwnd, cButtons, pButton)
proc ThumbBarUpdateButtons*(self: ptr ITaskbarList3, hwnd: HWND, cButtons: UINT, pButton: LPTHUMBBUTTON): HRESULT {.winapi, inline.} = self.lpVtbl.ThumbBarUpdateButtons(self, hwnd, cButtons, pButton)
proc ThumbBarSetImageList*(self: ptr ITaskbarList3, hwnd: HWND, himl: HIMAGELIST): HRESULT {.winapi, inline.} = self.lpVtbl.ThumbBarSetImageList(self, hwnd, himl)
proc SetOverlayIcon*(self: ptr ITaskbarList3, hwnd: HWND, hIcon: HICON, pszDescription: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetOverlayIcon(self, hwnd, hIcon, pszDescription)
proc SetThumbnailTooltip*(self: ptr ITaskbarList3, hwnd: HWND, pszTip: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetThumbnailTooltip(self, hwnd, pszTip)
proc SetThumbnailClip*(self: ptr ITaskbarList3, hwnd: HWND, prcClip: ptr RECT): HRESULT {.winapi, inline.} = self.lpVtbl.SetThumbnailClip(self, hwnd, prcClip)
proc Show*(self: ptr IModalWindow, hwndOwner: HWND): HRESULT {.winapi, inline.} = self.lpVtbl.Show(self, hwndOwner)
proc OnFileOk*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = self.lpVtbl.OnFileOk(self, pfd)
proc OnFolderChanging*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psiFolder: ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.OnFolderChanging(self, pfd, psiFolder)
proc OnFolderChange*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = self.lpVtbl.OnFolderChange(self, pfd)
proc OnSelectionChange*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = self.lpVtbl.OnSelectionChange(self, pfd)
proc OnShareViolation*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psi: ptr IShellItem, pResponse: ptr FDE_SHAREVIOLATION_RESPONSE): HRESULT {.winapi, inline.} = self.lpVtbl.OnShareViolation(self, pfd, psi, pResponse)
proc OnTypeChange*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = self.lpVtbl.OnTypeChange(self, pfd)
proc OnOverwrite*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psi: ptr IShellItem, pResponse: ptr FDE_OVERWRITE_RESPONSE): HRESULT {.winapi, inline.} = self.lpVtbl.OnOverwrite(self, pfd, psi, pResponse)
proc SetFileTypes*(self: ptr IFileDialog, cFileTypes: UINT, rgFilterSpec: ptr COMDLG_FILTERSPEC): HRESULT {.winapi, inline.} = self.lpVtbl.SetFileTypes(self, cFileTypes, rgFilterSpec)
proc SetFileTypeIndex*(self: ptr IFileDialog, iFileType: UINT): HRESULT {.winapi, inline.} = self.lpVtbl.SetFileTypeIndex(self, iFileType)
proc GetFileTypeIndex*(self: ptr IFileDialog, piFileType: ptr UINT): HRESULT {.winapi, inline.} = self.lpVtbl.GetFileTypeIndex(self, piFileType)
proc Advise*(self: ptr IFileDialog, pfde: ptr IFileDialogEvents, pdwCookie: ptr DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Advise(self, pfde, pdwCookie)
proc Unadvise*(self: ptr IFileDialog, dwCookie: DWORD): HRESULT {.winapi, inline.} = self.lpVtbl.Unadvise(self, dwCookie)
proc SetOptions*(self: ptr IFileDialog, fos: FILEOPENDIALOGOPTIONS): HRESULT {.winapi, inline.} = self.lpVtbl.SetOptions(self, fos)
proc GetOptions*(self: ptr IFileDialog, pfos: ptr FILEOPENDIALOGOPTIONS): HRESULT {.winapi, inline.} = self.lpVtbl.GetOptions(self, pfos)
proc SetDefaultFolder*(self: ptr IFileDialog, psi: ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.SetDefaultFolder(self, psi)
proc SetFolder*(self: ptr IFileDialog, psi: ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.SetFolder(self, psi)
proc GetFolder*(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.GetFolder(self, ppsi)
proc GetCurrentSelection*(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.GetCurrentSelection(self, ppsi)
proc SetFileName*(self: ptr IFileDialog, pszName: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetFileName(self, pszName)
proc GetFileName*(self: ptr IFileDialog, pszName: ptr LPWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.GetFileName(self, pszName)
proc SetTitle*(self: ptr IFileDialog, pszTitle: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetTitle(self, pszTitle)
proc SetOkButtonLabel*(self: ptr IFileDialog, pszText: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetOkButtonLabel(self, pszText)
proc SetFileNameLabel*(self: ptr IFileDialog, pszLabel: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetFileNameLabel(self, pszLabel)
proc GetResult*(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.GetResult(self, ppsi)
proc AddPlace*(self: ptr IFileDialog, psi: ptr IShellItem, fdap: FDAP): HRESULT {.winapi, inline.} = self.lpVtbl.AddPlace(self, psi, fdap)
proc SetDefaultExtension*(self: ptr IFileDialog, pszDefaultExtension: LPCWSTR): HRESULT {.winapi, inline.} = self.lpVtbl.SetDefaultExtension(self, pszDefaultExtension)
proc Close*(self: ptr IFileDialog, hr: HRESULT): HRESULT {.winapi, inline.} = self.lpVtbl.Close(self, hr)
proc SetClientGuid*(self: ptr IFileDialog, guid: REFGUID): HRESULT {.winapi, inline.} = self.lpVtbl.SetClientGuid(self, guid)
proc ClearClientData*(self: ptr IFileDialog): HRESULT {.winapi, inline.} = self.lpVtbl.ClearClientData(self)
proc SetFilter*(self: ptr IFileDialog, pFilter: ptr IShellItemFilter): HRESULT {.winapi, inline.} = self.lpVtbl.SetFilter(self, pFilter)
proc GetResults*(self: ptr IFileOpenDialog, ppenum: ptr ptr IShellItemArray): HRESULT {.winapi, inline.} = self.lpVtbl.GetResults(self, ppenum)
proc GetSelectedItems*(self: ptr IFileOpenDialog, ppsai: ptr ptr IShellItemArray): HRESULT {.winapi, inline.} = self.lpVtbl.GetSelectedItems(self, ppsai)
proc IncludeItem*(self: ptr IShellItemFilter, psi: ptr IShellItem): HRESULT {.winapi, inline.} = self.lpVtbl.IncludeItem(self, psi)
proc GetEnumFlagsForItem*(self: ptr IShellItemFilter, psi: ptr IShellItem, pgrfFlags: ptr SHCONTF): HRESULT {.winapi, inline.} = self.lpVtbl.GetEnumFlagsForItem(self, psi, pgrfFlags)
converter winimConverterIShellItemToIUnknown*(x: ptr IShellItem): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumShellItemsToIUnknown*(x: ptr IEnumShellItems): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIShellItemArrayToIUnknown*(x: ptr IShellItemArray): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterITaskbarListToIUnknown*(x: ptr ITaskbarList): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterITaskbarList2ToITaskbarList*(x: ptr ITaskbarList2): ptr ITaskbarList = cast[ptr ITaskbarList](x)
converter winimConverterITaskbarList2ToIUnknown*(x: ptr ITaskbarList2): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterITaskbarList3ToITaskbarList2*(x: ptr ITaskbarList3): ptr ITaskbarList2 = cast[ptr ITaskbarList2](x)
converter winimConverterITaskbarList3ToITaskbarList*(x: ptr ITaskbarList3): ptr ITaskbarList = cast[ptr ITaskbarList](x)
converter winimConverterITaskbarList3ToIUnknown*(x: ptr ITaskbarList3): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIModalWindowToIUnknown*(x: ptr IModalWindow): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIFileDialogEventsToIUnknown*(x: ptr IFileDialogEvents): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIFileDialogToIModalWindow*(x: ptr IFileDialog): ptr IModalWindow = cast[ptr IModalWindow](x)
converter winimConverterIFileDialogToIUnknown*(x: ptr IFileDialog): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIFileOpenDialogToIFileDialog*(x: ptr IFileOpenDialog): ptr IFileDialog = cast[ptr IFileDialog](x)
converter winimConverterIFileOpenDialogToIModalWindow*(x: ptr IFileOpenDialog): ptr IModalWindow = cast[ptr IModalWindow](x)
converter winimConverterIFileOpenDialogToIUnknown*(x: ptr IFileOpenDialog): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIShellItemFilterToIUnknown*(x: ptr IShellItemFilter): ptr IUnknown = cast[ptr IUnknown](x)
when winimUnicode:
  type
    NOTIFYICONDATA* = NOTIFYICONDATAW
    BROWSEINFO* = BROWSEINFOW
  const
    BFFM_SETSELECTION* = BFFM_SETSELECTIONW
  proc DragQueryFile*(hDrop: HDROP, iFile: UINT, lpszFile: LPWSTR, cch: UINT): UINT {.winapi, stdcall, dynlib: "shell32", importc: "DragQueryFileW".}
  proc Shell_NotifyIcon*(dwMessage: DWORD, lpData: PNOTIFYICONDATAW): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "Shell_NotifyIconW".}
  proc PathFileExists*(pszPath: LPCWSTR): WINBOOL {.winapi, stdcall, dynlib: "shlwapi", importc: "PathFileExistsW".}
  proc ILCreateFromPath*(pszPath: PCWSTR): PIDLIST_ABSOLUTE {.winapi, stdcall, dynlib: "shell32", importc: "ILCreateFromPathW".}
  proc SHGetPathFromIDList*(pidl: PCIDLIST_ABSOLUTE, pszPath: LPWSTR): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "SHGetPathFromIDListW".}
  proc SHBrowseForFolder*(lpbi: LPBROWSEINFOW): PIDLIST_ABSOLUTE {.winapi, stdcall, dynlib: "shell32", importc: "SHBrowseForFolderW".}
when winimAnsi:
  type
    NOTIFYICONDATA* = NOTIFYICONDATAA
    BROWSEINFO* = BROWSEINFOA
  const
    BFFM_SETSELECTION* = BFFM_SETSELECTIONA
  proc DragQueryFile*(hDrop: HDROP, iFile: UINT, lpszFile: LPSTR, cch: UINT): UINT {.winapi, stdcall, dynlib: "shell32", importc: "DragQueryFileA".}
  proc Shell_NotifyIcon*(dwMessage: DWORD, lpData: PNOTIFYICONDATAA): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "Shell_NotifyIconA".}
  proc PathFileExists*(pszPath: LPCSTR): WINBOOL {.winapi, stdcall, dynlib: "shlwapi", importc: "PathFileExistsA".}
  proc ILCreateFromPath*(pszPath: PCSTR): PIDLIST_ABSOLUTE {.winapi, stdcall, dynlib: "shell32", importc: "ILCreateFromPathA".}
  proc SHGetPathFromIDList*(pidl: PCIDLIST_ABSOLUTE, pszPath: LPSTR): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "SHGetPathFromIDListA".}
  proc SHBrowseForFolder*(lpbi: LPBROWSEINFOA): PIDLIST_ABSOLUTE {.winapi, stdcall, dynlib: "shell32", importc: "SHBrowseForFolderA".}
const
  requestSize* = 0
  TABP_BODY* = 10
proc OpenThemeData*(hwnd: HWND, pszClassList: LPCWSTR): HTHEME {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc CloseThemeData*(hTheme: HTHEME): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc GetThemeColor*(hTheme: HTHEME, iPartId: int32, iStateId: int32, iPropId: int32, pColor: ptr COLORREF): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc SetWindowTheme*(hwnd: HWND, pszSubAppName: LPCWSTR, pszSubIdList: LPCWSTR): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc IsThemeActive*(): WINBOOL {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc IsAppThemed*(): WINBOOL {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc GetCurrentThemeName*(pszThemeFileName: LPWSTR, cchMaxNameChars: int32, pszColorBuff: LPWSTR, cchMaxColorChars: int32, pszSizeBuff: LPWSTR, cchMaxSizeChars: int32): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
type
  InterpolationMode* = int32
  GpMatrixOrder* = int32
  GpStatus* = int32
  DebugEventProc* = pointer
  RotateFlipType* = int32
  ARGB* = DWORD
  REAL* = float32
  PixelFormat* = INT
const
  encoderParameterValueTypeLong* = 4
  interpolationModeDefault* = 0
  interpolationModeLowQuality* = 1
  interpolationModeHighQuality* = 2
  interpolationModeNearestNeighbor* = 5
  interpolationModeHighQualityBilinear* = 6
  interpolationModeHighQualityBicubic* = 7
  matrixOrderPrepend* = 0
  Ok* = 0
  imageLockModeRead* = 1
  rotateNoneFlipNone* = 0
  rotate90FlipNone* = 1
  rotate180FlipNone* = 2
  rotate270FlipNone* = 3
  rotateNoneFlipX* = 4
  rotate90FlipX* = 5
  rotate180FlipX* = 6
  rotate270FlipX* = 7
  rotate180FlipXY* = 0
  rotate270FlipXY* = 1
  rotateNoneFlipXY* = 2
  rotate90FlipXY* = 3
  rotate180FlipY* = 4
  rotate270FlipY* = 5
  rotateNoneFlipY* = 6
  rotate90FlipY* = 7
  pixelFormatGDI* = INT 0x00020000
  pixelFormatAlpha* = INT 0x00040000
  pixelFormatCanonical* = INT 0x00200000
  pixelFormat32bppARGB* = INT(10 or (32 shl 8) or pixelFormatAlpha or pixelFormatGDI or pixelFormatCanonical)
  EncoderQuality* = DEFINE_GUID(0x1D5BE4B5'i32, 0xFA4A, 0x452D, [0x9C'u8,0xDD,0x5D,0xB3,0x51,0x05,0xE7,0xEB])
  BlurEffectGuid* = DEFINE_GUID(0x633C80A4'i32, 0x1843, 0x482B, [0x9E'u8,0xF2,0xBE,0x28,0x34,0xC5,0xFD,0xD4])
  BrightnessContrastEffectGuid* = DEFINE_GUID(0xD3A1DBE1'i32, 0x8EC4, 0x4C17, [0x9F'u8,0x4C,0xEA,0x97,0xAD,0x1C,0x34,0x3D])
  ColorBalanceEffectGuid* = DEFINE_GUID(0x537E597D'i32, 0x251E, 0x48DA, [0x96'u8,0x64,0x29,0xCA,0x49,0x6B,0x70,0xF8])
  HueSaturationLightnessEffectGuid* = DEFINE_GUID(0x8B2DD6C3'i32, 0xEB07, 0x4D87, [0xA5'u8,0xF0,0x71,0x08,0xE2,0x6A,0x9C,0x5F])
  LevelsEffectGuid* = DEFINE_GUID(0x99C354EC'i32, 0x2A31, 0x4F3A, [0x8C'u8,0x34,0x17,0xA8,0x03,0xB3,0x3A,0x25])
  SharpenEffectGuid* = DEFINE_GUID(0x63CBF3EE'i32, 0xC526, 0x402C, [0x8F'u8,0x71,0x62,0xC5,0x40,0xBF,0x51,0x42])
  TintEffectGuid* = DEFINE_GUID(0x1077AF00'i32, 0x2848, 0x4441, [0x94'u8,0x89,0x44,0xAD,0x4C,0x2D,0x7A,0x2C])
type
  NotificationHookProc* = proc (token: ptr ULONG_PTR): GpStatus {.stdcall.}
  NotificationUnhookProc* = proc (token: ULONG_PTR): VOID {.stdcall.}
  GpRect* {.pure.} = object
    X*: INT
    Y*: INT
    Width*: INT
    Height*: INT
  BitmapData* {.pure.} = object
    Width*: UINT
    Height*: UINT
    Stride*: INT
    PixelFormat*: INT
    Scan0*: pointer
    Reserved*: UINT_PTR
  EncoderParameter* {.pure.} = object
    Guid*: GUID
    NumberOfValues*: ULONG
    Type*: ULONG
    Value*: pointer
  EncoderParameters* {.pure.} = object
    Count*: UINT
    Parameter*: array[1, EncoderParameter]
  ImageCodecInfo* {.pure.} = object
    Clsid*: CLSID
    FormatID*: GUID
    CodecName*: ptr WCHAR
    DllName*: ptr WCHAR
    FormatDescription*: ptr WCHAR
    FilenameExtension*: ptr WCHAR
    MimeType*: ptr WCHAR
    Flags*: DWORD
    Version*: DWORD
    SigCount*: DWORD
    SigSize*: DWORD
    SigPattern*: ptr BYTE
    SigMask*: ptr BYTE
  GdiplusStartupInput* {.pure.} = object
    GdiplusVersion*: UINT32
    DebugEventCallback*: DebugEventProc
    SuppressBackgroundThread*: BOOL
    SuppressExternalCodecs*: BOOL
  GdiplusStartupOutput* {.pure.} = object
    NotificationHook*: NotificationHookProc
    NotificationUnhook*: NotificationUnhookProc
  Color* {.pure.} = object
    Value*: ARGB
  BlurParams* {.pure.} = object
    radius*: REAL
    expandEdge*: BOOL
  BrightnessContrastParams* {.pure.} = object
    brightnessLevel*: INT
    contrastLevel*: INT
  ColorBalanceParams* {.pure.} = object
    cyanRed*: INT
    magentaGreen*: INT
    yellowBlue*: INT
  HueSaturationLightnessParams* {.pure.} = object
    hueLevel*: INT
    saturationLevel*: INT
    lightnessLevel*: INT
  LevelsParams* {.pure.} = object
    highlight*: INT
    midtone*: INT
    shadow*: INT
  SharpenParams* {.pure.} = object
    radius*: REAL
    amount*: REAL
  TintParams* {.pure.} = object
    hue*: INT
    amount*: INT
  CGpEffect* {.pure.} = object
  GpBitmap* {.pure.} = object
  GpGraphics* {.pure.} = object
  GpImage* {.pure.} = object
proc GdiplusStartup*(token: ptr ULONG_PTR, input: ptr GdiplusStartupInput, output: ptr GdiplusStartupOutput): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCreateBitmapFromStream*(stream: ptr IStream, bitmap: ptr ptr GpBitmap): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCreateBitmapFromFile*(filename: ptr WCHAR, bitmap: ptr ptr GpBitmap): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCreateBitmapFromScan0*(width: INT, height: INT, stride: INT, format: PixelFormat, scan0: ptr BYTE, bitmap: ptr ptr GpBitmap): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCreateBitmapFromHBITMAP*(hbm: HBITMAP, hpal: HPALETTE, bitmap: ptr ptr GpBitmap): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCreateHBITMAPFromBitmap*(bitmap: ptr GpBitmap, hbmReturn: ptr HBITMAP, background: ARGB): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipBitmapLockBits*(bitmap: ptr GpBitmap, rect: ptr GpRect, flags: UINT, format: PixelFormat, lockedBitmapData: ptr BitmapData): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipBitmapUnlockBits*(bitmap: ptr GpBitmap, lockedBitmapData: ptr BitmapData): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipBitmapGetPixel*(bitmap: ptr GpBitmap, x: INT, y: INT, color: ptr ARGB): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipBitmapSetPixel*(bitmap: ptr GpBitmap, x: INT, y: INT, color: ARGB): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipBitmapApplyEffect*(bitmap: ptr GpBitmap, effect: ptr CGpEffect, roi: ptr RECT, useAuxData: BOOL, auxData: ptr pointer, auxDataSize: ptr INT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipBitmapCreateApplyEffect*(inputBitmaps: ptr ptr GpBitmap, numInputs: INT, effect: ptr CGpEffect, roi: ptr RECT, outputRect: ptr RECT, outputBitmap: ptr ptr GpBitmap, useAuxData: BOOL, auxData: ptr pointer, auxDataSize: ptr INT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCreateEffect*(guid: GUID, effect: ptr ptr CGpEffect): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipDeleteEffect*(effect: ptr CGpEffect): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipSetEffectParameters*(effect: ptr CGpEffect, params: pointer, size: UINT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipDeleteGraphics*(graphics: ptr GpGraphics): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipSetInterpolationMode*(graphics: ptr GpGraphics, interpolationMode: InterpolationMode): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipTranslateWorldTransform*(graphics: ptr GpGraphics, dx: REAL, dy: REAL, order: GpMatrixOrder): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipRotateWorldTransform*(graphics: ptr GpGraphics, angle: REAL, order: GpMatrixOrder): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipDrawImageRectI*(graphics: ptr GpGraphics, image: ptr GpImage, x: INT, y: INT, width: INT, height: INT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipCloneImage*(image: ptr GpImage, cloneImage: ptr ptr GpImage): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipDisposeImage*(image: ptr GpImage): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipSaveImageToFile*(image: ptr GpImage, filename: ptr WCHAR, clsidEncoder: ptr CLSID, encoderParams: ptr EncoderParameters): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipSaveImageToStream*(image: ptr GpImage, stream: ptr IStream, clsidEncoder: ptr CLSID, encoderParams: ptr EncoderParameters): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageGraphicsContext*(image: ptr GpImage, graphics: ptr ptr GpGraphics): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageWidth*(image: ptr GpImage, width: ptr UINT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageHeight*(image: ptr GpImage, height: ptr UINT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipImageRotateFlip*(image: ptr GpImage, rfType: RotateFlipType): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageDecodersSize*(numDecoders: ptr UINT, size: ptr UINT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageDecoders*(numDecoders: UINT, size: UINT, decoders: ptr ImageCodecInfo): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageEncodersSize*(numEncoders: ptr UINT, size: ptr UINT): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
proc GdipGetImageEncoders*(numEncoders: UINT, size: UINT, encoders: ptr ImageCodecInfo): GpStatus {.winapi, stdcall, dynlib: "gdiplus", importc.}
