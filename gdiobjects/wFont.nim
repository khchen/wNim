## A font is an object which determines the appearance of text.
##
## :Superclass:
##    wGdiObject
## :Consts:
##    ==============================  =============================================================
##    Font Family                     Description
##    ==============================  =============================================================
##    wFontFamilyDefault              FF_DONTCARE
##    wFontFamilyRoman                FF_ROMAN
##    wFontFamilySwiss                FF_SWISS
##    wFontFamilyModern               FF_MODERN
##    wFontFamilyScript               FF_SCRIPT
##    wFontFamilyDecorative           FF_DECORATIVE
##    ==============================  =============================================================
##
##    ==============================  =============================================================
##    Font Weight                     Description
##    ==============================  =============================================================
##    wFontWeightThin                 FW_THIN
##    wFontWeightExtralight           FW_EXTRALIGHT
##    wFontWeightLight                FW_LIGHT
##    wFontWeightNormal               FW_NORMAL
##    wFontWeightMedium               FW_MEDIUM
##    wFontWeightSemiBold             FW_SEMIBOLD
##    wFontWeightBold                 FW_BOLD
##    wFontWeightExtraBold            FW_EXTRABOLD
##    wFontWeightHeavy                FW_HEAVY
##    ==============================  =============================================================
##
##    ==============================  =============================================================
##    Font Weight                     Description
##    ==============================  =============================================================
##    wFontWeightThin                 FW_THIN
##    wFontWeightExtralight           FW_EXTRALIGHT
##    wFontWeightLight                FW_LIGHT
##    wFontWeightNormal               FW_NORMAL
##    wFontWeightMedium               FW_MEDIUM
##    wFontWeightSemiBold             FW_SEMIBOLD
##    wFontWeightBold                 FW_BOLD
##    wFontWeightExtraBold            FW_EXTRABOLD
##    wFontWeightHeavy                FW_HEAVY
##    ==============================  =============================================================
##
##    ==============================  =============================================================
##    Font Encoding                   Description
##    ==============================  =============================================================
##    wFontEncodingDefault            DEFAULT_CHARSET
##    wFontEncodingSystem             DEFAULT_CHARSET
##    wFontEncodingCp1252             ANSI_CHARSET
##    wFontEncodingCp932              SHIFTJIS_CHARSET
##    wFontEncodingCp1361             JOHAB_CHARSET
##    wFontEncodingCp936              GB2312_CHARSET
##    wFontEncodingCp949              HANGUL_CHARSET
##    wFontEncodingCp950              CHINESEBIG5_CHARSET
##    wFontEncodingCp1250             EASTEUROPE_CHARSET
##    wFontEncodingCp1251             RUSSIAN_CHARSET
##    wFontEncodingCp1253             GREEK_CHARSET
##    wFontEncodingCp1254             HEBREW_CHARSET
##    wFontEncodingCp1255             ARABIC_CHARSET
##    wFontEncodingCp1257             BALTIC_CHARSET
##    wFontEncodingCp1258             VIETNAMESE_CHARSET
##    wFontEncodingCp874              THAI_CHARSET
##    wFontEncodingCp437              OEM_CHARSET
##    wFontEncodingCp850              OEM_CHARSET
##    ==============================  =============================================================

type
  wFontError* = object of wGdiObjectError
    ## An error raised when wFont creation failure.

