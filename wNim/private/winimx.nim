#====================================================================
#
#               Winim - Nim's Windows API Module
#                 (c) Copyright 2016-2022 Ward
#
#====================================================================

{.push hint[Name]: off.}

when defined(nimHasUsed): {.used.}

import winim/inc/winimbase
import winim/inc/windef
import winim/inc/winbase
const
  FACILITY_WIN32* = 7
  ERROR_SUCCESS* = 0
  ERROR_CANCELLED* = 1223
  E_UNEXPECTED* = HRESULT 0x8000FFFF'i32
  E_NOTIMPL* = HRESULT 0x80004001'i32
  E_NOINTERFACE* = HRESULT 0x80004002'i32
  E_POINTER* = HRESULT 0x80004003'i32
  E_FAIL* = HRESULT 0x80004005'i32
template HRESULT_FROM_WIN32*(x: untyped): HRESULT = (if x <= 0: HRESULT x else: HRESULT(x and 0x0000ffff) or HRESULT(FACILITY_WIN32 shl 16) or HRESULT(0x80000000'i32))
const
  S_OK* = HRESULT 0x00000000
  S_FALSE* = HRESULT 0x00000001
  DRAGDROP_S_DROP* = HRESULT 0x00040100
  DRAGDROP_S_CANCEL* = HRESULT 0x00040101
  DISP_E_MEMBERNOTFOUND* = HRESULT 0x80020003'i32
  DISP_E_UNKNOWNNAME* = HRESULT 0x80020006'i32
  TYPE_E_ELEMENTNOTFOUND* = HRESULT 0x8002802B'i32
template SUCCEEDED*(hr: untyped): bool = hr.HRESULT >= 0
template FAILED*(hr: untyped): bool = hr.HRESULT < 0
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
  TEXTMETRICA* {.pure.} = object
    tmHeight*: LONG
    tmAscent*: LONG
    tmDescent*: LONG
    tmInternalLeading*: LONG
    tmExternalLeading*: LONG
    tmAveCharWidth*: LONG
    tmMaxCharWidth*: LONG
    tmWeight*: LONG
    tmOverhang*: LONG
    tmDigitizedAspectX*: LONG
    tmDigitizedAspectY*: LONG
    tmFirstChar*: BYTE
    tmLastChar*: BYTE
    tmDefaultChar*: BYTE
    tmBreakChar*: BYTE
    tmItalic*: BYTE
    tmUnderlined*: BYTE
    tmStruckOut*: BYTE
    tmPitchAndFamily*: BYTE
    tmCharSet*: BYTE
  LPTEXTMETRICA* = ptr TEXTMETRICA
  TEXTMETRICW* {.pure.} = object
    tmHeight*: LONG
    tmAscent*: LONG
    tmDescent*: LONG
    tmInternalLeading*: LONG
    tmExternalLeading*: LONG
    tmAveCharWidth*: LONG
    tmMaxCharWidth*: LONG
    tmWeight*: LONG
    tmOverhang*: LONG
    tmDigitizedAspectX*: LONG
    tmDigitizedAspectY*: LONG
    tmFirstChar*: WCHAR
    tmLastChar*: WCHAR
    tmDefaultChar*: WCHAR
    tmBreakChar*: WCHAR
    tmItalic*: BYTE
    tmUnderlined*: BYTE
    tmStruckOut*: BYTE
    tmPitchAndFamily*: BYTE
    tmCharSet*: BYTE
  LPTEXTMETRICW* = ptr TEXTMETRICW
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
  PALETTEENTRY* {.pure.} = object
    peRed*: BYTE
    peGreen*: BYTE
    peBlue*: BYTE
    peFlags*: BYTE
  LOGPALETTE* {.pure.} = object
    palVersion*: WORD
    palNumEntries*: WORD
    palPalEntry*: array[1, PALETTEENTRY]
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
  LPLOGFONTA* = ptr LOGFONTA
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
  LPLOGFONTW* = ptr LOGFONTW
const
  CCHDEVICENAME* = 32
type
  DEVMODEA_UNION1_STRUCT1* {.pure.} = object
    dmOrientation*: int16
    dmPaperSize*: int16
    dmPaperLength*: int16
    dmPaperWidth*: int16
    dmScale*: int16
    dmCopies*: int16
    dmDefaultSource*: int16
    dmPrintQuality*: int16
  DEVMODEA_UNION1_STRUCT2* {.pure.} = object
    dmPosition*: POINTL
    dmDisplayOrientation*: DWORD
    dmDisplayFixedOutput*: DWORD
  DEVMODEA_UNION1* {.pure, union.} = object
    struct1*: DEVMODEA_UNION1_STRUCT1
    struct2*: DEVMODEA_UNION1_STRUCT2
const
  CCHFORMNAME* = 32
type
  DEVMODEA_UNION2* {.pure, union.} = object
    dmDisplayFlags*: DWORD
    dmNup*: DWORD
  DEVMODEA* {.pure.} = object
    dmDeviceName*: array[CCHDEVICENAME, BYTE]
    dmSpecVersion*: WORD
    dmDriverVersion*: WORD
    dmSize*: WORD
    dmDriverExtra*: WORD
    dmFields*: DWORD
    union1*: DEVMODEA_UNION1
    dmColor*: int16
    dmDuplex*: int16
    dmYResolution*: int16
    dmTTOption*: int16
    dmCollate*: int16
    dmFormName*: array[CCHFORMNAME, BYTE]
    dmLogPixels*: WORD
    dmBitsPerPel*: DWORD
    dmPelsWidth*: DWORD
    dmPelsHeight*: DWORD
    union2*: DEVMODEA_UNION2
    dmDisplayFrequency*: DWORD
    dmICMMethod*: DWORD
    dmICMIntent*: DWORD
    dmMediaType*: DWORD
    dmDitherType*: DWORD
    dmReserved1*: DWORD
    dmReserved2*: DWORD
    dmPanningWidth*: DWORD
    dmPanningHeight*: DWORD
  PDEVMODEA* = ptr DEVMODEA
  LPDEVMODEA* = ptr DEVMODEA
  DEVMODEW_UNION1_STRUCT1* {.pure.} = object
    dmOrientation*: int16
    dmPaperSize*: int16
    dmPaperLength*: int16
    dmPaperWidth*: int16
    dmScale*: int16
    dmCopies*: int16
    dmDefaultSource*: int16
    dmPrintQuality*: int16
  DEVMODEW_UNION1_STRUCT2* {.pure.} = object
    dmPosition*: POINTL
    dmDisplayOrientation*: DWORD
    dmDisplayFixedOutput*: DWORD
  DEVMODEW_UNION1* {.pure, union.} = object
    struct1*: DEVMODEW_UNION1_STRUCT1
    struct2*: DEVMODEW_UNION1_STRUCT2
  DEVMODEW_UNION2* {.pure, union.} = object
    dmDisplayFlags*: DWORD
    dmNup*: DWORD
  DEVMODEW* {.pure.} = object
    dmDeviceName*: array[CCHDEVICENAME, WCHAR]
    dmSpecVersion*: WORD
    dmDriverVersion*: WORD
    dmSize*: WORD
    dmDriverExtra*: WORD
    dmFields*: DWORD
    union1*: DEVMODEW_UNION1
    dmColor*: int16
    dmDuplex*: int16
    dmYResolution*: int16
    dmTTOption*: int16
    dmCollate*: int16
    dmFormName*: array[CCHFORMNAME, WCHAR]
    dmLogPixels*: WORD
    dmBitsPerPel*: DWORD
    dmPelsWidth*: DWORD
    dmPelsHeight*: DWORD
    union2*: DEVMODEW_UNION2
    dmDisplayFrequency*: DWORD
    dmICMMethod*: DWORD
    dmICMIntent*: DWORD
    dmMediaType*: DWORD
    dmDitherType*: DWORD
    dmReserved1*: DWORD
    dmReserved2*: DWORD
    dmPanningWidth*: DWORD
    dmPanningHeight*: DWORD
  PDEVMODEW* = ptr DEVMODEW
  LPDEVMODEW* = ptr DEVMODEW
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
  DOCINFOA* {.pure.} = object
    cbSize*: int32
    lpszDocName*: LPCSTR
    lpszOutput*: LPCSTR
    lpszDatatype*: LPCSTR
    fwType*: DWORD
  DOCINFOW* {.pure.} = object
    cbSize*: int32
    lpszDocName*: LPCWSTR
    lpszOutput*: LPCWSTR
    lpszDatatype*: LPCWSTR
    fwType*: DWORD
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
  ERROR* = 0
  RGN_AND* = 1
  RGN_OR* = 2
  RGN_XOR* = 3
  RGN_DIFF* = 4
  RGN_COPY* = 5
  HALFTONE* = 4
  ALTERNATE* = 1
  WINDING* = 2
  ETO_OPAQUE* = 0x0002
  abortDoc* = 2
  startDoc* = 10
  endDoc* = 11
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
  PS_INSIDEFRAME* = 6
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
  PHYSICALWIDTH* = 110
  PHYSICALHEIGHT* = 111
  PHYSICALOFFSETX* = 112
  PHYSICALOFFSETY* = 113
  DM_ORIENTATION* = 0x00000001
  DM_PAPERSIZE* = 0x00000002
  DM_PAPERLENGTH* = 0x00000004
  DM_PAPERWIDTH* = 0x00000008
  DM_COPIES* = 0x00000100
  DM_COLOR* = 0x00000800
  DM_DUPLEX* = 0x00001000
  DMORIENT_PORTRAIT* = 1
  DMORIENT_LANDSCAPE* = 2
  DMPAPER_LETTER* = 1
  DMPAPER_LETTERSMALL* = 2
  DMPAPER_TABLOID* = 3
  DMPAPER_LEDGER* = 4
  DMPAPER_LEGAL* = 5
  DMPAPER_STATEMENT* = 6
  DMPAPER_EXECUTIVE* = 7
  DMPAPER_A3* = 8
  DMPAPER_A4* = 9
  DMPAPER_A4SMALL* = 10
  DMPAPER_A5* = 11
  DMPAPER_B4* = 12
  DMPAPER_B5* = 13
  DMPAPER_FOLIO* = 14
  DMPAPER_QUARTO* = 15
  DMPAPER_10X14* = 16
  DMPAPER_11X17* = 17
  DMPAPER_NOTE* = 18
  DMPAPER_ENV_9* = 19
  DMPAPER_ENV_10* = 20
  DMPAPER_ENV_11* = 21
  DMPAPER_ENV_12* = 22
  DMPAPER_ENV_14* = 23
  DMPAPER_CSHEET* = 24
  DMPAPER_DSHEET* = 25
  DMPAPER_ESHEET* = 26
  DMPAPER_ENV_DL* = 27
  DMPAPER_ENV_C5* = 28
  DMPAPER_ENV_C3* = 29
  DMPAPER_ENV_C4* = 30
  DMPAPER_ENV_C6* = 31
  DMPAPER_ENV_C65* = 32
  DMPAPER_ENV_B4* = 33
  DMPAPER_ENV_B5* = 34
  DMPAPER_ENV_B6* = 35
  DMPAPER_ENV_ITALY* = 36
  DMPAPER_ENV_MONARCH* = 37
  DMPAPER_ENV_PERSONAL* = 38
  DMPAPER_FANFOLD_US* = 39
  DMPAPER_FANFOLD_STD_GERMAN* = 40
  DMPAPER_FANFOLD_LGL_GERMAN* = 41
  DMPAPER_ISO_B4* = 42
  DMPAPER_JAPANESE_POSTCARD* = 43
  DMPAPER_9X11* = 44
  DMPAPER_10X11* = 45
  DMPAPER_15X11* = 46
  DMPAPER_ENV_INVITE* = 47
  DMPAPER_RESERVED_48* = 48
  DMPAPER_RESERVED_49* = 49
  DMPAPER_LETTER_EXTRA* = 50
  DMPAPER_LEGAL_EXTRA* = 51
  DMPAPER_TABLOID_EXTRA* = 52
  DMPAPER_A4_EXTRA* = 53
  DMPAPER_LETTER_TRANSVERSE* = 54
  DMPAPER_A4_TRANSVERSE* = 55
  DMPAPER_LETTER_EXTRA_TRANSVERSE* = 56
  DMPAPER_A_PLUS* = 57
  DMPAPER_B_PLUS* = 58
  DMPAPER_LETTER_PLUS* = 59
  DMPAPER_A4_PLUS* = 60
  DMPAPER_A5_TRANSVERSE* = 61
  DMPAPER_B5_TRANSVERSE* = 62
  DMPAPER_A3_EXTRA* = 63
  DMPAPER_A5_EXTRA* = 64
  DMPAPER_B5_EXTRA* = 65
  DMPAPER_A2* = 66
  DMPAPER_A3_TRANSVERSE* = 67
  DMPAPER_A3_EXTRA_TRANSVERSE* = 68
  DMPAPER_DBL_JAPANESE_POSTCARD* = 69
  DMPAPER_A6* = 70
  DMPAPER_JENV_KAKU2* = 71
  DMPAPER_JENV_KAKU3* = 72
  DMPAPER_JENV_CHOU3* = 73
  DMPAPER_JENV_CHOU4* = 74
  DMPAPER_LETTER_ROTATED* = 75
  DMPAPER_A3_ROTATED* = 76
  DMPAPER_A4_ROTATED* = 77
  DMPAPER_A5_ROTATED* = 78
  DMPAPER_B4_JIS_ROTATED* = 79
  DMPAPER_B5_JIS_ROTATED* = 80
  DMPAPER_JAPANESE_POSTCARD_ROTATED* = 81
  DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED* = 82
  DMPAPER_A6_ROTATED* = 83
  DMPAPER_JENV_KAKU2_ROTATED* = 84
  DMPAPER_JENV_KAKU3_ROTATED* = 85
  DMPAPER_JENV_CHOU3_ROTATED* = 86
  DMPAPER_JENV_CHOU4_ROTATED* = 87
  DMPAPER_B6_JIS* = 88
  DMPAPER_B6_JIS_ROTATED* = 89
  DMPAPER_12X11* = 90
  DMPAPER_JENV_YOU4* = 91
  DMPAPER_JENV_YOU4_ROTATED* = 92
  DMPAPER_P16K* = 93
  DMPAPER_P32K* = 94
  DMPAPER_P32KBIG* = 95
  DMPAPER_PENV_1* = 96
  DMPAPER_PENV_2* = 97
  DMPAPER_PENV_3* = 98
  DMPAPER_PENV_4* = 99
  DMPAPER_PENV_5* = 100
  DMPAPER_PENV_6* = 101
  DMPAPER_PENV_7* = 102
  DMPAPER_PENV_8* = 103
  DMPAPER_PENV_9* = 104
  DMPAPER_PENV_10* = 105
  DMPAPER_P16K_ROTATED* = 106
  DMPAPER_P32K_ROTATED* = 107
  DMPAPER_P32KBIG_ROTATED* = 108
  DMPAPER_PENV_1_ROTATED* = 109
  DMPAPER_PENV_2_ROTATED* = 110
  DMPAPER_PENV_3_ROTATED* = 111
  DMPAPER_PENV_4_ROTATED* = 112
  DMPAPER_PENV_5_ROTATED* = 113
  DMPAPER_PENV_6_ROTATED* = 114
  DMPAPER_PENV_7_ROTATED* = 115
  DMPAPER_PENV_8_ROTATED* = 116
  DMPAPER_PENV_9_ROTATED* = 117
  DMPAPER_PENV_10_ROTATED* = 118
  DMPAPER_USER* = 256
  DMCOLOR_MONOCHROME* = 1
  DMCOLOR_COLOR* = 2
  DMDUP_SIMPLEX* = 1
  DMDUP_VERTICAL* = 2
  DMDUP_HORIZONTAL* = 3
  DMCOLLATE_FALSE* = 0
  AC_SRC_OVER* = 0x00
  AC_SRC_ALPHA* = 0x01
when winimUnicode:
  type
    LPDEVMODE* = LPDEVMODEW
when winimAnsi:
  type
    LPDEVMODE* = LPDEVMODEA
proc Arc*(hdc: HDC, x1: int32, y1: int32, x2: int32, y2: int32, x3: int32, y3: int32, x4: int32, y4: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc BitBlt*(hdc: HDC, x: int32, y: int32, cx: int32, cy: int32, hdcSrc: HDC, x1: int32, y1: int32, rop: DWORD): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CombineRgn*(hrgnDst: HRGN, hrgnSrc1: HRGN, hrgnSrc2: HRGN, iMode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateBitmap*(nWidth: int32, nHeight: int32, nPlanes: UINT, nBitCount: UINT, lpBits: pointer): HBITMAP {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateBrushIndirect*(plbrush: ptr LOGBRUSH): HBRUSH {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateCompatibleBitmap*(hdc: HDC, cx: int32, cy: int32): HBITMAP {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateCompatibleDC*(hdc: HDC): HDC {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateEllipticRgn*(x1: int32, y1: int32, x2: int32, y2: int32): HRGN {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateHatchBrush*(iHatch: int32, color: COLORREF): HBRUSH {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateRectRgn*(x1: int32, y1: int32, x2: int32, y2: int32): HRGN {.winapi, stdcall, dynlib: "gdi32", importc.}
proc CreateRoundRectRgn*(x1: int32, y1: int32, x2: int32, y2: int32, w: int32, h: int32): HRGN {.winapi, stdcall, dynlib: "gdi32", importc.}
proc DeleteDC*(hdc: HDC): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc DeleteObject*(ho: HGDIOBJ): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Ellipse*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc EqualRgn*(hrgn1: HRGN, hrgn2: HRGN): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc FrameRgn*(hdc: HDC, hrgn: HRGN, hbr: HBRUSH, w: int32, h: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetROP2*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetBkColor*(hdc: HDC): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetBkMode*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetDeviceCaps*(hdc: HDC, index: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetObjectType*(h: HGDIOBJ): DWORD {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetPixel*(hdc: HDC, x: int32, y: int32): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetRgnBox*(hrgn: HRGN, lprc: LPRECT): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetStockObject*(i: int32): HGDIOBJ {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetTextColor*(hdc: HDC): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc GetViewportOrgEx*(hdc: HDC, lppoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc LineTo*(hdc: HDC, x: int32, y: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc OffsetRgn*(hrgn: HRGN, x: int32, y: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Pie*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32, xr1: int32, yr1: int32, xr2: int32, yr2: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc PaintRgn*(hdc: HDC, hrgn: HRGN): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc PolyPolygon*(hdc: HDC, apt: ptr POINT, asz: ptr INT, csz: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc PtInRegion*(hrgn: HRGN, x: int32, y: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc RectInRegion*(hrgn: HRGN, lprect: ptr RECT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Rectangle*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc RoundRect*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32, width: int32, height: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SelectClipRgn*(hdc: HDC, hrgn: HRGN): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SelectObject*(hdc: HDC, h: HGDIOBJ): HGDIOBJ {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBkColor*(hdc: HDC, color: COLORREF): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBkMode*(hdc: HDC, mode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBitmapBits*(hbm: HBITMAP, cb: DWORD, pvBits: pointer): LONG {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetMapMode*(hdc: HDC, iMode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetPixel*(hdc: HDC, x: int32, y: int32, color: COLORREF): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetPolyFillMode*(hdc: HDC, mode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc StretchBlt*(hdcDest: HDC, xDest: int32, yDest: int32, wDest: int32, hDest: int32, hdcSrc: HDC, xSrc: int32, ySrc: int32, wSrc: int32, hSrc: int32, rop: DWORD): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetROP2*(hdc: HDC, rop2: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetStretchBltMode*(hdc: HDC, mode: int32): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetTextColor*(hdc: HDC, color: COLORREF): COLORREF {.winapi, stdcall, dynlib: "gdi32", importc.}
proc AlphaBlend*(hdcDest: HDC, xoriginDest: int32, yoriginDest: int32, wDest: int32, hDest: int32, hdcSrc: HDC, xoriginSrc: int32, yoriginSrc: int32, wSrc: int32, hSrc: int32, ftn: BLENDFUNCTION): WINBOOL {.winapi, stdcall, dynlib: "msimg32", importc.}
proc TransparentBlt*(hdcDest: HDC, xoriginDest: int32, yoriginDest: int32, wDest: int32, hDest: int32, hdcSrc: HDC, xoriginSrc: int32, yoriginSrc: int32, wSrc: int32, hSrc: int32, crTransparent: UINT): WINBOOL {.winapi, stdcall, dynlib: "msimg32", importc.}
proc CreateDIBSection*(hdc: HDC, lpbmi: ptr BITMAPINFO, usage: UINT, ppvBits: ptr pointer, hSection: HANDLE, offset: DWORD): HBITMAP {.winapi, stdcall, dynlib: "gdi32", importc.}
proc EndDoc*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc StartPage*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc EndPage*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc AbortDoc*(hdc: HDC): int32 {.winapi, stdcall, dynlib: "gdi32", importc.}
proc ExtCreatePen*(iPenStyle: DWORD, cWidth: DWORD, plbrush: ptr LOGBRUSH, cStyle: DWORD, pstyle: ptr DWORD): HPEN {.winapi, stdcall, dynlib: "gdi32", importc.}
proc MoveToEx*(hdc: HDC, x: int32, y: int32, lppt: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Polygon*(hdc: HDC, apt: ptr POINT, cpt: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc Polyline*(hdc: HDC, apt: ptr POINT, cpt: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc PolyBezier*(hdc: HDC, apt: ptr POINT, cpt: DWORD): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetViewportExtEx*(hdc: HDC, x: int32, y: int32, lpsz: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetViewportOrgEx*(hdc: HDC, x: int32, y: int32, lppt: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetWindowExtEx*(hdc: HDC, x: int32, y: int32, lpsz: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
proc SetBrushOrgEx*(hdc: HDC, x: int32, y: int32, lppt: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc.}
template RGB*(r: untyped, g: untyped, b: untyped): COLORREF = COLORREF(COLORREF(r and 0xff) or (COLORREF(g and 0xff) shl 8) or (COLORREF(b and 0xff) shl 16))
template GetRValue*(c: untyped): BYTE = BYTE((c) and 0xff)
template GetGValue*(c: untyped): BYTE = BYTE((c shr 8) and 0xff)
template GetBValue*(c: untyped): BYTE = BYTE((c shr 16) and 0xff)
proc `dmOrientation=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmOrientation = x
proc dmOrientation*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmOrientation
proc dmOrientation*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmOrientation
proc `dmPaperSize=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmPaperSize = x
proc dmPaperSize*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmPaperSize
proc dmPaperSize*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmPaperSize
proc `dmPaperLength=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmPaperLength = x
proc dmPaperLength*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmPaperLength
proc dmPaperLength*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmPaperLength
proc `dmPaperWidth=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmPaperWidth = x
proc dmPaperWidth*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmPaperWidth
proc dmPaperWidth*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmPaperWidth
proc `dmScale=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmScale = x
proc dmScale*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmScale
proc dmScale*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmScale
proc `dmCopies=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmCopies = x
proc dmCopies*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmCopies
proc dmCopies*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmCopies
proc `dmDefaultSource=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmDefaultSource = x
proc dmDefaultSource*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmDefaultSource
proc dmDefaultSource*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmDefaultSource
proc `dmPrintQuality=`*(self: var DEVMODEA, x: int16) {.inline.} = self.union1.struct1.dmPrintQuality = x
proc dmPrintQuality*(self: DEVMODEA): int16 {.inline.} = self.union1.struct1.dmPrintQuality
proc dmPrintQuality*(self: var DEVMODEA): var int16 {.inline.} = self.union1.struct1.dmPrintQuality
proc `dmPosition=`*(self: var DEVMODEA, x: POINTL) {.inline.} = self.union1.struct2.dmPosition = x
proc dmPosition*(self: DEVMODEA): POINTL {.inline.} = self.union1.struct2.dmPosition
proc dmPosition*(self: var DEVMODEA): var POINTL {.inline.} = self.union1.struct2.dmPosition
proc `dmDisplayOrientation=`*(self: var DEVMODEA, x: DWORD) {.inline.} = self.union1.struct2.dmDisplayOrientation = x
proc dmDisplayOrientation*(self: DEVMODEA): DWORD {.inline.} = self.union1.struct2.dmDisplayOrientation
proc dmDisplayOrientation*(self: var DEVMODEA): var DWORD {.inline.} = self.union1.struct2.dmDisplayOrientation
proc `dmDisplayFixedOutput=`*(self: var DEVMODEA, x: DWORD) {.inline.} = self.union1.struct2.dmDisplayFixedOutput = x
proc dmDisplayFixedOutput*(self: DEVMODEA): DWORD {.inline.} = self.union1.struct2.dmDisplayFixedOutput
proc dmDisplayFixedOutput*(self: var DEVMODEA): var DWORD {.inline.} = self.union1.struct2.dmDisplayFixedOutput
proc `dmDisplayFlags=`*(self: var DEVMODEA, x: DWORD) {.inline.} = self.union2.dmDisplayFlags = x
proc dmDisplayFlags*(self: DEVMODEA): DWORD {.inline.} = self.union2.dmDisplayFlags
proc dmDisplayFlags*(self: var DEVMODEA): var DWORD {.inline.} = self.union2.dmDisplayFlags
proc `dmNup=`*(self: var DEVMODEA, x: DWORD) {.inline.} = self.union2.dmNup = x
proc dmNup*(self: DEVMODEA): DWORD {.inline.} = self.union2.dmNup
proc dmNup*(self: var DEVMODEA): var DWORD {.inline.} = self.union2.dmNup
proc `dmOrientation=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmOrientation = x
proc dmOrientation*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmOrientation
proc dmOrientation*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmOrientation
proc `dmPaperSize=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmPaperSize = x
proc dmPaperSize*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmPaperSize
proc dmPaperSize*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmPaperSize
proc `dmPaperLength=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmPaperLength = x
proc dmPaperLength*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmPaperLength
proc dmPaperLength*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmPaperLength
proc `dmPaperWidth=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmPaperWidth = x
proc dmPaperWidth*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmPaperWidth
proc dmPaperWidth*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmPaperWidth
proc `dmScale=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmScale = x
proc dmScale*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmScale
proc dmScale*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmScale
proc `dmCopies=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmCopies = x
proc dmCopies*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmCopies
proc dmCopies*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmCopies
proc `dmDefaultSource=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmDefaultSource = x
proc dmDefaultSource*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmDefaultSource
proc dmDefaultSource*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmDefaultSource
proc `dmPrintQuality=`*(self: var DEVMODEW, x: int16) {.inline.} = self.union1.struct1.dmPrintQuality = x
proc dmPrintQuality*(self: DEVMODEW): int16 {.inline.} = self.union1.struct1.dmPrintQuality
proc dmPrintQuality*(self: var DEVMODEW): var int16 {.inline.} = self.union1.struct1.dmPrintQuality
proc `dmPosition=`*(self: var DEVMODEW, x: POINTL) {.inline.} = self.union1.struct2.dmPosition = x
proc dmPosition*(self: DEVMODEW): POINTL {.inline.} = self.union1.struct2.dmPosition
proc dmPosition*(self: var DEVMODEW): var POINTL {.inline.} = self.union1.struct2.dmPosition
proc `dmDisplayOrientation=`*(self: var DEVMODEW, x: DWORD) {.inline.} = self.union1.struct2.dmDisplayOrientation = x
proc dmDisplayOrientation*(self: DEVMODEW): DWORD {.inline.} = self.union1.struct2.dmDisplayOrientation
proc dmDisplayOrientation*(self: var DEVMODEW): var DWORD {.inline.} = self.union1.struct2.dmDisplayOrientation
proc `dmDisplayFixedOutput=`*(self: var DEVMODEW, x: DWORD) {.inline.} = self.union1.struct2.dmDisplayFixedOutput = x
proc dmDisplayFixedOutput*(self: DEVMODEW): DWORD {.inline.} = self.union1.struct2.dmDisplayFixedOutput
proc dmDisplayFixedOutput*(self: var DEVMODEW): var DWORD {.inline.} = self.union1.struct2.dmDisplayFixedOutput
proc `dmDisplayFlags=`*(self: var DEVMODEW, x: DWORD) {.inline.} = self.union2.dmDisplayFlags = x
proc dmDisplayFlags*(self: DEVMODEW): DWORD {.inline.} = self.union2.dmDisplayFlags
proc dmDisplayFlags*(self: var DEVMODEW): var DWORD {.inline.} = self.union2.dmDisplayFlags
proc `dmNup=`*(self: var DEVMODEW, x: DWORD) {.inline.} = self.union2.dmNup = x
proc dmNup*(self: DEVMODEW): DWORD {.inline.} = self.union2.dmNup
proc dmNup*(self: var DEVMODEW): var DWORD {.inline.} = self.union2.dmNup
when winimUnicode:
  type
    TEXTMETRIC* = TEXTMETRICW
    LOGFONT* = LOGFONTW
    DEVMODE* = DEVMODEW
    DOCINFO* = DOCINFOW
  proc CreateDC*(pwszDriver: LPCWSTR, pwszDevice: LPCWSTR, pszPort: LPCWSTR, pdm: ptr DEVMODEW): HDC {.winapi, stdcall, dynlib: "gdi32", importc: "CreateDCW".}
  proc CreateFontIndirect*(lplf: ptr LOGFONTW): HFONT {.winapi, stdcall, dynlib: "gdi32", importc: "CreateFontIndirectW".}
  proc DeviceCapabilities*(pDevice: LPCWSTR, pPort: LPCWSTR, fwCapability: WORD, pOutput: LPWSTR, pDevMode: ptr DEVMODEW): int32 {.winapi, stdcall, dynlib: "winspool.drv", importc: "DeviceCapabilitiesW".}
  proc GetCharWidth*(hdc: HDC, iFirst: UINT, iLast: UINT, lpBuffer: LPINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetCharWidthW".}
  proc GetTextExtentPoint32*(hdc: HDC, lpString: LPCWSTR, c: int32, psizl: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetTextExtentPoint32W".}
  proc GetTextMetrics*(hdc: HDC, lptm: LPTEXTMETRICW): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetTextMetricsW".}
  proc StartDoc*(hdc: HDC, lpdi: ptr DOCINFOW): int32 {.winapi, stdcall, dynlib: "gdi32", importc: "StartDocW".}
  proc GetObject*(h: HANDLE, c: int32, pv: LPVOID): int32 {.winapi, stdcall, dynlib: "gdi32", importc: "GetObjectW".}
  proc TextOut*(hdc: HDC, x: int32, y: int32, lpString: LPCWSTR, c: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "TextOutW".}
  proc ExtTextOut*(hdc: HDC, x: int32, y: int32, options: UINT, lprect: ptr RECT, lpString: LPCWSTR, c: UINT, lpDx: ptr INT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "ExtTextOutW".}
when winimAnsi:
  type
    TEXTMETRIC* = TEXTMETRICA
    LOGFONT* = LOGFONTA
    DEVMODE* = DEVMODEA
    DOCINFO* = DOCINFOA
  proc CreateDC*(pwszDriver: LPCSTR, pwszDevice: LPCSTR, pszPort: LPCSTR, pdm: ptr DEVMODEA): HDC {.winapi, stdcall, dynlib: "gdi32", importc: "CreateDCA".}
  proc CreateFontIndirect*(lplf: ptr LOGFONTA): HFONT {.winapi, stdcall, dynlib: "gdi32", importc: "CreateFontIndirectA".}
  proc DeviceCapabilities*(pDevice: LPCSTR, pPort: LPCSTR, fwCapability: WORD, pOutput: LPSTR, pDevMode: ptr DEVMODEA): int32 {.winapi, stdcall, dynlib: "winspool.drv", importc: "DeviceCapabilitiesA".}
  proc GetCharWidth*(hdc: HDC, iFirst: UINT, iLast: UINT, lpBuffer: LPINT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetCharWidthA".}
  proc GetTextExtentPoint32*(hdc: HDC, lpString: LPCSTR, c: int32, psizl: LPSIZE): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetTextExtentPoint32A".}
  proc GetTextMetrics*(hdc: HDC, lptm: LPTEXTMETRICA): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "GetTextMetricsA".}
  proc StartDoc*(hdc: HDC, lpdi: ptr DOCINFOA): int32 {.winapi, stdcall, dynlib: "gdi32", importc: "StartDocA".}
  proc GetObject*(h: HANDLE, c: int32, pv: LPVOID): int32 {.winapi, stdcall, dynlib: "gdi32", importc: "GetObjectA".}
  proc TextOut*(hdc: HDC, x: int32, y: int32, lpString: LPCSTR, c: int32): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "TextOutA".}
  proc ExtTextOut*(hdc: HDC, x: int32, y: int32, options: UINT, lprect: ptr RECT, lpString: LPCSTR, c: UINT, lpDx: ptr INT): WINBOOL {.winapi, stdcall, dynlib: "gdi32", importc: "ExtTextOutA".}
type
  CREATESTRUCTA* {.pure.} = object
    lpCreateParams*: LPVOID
    hInstance*: HINSTANCE
    hMenu*: HMENU
    hwndParent*: HWND
    cy*: int32
    cx*: int32
    y*: int32
    x*: int32
    style*: LONG
    lpszName*: LPCSTR
    lpszClass*: LPCSTR
    dwExStyle*: DWORD
  CREATESTRUCTW* {.pure.} = object
    lpCreateParams*: LPVOID
    hInstance*: HINSTANCE
    hMenu*: HMENU
    hwndParent*: HWND
    cy*: int32
    cx*: int32
    y*: int32
    x*: int32
    style*: LONG
    lpszName*: LPCWSTR
    lpszClass*: LPCWSTR
    dwExStyle*: DWORD
  KBDLLHOOKSTRUCT* {.pure.} = object
    vkCode*: DWORD
    scanCode*: DWORD
    flags*: DWORD
    time*: DWORD
    dwExtraInfo*: ULONG_PTR
  LPKBDLLHOOKSTRUCT* = ptr KBDLLHOOKSTRUCT
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
  WNDCLASSA* {.pure.} = object
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
  LPWNDCLASSA* = ptr WNDCLASSA
  WNDCLASSW* {.pure.} = object
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
  LPWNDCLASSW* = ptr WNDCLASSW
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
  TPMPARAMS* {.pure.} = object
    cbSize*: UINT
    rcExclude*: RECT
  LPTPMPARAMS* = ptr TPMPARAMS
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
  SW_SHOWMINIMIZED* = 2
  SW_SHOWMAXIMIZED* = 3
  SW_MAXIMIZE* = 3
  SW_SHOWNOACTIVATE* = 4
  SW_SHOW* = 5
  SW_MINIMIZE* = 6
  SW_SHOWMINNOACTIVE* = 7
  SW_SHOWNA* = 8
  SW_RESTORE* = 9
  SW_SHOWDEFAULT* = 10
  SW_FORCEMINIMIZE* = 11
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
  WH_MSGFILTER* = -1
  WH_CBT* = 5
  WH_KEYBOARD_LL* = 13
  HCBT_ACTIVATE* = 5
  GWL_STYLE* = -16
  GWL_EXSTYLE* = -20
  GWLP_USERDATA* = -21
  GWLP_ID* = -12
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
  WM_ERASEBKGND* = 0x0014
  WM_SHOWWINDOW* = 0x0018
  WM_CANCELMODE* = 0x001F
  WM_SETCURSOR* = 0x0020
  WM_GETMINMAXINFO* = 0x0024
  WM_DRAWITEM* = 0x002B
  WM_MEASUREITEM* = 0x002C
  WM_SETFONT* = 0x0030
  WM_GETFONT* = 0x0031
  WM_WINDOWPOSCHANGED* = 0x0047
  WM_NOTIFY* = 0x004E
  WM_CONTEXTMENU* = 0x007B
  WM_STYLECHANGED* = 0x007D
  WM_SETICON* = 0x0080
  WM_NCDESTROY* = 0x0082
  WM_NCCALCSIZE* = 0x0083
  WM_NCHITTEST* = 0x0084
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
  WM_NCXBUTTONDOWN* = 0x00AB
  WM_NCXBUTTONUP* = 0x00AC
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
  WM_SYSCOMMAND* = 0x0112
  WM_TIMER* = 0x0113
  WM_HSCROLL* = 0x0114
  WM_VSCROLL* = 0x0115
  WM_MENUSELECT* = 0x011F
  WM_MENURBUTTONUP* = 0x0122
  WM_MENUCOMMAND* = 0x0126
  WM_CHANGEUISTATE* = 0x0127
  WM_UPDATEUISTATE* = 0x0128
  WM_QUERYUISTATE* = 0x0129
  UIS_SET* = 1
  UIS_CLEAR* = 2
  UISF_HIDEFOCUS* = 0x1
  UISF_HIDEACCEL* = 0x2
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
  HTTRANSPARENT* = -1
  HTCLIENT* = 1
  HTCAPTION* = 2
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
  WS_EX_RTLREADING* = 0x00002000
  WS_EX_STATICEDGE* = 0x00020000
  WS_EX_LAYERED* = 0x00080000
  WS_EX_LAYOUTRTL* = 0x00400000
  WS_EX_COMPOSITED* = 0x02000000
  CS_VREDRAW* = 0x0001
  CS_HREDRAW* = 0x0002
  CS_DBLCLKS* = 0x0008
  CS_PARENTDC* = 0x0080
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
  ODT_COMBOBOX* = 3
  ODA_DRAWENTIRE* = 0x0001
  ODA_SELECT* = 0x0002
  ODS_SELECTED* = 0x0001
  ODS_COMBOBOXEDIT* = 0x1000
  PM_REMOVE* = 0x0001
  MOD_ALT* = 0x0001
  MOD_CONTROL* = 0x0002
  MOD_SHIFT* = 0x0004
  MOD_WIN* = 0x0008
  MOD_NOREPEAT* = 0x4000
  CW_USEDEFAULT* = int32 0x80000000'i32
  HWND_DESKTOP* = HWND 0
  LWA_ALPHA* = 0x00000002
  SWP_NOSIZE* = 0x0001
  SWP_NOMOVE* = 0x0002
  SWP_NOZORDER* = 0x0004
  SWP_NOACTIVATE* = 0x0010
  SWP_FRAMECHANGED* = 0x0020
  SWP_SHOWWINDOW* = 0x0040
  SWP_NOOWNERZORDER* = 0x0200
  SWP_DRAWFRAME* = SWP_FRAMECHANGED
  SWP_NOREPOSITION* = SWP_NOOWNERZORDER
  HWND_TOP* = HWND 0
  HWND_BOTTOM* = HWND 1
  HWND_TOPMOST* = HWND(-1)
  HWND_NOTOPMOST* = HWND(-2)
  KEYEVENTF_KEYUP* = 0x0002
  SM_CXSCREEN* = 0
  SM_CYSCREEN* = 1
  SM_CXVSCROLL* = 2
  SM_CYHSCROLL* = 3
  SM_CYCAPTION* = 4
  SM_CXBORDER* = 5
  SM_CYBORDER* = 6
  SM_CYVTHUMB* = 9
  SM_CXHTHUMB* = 10
  SM_CXICON* = 11
  SM_CYICON* = 12
  SM_CXCURSOR* = 13
  SM_CYCURSOR* = 14
  SM_CYMENU* = 15
  SM_CYVSCROLL* = 20
  SM_CXHSCROLL* = 21
  SM_SWAPBUTTON* = 23
  SM_CXMIN* = 28
  SM_CYMIN* = 29
  SM_CXFRAME* = 32
  SM_CYFRAME* = 33
  SM_CXDOUBLECLK* = 36
  SM_CYDOUBLECLK* = 37
  SM_CXICONSPACING* = 38
  SM_CYICONSPACING* = 39
  SM_MENUDROPALIGNMENT* = 40
  SM_PENWINDOWS* = 41
  SM_CXSIZEFRAME* = SM_CXFRAME
  SM_CYSIZEFRAME* = SM_CYFRAME
  SM_CXEDGE* = 45
  SM_CYEDGE* = 46
  SM_CXSMICON* = 49
  SM_CYSMICON* = 50
  SM_CXMENUSIZE* = 54
  SM_CYMENUSIZE* = 55
  SM_NETWORK* = 63
  SM_CXDRAG* = 68
  SM_CYDRAG* = 69
  SM_SHOWSOUNDS* = 70
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
  TPM_LEFTBUTTON* = 0x0000
  TPM_LEFTALIGN* = 0x0000
  TPM_RIGHTALIGN* = 0x0008
  TPM_TOPALIGN* = 0x0000
  TPM_VCENTERALIGN* = 0x0010
  TPM_BOTTOMALIGN* = 0x0020
  TPM_VERTICAL* = 0x0040
  TPM_RETURNCMD* = 0x0100
  TPM_RECURSE* = 0x0001
  TPM_HORPOSANIMATION* = 0x0400
  TPM_HORNEGANIMATION* = 0x0800
  TPM_LAYOUTRTL* = 0x8000
  DT_TOP* = 0x00000000
  DT_LEFT* = 0x00000000
  DT_CENTER* = 0x00000001
  DT_RIGHT* = 0x00000002
  DT_VCENTER* = 0x00000004
  DT_BOTTOM* = 0x00000008
  DT_SINGLELINE* = 0x00000020
  DT_CALCRECT* = 0x00000400
  DT_NOPREFIX* = 0x00000800
  DT_END_ELLIPSIS* = 0x00008000
  DT_HIDEPREFIX* = 0x00100000
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
  COLOR_MENUTEXT* = 7
  COLOR_ACTIVEBORDER* = 10
  COLOR_APPWORKSPACE* = 12
  COLOR_HIGHLIGHT* = 13
  COLOR_HIGHLIGHTTEXT* = 14
  COLOR_BTNFACE* = 15
  COLOR_GRAYTEXT* = 17
  GW_HWNDNEXT* = 2
  GW_OWNER* = 4
  GW_CHILD* = 5
  MF_BYCOMMAND* = 0x00000000
  MF_BYPOSITION* = 0x00000400
  MF_SEPARATOR* = 0x00000800
  MF_ENABLED* = 0x00000000
  MF_GRAYED* = 0x00000001
  MF_DISABLED* = 0x00000002
  MF_CHECKED* = 0x00000008
  MF_STRING* = 0x00000000
  MF_POPUP* = 0x00000010
  MF_MENUBARBREAK* = 0x00000020
  MF_MENUBREAK* = 0x00000040
  MFT_STRING* = MF_STRING
  MFT_SEPARATOR* = MF_SEPARATOR
  MFS_GRAYED* = 0x00000003
  MFS_DISABLED* = MFS_GRAYED
  MFS_CHECKED* = MF_CHECKED
  SC_SIZE* = 0xF000
  SC_MOVE* = 0xF010
  SC_MINIMIZE* = 0xF020
  SC_MAXIMIZE* = 0xF030
  SC_CLOSE* = 0xF060
  SC_RESTORE* = 0xF120
  IDC_ARROW* = MAKEINTRESOURCE(32512)
  IMAGE_BITMAP* = 0
  IMAGE_ICON* = 1
  LR_COPYDELETEORG* = 0x0008
  LR_DEFAULTSIZE* = 0x0040
  LR_CREATEDIBSECTION* = 0x2000
  LR_SHARED* = 0x8000
  DI_NORMAL* = 0x0003
  IDI_ASTERISK* = MAKEINTRESOURCE(32516)
  IDI_INFORMATION* = IDI_ASTERISK
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
  LBN_SETFOCUS* = 4
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
  LB_GETITEMDATA* = 0x0199
  LB_SETITEMDATA* = 0x019A
  LB_SETCARETINDEX* = 0x019E
  LB_GETCARETINDEX* = 0x019F
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
  CBS_OWNERDRAWFIXED* = 0x0010
  CBS_OWNERDRAWVARIABLE* = 0x0020
  CBS_AUTOHSCROLL* = 0x0040
  CBS_SORT* = 0x0100
  CBS_HASSTRINGS* = 0x0200
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
  CB_GETITEMDATA* = 0x0150
  CB_SETITEMDATA* = 0x0151
  CB_SETITEMHEIGHT* = 0x0153
  CB_GETITEMHEIGHT* = 0x0154
  CB_GETDROPPEDSTATE* = 0x0157
  SBS_HORZ* = 0x0000
  SBS_VERT* = 0x0001
  SIF_RANGE* = 0x0001
  SIF_PAGE* = 0x0002
  SIF_POS* = 0x0004
  SIF_TRACKPOS* = 0x0010
  SIF_ALL* = SIF_RANGE or SIF_PAGE or SIF_POS or SIF_TRACKPOS
  SPI_GETNONCLIENTMETRICS* = 0x0029
  SPI_GETKEYBOARDCUES* = 0x100A
  SPI_GETMENUUNDERLINES* = SPI_GETKEYBOARDCUES
  OBJID_VSCROLL* = LONG 0xFFFFFFFB'i32
  OBJID_HSCROLL* = LONG 0xFFFFFFFA'i32
  STATE_SYSTEM_PRESSED* = 0x00000008
  STATE_SYSTEM_INVISIBLE* = 0x00008000
  GA_PARENT* = 1
  GA_ROOT* = 2
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
proc GetMessageTime*(): LONG {.winapi, stdcall, dynlib: "user32", importc.}
proc AttachThreadInput*(idAttach: DWORD, idAttachTo: DWORD, fAttach: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc PostQuitMessage*(nExitCode: int32): VOID {.winapi, stdcall, dynlib: "user32", importc.}
proc IsWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsMenu*(hMenu: HMENU): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsChild*(hWndParent: HWND, hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ShowWindow*(hWnd: HWND, nCmdShow: int32): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetLayeredWindowAttributes*(hwnd: HWND, pcrKey: ptr COLORREF, pbAlpha: ptr BYTE, pdwFlags: ptr DWORD): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetLayeredWindowAttributes*(hwnd: HWND, crKey: COLORREF, bAlpha: BYTE, dwFlags: DWORD): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetWindowPos*(hWnd: HWND, hWndInsertAfter: HWND, X: int32, Y: int32, cx: int32, cy: int32, uFlags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsWindowVisible*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsIconic*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc BringWindowToTop*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
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
proc keybd_event*(bVk: BYTE, bScan: BYTE, dwFlags: DWORD, dwExtraInfo: ULONG_PTR): VOID {.winapi, stdcall, dynlib: "user32", importc.}
proc GetCapture*(): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc SetCapture*(hWnd: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc ReleaseCapture*(): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetTimer*(hWnd: HWND, nIDEvent: UINT_PTR, uElapse: UINT, lpTimerFunc: TIMERPROC): UINT_PTR {.winapi, stdcall, dynlib: "user32", importc.}
proc KillTimer*(hWnd: HWND, uIDEvent: UINT_PTR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc EnableWindow*(hWnd: HWND, bEnable: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IsWindowEnabled*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyAcceleratorTable*(hAccel: HACCEL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSystemMetrics*(nIndex: int32): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMenu*(hWnd: HWND): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc SetMenu*(hWnd: HWND, hMenu: HMENU): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMenuState*(hMenu: HMENU, uId: UINT, uFlags: UINT): UINT {.winapi, stdcall, dynlib: "user32", importc.}
proc DrawMenuBar*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSystemMenu*(hWnd: HWND, bRevert: WINBOOL): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc CreateMenu*(): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc CreatePopupMenu*(): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc DestroyMenu*(hMenu: HMENU): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc EnableMenuItem*(hMenu: HMENU, uIDEnableItem: UINT, uEnable: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSubMenu*(hMenu: HMENU, nPos: int32): HMENU {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMenuItemCount*(hMenu: HMENU): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc RemoveMenu*(hMenu: HMENU, uPosition: UINT, uFlags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc TrackPopupMenu*(hMenu: HMENU, uFlags: UINT, x: int32, y: int32, nReserved: int32, hWnd: HWND, prcRect: ptr RECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc TrackPopupMenuEx*(P1: HMENU, P2: UINT, P3: int32, P4: int32, P5: HWND, P6: LPTPMPARAMS): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetMenuInfo*(P1: HMENU, P2: LPMENUINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetMenuInfo*(P1: HMENU, P2: LPCMENUINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc DrawIcon*(hDC: HDC, X: int32, Y: int32, hIcon: HICON): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc UpdateWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetForegroundWindow*(): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc SetForegroundWindow*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetDC*(hWnd: HWND): HDC {.winapi, stdcall, dynlib: "user32", importc.}
proc GetWindowDC*(hWnd: HWND): HDC {.winapi, stdcall, dynlib: "user32", importc.}
proc ReleaseDC*(hWnd: HWND, hDC: HDC): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc BeginPaint*(hWnd: HWND, lpPaint: LPPAINTSTRUCT): HDC {.winapi, stdcall, dynlib: "user32", importc.}
proc EndPaint*(hWnd: HWND, lpPaint: ptr PAINTSTRUCT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetUpdateRect*(hWnd: HWND, lpRect: LPRECT, bErase: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetWindowRgn*(hWnd: HWND, hRgn: HRGN, bRedraw: WINBOOL): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc InvalidateRect*(hWnd: HWND, lpRect: ptr RECT, bErase: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc RedrawWindow*(hWnd: HWND, lprcUpdate: ptr RECT, hrgnUpdate: HRGN, flags: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ShowScrollBar*(hWnd: HWND, wBar: int32, bShow: WINBOOL): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc EnableScrollBar*(hWnd: HWND, wSBflags: UINT, wArrows: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetClientRect*(hWnd: HWND, lpRect: LPRECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetWindowRect*(hWnd: HWND, lpRect: LPRECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetCursorPos*(X: int32, Y: int32): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc SetCursor*(hCursor: HCURSOR): HCURSOR {.winapi, stdcall, dynlib: "user32", importc.}
proc GetCursorPos*(lpPoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc HideCaret*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ShowCaret*(hWnd: HWND): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ClientToScreen*(hWnd: HWND, lpPoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc ScreenToClient*(hWnd: HWND, lpPoint: LPPOINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc MapWindowPoints*(hWndFrom: HWND, hWndTo: HWND, lpPoints: LPPOINT, cPoints: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc WindowFromPoint*(Point: POINT): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetSysColor*(nIndex: int32): DWORD {.winapi, stdcall, dynlib: "user32", importc.}
proc DrawFocusRect*(hDC: HDC, lprc: ptr RECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc FillRect*(hDC: HDC, lprc: ptr RECT, hbr: HBRUSH): int32 {.winapi, stdcall, dynlib: "user32", importc.}
proc InflateRect*(lprc: LPRECT, dx: int32, dy: int32): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc IntersectRect*(lprcDst: LPRECT, lprcSrc1: ptr RECT, lprcSrc2: ptr RECT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc OffsetRect*(lprc: LPRECT, dx: int32, dy: int32): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc PtInRect*(lprc: ptr RECT, pt: POINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetDesktopWindow*(): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc GetParent*(hWnd: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc SetParent*(hWndChild: HWND, hWndNewParent: HWND): HWND {.winapi, stdcall, dynlib: "user32", importc.}
proc EnumChildWindows*(hWndParent: HWND, lpEnumFunc: WNDENUMPROC, lParam: LPARAM): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetWindowThreadProcessId*(hWnd: HWND, lpdwProcessId: LPDWORD): DWORD {.winapi, stdcall, dynlib: "user32", importc.}
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
proc SetProcessDPIAware*(): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetScrollBarInfo*(hwnd: HWND, idObject: LONG, psbi: PSCROLLBARINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetComboBoxInfo*(hwndCombo: HWND, pcbi: PCOMBOBOXINFO): WINBOOL {.winapi, stdcall, dynlib: "user32", importc.}
proc GetAncestor*(hwnd: HWND, gaFlags: UINT): HWND {.winapi, stdcall, dynlib: "user32", importc.}
template MAKEWPARAM*(l: untyped, h: untyped): WPARAM = WPARAM MAKELONG(l, h)
template MAKELPARAM*(l: untyped, h: untyped): LPARAM = LPARAM MAKELONG(l, h)
template GET_WHEEL_DELTA_WPARAM*(wParam: untyped): SHORT = cast[SHORT](HIWORD(wParam))
when winimAnsi:
  proc CreateWindowEx*(dwExStyle: DWORD, lpClassName: LPCSTR, lpWindowName: LPCSTR, dwStyle: DWORD, X: int32, Y: int32, nWidth: int32, nHeight: int32, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND {.winapi, stdcall, dynlib: "user32", importc: "CreateWindowExA".}
when winimUnicode:
  proc CreateWindowEx*(dwExStyle: DWORD, lpClassName: LPCWSTR, lpWindowName: LPCWSTR, dwStyle: DWORD, X: int32, Y: int32, nWidth: int32, nHeight: int32, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND {.winapi, stdcall, dynlib: "user32", importc: "CreateWindowExW".}
  type
    WNDCLASSEX* = WNDCLASSEXW
    WNDCLASS* = WNDCLASSW
    CREATESTRUCT* = CREATESTRUCTW
    MENUITEMINFO* = MENUITEMINFOW
    NONCLIENTMETRICS* = NONCLIENTMETRICSW
  proc RegisterWindowMessage*(lpString: LPCWSTR): UINT {.winapi, stdcall, dynlib: "user32", importc: "RegisterWindowMessageW".}
  proc GetMessage*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMessageW".}
  proc DispatchMessage*(lpMsg: ptr MSG): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DispatchMessageW".}
  proc PeekMessage*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "PeekMessageW".}
  proc SendMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "SendMessageW".}
  proc PostMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "PostMessageW".}
  proc DefWindowProc*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DefWindowProcW".}
  proc CallWindowProc*(lpPrevWndFunc: WNDPROC, hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "CallWindowProcW".}
  proc UnregisterClass*(lpClassName: LPCWSTR, hInstance: HINSTANCE): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "UnregisterClassW".}
  proc GetClassInfo*(hInstance: HINSTANCE, lpClassName: LPCWSTR, lpWndClass: LPWNDCLASSW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetClassInfoW".}
  proc RegisterClassEx*(P1: ptr WNDCLASSEXW): ATOM {.winapi, stdcall, dynlib: "user32", importc: "RegisterClassExW".}
  proc CreateAcceleratorTable*(paccel: LPACCEL, cAccel: int32): HACCEL {.winapi, stdcall, dynlib: "user32", importc: "CreateAcceleratorTableW".}
  proc TranslateAccelerator*(hWnd: HWND, hAccTable: HACCEL, lpMsg: LPMSG): int32 {.winapi, stdcall, dynlib: "user32", importc: "TranslateAcceleratorW".}
  proc InsertMenuItem*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmi: LPCMENUITEMINFOW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "InsertMenuItemW".}
  proc GetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmii: LPMENUITEMINFOW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMenuItemInfoW".}
  proc SetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPositon: WINBOOL, lpmii: LPCMENUITEMINFOW): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetMenuItemInfoW".}
  proc DrawText*(hdc: HDC, lpchText: LPCWSTR, cchText: int32, lprc: LPRECT, format: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc: "DrawTextW".}
  proc SetWindowText*(hWnd: HWND, lpString: LPCWSTR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetWindowTextW".}
  proc GetWindowText*(hWnd: HWND, lpString: LPWSTR, nMaxCount: int32): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextW".}
  proc GetWindowTextLength*(hWnd: HWND): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextLengthW".}
  proc MessageBox*(hWnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc: "MessageBoxW".}
  proc FindWindow*(lpClassName: LPCWSTR, lpWindowName: LPCWSTR): HWND {.winapi, stdcall, dynlib: "user32", importc: "FindWindowW".}
  proc FindWindowEx*(hWndParent: HWND, hWndChildAfter: HWND, lpszClass: LPCWSTR, lpszWindow: LPCWSTR): HWND {.winapi, stdcall, dynlib: "user32", importc: "FindWindowExW".}
  proc GetClassName*(hWnd: HWND, lpClassName: LPWSTR, nMaxCount: int32): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetClassNameW".}
  proc SetWindowsHookEx*(idHook: int32, lpfn: HOOKPROC, hmod: HINSTANCE, dwThreadId: DWORD): HHOOK {.winapi, stdcall, dynlib: "user32", importc: "SetWindowsHookExW".}
  proc LoadCursor*(hInstance: HINSTANCE, lpCursorName: LPCWSTR): HCURSOR {.winapi, stdcall, dynlib: "user32", importc: "LoadCursorW".}
  proc LoadImage*(hInst: HINSTANCE, name: LPCWSTR, `type`: UINT, cx: int32, cy: int32, fuLoad: UINT): HANDLE {.winapi, stdcall, dynlib: "user32", importc: "LoadImageW".}
  proc IsDialogMessage*(hDlg: HWND, lpMsg: LPMSG): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "IsDialogMessageW".}
  proc SystemParametersInfo*(uiAction: UINT, uiParam: UINT, pvParam: PVOID, fWinIni: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SystemParametersInfoW".}
when winimAnsi:
  type
    WNDCLASSEX* = WNDCLASSEXA
    WNDCLASS* = WNDCLASSA
    CREATESTRUCT* = CREATESTRUCTA
    MENUITEMINFO* = MENUITEMINFOA
    NONCLIENTMETRICS* = NONCLIENTMETRICSA
  proc RegisterWindowMessage*(lpString: LPCSTR): UINT {.winapi, stdcall, dynlib: "user32", importc: "RegisterWindowMessageA".}
  proc GetMessage*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMessageA".}
  proc DispatchMessage*(lpMsg: ptr MSG): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DispatchMessageA".}
  proc PeekMessage*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "PeekMessageA".}
  proc SendMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "SendMessageA".}
  proc PostMessage*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "PostMessageA".}
  proc DefWindowProc*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "DefWindowProcA".}
  proc CallWindowProc*(lpPrevWndFunc: WNDPROC, hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.winapi, stdcall, dynlib: "user32", importc: "CallWindowProcA".}
  proc UnregisterClass*(lpClassName: LPCSTR, hInstance: HINSTANCE): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "UnregisterClassA".}
  proc GetClassInfo*(hInstance: HINSTANCE, lpClassName: LPCSTR, lpWndClass: LPWNDCLASSA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetClassInfoA".}
  proc RegisterClassEx*(P1: ptr WNDCLASSEXA): ATOM {.winapi, stdcall, dynlib: "user32", importc: "RegisterClassExA".}
  proc CreateAcceleratorTable*(paccel: LPACCEL, cAccel: int32): HACCEL {.winapi, stdcall, dynlib: "user32", importc: "CreateAcceleratorTableA".}
  proc TranslateAccelerator*(hWnd: HWND, hAccTable: HACCEL, lpMsg: LPMSG): int32 {.winapi, stdcall, dynlib: "user32", importc: "TranslateAcceleratorA".}
  proc InsertMenuItem*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmi: LPCMENUITEMINFOA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "InsertMenuItemA".}
  proc GetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPosition: WINBOOL, lpmii: LPMENUITEMINFOA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "GetMenuItemInfoA".}
  proc SetMenuItemInfo*(hmenu: HMENU, item: UINT, fByPositon: WINBOOL, lpmii: LPCMENUITEMINFOA): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetMenuItemInfoA".}
  proc DrawText*(hdc: HDC, lpchText: LPCSTR, cchText: int32, lprc: LPRECT, format: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc: "DrawTextA".}
  proc SetWindowText*(hWnd: HWND, lpString: LPCSTR): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SetWindowTextA".}
  proc GetWindowText*(hWnd: HWND, lpString: LPSTR, nMaxCount: int32): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextA".}
  proc GetWindowTextLength*(hWnd: HWND): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetWindowTextLengthA".}
  proc MessageBox*(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 {.winapi, stdcall, dynlib: "user32", importc: "MessageBoxA".}
  proc FindWindow*(lpClassName: LPCSTR, lpWindowName: LPCSTR): HWND {.winapi, stdcall, dynlib: "user32", importc: "FindWindowA".}
  proc FindWindowEx*(hWndParent: HWND, hWndChildAfter: HWND, lpszClass: LPCSTR, lpszWindow: LPCSTR): HWND {.winapi, stdcall, dynlib: "user32", importc: "FindWindowExA".}
  proc GetClassName*(hWnd: HWND, lpClassName: LPSTR, nMaxCount: int32): int32 {.winapi, stdcall, dynlib: "user32", importc: "GetClassNameA".}
  proc SetWindowsHookEx*(idHook: int32, lpfn: HOOKPROC, hmod: HINSTANCE, dwThreadId: DWORD): HHOOK {.winapi, stdcall, dynlib: "user32", importc: "SetWindowsHookExA".}
  proc LoadCursor*(hInstance: HINSTANCE, lpCursorName: LPCSTR): HCURSOR {.winapi, stdcall, dynlib: "user32", importc: "LoadCursorA".}
  proc LoadImage*(hInst: HINSTANCE, name: LPCSTR, `type`: UINT, cx: int32, cy: int32, fuLoad: UINT): HANDLE {.winapi, stdcall, dynlib: "user32", importc: "LoadImageA".}
  proc IsDialogMessage*(hDlg: HWND, lpMsg: LPMSG): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "IsDialogMessageA".}
  proc SystemParametersInfo*(uiAction: UINT, uiParam: UINT, pvParam: PVOID, fWinIni: UINT): WINBOOL {.winapi, stdcall, dynlib: "user32", importc: "SystemParametersInfoA".}
when winimUnicode and winimCpu64:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongPtrW".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongPtrW".}
when winimAnsi and winimCpu64:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongPtrA".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongPtrA".}
when winimUnicode and winimCpu32:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongW".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG): LONG {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongW".}
when winimAnsi and winimCpu32:
  proc GetWindowLongPtr*(hWnd: HWND, nIndex: int32): LONG {.winapi, stdcall, dynlib: "user32", importc: "GetWindowLongA".}
  proc SetWindowLongPtr*(hWnd: HWND, nIndex: int32, dwNewLong: LONG): LONG {.winapi, stdcall, dynlib: "user32", importc: "SetWindowLongA".}
const
  CP_ACP* = 0
type
  REGSAM* = ACCESS_MASK
const
  HKEY_CURRENT_USER* = HKEY 0x80000001'i32
proc RegCloseKey*(hKey: HKEY): LONG {.winapi, stdcall, dynlib: "advapi32", importc.}
when winimUnicode:
  proc RegCreateKeyEx*(hKey: HKEY, lpSubKey: LPCWSTR, Reserved: DWORD, lpClass: LPWSTR, dwOptions: DWORD, samDesired: REGSAM, lpSecurityAttributes: LPSECURITY_ATTRIBUTES, phkResult: PHKEY, lpdwDisposition: LPDWORD): LONG {.winapi, stdcall, dynlib: "advapi32", importc: "RegCreateKeyExW".}
  proc RegSetValueEx*(hKey: HKEY, lpValueName: LPCWSTR, Reserved: DWORD, dwType: DWORD, lpData: ptr BYTE, cbData: DWORD): LONG {.winapi, stdcall, dynlib: "advapi32", importc: "RegSetValueExW".}
when winimAnsi:
  proc RegCreateKeyEx*(hKey: HKEY, lpSubKey: LPCSTR, Reserved: DWORD, lpClass: LPSTR, dwOptions: DWORD, samDesired: REGSAM, lpSecurityAttributes: LPSECURITY_ATTRIBUTES, phkResult: PHKEY, lpdwDisposition: LPDWORD): LONG {.winapi, stdcall, dynlib: "advapi32", importc: "RegCreateKeyExA".}
  proc RegSetValueEx*(hKey: HKEY, lpValueName: LPCSTR, Reserved: DWORD, dwType: DWORD, lpData: ptr BYTE, cbData: DWORD): LONG {.winapi, stdcall, dynlib: "advapi32", importc: "RegSetValueExA".}
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
proc send*(s: SOCKET, buf: ptr char, len: int32, flags: int32): int32 {.winapi, stdcall, dynlib: "ws2_32", importc.}
const
  network* = 3
  batch* = 4
type
  Percentage* = UINT8
  VARTYPE* = uint16
  TYPEKIND* = int32
  CALLCONV* = int32
  FUNCKIND* = int32
  INVOKEKIND* = int32
  VARKIND* = int32
  DESCKIND* = int32
  SYSKIND* = int32
  READYSTATE* = int32
  OLECMDF* = int32
  OLECMDEXECOPT* = int32
  OLECMDID* = int32
  GETPROPERTYSTOREFLAGS* = int32
  CLIPFORMAT* = WORD
  DISPID* = LONG
  HREFTYPE* = DWORD
  SCODE* = LONG
  HMETAFILEPICT* = HANDLE
  DATE* = float64
  CY_STRUCT1* {.pure.} = object
    Lo*: int32
    Hi*: int32
  CY* {.pure, union.} = object
    struct1*: CY_STRUCT1
    int64*: LONGLONG
  DECIMAL_UNION1_STRUCT1* {.pure.} = object
    scale*: BYTE
    sign*: BYTE
  DECIMAL_UNION1* {.pure, union.} = object
    struct1*: DECIMAL_UNION1_STRUCT1
    signscale*: USHORT
  DECIMAL_UNION2_STRUCT1* {.pure.} = object
    Lo32*: ULONG
    Mid32*: ULONG
  DECIMAL_UNION2* {.pure, union.} = object
    struct1*: DECIMAL_UNION2_STRUCT1
    Lo64*: ULONGLONG
  DECIMAL* {.pure.} = object
    wReserved*: USHORT
    union1*: DECIMAL_UNION1
    Hi32*: ULONG
    union2*: DECIMAL_UNION2
  VARIANT_BOOL* = int16
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
  IEnumUnknown* {.pure.} = object
    lpVtbl*: ptr IEnumUnknownVtbl
  IEnumUnknownVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumUnknown, celt: ULONG, rgelt: ptr ptr IUnknown, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumUnknown, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumUnknown): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumUnknown, ppenum: ptr ptr IEnumUnknown): HRESULT {.stdcall.}
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
  LPCOLESTR* = ptr OLECHAR
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
  SAFEARRAYBOUND* {.pure.} = object
    cElements*: ULONG
    lLbound*: LONG
  MEMBERID* = DISPID
  ARRAYDESC* {.pure.} = object
    tdescElem*: TYPEDESC
    cDims*: USHORT
    rgbounds*: array[1, SAFEARRAYBOUND]
  TYPEDESC_UNION1* {.pure, union.} = object
    lptdesc*: ptr TYPEDESC
    lpadesc*: ptr ARRAYDESC
    hreftype*: HREFTYPE
  TYPEDESC* {.pure.} = object
    union1*: TYPEDESC_UNION1
    vt*: VARTYPE
  IDLDESC* {.pure.} = object
    dwReserved*: ULONG_PTR
    wIDLFlags*: USHORT
  TYPEATTR* {.pure.} = object
    guid*: GUID
    lcid*: LCID
    dwReserved*: DWORD
    memidConstructor*: MEMBERID
    memidDestructor*: MEMBERID
    lpstrSchema*: LPOLESTR
    cbSizeInstance*: ULONG
    typekind*: TYPEKIND
    cFuncs*: WORD
    cVars*: WORD
    cImplTypes*: WORD
    cbSizeVft*: WORD
    cbAlignment*: WORD
    wTypeFlags*: WORD
    wMajorVerNum*: WORD
    wMinorVerNum*: WORD
    tdescAlias*: TYPEDESC
    idldescType*: IDLDESC
  SAFEARRAY* {.pure.} = object
    cDims*: USHORT
    fFeatures*: USHORT
    cbElements*: ULONG
    cLocks*: ULONG
    pvData*: PVOID
    rgsabound*: array[1, SAFEARRAYBOUND]
  IRecordInfo* {.pure.} = object
    lpVtbl*: ptr IRecordInfoVtbl
  IRecordInfoVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    RecordInit*: proc(self: ptr IRecordInfo, pvNew: PVOID): HRESULT {.stdcall.}
    RecordClear*: proc(self: ptr IRecordInfo, pvExisting: PVOID): HRESULT {.stdcall.}
    RecordCopy*: proc(self: ptr IRecordInfo, pvExisting: PVOID, pvNew: PVOID): HRESULT {.stdcall.}
    GetGuid*: proc(self: ptr IRecordInfo, pguid: ptr GUID): HRESULT {.stdcall.}
    GetName*: proc(self: ptr IRecordInfo, pbstrName: ptr BSTR): HRESULT {.stdcall.}
    GetSize*: proc(self: ptr IRecordInfo, pcbSize: ptr ULONG): HRESULT {.stdcall.}
    GetTypeInfo*: proc(self: ptr IRecordInfo, ppTypeInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
    GetField*: proc(self: ptr IRecordInfo, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.stdcall.}
    GetFieldNoCopy*: proc(self: ptr IRecordInfo, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT, ppvDataCArray: ptr PVOID): HRESULT {.stdcall.}
    PutField*: proc(self: ptr IRecordInfo, wFlags: ULONG, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.stdcall.}
    PutFieldNoCopy*: proc(self: ptr IRecordInfo, wFlags: ULONG, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.stdcall.}
    GetFieldNames*: proc(self: ptr IRecordInfo, pcNames: ptr ULONG, rgBstrNames: ptr BSTR): HRESULT {.stdcall.}
    IsMatchingType*: proc(self: ptr IRecordInfo, pRecordInfo: ptr IRecordInfo): WINBOOL {.stdcall.}
    RecordCreate*: proc(self: ptr IRecordInfo): PVOID {.stdcall.}
    RecordCreateCopy*: proc(self: ptr IRecordInfo, pvSource: PVOID, ppvDest: ptr PVOID): HRESULT {.stdcall.}
    RecordDestroy*: proc(self: ptr IRecordInfo, pvRecord: PVOID): HRESULT {.stdcall.}
  VARIANT_UNION1_STRUCT1_UNION1_STRUCT1* {.pure.} = object
    pvRecord*: PVOID
    pRecInfo*: ptr IRecordInfo
  VARIANT_UNION1_STRUCT1_UNION1* {.pure, union.} = object
    llVal*: LONGLONG
    lVal*: LONG
    bVal*: BYTE
    iVal*: SHORT
    fltVal*: FLOAT
    dblVal*: DOUBLE
    boolVal*: VARIANT_BOOL
    scode*: SCODE
    cyVal*: CY
    date*: DATE
    bstrVal*: BSTR
    punkVal*: ptr IUnknown
    pdispVal*: ptr IDispatch
    parray*: ptr SAFEARRAY
    pbVal*: ptr BYTE
    piVal*: ptr SHORT
    plVal*: ptr LONG
    pllVal*: ptr LONGLONG
    pfltVal*: ptr FLOAT
    pdblVal*: ptr DOUBLE
    pboolVal*: ptr VARIANT_BOOL
    pscode*: ptr SCODE
    pcyVal*: ptr CY
    pdate*: ptr DATE
    pbstrVal*: ptr BSTR
    ppunkVal*: ptr ptr IUnknown
    ppdispVal*: ptr ptr IDispatch
    pparray*: ptr ptr SAFEARRAY
    pvarVal*: ptr VARIANT
    byref*: PVOID
    cVal*: CHAR
    uiVal*: USHORT
    ulVal*: ULONG
    ullVal*: ULONGLONG
    intVal*: INT
    uintVal*: UINT
    pdecVal*: ptr DECIMAL
    pcVal*: ptr CHAR
    puiVal*: ptr USHORT
    pulVal*: ptr ULONG
    pullVal*: ptr ULONGLONG
    pintVal*: ptr INT
    puintVal*: ptr UINT
    struct1*: VARIANT_UNION1_STRUCT1_UNION1_STRUCT1
  VARIANT_UNION1_STRUCT1* {.pure.} = object
    vt*: VARTYPE
    wReserved1*: WORD
    wReserved2*: WORD
    wReserved3*: WORD
    union1*: VARIANT_UNION1_STRUCT1_UNION1
  VARIANT_UNION1* {.pure, union.} = object
    struct1*: VARIANT_UNION1_STRUCT1
    decVal*: DECIMAL
  VARIANT* {.pure.} = object
    union1*: VARIANT_UNION1
  VARIANTARG* = VARIANT
  PARAMDESCEX* {.pure.} = object
    cBytes*: ULONG
    varDefaultValue*: VARIANTARG
  LPPARAMDESCEX* = ptr PARAMDESCEX
  PARAMDESC* {.pure.} = object
    pparamdescex*: LPPARAMDESCEX
    wParamFlags*: USHORT
  ELEMDESC_UNION1* {.pure, union.} = object
    idldesc*: IDLDESC
    paramdesc*: PARAMDESC
  ELEMDESC* {.pure.} = object
    tdesc*: TYPEDESC
    union1*: ELEMDESC_UNION1
  FUNCDESC* {.pure.} = object
    memid*: MEMBERID
    lprgscode*: ptr SCODE
    lprgelemdescParam*: ptr ELEMDESC
    funckind*: FUNCKIND
    invkind*: INVOKEKIND
    callconv*: CALLCONV
    cParams*: SHORT
    cParamsOpt*: SHORT
    oVft*: SHORT
    cScodes*: SHORT
    elemdescFunc*: ELEMDESC
    wFuncFlags*: WORD
  VARDESC_UNION1* {.pure, union.} = object
    oInst*: ULONG
    lpvarValue*: ptr VARIANT
  VARDESC* {.pure.} = object
    memid*: MEMBERID
    lpstrSchema*: LPOLESTR
    union1*: VARDESC_UNION1
    elemdescVar*: ELEMDESC
    wVarFlags*: WORD
    varkind*: VARKIND
  BINDPTR* {.pure, union.} = object
    lpfuncdesc*: ptr FUNCDESC
    lpvardesc*: ptr VARDESC
    lptcomp*: ptr ITypeComp
  ITypeComp* {.pure.} = object
    lpVtbl*: ptr ITypeCompVtbl
  ITypeCompVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Bind*: proc(self: ptr ITypeComp, szName: LPOLESTR, lHashVal: ULONG, wFlags: WORD, ppTInfo: ptr ptr ITypeInfo, pDescKind: ptr DESCKIND, pBindPtr: ptr BINDPTR): HRESULT {.stdcall.}
    BindType*: proc(self: ptr ITypeComp, szName: LPOLESTR, lHashVal: ULONG, ppTInfo: ptr ptr ITypeInfo, ppTComp: ptr ptr ITypeComp): HRESULT {.stdcall.}
  DISPPARAMS* {.pure.} = object
    rgvarg*: ptr VARIANTARG
    rgdispidNamedArgs*: ptr DISPID
    cArgs*: UINT
    cNamedArgs*: UINT
  EXCEPINFO* {.pure.} = object
    wCode*: WORD
    wReserved*: WORD
    bstrSource*: BSTR
    bstrDescription*: BSTR
    bstrHelpFile*: BSTR
    dwHelpContext*: DWORD
    pvReserved*: PVOID
    pfnDeferredFillIn*: proc(P1: ptr EXCEPINFO): HRESULT {.stdcall.}
    scode*: SCODE
  TLIBATTR* {.pure.} = object
    guid*: GUID
    lcid*: LCID
    syskind*: SYSKIND
    wMajorVerNum*: WORD
    wMinorVerNum*: WORD
    wLibFlags*: WORD
  ITypeLib* {.pure.} = object
    lpVtbl*: ptr ITypeLibVtbl
  ITypeLibVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetTypeInfoCount*: proc(self: ptr ITypeLib): UINT {.stdcall.}
    GetTypeInfo*: proc(self: ptr ITypeLib, index: UINT, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
    GetTypeInfoType*: proc(self: ptr ITypeLib, index: UINT, pTKind: ptr TYPEKIND): HRESULT {.stdcall.}
    GetTypeInfoOfGuid*: proc(self: ptr ITypeLib, guid: REFGUID, ppTinfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
    GetLibAttr*: proc(self: ptr ITypeLib, ppTLibAttr: ptr ptr TLIBATTR): HRESULT {.stdcall.}
    GetTypeComp*: proc(self: ptr ITypeLib, ppTComp: ptr ptr ITypeComp): HRESULT {.stdcall.}
    GetDocumentation*: proc(self: ptr ITypeLib, index: INT, pBstrName: ptr BSTR, pBstrDocString: ptr BSTR, pdwHelpContext: ptr DWORD, pBstrHelpFile: ptr BSTR): HRESULT {.stdcall.}
    IsName*: proc(self: ptr ITypeLib, szNameBuf: LPOLESTR, lHashVal: ULONG, pfName: ptr WINBOOL): HRESULT {.stdcall.}
    FindName*: proc(self: ptr ITypeLib, szNameBuf: LPOLESTR, lHashVal: ULONG, ppTInfo: ptr ptr ITypeInfo, rgMemId: ptr MEMBERID, pcFound: ptr USHORT): HRESULT {.stdcall.}
    ReleaseTLibAttr*: proc(self: ptr ITypeLib, pTLibAttr: ptr TLIBATTR): void {.stdcall.}
  ITypeInfo* {.pure.} = object
    lpVtbl*: ptr ITypeInfoVtbl
  ITypeInfoVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetTypeAttr*: proc(self: ptr ITypeInfo, ppTypeAttr: ptr ptr TYPEATTR): HRESULT {.stdcall.}
    GetTypeComp*: proc(self: ptr ITypeInfo, ppTComp: ptr ptr ITypeComp): HRESULT {.stdcall.}
    GetFuncDesc*: proc(self: ptr ITypeInfo, index: UINT, ppFuncDesc: ptr ptr FUNCDESC): HRESULT {.stdcall.}
    GetVarDesc*: proc(self: ptr ITypeInfo, index: UINT, ppVarDesc: ptr ptr VARDESC): HRESULT {.stdcall.}
    GetNames*: proc(self: ptr ITypeInfo, memid: MEMBERID, rgBstrNames: ptr BSTR, cMaxNames: UINT, pcNames: ptr UINT): HRESULT {.stdcall.}
    GetRefTypeOfImplType*: proc(self: ptr ITypeInfo, index: UINT, pRefType: ptr HREFTYPE): HRESULT {.stdcall.}
    GetImplTypeFlags*: proc(self: ptr ITypeInfo, index: UINT, pImplTypeFlags: ptr INT): HRESULT {.stdcall.}
    GetIDsOfNames*: proc(self: ptr ITypeInfo, rgszNames: ptr LPOLESTR, cNames: UINT, pMemId: ptr MEMBERID): HRESULT {.stdcall.}
    Invoke*: proc(self: ptr ITypeInfo, pvInstance: PVOID, memid: MEMBERID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.stdcall.}
    GetDocumentation*: proc(self: ptr ITypeInfo, memid: MEMBERID, pBstrName: ptr BSTR, pBstrDocString: ptr BSTR, pdwHelpContext: ptr DWORD, pBstrHelpFile: ptr BSTR): HRESULT {.stdcall.}
    GetDllEntry*: proc(self: ptr ITypeInfo, memid: MEMBERID, invKind: INVOKEKIND, pBstrDllName: ptr BSTR, pBstrName: ptr BSTR, pwOrdinal: ptr WORD): HRESULT {.stdcall.}
    GetRefTypeInfo*: proc(self: ptr ITypeInfo, hRefType: HREFTYPE, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
    AddressOfMember*: proc(self: ptr ITypeInfo, memid: MEMBERID, invKind: INVOKEKIND, ppv: ptr PVOID): HRESULT {.stdcall.}
    CreateInstance*: proc(self: ptr ITypeInfo, pUnkOuter: ptr IUnknown, riid: REFIID, ppvObj: ptr PVOID): HRESULT {.stdcall.}
    GetMops*: proc(self: ptr ITypeInfo, memid: MEMBERID, pBstrMops: ptr BSTR): HRESULT {.stdcall.}
    GetContainingTypeLib*: proc(self: ptr ITypeInfo, ppTLib: ptr ptr ITypeLib, pIndex: ptr UINT): HRESULT {.stdcall.}
    ReleaseTypeAttr*: proc(self: ptr ITypeInfo, pTypeAttr: ptr TYPEATTR): void {.stdcall.}
    ReleaseFuncDesc*: proc(self: ptr ITypeInfo, pFuncDesc: ptr FUNCDESC): void {.stdcall.}
    ReleaseVarDesc*: proc(self: ptr ITypeInfo, pVarDesc: ptr VARDESC): void {.stdcall.}
  IDispatch* {.pure.} = object
    lpVtbl*: ptr IDispatchVtbl
  IDispatchVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetTypeInfoCount*: proc(self: ptr IDispatch, pctinfo: ptr UINT): HRESULT {.stdcall.}
    GetTypeInfo*: proc(self: ptr IDispatch, iTInfo: UINT, lcid: LCID, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
    GetIDsOfNames*: proc(self: ptr IDispatch, riid: REFIID, rgszNames: ptr LPOLESTR, cNames: UINT, lcid: LCID, rgDispId: ptr DISPID): HRESULT {.stdcall.}
    Invoke*: proc(self: ptr IDispatch, dispIdMember: DISPID, riid: REFIID, lcid: LCID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.stdcall.}
  IParseDisplayName* {.pure.} = object
    lpVtbl*: ptr IParseDisplayNameVtbl
  IParseDisplayNameVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    ParseDisplayName*: proc(self: ptr IParseDisplayName, pbc: ptr IBindCtx, pszDisplayName: LPOLESTR, pchEaten: ptr ULONG, ppmkOut: ptr ptr IMoniker): HRESULT {.stdcall.}
  IOleContainer* {.pure.} = object
    lpVtbl*: ptr IOleContainerVtbl
  IOleContainerVtbl* {.pure, inheritable.} = object of IParseDisplayNameVtbl
    EnumObjects*: proc(self: ptr IOleContainer, grfFlags: DWORD, ppenum: ptr ptr IEnumUnknown): HRESULT {.stdcall.}
    LockContainer*: proc(self: ptr IOleContainer, fLock: WINBOOL): HRESULT {.stdcall.}
  IOleClientSite* {.pure.} = object
    lpVtbl*: ptr IOleClientSiteVtbl
  IOleClientSiteVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    SaveObject*: proc(self: ptr IOleClientSite): HRESULT {.stdcall.}
    GetMoniker*: proc(self: ptr IOleClientSite, dwAssign: DWORD, dwWhichMoniker: DWORD, ppmk: ptr ptr IMoniker): HRESULT {.stdcall.}
    GetContainer*: proc(self: ptr IOleClientSite, ppContainer: ptr ptr IOleContainer): HRESULT {.stdcall.}
    ShowObject*: proc(self: ptr IOleClientSite): HRESULT {.stdcall.}
    OnShowWindow*: proc(self: ptr IOleClientSite, fShow: WINBOOL): HRESULT {.stdcall.}
    RequestNewObjectLayout*: proc(self: ptr IOleClientSite): HRESULT {.stdcall.}
  OLEVERB* {.pure.} = object
    lVerb*: LONG
    lpszVerbName*: LPOLESTR
    fuFlags*: DWORD
    grfAttribs*: DWORD
  LPOLEVERB* = ptr OLEVERB
  IEnumOLEVERB* {.pure.} = object
    lpVtbl*: ptr IEnumOLEVERBVtbl
  IEnumOLEVERBVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumOLEVERB, celt: ULONG, rgelt: LPOLEVERB, pceltFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumOLEVERB, celt: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumOLEVERB): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumOLEVERB, ppenum: ptr ptr IEnumOLEVERB): HRESULT {.stdcall.}
  IOleObject* {.pure.} = object
    lpVtbl*: ptr IOleObjectVtbl
  IOleObjectVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    SetClientSite*: proc(self: ptr IOleObject, pClientSite: ptr IOleClientSite): HRESULT {.stdcall.}
    GetClientSite*: proc(self: ptr IOleObject, ppClientSite: ptr ptr IOleClientSite): HRESULT {.stdcall.}
    SetHostNames*: proc(self: ptr IOleObject, szContainerApp: LPCOLESTR, szContainerObj: LPCOLESTR): HRESULT {.stdcall.}
    Close*: proc(self: ptr IOleObject, dwSaveOption: DWORD): HRESULT {.stdcall.}
    SetMoniker*: proc(self: ptr IOleObject, dwWhichMoniker: DWORD, pmk: ptr IMoniker): HRESULT {.stdcall.}
    GetMoniker*: proc(self: ptr IOleObject, dwAssign: DWORD, dwWhichMoniker: DWORD, ppmk: ptr ptr IMoniker): HRESULT {.stdcall.}
    InitFromData*: proc(self: ptr IOleObject, pDataObject: ptr IDataObject, fCreation: WINBOOL, dwReserved: DWORD): HRESULT {.stdcall.}
    GetClipboardData*: proc(self: ptr IOleObject, dwReserved: DWORD, ppDataObject: ptr ptr IDataObject): HRESULT {.stdcall.}
    DoVerb*: proc(self: ptr IOleObject, iVerb: LONG, lpmsg: LPMSG, pActiveSite: ptr IOleClientSite, lindex: LONG, hwndParent: HWND, lprcPosRect: LPCRECT): HRESULT {.stdcall.}
    EnumVerbs*: proc(self: ptr IOleObject, ppEnumOleVerb: ptr ptr IEnumOLEVERB): HRESULT {.stdcall.}
    Update*: proc(self: ptr IOleObject): HRESULT {.stdcall.}
    IsUpToDate*: proc(self: ptr IOleObject): HRESULT {.stdcall.}
    GetUserClassID*: proc(self: ptr IOleObject, pClsid: ptr CLSID): HRESULT {.stdcall.}
    GetUserType*: proc(self: ptr IOleObject, dwFormOfType: DWORD, pszUserType: ptr LPOLESTR): HRESULT {.stdcall.}
    SetExtent*: proc(self: ptr IOleObject, dwDrawAspect: DWORD, psizel: ptr SIZEL): HRESULT {.stdcall.}
    GetExtent*: proc(self: ptr IOleObject, dwDrawAspect: DWORD, psizel: ptr SIZEL): HRESULT {.stdcall.}
    Advise*: proc(self: ptr IOleObject, pAdvSink: ptr IAdviseSink, pdwConnection: ptr DWORD): HRESULT {.stdcall.}
    Unadvise*: proc(self: ptr IOleObject, dwConnection: DWORD): HRESULT {.stdcall.}
    EnumAdvise*: proc(self: ptr IOleObject, ppenumAdvise: ptr ptr IEnumSTATDATA): HRESULT {.stdcall.}
    GetMiscStatus*: proc(self: ptr IOleObject, dwAspect: DWORD, pdwStatus: ptr DWORD): HRESULT {.stdcall.}
    SetColorScheme*: proc(self: ptr IOleObject, pLogpal: ptr LOGPALETTE): HRESULT {.stdcall.}
  IOleWindow* {.pure.} = object
    lpVtbl*: ptr IOleWindowVtbl
  IOleWindowVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetWindow*: proc(self: ptr IOleWindow, phwnd: ptr HWND): HRESULT {.stdcall.}
    ContextSensitiveHelp*: proc(self: ptr IOleWindow, fEnterMode: WINBOOL): HRESULT {.stdcall.}
  LPCBORDERWIDTHS* = LPCRECT
  IOleInPlaceActiveObject* {.pure.} = object
    lpVtbl*: ptr IOleInPlaceActiveObjectVtbl
  IOleInPlaceActiveObjectVtbl* {.pure, inheritable.} = object of IOleWindowVtbl
    TranslateAccelerator*: proc(self: ptr IOleInPlaceActiveObject, lpmsg: LPMSG): HRESULT {.stdcall.}
    OnFrameWindowActivate*: proc(self: ptr IOleInPlaceActiveObject, fActivate: WINBOOL): HRESULT {.stdcall.}
    OnDocWindowActivate*: proc(self: ptr IOleInPlaceActiveObject, fActivate: WINBOOL): HRESULT {.stdcall.}
    ResizeBorder*: proc(self: ptr IOleInPlaceActiveObject, prcBorder: LPCRECT, pUIWindow: ptr IOleInPlaceUIWindow, fFrameWindow: WINBOOL): HRESULT {.stdcall.}
    EnableModeless*: proc(self: ptr IOleInPlaceActiveObject, fEnable: WINBOOL): HRESULT {.stdcall.}
  IOleInPlaceUIWindow* {.pure.} = object
    lpVtbl*: ptr IOleInPlaceUIWindowVtbl
  IOleInPlaceUIWindowVtbl* {.pure, inheritable.} = object of IOleWindowVtbl
    GetBorder*: proc(self: ptr IOleInPlaceUIWindow, lprectBorder: LPRECT): HRESULT {.stdcall.}
    RequestBorderSpace*: proc(self: ptr IOleInPlaceUIWindow, pborderwidths: LPCBORDERWIDTHS): HRESULT {.stdcall.}
    SetBorderSpace*: proc(self: ptr IOleInPlaceUIWindow, pborderwidths: LPCBORDERWIDTHS): HRESULT {.stdcall.}
    SetActiveObject*: proc(self: ptr IOleInPlaceUIWindow, pActiveObject: ptr IOleInPlaceActiveObject, pszObjName: LPCOLESTR): HRESULT {.stdcall.}
  OLEMENUGROUPWIDTHS* {.pure.} = object
    width*: array[6, LONG]
  LPOLEMENUGROUPWIDTHS* = ptr OLEMENUGROUPWIDTHS
  HOLEMENU* = HGLOBAL
  IOleInPlaceFrame* {.pure.} = object
    lpVtbl*: ptr IOleInPlaceFrameVtbl
  IOleInPlaceFrameVtbl* {.pure, inheritable.} = object of IOleInPlaceUIWindowVtbl
    InsertMenus*: proc(self: ptr IOleInPlaceFrame, hmenuShared: HMENU, lpMenuWidths: LPOLEMENUGROUPWIDTHS): HRESULT {.stdcall.}
    SetMenu*: proc(self: ptr IOleInPlaceFrame, hmenuShared: HMENU, holemenu: HOLEMENU, hwndActiveObject: HWND): HRESULT {.stdcall.}
    RemoveMenus*: proc(self: ptr IOleInPlaceFrame, hmenuShared: HMENU): HRESULT {.stdcall.}
    SetStatusText*: proc(self: ptr IOleInPlaceFrame, pszStatusText: LPCOLESTR): HRESULT {.stdcall.}
    EnableModeless*: proc(self: ptr IOleInPlaceFrame, fEnable: WINBOOL): HRESULT {.stdcall.}
    TranslateAccelerator*: proc(self: ptr IOleInPlaceFrame, lpmsg: LPMSG, wID: WORD): HRESULT {.stdcall.}
  IOleInPlaceObject* {.pure.} = object
    lpVtbl*: ptr IOleInPlaceObjectVtbl
  IOleInPlaceObjectVtbl* {.pure, inheritable.} = object of IOleWindowVtbl
    InPlaceDeactivate*: proc(self: ptr IOleInPlaceObject): HRESULT {.stdcall.}
    UIDeactivate*: proc(self: ptr IOleInPlaceObject): HRESULT {.stdcall.}
    SetObjectRects*: proc(self: ptr IOleInPlaceObject, lprcPosRect: LPCRECT, lprcClipRect: LPCRECT): HRESULT {.stdcall.}
    ReactivateAndUndo*: proc(self: ptr IOleInPlaceObject): HRESULT {.stdcall.}
  OLEINPLACEFRAMEINFO* {.pure.} = object
    cb*: UINT
    fMDIApp*: WINBOOL
    hwndFrame*: HWND
    haccel*: HACCEL
    cAccelEntries*: UINT
  LPOLEINPLACEFRAMEINFO* = ptr OLEINPLACEFRAMEINFO
  IOleInPlaceSite* {.pure.} = object
    lpVtbl*: ptr IOleInPlaceSiteVtbl
  IOleInPlaceSiteVtbl* {.pure, inheritable.} = object of IOleWindowVtbl
    CanInPlaceActivate*: proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.}
    OnInPlaceActivate*: proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.}
    OnUIActivate*: proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.}
    GetWindowContext*: proc(self: ptr IOleInPlaceSite, ppFrame: ptr ptr IOleInPlaceFrame, ppDoc: ptr ptr IOleInPlaceUIWindow, lprcPosRect: LPRECT, lprcClipRect: LPRECT, lpFrameInfo: LPOLEINPLACEFRAMEINFO): HRESULT {.stdcall.}
    Scroll*: proc(self: ptr IOleInPlaceSite, scrollExtant: SIZE): HRESULT {.stdcall.}
    OnUIDeactivate*: proc(self: ptr IOleInPlaceSite, fUndoable: WINBOOL): HRESULT {.stdcall.}
    OnInPlaceDeactivate*: proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.}
    DiscardUndoState*: proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.}
    DeactivateAndUndo*: proc(self: ptr IOleInPlaceSite): HRESULT {.stdcall.}
    OnPosRectChange*: proc(self: ptr IOleInPlaceSite, lprcPosRect: LPCRECT): HRESULT {.stdcall.}
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
  CONNECTDATA* {.pure.} = object
    pUnk*: ptr IUnknown
    dwCookie*: DWORD
  LPCONNECTDATA* = ptr CONNECTDATA
  IEnumConnections* {.pure.} = object
    lpVtbl*: ptr IEnumConnectionsVtbl
  IEnumConnectionsVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumConnections, cConnections: ULONG, rgcd: LPCONNECTDATA, pcFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumConnections, cConnections: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumConnections): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumConnections, ppEnum: ptr ptr IEnumConnections): HRESULT {.stdcall.}
  LPCONNECTIONPOINT* = ptr IConnectionPoint
  IEnumConnectionPoints* {.pure.} = object
    lpVtbl*: ptr IEnumConnectionPointsVtbl
  IEnumConnectionPointsVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Next*: proc(self: ptr IEnumConnectionPoints, cConnections: ULONG, ppCP: ptr LPCONNECTIONPOINT, pcFetched: ptr ULONG): HRESULT {.stdcall.}
    Skip*: proc(self: ptr IEnumConnectionPoints, cConnections: ULONG): HRESULT {.stdcall.}
    Reset*: proc(self: ptr IEnumConnectionPoints): HRESULT {.stdcall.}
    Clone*: proc(self: ptr IEnumConnectionPoints, ppEnum: ptr ptr IEnumConnectionPoints): HRESULT {.stdcall.}
  IConnectionPointContainer* {.pure.} = object
    lpVtbl*: ptr IConnectionPointContainerVtbl
  IConnectionPointContainerVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    EnumConnectionPoints*: proc(self: ptr IConnectionPointContainer, ppEnum: ptr ptr IEnumConnectionPoints): HRESULT {.stdcall.}
    FindConnectionPoint*: proc(self: ptr IConnectionPointContainer, riid: REFIID, ppCP: ptr ptr IConnectionPoint): HRESULT {.stdcall.}
  IConnectionPoint* {.pure.} = object
    lpVtbl*: ptr IConnectionPointVtbl
  IConnectionPointVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetConnectionInterface*: proc(self: ptr IConnectionPoint, pIID: ptr IID): HRESULT {.stdcall.}
    GetConnectionPointContainer*: proc(self: ptr IConnectionPoint, ppCPC: ptr ptr IConnectionPointContainer): HRESULT {.stdcall.}
    Advise*: proc(self: ptr IConnectionPoint, pUnkSink: ptr IUnknown, pdwCookie: ptr DWORD): HRESULT {.stdcall.}
    Unadvise*: proc(self: ptr IConnectionPoint, dwCookie: DWORD): HRESULT {.stdcall.}
    EnumConnections*: proc(self: ptr IConnectionPoint, ppEnum: ptr ptr IEnumConnections): HRESULT {.stdcall.}
  IOleInPlaceSiteEx* {.pure.} = object
    lpVtbl*: ptr IOleInPlaceSiteExVtbl
  IOleInPlaceSiteExVtbl* {.pure, inheritable.} = object of IOleInPlaceSiteVtbl
    OnInPlaceActivateEx*: proc(self: ptr IOleInPlaceSiteEx, pfNoRedraw: ptr WINBOOL, dwFlags: DWORD): HRESULT {.stdcall.}
    OnInPlaceDeactivateEx*: proc(self: ptr IOleInPlaceSiteEx, fNoRedraw: WINBOOL): HRESULT {.stdcall.}
    RequestUIActivate*: proc(self: ptr IOleInPlaceSiteEx): HRESULT {.stdcall.}
  IObjectWithSite* {.pure.} = object
    lpVtbl*: ptr IObjectWithSiteVtbl
  IObjectWithSiteVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    SetSite*: proc(self: ptr IObjectWithSite, pUnkSite: ptr IUnknown): HRESULT {.stdcall.}
    GetSite*: proc(self: ptr IObjectWithSite, riid: REFIID, ppvSite: ptr pointer): HRESULT {.stdcall.}
  SHITEMID* {.pure, packed.} = object
    cb*: USHORT
    abID*: array[1, BYTE]
  ITEMIDLIST* {.pure, packed.} = object
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
  OLECMD* {.pure.} = object
    cmdID*: ULONG
    cmdf*: DWORD
  OLECMDTEXT* {.pure.} = object
    cmdtextf*: DWORD
    cwActual*: ULONG
    cwBuf*: ULONG
    rgwz*: array[1, uint16]
  IOleCommandTarget* {.pure.} = object
    lpVtbl*: ptr IOleCommandTargetVtbl
  IOleCommandTargetVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    QueryStatus*: proc(self: ptr IOleCommandTarget, pguidCmdGroup: ptr GUID, cCmds: ULONG, prgCmds: ptr OLECMD, pCmdText: ptr OLECMDTEXT): HRESULT {.stdcall.}
    Exec*: proc(self: ptr IOleCommandTarget, pguidCmdGroup: ptr GUID, nCmdID: DWORD, nCmdexecopt: DWORD, pvaIn: ptr VARIANT, pvaOut: ptr VARIANT): HRESULT {.stdcall.}
  REFPROPERTYKEY* = ptr PROPERTYKEY
const
  CLSCTX_INPROC_SERVER* = 0x1
  CLSCTX_INPROC_HANDLER* = 0x2
  CLSCTX_LOCAL_SERVER* = 0x4
  CLSCTX_REMOTE_SERVER* = 0x10
  CLSCTX_ALL* = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER or CLSCTX_LOCAL_SERVER or CLSCTX_REMOTE_SERVER
  DVASPECT_CONTENT* = 1
  STATFLAG_NONAME* = 1
  VARIANT_TRUE* = VARIANT_BOOL(-1)
  VARIANT_FALSE* = VARIANT_BOOL 0
  VT_I4* = 3
  VT_BSTR* = 8
  VT_VARIANT* = 12
  IID_IUnknown* = DEFINE_GUID("00000000-0000-0000-c000-000000000046")
  IID_IEnumString* = DEFINE_GUID("00000101-0000-0000-c000-000000000046")
  STREAM_SEEK_SET* = 0
  TYMED_HGLOBAL* = 1
  TYMED_GDI* = 16
  DATADIR_GET* = 1
  IID_IDataObject* = DEFINE_GUID("0000010e-0000-0000-c000-000000000046")
  DISPID_UNKNOWN* = -1
  IID_IDispatch* = DEFINE_GUID("00020400-0000-0000-c000-000000000046")
  OLEIVERB_HIDE* = -3
  OLEIVERB_INPLACEACTIVATE* = -5
  IID_IOleClientSite* = DEFINE_GUID("00000118-0000-0000-c000-000000000046")
  OLECLOSE_NOSAVE* = 1
  IID_IOleObject* = DEFINE_GUID("00000112-0000-0000-c000-000000000046")
  IID_IOleWindow* = DEFINE_GUID("00000114-0000-0000-c000-000000000046")
  IID_IOleInPlaceActiveObject* = DEFINE_GUID("00000117-0000-0000-c000-000000000046")
  IID_IOleInPlaceFrame* = DEFINE_GUID("00000116-0000-0000-c000-000000000046")
  IID_IOleInPlaceObject* = DEFINE_GUID("00000113-0000-0000-c000-000000000046")
  IID_IOleInPlaceSite* = DEFINE_GUID("00000119-0000-0000-c000-000000000046")
  DROPEFFECT_NONE* = 0
  DROPEFFECT_COPY* = 1
  DROPEFFECT_MOVE* = 2
  DROPEFFECT_LINK* = 4
  IID_IConnectionPointContainer* = DEFINE_GUID("b196b284-bab4-101a-b69c-00aa00341d07")
  IID_IOleInPlaceSiteEx* = DEFINE_GUID("9c2cad80-3424-11cf-b670-00aa004cd6d8")
  IID_IObjectWithSite* = DEFINE_GUID("fc4801a3-2ba9-11cf-a229-00aa003d7352")
  navNoHistory* = 0x2
  DIID_DWebBrowserEvents* = DEFINE_GUID("eab22ac2-30c1-11cf-a7eb-0000c05bae0b")
  CSC_NAVIGATEFORWARD* = 1
  CSC_NAVIGATEBACK* = 2
  IID_IWebBrowser2* = DEFINE_GUID("d30c1661-cdaf-11d0-8a3e-00c04fc9e26e")
  DIID_DWebBrowserEvents2* = DEFINE_GUID("34a715a0-6587-11d0-924a-0020afc7ac4d")
  CLSID_WebBrowser* = DEFINE_GUID("8856f961-340a-11d0-a96b-00c04fd705a2")
  DISPID_STATUSTEXTCHANGE* = 102
  DISPID_COMMANDSTATECHANGE* = 105
  DISPID_PROGRESSCHANGE* = 108
  DISPID_TITLECHANGE* = 113
  DISPID_BEFORENAVIGATE2* = 250
  DISPID_NEWWINDOW2* = 251
  DISPID_NAVIGATECOMPLETE2* = 252
  DISPID_NAVIGATEERROR* = 271
  DISPID_NEWWINDOW3* = 273
type
  COMDLG_FILTERSPEC* {.pure.} = object
    pszName*: LPCWSTR
    pszSpec*: LPCWSTR
  IWebBrowser* {.pure.} = object
    lpVtbl*: ptr IWebBrowserVtbl
  IWebBrowserVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    GoBack*: proc(self: ptr IWebBrowser): HRESULT {.stdcall.}
    GoForward*: proc(self: ptr IWebBrowser): HRESULT {.stdcall.}
    GoHome*: proc(self: ptr IWebBrowser): HRESULT {.stdcall.}
    GoSearch*: proc(self: ptr IWebBrowser): HRESULT {.stdcall.}
    Navigate*: proc(self: ptr IWebBrowser, URL: BSTR, Flags: ptr VARIANT, TargetFrameName: ptr VARIANT, PostData: ptr VARIANT, Headers: ptr VARIANT): HRESULT {.stdcall.}
    Refresh*: proc(self: ptr IWebBrowser): HRESULT {.stdcall.}
    Refresh2*: proc(self: ptr IWebBrowser, Level: ptr VARIANT): HRESULT {.stdcall.}
    Stop*: proc(self: ptr IWebBrowser): HRESULT {.stdcall.}
    get_Application*: proc(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.stdcall.}
    get_Parent*: proc(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.stdcall.}
    get_Container*: proc(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.stdcall.}
    get_Document*: proc(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.stdcall.}
    get_TopLevelContainer*: proc(self: ptr IWebBrowser, pBool: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_Type*: proc(self: ptr IWebBrowser, Type: ptr BSTR): HRESULT {.stdcall.}
    get_Left*: proc(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.stdcall.}
    put_Left*: proc(self: ptr IWebBrowser, Left: LONG): HRESULT {.stdcall.}
    get_Top*: proc(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.stdcall.}
    put_Top*: proc(self: ptr IWebBrowser, Top: LONG): HRESULT {.stdcall.}
    get_Width*: proc(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.stdcall.}
    put_Width*: proc(self: ptr IWebBrowser, Width: LONG): HRESULT {.stdcall.}
    get_Height*: proc(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.stdcall.}
    put_Height*: proc(self: ptr IWebBrowser, Height: LONG): HRESULT {.stdcall.}
    get_LocationName*: proc(self: ptr IWebBrowser, LocationName: ptr BSTR): HRESULT {.stdcall.}
    get_LocationURL*: proc(self: ptr IWebBrowser, LocationURL: ptr BSTR): HRESULT {.stdcall.}
    get_Busy*: proc(self: ptr IWebBrowser, pBool: ptr VARIANT_BOOL): HRESULT {.stdcall.}
  IWebBrowserApp* {.pure.} = object
    lpVtbl*: ptr IWebBrowserAppVtbl
  IWebBrowserAppVtbl* {.pure, inheritable.} = object of IWebBrowserVtbl
    Quit*: proc(self: ptr IWebBrowserApp): HRESULT {.stdcall.}
    ClientToWindow*: proc(self: ptr IWebBrowserApp, pcx: ptr int32, pcy: ptr int32): HRESULT {.stdcall.}
    PutProperty*: proc(self: ptr IWebBrowserApp, Property: BSTR, vtValue: VARIANT): HRESULT {.stdcall.}
    GetProperty*: proc(self: ptr IWebBrowserApp, Property: BSTR, pvtValue: ptr VARIANT): HRESULT {.stdcall.}
    get_Name*: proc(self: ptr IWebBrowserApp, Name: ptr BSTR): HRESULT {.stdcall.}
    get_HWND*: proc(self: ptr IWebBrowserApp, pHWND: ptr SHANDLE_PTR): HRESULT {.stdcall.}
    get_FullName*: proc(self: ptr IWebBrowserApp, FullName: ptr BSTR): HRESULT {.stdcall.}
    get_Path*: proc(self: ptr IWebBrowserApp, Path: ptr BSTR): HRESULT {.stdcall.}
    get_Visible*: proc(self: ptr IWebBrowserApp, pBool: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_Visible*: proc(self: ptr IWebBrowserApp, Value: VARIANT_BOOL): HRESULT {.stdcall.}
    get_StatusBar*: proc(self: ptr IWebBrowserApp, pBool: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_StatusBar*: proc(self: ptr IWebBrowserApp, Value: VARIANT_BOOL): HRESULT {.stdcall.}
    get_StatusText*: proc(self: ptr IWebBrowserApp, StatusText: ptr BSTR): HRESULT {.stdcall.}
    put_StatusText*: proc(self: ptr IWebBrowserApp, StatusText: BSTR): HRESULT {.stdcall.}
    get_ToolBar*: proc(self: ptr IWebBrowserApp, Value: ptr int32): HRESULT {.stdcall.}
    put_ToolBar*: proc(self: ptr IWebBrowserApp, Value: int32): HRESULT {.stdcall.}
    get_MenuBar*: proc(self: ptr IWebBrowserApp, Value: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_MenuBar*: proc(self: ptr IWebBrowserApp, Value: VARIANT_BOOL): HRESULT {.stdcall.}
    get_FullScreen*: proc(self: ptr IWebBrowserApp, pbFullScreen: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_FullScreen*: proc(self: ptr IWebBrowserApp, bFullScreen: VARIANT_BOOL): HRESULT {.stdcall.}
  IWebBrowser2* {.pure.} = object
    lpVtbl*: ptr IWebBrowser2Vtbl
  IWebBrowser2Vtbl* {.pure, inheritable.} = object of IWebBrowserAppVtbl
    Navigate2*: proc(self: ptr IWebBrowser2, URL: ptr VARIANT, Flags: ptr VARIANT, TargetFrameName: ptr VARIANT, PostData: ptr VARIANT, Headers: ptr VARIANT): HRESULT {.stdcall.}
    QueryStatusWB*: proc(self: ptr IWebBrowser2, cmdID: OLECMDID, pcmdf: ptr OLECMDF): HRESULT {.stdcall.}
    ExecWB*: proc(self: ptr IWebBrowser2, cmdID: OLECMDID, cmdexecopt: OLECMDEXECOPT, pvaIn: ptr VARIANT, pvaOut: ptr VARIANT): HRESULT {.stdcall.}
    ShowBrowserBar*: proc(self: ptr IWebBrowser2, pvaClsid: ptr VARIANT, pvarShow: ptr VARIANT, pvarSize: ptr VARIANT): HRESULT {.stdcall.}
    get_ReadyState*: proc(self: ptr IWebBrowser2, plReadyState: ptr READYSTATE): HRESULT {.stdcall.}
    get_Offline*: proc(self: ptr IWebBrowser2, pbOffline: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_Offline*: proc(self: ptr IWebBrowser2, bOffline: VARIANT_BOOL): HRESULT {.stdcall.}
    get_Silent*: proc(self: ptr IWebBrowser2, pbSilent: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_Silent*: proc(self: ptr IWebBrowser2, bSilent: VARIANT_BOOL): HRESULT {.stdcall.}
    get_RegisterAsBrowser*: proc(self: ptr IWebBrowser2, pbRegister: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_RegisterAsBrowser*: proc(self: ptr IWebBrowser2, bRegister: VARIANT_BOOL): HRESULT {.stdcall.}
    get_RegisterAsDropTarget*: proc(self: ptr IWebBrowser2, pbRegister: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_RegisterAsDropTarget*: proc(self: ptr IWebBrowser2, bRegister: VARIANT_BOOL): HRESULT {.stdcall.}
    get_TheaterMode*: proc(self: ptr IWebBrowser2, pbRegister: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_TheaterMode*: proc(self: ptr IWebBrowser2, bRegister: VARIANT_BOOL): HRESULT {.stdcall.}
    get_AddressBar*: proc(self: ptr IWebBrowser2, Value: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_AddressBar*: proc(self: ptr IWebBrowser2, Value: VARIANT_BOOL): HRESULT {.stdcall.}
    get_Resizable*: proc(self: ptr IWebBrowser2, Value: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_Resizable*: proc(self: ptr IWebBrowser2, Value: VARIANT_BOOL): HRESULT {.stdcall.}
proc SysAllocString*(P1: ptr OLECHAR): BSTR {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc SysFreeString*(P1: BSTR): void {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc SafeArrayDestroy*(psa: ptr SAFEARRAY): HRESULT {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc SafeArrayAccessData*(psa: ptr SAFEARRAY, ppvData: ptr pointer): HRESULT {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc SafeArrayUnaccessData*(psa: ptr SAFEARRAY): HRESULT {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc SafeArrayCreateVector*(vt: VARTYPE, lLbound: LONG, cElements: ULONG): ptr SAFEARRAY {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc VariantClear*(pvarg: ptr VARIANTARG): HRESULT {.winapi, stdcall, dynlib: "oleaut32", importc.}
proc OleInitialize*(pvReserved: LPVOID): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleSetContainedObject*(pUnknown: LPUNKNOWN, fContained: WINBOOL): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc RegisterDragDrop*(hwnd: HWND, pDropTarget: LPDROPTARGET): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc RevokeDragDrop*(hwnd: HWND): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc DoDragDrop*(pDataObj: LPDATAOBJECT, pDropSource: LPDROPSOURCE, dwOKEffects: DWORD, pdwEffect: LPDWORD): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleSetClipboard*(pDataObj: LPDATAOBJECT): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleGetClipboard*(ppDataObj: ptr LPDATAOBJECT): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleFlushClipboard*(): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc OleIsCurrentClipboard*(pDataObj: LPDATAOBJECT): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc ReleaseStgMedium*(P1: LPSTGMEDIUM): void {.winapi, stdcall, dynlib: "ole32", importc.}
proc CoDisconnectObject*(pUnk: LPUNKNOWN, dwReserved: DWORD): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc CoCreateInstance*(rclsid: REFCLSID, pUnkOuter: LPUNKNOWN, dwClsContext: DWORD, riid: REFIID, ppv: ptr LPVOID): HRESULT {.winapi, stdcall, dynlib: "ole32", importc.}
proc CoTaskMemAlloc*(cb: SIZE_T): LPVOID {.winapi, stdcall, dynlib: "ole32", importc.}
proc CoTaskMemFree*(pv: LPVOID): void {.winapi, stdcall, dynlib: "ole32", importc.}
proc `Lo=`*(self: var CY, x: int32) {.inline.} = self.struct1.Lo = x
proc Lo*(self: CY): int32 {.inline.} = self.struct1.Lo
proc Lo*(self: var CY): var int32 {.inline.} = self.struct1.Lo
proc `Hi=`*(self: var CY, x: int32) {.inline.} = self.struct1.Hi = x
proc Hi*(self: CY): int32 {.inline.} = self.struct1.Hi
proc Hi*(self: var CY): var int32 {.inline.} = self.struct1.Hi
proc `scale=`*(self: var DECIMAL, x: BYTE) {.inline.} = self.union1.struct1.scale = x
proc scale*(self: DECIMAL): BYTE {.inline.} = self.union1.struct1.scale
proc scale*(self: var DECIMAL): var BYTE {.inline.} = self.union1.struct1.scale
proc `sign=`*(self: var DECIMAL, x: BYTE) {.inline.} = self.union1.struct1.sign = x
proc sign*(self: DECIMAL): BYTE {.inline.} = self.union1.struct1.sign
proc sign*(self: var DECIMAL): var BYTE {.inline.} = self.union1.struct1.sign
proc `signscale=`*(self: var DECIMAL, x: USHORT) {.inline.} = self.union1.signscale = x
proc signscale*(self: DECIMAL): USHORT {.inline.} = self.union1.signscale
proc signscale*(self: var DECIMAL): var USHORT {.inline.} = self.union1.signscale
proc `Lo32=`*(self: var DECIMAL, x: ULONG) {.inline.} = self.union2.struct1.Lo32 = x
proc Lo32*(self: DECIMAL): ULONG {.inline.} = self.union2.struct1.Lo32
proc Lo32*(self: var DECIMAL): var ULONG {.inline.} = self.union2.struct1.Lo32
proc `Mid32=`*(self: var DECIMAL, x: ULONG) {.inline.} = self.union2.struct1.Mid32 = x
proc Mid32*(self: DECIMAL): ULONG {.inline.} = self.union2.struct1.Mid32
proc Mid32*(self: var DECIMAL): var ULONG {.inline.} = self.union2.struct1.Mid32
proc `Lo64=`*(self: var DECIMAL, x: ULONGLONG) {.inline.} = self.union2.Lo64 = x
proc Lo64*(self: DECIMAL): ULONGLONG {.inline.} = self.union2.Lo64
proc Lo64*(self: var DECIMAL): var ULONGLONG {.inline.} = self.union2.Lo64
proc `vt=`*(self: var VARIANT, x: VARTYPE) {.inline.} = self.union1.struct1.vt = x
proc vt*(self: VARIANT): VARTYPE {.inline.} = self.union1.struct1.vt
proc vt*(self: var VARIANT): var VARTYPE {.inline.} = self.union1.struct1.vt
proc `wReserved1=`*(self: var VARIANT, x: WORD) {.inline.} = self.union1.struct1.wReserved1 = x
proc wReserved1*(self: VARIANT): WORD {.inline.} = self.union1.struct1.wReserved1
proc wReserved1*(self: var VARIANT): var WORD {.inline.} = self.union1.struct1.wReserved1
proc `wReserved2=`*(self: var VARIANT, x: WORD) {.inline.} = self.union1.struct1.wReserved2 = x
proc wReserved2*(self: VARIANT): WORD {.inline.} = self.union1.struct1.wReserved2
proc wReserved2*(self: var VARIANT): var WORD {.inline.} = self.union1.struct1.wReserved2
proc `wReserved3=`*(self: var VARIANT, x: WORD) {.inline.} = self.union1.struct1.wReserved3 = x
proc wReserved3*(self: VARIANT): WORD {.inline.} = self.union1.struct1.wReserved3
proc wReserved3*(self: var VARIANT): var WORD {.inline.} = self.union1.struct1.wReserved3
proc `llVal=`*(self: var VARIANT, x: LONGLONG) {.inline.} = self.union1.struct1.union1.llVal = x
proc llVal*(self: VARIANT): LONGLONG {.inline.} = self.union1.struct1.union1.llVal
proc llVal*(self: var VARIANT): var LONGLONG {.inline.} = self.union1.struct1.union1.llVal
proc `lVal=`*(self: var VARIANT, x: LONG) {.inline.} = self.union1.struct1.union1.lVal = x
proc lVal*(self: VARIANT): LONG {.inline.} = self.union1.struct1.union1.lVal
proc lVal*(self: var VARIANT): var LONG {.inline.} = self.union1.struct1.union1.lVal
proc `bVal=`*(self: var VARIANT, x: BYTE) {.inline.} = self.union1.struct1.union1.bVal = x
proc bVal*(self: VARIANT): BYTE {.inline.} = self.union1.struct1.union1.bVal
proc bVal*(self: var VARIANT): var BYTE {.inline.} = self.union1.struct1.union1.bVal
proc `iVal=`*(self: var VARIANT, x: SHORT) {.inline.} = self.union1.struct1.union1.iVal = x
proc iVal*(self: VARIANT): SHORT {.inline.} = self.union1.struct1.union1.iVal
proc iVal*(self: var VARIANT): var SHORT {.inline.} = self.union1.struct1.union1.iVal
proc `fltVal=`*(self: var VARIANT, x: FLOAT) {.inline.} = self.union1.struct1.union1.fltVal = x
proc fltVal*(self: VARIANT): FLOAT {.inline.} = self.union1.struct1.union1.fltVal
proc fltVal*(self: var VARIANT): var FLOAT {.inline.} = self.union1.struct1.union1.fltVal
proc `dblVal=`*(self: var VARIANT, x: DOUBLE) {.inline.} = self.union1.struct1.union1.dblVal = x
proc dblVal*(self: VARIANT): DOUBLE {.inline.} = self.union1.struct1.union1.dblVal
proc dblVal*(self: var VARIANT): var DOUBLE {.inline.} = self.union1.struct1.union1.dblVal
proc `boolVal=`*(self: var VARIANT, x: VARIANT_BOOL) {.inline.} = self.union1.struct1.union1.boolVal = x
proc boolVal*(self: VARIANT): VARIANT_BOOL {.inline.} = self.union1.struct1.union1.boolVal
proc boolVal*(self: var VARIANT): var VARIANT_BOOL {.inline.} = self.union1.struct1.union1.boolVal
proc `scode=`*(self: var VARIANT, x: SCODE) {.inline.} = self.union1.struct1.union1.scode = x
proc scode*(self: VARIANT): SCODE {.inline.} = self.union1.struct1.union1.scode
proc scode*(self: var VARIANT): var SCODE {.inline.} = self.union1.struct1.union1.scode
proc `cyVal=`*(self: var VARIANT, x: CY) {.inline.} = self.union1.struct1.union1.cyVal = x
proc cyVal*(self: VARIANT): CY {.inline.} = self.union1.struct1.union1.cyVal
proc cyVal*(self: var VARIANT): var CY {.inline.} = self.union1.struct1.union1.cyVal
proc `date=`*(self: var VARIANT, x: DATE) {.inline.} = self.union1.struct1.union1.date = x
proc date*(self: VARIANT): DATE {.inline.} = self.union1.struct1.union1.date
proc date*(self: var VARIANT): var DATE {.inline.} = self.union1.struct1.union1.date
proc `bstrVal=`*(self: var VARIANT, x: BSTR) {.inline.} = self.union1.struct1.union1.bstrVal = x
proc bstrVal*(self: VARIANT): BSTR {.inline.} = self.union1.struct1.union1.bstrVal
proc bstrVal*(self: var VARIANT): var BSTR {.inline.} = self.union1.struct1.union1.bstrVal
proc `punkVal=`*(self: var VARIANT, x: ptr IUnknown) {.inline.} = self.union1.struct1.union1.punkVal = x
proc punkVal*(self: VARIANT): ptr IUnknown {.inline.} = self.union1.struct1.union1.punkVal
proc punkVal*(self: var VARIANT): var ptr IUnknown {.inline.} = self.union1.struct1.union1.punkVal
proc `pdispVal=`*(self: var VARIANT, x: ptr IDispatch) {.inline.} = self.union1.struct1.union1.pdispVal = x
proc pdispVal*(self: VARIANT): ptr IDispatch {.inline.} = self.union1.struct1.union1.pdispVal
proc pdispVal*(self: var VARIANT): var ptr IDispatch {.inline.} = self.union1.struct1.union1.pdispVal
proc `parray=`*(self: var VARIANT, x: ptr SAFEARRAY) {.inline.} = self.union1.struct1.union1.parray = x
proc parray*(self: VARIANT): ptr SAFEARRAY {.inline.} = self.union1.struct1.union1.parray
proc parray*(self: var VARIANT): var ptr SAFEARRAY {.inline.} = self.union1.struct1.union1.parray
proc `pbVal=`*(self: var VARIANT, x: ptr BYTE) {.inline.} = self.union1.struct1.union1.pbVal = x
proc pbVal*(self: VARIANT): ptr BYTE {.inline.} = self.union1.struct1.union1.pbVal
proc pbVal*(self: var VARIANT): var ptr BYTE {.inline.} = self.union1.struct1.union1.pbVal
proc `piVal=`*(self: var VARIANT, x: ptr SHORT) {.inline.} = self.union1.struct1.union1.piVal = x
proc piVal*(self: VARIANT): ptr SHORT {.inline.} = self.union1.struct1.union1.piVal
proc piVal*(self: var VARIANT): var ptr SHORT {.inline.} = self.union1.struct1.union1.piVal
proc `plVal=`*(self: var VARIANT, x: ptr LONG) {.inline.} = self.union1.struct1.union1.plVal = x
proc plVal*(self: VARIANT): ptr LONG {.inline.} = self.union1.struct1.union1.plVal
proc plVal*(self: var VARIANT): var ptr LONG {.inline.} = self.union1.struct1.union1.plVal
proc `pllVal=`*(self: var VARIANT, x: ptr LONGLONG) {.inline.} = self.union1.struct1.union1.pllVal = x
proc pllVal*(self: VARIANT): ptr LONGLONG {.inline.} = self.union1.struct1.union1.pllVal
proc pllVal*(self: var VARIANT): var ptr LONGLONG {.inline.} = self.union1.struct1.union1.pllVal
proc `pfltVal=`*(self: var VARIANT, x: ptr FLOAT) {.inline.} = self.union1.struct1.union1.pfltVal = x
proc pfltVal*(self: VARIANT): ptr FLOAT {.inline.} = self.union1.struct1.union1.pfltVal
proc pfltVal*(self: var VARIANT): var ptr FLOAT {.inline.} = self.union1.struct1.union1.pfltVal
proc `pdblVal=`*(self: var VARIANT, x: ptr DOUBLE) {.inline.} = self.union1.struct1.union1.pdblVal = x
proc pdblVal*(self: VARIANT): ptr DOUBLE {.inline.} = self.union1.struct1.union1.pdblVal
proc pdblVal*(self: var VARIANT): var ptr DOUBLE {.inline.} = self.union1.struct1.union1.pdblVal
proc `pboolVal=`*(self: var VARIANT, x: ptr VARIANT_BOOL) {.inline.} = self.union1.struct1.union1.pboolVal = x
proc pboolVal*(self: VARIANT): ptr VARIANT_BOOL {.inline.} = self.union1.struct1.union1.pboolVal
proc pboolVal*(self: var VARIANT): var ptr VARIANT_BOOL {.inline.} = self.union1.struct1.union1.pboolVal
proc `pscode=`*(self: var VARIANT, x: ptr SCODE) {.inline.} = self.union1.struct1.union1.pscode = x
proc pscode*(self: VARIANT): ptr SCODE {.inline.} = self.union1.struct1.union1.pscode
proc pscode*(self: var VARIANT): var ptr SCODE {.inline.} = self.union1.struct1.union1.pscode
proc `pcyVal=`*(self: var VARIANT, x: ptr CY) {.inline.} = self.union1.struct1.union1.pcyVal = x
proc pcyVal*(self: VARIANT): ptr CY {.inline.} = self.union1.struct1.union1.pcyVal
proc pcyVal*(self: var VARIANT): var ptr CY {.inline.} = self.union1.struct1.union1.pcyVal
proc `pdate=`*(self: var VARIANT, x: ptr DATE) {.inline.} = self.union1.struct1.union1.pdate = x
proc pdate*(self: VARIANT): ptr DATE {.inline.} = self.union1.struct1.union1.pdate
proc pdate*(self: var VARIANT): var ptr DATE {.inline.} = self.union1.struct1.union1.pdate
proc `pbstrVal=`*(self: var VARIANT, x: ptr BSTR) {.inline.} = self.union1.struct1.union1.pbstrVal = x
proc pbstrVal*(self: VARIANT): ptr BSTR {.inline.} = self.union1.struct1.union1.pbstrVal
proc pbstrVal*(self: var VARIANT): var ptr BSTR {.inline.} = self.union1.struct1.union1.pbstrVal
proc `ppunkVal=`*(self: var VARIANT, x: ptr ptr IUnknown) {.inline.} = self.union1.struct1.union1.ppunkVal = x
proc ppunkVal*(self: VARIANT): ptr ptr IUnknown {.inline.} = self.union1.struct1.union1.ppunkVal
proc ppunkVal*(self: var VARIANT): var ptr ptr IUnknown {.inline.} = self.union1.struct1.union1.ppunkVal
proc `ppdispVal=`*(self: var VARIANT, x: ptr ptr IDispatch) {.inline.} = self.union1.struct1.union1.ppdispVal = x
proc ppdispVal*(self: VARIANT): ptr ptr IDispatch {.inline.} = self.union1.struct1.union1.ppdispVal
proc ppdispVal*(self: var VARIANT): var ptr ptr IDispatch {.inline.} = self.union1.struct1.union1.ppdispVal
proc `pparray=`*(self: var VARIANT, x: ptr ptr SAFEARRAY) {.inline.} = self.union1.struct1.union1.pparray = x
proc pparray*(self: VARIANT): ptr ptr SAFEARRAY {.inline.} = self.union1.struct1.union1.pparray
proc pparray*(self: var VARIANT): var ptr ptr SAFEARRAY {.inline.} = self.union1.struct1.union1.pparray
proc `pvarVal=`*(self: var VARIANT, x: ptr VARIANT) {.inline.} = self.union1.struct1.union1.pvarVal = x
proc pvarVal*(self: VARIANT): ptr VARIANT {.inline.} = self.union1.struct1.union1.pvarVal
proc pvarVal*(self: var VARIANT): var ptr VARIANT {.inline.} = self.union1.struct1.union1.pvarVal
proc `byref=`*(self: var VARIANT, x: PVOID) {.inline.} = self.union1.struct1.union1.byref = x
proc byref*(self: VARIANT): PVOID {.inline.} = self.union1.struct1.union1.byref
proc byref*(self: var VARIANT): var PVOID {.inline.} = self.union1.struct1.union1.byref
proc `cVal=`*(self: var VARIANT, x: CHAR) {.inline.} = self.union1.struct1.union1.cVal = x
proc cVal*(self: VARIANT): CHAR {.inline.} = self.union1.struct1.union1.cVal
proc cVal*(self: var VARIANT): var CHAR {.inline.} = self.union1.struct1.union1.cVal
proc `uiVal=`*(self: var VARIANT, x: USHORT) {.inline.} = self.union1.struct1.union1.uiVal = x
proc uiVal*(self: VARIANT): USHORT {.inline.} = self.union1.struct1.union1.uiVal
proc uiVal*(self: var VARIANT): var USHORT {.inline.} = self.union1.struct1.union1.uiVal
proc `ulVal=`*(self: var VARIANT, x: ULONG) {.inline.} = self.union1.struct1.union1.ulVal = x
proc ulVal*(self: VARIANT): ULONG {.inline.} = self.union1.struct1.union1.ulVal
proc ulVal*(self: var VARIANT): var ULONG {.inline.} = self.union1.struct1.union1.ulVal
proc `ullVal=`*(self: var VARIANT, x: ULONGLONG) {.inline.} = self.union1.struct1.union1.ullVal = x
proc ullVal*(self: VARIANT): ULONGLONG {.inline.} = self.union1.struct1.union1.ullVal
proc ullVal*(self: var VARIANT): var ULONGLONG {.inline.} = self.union1.struct1.union1.ullVal
proc `intVal=`*(self: var VARIANT, x: INT) {.inline.} = self.union1.struct1.union1.intVal = x
proc intVal*(self: VARIANT): INT {.inline.} = self.union1.struct1.union1.intVal
proc intVal*(self: var VARIANT): var INT {.inline.} = self.union1.struct1.union1.intVal
proc `uintVal=`*(self: var VARIANT, x: UINT) {.inline.} = self.union1.struct1.union1.uintVal = x
proc uintVal*(self: VARIANT): UINT {.inline.} = self.union1.struct1.union1.uintVal
proc uintVal*(self: var VARIANT): var UINT {.inline.} = self.union1.struct1.union1.uintVal
proc `pdecVal=`*(self: var VARIANT, x: ptr DECIMAL) {.inline.} = self.union1.struct1.union1.pdecVal = x
proc pdecVal*(self: VARIANT): ptr DECIMAL {.inline.} = self.union1.struct1.union1.pdecVal
proc pdecVal*(self: var VARIANT): var ptr DECIMAL {.inline.} = self.union1.struct1.union1.pdecVal
proc `pcVal=`*(self: var VARIANT, x: ptr CHAR) {.inline.} = self.union1.struct1.union1.pcVal = x
proc pcVal*(self: VARIANT): ptr CHAR {.inline.} = self.union1.struct1.union1.pcVal
proc pcVal*(self: var VARIANT): var ptr CHAR {.inline.} = self.union1.struct1.union1.pcVal
proc `puiVal=`*(self: var VARIANT, x: ptr USHORT) {.inline.} = self.union1.struct1.union1.puiVal = x
proc puiVal*(self: VARIANT): ptr USHORT {.inline.} = self.union1.struct1.union1.puiVal
proc puiVal*(self: var VARIANT): var ptr USHORT {.inline.} = self.union1.struct1.union1.puiVal
proc `pulVal=`*(self: var VARIANT, x: ptr ULONG) {.inline.} = self.union1.struct1.union1.pulVal = x
proc pulVal*(self: VARIANT): ptr ULONG {.inline.} = self.union1.struct1.union1.pulVal
proc pulVal*(self: var VARIANT): var ptr ULONG {.inline.} = self.union1.struct1.union1.pulVal
proc `pullVal=`*(self: var VARIANT, x: ptr ULONGLONG) {.inline.} = self.union1.struct1.union1.pullVal = x
proc pullVal*(self: VARIANT): ptr ULONGLONG {.inline.} = self.union1.struct1.union1.pullVal
proc pullVal*(self: var VARIANT): var ptr ULONGLONG {.inline.} = self.union1.struct1.union1.pullVal
proc `pintVal=`*(self: var VARIANT, x: ptr INT) {.inline.} = self.union1.struct1.union1.pintVal = x
proc pintVal*(self: VARIANT): ptr INT {.inline.} = self.union1.struct1.union1.pintVal
proc pintVal*(self: var VARIANT): var ptr INT {.inline.} = self.union1.struct1.union1.pintVal
proc `puintVal=`*(self: var VARIANT, x: ptr UINT) {.inline.} = self.union1.struct1.union1.puintVal = x
proc puintVal*(self: VARIANT): ptr UINT {.inline.} = self.union1.struct1.union1.puintVal
proc puintVal*(self: var VARIANT): var ptr UINT {.inline.} = self.union1.struct1.union1.puintVal
proc `pvRecord=`*(self: var VARIANT, x: PVOID) {.inline.} = self.union1.struct1.union1.struct1.pvRecord = x
proc pvRecord*(self: VARIANT): PVOID {.inline.} = self.union1.struct1.union1.struct1.pvRecord
proc pvRecord*(self: var VARIANT): var PVOID {.inline.} = self.union1.struct1.union1.struct1.pvRecord
proc `pRecInfo=`*(self: var VARIANT, x: ptr IRecordInfo) {.inline.} = self.union1.struct1.union1.struct1.pRecInfo = x
proc pRecInfo*(self: VARIANT): ptr IRecordInfo {.inline.} = self.union1.struct1.union1.struct1.pRecInfo
proc pRecInfo*(self: var VARIANT): var ptr IRecordInfo {.inline.} = self.union1.struct1.union1.struct1.pRecInfo
proc `decVal=`*(self: var VARIANT, x: DECIMAL) {.inline.} = self.union1.decVal = x
proc decVal*(self: VARIANT): DECIMAL {.inline.} = self.union1.decVal
proc decVal*(self: var VARIANT): var DECIMAL {.inline.} = self.union1.decVal
proc `lptdesc=`*(self: var TYPEDESC, x: ptr TYPEDESC) {.inline.} = self.union1.lptdesc = x
proc lptdesc*(self: TYPEDESC): ptr TYPEDESC {.inline.} = self.union1.lptdesc
proc lptdesc*(self: var TYPEDESC): var ptr TYPEDESC {.inline.} = self.union1.lptdesc
proc `lpadesc=`*(self: var TYPEDESC, x: ptr ARRAYDESC) {.inline.} = self.union1.lpadesc = x
proc lpadesc*(self: TYPEDESC): ptr ARRAYDESC {.inline.} = self.union1.lpadesc
proc lpadesc*(self: var TYPEDESC): var ptr ARRAYDESC {.inline.} = self.union1.lpadesc
proc `hreftype=`*(self: var TYPEDESC, x: HREFTYPE) {.inline.} = self.union1.hreftype = x
proc hreftype*(self: TYPEDESC): HREFTYPE {.inline.} = self.union1.hreftype
proc hreftype*(self: var TYPEDESC): var HREFTYPE {.inline.} = self.union1.hreftype
proc `idldesc=`*(self: var ELEMDESC, x: IDLDESC) {.inline.} = self.union1.idldesc = x
proc idldesc*(self: ELEMDESC): IDLDESC {.inline.} = self.union1.idldesc
proc idldesc*(self: var ELEMDESC): var IDLDESC {.inline.} = self.union1.idldesc
proc `paramdesc=`*(self: var ELEMDESC, x: PARAMDESC) {.inline.} = self.union1.paramdesc = x
proc paramdesc*(self: ELEMDESC): PARAMDESC {.inline.} = self.union1.paramdesc
proc paramdesc*(self: var ELEMDESC): var PARAMDESC {.inline.} = self.union1.paramdesc
proc `oInst=`*(self: var VARDESC, x: ULONG) {.inline.} = self.union1.oInst = x
proc oInst*(self: VARDESC): ULONG {.inline.} = self.union1.oInst
proc oInst*(self: var VARDESC): var ULONG {.inline.} = self.union1.oInst
proc `lpvarValue=`*(self: var VARDESC, x: ptr VARIANT) {.inline.} = self.union1.lpvarValue = x
proc lpvarValue*(self: VARDESC): ptr VARIANT {.inline.} = self.union1.lpvarValue
proc lpvarValue*(self: var VARDESC): var ptr VARIANT {.inline.} = self.union1.lpvarValue
proc QueryInterface*(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.QueryInterface(self, riid, ppvObject)
proc AddRef*(self: ptr IUnknown): ULONG {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.AddRef(self)
proc Release*(self: ptr IUnknown): ULONG {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Release(self)
proc Next*(self: ptr IEnumUnknown, celt: ULONG, rgelt: ptr ptr IUnknown, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumUnknown, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumUnknown, ppenum: ptr ptr IEnumUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc Next*(self: ptr IEnumString, celt: ULONG, rgelt: ptr LPOLESTR, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumString, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumString): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumString, ppenum: ptr ptr IEnumString): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc Read*(self: ptr ISequentialStream, pv: pointer, cb: ULONG, pcbRead: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Read(self, pv, cb, pcbRead)
proc Write*(self: ptr ISequentialStream, pv: pointer, cb: ULONG, pcbWritten: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Write(self, pv, cb, pcbWritten)
proc Seek*(self: ptr IStream, dlibMove: LARGE_INTEGER, dwOrigin: DWORD, plibNewPosition: ptr ULARGE_INTEGER): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Seek(self, dlibMove, dwOrigin, plibNewPosition)
proc SetSize*(self: ptr IStream, libNewSize: ULARGE_INTEGER): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetSize(self, libNewSize)
proc CopyTo*(self: ptr IStream, pstm: ptr IStream, cb: ULARGE_INTEGER, pcbRead: ptr ULARGE_INTEGER, pcbWritten: ptr ULARGE_INTEGER): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CopyTo(self, pstm, cb, pcbRead, pcbWritten)
proc Commit*(self: ptr IStream, grfCommitFlags: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Commit(self, grfCommitFlags)
proc Revert*(self: ptr IStream): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Revert(self)
proc LockRegion*(self: ptr IStream, libOffset: ULARGE_INTEGER, cb: ULARGE_INTEGER, dwLockType: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.LockRegion(self, libOffset, cb, dwLockType)
proc UnlockRegion*(self: ptr IStream, libOffset: ULARGE_INTEGER, cb: ULARGE_INTEGER, dwLockType: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.UnlockRegion(self, libOffset, cb, dwLockType)
proc Stat*(self: ptr IStream, pstatstg: ptr STATSTG, grfStatFlag: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Stat(self, pstatstg, grfStatFlag)
proc Clone*(self: ptr IStream, ppstm: ptr ptr IStream): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppstm)
proc RegisterObjectBound*(self: ptr IBindCtx, punk: ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RegisterObjectBound(self, punk)
proc RevokeObjectBound*(self: ptr IBindCtx, punk: ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RevokeObjectBound(self, punk)
proc ReleaseBoundObjects*(self: ptr IBindCtx): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ReleaseBoundObjects(self)
proc SetBindOptions*(self: ptr IBindCtx, pbindopts: ptr BIND_OPTS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetBindOptions(self, pbindopts)
proc GetBindOptions*(self: ptr IBindCtx, pbindopts: ptr BIND_OPTS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetBindOptions(self, pbindopts)
proc GetRunningObjectTable*(self: ptr IBindCtx, pprot: ptr ptr IRunningObjectTable): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetRunningObjectTable(self, pprot)
proc RegisterObjectParam*(self: ptr IBindCtx, pszKey: LPOLESTR, punk: ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RegisterObjectParam(self, pszKey, punk)
proc GetObjectParam*(self: ptr IBindCtx, pszKey: LPOLESTR, ppunk: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetObjectParam(self, pszKey, ppunk)
proc EnumObjectParam*(self: ptr IBindCtx, ppenum: ptr ptr IEnumString): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumObjectParam(self, ppenum)
proc RevokeObjectParam*(self: ptr IBindCtx, pszKey: LPOLESTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RevokeObjectParam(self, pszKey)
proc Next*(self: ptr IEnumMoniker, celt: ULONG, rgelt: ptr ptr IMoniker, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumMoniker, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumMoniker, ppenum: ptr ptr IEnumMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc Register*(self: ptr IRunningObjectTable, grfFlags: DWORD, punkObject: ptr IUnknown, pmkObjectName: ptr IMoniker, pdwRegister: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Register(self, grfFlags, punkObject, pmkObjectName, pdwRegister)
proc Revoke*(self: ptr IRunningObjectTable, dwRegister: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Revoke(self, dwRegister)
proc IsRunning*(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsRunning(self, pmkObjectName)
proc GetObject*(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker, ppunkObject: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetObject(self, pmkObjectName, ppunkObject)
proc NoteChangeTime*(self: ptr IRunningObjectTable, dwRegister: DWORD, pfiletime: ptr FILETIME): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.NoteChangeTime(self, dwRegister, pfiletime)
proc GetTimeOfLastChange*(self: ptr IRunningObjectTable, pmkObjectName: ptr IMoniker, pfiletime: ptr FILETIME): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTimeOfLastChange(self, pmkObjectName, pfiletime)
proc EnumRunning*(self: ptr IRunningObjectTable, ppenumMoniker: ptr ptr IEnumMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumRunning(self, ppenumMoniker)
proc GetClassID*(self: ptr IPersist, pClassID: ptr CLSID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetClassID(self, pClassID)
proc IsDirty*(self: ptr IPersistStream): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsDirty(self)
proc Load*(self: ptr IPersistStream, pStm: ptr IStream): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Load(self, pStm)
proc Save*(self: ptr IPersistStream, pStm: ptr IStream, fClearDirty: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Save(self, pStm, fClearDirty)
proc GetSizeMax*(self: ptr IPersistStream, pcbSize: ptr ULARGE_INTEGER): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetSizeMax(self, pcbSize)
proc BindToObject*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, riidResult: REFIID, ppvResult: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.BindToObject(self, pbc, pmkToLeft, riidResult, ppvResult)
proc BindToStorage*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, riid: REFIID, ppvObj: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.BindToStorage(self, pbc, pmkToLeft, riid, ppvObj)
proc Reduce*(self: ptr IMoniker, pbc: ptr IBindCtx, dwReduceHowFar: DWORD, ppmkToLeft: ptr ptr IMoniker, ppmkReduced: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reduce(self, pbc, dwReduceHowFar, ppmkToLeft, ppmkReduced)
proc ComposeWith*(self: ptr IMoniker, pmkRight: ptr IMoniker, fOnlyIfNotGeneric: WINBOOL, ppmkComposite: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ComposeWith(self, pmkRight, fOnlyIfNotGeneric, ppmkComposite)
proc Enum*(self: ptr IMoniker, fForward: WINBOOL, ppenumMoniker: ptr ptr IEnumMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Enum(self, fForward, ppenumMoniker)
proc IsEqual*(self: ptr IMoniker, pmkOtherMoniker: ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsEqual(self, pmkOtherMoniker)
proc Hash*(self: ptr IMoniker, pdwHash: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Hash(self, pdwHash)
proc IsRunning*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pmkNewlyRunning: ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsRunning(self, pbc, pmkToLeft, pmkNewlyRunning)
proc GetTimeOfLastChange*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pFileTime: ptr FILETIME): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTimeOfLastChange(self, pbc, pmkToLeft, pFileTime)
proc Inverse*(self: ptr IMoniker, ppmk: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Inverse(self, ppmk)
proc CommonPrefixWith*(self: ptr IMoniker, pmkOther: ptr IMoniker, ppmkPrefix: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CommonPrefixWith(self, pmkOther, ppmkPrefix)
proc RelativePathTo*(self: ptr IMoniker, pmkOther: ptr IMoniker, ppmkRelPath: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RelativePathTo(self, pmkOther, ppmkRelPath)
proc GetDisplayName*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, ppszDisplayName: ptr LPOLESTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDisplayName(self, pbc, pmkToLeft, ppszDisplayName)
proc ParseDisplayName*(self: ptr IMoniker, pbc: ptr IBindCtx, pmkToLeft: ptr IMoniker, pszDisplayName: LPOLESTR, pchEaten: ptr ULONG, ppmkOut: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ParseDisplayName(self, pbc, pmkToLeft, pszDisplayName, pchEaten, ppmkOut)
proc IsSystemMoniker*(self: ptr IMoniker, pdwMksys: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsSystemMoniker(self, pdwMksys)
proc Next*(self: ptr IEnumSTATSTG, celt: ULONG, rgelt: ptr STATSTG, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumSTATSTG, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumSTATSTG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumSTATSTG, ppenum: ptr ptr IEnumSTATSTG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc CreateStream*(self: ptr IStorage, pwcsName: ptr OLECHAR, grfMode: DWORD, reserved1: DWORD, reserved2: DWORD, ppstm: ptr ptr IStream): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CreateStream(self, pwcsName, grfMode, reserved1, reserved2, ppstm)
proc OpenStream*(self: ptr IStorage, pwcsName: ptr OLECHAR, reserved1: pointer, grfMode: DWORD, reserved2: DWORD, ppstm: ptr ptr IStream): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OpenStream(self, pwcsName, reserved1, grfMode, reserved2, ppstm)
proc CreateStorage*(self: ptr IStorage, pwcsName: ptr OLECHAR, grfMode: DWORD, reserved1: DWORD, reserved2: DWORD, ppstg: ptr ptr IStorage): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CreateStorage(self, pwcsName, grfMode, reserved1, reserved2, ppstg)
proc OpenStorage*(self: ptr IStorage, pwcsName: ptr OLECHAR, pstgPriority: ptr IStorage, grfMode: DWORD, snbExclude: SNB, reserved: DWORD, ppstg: ptr ptr IStorage): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OpenStorage(self, pwcsName, pstgPriority, grfMode, snbExclude, reserved, ppstg)
proc CopyTo*(self: ptr IStorage, ciidExclude: DWORD, rgiidExclude: ptr IID, snbExclude: SNB, pstgDest: ptr IStorage): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CopyTo(self, ciidExclude, rgiidExclude, snbExclude, pstgDest)
proc MoveElementTo*(self: ptr IStorage, pwcsName: ptr OLECHAR, pstgDest: ptr IStorage, pwcsNewName: ptr OLECHAR, grfFlags: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.MoveElementTo(self, pwcsName, pstgDest, pwcsNewName, grfFlags)
proc Commit*(self: ptr IStorage, grfCommitFlags: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Commit(self, grfCommitFlags)
proc Revert*(self: ptr IStorage): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Revert(self)
proc EnumElements*(self: ptr IStorage, reserved1: DWORD, reserved2: pointer, reserved3: DWORD, ppenum: ptr ptr IEnumSTATSTG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumElements(self, reserved1, reserved2, reserved3, ppenum)
proc DestroyElement*(self: ptr IStorage, pwcsName: ptr OLECHAR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DestroyElement(self, pwcsName)
proc RenameElement*(self: ptr IStorage, pwcsOldName: ptr OLECHAR, pwcsNewName: ptr OLECHAR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RenameElement(self, pwcsOldName, pwcsNewName)
proc SetElementTimes*(self: ptr IStorage, pwcsName: ptr OLECHAR, pctime: ptr FILETIME, patime: ptr FILETIME, pmtime: ptr FILETIME): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetElementTimes(self, pwcsName, pctime, patime, pmtime)
proc SetClass*(self: ptr IStorage, clsid: REFCLSID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetClass(self, clsid)
proc SetStateBits*(self: ptr IStorage, grfStateBits: DWORD, grfMask: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetStateBits(self, grfStateBits, grfMask)
proc Stat*(self: ptr IStorage, pstatstg: ptr STATSTG, grfStatFlag: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Stat(self, pstatstg, grfStatFlag)
proc Next*(self: ptr IEnumFORMATETC, celt: ULONG, rgelt: ptr FORMATETC, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumFORMATETC, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumFORMATETC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumFORMATETC, ppenum: ptr ptr IEnumFORMATETC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc Next*(self: ptr IEnumSTATDATA, celt: ULONG, rgelt: ptr STATDATA, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumSTATDATA, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumSTATDATA, ppenum: ptr ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc OnDataChange*(self: ptr IAdviseSink, pFormatetc: ptr FORMATETC, pStgmed: ptr STGMEDIUM): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnDataChange(self, pFormatetc, pStgmed)
proc OnViewChange*(self: ptr IAdviseSink, dwAspect: DWORD, lindex: LONG): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnViewChange(self, dwAspect, lindex)
proc OnRename*(self: ptr IAdviseSink, pmk: ptr IMoniker): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnRename(self, pmk)
proc OnSave*(self: ptr IAdviseSink): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnSave(self)
proc OnClose*(self: ptr IAdviseSink): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnClose(self)
proc GetData*(self: ptr IDataObject, pformatetcIn: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetData(self, pformatetcIn, pmedium)
proc GetDataHere*(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDataHere(self, pformatetc, pmedium)
proc QueryGetData*(self: ptr IDataObject, pformatetc: ptr FORMATETC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.QueryGetData(self, pformatetc)
proc GetCanonicalFormatEtc*(self: ptr IDataObject, pformatectIn: ptr FORMATETC, pformatetcOut: ptr FORMATETC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetCanonicalFormatEtc(self, pformatectIn, pformatetcOut)
proc SetData*(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM, fRelease: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetData(self, pformatetc, pmedium, fRelease)
proc EnumFormatEtc*(self: ptr IDataObject, dwDirection: DWORD, ppenumFormatEtc: ptr ptr IEnumFORMATETC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumFormatEtc(self, dwDirection, ppenumFormatEtc)
proc DAdvise*(self: ptr IDataObject, pformatetc: ptr FORMATETC, advf: DWORD, pAdvSink: ptr IAdviseSink, pdwConnection: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DAdvise(self, pformatetc, advf, pAdvSink, pdwConnection)
proc DUnadvise*(self: ptr IDataObject, dwConnection: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DUnadvise(self, dwConnection)
proc EnumDAdvise*(self: ptr IDataObject, ppenumAdvise: ptr ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumDAdvise(self, ppenumAdvise)
proc GetTypeInfoCount*(self: ptr IDispatch, pctinfo: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfoCount(self, pctinfo)
proc GetTypeInfo*(self: ptr IDispatch, iTInfo: UINT, lcid: LCID, ppTInfo: ptr ptr ITypeInfo): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfo(self, iTInfo, lcid, ppTInfo)
proc GetIDsOfNames*(self: ptr IDispatch, riid: REFIID, rgszNames: ptr LPOLESTR, cNames: UINT, lcid: LCID, rgDispId: ptr DISPID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetIDsOfNames(self, riid, rgszNames, cNames, lcid, rgDispId)
proc Invoke*(self: ptr IDispatch, dispIdMember: DISPID, riid: REFIID, lcid: LCID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Invoke(self, dispIdMember, riid, lcid, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr)
proc Bind*(self: ptr ITypeComp, szName: LPOLESTR, lHashVal: ULONG, wFlags: WORD, ppTInfo: ptr ptr ITypeInfo, pDescKind: ptr DESCKIND, pBindPtr: ptr BINDPTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Bind(self, szName, lHashVal, wFlags, ppTInfo, pDescKind, pBindPtr)
proc BindType*(self: ptr ITypeComp, szName: LPOLESTR, lHashVal: ULONG, ppTInfo: ptr ptr ITypeInfo, ppTComp: ptr ptr ITypeComp): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.BindType(self, szName, lHashVal, ppTInfo, ppTComp)
proc GetTypeAttr*(self: ptr ITypeInfo, ppTypeAttr: ptr ptr TYPEATTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeAttr(self, ppTypeAttr)
proc GetTypeComp*(self: ptr ITypeInfo, ppTComp: ptr ptr ITypeComp): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeComp(self, ppTComp)
proc GetFuncDesc*(self: ptr ITypeInfo, index: UINT, ppFuncDesc: ptr ptr FUNCDESC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetFuncDesc(self, index, ppFuncDesc)
proc GetVarDesc*(self: ptr ITypeInfo, index: UINT, ppVarDesc: ptr ptr VARDESC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetVarDesc(self, index, ppVarDesc)
proc GetNames*(self: ptr ITypeInfo, memid: MEMBERID, rgBstrNames: ptr BSTR, cMaxNames: UINT, pcNames: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetNames(self, memid, rgBstrNames, cMaxNames, pcNames)
proc GetRefTypeOfImplType*(self: ptr ITypeInfo, index: UINT, pRefType: ptr HREFTYPE): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetRefTypeOfImplType(self, index, pRefType)
proc GetImplTypeFlags*(self: ptr ITypeInfo, index: UINT, pImplTypeFlags: ptr INT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetImplTypeFlags(self, index, pImplTypeFlags)
proc GetIDsOfNames*(self: ptr ITypeInfo, rgszNames: ptr LPOLESTR, cNames: UINT, pMemId: ptr MEMBERID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetIDsOfNames(self, rgszNames, cNames, pMemId)
proc Invoke*(self: ptr ITypeInfo, pvInstance: PVOID, memid: MEMBERID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Invoke(self, pvInstance, memid, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr)
proc GetDocumentation*(self: ptr ITypeInfo, memid: MEMBERID, pBstrName: ptr BSTR, pBstrDocString: ptr BSTR, pdwHelpContext: ptr DWORD, pBstrHelpFile: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDocumentation(self, memid, pBstrName, pBstrDocString, pdwHelpContext, pBstrHelpFile)
proc GetDllEntry*(self: ptr ITypeInfo, memid: MEMBERID, invKind: INVOKEKIND, pBstrDllName: ptr BSTR, pBstrName: ptr BSTR, pwOrdinal: ptr WORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDllEntry(self, memid, invKind, pBstrDllName, pBstrName, pwOrdinal)
proc GetRefTypeInfo*(self: ptr ITypeInfo, hRefType: HREFTYPE, ppTInfo: ptr ptr ITypeInfo): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetRefTypeInfo(self, hRefType, ppTInfo)
proc AddressOfMember*(self: ptr ITypeInfo, memid: MEMBERID, invKind: INVOKEKIND, ppv: ptr PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.AddressOfMember(self, memid, invKind, ppv)
proc CreateInstance*(self: ptr ITypeInfo, pUnkOuter: ptr IUnknown, riid: REFIID, ppvObj: ptr PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CreateInstance(self, pUnkOuter, riid, ppvObj)
proc GetMops*(self: ptr ITypeInfo, memid: MEMBERID, pBstrMops: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetMops(self, memid, pBstrMops)
proc GetContainingTypeLib*(self: ptr ITypeInfo, ppTLib: ptr ptr ITypeLib, pIndex: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetContainingTypeLib(self, ppTLib, pIndex)
proc ReleaseTypeAttr*(self: ptr ITypeInfo, pTypeAttr: ptr TYPEATTR): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ReleaseTypeAttr(self, pTypeAttr)
proc ReleaseFuncDesc*(self: ptr ITypeInfo, pFuncDesc: ptr FUNCDESC): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ReleaseFuncDesc(self, pFuncDesc)
proc ReleaseVarDesc*(self: ptr ITypeInfo, pVarDesc: ptr VARDESC): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ReleaseVarDesc(self, pVarDesc)
proc GetTypeInfoCount*(self: ptr ITypeLib): UINT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfoCount(self)
proc GetTypeInfo*(self: ptr ITypeLib, index: UINT, ppTInfo: ptr ptr ITypeInfo): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfo(self, index, ppTInfo)
proc GetTypeInfoType*(self: ptr ITypeLib, index: UINT, pTKind: ptr TYPEKIND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfoType(self, index, pTKind)
proc GetTypeInfoOfGuid*(self: ptr ITypeLib, guid: REFGUID, ppTinfo: ptr ptr ITypeInfo): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfoOfGuid(self, guid, ppTinfo)
proc GetLibAttr*(self: ptr ITypeLib, ppTLibAttr: ptr ptr TLIBATTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetLibAttr(self, ppTLibAttr)
proc GetTypeComp*(self: ptr ITypeLib, ppTComp: ptr ptr ITypeComp): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeComp(self, ppTComp)
proc GetDocumentation*(self: ptr ITypeLib, index: INT, pBstrName: ptr BSTR, pBstrDocString: ptr BSTR, pdwHelpContext: ptr DWORD, pBstrHelpFile: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDocumentation(self, index, pBstrName, pBstrDocString, pdwHelpContext, pBstrHelpFile)
proc IsName*(self: ptr ITypeLib, szNameBuf: LPOLESTR, lHashVal: ULONG, pfName: ptr WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsName(self, szNameBuf, lHashVal, pfName)
proc FindName*(self: ptr ITypeLib, szNameBuf: LPOLESTR, lHashVal: ULONG, ppTInfo: ptr ptr ITypeInfo, rgMemId: ptr MEMBERID, pcFound: ptr USHORT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.FindName(self, szNameBuf, lHashVal, ppTInfo, rgMemId, pcFound)
proc ReleaseTLibAttr*(self: ptr ITypeLib, pTLibAttr: ptr TLIBATTR): void {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ReleaseTLibAttr(self, pTLibAttr)
proc RecordInit*(self: ptr IRecordInfo, pvNew: PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RecordInit(self, pvNew)
proc RecordClear*(self: ptr IRecordInfo, pvExisting: PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RecordClear(self, pvExisting)
proc RecordCopy*(self: ptr IRecordInfo, pvExisting: PVOID, pvNew: PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RecordCopy(self, pvExisting, pvNew)
proc GetGuid*(self: ptr IRecordInfo, pguid: ptr GUID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetGuid(self, pguid)
proc GetName*(self: ptr IRecordInfo, pbstrName: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetName(self, pbstrName)
proc GetSize*(self: ptr IRecordInfo, pcbSize: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetSize(self, pcbSize)
proc GetTypeInfo*(self: ptr IRecordInfo, ppTypeInfo: ptr ptr ITypeInfo): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetTypeInfo(self, ppTypeInfo)
proc GetField*(self: ptr IRecordInfo, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetField(self, pvData, szFieldName, pvarField)
proc GetFieldNoCopy*(self: ptr IRecordInfo, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT, ppvDataCArray: ptr PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetFieldNoCopy(self, pvData, szFieldName, pvarField, ppvDataCArray)
proc PutField*(self: ptr IRecordInfo, wFlags: ULONG, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.PutField(self, wFlags, pvData, szFieldName, pvarField)
proc PutFieldNoCopy*(self: ptr IRecordInfo, wFlags: ULONG, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.PutFieldNoCopy(self, wFlags, pvData, szFieldName, pvarField)
proc GetFieldNames*(self: ptr IRecordInfo, pcNames: ptr ULONG, rgBstrNames: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetFieldNames(self, pcNames, rgBstrNames)
proc IsMatchingType*(self: ptr IRecordInfo, pRecordInfo: ptr IRecordInfo): WINBOOL {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsMatchingType(self, pRecordInfo)
proc RecordCreate*(self: ptr IRecordInfo): PVOID {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RecordCreate(self)
proc RecordCreateCopy*(self: ptr IRecordInfo, pvSource: PVOID, ppvDest: ptr PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RecordCreateCopy(self, pvSource, ppvDest)
proc RecordDestroy*(self: ptr IRecordInfo, pvRecord: PVOID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RecordDestroy(self, pvRecord)
proc ParseDisplayName*(self: ptr IParseDisplayName, pbc: ptr IBindCtx, pszDisplayName: LPOLESTR, pchEaten: ptr ULONG, ppmkOut: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ParseDisplayName(self, pbc, pszDisplayName, pchEaten, ppmkOut)
proc EnumObjects*(self: ptr IOleContainer, grfFlags: DWORD, ppenum: ptr ptr IEnumUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumObjects(self, grfFlags, ppenum)
proc LockContainer*(self: ptr IOleContainer, fLock: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.LockContainer(self, fLock)
proc SaveObject*(self: ptr IOleClientSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SaveObject(self)
proc GetMoniker*(self: ptr IOleClientSite, dwAssign: DWORD, dwWhichMoniker: DWORD, ppmk: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetMoniker(self, dwAssign, dwWhichMoniker, ppmk)
proc GetContainer*(self: ptr IOleClientSite, ppContainer: ptr ptr IOleContainer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetContainer(self, ppContainer)
proc ShowObject*(self: ptr IOleClientSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ShowObject(self)
proc OnShowWindow*(self: ptr IOleClientSite, fShow: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnShowWindow(self, fShow)
proc RequestNewObjectLayout*(self: ptr IOleClientSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RequestNewObjectLayout(self)
proc SetClientSite*(self: ptr IOleObject, pClientSite: ptr IOleClientSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetClientSite(self, pClientSite)
proc GetClientSite*(self: ptr IOleObject, ppClientSite: ptr ptr IOleClientSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetClientSite(self, ppClientSite)
proc SetHostNames*(self: ptr IOleObject, szContainerApp: LPCOLESTR, szContainerObj: LPCOLESTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetHostNames(self, szContainerApp, szContainerObj)
proc Close*(self: ptr IOleObject, dwSaveOption: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Close(self, dwSaveOption)
proc SetMoniker*(self: ptr IOleObject, dwWhichMoniker: DWORD, pmk: ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetMoniker(self, dwWhichMoniker, pmk)
proc GetMoniker*(self: ptr IOleObject, dwAssign: DWORD, dwWhichMoniker: DWORD, ppmk: ptr ptr IMoniker): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetMoniker(self, dwAssign, dwWhichMoniker, ppmk)
proc InitFromData*(self: ptr IOleObject, pDataObject: ptr IDataObject, fCreation: WINBOOL, dwReserved: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.InitFromData(self, pDataObject, fCreation, dwReserved)
proc GetClipboardData*(self: ptr IOleObject, dwReserved: DWORD, ppDataObject: ptr ptr IDataObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetClipboardData(self, dwReserved, ppDataObject)
proc DoVerb*(self: ptr IOleObject, iVerb: LONG, lpmsg: LPMSG, pActiveSite: ptr IOleClientSite, lindex: LONG, hwndParent: HWND, lprcPosRect: LPCRECT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DoVerb(self, iVerb, lpmsg, pActiveSite, lindex, hwndParent, lprcPosRect)
proc EnumVerbs*(self: ptr IOleObject, ppEnumOleVerb: ptr ptr IEnumOLEVERB): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumVerbs(self, ppEnumOleVerb)
proc Update*(self: ptr IOleObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Update(self)
proc IsUpToDate*(self: ptr IOleObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IsUpToDate(self)
proc GetUserClassID*(self: ptr IOleObject, pClsid: ptr CLSID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetUserClassID(self, pClsid)
proc GetUserType*(self: ptr IOleObject, dwFormOfType: DWORD, pszUserType: ptr LPOLESTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetUserType(self, dwFormOfType, pszUserType)
proc SetExtent*(self: ptr IOleObject, dwDrawAspect: DWORD, psizel: ptr SIZEL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetExtent(self, dwDrawAspect, psizel)
proc GetExtent*(self: ptr IOleObject, dwDrawAspect: DWORD, psizel: ptr SIZEL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetExtent(self, dwDrawAspect, psizel)
proc Advise*(self: ptr IOleObject, pAdvSink: ptr IAdviseSink, pdwConnection: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Advise(self, pAdvSink, pdwConnection)
proc Unadvise*(self: ptr IOleObject, dwConnection: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Unadvise(self, dwConnection)
proc EnumAdvise*(self: ptr IOleObject, ppenumAdvise: ptr ptr IEnumSTATDATA): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumAdvise(self, ppenumAdvise)
proc GetMiscStatus*(self: ptr IOleObject, dwAspect: DWORD, pdwStatus: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetMiscStatus(self, dwAspect, pdwStatus)
proc SetColorScheme*(self: ptr IOleObject, pLogpal: ptr LOGPALETTE): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetColorScheme(self, pLogpal)
proc GetWindow*(self: ptr IOleWindow, phwnd: ptr HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetWindow(self, phwnd)
proc ContextSensitiveHelp*(self: ptr IOleWindow, fEnterMode: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ContextSensitiveHelp(self, fEnterMode)
proc GetBorder*(self: ptr IOleInPlaceUIWindow, lprectBorder: LPRECT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetBorder(self, lprectBorder)
proc RequestBorderSpace*(self: ptr IOleInPlaceUIWindow, pborderwidths: LPCBORDERWIDTHS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RequestBorderSpace(self, pborderwidths)
proc SetBorderSpace*(self: ptr IOleInPlaceUIWindow, pborderwidths: LPCBORDERWIDTHS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetBorderSpace(self, pborderwidths)
proc SetActiveObject*(self: ptr IOleInPlaceUIWindow, pActiveObject: ptr IOleInPlaceActiveObject, pszObjName: LPCOLESTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetActiveObject(self, pActiveObject, pszObjName)
proc TranslateAccelerator*(self: ptr IOleInPlaceActiveObject, lpmsg: LPMSG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.TranslateAccelerator(self, lpmsg)
proc OnFrameWindowActivate*(self: ptr IOleInPlaceActiveObject, fActivate: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnFrameWindowActivate(self, fActivate)
proc OnDocWindowActivate*(self: ptr IOleInPlaceActiveObject, fActivate: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnDocWindowActivate(self, fActivate)
proc ResizeBorder*(self: ptr IOleInPlaceActiveObject, prcBorder: LPCRECT, pUIWindow: ptr IOleInPlaceUIWindow, fFrameWindow: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ResizeBorder(self, prcBorder, pUIWindow, fFrameWindow)
proc EnableModeless*(self: ptr IOleInPlaceActiveObject, fEnable: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnableModeless(self, fEnable)
proc InsertMenus*(self: ptr IOleInPlaceFrame, hmenuShared: HMENU, lpMenuWidths: LPOLEMENUGROUPWIDTHS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.InsertMenus(self, hmenuShared, lpMenuWidths)
proc SetMenu*(self: ptr IOleInPlaceFrame, hmenuShared: HMENU, holemenu: HOLEMENU, hwndActiveObject: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetMenu(self, hmenuShared, holemenu, hwndActiveObject)
proc RemoveMenus*(self: ptr IOleInPlaceFrame, hmenuShared: HMENU): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RemoveMenus(self, hmenuShared)
proc SetStatusText*(self: ptr IOleInPlaceFrame, pszStatusText: LPCOLESTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetStatusText(self, pszStatusText)
proc EnableModeless*(self: ptr IOleInPlaceFrame, fEnable: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnableModeless(self, fEnable)
proc TranslateAccelerator*(self: ptr IOleInPlaceFrame, lpmsg: LPMSG, wID: WORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.TranslateAccelerator(self, lpmsg, wID)
proc InPlaceDeactivate*(self: ptr IOleInPlaceObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.InPlaceDeactivate(self)
proc UIDeactivate*(self: ptr IOleInPlaceObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.UIDeactivate(self)
proc SetObjectRects*(self: ptr IOleInPlaceObject, lprcPosRect: LPCRECT, lprcClipRect: LPCRECT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetObjectRects(self, lprcPosRect, lprcClipRect)
proc ReactivateAndUndo*(self: ptr IOleInPlaceObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ReactivateAndUndo(self)
proc CanInPlaceActivate*(self: ptr IOleInPlaceSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.CanInPlaceActivate(self)
proc OnInPlaceActivate*(self: ptr IOleInPlaceSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnInPlaceActivate(self)
proc OnUIActivate*(self: ptr IOleInPlaceSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnUIActivate(self)
proc GetWindowContext*(self: ptr IOleInPlaceSite, ppFrame: ptr ptr IOleInPlaceFrame, ppDoc: ptr ptr IOleInPlaceUIWindow, lprcPosRect: LPRECT, lprcClipRect: LPRECT, lpFrameInfo: LPOLEINPLACEFRAMEINFO): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetWindowContext(self, ppFrame, ppDoc, lprcPosRect, lprcClipRect, lpFrameInfo)
proc Scroll*(self: ptr IOleInPlaceSite, scrollExtant: SIZE): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Scroll(self, scrollExtant)
proc OnUIDeactivate*(self: ptr IOleInPlaceSite, fUndoable: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnUIDeactivate(self, fUndoable)
proc OnInPlaceDeactivate*(self: ptr IOleInPlaceSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnInPlaceDeactivate(self)
proc DiscardUndoState*(self: ptr IOleInPlaceSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DiscardUndoState(self)
proc DeactivateAndUndo*(self: ptr IOleInPlaceSite): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DeactivateAndUndo(self)
proc OnPosRectChange*(self: ptr IOleInPlaceSite, lprcPosRect: LPCRECT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnPosRectChange(self, lprcPosRect)
proc QueryContinueDrag*(self: ptr IDropSource, fEscapePressed: WINBOOL, grfKeyState: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.QueryContinueDrag(self, fEscapePressed, grfKeyState)
proc GiveFeedback*(self: ptr IDropSource, dwEffect: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GiveFeedback(self, dwEffect)
proc DragEnter*(self: ptr IDropTarget, pDataObj: ptr IDataObject, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DragEnter(self, pDataObj, grfKeyState, pt, pdwEffect)
proc DragOver*(self: ptr IDropTarget, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DragOver(self, grfKeyState, pt, pdwEffect)
proc DragLeave*(self: ptr IDropTarget): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DragLeave(self)
proc Drop*(self: ptr IDropTarget, pDataObj: ptr IDataObject, grfKeyState: DWORD, pt: POINTL, pdwEffect: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Drop(self, pDataObj, grfKeyState, pt, pdwEffect)
proc Next*(self: ptr IEnumOLEVERB, celt: ULONG, rgelt: LPOLEVERB, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumOLEVERB, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumOLEVERB): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumOLEVERB, ppenum: ptr ptr IEnumOLEVERB): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc Next*(self: ptr IEnumConnections, cConnections: ULONG, rgcd: LPCONNECTDATA, pcFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, cConnections, rgcd, pcFetched)
proc Skip*(self: ptr IEnumConnections, cConnections: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, cConnections)
proc Reset*(self: ptr IEnumConnections): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumConnections, ppEnum: ptr ptr IEnumConnections): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppEnum)
proc GetConnectionInterface*(self: ptr IConnectionPoint, pIID: ptr IID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetConnectionInterface(self, pIID)
proc GetConnectionPointContainer*(self: ptr IConnectionPoint, ppCPC: ptr ptr IConnectionPointContainer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetConnectionPointContainer(self, ppCPC)
proc Advise*(self: ptr IConnectionPoint, pUnkSink: ptr IUnknown, pdwCookie: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Advise(self, pUnkSink, pdwCookie)
proc Unadvise*(self: ptr IConnectionPoint, dwCookie: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Unadvise(self, dwCookie)
proc EnumConnections*(self: ptr IConnectionPoint, ppEnum: ptr ptr IEnumConnections): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumConnections(self, ppEnum)
proc Next*(self: ptr IEnumConnectionPoints, cConnections: ULONG, ppCP: ptr LPCONNECTIONPOINT, pcFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, cConnections, ppCP, pcFetched)
proc Skip*(self: ptr IEnumConnectionPoints, cConnections: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, cConnections)
proc Reset*(self: ptr IEnumConnectionPoints): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumConnectionPoints, ppEnum: ptr ptr IEnumConnectionPoints): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppEnum)
proc EnumConnectionPoints*(self: ptr IConnectionPointContainer, ppEnum: ptr ptr IEnumConnectionPoints): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumConnectionPoints(self, ppEnum)
proc FindConnectionPoint*(self: ptr IConnectionPointContainer, riid: REFIID, ppCP: ptr ptr IConnectionPoint): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.FindConnectionPoint(self, riid, ppCP)
proc OnInPlaceActivateEx*(self: ptr IOleInPlaceSiteEx, pfNoRedraw: ptr WINBOOL, dwFlags: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnInPlaceActivateEx(self, pfNoRedraw, dwFlags)
proc OnInPlaceDeactivateEx*(self: ptr IOleInPlaceSiteEx, fNoRedraw: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnInPlaceDeactivateEx(self, fNoRedraw)
proc RequestUIActivate*(self: ptr IOleInPlaceSiteEx): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RequestUIActivate(self)
proc SetSite*(self: ptr IObjectWithSite, pUnkSite: ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetSite(self, pUnkSite)
proc GetSite*(self: ptr IObjectWithSite, riid: REFIID, ppvSite: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetSite(self, riid, ppvSite)
proc QueryStatus*(self: ptr IOleCommandTarget, pguidCmdGroup: ptr GUID, cCmds: ULONG, prgCmds: ptr OLECMD, pCmdText: ptr OLECMDTEXT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.QueryStatus(self, pguidCmdGroup, cCmds, prgCmds, pCmdText)
proc Exec*(self: ptr IOleCommandTarget, pguidCmdGroup: ptr GUID, nCmdID: DWORD, nCmdexecopt: DWORD, pvaIn: ptr VARIANT, pvaOut: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Exec(self, pguidCmdGroup, nCmdID, nCmdexecopt, pvaIn, pvaOut)
proc GoBack*(self: ptr IWebBrowser): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GoBack(self)
proc GoForward*(self: ptr IWebBrowser): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GoForward(self)
proc GoHome*(self: ptr IWebBrowser): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GoHome(self)
proc GoSearch*(self: ptr IWebBrowser): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GoSearch(self)
proc Navigate*(self: ptr IWebBrowser, URL: BSTR, Flags: ptr VARIANT, TargetFrameName: ptr VARIANT, PostData: ptr VARIANT, Headers: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Navigate(self, URL, Flags, TargetFrameName, PostData, Headers)
proc Refresh*(self: ptr IWebBrowser): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Refresh(self)
proc Refresh2*(self: ptr IWebBrowser, Level: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Refresh2(self, Level)
proc Stop*(self: ptr IWebBrowser): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Stop(self)
proc get_Application*(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Application(self, ppDisp)
proc get_Parent*(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Parent(self, ppDisp)
proc get_Container*(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Container(self, ppDisp)
proc get_Document*(self: ptr IWebBrowser, ppDisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Document(self, ppDisp)
proc get_TopLevelContainer*(self: ptr IWebBrowser, pBool: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_TopLevelContainer(self, pBool)
proc get_Type*(self: ptr IWebBrowser, Type: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Type(self, Type)
proc get_Left*(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Left(self, pl)
proc put_Left*(self: ptr IWebBrowser, Left: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Left(self, Left)
proc get_Top*(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Top(self, pl)
proc put_Top*(self: ptr IWebBrowser, Top: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Top(self, Top)
proc get_Width*(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Width(self, pl)
proc put_Width*(self: ptr IWebBrowser, Width: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Width(self, Width)
proc get_Height*(self: ptr IWebBrowser, pl: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Height(self, pl)
proc put_Height*(self: ptr IWebBrowser, Height: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Height(self, Height)
proc get_LocationName*(self: ptr IWebBrowser, LocationName: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_LocationName(self, LocationName)
proc get_LocationURL*(self: ptr IWebBrowser, LocationURL: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_LocationURL(self, LocationURL)
proc get_Busy*(self: ptr IWebBrowser, pBool: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Busy(self, pBool)
proc Quit*(self: ptr IWebBrowserApp): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Quit(self)
proc ClientToWindow*(self: ptr IWebBrowserApp, pcx: ptr int32, pcy: ptr int32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ClientToWindow(self, pcx, pcy)
proc PutProperty*(self: ptr IWebBrowserApp, Property: BSTR, vtValue: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.PutProperty(self, Property, vtValue)
proc GetProperty*(self: ptr IWebBrowserApp, Property: BSTR, pvtValue: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetProperty(self, Property, pvtValue)
proc get_Name*(self: ptr IWebBrowserApp, Name: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Name(self, Name)
proc get_HWND*(self: ptr IWebBrowserApp, pHWND: ptr SHANDLE_PTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_HWND(self, pHWND)
proc get_FullName*(self: ptr IWebBrowserApp, FullName: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_FullName(self, FullName)
proc get_Path*(self: ptr IWebBrowserApp, Path: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Path(self, Path)
proc get_Visible*(self: ptr IWebBrowserApp, pBool: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Visible(self, pBool)
proc put_Visible*(self: ptr IWebBrowserApp, Value: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Visible(self, Value)
proc get_StatusBar*(self: ptr IWebBrowserApp, pBool: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_StatusBar(self, pBool)
proc put_StatusBar*(self: ptr IWebBrowserApp, Value: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_StatusBar(self, Value)
proc get_StatusText*(self: ptr IWebBrowserApp, StatusText: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_StatusText(self, StatusText)
proc put_StatusText*(self: ptr IWebBrowserApp, StatusText: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_StatusText(self, StatusText)
proc get_ToolBar*(self: ptr IWebBrowserApp, Value: ptr int32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ToolBar(self, Value)
proc put_ToolBar*(self: ptr IWebBrowserApp, Value: int32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ToolBar(self, Value)
proc get_MenuBar*(self: ptr IWebBrowserApp, Value: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_MenuBar(self, Value)
proc put_MenuBar*(self: ptr IWebBrowserApp, Value: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_MenuBar(self, Value)
proc get_FullScreen*(self: ptr IWebBrowserApp, pbFullScreen: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_FullScreen(self, pbFullScreen)
proc put_FullScreen*(self: ptr IWebBrowserApp, bFullScreen: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_FullScreen(self, bFullScreen)
proc Navigate2*(self: ptr IWebBrowser2, URL: ptr VARIANT, Flags: ptr VARIANT, TargetFrameName: ptr VARIANT, PostData: ptr VARIANT, Headers: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Navigate2(self, URL, Flags, TargetFrameName, PostData, Headers)
proc QueryStatusWB*(self: ptr IWebBrowser2, cmdID: OLECMDID, pcmdf: ptr OLECMDF): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.QueryStatusWB(self, cmdID, pcmdf)
proc ExecWB*(self: ptr IWebBrowser2, cmdID: OLECMDID, cmdexecopt: OLECMDEXECOPT, pvaIn: ptr VARIANT, pvaOut: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ExecWB(self, cmdID, cmdexecopt, pvaIn, pvaOut)
proc ShowBrowserBar*(self: ptr IWebBrowser2, pvaClsid: ptr VARIANT, pvarShow: ptr VARIANT, pvarSize: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ShowBrowserBar(self, pvaClsid, pvarShow, pvarSize)
proc get_ReadyState*(self: ptr IWebBrowser2, plReadyState: ptr READYSTATE): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ReadyState(self, plReadyState)
proc get_Offline*(self: ptr IWebBrowser2, pbOffline: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Offline(self, pbOffline)
proc put_Offline*(self: ptr IWebBrowser2, bOffline: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Offline(self, bOffline)
proc get_Silent*(self: ptr IWebBrowser2, pbSilent: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Silent(self, pbSilent)
proc put_Silent*(self: ptr IWebBrowser2, bSilent: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Silent(self, bSilent)
proc get_RegisterAsBrowser*(self: ptr IWebBrowser2, pbRegister: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_RegisterAsBrowser(self, pbRegister)
proc put_RegisterAsBrowser*(self: ptr IWebBrowser2, bRegister: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_RegisterAsBrowser(self, bRegister)
proc get_RegisterAsDropTarget*(self: ptr IWebBrowser2, pbRegister: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_RegisterAsDropTarget(self, pbRegister)
proc put_RegisterAsDropTarget*(self: ptr IWebBrowser2, bRegister: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_RegisterAsDropTarget(self, bRegister)
proc get_TheaterMode*(self: ptr IWebBrowser2, pbRegister: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_TheaterMode(self, pbRegister)
proc put_TheaterMode*(self: ptr IWebBrowser2, bRegister: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_TheaterMode(self, bRegister)
proc get_AddressBar*(self: ptr IWebBrowser2, Value: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_AddressBar(self, Value)
proc put_AddressBar*(self: ptr IWebBrowser2, Value: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_AddressBar(self, Value)
proc get_Resizable*(self: ptr IWebBrowser2, Value: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Resizable(self, Value)
proc put_Resizable*(self: ptr IWebBrowser2, Value: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_Resizable(self, Value)
converter winimConverterIEnumUnknownToIUnknown*(x: ptr IEnumUnknown): ptr IUnknown = cast[ptr IUnknown](x)
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
converter winimConverterIDispatchToIUnknown*(x: ptr IDispatch): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterITypeCompToIUnknown*(x: ptr ITypeComp): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterITypeInfoToIUnknown*(x: ptr ITypeInfo): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterITypeLibToIUnknown*(x: ptr ITypeLib): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIRecordInfoToIUnknown*(x: ptr IRecordInfo): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIParseDisplayNameToIUnknown*(x: ptr IParseDisplayName): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleContainerToIParseDisplayName*(x: ptr IOleContainer): ptr IParseDisplayName = cast[ptr IParseDisplayName](x)
converter winimConverterIOleContainerToIUnknown*(x: ptr IOleContainer): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleClientSiteToIUnknown*(x: ptr IOleClientSite): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleObjectToIUnknown*(x: ptr IOleObject): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleWindowToIUnknown*(x: ptr IOleWindow): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleInPlaceUIWindowToIOleWindow*(x: ptr IOleInPlaceUIWindow): ptr IOleWindow = cast[ptr IOleWindow](x)
converter winimConverterIOleInPlaceUIWindowToIUnknown*(x: ptr IOleInPlaceUIWindow): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleInPlaceActiveObjectToIOleWindow*(x: ptr IOleInPlaceActiveObject): ptr IOleWindow = cast[ptr IOleWindow](x)
converter winimConverterIOleInPlaceActiveObjectToIUnknown*(x: ptr IOleInPlaceActiveObject): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleInPlaceFrameToIOleInPlaceUIWindow*(x: ptr IOleInPlaceFrame): ptr IOleInPlaceUIWindow = cast[ptr IOleInPlaceUIWindow](x)
converter winimConverterIOleInPlaceFrameToIOleWindow*(x: ptr IOleInPlaceFrame): ptr IOleWindow = cast[ptr IOleWindow](x)
converter winimConverterIOleInPlaceFrameToIUnknown*(x: ptr IOleInPlaceFrame): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleInPlaceObjectToIOleWindow*(x: ptr IOleInPlaceObject): ptr IOleWindow = cast[ptr IOleWindow](x)
converter winimConverterIOleInPlaceObjectToIUnknown*(x: ptr IOleInPlaceObject): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleInPlaceSiteToIOleWindow*(x: ptr IOleInPlaceSite): ptr IOleWindow = cast[ptr IOleWindow](x)
converter winimConverterIOleInPlaceSiteToIUnknown*(x: ptr IOleInPlaceSite): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIDropSourceToIUnknown*(x: ptr IDropSource): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIDropTargetToIUnknown*(x: ptr IDropTarget): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumOLEVERBToIUnknown*(x: ptr IEnumOLEVERB): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumConnectionsToIUnknown*(x: ptr IEnumConnections): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIConnectionPointToIUnknown*(x: ptr IConnectionPoint): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIEnumConnectionPointsToIUnknown*(x: ptr IEnumConnectionPoints): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIConnectionPointContainerToIUnknown*(x: ptr IConnectionPointContainer): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleInPlaceSiteExToIOleInPlaceSite*(x: ptr IOleInPlaceSiteEx): ptr IOleInPlaceSite = cast[ptr IOleInPlaceSite](x)
converter winimConverterIOleInPlaceSiteExToIOleWindow*(x: ptr IOleInPlaceSiteEx): ptr IOleWindow = cast[ptr IOleWindow](x)
converter winimConverterIOleInPlaceSiteExToIUnknown*(x: ptr IOleInPlaceSiteEx): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIObjectWithSiteToIUnknown*(x: ptr IObjectWithSite): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOleCommandTargetToIUnknown*(x: ptr IOleCommandTarget): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIWebBrowserToIDispatch*(x: ptr IWebBrowser): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIWebBrowserToIUnknown*(x: ptr IWebBrowser): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIWebBrowserAppToIWebBrowser*(x: ptr IWebBrowserApp): ptr IWebBrowser = cast[ptr IWebBrowser](x)
converter winimConverterIWebBrowserAppToIDispatch*(x: ptr IWebBrowserApp): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIWebBrowserAppToIUnknown*(x: ptr IWebBrowserApp): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIWebBrowser2ToIWebBrowserApp*(x: ptr IWebBrowser2): ptr IWebBrowserApp = cast[ptr IWebBrowserApp](x)
converter winimConverterIWebBrowser2ToIWebBrowser*(x: ptr IWebBrowser2): ptr IWebBrowser = cast[ptr IWebBrowser](x)
converter winimConverterIWebBrowser2ToIDispatch*(x: ptr IWebBrowser2): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIWebBrowser2ToIUnknown*(x: ptr IWebBrowser2): ptr IUnknown = cast[ptr IUnknown](x)
type
  HIMAGELIST* = HANDLE
  HPROPSHEETPAGE* = HANDLE
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
  TNMCUSTOMDRAW* {.pure.} = object
    hdr*: NMHDR
    dwDrawStage*: DWORD
    hdc*: HDC
    rc*: RECT
    dwItemSpec*: DWORD_PTR
    uItemState*: UINT
    lItemlParam*: LPARAM
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
  NMTBCUSTOMDRAW* {.pure.} = object
    nmcd*: TNMCUSTOMDRAW
    hbrMonoDither*: HBRUSH
    hbrLines*: HBRUSH
    hpenLines*: HPEN
    clrText*: COLORREF
    clrMark*: COLORREF
    clrTextHighlight*: COLORREF
    clrBtnFace*: COLORREF
    clrBtnHighlight*: COLORREF
    clrHighlightHotTrack*: COLORREF
    rcText*: RECT
    nStringBkMode*: int32
    nHLStringBkMode*: int32
    iListGap*: int32
  LPNMTBCUSTOMDRAW* = ptr NMTBCUSTOMDRAW
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
  RBHITTESTINFO* {.pure.} = object
    pt*: POINT
    flags*: UINT
    iBand*: int32
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
    iReserved*: int32
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
    iReserved*: int32
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
  ECM_FIRST* = 0x1500
  BCM_FIRST* = 0x1600
  NM_FIRST* = 0-0
  NM_CLICK* = NM_FIRST-2
  NM_DBLCLK* = NM_FIRST-3
  NM_RETURN* = NM_FIRST-4
  NM_RCLICK* = NM_FIRST-5
  NM_RDBLCLK* = NM_FIRST-6
  NM_SETFOCUS* = NM_FIRST-7
  NM_KILLFOCUS* = NM_FIRST-8
  NM_CUSTOMDRAW* = NM_FIRST-12
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
  CDRF_DODEFAULT* = 0x0
  CDRF_SKIPDEFAULT* = 0x4
  CDRF_NOTIFYITEMDRAW* = 0x20
  CDDS_PREPAINT* = 0x1
  CDDS_PREERASE* = 0x3
  CDDS_ITEM* = 0x10000
  CDDS_ITEMPREPAINT* = CDDS_ITEM or CDDS_PREPAINT
  CDIS_SELECTED* = 0x1
  CDIS_HOT* = 0x40
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
  TBSTATE_PRESSED* = 0x2
  TBSTATE_ENABLED* = 0x4
  TBSTATE_WRAP* = 0x20
  TBSTYLE_BUTTON* = 0x0
  TBSTYLE_SEP* = 0x1
  TBSTYLE_CHECK* = 0x2
  TBSTYLE_GROUP* = 0x4
  TBSTYLE_CHECKGROUP* = TBSTYLE_GROUP or TBSTYLE_CHECK
  TBSTYLE_DROPDOWN* = 0x8
  TBSTYLE_AUTOSIZE* = 0x10
  TBSTYLE_TOOLTIPS* = 0x100
  TBSTYLE_FLAT* = 0x800
  TBSTYLE_CUSTOMERASE* = 0x2000
  TBSTYLE_TRANSPARENT* = 0x8000
  TBSTYLE_EX_DRAWDDARROWS* = 0x1
  BTNS_SEP* = TBSTYLE_SEP
  BTNS_DROPDOWN* = TBSTYLE_DROPDOWN
  BTNS_AUTOSIZE* = TBSTYLE_AUTOSIZE
  BTNS_SHOWTEXT* = 0x40
  BTNS_WHOLEDROPDOWN* = 0x80
  TB_ENABLEBUTTON* = WM_USER+1
  TB_SETSTATE* = WM_USER+17
  TB_GETSTATE* = WM_USER+18
  TB_ADDBITMAP* = WM_USER+19
  TB_ADDBUTTONSA* = WM_USER+20
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
  TB_MAPACCELERATORA* = WM_USER+78
  TB_SETEXTENDEDSTYLE* = WM_USER+84
  TB_GETPADDING* = WM_USER+86
  TB_SETPADDING* = WM_USER+87
  TB_MAPACCELERATORW* = WM_USER+90
  TBIF_IMAGE* = 0x1
  TBIF_TEXT* = 0x2
  TBIF_STATE* = 0x4
  TBIF_STYLE* = 0x8
  TBIF_LPARAM* = 0x10
  TB_GETBUTTONINFOW* = WM_USER+63
  TB_GETBUTTONINFOA* = WM_USER+65
  TB_INSERTBUTTONW* = WM_USER+67
  TB_ADDBUTTONSW* = WM_USER+68
  TB_HITTEST* = WM_USER+69
  TB_SETDRAWTEXTFLAGS* = WM_USER+70
  TB_GETIDEALSIZE* = WM_USER+99
  TBN_DROPDOWN* = TBN_FIRST-10
  HICF_ENTERING* = 0x10
  HICF_LEAVING* = 0x20
  TBN_HOTITEMCHANGE* = TBN_FIRST-13
  TBDDRET_DEFAULT* = 0
  REBARCLASSNAMEW* = "ReBarWindow32"
  REBARCLASSNAMEA* = "ReBarWindow32"
  RBIM_IMAGELIST* = 0x1
  RBS_VARHEIGHT* = 0x200
  RBS_BANDBORDERS* = 0x400
  RBS_AUTOSIZE* = 0x2000
  RBS_DBLCLKTOGGLE* = 0x8000
  RBBS_BREAK* = 0x1
  RBBS_FIXEDSIZE* = 0x2
  RBBS_CHILDEDGE* = 0x4
  RBBS_HIDDEN* = 0x8
  RBBS_GRIPPERALWAYS* = 0x80
  RBBS_TOPALIGN* = 0x800
  RBBIM_STYLE* = 0x1
  RBBIM_TEXT* = 0x4
  RBBIM_IMAGE* = 0x8
  RBBIM_CHILD* = 0x10
  RBBIM_CHILDSIZE* = 0x20
  RBBIM_SIZE* = 0x40
  RBBIM_ID* = 0x100
  RB_INSERTBANDA* = WM_USER+1
  RB_DELETEBAND* = WM_USER+2
  RB_SETBARINFO* = WM_USER+4
  RB_SETBANDINFOA* = WM_USER+6
  RB_HITTEST* = WM_USER+8
  RB_GETRECT* = WM_USER+9
  RB_INSERTBANDW* = WM_USER+10
  RB_SETBANDINFOW* = WM_USER+11
  RB_GETBANDCOUNT* = WM_USER+12
  RB_GETROWCOUNT* = WM_USER+13
  RB_GETROWHEIGHT* = WM_USER+14
  RB_IDTOINDEX* = WM_USER+16
  RB_GETBARHEIGHT* = WM_USER+27
  RB_GETBANDINFOW* = WM_USER+28
  RB_GETBANDINFOA* = WM_USER+29
  RB_MINIMIZEBAND* = WM_USER+30
  RB_MAXIMIZEBAND* = WM_USER+31
  RB_SHOWBAND* = WM_USER+35
  RB_MOVEBAND* = WM_USER+39
  RB_SETBANDWIDTH* = WM_USER+44
  RBN_AUTOSIZE* = RBN_FIRST-3
  RBN_BEGINDRAG* = RBN_FIRST-4
  RBN_ENDDRAG* = RBN_FIRST-5
  RBN_MINMAX* = RBN_FIRST-21
  RBHT_NOWHERE* = 0x1
  RBHT_CAPTION* = 0x2
  RBHT_CLIENT* = 0x3
  RBHT_GRABBER* = 0x4
  RBHT_CHEVRON* = 0x8
  RBHT_SPLITTER* = 0x10
  TOOLTIPS_CLASSW* = "tooltips_class32"
  TOOLTIPS_CLASSA* = "tooltips_class32"
  TTS_ALWAYSTIP* = 0x1
  TTS_NOPREFIX* = 0x2
  TTS_BALLOON* = 0x40
  TTF_IDISHWND* = 0x1
  TTF_SUBCLASS* = 0x10
  TTF_TRACK* = 0x20
  TTDT_RESHOW* = 1
  TTDT_AUTOPOP* = 2
  TTDT_INITIAL* = 3
  TTI_INFO* = 1
  TTM_ACTIVATE* = WM_USER+1
  TTM_SETDELAYTIME* = WM_USER+3
  TTM_ADDTOOLA* = WM_USER+4
  TTM_ADDTOOLW* = WM_USER+50
  TTM_SETTOOLINFOA* = WM_USER+9
  TTM_SETTOOLINFOW* = WM_USER+54
  TTM_GETTEXTA* = WM_USER+11
  TTM_GETTEXTW* = WM_USER+56
  TTM_UPDATETIPTEXTA* = WM_USER+12
  TTM_UPDATETIPTEXTW* = WM_USER+57
  TTM_TRACKACTIVATE* = WM_USER+17
  TTM_TRACKPOSITION* = WM_USER+18
  TTM_SETMAXTIPWIDTH* = WM_USER+24
  TTM_SETTITLEA* = WM_USER+32
  TTM_SETTITLEW* = WM_USER+33
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
  TVS_SHOWSELALWAYS* = 0x20
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
    TB_MAPACCELERATOR* = TB_MAPACCELERATORW
    TB_GETBUTTONINFO* = TB_GETBUTTONINFOW
    TB_INSERTBUTTON* = TB_INSERTBUTTONW
    TB_ADDBUTTONS* = TB_ADDBUTTONSW
    REBARCLASSNAME* = REBARCLASSNAMEW
    RB_INSERTBAND* = RB_INSERTBANDW
    RB_SETBANDINFO* = RB_SETBANDINFOW
    RB_GETBANDINFO* = RB_GETBANDINFOW
    TOOLTIPS_CLASS* = TOOLTIPS_CLASSW
    TTM_ADDTOOL* = TTM_ADDTOOLW
    TTM_SETTOOLINFO* = TTM_SETTOOLINFOW
    TTM_GETTEXT* = TTM_GETTEXTW
    TTM_UPDATETIPTEXT* = TTM_UPDATETIPTEXTW
    TTM_SETTITLE* = TTM_SETTITLEW
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
    TB_MAPACCELERATOR* = TB_MAPACCELERATORA
    TB_GETBUTTONINFO* = TB_GETBUTTONINFOA
    TB_INSERTBUTTON* = TB_INSERTBUTTONA
    TB_ADDBUTTONS* = TB_ADDBUTTONSA
    REBARCLASSNAME* = REBARCLASSNAMEA
    RB_INSERTBAND* = RB_INSERTBANDA
    RB_SETBANDINFO* = RB_SETBANDINFOA
    RB_GETBANDINFO* = RB_GETBANDINFOA
    TOOLTIPS_CLASS* = TOOLTIPS_CLASSA
    TTM_ADDTOOL* = TTM_ADDTOOLA
    TTM_SETTOOLINFO* = TTM_SETTOOLINFOA
    TTM_GETTEXT* = TTM_GETTEXTA
    TTM_UPDATETIPTEXT* = TTM_UPDATETIPTEXTA
    TTM_SETTITLE* = TTM_SETTITLEA
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
  LPFRHOOKPROC* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): UINT_PTR {.stdcall.}
  FINDREPLACEA* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hInstance*: HINSTANCE
    Flags*: DWORD
    lpstrFindWhat*: LPSTR
    lpstrReplaceWith*: LPSTR
    wFindWhatLen*: WORD
    wReplaceWithLen*: WORD
    lCustData*: LPARAM
    lpfnHook*: LPFRHOOKPROC
    lpTemplateName*: LPCSTR
  LPFINDREPLACEA* = ptr FINDREPLACEA
  FINDREPLACEW* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hInstance*: HINSTANCE
    Flags*: DWORD
    lpstrFindWhat*: LPWSTR
    lpstrReplaceWith*: LPWSTR
    wFindWhatLen*: WORD
    wReplaceWithLen*: WORD
    lCustData*: LPARAM
    lpfnHook*: LPFRHOOKPROC
    lpTemplateName*: LPCWSTR
  LPFINDREPLACEW* = ptr FINDREPLACEW
  LPCFHOOKPROC* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): UINT_PTR {.stdcall.}
  TCHOOSEFONTA* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hDC*: HDC
    lpLogFont*: LPLOGFONTA
    iPointSize*: INT
    Flags*: DWORD
    rgbColors*: COLORREF
    lCustData*: LPARAM
    lpfnHook*: LPCFHOOKPROC
    lpTemplateName*: LPCSTR
    hInstance*: HINSTANCE
    lpszStyle*: LPSTR
    nFontType*: WORD
    MISSING_ALIGNMENT*: WORD
    nSizeMin*: INT
    nSizeMax*: INT
  LPCHOOSEFONTA* = ptr TCHOOSEFONTA
  TCHOOSEFONTW* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hDC*: HDC
    lpLogFont*: LPLOGFONTW
    iPointSize*: INT
    Flags*: DWORD
    rgbColors*: COLORREF
    lCustData*: LPARAM
    lpfnHook*: LPCFHOOKPROC
    lpTemplateName*: LPCWSTR
    hInstance*: HINSTANCE
    lpszStyle*: LPWSTR
    nFontType*: WORD
    MISSING_ALIGNMENT*: WORD
    nSizeMin*: INT
    nSizeMax*: INT
  LPCHOOSEFONTW* = ptr TCHOOSEFONTW
  PRINTPAGERANGE* {.pure.} = object
    nFromPage*: DWORD
    nToPage*: DWORD
  LPPRINTPAGERANGE* = ptr PRINTPAGERANGE
  TPRINTDLGEXA* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hDevMode*: HGLOBAL
    hDevNames*: HGLOBAL
    hDC*: HDC
    Flags*: DWORD
    Flags2*: DWORD
    ExclusionFlags*: DWORD
    nPageRanges*: DWORD
    nMaxPageRanges*: DWORD
    lpPageRanges*: LPPRINTPAGERANGE
    nMinPage*: DWORD
    nMaxPage*: DWORD
    nCopies*: DWORD
    hInstance*: HINSTANCE
    lpPrintTemplateName*: LPCSTR
    lpCallback*: LPUNKNOWN
    nPropertyPages*: DWORD
    lphPropertyPages*: ptr HPROPSHEETPAGE
    nStartPage*: DWORD
    dwResultAction*: DWORD
  LPPRINTDLGEXA* = ptr TPRINTDLGEXA
  TPRINTDLGEXW* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hDevMode*: HGLOBAL
    hDevNames*: HGLOBAL
    hDC*: HDC
    Flags*: DWORD
    Flags2*: DWORD
    ExclusionFlags*: DWORD
    nPageRanges*: DWORD
    nMaxPageRanges*: DWORD
    lpPageRanges*: LPPRINTPAGERANGE
    nMinPage*: DWORD
    nMaxPage*: DWORD
    nCopies*: DWORD
    hInstance*: HINSTANCE
    lpPrintTemplateName*: LPCWSTR
    lpCallback*: LPUNKNOWN
    nPropertyPages*: DWORD
    lphPropertyPages*: ptr HPROPSHEETPAGE
    nStartPage*: DWORD
    dwResultAction*: DWORD
  LPPRINTDLGEXW* = ptr TPRINTDLGEXW
  DEVNAMES* {.pure.} = object
    wDriverOffset*: WORD
    wDeviceOffset*: WORD
    wOutputOffset*: WORD
    wDefault*: WORD
  LPPAGESETUPHOOK* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): UINT_PTR {.stdcall.}
  LPPAGEPAINTHOOK* = proc (P1: HWND, P2: UINT, P3: WPARAM, P4: LPARAM): UINT_PTR {.stdcall.}
  TPAGESETUPDLGA* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hDevMode*: HGLOBAL
    hDevNames*: HGLOBAL
    Flags*: DWORD
    ptPaperSize*: POINT
    rtMinMargin*: RECT
    rtMargin*: RECT
    hInstance*: HINSTANCE
    lCustData*: LPARAM
    lpfnPageSetupHook*: LPPAGESETUPHOOK
    lpfnPagePaintHook*: LPPAGEPAINTHOOK
    lpPageSetupTemplateName*: LPCSTR
    hPageSetupTemplate*: HGLOBAL
  LPPAGESETUPDLGA* = ptr TPAGESETUPDLGA
  TPAGESETUPDLGW* {.pure.} = object
    lStructSize*: DWORD
    hwndOwner*: HWND
    hDevMode*: HGLOBAL
    hDevNames*: HGLOBAL
    Flags*: DWORD
    ptPaperSize*: POINT
    rtMinMargin*: RECT
    rtMargin*: RECT
    hInstance*: HINSTANCE
    lCustData*: LPARAM
    lpfnPageSetupHook*: LPPAGESETUPHOOK
    lpfnPagePaintHook*: LPPAGEPAINTHOOK
    lpPageSetupTemplateName*: LPCWSTR
    hPageSetupTemplate*: HGLOBAL
  LPPAGESETUPDLGW* = ptr TPAGESETUPDLGW
const
  IID_IPrintDialogCallback* = DEFINE_GUID("5852a2c3-6530-11d1-b6a3-0000f8757bf9")
  OFN_OVERWRITEPROMPT* = 0x2
  OFN_NOCHANGEDIR* = 0x8
  OFN_ENABLEHOOK* = 0x20
  OFN_ALLOWMULTISELECT* = 0x200
  OFN_FILEMUSTEXIST* = 0x1000
  OFN_CREATEPROMPT* = 0x2000
  OFN_EXPLORER* = 0x80000
  OFN_NODEREFERENCELINKS* = 0x100000
  CC_RGBINIT* = 0x1
  CC_FULLOPEN* = 0x2
  CC_SHOWHELP* = 0x8
  CC_ENABLEHOOK* = 0x10
  CC_ANYCOLOR* = 0x100
  FR_DOWN* = 0x1
  FR_WHOLEWORD* = 0x2
  FR_MATCHCASE* = 0x4
  FR_FINDNEXT* = 0x8
  FR_REPLACE* = 0x10
  FR_REPLACEALL* = 0x20
  FR_DIALOGTERM* = 0x40
  FR_SHOWHELP* = 0x80
  FR_ENABLEHOOK* = 0x100
  FR_NOUPDOWN* = 0x400
  FR_NOMATCHCASE* = 0x800
  FR_NOWHOLEWORD* = 0x1000
  FR_HIDEUPDOWN* = 0x4000
  FR_HIDEMATCHCASE* = 0x8000
  FR_HIDEWHOLEWORD* = 0x10000
  CF_SHOWHELP* = 0x4
  CF_ENABLEHOOK* = 0x8
  CF_INITTOLOGFONTSTRUCT* = 0x40
  CF_EFFECTS* = 0x100
  CF_APPLY* = 0x200
  CF_ANSIONLY* = 0x400
  CF_SCRIPTSONLY* = CF_ANSIONLY
  CF_LIMITSIZE* = 0x2000
  WM_CHOOSEFONT_GETLOGFONT* = WM_USER+1
  FINDMSGSTRINGA* = "commdlg_FindReplace"
  FINDMSGSTRINGW* = "commdlg_FindReplace"
  PD_SELECTION* = 0x1
  PD_PAGENUMS* = 0x2
  PD_NOSELECTION* = 0x4
  PD_NOPAGENUMS* = 0x8
  PD_COLLATE* = 0x10
  PD_PRINTTOFILE* = 0x20
  PD_DISABLEPRINTTOFILE* = 0x80000
  PD_CURRENTPAGE* = 0x400000
  PD_NOCURRENTPAGE* = 0x800000
  START_PAGE_GENERAL* = 0xffffffff'i32
  PD_RESULT_PRINT* = 1
  PD_RESULT_APPLY* = 2
  PSD_MINMARGINS* = 0x1
  PSD_MARGINS* = 0x2
  PSD_INHUNDREDTHSOFMILLIMETERS* = 0x8
  PSD_DISABLEMARGINS* = 0x10
  PSD_DISABLEPRINTER* = 0x20
  PSD_DISABLEORIENTATION* = 0x100
  PSD_RETURNDEFAULT* = 0x400
  PSD_DISABLEPAPER* = 0x200
  PSD_SHOWHELP* = 0x800
  PSD_ENABLEPAGESETUPHOOK* = 0x2000
type
  IPrintDialogCallback* {.pure.} = object
    lpVtbl*: ptr IPrintDialogCallbackVtbl
  IPrintDialogCallbackVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    InitDone*: proc(self: ptr IPrintDialogCallback): HRESULT {.stdcall.}
    SelectionChange*: proc(self: ptr IPrintDialogCallback): HRESULT {.stdcall.}
    HandleMessage*: proc(self: ptr IPrintDialogCallback, hDlg: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM, pResult: ptr LRESULT): HRESULT {.stdcall.}
  IPrintDialogServices* {.pure.} = object
    lpVtbl*: ptr IPrintDialogServicesVtbl
  IPrintDialogServicesVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    GetCurrentDevMode*: proc(self: ptr IPrintDialogServices, pDevMode: LPDEVMODE, pcbSize: ptr UINT): HRESULT {.stdcall.}
    GetCurrentPrinterName*: proc(self: ptr IPrintDialogServices, pPrinterName: LPTSTR, pcchSize: ptr UINT): HRESULT {.stdcall.}
    GetCurrentPortName*: proc(self: ptr IPrintDialogServices, pPortName: LPTSTR, pcchSize: ptr UINT): HRESULT {.stdcall.}
proc InitDone*(self: ptr IPrintDialogCallback): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.InitDone(self)
proc SelectionChange*(self: ptr IPrintDialogCallback): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SelectionChange(self)
proc HandleMessage*(self: ptr IPrintDialogCallback, hDlg: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM, pResult: ptr LRESULT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.HandleMessage(self, hDlg, uMsg, wParam, lParam, pResult)
proc GetCurrentDevMode*(self: ptr IPrintDialogServices, pDevMode: LPDEVMODE, pcbSize: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetCurrentDevMode(self, pDevMode, pcbSize)
proc GetCurrentPrinterName*(self: ptr IPrintDialogServices, pPrinterName: LPTSTR, pcchSize: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetCurrentPrinterName(self, pPrinterName, pcchSize)
proc GetCurrentPortName*(self: ptr IPrintDialogServices, pPortName: LPTSTR, pcchSize: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetCurrentPortName(self, pPortName, pcchSize)
converter winimConverterIPrintDialogCallbackToIUnknown*(x: ptr IPrintDialogCallback): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIPrintDialogServicesToIUnknown*(x: ptr IPrintDialogServices): ptr IUnknown = cast[ptr IUnknown](x)
when winimUnicode:
  type
    OPENFILENAME* = OPENFILENAMEW
    TCHOOSECOLOR* = TCHOOSECOLORW
    FINDREPLACE* = FINDREPLACEW
    TCHOOSEFONT* = TCHOOSEFONTW
    TPRINTDLGEX* = TPRINTDLGEXW
    TPAGESETUPDLG* = TPAGESETUPDLGW
  const
    FINDMSGSTRING* = FINDMSGSTRINGW
  proc GetOpenFileName*(P1: LPOPENFILENAMEW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetOpenFileNameW".}
  proc GetSaveFileName*(P1: LPOPENFILENAMEW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetSaveFileNameW".}
  proc ChooseColor*(P1: LPCHOOSECOLORW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "ChooseColorW".}
  proc FindText*(P1: LPFINDREPLACEW): HWND {.winapi, stdcall, dynlib: "comdlg32", importc: "FindTextW".}
  proc ReplaceText*(P1: LPFINDREPLACEW): HWND {.winapi, stdcall, dynlib: "comdlg32", importc: "ReplaceTextW".}
  proc ChooseFont*(P1: LPCHOOSEFONTW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "ChooseFontW".}
  proc PrintDlgEx*(P1: LPPRINTDLGEXW): HRESULT {.winapi, stdcall, dynlib: "comdlg32", importc: "PrintDlgExW".}
  proc PageSetupDlg*(P1: LPPAGESETUPDLGW): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "PageSetupDlgW".}
when winimAnsi:
  type
    OPENFILENAME* = OPENFILENAMEA
    TCHOOSECOLOR* = TCHOOSECOLORA
    FINDREPLACE* = FINDREPLACEA
    TCHOOSEFONT* = TCHOOSEFONTA
    TPRINTDLGEX* = TPRINTDLGEXA
    TPAGESETUPDLG* = TPAGESETUPDLGA
  const
    FINDMSGSTRING* = FINDMSGSTRINGA
  proc GetOpenFileName*(P1: LPOPENFILENAMEA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetOpenFileNameA".}
  proc GetSaveFileName*(P1: LPOPENFILENAMEA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "GetSaveFileNameA".}
  proc ChooseColor*(P1: LPCHOOSECOLORA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "ChooseColorA".}
  proc FindText*(P1: LPFINDREPLACEA): HWND {.winapi, stdcall, dynlib: "comdlg32", importc: "FindTextA".}
  proc ReplaceText*(P1: LPFINDREPLACEA): HWND {.winapi, stdcall, dynlib: "comdlg32", importc: "ReplaceTextA".}
  proc ChooseFont*(P1: LPCHOOSEFONTA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "ChooseFontA".}
  proc PrintDlgEx*(P1: LPPRINTDLGEXA): HRESULT {.winapi, stdcall, dynlib: "comdlg32", importc: "PrintDlgExA".}
  proc PageSetupDlg*(P1: LPPAGESETUPDLGA): WINBOOL {.winapi, stdcall, dynlib: "comdlg32", importc: "PageSetupDlgA".}
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
  EM_STREAMIN* = WM_USER+73
  EM_STREAMOUT* = WM_USER+74
  EM_GETTEXTRANGE* = WM_USER+75
  EM_REDO* = WM_USER+84
  EM_CANREDO* = WM_USER+85
  EM_AUTOURLDETECT* = WM_USER+91
  EM_GETTEXTLENGTHEX* = WM_USER+95
  EM_SETTEXTEX* = WM_USER+97
  EM_SETZOOM* = WM_USER+225
  EN_REQUESTRESIZE* = 0x0701
  EN_LINK* = 0x070b
  ENM_CHANGE* = 0x00000001
  ENM_UPDATE* = 0x00000002
  ENM_REQUESTRESIZE* = 0x00040000
  ENM_LINK* = 0x04000000
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
  CFM_BACKCOLOR* = 0x04000000
  CFM_EFFECTS* = CFM_BOLD or CFM_ITALIC or CFM_UNDERLINE or CFM_COLOR or CFM_STRIKEOUT or CFE_PROTECTED or CFM_LINK
  SCF_SELECTION* = 0x0001
  SCF_DEFAULT* = 0x0000
  SF_RTF* = 0x0002
  SFF_SELECTION* = 0x8000
  MAX_TAB_STOPS* = 32
  PFM_STARTINDENT* = 0x00000001
  PFM_RIGHTINDENT* = 0x00000002
  PFM_OFFSET* = 0x00000004
  PFM_ALIGNMENT* = 0x00000008
  PFM_TABSTOPS* = 0x00000010
  PFM_NUMBERING* = 0x00000020
  PFM_SPACEBEFORE* = 0x00000040
  PFM_SPACEAFTER* = 0x00000080
  PFM_LINESPACING* = 0x00000100
  PFN_BULLET* = 1
  PFN_ARABIC* = 2
  PFN_LCLETTER* = 3
  PFN_UCLETTER* = 4
  PFN_LCROMAN* = 5
  PFN_UCROMAN* = 6
  PFA_LEFT* = 1
  PFA_RIGHT* = 2
  PFA_CENTER* = 3
  PFA_JUSTIFY* = 4
  ST_SELECTION* = 2
  GTL_DEFAULT* = 0
  AURL_ENABLEEA* = 1
type
  EDITSTREAMCALLBACK* = proc (dwCookie: DWORD_PTR, pbBuff: LPBYTE, cb: LONG, pcb: ptr LONG): DWORD {.stdcall.}
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
  EDITSTREAM* {.pure, packed.} = object
    dwCookie*: DWORD_PTR
    dwError*: DWORD
    pfnCallback*: EDITSTREAMCALLBACK
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
  TENLINK* {.pure, packed.} = object
    nmhdr*: NMHDR
    msg*: UINT
    wParam*: WPARAM
    lParam*: LPARAM
    chrg*: CHARRANGE
  SETTEXTEX* {.pure.} = object
    flags*: DWORD
    codepage*: UINT
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
  IAutoComplete* {.pure.} = object
    lpVtbl*: ptr IAutoCompleteVtbl
  IAutoCompleteVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Init*: proc(self: ptr IAutoComplete, hwndEdit: HWND, punkACL: ptr IUnknown, pwszRegKeyPath: LPCWSTR, pwszQuickComplete: LPCWSTR): HRESULT {.stdcall.}
    Enable*: proc(self: ptr IAutoComplete, fEnable: WINBOOL): HRESULT {.stdcall.}
  IAutoComplete2* {.pure.} = object
    lpVtbl*: ptr IAutoComplete2Vtbl
  IAutoComplete2Vtbl* {.pure, inheritable.} = object of IAutoCompleteVtbl
    SetOptions*: proc(self: ptr IAutoComplete2, dwFlag: DWORD): HRESULT {.stdcall.}
    GetOptions*: proc(self: ptr IAutoComplete2, pdwFlag: ptr DWORD): HRESULT {.stdcall.}
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
  IID_IAutoComplete* = DEFINE_GUID("00bb2762-6a77-11d0-a535-00c04fd7d062")
  ACO_AUTOSUGGEST* = 0x1
  IID_IAutoComplete2* = DEFINE_GUID("eac04bc0-3791-11d2-bb95-0060977b464c")
  IID_IObjMgr* = DEFINE_GUID("00bb2761-6a77-11d0-a535-00c04fd7d062")
  IID_IACList2* = DEFINE_GUID("470141a0-5186-11d2-bbb6-0060977b464c")
  CLSID_AutoComplete* = DEFINE_GUID("00bb2763-6a77-11d0-a535-00c04fd7d062")
  CLSID_ACLHistory* = DEFINE_GUID("00bb2764-6a77-11d0-a535-00c04fd7d062")
  CLSID_ACListISF* = DEFINE_GUID("03c036f1-a186-11d0-824a-00aa005b4383")
  CLSID_ACLMRU* = DEFINE_GUID("6756a641-de71-11d0-831b-00aa005b4383")
  CLSID_ACLMulti* = DEFINE_GUID("00bb2765-6a77-11d0-a535-00c04fd7d062")
  SIGDN_FILESYSPATH* = int32 0x80058000'i32
  IID_IShellItem* = DEFINE_GUID("43826d1e-e718-42ee-bc55-a1e261c37bfe")
  TBPF_NOPROGRESS* = 0x0
  TBPF_INDETERMINATE* = 0x1
  TBPF_NORMAL* = 0x2
  TBPF_ERROR* = 0x4
  TBPF_PAUSED* = 0x8
  IID_ITaskbarList3* = DEFINE_GUID("ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf")
  FOS_PICKFOLDERS* = 0x20
  FOS_FORCEFILESYSTEM* = 0x40
  IID_IFileOpenDialog* = DEFINE_GUID("d57c7288-d4ad-4768-be02-9d969532d960")
  CLSID_TaskbarList* = DEFINE_GUID("56fdf344-fd6d-11d0-958a-006097c9a090")
  CLSID_FileOpenDialog* = DEFINE_GUID("dc1c5a9c-e88a-4dde-a5a1-60f82a20aef7")
  CSIDL_DESKTOP* = 0x0000
  BIF_RETURNONLYFSDIRS* = 0x00000001
  BIF_EDITBOX* = 0x00000010
  BIF_NEWDIALOGSTYLE* = 0x00000040
  BIF_USENEWUI* = BIF_NEWDIALOGSTYLE or BIF_EDITBOX
  BIF_NONEWFOLDERBUTTON* = 0x00000200
  BFFM_INITIALIZED* = 1
  BFFM_SETSELECTIONA* = WM_USER+102
  BFFM_SETSELECTIONW* = WM_USER+103
  ACLO_FILESYSONLY* = 16
  ACLO_FILESYSDIRS* = 32
type
  DLLVERSIONINFO* {.pure.} = object
    cbSize*: DWORD
    dwMajorVersion*: DWORD
    dwMinorVersion*: DWORD
    dwBuildNumber*: DWORD
    dwPlatformID*: DWORD
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
  IObjMgr* {.pure.} = object
    lpVtbl*: ptr IObjMgrVtbl
  IObjMgrVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Append*: proc(self: ptr IObjMgr, punk: ptr IUnknown): HRESULT {.stdcall.}
    Remove*: proc(self: ptr IObjMgr, punk: ptr IUnknown): HRESULT {.stdcall.}
  IACList* {.pure.} = object
    lpVtbl*: ptr IACListVtbl
  IACListVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    Expand*: proc(self: ptr IACList, pszExpand: PCWSTR): HRESULT {.stdcall.}
  IACList2* {.pure.} = object
    lpVtbl*: ptr IACList2Vtbl
  IACList2Vtbl* {.pure, inheritable.} = object of IACListVtbl
    SetOptions*: proc(self: ptr IACList2, dwFlag: DWORD): HRESULT {.stdcall.}
    GetOptions*: proc(self: ptr IACList2, pdwFlag: ptr DWORD): HRESULT {.stdcall.}
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
proc Init*(self: ptr IAutoComplete, hwndEdit: HWND, punkACL: ptr IUnknown, pwszRegKeyPath: LPCWSTR, pwszQuickComplete: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Init(self, hwndEdit, punkACL, pwszRegKeyPath, pwszQuickComplete)
proc Enable*(self: ptr IAutoComplete, fEnable: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Enable(self, fEnable)
proc SetOptions*(self: ptr IAutoComplete2, dwFlag: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetOptions(self, dwFlag)
proc GetOptions*(self: ptr IAutoComplete2, pdwFlag: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetOptions(self, pdwFlag)
proc BindToHandler*(self: ptr IShellItem, pbc: ptr IBindCtx, bhid: REFGUID, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.BindToHandler(self, pbc, bhid, riid, ppv)
proc GetParent*(self: ptr IShellItem, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetParent(self, ppsi)
proc GetDisplayName*(self: ptr IShellItem, sigdnName: SIGDN, ppszName: ptr LPWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDisplayName(self, sigdnName, ppszName)
proc GetAttributes*(self: ptr IShellItem, sfgaoMask: SFGAOF, psfgaoAttribs: ptr SFGAOF): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetAttributes(self, sfgaoMask, psfgaoAttribs)
proc Compare*(self: ptr IShellItem, psi: ptr IShellItem, hint: SICHINTF, piOrder: ptr int32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Compare(self, psi, hint, piOrder)
proc Next*(self: ptr IEnumShellItems, celt: ULONG, rgelt: ptr ptr IShellItem, pceltFetched: ptr ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Next(self, celt, rgelt, pceltFetched)
proc Skip*(self: ptr IEnumShellItems, celt: ULONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Skip(self, celt)
proc Reset*(self: ptr IEnumShellItems): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Reset(self)
proc Clone*(self: ptr IEnumShellItems, ppenum: ptr ptr IEnumShellItems): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Clone(self, ppenum)
proc BindToHandler*(self: ptr IShellItemArray, pbc: ptr IBindCtx, bhid: REFGUID, riid: REFIID, ppvOut: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.BindToHandler(self, pbc, bhid, riid, ppvOut)
proc GetPropertyStore*(self: ptr IShellItemArray, flags: GETPROPERTYSTOREFLAGS, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetPropertyStore(self, flags, riid, ppv)
proc GetPropertyDescriptionList*(self: ptr IShellItemArray, keyType: REFPROPERTYKEY, riid: REFIID, ppv: ptr pointer): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetPropertyDescriptionList(self, keyType, riid, ppv)
proc GetAttributes*(self: ptr IShellItemArray, AttribFlags: SIATTRIBFLAGS, sfgaoMask: SFGAOF, psfgaoAttribs: ptr SFGAOF): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetAttributes(self, AttribFlags, sfgaoMask, psfgaoAttribs)
proc GetCount*(self: ptr IShellItemArray, pdwNumItems: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetCount(self, pdwNumItems)
proc GetItemAt*(self: ptr IShellItemArray, dwIndex: DWORD, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetItemAt(self, dwIndex, ppsi)
proc EnumItems*(self: ptr IShellItemArray, ppenumShellItems: ptr ptr IEnumShellItems): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnumItems(self, ppenumShellItems)
proc HrInit*(self: ptr ITaskbarList): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.HrInit(self)
proc AddTab*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.AddTab(self, hwnd)
proc DeleteTab*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.DeleteTab(self, hwnd)
proc ActivateTab*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ActivateTab(self, hwnd)
proc SetActiveAlt*(self: ptr ITaskbarList, hwnd: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetActiveAlt(self, hwnd)
proc MarkFullscreenWindow*(self: ptr ITaskbarList2, hwnd: HWND, fFullscreen: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.MarkFullscreenWindow(self, hwnd, fFullscreen)
proc SetProgressValue*(self: ptr ITaskbarList3, hwnd: HWND, ullCompleted: ULONGLONG, ullTotal: ULONGLONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetProgressValue(self, hwnd, ullCompleted, ullTotal)
proc SetProgressState*(self: ptr ITaskbarList3, hwnd: HWND, tbpFlags: TBPFLAG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetProgressState(self, hwnd, tbpFlags)
proc RegisterTab*(self: ptr ITaskbarList3, hwndTab: HWND, hwndMDI: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.RegisterTab(self, hwndTab, hwndMDI)
proc UnregisterTab*(self: ptr ITaskbarList3, hwndTab: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.UnregisterTab(self, hwndTab)
proc SetTabOrder*(self: ptr ITaskbarList3, hwndTab: HWND, hwndInsertBefore: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetTabOrder(self, hwndTab, hwndInsertBefore)
proc SetTabActive*(self: ptr ITaskbarList3, hwndTab: HWND, hwndMDI: HWND, dwReserved: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetTabActive(self, hwndTab, hwndMDI, dwReserved)
proc ThumbBarAddButtons*(self: ptr ITaskbarList3, hwnd: HWND, cButtons: UINT, pButton: LPTHUMBBUTTON): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ThumbBarAddButtons(self, hwnd, cButtons, pButton)
proc ThumbBarUpdateButtons*(self: ptr ITaskbarList3, hwnd: HWND, cButtons: UINT, pButton: LPTHUMBBUTTON): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ThumbBarUpdateButtons(self, hwnd, cButtons, pButton)
proc ThumbBarSetImageList*(self: ptr ITaskbarList3, hwnd: HWND, himl: HIMAGELIST): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ThumbBarSetImageList(self, hwnd, himl)
proc SetOverlayIcon*(self: ptr ITaskbarList3, hwnd: HWND, hIcon: HICON, pszDescription: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetOverlayIcon(self, hwnd, hIcon, pszDescription)
proc SetThumbnailTooltip*(self: ptr ITaskbarList3, hwnd: HWND, pszTip: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetThumbnailTooltip(self, hwnd, pszTip)
proc SetThumbnailClip*(self: ptr ITaskbarList3, hwnd: HWND, prcClip: ptr RECT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetThumbnailClip(self, hwnd, prcClip)
proc Show*(self: ptr IModalWindow, hwndOwner: HWND): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Show(self, hwndOwner)
proc OnFileOk*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnFileOk(self, pfd)
proc OnFolderChanging*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psiFolder: ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnFolderChanging(self, pfd, psiFolder)
proc OnFolderChange*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnFolderChange(self, pfd)
proc OnSelectionChange*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnSelectionChange(self, pfd)
proc OnShareViolation*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psi: ptr IShellItem, pResponse: ptr FDE_SHAREVIOLATION_RESPONSE): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnShareViolation(self, pfd, psi, pResponse)
proc OnTypeChange*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnTypeChange(self, pfd)
proc OnOverwrite*(self: ptr IFileDialogEvents, pfd: ptr IFileDialog, psi: ptr IShellItem, pResponse: ptr FDE_OVERWRITE_RESPONSE): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnOverwrite(self, pfd, psi, pResponse)
proc SetFileTypes*(self: ptr IFileDialog, cFileTypes: UINT, rgFilterSpec: ptr COMDLG_FILTERSPEC): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetFileTypes(self, cFileTypes, rgFilterSpec)
proc SetFileTypeIndex*(self: ptr IFileDialog, iFileType: UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetFileTypeIndex(self, iFileType)
proc GetFileTypeIndex*(self: ptr IFileDialog, piFileType: ptr UINT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetFileTypeIndex(self, piFileType)
proc Advise*(self: ptr IFileDialog, pfde: ptr IFileDialogEvents, pdwCookie: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Advise(self, pfde, pdwCookie)
proc Unadvise*(self: ptr IFileDialog, dwCookie: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Unadvise(self, dwCookie)
proc SetOptions*(self: ptr IFileDialog, fos: FILEOPENDIALOGOPTIONS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetOptions(self, fos)
proc GetOptions*(self: ptr IFileDialog, pfos: ptr FILEOPENDIALOGOPTIONS): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetOptions(self, pfos)
proc SetDefaultFolder*(self: ptr IFileDialog, psi: ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetDefaultFolder(self, psi)
proc SetFolder*(self: ptr IFileDialog, psi: ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetFolder(self, psi)
proc GetFolder*(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetFolder(self, ppsi)
proc GetCurrentSelection*(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetCurrentSelection(self, ppsi)
proc SetFileName*(self: ptr IFileDialog, pszName: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetFileName(self, pszName)
proc GetFileName*(self: ptr IFileDialog, pszName: ptr LPWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetFileName(self, pszName)
proc SetTitle*(self: ptr IFileDialog, pszTitle: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetTitle(self, pszTitle)
proc SetOkButtonLabel*(self: ptr IFileDialog, pszText: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetOkButtonLabel(self, pszText)
proc SetFileNameLabel*(self: ptr IFileDialog, pszLabel: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetFileNameLabel(self, pszLabel)
proc GetResult*(self: ptr IFileDialog, ppsi: ptr ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetResult(self, ppsi)
proc AddPlace*(self: ptr IFileDialog, psi: ptr IShellItem, fdap: FDAP): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.AddPlace(self, psi, fdap)
proc SetDefaultExtension*(self: ptr IFileDialog, pszDefaultExtension: LPCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetDefaultExtension(self, pszDefaultExtension)
proc Close*(self: ptr IFileDialog, hr: HRESULT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Close(self, hr)
proc SetClientGuid*(self: ptr IFileDialog, guid: REFGUID): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetClientGuid(self, guid)
proc ClearClientData*(self: ptr IFileDialog): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ClearClientData(self)
proc SetFilter*(self: ptr IFileDialog, pFilter: ptr IShellItemFilter): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetFilter(self, pFilter)
proc GetResults*(self: ptr IFileOpenDialog, ppenum: ptr ptr IShellItemArray): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetResults(self, ppenum)
proc GetSelectedItems*(self: ptr IFileOpenDialog, ppsai: ptr ptr IShellItemArray): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetSelectedItems(self, ppsai)
proc IncludeItem*(self: ptr IShellItemFilter, psi: ptr IShellItem): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.IncludeItem(self, psi)
proc GetEnumFlagsForItem*(self: ptr IShellItemFilter, psi: ptr IShellItem, pgrfFlags: ptr SHCONTF): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetEnumFlagsForItem(self, psi, pgrfFlags)
proc Append*(self: ptr IObjMgr, punk: ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Append(self, punk)
proc Remove*(self: ptr IObjMgr, punk: ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Remove(self, punk)
proc Expand*(self: ptr IACList, pszExpand: PCWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.Expand(self, pszExpand)
proc SetOptions*(self: ptr IACList2, dwFlag: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.SetOptions(self, dwFlag)
proc GetOptions*(self: ptr IACList2, pdwFlag: ptr DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetOptions(self, pdwFlag)
converter winimConverterIAutoCompleteToIUnknown*(x: ptr IAutoComplete): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIAutoComplete2ToIAutoComplete*(x: ptr IAutoComplete2): ptr IAutoComplete = cast[ptr IAutoComplete](x)
converter winimConverterIAutoComplete2ToIUnknown*(x: ptr IAutoComplete2): ptr IUnknown = cast[ptr IUnknown](x)
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
converter winimConverterIObjMgrToIUnknown*(x: ptr IObjMgr): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIACListToIUnknown*(x: ptr IACList): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIACList2ToIACList*(x: ptr IACList2): ptr IACList = cast[ptr IACList](x)
converter winimConverterIACList2ToIUnknown*(x: ptr IACList2): ptr IUnknown = cast[ptr IUnknown](x)
when winimUnicode:
  type
    NOTIFYICONDATA* = NOTIFYICONDATAW
    BROWSEINFO* = BROWSEINFOW
  const
    BFFM_SETSELECTION* = BFFM_SETSELECTIONW
  proc DragQueryFile*(hDrop: HDROP, iFile: UINT, lpszFile: LPWSTR, cch: UINT): UINT {.winapi, stdcall, dynlib: "shell32", importc: "DragQueryFileW".}
  proc ShellExecute*(hwnd: HWND, lpOperation: LPCWSTR, lpFile: LPCWSTR, lpParameters: LPCWSTR, lpDirectory: LPCWSTR, nShowCmd: INT): HINSTANCE {.winapi, stdcall, dynlib: "shell32", importc: "ShellExecuteW".}
  proc ExtractIconEx*(lpszFile: LPCWSTR, nIconIndex: int32, phiconLarge: ptr HICON, phiconSmall: ptr HICON, nIcons: UINT): UINT {.winapi, stdcall, dynlib: "shell32", importc: "ExtractIconExW".}
  proc Shell_NotifyIcon*(dwMessage: DWORD, lpData: PNOTIFYICONDATAW): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "Shell_NotifyIconW".}
  proc PathFileExists*(pszPath: LPCWSTR): WINBOOL {.winapi, stdcall, dynlib: "shlwapi", importc: "PathFileExistsW".}
  proc PathCompactPath*(hDC: HDC, pszPath: LPWSTR, dx: UINT): WINBOOL {.winapi, stdcall, dynlib: "shlwapi", importc: "PathCompactPathW".}
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
  proc ShellExecute*(hwnd: HWND, lpOperation: LPCSTR, lpFile: LPCSTR, lpParameters: LPCSTR, lpDirectory: LPCSTR, nShowCmd: INT): HINSTANCE {.winapi, stdcall, dynlib: "shell32", importc: "ShellExecuteA".}
  proc ExtractIconEx*(lpszFile: LPCSTR, nIconIndex: int32, phiconLarge: ptr HICON, phiconSmall: ptr HICON, nIcons: UINT): UINT {.winapi, stdcall, dynlib: "shell32", importc: "ExtractIconExA".}
  proc Shell_NotifyIcon*(dwMessage: DWORD, lpData: PNOTIFYICONDATAA): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "Shell_NotifyIconA".}
  proc PathFileExists*(pszPath: LPCSTR): WINBOOL {.winapi, stdcall, dynlib: "shlwapi", importc: "PathFileExistsA".}
  proc PathCompactPath*(hDC: HDC, pszPath: LPSTR, dx: UINT): WINBOOL {.winapi, stdcall, dynlib: "shlwapi", importc: "PathCompactPathA".}
  proc ILCreateFromPath*(pszPath: PCSTR): PIDLIST_ABSOLUTE {.winapi, stdcall, dynlib: "shell32", importc: "ILCreateFromPathA".}
  proc SHGetPathFromIDList*(pidl: PCIDLIST_ABSOLUTE, pszPath: LPSTR): WINBOOL {.winapi, stdcall, dynlib: "shell32", importc: "SHGetPathFromIDListA".}
  proc SHBrowseForFolder*(lpbi: LPBROWSEINFOA): PIDLIST_ABSOLUTE {.winapi, stdcall, dynlib: "shell32", importc: "SHBrowseForFolderA".}
const
  IID_IHTMLTxtRange* = DEFINE_GUID("3050f220-98b5-11cf-bb82-00aa00bdce0b")
  IID_IHTMLDocument2* = DEFINE_GUID("332c4425-26cb-11d0-b483-00c04fd90119")
  DOCHOSTUIFLAG_DIALOG* = 0x1
  DOCHOSTUIFLAG_SCROLL_NO* = 0x8
  DOCHOSTUIFLAG_THEME* = 0x40000
  DOCHOSTUIFLAG_NO3DOUTERBORDER* = 0x200000
  IID_IDocHostUIHandler* = DEFINE_GUID("bd3f23c0-d43e-11cf-893b-00aa00bdce1a")
type
  IHTMLFramesCollection2* {.pure.} = object
    lpVtbl*: ptr IHTMLFramesCollection2Vtbl
  IHTMLFramesCollection2Vtbl* {.pure, inheritable.} = object of IDispatchVtbl
    item*: proc(self: ptr IHTMLFramesCollection2, pvarIndex: ptr VARIANT, pvarResult: ptr VARIANT): HRESULT {.stdcall.}
    get_length*: proc(self: ptr IHTMLFramesCollection2, p: ptr LONG): HRESULT {.stdcall.}
  IHTMLImgElement* {.pure.} = object
    lpVtbl*: ptr IHTMLImgElementVtbl
  IHTMLImgElementVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_isMap*: proc(self: ptr IHTMLImgElement, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_isMap*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_useMap*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_useMap*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_mimeType*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileSize*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileCreatedDate*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileModifiedDate*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileUpdatedDate*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_protocol*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_href*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_nameProp*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_border*: proc(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.stdcall.}
    get_border*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_vspace*: proc(self: ptr IHTMLImgElement, v: LONG): HRESULT {.stdcall.}
    get_vspace*: proc(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.stdcall.}
    put_hspace*: proc(self: ptr IHTMLImgElement, v: LONG): HRESULT {.stdcall.}
    get_hspace*: proc(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.stdcall.}
    put_alt*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_alt*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_src*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_src*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_lowsrc*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_lowsrc*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_vrml*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_vrml*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_dynsrc*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_dynsrc*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_readyState*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_complete*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_loop*: proc(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.stdcall.}
    get_loop*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_align*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_align*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_onload*: proc(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.stdcall.}
    get_onload*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onerror*: proc(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.stdcall.}
    get_onerror*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onabort*: proc(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.stdcall.}
    get_onabort*: proc(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_name*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_name*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_width*: proc(self: ptr IHTMLImgElement, v: LONG): HRESULT {.stdcall.}
    get_width*: proc(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.stdcall.}
    put_height*: proc(self: ptr IHTMLImgElement, v: LONG): HRESULT {.stdcall.}
    get_height*: proc(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.stdcall.}
    put_start*: proc(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.stdcall.}
    get_start*: proc(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.stdcall.}
  IHTMLImageElementFactory* {.pure.} = object
    lpVtbl*: ptr IHTMLImageElementFactoryVtbl
  IHTMLImageElementFactoryVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    create*: proc(self: ptr IHTMLImageElementFactory, width: VARIANT, height: VARIANT, a: ptr ptr IHTMLImgElement): HRESULT {.stdcall.}
  IHTMLLocation* {.pure.} = object
    lpVtbl*: ptr IHTMLLocationVtbl
  IHTMLLocationVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_href*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_href*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_protocol*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_protocol*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_host*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_host*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_hostname*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_hostname*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_port*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_port*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_pathname*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_pathname*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_search*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_search*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    put_hash*: proc(self: ptr IHTMLLocation, v: BSTR): HRESULT {.stdcall.}
    get_hash*: proc(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.stdcall.}
    reload*: proc(self: ptr IHTMLLocation, flag: VARIANT_BOOL): HRESULT {.stdcall.}
    replace*: proc(self: ptr IHTMLLocation, bstr: BSTR): HRESULT {.stdcall.}
    assign*: proc(self: ptr IHTMLLocation, bstr: BSTR): HRESULT {.stdcall.}
    toString*: proc(self: ptr IHTMLLocation, string: ptr BSTR): HRESULT {.stdcall.}
  IOmHistory* {.pure.} = object
    lpVtbl*: ptr IOmHistoryVtbl
  IOmHistoryVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_length*: proc(self: ptr IOmHistory, p: ptr int16): HRESULT {.stdcall.}
    back*: proc(self: ptr IOmHistory, pvargdistance: ptr VARIANT): HRESULT {.stdcall.}
    forward*: proc(self: ptr IOmHistory, pvargdistance: ptr VARIANT): HRESULT {.stdcall.}
    go*: proc(self: ptr IOmHistory, pvargdistance: ptr VARIANT): HRESULT {.stdcall.}
  IHTMLMimeTypesCollection* {.pure.} = object
    lpVtbl*: ptr IHTMLMimeTypesCollectionVtbl
  IHTMLMimeTypesCollectionVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_length*: proc(self: ptr IHTMLMimeTypesCollection, p: ptr LONG): HRESULT {.stdcall.}
  IHTMLPluginsCollection* {.pure.} = object
    lpVtbl*: ptr IHTMLPluginsCollectionVtbl
  IHTMLPluginsCollectionVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_length*: proc(self: ptr IHTMLPluginsCollection, p: ptr LONG): HRESULT {.stdcall.}
    refresh*: proc(self: ptr IHTMLPluginsCollection, reload: VARIANT_BOOL): HRESULT {.stdcall.}
  IHTMLOpsProfile* {.pure.} = object
    lpVtbl*: ptr IHTMLOpsProfileVtbl
  IHTMLOpsProfileVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    addRequest*: proc(self: ptr IHTMLOpsProfile, name: BSTR, reserved: VARIANT, success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    clearRequest*: proc(self: ptr IHTMLOpsProfile): HRESULT {.stdcall.}
    doRequest*: proc(self: ptr IHTMLOpsProfile, usage: VARIANT, fname: VARIANT, domain: VARIANT, path: VARIANT, expire: VARIANT, reserved: VARIANT): HRESULT {.stdcall.}
    getAttribute*: proc(self: ptr IHTMLOpsProfile, name: BSTR, value: ptr BSTR): HRESULT {.stdcall.}
    setAttribute*: proc(self: ptr IHTMLOpsProfile, name: BSTR, value: BSTR, prefs: VARIANT, success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    commitChanges*: proc(self: ptr IHTMLOpsProfile, success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    addReadRequest*: proc(self: ptr IHTMLOpsProfile, name: BSTR, reserved: VARIANT, success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    doReadRequest*: proc(self: ptr IHTMLOpsProfile, usage: VARIANT, fname: VARIANT, domain: VARIANT, path: VARIANT, expire: VARIANT, reserved: VARIANT): HRESULT {.stdcall.}
    doWriteRequest*: proc(self: ptr IHTMLOpsProfile, success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
  IOmNavigator* {.pure.} = object
    lpVtbl*: ptr IOmNavigatorVtbl
  IOmNavigatorVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_appCodeName*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_appName*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_appVersion*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_userAgent*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    javaEnabled*: proc(self: ptr IOmNavigator, enabled: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    taintEnabled*: proc(self: ptr IOmNavigator, enabled: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_mimeTypes*: proc(self: ptr IOmNavigator, p: ptr ptr IHTMLMimeTypesCollection): HRESULT {.stdcall.}
    get_plugins*: proc(self: ptr IOmNavigator, p: ptr ptr IHTMLPluginsCollection): HRESULT {.stdcall.}
    get_cookieEnabled*: proc(self: ptr IOmNavigator, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_opsProfile*: proc(self: ptr IOmNavigator, p: ptr ptr IHTMLOpsProfile): HRESULT {.stdcall.}
    toString*: proc(self: ptr IOmNavigator, string: ptr BSTR): HRESULT {.stdcall.}
    get_cpuClass*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_systemLanguage*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_browserLanguage*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_userLanguage*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_platform*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_appMinorVersion*: proc(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.stdcall.}
    get_connectionSpeed*: proc(self: ptr IOmNavigator, p: ptr LONG): HRESULT {.stdcall.}
    get_onLine*: proc(self: ptr IOmNavigator, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_userProfile*: proc(self: ptr IOmNavigator, p: ptr ptr IHTMLOpsProfile): HRESULT {.stdcall.}
  IHTMLDocument* {.pure.} = object
    lpVtbl*: ptr IHTMLDocumentVtbl
  IHTMLDocumentVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_Script*: proc(self: ptr IHTMLDocument, p: ptr ptr IDispatch): HRESULT {.stdcall.}
  IHTMLElementCollection* {.pure.} = object
    lpVtbl*: ptr IHTMLElementCollectionVtbl
  IHTMLElementCollectionVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    toString*: proc(self: ptr IHTMLElementCollection, String: ptr BSTR): HRESULT {.stdcall.}
    put_length*: proc(self: ptr IHTMLElementCollection, v: LONG): HRESULT {.stdcall.}
    get_length*: proc(self: ptr IHTMLElementCollection, p: ptr LONG): HRESULT {.stdcall.}
    get_newEnum*: proc(self: ptr IHTMLElementCollection, p: ptr ptr IUnknown): HRESULT {.stdcall.}
    item*: proc(self: ptr IHTMLElementCollection, name: VARIANT, index: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.stdcall.}
    tags*: proc(self: ptr IHTMLElementCollection, tagName: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.stdcall.}
  IHTMLStyle* {.pure.} = object
    lpVtbl*: ptr IHTMLStyleVtbl
  IHTMLStyleVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_fontFamily*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontFamily*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontVariant*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontVariant*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontWeight*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontWeight*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontSize*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_fontSize*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_font*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_font*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_color*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_color*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_background*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_background*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundColor*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_backgroundColor*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_backgroundImage*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundImage*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundRepeat*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundRepeat*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundAttachment*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundAttachment*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundPosition*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundPosition*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundPositionX*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_backgroundPositionX*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_backgroundPositionY*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_backgroundPositionY*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_wordSpacing*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_wordSpacing*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_letterSpacing*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_letterSpacing*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_textDecoration*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_textDecoration*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_textDecorationNone*: proc(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationNone*: proc(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationUnderline*: proc(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationUnderline*: proc(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationOverline*: proc(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationOverline*: proc(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationLineThrough*: proc(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationLineThrough*: proc(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationBlink*: proc(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationBlink*: proc(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_verticalAlign*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_verticalAlign*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_textTransform*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_textTransform*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_textAlign*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_textAlign*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_textIndent*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_textIndent*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_lineHeight*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_lineHeight*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginTop*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginTop*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginRight*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginRight*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginBottom*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginBottom*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginLeft*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginLeft*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_margin*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_margin*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_paddingTop*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingTop*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_paddingRight*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingRight*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_paddingBottom*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingBottom*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_paddingLeft*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingLeft*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_padding*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_padding*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_border*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_border*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTop*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderTop*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderRight*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderRight*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderBottom*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderBottom*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderLeft*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderLeft*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderColor*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderColor*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTopColor*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderTopColor*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderRightColor*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderRightColor*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderBottomColor*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderBottomColor*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderLeftColor*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderLeftColor*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderWidth*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderWidth*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTopWidth*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderTopWidth*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderRightWidth*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderRightWidth*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderBottomWidth*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderBottomWidth*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderLeftWidth*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderLeftWidth*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTopStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderTopStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderRightStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderRightStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderBottomStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderBottomStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderLeftStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderLeftStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_width*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_width*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_height*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_height*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_styleFloat*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_styleFloat*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_clear*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_clear*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_display*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_display*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_visibility*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_visibility*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStyleType*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStyleType*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStylePosition*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStylePosition*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStyleImage*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStyleImage*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStyle*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStyle*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_whiteSpace*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_whiteSpace*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_top*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_top*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_left*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_left*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    get_position*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_zIndex*: proc(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.stdcall.}
    get_zIndex*: proc(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_overflow*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_overflow*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_pageBreakBefore*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_pageBreakBefore*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_pageBreakAfter*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_pageBreakAfter*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_cssText*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_cssText*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_pixelTop*: proc(self: ptr IHTMLStyle, v: LONG): HRESULT {.stdcall.}
    get_pixelTop*: proc(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.stdcall.}
    put_pixelLeft*: proc(self: ptr IHTMLStyle, v: LONG): HRESULT {.stdcall.}
    get_pixelLeft*: proc(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.stdcall.}
    put_pixelWidth*: proc(self: ptr IHTMLStyle, v: LONG): HRESULT {.stdcall.}
    get_pixelWidth*: proc(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.stdcall.}
    put_pixelHeight*: proc(self: ptr IHTMLStyle, v: LONG): HRESULT {.stdcall.}
    get_pixelHeight*: proc(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.stdcall.}
    put_posTop*: proc(self: ptr IHTMLStyle, v: float32): HRESULT {.stdcall.}
    get_posTop*: proc(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.stdcall.}
    put_posLeft*: proc(self: ptr IHTMLStyle, v: float32): HRESULT {.stdcall.}
    get_posLeft*: proc(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.stdcall.}
    put_posWidth*: proc(self: ptr IHTMLStyle, v: float32): HRESULT {.stdcall.}
    get_posWidth*: proc(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.stdcall.}
    put_posHeight*: proc(self: ptr IHTMLStyle, v: float32): HRESULT {.stdcall.}
    get_posHeight*: proc(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.stdcall.}
    put_cursor*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_cursor*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_clip*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_clip*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_filter*: proc(self: ptr IHTMLStyle, v: BSTR): HRESULT {.stdcall.}
    get_filter*: proc(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.stdcall.}
    setAttribute*: proc(self: ptr IHTMLStyle, strAttributeName: BSTR, AttributeValue: VARIANT, lFlags: LONG): HRESULT {.stdcall.}
    getAttribute*: proc(self: ptr IHTMLStyle, strAttributeName: BSTR, lFlags: LONG, AttributeValue: ptr VARIANT): HRESULT {.stdcall.}
    removeAttribute*: proc(self: ptr IHTMLStyle, strAttributeName: BSTR, lFlags: LONG, pfSuccess: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    toString*: proc(self: ptr IHTMLStyle, String: ptr BSTR): HRESULT {.stdcall.}
  IHTMLFiltersCollection* {.pure.} = object
    lpVtbl*: ptr IHTMLFiltersCollectionVtbl
  IHTMLFiltersCollectionVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_length*: proc(self: ptr IHTMLFiltersCollection, p: ptr LONG): HRESULT {.stdcall.}
    get_newEnum*: proc(self: ptr IHTMLFiltersCollection, p: ptr ptr IUnknown): HRESULT {.stdcall.}
    item*: proc(self: ptr IHTMLFiltersCollection, pvarIndex: ptr VARIANT, pvarResult: ptr VARIANT): HRESULT {.stdcall.}
  IHTMLElement* {.pure.} = object
    lpVtbl*: ptr IHTMLElementVtbl
  IHTMLElementVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    setAttribute*: proc(self: ptr IHTMLElement, strAttributeName: BSTR, AttributeValue: VARIANT, lFlags: LONG): HRESULT {.stdcall.}
    getAttribute*: proc(self: ptr IHTMLElement, strAttributeName: BSTR, lFlags: LONG, AttributeValue: ptr VARIANT): HRESULT {.stdcall.}
    removeAttribute*: proc(self: ptr IHTMLElement, strAttributeName: BSTR, lFlags: LONG, pfSuccess: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_className*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_className*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_id*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_id*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_tagName*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_parentElement*: proc(self: ptr IHTMLElement, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_style*: proc(self: ptr IHTMLElement, p: ptr ptr IHTMLStyle): HRESULT {.stdcall.}
    put_onhelp*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onhelp*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onclick*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onclick*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_ondblclick*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_ondblclick*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onkeydown*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onkeydown*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onkeyup*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onkeyup*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onkeypress*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onkeypress*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmouseout*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onmouseout*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmouseover*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onmouseover*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmousemove*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onmousemove*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmousedown*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onmousedown*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmouseup*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onmouseup*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    get_document*: proc(self: ptr IHTMLElement, p: ptr ptr IDispatch): HRESULT {.stdcall.}
    put_title*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_title*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_language*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_language*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_onselectstart*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onselectstart*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    scrollIntoView*: proc(self: ptr IHTMLElement, varargStart: VARIANT): HRESULT {.stdcall.}
    contains*: proc(self: ptr IHTMLElement, pChild: ptr IHTMLElement, pfResult: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_sourceIndex*: proc(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.stdcall.}
    get_recordNumber*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_lang*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_lang*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_offsetLeft*: proc(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.stdcall.}
    get_offsetTop*: proc(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.stdcall.}
    get_offsetWidth*: proc(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.stdcall.}
    get_offsetHeight*: proc(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.stdcall.}
    get_offsetParent*: proc(self: ptr IHTMLElement, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    put_innerHTML*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_innerHTML*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_innerText*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_innerText*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_outerHTML*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_outerHTML*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_outerText*: proc(self: ptr IHTMLElement, v: BSTR): HRESULT {.stdcall.}
    get_outerText*: proc(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.stdcall.}
    insertAdjacentHTML*: proc(self: ptr IHTMLElement, where: BSTR, html: BSTR): HRESULT {.stdcall.}
    insertAdjacentText*: proc(self: ptr IHTMLElement, where: BSTR, text: BSTR): HRESULT {.stdcall.}
    get_parentTextEdit*: proc(self: ptr IHTMLElement, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_isTextEdit*: proc(self: ptr IHTMLElement, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    click*: proc(self: ptr IHTMLElement): HRESULT {.stdcall.}
    get_filters*: proc(self: ptr IHTMLElement, p: ptr ptr IHTMLFiltersCollection): HRESULT {.stdcall.}
    put_ondragstart*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_ondragstart*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    toString*: proc(self: ptr IHTMLElement, String: ptr BSTR): HRESULT {.stdcall.}
    put_onbeforeupdate*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onbeforeupdate*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onafterupdate*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onafterupdate*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onerrorupdate*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onerrorupdate*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onrowexit*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onrowexit*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onrowenter*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onrowenter*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_ondatasetchanged*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_ondatasetchanged*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_ondataavailable*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_ondataavailable*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_ondatasetcomplete*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_ondatasetcomplete*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onfilterchange*: proc(self: ptr IHTMLElement, v: VARIANT): HRESULT {.stdcall.}
    get_onfilterchange*: proc(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.stdcall.}
    get_children*: proc(self: ptr IHTMLElement, p: ptr ptr IDispatch): HRESULT {.stdcall.}
    get_all*: proc(self: ptr IHTMLElement, p: ptr ptr IDispatch): HRESULT {.stdcall.}
  IHTMLSelectionObject* {.pure.} = object
    lpVtbl*: ptr IHTMLSelectionObjectVtbl
  IHTMLSelectionObjectVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    createRange*: proc(self: ptr IHTMLSelectionObject, range: ptr ptr IDispatch): HRESULT {.stdcall.}
    empty*: proc(self: ptr IHTMLSelectionObject): HRESULT {.stdcall.}
    clear*: proc(self: ptr IHTMLSelectionObject): HRESULT {.stdcall.}
    get_type*: proc(self: ptr IHTMLSelectionObject, p: ptr BSTR): HRESULT {.stdcall.}
  IHTMLStyleSheetsCollection* {.pure.} = object
    lpVtbl*: ptr IHTMLStyleSheetsCollectionVtbl
  IHTMLStyleSheetsCollectionVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_length*: proc(self: ptr IHTMLStyleSheetsCollection, p: ptr LONG): HRESULT {.stdcall.}
    get_newEnum*: proc(self: ptr IHTMLStyleSheetsCollection, p: ptr ptr IUnknown): HRESULT {.stdcall.}
    item*: proc(self: ptr IHTMLStyleSheetsCollection, pvarIndex: ptr VARIANT, pvarResult: ptr VARIANT): HRESULT {.stdcall.}
  IHTMLRuleStyle* {.pure.} = object
    lpVtbl*: ptr IHTMLRuleStyleVtbl
  IHTMLRuleStyleVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_fontFamily*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontFamily*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontVariant*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontVariant*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontWeight*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_fontWeight*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_fontSize*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_fontSize*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_font*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_font*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_color*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_color*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_background*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_background*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundColor*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_backgroundColor*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_backgroundImage*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundImage*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundRepeat*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundRepeat*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundAttachment*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundAttachment*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundPosition*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_backgroundPosition*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_backgroundPositionX*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_backgroundPositionX*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_backgroundPositionY*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_backgroundPositionY*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_wordSpacing*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_wordSpacing*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_letterSpacing*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_letterSpacing*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_textDecoration*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_textDecoration*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_textDecorationNone*: proc(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationNone*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationUnderline*: proc(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationUnderline*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationOverline*: proc(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationOverline*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationLineThrough*: proc(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationLineThrough*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_textDecorationBlink*: proc(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_textDecorationBlink*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_verticalAlign*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_verticalAlign*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_textTransform*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_textTransform*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_textAlign*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_textAlign*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_textIndent*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_textIndent*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_lineHeight*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_lineHeight*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginTop*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginTop*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginRight*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginRight*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginBottom*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginBottom*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_marginLeft*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_marginLeft*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_margin*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_margin*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_paddingTop*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingTop*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_paddingRight*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingRight*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_paddingBottom*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingBottom*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_paddingLeft*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_paddingLeft*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_padding*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_padding*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_border*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_border*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTop*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderTop*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderRight*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderRight*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderBottom*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderBottom*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderLeft*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderLeft*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderColor*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderColor*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTopColor*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderTopColor*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderRightColor*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderRightColor*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderBottomColor*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderBottomColor*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderLeftColor*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderLeftColor*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderWidth*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderWidth*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTopWidth*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderTopWidth*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderRightWidth*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderRightWidth*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderBottomWidth*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderBottomWidth*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderLeftWidth*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_borderLeftWidth*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_borderStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderTopStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderTopStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderRightStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderRightStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderBottomStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderBottomStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_borderLeftStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_borderLeftStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_width*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_width*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_height*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_height*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_styleFloat*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_styleFloat*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_clear*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_clear*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_display*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_display*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_visibility*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_visibility*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStyleType*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStyleType*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStylePosition*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStylePosition*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStyleImage*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStyleImage*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_listStyle*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_listStyle*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_whiteSpace*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_whiteSpace*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_top*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_top*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_left*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_left*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    get_position*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_zIndex*: proc(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.stdcall.}
    get_zIndex*: proc(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.stdcall.}
    put_overflow*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_overflow*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_pageBreakBefore*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_pageBreakBefore*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_pageBreakAfter*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_pageBreakAfter*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_cssText*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_cssText*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_cursor*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_cursor*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_clip*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_clip*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    put_filter*: proc(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.stdcall.}
    get_filter*: proc(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.stdcall.}
    setAttribute*: proc(self: ptr IHTMLRuleStyle, strAttributeName: BSTR, AttributeValue: VARIANT, lFlags: LONG): HRESULT {.stdcall.}
    getAttribute*: proc(self: ptr IHTMLRuleStyle, strAttributeName: BSTR, lFlags: LONG, AttributeValue: ptr VARIANT): HRESULT {.stdcall.}
    removeAttribute*: proc(self: ptr IHTMLRuleStyle, strAttributeName: BSTR, lFlags: LONG, pfSuccess: ptr VARIANT_BOOL): HRESULT {.stdcall.}
  IHTMLStyleSheetRule* {.pure.} = object
    lpVtbl*: ptr IHTMLStyleSheetRuleVtbl
  IHTMLStyleSheetRuleVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_selectorText*: proc(self: ptr IHTMLStyleSheetRule, v: BSTR): HRESULT {.stdcall.}
    get_selectorText*: proc(self: ptr IHTMLStyleSheetRule, p: ptr BSTR): HRESULT {.stdcall.}
    get_style*: proc(self: ptr IHTMLStyleSheetRule, p: ptr ptr IHTMLRuleStyle): HRESULT {.stdcall.}
    get_readOnly*: proc(self: ptr IHTMLStyleSheetRule, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
  IHTMLStyleSheetRulesCollection* {.pure.} = object
    lpVtbl*: ptr IHTMLStyleSheetRulesCollectionVtbl
  IHTMLStyleSheetRulesCollectionVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_length*: proc(self: ptr IHTMLStyleSheetRulesCollection, p: ptr LONG): HRESULT {.stdcall.}
    item*: proc(self: ptr IHTMLStyleSheetRulesCollection, index: LONG, ppHTMLStyleSheetRule: ptr ptr IHTMLStyleSheetRule): HRESULT {.stdcall.}
  IHTMLStyleSheet* {.pure.} = object
    lpVtbl*: ptr IHTMLStyleSheetVtbl
  IHTMLStyleSheetVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_title*: proc(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.stdcall.}
    get_title*: proc(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.stdcall.}
    get_parentStyleSheet*: proc(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLStyleSheet): HRESULT {.stdcall.}
    get_owningElement*: proc(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    put_disabled*: proc(self: ptr IHTMLStyleSheet, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_disabled*: proc(self: ptr IHTMLStyleSheet, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_readOnly*: proc(self: ptr IHTMLStyleSheet, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_imports*: proc(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLStyleSheetsCollection): HRESULT {.stdcall.}
    put_href*: proc(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.stdcall.}
    get_href*: proc(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.stdcall.}
    get_type*: proc(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.stdcall.}
    get_id*: proc(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.stdcall.}
    addImport*: proc(self: ptr IHTMLStyleSheet, bstrURL: BSTR, lIndex: LONG, plIndex: ptr LONG): HRESULT {.stdcall.}
    addRule*: proc(self: ptr IHTMLStyleSheet, bstrSelector: BSTR, bstrStyle: BSTR, lIndex: LONG, plNewIndex: ptr LONG): HRESULT {.stdcall.}
    removeImport*: proc(self: ptr IHTMLStyleSheet, lIndex: LONG): HRESULT {.stdcall.}
    removeRule*: proc(self: ptr IHTMLStyleSheet, lIndex: LONG): HRESULT {.stdcall.}
    put_media*: proc(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.stdcall.}
    get_media*: proc(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.stdcall.}
    put_cssText*: proc(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.stdcall.}
    get_cssText*: proc(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.stdcall.}
    get_rules*: proc(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLStyleSheetRulesCollection): HRESULT {.stdcall.}
  IHTMLDocument2* {.pure.} = object
    lpVtbl*: ptr IHTMLDocument2Vtbl
  IHTMLDocument2Vtbl* {.pure, inheritable.} = object of IHTMLDocumentVtbl
    get_all*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    get_body*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_activeElement*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_images*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    get_applets*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    get_links*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    get_forms*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    get_anchors*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    put_title*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_title*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_scripts*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    put_designMode*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_designMode*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_selection*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLSelectionObject): HRESULT {.stdcall.}
    get_readyState*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_frames*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLFramesCollection2): HRESULT {.stdcall.}
    get_embeds*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    get_plugins*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.stdcall.}
    put_alinkColor*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_alinkColor*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_bgColor*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_bgColor*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_fgColor*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_fgColor*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_linkColor*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_linkColor*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_vlinkColor*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_vlinkColor*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    get_referrer*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_location*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLLocation): HRESULT {.stdcall.}
    get_lastModified*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    put_URL*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_URL*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    put_domain*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_domain*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    put_cookie*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_cookie*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    put_expando*: proc(self: ptr IHTMLDocument2, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_expando*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_charset*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_charset*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    put_defaultCharset*: proc(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.stdcall.}
    get_defaultCharset*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_mimeType*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileSize*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileCreatedDate*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileModifiedDate*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_fileUpdatedDate*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_security*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_protocol*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    get_nameProp*: proc(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.stdcall.}
    write*: proc(self: ptr IHTMLDocument2, psarray: ptr SAFEARRAY): HRESULT {.stdcall.}
    writeln*: proc(self: ptr IHTMLDocument2, psarray: ptr SAFEARRAY): HRESULT {.stdcall.}
    open*: proc(self: ptr IHTMLDocument2, url: BSTR, name: VARIANT, features: VARIANT, replace: VARIANT, pomWindowResult: ptr ptr IDispatch): HRESULT {.stdcall.}
    close*: proc(self: ptr IHTMLDocument2): HRESULT {.stdcall.}
    clear*: proc(self: ptr IHTMLDocument2): HRESULT {.stdcall.}
    queryCommandSupported*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandEnabled*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandState*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandIndeterm*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandText*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pcmdText: ptr BSTR): HRESULT {.stdcall.}
    queryCommandValue*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pcmdValue: ptr VARIANT): HRESULT {.stdcall.}
    execCommand*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, showUI: VARIANT_BOOL, value: VARIANT, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    execCommandShowHelp*: proc(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    createElement*: proc(self: ptr IHTMLDocument2, eTag: BSTR, newElem: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    put_onhelp*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onhelp*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onclick*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onclick*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_ondblclick*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_ondblclick*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onkeyup*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onkeyup*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onkeydown*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onkeydown*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onkeypress*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onkeypress*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmouseup*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onmouseup*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmousedown*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onmousedown*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmousemove*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onmousemove*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmouseout*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onmouseout*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onmouseover*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onmouseover*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onreadystatechange*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onreadystatechange*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onafterupdate*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onafterupdate*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onrowexit*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onrowexit*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onrowenter*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onrowenter*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_ondragstart*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_ondragstart*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onselectstart*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onselectstart*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    elementFromPoint*: proc(self: ptr IHTMLDocument2, x: LONG, y: LONG, elementHit: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_parentWindow*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLWindow2): HRESULT {.stdcall.}
    get_styleSheets*: proc(self: ptr IHTMLDocument2, p: ptr ptr IHTMLStyleSheetsCollection): HRESULT {.stdcall.}
    put_onbeforeupdate*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onbeforeupdate*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onerrorupdate*: proc(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.stdcall.}
    get_onerrorupdate*: proc(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.stdcall.}
    toString*: proc(self: ptr IHTMLDocument2, String: ptr BSTR): HRESULT {.stdcall.}
    createStyleSheet*: proc(self: ptr IHTMLDocument2, bstrHref: BSTR, lIndex: LONG, ppnewStyleSheet: ptr ptr IHTMLStyleSheet): HRESULT {.stdcall.}
  IHTMLEventObj* {.pure.} = object
    lpVtbl*: ptr IHTMLEventObjVtbl
  IHTMLEventObjVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_srcElement*: proc(self: ptr IHTMLEventObj, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_altKey*: proc(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_ctrlKey*: proc(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_shiftKey*: proc(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_returnValue*: proc(self: ptr IHTMLEventObj, v: VARIANT): HRESULT {.stdcall.}
    get_returnValue*: proc(self: ptr IHTMLEventObj, p: ptr VARIANT): HRESULT {.stdcall.}
    put_cancelBubble*: proc(self: ptr IHTMLEventObj, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_cancelBubble*: proc(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    get_fromElement*: proc(self: ptr IHTMLEventObj, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    get_toElement*: proc(self: ptr IHTMLEventObj, p: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    put_keyCode*: proc(self: ptr IHTMLEventObj, v: LONG): HRESULT {.stdcall.}
    get_keyCode*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_button*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_type*: proc(self: ptr IHTMLEventObj, p: ptr BSTR): HRESULT {.stdcall.}
    get_qualifier*: proc(self: ptr IHTMLEventObj, p: ptr BSTR): HRESULT {.stdcall.}
    get_reason*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_x*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_y*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_clientX*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_clientY*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_offsetX*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_offsetY*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_screenX*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_screenY*: proc(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.stdcall.}
    get_srcFilter*: proc(self: ptr IHTMLEventObj, p: ptr ptr IDispatch): HRESULT {.stdcall.}
  IHTMLScreen* {.pure.} = object
    lpVtbl*: ptr IHTMLScreenVtbl
  IHTMLScreenVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_colorDepth*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    put_bufferDepth*: proc(self: ptr IHTMLScreen, v: LONG): HRESULT {.stdcall.}
    get_bufferDepth*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    get_width*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    get_height*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    put_updateInterval*: proc(self: ptr IHTMLScreen, v: LONG): HRESULT {.stdcall.}
    get_updateInterval*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    get_availHeight*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    get_availWidth*: proc(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.stdcall.}
    get_fontSmoothingEnabled*: proc(self: ptr IHTMLScreen, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
  IHTMLFormElement* {.pure.} = object
    lpVtbl*: ptr IHTMLFormElementVtbl
  IHTMLFormElementVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_action*: proc(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.stdcall.}
    get_action*: proc(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_dir*: proc(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.stdcall.}
    get_dir*: proc(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_encoding*: proc(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.stdcall.}
    get_encoding*: proc(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_method*: proc(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.stdcall.}
    get_method*: proc(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_elements*: proc(self: ptr IHTMLFormElement, p: ptr ptr IDispatch): HRESULT {.stdcall.}
    put_target*: proc(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.stdcall.}
    get_target*: proc(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_name*: proc(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.stdcall.}
    get_name*: proc(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_onsubmit*: proc(self: ptr IHTMLFormElement, v: VARIANT): HRESULT {.stdcall.}
    get_onsubmit*: proc(self: ptr IHTMLFormElement, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onreset*: proc(self: ptr IHTMLFormElement, v: VARIANT): HRESULT {.stdcall.}
    get_onreset*: proc(self: ptr IHTMLFormElement, p: ptr VARIANT): HRESULT {.stdcall.}
    submit*: proc(self: ptr IHTMLFormElement): HRESULT {.stdcall.}
    reset*: proc(self: ptr IHTMLFormElement): HRESULT {.stdcall.}
    put_length*: proc(self: ptr IHTMLFormElement, v: LONG): HRESULT {.stdcall.}
    get_length*: proc(self: ptr IHTMLFormElement, p: ptr LONG): HRESULT {.stdcall.}
    get_newEnum*: proc(self: ptr IHTMLFormElement, p: ptr ptr IUnknown): HRESULT {.stdcall.}
    item*: proc(self: ptr IHTMLFormElement, name: VARIANT, index: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.stdcall.}
    tags*: proc(self: ptr IHTMLFormElement, tagName: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.stdcall.}
  IHTMLOptionElement* {.pure.} = object
    lpVtbl*: ptr IHTMLOptionElementVtbl
  IHTMLOptionElementVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    put_selected*: proc(self: ptr IHTMLOptionElement, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_selected*: proc(self: ptr IHTMLOptionElement, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_value*: proc(self: ptr IHTMLOptionElement, v: BSTR): HRESULT {.stdcall.}
    get_value*: proc(self: ptr IHTMLOptionElement, p: ptr BSTR): HRESULT {.stdcall.}
    put_defaultSelected*: proc(self: ptr IHTMLOptionElement, v: VARIANT_BOOL): HRESULT {.stdcall.}
    get_defaultSelected*: proc(self: ptr IHTMLOptionElement, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    put_index*: proc(self: ptr IHTMLOptionElement, v: LONG): HRESULT {.stdcall.}
    get_index*: proc(self: ptr IHTMLOptionElement, p: ptr LONG): HRESULT {.stdcall.}
    put_text*: proc(self: ptr IHTMLOptionElement, v: BSTR): HRESULT {.stdcall.}
    get_text*: proc(self: ptr IHTMLOptionElement, p: ptr BSTR): HRESULT {.stdcall.}
    get_form*: proc(self: ptr IHTMLOptionElement, p: ptr ptr IHTMLFormElement): HRESULT {.stdcall.}
  IHTMLOptionElementFactory* {.pure.} = object
    lpVtbl*: ptr IHTMLOptionElementFactoryVtbl
  IHTMLOptionElementFactoryVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    create*: proc(self: ptr IHTMLOptionElementFactory, text: VARIANT, value: VARIANT, defaultselected: VARIANT, selected: VARIANT, a: ptr ptr IHTMLOptionElement): HRESULT {.stdcall.}
  IHTMLWindow2* {.pure.} = object
    lpVtbl*: ptr IHTMLWindow2Vtbl
  IHTMLWindow2Vtbl* {.pure, inheritable.} = object of IHTMLFramesCollection2Vtbl
    get_frames*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLFramesCollection2): HRESULT {.stdcall.}
    put_defaultStatus*: proc(self: ptr IHTMLWindow2, v: BSTR): HRESULT {.stdcall.}
    get_defaultStatus*: proc(self: ptr IHTMLWindow2, p: ptr BSTR): HRESULT {.stdcall.}
    put_status*: proc(self: ptr IHTMLWindow2, v: BSTR): HRESULT {.stdcall.}
    get_status*: proc(self: ptr IHTMLWindow2, p: ptr BSTR): HRESULT {.stdcall.}
    setTimeout*: proc(self: ptr IHTMLWindow2, expression: BSTR, msec: LONG, language: ptr VARIANT, timerID: ptr LONG): HRESULT {.stdcall.}
    clearTimeout*: proc(self: ptr IHTMLWindow2, timerID: LONG): HRESULT {.stdcall.}
    alert*: proc(self: ptr IHTMLWindow2, message: BSTR): HRESULT {.stdcall.}
    confirm*: proc(self: ptr IHTMLWindow2, message: BSTR, confirmed: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    prompt*: proc(self: ptr IHTMLWindow2, message: BSTR, defstr: BSTR, textdata: ptr VARIANT): HRESULT {.stdcall.}
    get_Image*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLImageElementFactory): HRESULT {.stdcall.}
    get_location*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLLocation): HRESULT {.stdcall.}
    get_history*: proc(self: ptr IHTMLWindow2, p: ptr ptr IOmHistory): HRESULT {.stdcall.}
    close*: proc(self: ptr IHTMLWindow2): HRESULT {.stdcall.}
    put_opener*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_opener*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    get_navigator*: proc(self: ptr IHTMLWindow2, p: ptr ptr IOmNavigator): HRESULT {.stdcall.}
    put_name*: proc(self: ptr IHTMLWindow2, v: BSTR): HRESULT {.stdcall.}
    get_name*: proc(self: ptr IHTMLWindow2, p: ptr BSTR): HRESULT {.stdcall.}
    get_parent*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.stdcall.}
    open*: proc(self: ptr IHTMLWindow2, url: BSTR, name: BSTR, features: BSTR, replace: VARIANT_BOOL, pomWindowResult: ptr ptr IHTMLWindow2): HRESULT {.stdcall.}
    get_self*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.stdcall.}
    get_top*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.stdcall.}
    get_window*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.stdcall.}
    navigate*: proc(self: ptr IHTMLWindow2, url: BSTR): HRESULT {.stdcall.}
    put_onfocus*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onfocus*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onblur*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onblur*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onload*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onload*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onbeforeunload*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onbeforeunload*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onunload*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onunload*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onhelp*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onhelp*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onerror*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onerror*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onresize*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onresize*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    put_onscroll*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_onscroll*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    get_document*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLDocument2): HRESULT {.stdcall.}
    get_event*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLEventObj): HRESULT {.stdcall.}
    get_newEnum*: proc(self: ptr IHTMLWindow2, p: ptr ptr IUnknown): HRESULT {.stdcall.}
    showModalDialog*: proc(self: ptr IHTMLWindow2, dialog: BSTR, varArgIn: ptr VARIANT, varOptions: ptr VARIANT, varArgOut: ptr VARIANT): HRESULT {.stdcall.}
    showHelp*: proc(self: ptr IHTMLWindow2, helpURL: BSTR, helpArg: VARIANT, features: BSTR): HRESULT {.stdcall.}
    get_screen*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLScreen): HRESULT {.stdcall.}
    get_Option*: proc(self: ptr IHTMLWindow2, p: ptr ptr IHTMLOptionElementFactory): HRESULT {.stdcall.}
    focus*: proc(self: ptr IHTMLWindow2): HRESULT {.stdcall.}
    get_closed*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    blur*: proc(self: ptr IHTMLWindow2): HRESULT {.stdcall.}
    scroll*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    get_clientInformation*: proc(self: ptr IHTMLWindow2, p: ptr ptr IOmNavigator): HRESULT {.stdcall.}
    setInterval*: proc(self: ptr IHTMLWindow2, expression: BSTR, msec: LONG, language: ptr VARIANT, timerID: ptr LONG): HRESULT {.stdcall.}
    clearInterval*: proc(self: ptr IHTMLWindow2, timerID: LONG): HRESULT {.stdcall.}
    put_offscreenBuffering*: proc(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.stdcall.}
    get_offscreenBuffering*: proc(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.stdcall.}
    execScript*: proc(self: ptr IHTMLWindow2, code: BSTR, language: BSTR, pvarRet: ptr VARIANT): HRESULT {.stdcall.}
    toString*: proc(self: ptr IHTMLWindow2, String: ptr BSTR): HRESULT {.stdcall.}
    scrollBy*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    scrollTo*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    moveTo*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    moveBy*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    resizeTo*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    resizeBy*: proc(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.stdcall.}
    get_external*: proc(self: ptr IHTMLWindow2, p: ptr ptr IDispatch): HRESULT {.stdcall.}
  DOCHOSTUIINFO* {.pure.} = object
    cbSize*: ULONG
    dwFlags*: DWORD
    dwDoubleClick*: DWORD
    pchHostCss*: ptr OLECHAR
    pchHostNS*: ptr OLECHAR
  IHTMLTxtRange* {.pure.} = object
    lpVtbl*: ptr IHTMLTxtRangeVtbl
  IHTMLTxtRangeVtbl* {.pure, inheritable.} = object of IDispatchVtbl
    get_htmlText*: proc(self: ptr IHTMLTxtRange, p: ptr BSTR): HRESULT {.stdcall.}
    put_text*: proc(self: ptr IHTMLTxtRange, v: BSTR): HRESULT {.stdcall.}
    get_text*: proc(self: ptr IHTMLTxtRange, p: ptr BSTR): HRESULT {.stdcall.}
    parentElement*: proc(self: ptr IHTMLTxtRange, parent: ptr ptr IHTMLElement): HRESULT {.stdcall.}
    duplicate*: proc(self: ptr IHTMLTxtRange, Duplicate: ptr ptr IHTMLTxtRange): HRESULT {.stdcall.}
    inRange*: proc(self: ptr IHTMLTxtRange, Range: ptr IHTMLTxtRange, InRange: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    isEqual*: proc(self: ptr IHTMLTxtRange, Range: ptr IHTMLTxtRange, IsEqual: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    scrollIntoView*: proc(self: ptr IHTMLTxtRange, fStart: VARIANT_BOOL): HRESULT {.stdcall.}
    collapse*: proc(self: ptr IHTMLTxtRange, Start: VARIANT_BOOL): HRESULT {.stdcall.}
    expand*: proc(self: ptr IHTMLTxtRange, Unit: BSTR, Success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    move*: proc(self: ptr IHTMLTxtRange, Unit: BSTR, Count: LONG, ActualCount: ptr LONG): HRESULT {.stdcall.}
    moveStart*: proc(self: ptr IHTMLTxtRange, Unit: BSTR, Count: LONG, ActualCount: ptr LONG): HRESULT {.stdcall.}
    moveEnd*: proc(self: ptr IHTMLTxtRange, Unit: BSTR, Count: LONG, ActualCount: ptr LONG): HRESULT {.stdcall.}
    select*: proc(self: ptr IHTMLTxtRange): HRESULT {.stdcall.}
    pasteHTML*: proc(self: ptr IHTMLTxtRange, html: BSTR): HRESULT {.stdcall.}
    moveToElementText*: proc(self: ptr IHTMLTxtRange, element: ptr IHTMLElement): HRESULT {.stdcall.}
    setEndPoint*: proc(self: ptr IHTMLTxtRange, how: BSTR, SourceRange: ptr IHTMLTxtRange): HRESULT {.stdcall.}
    compareEndPoints*: proc(self: ptr IHTMLTxtRange, how: BSTR, SourceRange: ptr IHTMLTxtRange, ret: ptr LONG): HRESULT {.stdcall.}
    findText*: proc(self: ptr IHTMLTxtRange, String: BSTR, count: LONG, Flags: LONG, Success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    moveToPoint*: proc(self: ptr IHTMLTxtRange, x: LONG, y: LONG): HRESULT {.stdcall.}
    getBookmark*: proc(self: ptr IHTMLTxtRange, Boolmark: ptr BSTR): HRESULT {.stdcall.}
    moveToBookmark*: proc(self: ptr IHTMLTxtRange, Bookmark: BSTR, Success: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandSupported*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandEnabled*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandState*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandIndeterm*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    queryCommandText*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pcmdText: ptr BSTR): HRESULT {.stdcall.}
    queryCommandValue*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pcmdValue: ptr VARIANT): HRESULT {.stdcall.}
    execCommand*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, showUI: VARIANT_BOOL, value: VARIANT, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
    execCommandShowHelp*: proc(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.stdcall.}
  IDocHostUIHandler* {.pure.} = object
    lpVtbl*: ptr IDocHostUIHandlerVtbl
  IDocHostUIHandlerVtbl* {.pure, inheritable.} = object of IUnknownVtbl
    ShowContextMenu*: proc(self: ptr IDocHostUIHandler, dwID: DWORD, ppt: ptr POINT, pcmdtReserved: ptr IUnknown, pdispReserved: ptr IDispatch): HRESULT {.stdcall.}
    GetHostInfo*: proc(self: ptr IDocHostUIHandler, pInfo: ptr DOCHOSTUIINFO): HRESULT {.stdcall.}
    ShowUI*: proc(self: ptr IDocHostUIHandler, dwID: DWORD, pActiveObject: ptr IOleInPlaceActiveObject, pCommandTarget: ptr IOleCommandTarget, pFrame: ptr IOleInPlaceFrame, pDoc: ptr IOleInPlaceUIWindow): HRESULT {.stdcall.}
    HideUI*: proc(self: ptr IDocHostUIHandler): HRESULT {.stdcall.}
    UpdateUI*: proc(self: ptr IDocHostUIHandler): HRESULT {.stdcall.}
    EnableModeless*: proc(self: ptr IDocHostUIHandler, fEnable: WINBOOL): HRESULT {.stdcall.}
    OnDocWindowActivate*: proc(self: ptr IDocHostUIHandler, fActivate: WINBOOL): HRESULT {.stdcall.}
    OnFrameWindowActivate*: proc(self: ptr IDocHostUIHandler, fActivate: WINBOOL): HRESULT {.stdcall.}
    ResizeBorder*: proc(self: ptr IDocHostUIHandler, prcBorder: LPCRECT, pUIWindow: ptr IOleInPlaceUIWindow, fRameWindow: WINBOOL): HRESULT {.stdcall.}
    TranslateAccelerator*: proc(self: ptr IDocHostUIHandler, lpMsg: LPMSG, pguidCmdGroup: ptr GUID, nCmdID: DWORD): HRESULT {.stdcall.}
    GetOptionKeyPath*: proc(self: ptr IDocHostUIHandler, pchKey: ptr LPOLESTR, dw: DWORD): HRESULT {.stdcall.}
    GetDropTarget*: proc(self: ptr IDocHostUIHandler, pDropTarget: ptr IDropTarget, ppDropTarget: ptr ptr IDropTarget): HRESULT {.stdcall.}
    GetExternal*: proc(self: ptr IDocHostUIHandler, ppDispatch: ptr ptr IDispatch): HRESULT {.stdcall.}
    TranslateUrl*: proc(self: ptr IDocHostUIHandler, dwTranslate: DWORD, pchURLIn: LPWSTR, ppchURLOut: ptr LPWSTR): HRESULT {.stdcall.}
    FilterDataObject*: proc(self: ptr IDocHostUIHandler, pDO: ptr IDataObject, ppDORet: ptr ptr IDataObject): HRESULT {.stdcall.}
proc get_length*(self: ptr IHTMLFiltersCollection, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc get_newEnum*(self: ptr IHTMLFiltersCollection, p: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_newEnum(self, p)
proc item*(self: ptr IHTMLFiltersCollection, pvarIndex: ptr VARIANT, pvarResult: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.item(self, pvarIndex, pvarResult)
proc put_fontFamily*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontFamily(self, v)
proc get_fontFamily*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontFamily(self, p)
proc put_fontStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontStyle(self, v)
proc get_fontStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontStyle(self, p)
proc put_fontVariant*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontVariant(self, v)
proc get_fontVariant*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontVariant(self, p)
proc put_fontWeight*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontWeight(self, v)
proc get_fontWeight*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontWeight(self, p)
proc put_fontSize*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontSize(self, v)
proc get_fontSize*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontSize(self, p)
proc put_font*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_font(self, v)
proc get_font*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_font(self, p)
proc put_color*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_color(self, v)
proc get_color*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_color(self, p)
proc put_background*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_background(self, v)
proc get_background*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_background(self, p)
proc put_backgroundColor*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundColor(self, v)
proc get_backgroundColor*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundColor(self, p)
proc put_backgroundImage*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundImage(self, v)
proc get_backgroundImage*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundImage(self, p)
proc put_backgroundRepeat*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundRepeat(self, v)
proc get_backgroundRepeat*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundRepeat(self, p)
proc put_backgroundAttachment*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundAttachment(self, v)
proc get_backgroundAttachment*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundAttachment(self, p)
proc put_backgroundPosition*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundPosition(self, v)
proc get_backgroundPosition*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundPosition(self, p)
proc put_backgroundPositionX*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundPositionX(self, v)
proc get_backgroundPositionX*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundPositionX(self, p)
proc put_backgroundPositionY*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundPositionY(self, v)
proc get_backgroundPositionY*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundPositionY(self, p)
proc put_wordSpacing*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_wordSpacing(self, v)
proc get_wordSpacing*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_wordSpacing(self, p)
proc put_letterSpacing*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_letterSpacing(self, v)
proc get_letterSpacing*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_letterSpacing(self, p)
proc put_textDecoration*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecoration(self, v)
proc get_textDecoration*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecoration(self, p)
proc put_textDecorationNone*(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationNone(self, v)
proc get_textDecorationNone*(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationNone(self, p)
proc put_textDecorationUnderline*(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationUnderline(self, v)
proc get_textDecorationUnderline*(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationUnderline(self, p)
proc put_textDecorationOverline*(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationOverline(self, v)
proc get_textDecorationOverline*(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationOverline(self, p)
proc put_textDecorationLineThrough*(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationLineThrough(self, v)
proc get_textDecorationLineThrough*(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationLineThrough(self, p)
proc put_textDecorationBlink*(self: ptr IHTMLStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationBlink(self, v)
proc get_textDecorationBlink*(self: ptr IHTMLStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationBlink(self, p)
proc put_verticalAlign*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_verticalAlign(self, v)
proc get_verticalAlign*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_verticalAlign(self, p)
proc put_textTransform*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textTransform(self, v)
proc get_textTransform*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textTransform(self, p)
proc put_textAlign*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textAlign(self, v)
proc get_textAlign*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textAlign(self, p)
proc put_textIndent*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textIndent(self, v)
proc get_textIndent*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textIndent(self, p)
proc put_lineHeight*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_lineHeight(self, v)
proc get_lineHeight*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_lineHeight(self, p)
proc put_marginTop*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginTop(self, v)
proc get_marginTop*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginTop(self, p)
proc put_marginRight*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginRight(self, v)
proc get_marginRight*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginRight(self, p)
proc put_marginBottom*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginBottom(self, v)
proc get_marginBottom*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginBottom(self, p)
proc put_marginLeft*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginLeft(self, v)
proc get_marginLeft*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginLeft(self, p)
proc put_margin*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_margin(self, v)
proc get_margin*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_margin(self, p)
proc put_paddingTop*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingTop(self, v)
proc get_paddingTop*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingTop(self, p)
proc put_paddingRight*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingRight(self, v)
proc get_paddingRight*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingRight(self, p)
proc put_paddingBottom*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingBottom(self, v)
proc get_paddingBottom*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingBottom(self, p)
proc put_paddingLeft*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingLeft(self, v)
proc get_paddingLeft*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingLeft(self, p)
proc put_padding*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_padding(self, v)
proc get_padding*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_padding(self, p)
proc put_border*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_border(self, v)
proc get_border*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_border(self, p)
proc put_borderTop*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTop(self, v)
proc get_borderTop*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTop(self, p)
proc put_borderRight*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRight(self, v)
proc get_borderRight*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRight(self, p)
proc put_borderBottom*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottom(self, v)
proc get_borderBottom*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottom(self, p)
proc put_borderLeft*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeft(self, v)
proc get_borderLeft*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeft(self, p)
proc put_borderColor*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderColor(self, v)
proc get_borderColor*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderColor(self, p)
proc put_borderTopColor*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTopColor(self, v)
proc get_borderTopColor*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTopColor(self, p)
proc put_borderRightColor*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRightColor(self, v)
proc get_borderRightColor*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRightColor(self, p)
proc put_borderBottomColor*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottomColor(self, v)
proc get_borderBottomColor*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottomColor(self, p)
proc put_borderLeftColor*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeftColor(self, v)
proc get_borderLeftColor*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeftColor(self, p)
proc put_borderWidth*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderWidth(self, v)
proc get_borderWidth*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderWidth(self, p)
proc put_borderTopWidth*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTopWidth(self, v)
proc get_borderTopWidth*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTopWidth(self, p)
proc put_borderRightWidth*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRightWidth(self, v)
proc get_borderRightWidth*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRightWidth(self, p)
proc put_borderBottomWidth*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottomWidth(self, v)
proc get_borderBottomWidth*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottomWidth(self, p)
proc put_borderLeftWidth*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeftWidth(self, v)
proc get_borderLeftWidth*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeftWidth(self, p)
proc put_borderStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderStyle(self, v)
proc get_borderStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderStyle(self, p)
proc put_borderTopStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTopStyle(self, v)
proc get_borderTopStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTopStyle(self, p)
proc put_borderRightStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRightStyle(self, v)
proc get_borderRightStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRightStyle(self, p)
proc put_borderBottomStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottomStyle(self, v)
proc get_borderBottomStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottomStyle(self, p)
proc put_borderLeftStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeftStyle(self, v)
proc get_borderLeftStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeftStyle(self, p)
proc put_width*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_width(self, v)
proc get_width*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_width(self, p)
proc put_height*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_height(self, v)
proc get_height*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_height(self, p)
proc put_styleFloat*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_styleFloat(self, v)
proc get_styleFloat*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_styleFloat(self, p)
proc put_clear*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_clear(self, v)
proc get_clear*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clear(self, p)
proc put_display*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_display(self, v)
proc get_display*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_display(self, p)
proc put_visibility*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_visibility(self, v)
proc get_visibility*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_visibility(self, p)
proc put_listStyleType*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStyleType(self, v)
proc get_listStyleType*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStyleType(self, p)
proc put_listStylePosition*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStylePosition(self, v)
proc get_listStylePosition*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStylePosition(self, p)
proc put_listStyleImage*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStyleImage(self, v)
proc get_listStyleImage*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStyleImage(self, p)
proc put_listStyle*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStyle(self, v)
proc get_listStyle*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStyle(self, p)
proc put_whiteSpace*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_whiteSpace(self, v)
proc get_whiteSpace*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_whiteSpace(self, p)
proc put_top*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_top(self, v)
proc get_top*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_top(self, p)
proc put_left*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_left(self, v)
proc get_left*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_left(self, p)
proc get_position*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_position(self, p)
proc put_zIndex*(self: ptr IHTMLStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_zIndex(self, v)
proc get_zIndex*(self: ptr IHTMLStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_zIndex(self, p)
proc put_overflow*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_overflow(self, v)
proc get_overflow*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_overflow(self, p)
proc put_pageBreakBefore*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pageBreakBefore(self, v)
proc get_pageBreakBefore*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pageBreakBefore(self, p)
proc put_pageBreakAfter*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pageBreakAfter(self, v)
proc get_pageBreakAfter*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pageBreakAfter(self, p)
proc put_cssText*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cssText(self, v)
proc get_cssText*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cssText(self, p)
proc put_pixelTop*(self: ptr IHTMLStyle, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pixelTop(self, v)
proc get_pixelTop*(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pixelTop(self, p)
proc put_pixelLeft*(self: ptr IHTMLStyle, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pixelLeft(self, v)
proc get_pixelLeft*(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pixelLeft(self, p)
proc put_pixelWidth*(self: ptr IHTMLStyle, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pixelWidth(self, v)
proc get_pixelWidth*(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pixelWidth(self, p)
proc put_pixelHeight*(self: ptr IHTMLStyle, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pixelHeight(self, v)
proc get_pixelHeight*(self: ptr IHTMLStyle, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pixelHeight(self, p)
proc put_posTop*(self: ptr IHTMLStyle, v: float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_posTop(self, v)
proc get_posTop*(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_posTop(self, p)
proc put_posLeft*(self: ptr IHTMLStyle, v: float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_posLeft(self, v)
proc get_posLeft*(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_posLeft(self, p)
proc put_posWidth*(self: ptr IHTMLStyle, v: float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_posWidth(self, v)
proc get_posWidth*(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_posWidth(self, p)
proc put_posHeight*(self: ptr IHTMLStyle, v: float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_posHeight(self, v)
proc get_posHeight*(self: ptr IHTMLStyle, p: ptr float32): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_posHeight(self, p)
proc put_cursor*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cursor(self, v)
proc get_cursor*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cursor(self, p)
proc put_clip*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_clip(self, v)
proc get_clip*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clip(self, p)
proc put_filter*(self: ptr IHTMLStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_filter(self, v)
proc get_filter*(self: ptr IHTMLStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_filter(self, p)
proc setAttribute*(self: ptr IHTMLStyle, strAttributeName: BSTR, AttributeValue: VARIANT, lFlags: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setAttribute(self, strAttributeName, AttributeValue, lFlags)
proc getAttribute*(self: ptr IHTMLStyle, strAttributeName: BSTR, lFlags: LONG, AttributeValue: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.getAttribute(self, strAttributeName, lFlags, AttributeValue)
proc removeAttribute*(self: ptr IHTMLStyle, strAttributeName: BSTR, lFlags: LONG, pfSuccess: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.removeAttribute(self, strAttributeName, lFlags, pfSuccess)
proc toString*(self: ptr IHTMLStyle, String: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, String)
proc put_fontFamily*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontFamily(self, v)
proc get_fontFamily*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontFamily(self, p)
proc put_fontStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontStyle(self, v)
proc get_fontStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontStyle(self, p)
proc put_fontVariant*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontVariant(self, v)
proc get_fontVariant*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontVariant(self, p)
proc put_fontWeight*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontWeight(self, v)
proc get_fontWeight*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontWeight(self, p)
proc put_fontSize*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fontSize(self, v)
proc get_fontSize*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontSize(self, p)
proc put_font*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_font(self, v)
proc get_font*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_font(self, p)
proc put_color*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_color(self, v)
proc get_color*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_color(self, p)
proc put_background*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_background(self, v)
proc get_background*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_background(self, p)
proc put_backgroundColor*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundColor(self, v)
proc get_backgroundColor*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundColor(self, p)
proc put_backgroundImage*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundImage(self, v)
proc get_backgroundImage*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundImage(self, p)
proc put_backgroundRepeat*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundRepeat(self, v)
proc get_backgroundRepeat*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundRepeat(self, p)
proc put_backgroundAttachment*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundAttachment(self, v)
proc get_backgroundAttachment*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundAttachment(self, p)
proc put_backgroundPosition*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundPosition(self, v)
proc get_backgroundPosition*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundPosition(self, p)
proc put_backgroundPositionX*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundPositionX(self, v)
proc get_backgroundPositionX*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundPositionX(self, p)
proc put_backgroundPositionY*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_backgroundPositionY(self, v)
proc get_backgroundPositionY*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_backgroundPositionY(self, p)
proc put_wordSpacing*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_wordSpacing(self, v)
proc get_wordSpacing*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_wordSpacing(self, p)
proc put_letterSpacing*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_letterSpacing(self, v)
proc get_letterSpacing*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_letterSpacing(self, p)
proc put_textDecoration*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecoration(self, v)
proc get_textDecoration*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecoration(self, p)
proc put_textDecorationNone*(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationNone(self, v)
proc get_textDecorationNone*(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationNone(self, p)
proc put_textDecorationUnderline*(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationUnderline(self, v)
proc get_textDecorationUnderline*(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationUnderline(self, p)
proc put_textDecorationOverline*(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationOverline(self, v)
proc get_textDecorationOverline*(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationOverline(self, p)
proc put_textDecorationLineThrough*(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationLineThrough(self, v)
proc get_textDecorationLineThrough*(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationLineThrough(self, p)
proc put_textDecorationBlink*(self: ptr IHTMLRuleStyle, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textDecorationBlink(self, v)
proc get_textDecorationBlink*(self: ptr IHTMLRuleStyle, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textDecorationBlink(self, p)
proc put_verticalAlign*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_verticalAlign(self, v)
proc get_verticalAlign*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_verticalAlign(self, p)
proc put_textTransform*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textTransform(self, v)
proc get_textTransform*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textTransform(self, p)
proc put_textAlign*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textAlign(self, v)
proc get_textAlign*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textAlign(self, p)
proc put_textIndent*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_textIndent(self, v)
proc get_textIndent*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_textIndent(self, p)
proc put_lineHeight*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_lineHeight(self, v)
proc get_lineHeight*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_lineHeight(self, p)
proc put_marginTop*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginTop(self, v)
proc get_marginTop*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginTop(self, p)
proc put_marginRight*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginRight(self, v)
proc get_marginRight*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginRight(self, p)
proc put_marginBottom*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginBottom(self, v)
proc get_marginBottom*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginBottom(self, p)
proc put_marginLeft*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_marginLeft(self, v)
proc get_marginLeft*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_marginLeft(self, p)
proc put_margin*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_margin(self, v)
proc get_margin*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_margin(self, p)
proc put_paddingTop*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingTop(self, v)
proc get_paddingTop*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingTop(self, p)
proc put_paddingRight*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingRight(self, v)
proc get_paddingRight*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingRight(self, p)
proc put_paddingBottom*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingBottom(self, v)
proc get_paddingBottom*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingBottom(self, p)
proc put_paddingLeft*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_paddingLeft(self, v)
proc get_paddingLeft*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_paddingLeft(self, p)
proc put_padding*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_padding(self, v)
proc get_padding*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_padding(self, p)
proc put_border*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_border(self, v)
proc get_border*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_border(self, p)
proc put_borderTop*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTop(self, v)
proc get_borderTop*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTop(self, p)
proc put_borderRight*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRight(self, v)
proc get_borderRight*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRight(self, p)
proc put_borderBottom*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottom(self, v)
proc get_borderBottom*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottom(self, p)
proc put_borderLeft*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeft(self, v)
proc get_borderLeft*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeft(self, p)
proc put_borderColor*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderColor(self, v)
proc get_borderColor*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderColor(self, p)
proc put_borderTopColor*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTopColor(self, v)
proc get_borderTopColor*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTopColor(self, p)
proc put_borderRightColor*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRightColor(self, v)
proc get_borderRightColor*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRightColor(self, p)
proc put_borderBottomColor*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottomColor(self, v)
proc get_borderBottomColor*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottomColor(self, p)
proc put_borderLeftColor*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeftColor(self, v)
proc get_borderLeftColor*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeftColor(self, p)
proc put_borderWidth*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderWidth(self, v)
proc get_borderWidth*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderWidth(self, p)
proc put_borderTopWidth*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTopWidth(self, v)
proc get_borderTopWidth*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTopWidth(self, p)
proc put_borderRightWidth*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRightWidth(self, v)
proc get_borderRightWidth*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRightWidth(self, p)
proc put_borderBottomWidth*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottomWidth(self, v)
proc get_borderBottomWidth*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottomWidth(self, p)
proc put_borderLeftWidth*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeftWidth(self, v)
proc get_borderLeftWidth*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeftWidth(self, p)
proc put_borderStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderStyle(self, v)
proc get_borderStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderStyle(self, p)
proc put_borderTopStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderTopStyle(self, v)
proc get_borderTopStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderTopStyle(self, p)
proc put_borderRightStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderRightStyle(self, v)
proc get_borderRightStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderRightStyle(self, p)
proc put_borderBottomStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderBottomStyle(self, v)
proc get_borderBottomStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderBottomStyle(self, p)
proc put_borderLeftStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_borderLeftStyle(self, v)
proc get_borderLeftStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_borderLeftStyle(self, p)
proc put_width*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_width(self, v)
proc get_width*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_width(self, p)
proc put_height*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_height(self, v)
proc get_height*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_height(self, p)
proc put_styleFloat*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_styleFloat(self, v)
proc get_styleFloat*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_styleFloat(self, p)
proc put_clear*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_clear(self, v)
proc get_clear*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clear(self, p)
proc put_display*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_display(self, v)
proc get_display*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_display(self, p)
proc put_visibility*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_visibility(self, v)
proc get_visibility*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_visibility(self, p)
proc put_listStyleType*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStyleType(self, v)
proc get_listStyleType*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStyleType(self, p)
proc put_listStylePosition*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStylePosition(self, v)
proc get_listStylePosition*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStylePosition(self, p)
proc put_listStyleImage*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStyleImage(self, v)
proc get_listStyleImage*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStyleImage(self, p)
proc put_listStyle*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_listStyle(self, v)
proc get_listStyle*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_listStyle(self, p)
proc put_whiteSpace*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_whiteSpace(self, v)
proc get_whiteSpace*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_whiteSpace(self, p)
proc put_top*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_top(self, v)
proc get_top*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_top(self, p)
proc put_left*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_left(self, v)
proc get_left*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_left(self, p)
proc get_position*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_position(self, p)
proc put_zIndex*(self: ptr IHTMLRuleStyle, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_zIndex(self, v)
proc get_zIndex*(self: ptr IHTMLRuleStyle, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_zIndex(self, p)
proc put_overflow*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_overflow(self, v)
proc get_overflow*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_overflow(self, p)
proc put_pageBreakBefore*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pageBreakBefore(self, v)
proc get_pageBreakBefore*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pageBreakBefore(self, p)
proc put_pageBreakAfter*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pageBreakAfter(self, v)
proc get_pageBreakAfter*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pageBreakAfter(self, p)
proc put_cssText*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cssText(self, v)
proc get_cssText*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cssText(self, p)
proc put_cursor*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cursor(self, v)
proc get_cursor*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cursor(self, p)
proc put_clip*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_clip(self, v)
proc get_clip*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clip(self, p)
proc put_filter*(self: ptr IHTMLRuleStyle, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_filter(self, v)
proc get_filter*(self: ptr IHTMLRuleStyle, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_filter(self, p)
proc setAttribute*(self: ptr IHTMLRuleStyle, strAttributeName: BSTR, AttributeValue: VARIANT, lFlags: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setAttribute(self, strAttributeName, AttributeValue, lFlags)
proc getAttribute*(self: ptr IHTMLRuleStyle, strAttributeName: BSTR, lFlags: LONG, AttributeValue: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.getAttribute(self, strAttributeName, lFlags, AttributeValue)
proc removeAttribute*(self: ptr IHTMLRuleStyle, strAttributeName: BSTR, lFlags: LONG, pfSuccess: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.removeAttribute(self, strAttributeName, lFlags, pfSuccess)
proc setAttribute*(self: ptr IHTMLElement, strAttributeName: BSTR, AttributeValue: VARIANT, lFlags: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setAttribute(self, strAttributeName, AttributeValue, lFlags)
proc getAttribute*(self: ptr IHTMLElement, strAttributeName: BSTR, lFlags: LONG, AttributeValue: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.getAttribute(self, strAttributeName, lFlags, AttributeValue)
proc removeAttribute*(self: ptr IHTMLElement, strAttributeName: BSTR, lFlags: LONG, pfSuccess: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.removeAttribute(self, strAttributeName, lFlags, pfSuccess)
proc put_className*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_className(self, v)
proc get_className*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_className(self, p)
proc put_id*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_id(self, v)
proc get_id*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_id(self, p)
proc get_tagName*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_tagName(self, p)
proc get_parentElement*(self: ptr IHTMLElement, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_parentElement(self, p)
proc get_style*(self: ptr IHTMLElement, p: ptr ptr IHTMLStyle): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_style(self, p)
proc put_onhelp*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onhelp(self, v)
proc get_onhelp*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onhelp(self, p)
proc put_onclick*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onclick(self, v)
proc get_onclick*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onclick(self, p)
proc put_ondblclick*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondblclick(self, v)
proc get_ondblclick*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondblclick(self, p)
proc put_onkeydown*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onkeydown(self, v)
proc get_onkeydown*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onkeydown(self, p)
proc put_onkeyup*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onkeyup(self, v)
proc get_onkeyup*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onkeyup(self, p)
proc put_onkeypress*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onkeypress(self, v)
proc get_onkeypress*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onkeypress(self, p)
proc put_onmouseout*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmouseout(self, v)
proc get_onmouseout*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmouseout(self, p)
proc put_onmouseover*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmouseover(self, v)
proc get_onmouseover*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmouseover(self, p)
proc put_onmousemove*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmousemove(self, v)
proc get_onmousemove*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmousemove(self, p)
proc put_onmousedown*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmousedown(self, v)
proc get_onmousedown*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmousedown(self, p)
proc put_onmouseup*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmouseup(self, v)
proc get_onmouseup*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmouseup(self, p)
proc get_document*(self: ptr IHTMLElement, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_document(self, p)
proc put_title*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_title(self, v)
proc get_title*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_title(self, p)
proc put_language*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_language(self, v)
proc get_language*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_language(self, p)
proc put_onselectstart*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onselectstart(self, v)
proc get_onselectstart*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onselectstart(self, p)
proc scrollIntoView*(self: ptr IHTMLElement, varargStart: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.scrollIntoView(self, varargStart)
proc contains*(self: ptr IHTMLElement, pChild: ptr IHTMLElement, pfResult: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.contains(self, pChild, pfResult)
proc get_sourceIndex*(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_sourceIndex(self, p)
proc get_recordNumber*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_recordNumber(self, p)
proc put_lang*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_lang(self, v)
proc get_lang*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_lang(self, p)
proc get_offsetLeft*(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetLeft(self, p)
proc get_offsetTop*(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetTop(self, p)
proc get_offsetWidth*(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetWidth(self, p)
proc get_offsetHeight*(self: ptr IHTMLElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetHeight(self, p)
proc get_offsetParent*(self: ptr IHTMLElement, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetParent(self, p)
proc put_innerHTML*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_innerHTML(self, v)
proc get_innerHTML*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_innerHTML(self, p)
proc put_innerText*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_innerText(self, v)
proc get_innerText*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_innerText(self, p)
proc put_outerHTML*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_outerHTML(self, v)
proc get_outerHTML*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_outerHTML(self, p)
proc put_outerText*(self: ptr IHTMLElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_outerText(self, v)
proc get_outerText*(self: ptr IHTMLElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_outerText(self, p)
proc insertAdjacentHTML*(self: ptr IHTMLElement, where: BSTR, html: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.insertAdjacentHTML(self, where, html)
proc insertAdjacentText*(self: ptr IHTMLElement, where: BSTR, text: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.insertAdjacentText(self, where, text)
proc get_parentTextEdit*(self: ptr IHTMLElement, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_parentTextEdit(self, p)
proc get_isTextEdit*(self: ptr IHTMLElement, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_isTextEdit(self, p)
proc click*(self: ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.click(self)
proc get_filters*(self: ptr IHTMLElement, p: ptr ptr IHTMLFiltersCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_filters(self, p)
proc put_ondragstart*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondragstart(self, v)
proc get_ondragstart*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondragstart(self, p)
proc toString*(self: ptr IHTMLElement, String: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, String)
proc put_onbeforeupdate*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onbeforeupdate(self, v)
proc get_onbeforeupdate*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onbeforeupdate(self, p)
proc put_onafterupdate*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onafterupdate(self, v)
proc get_onafterupdate*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onafterupdate(self, p)
proc put_onerrorupdate*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onerrorupdate(self, v)
proc get_onerrorupdate*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onerrorupdate(self, p)
proc put_onrowexit*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onrowexit(self, v)
proc get_onrowexit*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onrowexit(self, p)
proc put_onrowenter*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onrowenter(self, v)
proc get_onrowenter*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onrowenter(self, p)
proc put_ondatasetchanged*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondatasetchanged(self, v)
proc get_ondatasetchanged*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondatasetchanged(self, p)
proc put_ondataavailable*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondataavailable(self, v)
proc get_ondataavailable*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondataavailable(self, p)
proc put_ondatasetcomplete*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondatasetcomplete(self, v)
proc get_ondatasetcomplete*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondatasetcomplete(self, p)
proc put_onfilterchange*(self: ptr IHTMLElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onfilterchange(self, v)
proc get_onfilterchange*(self: ptr IHTMLElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onfilterchange(self, p)
proc get_children*(self: ptr IHTMLElement, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_children(self, p)
proc get_all*(self: ptr IHTMLElement, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_all(self, p)
proc put_selectorText*(self: ptr IHTMLStyleSheetRule, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_selectorText(self, v)
proc get_selectorText*(self: ptr IHTMLStyleSheetRule, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_selectorText(self, p)
proc get_style*(self: ptr IHTMLStyleSheetRule, p: ptr ptr IHTMLRuleStyle): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_style(self, p)
proc get_readOnly*(self: ptr IHTMLStyleSheetRule, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_readOnly(self, p)
proc get_length*(self: ptr IHTMLStyleSheetRulesCollection, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc item*(self: ptr IHTMLStyleSheetRulesCollection, index: LONG, ppHTMLStyleSheetRule: ptr ptr IHTMLStyleSheetRule): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.item(self, index, ppHTMLStyleSheetRule)
proc put_title*(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_title(self, v)
proc get_title*(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_title(self, p)
proc get_parentStyleSheet*(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLStyleSheet): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_parentStyleSheet(self, p)
proc get_owningElement*(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_owningElement(self, p)
proc put_disabled*(self: ptr IHTMLStyleSheet, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_disabled(self, v)
proc get_disabled*(self: ptr IHTMLStyleSheet, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_disabled(self, p)
proc get_readOnly*(self: ptr IHTMLStyleSheet, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_readOnly(self, p)
proc get_imports*(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLStyleSheetsCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_imports(self, p)
proc put_href*(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_href(self, v)
proc get_href*(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_href(self, p)
proc get_type*(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_type(self, p)
proc get_id*(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_id(self, p)
proc addImport*(self: ptr IHTMLStyleSheet, bstrURL: BSTR, lIndex: LONG, plIndex: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.addImport(self, bstrURL, lIndex, plIndex)
proc addRule*(self: ptr IHTMLStyleSheet, bstrSelector: BSTR, bstrStyle: BSTR, lIndex: LONG, plNewIndex: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.addRule(self, bstrSelector, bstrStyle, lIndex, plNewIndex)
proc removeImport*(self: ptr IHTMLStyleSheet, lIndex: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.removeImport(self, lIndex)
proc removeRule*(self: ptr IHTMLStyleSheet, lIndex: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.removeRule(self, lIndex)
proc put_media*(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_media(self, v)
proc get_media*(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_media(self, p)
proc put_cssText*(self: ptr IHTMLStyleSheet, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cssText(self, v)
proc get_cssText*(self: ptr IHTMLStyleSheet, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cssText(self, p)
proc get_rules*(self: ptr IHTMLStyleSheet, p: ptr ptr IHTMLStyleSheetRulesCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_rules(self, p)
proc get_length*(self: ptr IHTMLStyleSheetsCollection, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc get_newEnum*(self: ptr IHTMLStyleSheetsCollection, p: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_newEnum(self, p)
proc item*(self: ptr IHTMLStyleSheetsCollection, pvarIndex: ptr VARIANT, pvarResult: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.item(self, pvarIndex, pvarResult)
proc get_htmlText*(self: ptr IHTMLTxtRange, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_htmlText(self, p)
proc put_text*(self: ptr IHTMLTxtRange, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_text(self, v)
proc get_text*(self: ptr IHTMLTxtRange, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_text(self, p)
proc parentElement*(self: ptr IHTMLTxtRange, parent: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.parentElement(self, parent)
proc duplicate*(self: ptr IHTMLTxtRange, Duplicate: ptr ptr IHTMLTxtRange): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.duplicate(self, Duplicate)
proc inRange*(self: ptr IHTMLTxtRange, Range: ptr IHTMLTxtRange, InRange: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.inRange(self, Range, InRange)
proc isEqual*(self: ptr IHTMLTxtRange, Range: ptr IHTMLTxtRange, IsEqual: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.isEqual(self, Range, IsEqual)
proc scrollIntoView*(self: ptr IHTMLTxtRange, fStart: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.scrollIntoView(self, fStart)
proc collapse*(self: ptr IHTMLTxtRange, Start: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.collapse(self, Start)
proc expand*(self: ptr IHTMLTxtRange, Unit: BSTR, Success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.expand(self, Unit, Success)
proc move*(self: ptr IHTMLTxtRange, Unit: BSTR, Count: LONG, ActualCount: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.move(self, Unit, Count, ActualCount)
proc moveStart*(self: ptr IHTMLTxtRange, Unit: BSTR, Count: LONG, ActualCount: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveStart(self, Unit, Count, ActualCount)
proc moveEnd*(self: ptr IHTMLTxtRange, Unit: BSTR, Count: LONG, ActualCount: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveEnd(self, Unit, Count, ActualCount)
proc select*(self: ptr IHTMLTxtRange): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.select(self)
proc pasteHTML*(self: ptr IHTMLTxtRange, html: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.pasteHTML(self, html)
proc moveToElementText*(self: ptr IHTMLTxtRange, element: ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveToElementText(self, element)
proc setEndPoint*(self: ptr IHTMLTxtRange, how: BSTR, SourceRange: ptr IHTMLTxtRange): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setEndPoint(self, how, SourceRange)
proc compareEndPoints*(self: ptr IHTMLTxtRange, how: BSTR, SourceRange: ptr IHTMLTxtRange, ret: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.compareEndPoints(self, how, SourceRange, ret)
proc findText*(self: ptr IHTMLTxtRange, String: BSTR, count: LONG, Flags: LONG, Success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.findText(self, String, count, Flags, Success)
proc moveToPoint*(self: ptr IHTMLTxtRange, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveToPoint(self, x, y)
proc getBookmark*(self: ptr IHTMLTxtRange, Boolmark: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.getBookmark(self, Boolmark)
proc moveToBookmark*(self: ptr IHTMLTxtRange, Bookmark: BSTR, Success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveToBookmark(self, Bookmark, Success)
proc queryCommandSupported*(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandSupported(self, cmdID, pfRet)
proc queryCommandEnabled*(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandEnabled(self, cmdID, pfRet)
proc queryCommandState*(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandState(self, cmdID, pfRet)
proc queryCommandIndeterm*(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandIndeterm(self, cmdID, pfRet)
proc queryCommandText*(self: ptr IHTMLTxtRange, cmdID: BSTR, pcmdText: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandText(self, cmdID, pcmdText)
proc queryCommandValue*(self: ptr IHTMLTxtRange, cmdID: BSTR, pcmdValue: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandValue(self, cmdID, pcmdValue)
proc execCommand*(self: ptr IHTMLTxtRange, cmdID: BSTR, showUI: VARIANT_BOOL, value: VARIANT, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.execCommand(self, cmdID, showUI, value, pfRet)
proc execCommandShowHelp*(self: ptr IHTMLTxtRange, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.execCommandShowHelp(self, cmdID, pfRet)
proc put_action*(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_action(self, v)
proc get_action*(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_action(self, p)
proc put_dir*(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_dir(self, v)
proc get_dir*(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_dir(self, p)
proc put_encoding*(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_encoding(self, v)
proc get_encoding*(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_encoding(self, p)
proc put_method*(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_method(self, v)
proc get_method*(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_method(self, p)
proc get_elements*(self: ptr IHTMLFormElement, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_elements(self, p)
proc put_target*(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_target(self, v)
proc get_target*(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_target(self, p)
proc put_name*(self: ptr IHTMLFormElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_name(self, v)
proc get_name*(self: ptr IHTMLFormElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_name(self, p)
proc put_onsubmit*(self: ptr IHTMLFormElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onsubmit(self, v)
proc get_onsubmit*(self: ptr IHTMLFormElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onsubmit(self, p)
proc put_onreset*(self: ptr IHTMLFormElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onreset(self, v)
proc get_onreset*(self: ptr IHTMLFormElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onreset(self, p)
proc submit*(self: ptr IHTMLFormElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.submit(self)
proc reset*(self: ptr IHTMLFormElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.reset(self)
proc put_length*(self: ptr IHTMLFormElement, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_length(self, v)
proc get_length*(self: ptr IHTMLFormElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc get_newEnum*(self: ptr IHTMLFormElement, p: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_newEnum(self, p)
proc item*(self: ptr IHTMLFormElement, name: VARIANT, index: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.item(self, name, index, pdisp)
proc tags*(self: ptr IHTMLFormElement, tagName: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.tags(self, tagName, pdisp)
proc put_isMap*(self: ptr IHTMLImgElement, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_isMap(self, v)
proc get_isMap*(self: ptr IHTMLImgElement, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_isMap(self, p)
proc put_useMap*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_useMap(self, v)
proc get_useMap*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_useMap(self, p)
proc get_mimeType*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_mimeType(self, p)
proc get_fileSize*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileSize(self, p)
proc get_fileCreatedDate*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileCreatedDate(self, p)
proc get_fileModifiedDate*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileModifiedDate(self, p)
proc get_fileUpdatedDate*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileUpdatedDate(self, p)
proc get_protocol*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_protocol(self, p)
proc get_href*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_href(self, p)
proc get_nameProp*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_nameProp(self, p)
proc put_border*(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_border(self, v)
proc get_border*(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_border(self, p)
proc put_vspace*(self: ptr IHTMLImgElement, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_vspace(self, v)
proc get_vspace*(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_vspace(self, p)
proc put_hspace*(self: ptr IHTMLImgElement, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_hspace(self, v)
proc get_hspace*(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_hspace(self, p)
proc put_alt*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_alt(self, v)
proc get_alt*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_alt(self, p)
proc put_src*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_src(self, v)
proc get_src*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_src(self, p)
proc put_lowsrc*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_lowsrc(self, v)
proc get_lowsrc*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_lowsrc(self, p)
proc put_vrml*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_vrml(self, v)
proc get_vrml*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_vrml(self, p)
proc put_dynsrc*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_dynsrc(self, v)
proc get_dynsrc*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_dynsrc(self, p)
proc get_readyState*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_readyState(self, p)
proc get_complete*(self: ptr IHTMLImgElement, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_complete(self, p)
proc put_loop*(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_loop(self, v)
proc get_loop*(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_loop(self, p)
proc put_align*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_align(self, v)
proc get_align*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_align(self, p)
proc put_onload*(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onload(self, v)
proc get_onload*(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onload(self, p)
proc put_onerror*(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onerror(self, v)
proc get_onerror*(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onerror(self, p)
proc put_onabort*(self: ptr IHTMLImgElement, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onabort(self, v)
proc get_onabort*(self: ptr IHTMLImgElement, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onabort(self, p)
proc put_name*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_name(self, v)
proc get_name*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_name(self, p)
proc put_width*(self: ptr IHTMLImgElement, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_width(self, v)
proc get_width*(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_width(self, p)
proc put_height*(self: ptr IHTMLImgElement, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_height(self, v)
proc get_height*(self: ptr IHTMLImgElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_height(self, p)
proc put_start*(self: ptr IHTMLImgElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_start(self, v)
proc get_start*(self: ptr IHTMLImgElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_start(self, p)
proc create*(self: ptr IHTMLImageElementFactory, width: VARIANT, height: VARIANT, a: ptr ptr IHTMLImgElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.create(self, width, height, a)
proc toString*(self: ptr IHTMLElementCollection, String: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, String)
proc put_length*(self: ptr IHTMLElementCollection, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_length(self, v)
proc get_length*(self: ptr IHTMLElementCollection, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc get_newEnum*(self: ptr IHTMLElementCollection, p: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_newEnum(self, p)
proc item*(self: ptr IHTMLElementCollection, name: VARIANT, index: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.item(self, name, index, pdisp)
proc tags*(self: ptr IHTMLElementCollection, tagName: VARIANT, pdisp: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.tags(self, tagName, pdisp)
proc createRange*(self: ptr IHTMLSelectionObject, range: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.createRange(self, range)
proc empty*(self: ptr IHTMLSelectionObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.empty(self)
proc clear*(self: ptr IHTMLSelectionObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.clear(self)
proc get_type*(self: ptr IHTMLSelectionObject, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_type(self, p)
proc put_selected*(self: ptr IHTMLOptionElement, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_selected(self, v)
proc get_selected*(self: ptr IHTMLOptionElement, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_selected(self, p)
proc put_value*(self: ptr IHTMLOptionElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_value(self, v)
proc get_value*(self: ptr IHTMLOptionElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_value(self, p)
proc put_defaultSelected*(self: ptr IHTMLOptionElement, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_defaultSelected(self, v)
proc get_defaultSelected*(self: ptr IHTMLOptionElement, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_defaultSelected(self, p)
proc put_index*(self: ptr IHTMLOptionElement, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_index(self, v)
proc get_index*(self: ptr IHTMLOptionElement, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_index(self, p)
proc put_text*(self: ptr IHTMLOptionElement, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_text(self, v)
proc get_text*(self: ptr IHTMLOptionElement, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_text(self, p)
proc get_form*(self: ptr IHTMLOptionElement, p: ptr ptr IHTMLFormElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_form(self, p)
proc create*(self: ptr IHTMLOptionElementFactory, text: VARIANT, value: VARIANT, defaultselected: VARIANT, selected: VARIANT, a: ptr ptr IHTMLOptionElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.create(self, text, value, defaultselected, selected, a)
proc get_length*(self: ptr IOmHistory, p: ptr int16): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc back*(self: ptr IOmHistory, pvargdistance: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.back(self, pvargdistance)
proc forward*(self: ptr IOmHistory, pvargdistance: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.forward(self, pvargdistance)
proc go*(self: ptr IOmHistory, pvargdistance: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.go(self, pvargdistance)
proc get_length*(self: ptr IHTMLMimeTypesCollection, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc get_length*(self: ptr IHTMLPluginsCollection, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc refresh*(self: ptr IHTMLPluginsCollection, reload: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.refresh(self, reload)
proc addRequest*(self: ptr IHTMLOpsProfile, name: BSTR, reserved: VARIANT, success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.addRequest(self, name, reserved, success)
proc clearRequest*(self: ptr IHTMLOpsProfile): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.clearRequest(self)
proc doRequest*(self: ptr IHTMLOpsProfile, usage: VARIANT, fname: VARIANT, domain: VARIANT, path: VARIANT, expire: VARIANT, reserved: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.doRequest(self, usage, fname, domain, path, expire, reserved)
proc getAttribute*(self: ptr IHTMLOpsProfile, name: BSTR, value: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.getAttribute(self, name, value)
proc setAttribute*(self: ptr IHTMLOpsProfile, name: BSTR, value: BSTR, prefs: VARIANT, success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setAttribute(self, name, value, prefs, success)
proc commitChanges*(self: ptr IHTMLOpsProfile, success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.commitChanges(self, success)
proc addReadRequest*(self: ptr IHTMLOpsProfile, name: BSTR, reserved: VARIANT, success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.addReadRequest(self, name, reserved, success)
proc doReadRequest*(self: ptr IHTMLOpsProfile, usage: VARIANT, fname: VARIANT, domain: VARIANT, path: VARIANT, expire: VARIANT, reserved: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.doReadRequest(self, usage, fname, domain, path, expire, reserved)
proc doWriteRequest*(self: ptr IHTMLOpsProfile, success: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.doWriteRequest(self, success)
proc get_appCodeName*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_appCodeName(self, p)
proc get_appName*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_appName(self, p)
proc get_appVersion*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_appVersion(self, p)
proc get_userAgent*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_userAgent(self, p)
proc javaEnabled*(self: ptr IOmNavigator, enabled: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.javaEnabled(self, enabled)
proc taintEnabled*(self: ptr IOmNavigator, enabled: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.taintEnabled(self, enabled)
proc get_mimeTypes*(self: ptr IOmNavigator, p: ptr ptr IHTMLMimeTypesCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_mimeTypes(self, p)
proc get_plugins*(self: ptr IOmNavigator, p: ptr ptr IHTMLPluginsCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_plugins(self, p)
proc get_cookieEnabled*(self: ptr IOmNavigator, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cookieEnabled(self, p)
proc get_opsProfile*(self: ptr IOmNavigator, p: ptr ptr IHTMLOpsProfile): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_opsProfile(self, p)
proc toString*(self: ptr IOmNavigator, string: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, string)
proc get_cpuClass*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cpuClass(self, p)
proc get_systemLanguage*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_systemLanguage(self, p)
proc get_browserLanguage*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_browserLanguage(self, p)
proc get_userLanguage*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_userLanguage(self, p)
proc get_platform*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_platform(self, p)
proc get_appMinorVersion*(self: ptr IOmNavigator, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_appMinorVersion(self, p)
proc get_connectionSpeed*(self: ptr IOmNavigator, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_connectionSpeed(self, p)
proc get_onLine*(self: ptr IOmNavigator, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onLine(self, p)
proc get_userProfile*(self: ptr IOmNavigator, p: ptr ptr IHTMLOpsProfile): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_userProfile(self, p)
proc put_href*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_href(self, v)
proc get_href*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_href(self, p)
proc put_protocol*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_protocol(self, v)
proc get_protocol*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_protocol(self, p)
proc put_host*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_host(self, v)
proc get_host*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_host(self, p)
proc put_hostname*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_hostname(self, v)
proc get_hostname*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_hostname(self, p)
proc put_port*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_port(self, v)
proc get_port*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_port(self, p)
proc put_pathname*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_pathname(self, v)
proc get_pathname*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_pathname(self, p)
proc put_search*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_search(self, v)
proc get_search*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_search(self, p)
proc put_hash*(self: ptr IHTMLLocation, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_hash(self, v)
proc get_hash*(self: ptr IHTMLLocation, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_hash(self, p)
proc reload*(self: ptr IHTMLLocation, flag: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.reload(self, flag)
proc replace*(self: ptr IHTMLLocation, bstr: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.replace(self, bstr)
proc assign*(self: ptr IHTMLLocation, bstr: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.assign(self, bstr)
proc toString*(self: ptr IHTMLLocation, string: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, string)
proc get_srcElement*(self: ptr IHTMLEventObj, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_srcElement(self, p)
proc get_altKey*(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_altKey(self, p)
proc get_ctrlKey*(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ctrlKey(self, p)
proc get_shiftKey*(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_shiftKey(self, p)
proc put_returnValue*(self: ptr IHTMLEventObj, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_returnValue(self, v)
proc get_returnValue*(self: ptr IHTMLEventObj, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_returnValue(self, p)
proc put_cancelBubble*(self: ptr IHTMLEventObj, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cancelBubble(self, v)
proc get_cancelBubble*(self: ptr IHTMLEventObj, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cancelBubble(self, p)
proc get_fromElement*(self: ptr IHTMLEventObj, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fromElement(self, p)
proc get_toElement*(self: ptr IHTMLEventObj, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_toElement(self, p)
proc put_keyCode*(self: ptr IHTMLEventObj, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_keyCode(self, v)
proc get_keyCode*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_keyCode(self, p)
proc get_button*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_button(self, p)
proc get_type*(self: ptr IHTMLEventObj, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_type(self, p)
proc get_qualifier*(self: ptr IHTMLEventObj, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_qualifier(self, p)
proc get_reason*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_reason(self, p)
proc get_x*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_x(self, p)
proc get_y*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_y(self, p)
proc get_clientX*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clientX(self, p)
proc get_clientY*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clientY(self, p)
proc get_offsetX*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetX(self, p)
proc get_offsetY*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offsetY(self, p)
proc get_screenX*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_screenX(self, p)
proc get_screenY*(self: ptr IHTMLEventObj, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_screenY(self, p)
proc get_srcFilter*(self: ptr IHTMLEventObj, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_srcFilter(self, p)
proc item*(self: ptr IHTMLFramesCollection2, pvarIndex: ptr VARIANT, pvarResult: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.item(self, pvarIndex, pvarResult)
proc get_length*(self: ptr IHTMLFramesCollection2, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_length(self, p)
proc get_colorDepth*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_colorDepth(self, p)
proc put_bufferDepth*(self: ptr IHTMLScreen, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_bufferDepth(self, v)
proc get_bufferDepth*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_bufferDepth(self, p)
proc get_width*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_width(self, p)
proc get_height*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_height(self, p)
proc put_updateInterval*(self: ptr IHTMLScreen, v: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_updateInterval(self, v)
proc get_updateInterval*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_updateInterval(self, p)
proc get_availHeight*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_availHeight(self, p)
proc get_availWidth*(self: ptr IHTMLScreen, p: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_availWidth(self, p)
proc get_fontSmoothingEnabled*(self: ptr IHTMLScreen, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fontSmoothingEnabled(self, p)
proc get_frames*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLFramesCollection2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_frames(self, p)
proc put_defaultStatus*(self: ptr IHTMLWindow2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_defaultStatus(self, v)
proc get_defaultStatus*(self: ptr IHTMLWindow2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_defaultStatus(self, p)
proc put_status*(self: ptr IHTMLWindow2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_status(self, v)
proc get_status*(self: ptr IHTMLWindow2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_status(self, p)
proc setTimeout*(self: ptr IHTMLWindow2, expression: BSTR, msec: LONG, language: ptr VARIANT, timerID: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setTimeout(self, expression, msec, language, timerID)
proc clearTimeout*(self: ptr IHTMLWindow2, timerID: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.clearTimeout(self, timerID)
proc alert*(self: ptr IHTMLWindow2, message: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.alert(self, message)
proc confirm*(self: ptr IHTMLWindow2, message: BSTR, confirmed: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.confirm(self, message, confirmed)
proc prompt*(self: ptr IHTMLWindow2, message: BSTR, defstr: BSTR, textdata: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.prompt(self, message, defstr, textdata)
proc get_Image*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLImageElementFactory): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Image(self, p)
proc get_location*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLLocation): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_location(self, p)
proc get_history*(self: ptr IHTMLWindow2, p: ptr ptr IOmHistory): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_history(self, p)
proc close*(self: ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.close(self)
proc put_opener*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_opener(self, v)
proc get_opener*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_opener(self, p)
proc get_navigator*(self: ptr IHTMLWindow2, p: ptr ptr IOmNavigator): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_navigator(self, p)
proc put_name*(self: ptr IHTMLWindow2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_name(self, v)
proc get_name*(self: ptr IHTMLWindow2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_name(self, p)
proc get_parent*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_parent(self, p)
proc open*(self: ptr IHTMLWindow2, url: BSTR, name: BSTR, features: BSTR, replace: VARIANT_BOOL, pomWindowResult: ptr ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.open(self, url, name, features, replace, pomWindowResult)
proc get_self*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_self(self, p)
proc get_top*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_top(self, p)
proc get_window*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_window(self, p)
proc navigate*(self: ptr IHTMLWindow2, url: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.navigate(self, url)
proc put_onfocus*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onfocus(self, v)
proc get_onfocus*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onfocus(self, p)
proc put_onblur*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onblur(self, v)
proc get_onblur*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onblur(self, p)
proc put_onload*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onload(self, v)
proc get_onload*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onload(self, p)
proc put_onbeforeunload*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onbeforeunload(self, v)
proc get_onbeforeunload*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onbeforeunload(self, p)
proc put_onunload*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onunload(self, v)
proc get_onunload*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onunload(self, p)
proc put_onhelp*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onhelp(self, v)
proc get_onhelp*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onhelp(self, p)
proc put_onerror*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onerror(self, v)
proc get_onerror*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onerror(self, p)
proc put_onresize*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onresize(self, v)
proc get_onresize*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onresize(self, p)
proc put_onscroll*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onscroll(self, v)
proc get_onscroll*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onscroll(self, p)
proc get_document*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLDocument2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_document(self, p)
proc get_event*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLEventObj): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_event(self, p)
proc get_newEnum*(self: ptr IHTMLWindow2, p: ptr ptr IUnknown): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_newEnum(self, p)
proc showModalDialog*(self: ptr IHTMLWindow2, dialog: BSTR, varArgIn: ptr VARIANT, varOptions: ptr VARIANT, varArgOut: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.showModalDialog(self, dialog, varArgIn, varOptions, varArgOut)
proc showHelp*(self: ptr IHTMLWindow2, helpURL: BSTR, helpArg: VARIANT, features: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.showHelp(self, helpURL, helpArg, features)
proc get_screen*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLScreen): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_screen(self, p)
proc get_Option*(self: ptr IHTMLWindow2, p: ptr ptr IHTMLOptionElementFactory): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Option(self, p)
proc focus*(self: ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.focus(self)
proc get_closed*(self: ptr IHTMLWindow2, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_closed(self, p)
proc blur*(self: ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.blur(self)
proc scroll*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.scroll(self, x, y)
proc get_clientInformation*(self: ptr IHTMLWindow2, p: ptr ptr IOmNavigator): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_clientInformation(self, p)
proc setInterval*(self: ptr IHTMLWindow2, expression: BSTR, msec: LONG, language: ptr VARIANT, timerID: ptr LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.setInterval(self, expression, msec, language, timerID)
proc clearInterval*(self: ptr IHTMLWindow2, timerID: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.clearInterval(self, timerID)
proc put_offscreenBuffering*(self: ptr IHTMLWindow2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_offscreenBuffering(self, v)
proc get_offscreenBuffering*(self: ptr IHTMLWindow2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_offscreenBuffering(self, p)
proc execScript*(self: ptr IHTMLWindow2, code: BSTR, language: BSTR, pvarRet: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.execScript(self, code, language, pvarRet)
proc toString*(self: ptr IHTMLWindow2, String: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, String)
proc scrollBy*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.scrollBy(self, x, y)
proc scrollTo*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.scrollTo(self, x, y)
proc moveTo*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveTo(self, x, y)
proc moveBy*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.moveBy(self, x, y)
proc resizeTo*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.resizeTo(self, x, y)
proc resizeBy*(self: ptr IHTMLWindow2, x: LONG, y: LONG): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.resizeBy(self, x, y)
proc get_external*(self: ptr IHTMLWindow2, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_external(self, p)
proc get_Script*(self: ptr IHTMLDocument, p: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_Script(self, p)
proc get_all*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_all(self, p)
proc get_body*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_body(self, p)
proc get_activeElement*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_activeElement(self, p)
proc get_images*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_images(self, p)
proc get_applets*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_applets(self, p)
proc get_links*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_links(self, p)
proc get_forms*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_forms(self, p)
proc get_anchors*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_anchors(self, p)
proc put_title*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_title(self, v)
proc get_title*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_title(self, p)
proc get_scripts*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_scripts(self, p)
proc put_designMode*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_designMode(self, v)
proc get_designMode*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_designMode(self, p)
proc get_selection*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLSelectionObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_selection(self, p)
proc get_readyState*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_readyState(self, p)
proc get_frames*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLFramesCollection2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_frames(self, p)
proc get_embeds*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_embeds(self, p)
proc get_plugins*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLElementCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_plugins(self, p)
proc put_alinkColor*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_alinkColor(self, v)
proc get_alinkColor*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_alinkColor(self, p)
proc put_bgColor*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_bgColor(self, v)
proc get_bgColor*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_bgColor(self, p)
proc put_fgColor*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_fgColor(self, v)
proc get_fgColor*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fgColor(self, p)
proc put_linkColor*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_linkColor(self, v)
proc get_linkColor*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_linkColor(self, p)
proc put_vlinkColor*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_vlinkColor(self, v)
proc get_vlinkColor*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_vlinkColor(self, p)
proc get_referrer*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_referrer(self, p)
proc get_location*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLLocation): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_location(self, p)
proc get_lastModified*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_lastModified(self, p)
proc put_URL*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_URL(self, v)
proc get_URL*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_URL(self, p)
proc put_domain*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_domain(self, v)
proc get_domain*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_domain(self, p)
proc put_cookie*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_cookie(self, v)
proc get_cookie*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_cookie(self, p)
proc put_expando*(self: ptr IHTMLDocument2, v: VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_expando(self, v)
proc get_expando*(self: ptr IHTMLDocument2, p: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_expando(self, p)
proc put_charset*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_charset(self, v)
proc get_charset*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_charset(self, p)
proc put_defaultCharset*(self: ptr IHTMLDocument2, v: BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_defaultCharset(self, v)
proc get_defaultCharset*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_defaultCharset(self, p)
proc get_mimeType*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_mimeType(self, p)
proc get_fileSize*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileSize(self, p)
proc get_fileCreatedDate*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileCreatedDate(self, p)
proc get_fileModifiedDate*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileModifiedDate(self, p)
proc get_fileUpdatedDate*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_fileUpdatedDate(self, p)
proc get_security*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_security(self, p)
proc get_protocol*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_protocol(self, p)
proc get_nameProp*(self: ptr IHTMLDocument2, p: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_nameProp(self, p)
proc write*(self: ptr IHTMLDocument2, psarray: ptr SAFEARRAY): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.write(self, psarray)
proc writeln*(self: ptr IHTMLDocument2, psarray: ptr SAFEARRAY): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.writeln(self, psarray)
proc open*(self: ptr IHTMLDocument2, url: BSTR, name: VARIANT, features: VARIANT, replace: VARIANT, pomWindowResult: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.open(self, url, name, features, replace, pomWindowResult)
proc close*(self: ptr IHTMLDocument2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.close(self)
proc clear*(self: ptr IHTMLDocument2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.clear(self)
proc queryCommandSupported*(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandSupported(self, cmdID, pfRet)
proc queryCommandEnabled*(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandEnabled(self, cmdID, pfRet)
proc queryCommandState*(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandState(self, cmdID, pfRet)
proc queryCommandIndeterm*(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandIndeterm(self, cmdID, pfRet)
proc queryCommandText*(self: ptr IHTMLDocument2, cmdID: BSTR, pcmdText: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandText(self, cmdID, pcmdText)
proc queryCommandValue*(self: ptr IHTMLDocument2, cmdID: BSTR, pcmdValue: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.queryCommandValue(self, cmdID, pcmdValue)
proc execCommand*(self: ptr IHTMLDocument2, cmdID: BSTR, showUI: VARIANT_BOOL, value: VARIANT, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.execCommand(self, cmdID, showUI, value, pfRet)
proc execCommandShowHelp*(self: ptr IHTMLDocument2, cmdID: BSTR, pfRet: ptr VARIANT_BOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.execCommandShowHelp(self, cmdID, pfRet)
proc createElement*(self: ptr IHTMLDocument2, eTag: BSTR, newElem: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.createElement(self, eTag, newElem)
proc put_onhelp*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onhelp(self, v)
proc get_onhelp*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onhelp(self, p)
proc put_onclick*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onclick(self, v)
proc get_onclick*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onclick(self, p)
proc put_ondblclick*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondblclick(self, v)
proc get_ondblclick*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondblclick(self, p)
proc put_onkeyup*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onkeyup(self, v)
proc get_onkeyup*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onkeyup(self, p)
proc put_onkeydown*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onkeydown(self, v)
proc get_onkeydown*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onkeydown(self, p)
proc put_onkeypress*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onkeypress(self, v)
proc get_onkeypress*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onkeypress(self, p)
proc put_onmouseup*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmouseup(self, v)
proc get_onmouseup*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmouseup(self, p)
proc put_onmousedown*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmousedown(self, v)
proc get_onmousedown*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmousedown(self, p)
proc put_onmousemove*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmousemove(self, v)
proc get_onmousemove*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmousemove(self, p)
proc put_onmouseout*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmouseout(self, v)
proc get_onmouseout*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmouseout(self, p)
proc put_onmouseover*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onmouseover(self, v)
proc get_onmouseover*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onmouseover(self, p)
proc put_onreadystatechange*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onreadystatechange(self, v)
proc get_onreadystatechange*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onreadystatechange(self, p)
proc put_onafterupdate*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onafterupdate(self, v)
proc get_onafterupdate*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onafterupdate(self, p)
proc put_onrowexit*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onrowexit(self, v)
proc get_onrowexit*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onrowexit(self, p)
proc put_onrowenter*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onrowenter(self, v)
proc get_onrowenter*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onrowenter(self, p)
proc put_ondragstart*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_ondragstart(self, v)
proc get_ondragstart*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_ondragstart(self, p)
proc put_onselectstart*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onselectstart(self, v)
proc get_onselectstart*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onselectstart(self, p)
proc elementFromPoint*(self: ptr IHTMLDocument2, x: LONG, y: LONG, elementHit: ptr ptr IHTMLElement): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.elementFromPoint(self, x, y, elementHit)
proc get_parentWindow*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLWindow2): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_parentWindow(self, p)
proc get_styleSheets*(self: ptr IHTMLDocument2, p: ptr ptr IHTMLStyleSheetsCollection): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_styleSheets(self, p)
proc put_onbeforeupdate*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onbeforeupdate(self, v)
proc get_onbeforeupdate*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onbeforeupdate(self, p)
proc put_onerrorupdate*(self: ptr IHTMLDocument2, v: VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.put_onerrorupdate(self, v)
proc get_onerrorupdate*(self: ptr IHTMLDocument2, p: ptr VARIANT): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.get_onerrorupdate(self, p)
proc toString*(self: ptr IHTMLDocument2, String: ptr BSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.toString(self, String)
proc createStyleSheet*(self: ptr IHTMLDocument2, bstrHref: BSTR, lIndex: LONG, ppnewStyleSheet: ptr ptr IHTMLStyleSheet): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.createStyleSheet(self, bstrHref, lIndex, ppnewStyleSheet)
proc ShowContextMenu*(self: ptr IDocHostUIHandler, dwID: DWORD, ppt: ptr POINT, pcmdtReserved: ptr IUnknown, pdispReserved: ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ShowContextMenu(self, dwID, ppt, pcmdtReserved, pdispReserved)
proc GetHostInfo*(self: ptr IDocHostUIHandler, pInfo: ptr DOCHOSTUIINFO): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetHostInfo(self, pInfo)
proc ShowUI*(self: ptr IDocHostUIHandler, dwID: DWORD, pActiveObject: ptr IOleInPlaceActiveObject, pCommandTarget: ptr IOleCommandTarget, pFrame: ptr IOleInPlaceFrame, pDoc: ptr IOleInPlaceUIWindow): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ShowUI(self, dwID, pActiveObject, pCommandTarget, pFrame, pDoc)
proc HideUI*(self: ptr IDocHostUIHandler): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.HideUI(self)
proc UpdateUI*(self: ptr IDocHostUIHandler): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.UpdateUI(self)
proc EnableModeless*(self: ptr IDocHostUIHandler, fEnable: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.EnableModeless(self, fEnable)
proc OnDocWindowActivate*(self: ptr IDocHostUIHandler, fActivate: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnDocWindowActivate(self, fActivate)
proc OnFrameWindowActivate*(self: ptr IDocHostUIHandler, fActivate: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.OnFrameWindowActivate(self, fActivate)
proc ResizeBorder*(self: ptr IDocHostUIHandler, prcBorder: LPCRECT, pUIWindow: ptr IOleInPlaceUIWindow, fRameWindow: WINBOOL): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.ResizeBorder(self, prcBorder, pUIWindow, fRameWindow)
proc TranslateAccelerator*(self: ptr IDocHostUIHandler, lpMsg: LPMSG, pguidCmdGroup: ptr GUID, nCmdID: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.TranslateAccelerator(self, lpMsg, pguidCmdGroup, nCmdID)
proc GetOptionKeyPath*(self: ptr IDocHostUIHandler, pchKey: ptr LPOLESTR, dw: DWORD): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetOptionKeyPath(self, pchKey, dw)
proc GetDropTarget*(self: ptr IDocHostUIHandler, pDropTarget: ptr IDropTarget, ppDropTarget: ptr ptr IDropTarget): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetDropTarget(self, pDropTarget, ppDropTarget)
proc GetExternal*(self: ptr IDocHostUIHandler, ppDispatch: ptr ptr IDispatch): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.GetExternal(self, ppDispatch)
proc TranslateUrl*(self: ptr IDocHostUIHandler, dwTranslate: DWORD, pchURLIn: LPWSTR, ppchURLOut: ptr LPWSTR): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.TranslateUrl(self, dwTranslate, pchURLIn, ppchURLOut)
proc FilterDataObject*(self: ptr IDocHostUIHandler, pDO: ptr IDataObject, ppDORet: ptr ptr IDataObject): HRESULT {.winapi, inline.} = {.gcsafe.}: self.lpVtbl.FilterDataObject(self, pDO, ppDORet)
converter winimConverterIHTMLFiltersCollectionToIDispatch*(x: ptr IHTMLFiltersCollection): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLFiltersCollectionToIUnknown*(x: ptr IHTMLFiltersCollection): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLStyleToIDispatch*(x: ptr IHTMLStyle): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLStyleToIUnknown*(x: ptr IHTMLStyle): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLRuleStyleToIDispatch*(x: ptr IHTMLRuleStyle): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLRuleStyleToIUnknown*(x: ptr IHTMLRuleStyle): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLElementToIDispatch*(x: ptr IHTMLElement): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLElementToIUnknown*(x: ptr IHTMLElement): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLStyleSheetRuleToIDispatch*(x: ptr IHTMLStyleSheetRule): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLStyleSheetRuleToIUnknown*(x: ptr IHTMLStyleSheetRule): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLStyleSheetRulesCollectionToIDispatch*(x: ptr IHTMLStyleSheetRulesCollection): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLStyleSheetRulesCollectionToIUnknown*(x: ptr IHTMLStyleSheetRulesCollection): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLStyleSheetToIDispatch*(x: ptr IHTMLStyleSheet): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLStyleSheetToIUnknown*(x: ptr IHTMLStyleSheet): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLStyleSheetsCollectionToIDispatch*(x: ptr IHTMLStyleSheetsCollection): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLStyleSheetsCollectionToIUnknown*(x: ptr IHTMLStyleSheetsCollection): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLTxtRangeToIDispatch*(x: ptr IHTMLTxtRange): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLTxtRangeToIUnknown*(x: ptr IHTMLTxtRange): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLFormElementToIDispatch*(x: ptr IHTMLFormElement): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLFormElementToIUnknown*(x: ptr IHTMLFormElement): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLImgElementToIDispatch*(x: ptr IHTMLImgElement): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLImgElementToIUnknown*(x: ptr IHTMLImgElement): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLImageElementFactoryToIDispatch*(x: ptr IHTMLImageElementFactory): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLImageElementFactoryToIUnknown*(x: ptr IHTMLImageElementFactory): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLElementCollectionToIDispatch*(x: ptr IHTMLElementCollection): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLElementCollectionToIUnknown*(x: ptr IHTMLElementCollection): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLSelectionObjectToIDispatch*(x: ptr IHTMLSelectionObject): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLSelectionObjectToIUnknown*(x: ptr IHTMLSelectionObject): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLOptionElementToIDispatch*(x: ptr IHTMLOptionElement): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLOptionElementToIUnknown*(x: ptr IHTMLOptionElement): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLOptionElementFactoryToIDispatch*(x: ptr IHTMLOptionElementFactory): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLOptionElementFactoryToIUnknown*(x: ptr IHTMLOptionElementFactory): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOmHistoryToIDispatch*(x: ptr IOmHistory): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIOmHistoryToIUnknown*(x: ptr IOmHistory): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLMimeTypesCollectionToIDispatch*(x: ptr IHTMLMimeTypesCollection): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLMimeTypesCollectionToIUnknown*(x: ptr IHTMLMimeTypesCollection): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLPluginsCollectionToIDispatch*(x: ptr IHTMLPluginsCollection): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLPluginsCollectionToIUnknown*(x: ptr IHTMLPluginsCollection): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLOpsProfileToIDispatch*(x: ptr IHTMLOpsProfile): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLOpsProfileToIUnknown*(x: ptr IHTMLOpsProfile): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIOmNavigatorToIDispatch*(x: ptr IOmNavigator): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIOmNavigatorToIUnknown*(x: ptr IOmNavigator): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLLocationToIDispatch*(x: ptr IHTMLLocation): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLLocationToIUnknown*(x: ptr IHTMLLocation): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLEventObjToIDispatch*(x: ptr IHTMLEventObj): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLEventObjToIUnknown*(x: ptr IHTMLEventObj): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLFramesCollection2ToIDispatch*(x: ptr IHTMLFramesCollection2): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLFramesCollection2ToIUnknown*(x: ptr IHTMLFramesCollection2): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLScreenToIDispatch*(x: ptr IHTMLScreen): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLScreenToIUnknown*(x: ptr IHTMLScreen): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLWindow2ToIHTMLFramesCollection2*(x: ptr IHTMLWindow2): ptr IHTMLFramesCollection2 = cast[ptr IHTMLFramesCollection2](x)
converter winimConverterIHTMLWindow2ToIDispatch*(x: ptr IHTMLWindow2): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLWindow2ToIUnknown*(x: ptr IHTMLWindow2): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLDocumentToIDispatch*(x: ptr IHTMLDocument): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLDocumentToIUnknown*(x: ptr IHTMLDocument): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIHTMLDocument2ToIHTMLDocument*(x: ptr IHTMLDocument2): ptr IHTMLDocument = cast[ptr IHTMLDocument](x)
converter winimConverterIHTMLDocument2ToIDispatch*(x: ptr IHTMLDocument2): ptr IDispatch = cast[ptr IDispatch](x)
converter winimConverterIHTMLDocument2ToIUnknown*(x: ptr IHTMLDocument2): ptr IUnknown = cast[ptr IUnknown](x)
converter winimConverterIDocHostUIHandlerToIUnknown*(x: ptr IDocHostUIHandler): ptr IUnknown = cast[ptr IUnknown](x)
const
  unknown* = 0
  requestSize* = 0
type
  PRINTER_INFO_1A* {.pure.} = object
    Flags*: DWORD
    pDescription*: LPSTR
    pName*: LPSTR
    pComment*: LPSTR
  PRINTER_INFO_1W* {.pure.} = object
    Flags*: DWORD
    pDescription*: LPWSTR
    pName*: LPWSTR
    pComment*: LPWSTR
  PRINTER_DEFAULTSA* {.pure.} = object
    pDatatype*: LPSTR
    pDevMode*: LPDEVMODEA
    DesiredAccess*: ACCESS_MASK
  LPPRINTER_DEFAULTSA* = ptr PRINTER_DEFAULTSA
  PRINTER_DEFAULTSW* {.pure.} = object
    pDatatype*: LPWSTR
    pDevMode*: LPDEVMODEW
    DesiredAccess*: ACCESS_MASK
  LPPRINTER_DEFAULTSW* = ptr PRINTER_DEFAULTSW
const
  PRINTER_ENUM_LOCAL* = 0x00000002
  PRINTER_ENUM_CONNECTIONS* = 0x00000004
proc ClosePrinter*(hPrinter: HANDLE): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc.}
when winimUnicode:
  type
    PRINTER_INFO_1* = PRINTER_INFO_1W
  proc EnumPrinters*(Flags: DWORD, Name: LPWSTR, Level: DWORD, pPrinterEnum: LPBYTE, cbBuf: DWORD, pcbNeeded: LPDWORD, pcReturned: LPDWORD): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "EnumPrintersW".}
  proc OpenPrinter*(pPrinterName: LPWSTR, phPrinter: LPHANDLE, pDefault: LPPRINTER_DEFAULTSW): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "OpenPrinterW".}
  proc DocumentProperties*(hWnd: HWND, hPrinter: HANDLE, pDeviceName: LPWSTR, pDevModeOutput: PDEVMODEW, pDevModeInput: PDEVMODEW, fMode: DWORD): LONG {.winapi, stdcall, dynlib: "winspool.drv", importc: "DocumentPropertiesW".}
  proc GetDefaultPrinter*(pszBuffer: LPWSTR, pcchBuffer: LPDWORD): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "GetDefaultPrinterW".}
  proc SetDefaultPrinter*(pszPrinter: LPCWSTR): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "SetDefaultPrinterW".}
when winimAnsi:
  type
    PRINTER_INFO_1* = PRINTER_INFO_1A
  proc EnumPrinters*(Flags: DWORD, Name: LPSTR, Level: DWORD, pPrinterEnum: LPBYTE, cbBuf: DWORD, pcbNeeded: LPDWORD, pcReturned: LPDWORD): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "EnumPrintersA".}
  proc OpenPrinter*(pPrinterName: LPSTR, phPrinter: LPHANDLE, pDefault: LPPRINTER_DEFAULTSA): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "OpenPrinterA".}
  proc DocumentProperties*(hWnd: HWND, hPrinter: HANDLE, pDeviceName: LPSTR, pDevModeOutput: PDEVMODEA, pDevModeInput: PDEVMODEA, fMode: DWORD): LONG {.winapi, stdcall, dynlib: "winspool.drv", importc: "DocumentPropertiesA".}
  proc GetDefaultPrinter*(pszBuffer: LPSTR, pcchBuffer: LPDWORD): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "GetDefaultPrinterA".}
  proc SetDefaultPrinter*(pszPrinter: LPCSTR): WINBOOL {.winapi, stdcall, dynlib: "winspool.drv", importc: "SetDefaultPrinterA".}
const
  BP_CHECKBOX* = 3
  CBS_UNCHECKEDNORMAL* = 1
  CBS_UNCHECKEDHOT* = 2
  CBS_UNCHECKEDDISABLED* = 4
  CBS_CHECKEDNORMAL* = 5
  CBS_CHECKEDHOT* = 6
  CBS_CHECKEDDISABLED* = 8
  CP_DROPDOWNBUTTON* = 1
  CP_BORDER* = 4
  CP_READONLY* = 5
  CP_DROPDOWNBUTTONRIGHT* = 6
  CBRO_NORMAL* = 1
  CBRO_HOT* = 2
  CBRO_PRESSED* = 3
  CBRO_DISABLED* = 4
  TABP_BODY* = 10
type
  THEMESIZE* = int32
const
  TS_DRAW* = 2
proc OpenThemeData*(hwnd: HWND, pszClassList: LPCWSTR): HTHEME {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc CloseThemeData*(hTheme: HTHEME): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc DrawThemeBackground*(hTheme: HTHEME, hdc: HDC, iPartId: int32, iStateId: int32, pRect: ptr RECT, pClipRect: ptr RECT): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc DrawThemeText*(hTheme: HTHEME, hdc: HDC, iPartId: int32, iStateId: int32, pszText: LPCWSTR, iCharCount: int32, dwTextFlags: DWORD, dwTextFlags2: DWORD, pRect: ptr RECT): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc GetThemePartSize*(hTheme: HTHEME, hdc: HDC, iPartId: int32, iStateId: int32, prc: ptr RECT, eSize: THEMESIZE, psz: ptr SIZE): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc SetWindowTheme*(hwnd: HWND, pszSubAppName: LPCWSTR, pszSubIdList: LPCWSTR): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc GetThemeSysColor*(hTheme: HTHEME, iColorId: int32): COLORREF {.winapi, stdcall, dynlib: "uxtheme", importc.}
proc DrawThemeParentBackground*(hwnd: HWND, hdc: HDC, prc: ptr RECT): HRESULT {.winapi, stdcall, dynlib: "uxtheme", importc.}
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
  pixelFormatIndexed* = INT 0x00010000
  pixelFormatGDI* = INT 0x00020000
  pixelFormatAlpha* = INT 0x00040000
  pixelFormatPAlpha* = INT 0x00080000
  pixelFormatExtended* = INT 0x00100000
  pixelFormatCanonical* = INT 0x00200000
  pixelFormat1bppIndexed* = INT(1 or (1 shl 8) or pixelFormatIndexed or pixelFormatGDI)
  pixelFormat4bppIndexed* = INT(2 or (4 shl 8) or pixelFormatIndexed or pixelFormatGDI)
  pixelFormat8bppIndexed* = INT(3 or (8 shl 8) or pixelFormatIndexed or pixelFormatGDI)
  pixelFormat16bppGrayScale* = INT(4 or (16 shl 8) or pixelFormatExtended)
  pixelFormat16bppRGB555* = INT(5 or (16 shl 8) or pixelFormatGDI)
  pixelFormat16bppRGB565* = INT(6 or (16 shl 8) or pixelFormatGDI)
  pixelFormat16bppARGB1555* = INT(7 or (16 shl 8) or pixelFormatAlpha or pixelFormatGDI)
  pixelFormat24bppRGB* = INT(8 or (24 shl 8) or pixelFormatGDI)
  pixelFormat32bppRGB* = INT(9 or (32 shl 8) or pixelFormatGDI)
  pixelFormat32bppARGB* = INT(10 or (32 shl 8) or pixelFormatAlpha or pixelFormatGDI or pixelFormatCanonical)
  pixelFormat32bppPARGB* = INT(11 or (32 shl 8) or pixelFormatAlpha or pixelFormatPAlpha or pixelFormatGDI)
  pixelFormat48bppRGB* = INT(12 or (48 shl 8) or pixelFormatExtended)
  pixelFormat64bppARGB* = INT(13 or (64 shl 8) or pixelFormatAlpha or pixelFormatCanonical or pixelFormatExtended)
  pixelFormat64bppPARGB* = INT(14 or (64 shl 8) or pixelFormatAlpha or pixelFormatPAlpha or pixelFormatExtended)
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