const
  # font family
  wFontFamilyDefault* = FF_DONTCARE
  wFontFamilyRoman* = FF_ROMAN
  wFontFamilySwiss* = FF_SWISS
  wFontFamilyModern* = FF_MODERN
  wFontFamilyScript* = FF_SCRIPT
  wFontFamilyDecorative* = FF_DECORATIVE
  # font weight
  wFontWeightThin* = FW_THIN
  wFontWeightExtralight* = FW_EXTRALIGHT
  wFontWeightLight* = FW_LIGHT
  wFontWeightNormal* = FW_NORMAL
  wFontWeightMedium* = FW_MEDIUM
  wFontWeightSemiBold* = FW_SEMIBOLD
  wFontWeightBold* = FW_BOLD
  wFontWeightExtraBold* = FW_EXTRABOLD
  wFontWeightHeavy* = FW_HEAVY
  # font encoding
  wFontEncodingDefault* = DEFAULT_CHARSET
  wFontEncodingSystem* = DEFAULT_CHARSET
  wFontEncodingCp1252* = ANSI_CHARSET
  wFontEncodingCp932* = SHIFTJIS_CHARSET
  wFontEncodingCp1361* = JOHAB_CHARSET
  wFontEncodingCp936* = GB2312_CHARSET
  wFontEncodingCp949* = HANGUL_CHARSET
  wFontEncodingCp950* = CHINESEBIG5_CHARSET
  wFontEncodingCp1250* = EASTEUROPE_CHARSET
  wFontEncodingCp1251* = RUSSIAN_CHARSET
  wFontEncodingCp1253* = GREEK_CHARSET
  wFontEncodingCp1254* = HEBREW_CHARSET
  wFontEncodingCp1255* = ARABIC_CHARSET
  wFontEncodingCp1257* = BALTIC_CHARSET
  wFontEncodingCp1258* = VIETNAMESE_CHARSET
  wFontEncodingCp874* = THAI_CHARSET
  wFontEncodingCp437* = OEM_CHARSET
  wFontEncodingCp850* = OEM_CHARSET

proc initFromNative(self: wFont, lf: var LOGFONT) =
  self.wGdiObject.init()

  mHandle = CreateFontIndirect(lf)
  if mHandle == 0:
    raise newException(wFontError, "wFont creation failure")

  mPointSize = -(lf.lfHeight * 72 / wGetDPI())
  mWeight = lf.lfWeight
  mFaceName = $lf.lfFaceName
  mFaceName.nullTerminate()
  mEncoding = int lf.lfCharSet
  mFamily = int(lf.lfPitchAndFamily and 0b000)
  mItalic = (lf.lfItalic != 0)
  mUnderline = (lf.lfUnderline != 0)

proc init(self: wFont, pointSize: float = NaN, family = wFontFamilyDefault, weight = wFontWeightNormal,
  italic = false, underline = false, faceName: string = nil, encoding = wFontEncodingDefault) =

  # use lfMessageFont in nonclientMetrics instead of DEFAULT_GUI_FONT
  var nonclientMetrics = NONCLIENTMETRICS(cbSize: sizeof(NONCLIENTMETRICS).UINT)
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, addr nonclientMetrics, 0)

  var lf: LOGFONT = nonclientMetrics.lfMessageFont
  # GetObject(GetStockObject(DEFAULT_GUI_FONT), sizeof(LOGFONT), addr lf)

  if pointSize.classify != fcNaN:
    lf.lfHeight = -round(pointSize * wGetDPI().float / 72'f).LONG

  if family != wFontFamilyDefault:
    lf.lfPitchAndFamily = family.ord.byte or DEFAULT_PITCH

  lf.lfItalic = italic.byte
  lf.lfUnderline = underline.byte
  lf.lfWeight = weight

  if encoding != wFontEncodingDefault:
    lf.lfCharSet = encoding.byte

  if faceName != nil:
    lf.lfFaceName <<< T(faceName)

  initFromNative(lf)

proc final(self: wFont) =
  delete()

proc getPointSize*(self: wFont): float {.validate, property, inline.} =
  ## Gets the point size.
  result = mPointSize

proc getFamily*(self: wFont): int {.validate, property, inline.} =
  ## Gets the font family if possible.
  result = mFamily

proc getWeight*(self: wFont): int {.validate, property, inline.} =
  ## Gets the font weight.
  result = mWeight

proc getItalic*(self: wFont): bool {.validate, property, inline.} =
  ## Gets true if font is italic.
  result = mItalic

proc getUnderlined*(self: wFont): bool {.validate, property, inline.} =
  ## Gets true if font is underlined.
  result = mUnderline

proc getFaceName*(self: wFont): string {.validate, property, inline.} =
  ## Gets the font family if possible.
  result = mFaceName

proc getEncoding*(self: wFont): int {.validate, property, inline.} =
  ## Gets the encoding of this font.
  result = mEncoding

proc setPointSize*(self: wFont, pointSize: float) {.validate, property.} =
  ## Sets the point size.
  DeleteObject(mHandle)
  init(pointSize=pointSize, family=mFamily, weight=mWeight, italic=mItalic, underline=mUnderline, faceName=mFaceName, encoding=mEncoding)

proc setFamily*(self: wFont, family: int) {.validate, property.} =
  ## Sets the font family.
  DeleteObject(mHandle)
  init(pointSize=mPointSize, family=family, weight=mWeight, italic=mItalic, underline=mUnderline, faceName=mFaceName, encoding=mEncoding)

proc setWeight*(self: wFont, weight: int) {.validate, property.} =
  ## Sets the font weight.
  DeleteObject(mHandle)
  init(pointSize=mPointSize, family=mFamily, weight=weight, italic=mItalic, underline=mUnderline, faceName=mFaceName, encoding=mEncoding)

proc setItalic*(self: wFont, italic: bool) {.validate, property.} =
  ## Sets the font italic style.
  DeleteObject(mHandle)
  init(pointSize=mPointSize, family=mFamily, weight=mWeight, italic=italic, underline=mUnderline, faceName=mFaceName, encoding=mEncoding)

proc setUnderlined*(self: wFont, underline: bool) {.validate, property.} =
  ## Sets underlining.
  DeleteObject(mHandle)
  init(pointSize=mPointSize, family=mFamily, weight=mWeight, italic=mItalic, underline=underline, faceName=mFaceName, encoding=mEncoding)

proc setFaceName*(self: wFont, faceName: string) {.validate, property.} =
  ## Sets the facename for the font.
  DeleteObject(mHandle)
  init(pointSize=mPointSize, family=mFamily, weight=mWeight, italic=mItalic, underline=mUnderline, faceName=faceName, encoding=mEncoding)

proc setEncoding*(self: wFont, encoding: int) {.validate, property.} =
  ## Sets the encoding for this font.
  DeleteObject(mHandle)
  init(pointSize=mPointSize, family=mFamily, weight=mWeight, italic=mItalic, underline=mUnderline, faceName=mFaceName, encoding=encoding)

proc Font*(pointSize: float = NaN, family = wFontFamilyDefault, weight = wFontWeightNormal,
  italic = false, underline = false, faceName: string = nil, encoding = wFontEncodingDefault): wFont =
  ## Creates a font object with the specified attributes.
  ## ==========  =================================================================================
  ## Parameters  Description
  ## ==========  =================================================================================
  ## pointSize   Size in points.
  ## family      The font family: a generic portable way of referring to fonts without specifying a facename.
  ## weight      Font weight, sometimes also referred to as font boldness.
  ## italic      The value can be true or false.
  ## underline   The value can be true or false.
  ## faceName    An optional string specifying the face name to be used.
  ## encoding    The font encoding.

  new(result, final)
  result.init(pointSize=pointSize, family=family, weight=weight, italic=italic, underline=underline, faceName=faceName, encoding=encoding)

proc Font*(hFont: HANDLE): wFont =
  ## Construct wFont object from a system font handle.
  if hFont in 0..1000: # maybe it means pointSize?
    return Font(float hFont)

  new(result, final)
  var lf: LOGFONT
  GetObject(hFont, sizeof(LOGFONT), cast[pointer](addr lf))
  result.initFromNative(lf)

proc Font*(font: wFont): wFont {.inline.} =
  ## Copy constructor
  wValidate(font)
  result = Font(font.mHandle)
