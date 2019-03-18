#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A font is an object which determines the appearance of text.
#
## :Superclass:
##   `wGdiObject <wGdiObject.html>`_
#
## :Seealso:
##   `wDC <wDC.html>`_
##   `wPredefined <wPredefined.html>`_
#
## :Consts:
##   ==============================  =============================================================
##   Font Family                     Description
##   ==============================  =============================================================
##   wFontFamilyDefault              FF_DONTCARE
##   wFontFamilyRoman                FF_ROMAN
##   wFontFamilySwiss                FF_SWISS
##   wFontFamilyModern               FF_MODERN
##   wFontFamilyScript               FF_SCRIPT
##   wFontFamilyDecorative           FF_DECORATIVE
##   ==============================  =============================================================
##
##   ==============================  =============================================================
##   Font Weight                     Description
##   ==============================  =============================================================
##   wFontWeightThin                 FW_THIN
##   wFontWeightExtralight           FW_EXTRALIGHT
##   wFontWeightLight                FW_LIGHT
##   wFontWeightNormal               FW_NORMAL
##   wFontWeightMedium               FW_MEDIUM
##   wFontWeightSemiBold             FW_SEMIBOLD
##   wFontWeightBold                 FW_BOLD
##   wFontWeightExtraBold            FW_EXTRABOLD
##   wFontWeightHeavy                FW_HEAVY
##   ==============================  =============================================================
##
##   ==============================  =============================================================
##   Font Weight                     Description
##   ==============================  =============================================================
##   wFontWeightThin                 FW_THIN
##   wFontWeightExtralight           FW_EXTRALIGHT
##   wFontWeightLight                FW_LIGHT
##   wFontWeightNormal               FW_NORMAL
##   wFontWeightMedium               FW_MEDIUM
##   wFontWeightSemiBold             FW_SEMIBOLD
##   wFontWeightBold                 FW_BOLD
##   wFontWeightExtraBold            FW_EXTRABOLD
##   wFontWeightHeavy                FW_HEAVY
##   ==============================  =============================================================
##
##   ==============================  =============================================================
##   Font Encoding                   Description
##   ==============================  =============================================================
##   wFontEncodingDefault            DEFAULT_CHARSET
##   wFontEncodingSystem             DEFAULT_CHARSET
##   wFontEncodingCp1252             ANSI_CHARSET
##   wFontEncodingCp932              SHIFTJIS_CHARSET
##   wFontEncodingCp1361             JOHAB_CHARSET
##   wFontEncodingCp936              GB2312_CHARSET
##   wFontEncodingCp949              HANGUL_CHARSET
##   wFontEncodingCp950              CHINESEBIG5_CHARSET
##   wFontEncodingCp1250             EASTEUROPE_CHARSET
##   wFontEncodingCp1251             RUSSIAN_CHARSET
##   wFontEncodingCp1253             GREEK_CHARSET
##   wFontEncodingCp1254             HEBREW_CHARSET
##   wFontEncodingCp1255             ARABIC_CHARSET
##   wFontEncodingCp1257             BALTIC_CHARSET
##   wFontEncodingCp1258             VIETNAMESE_CHARSET
##   wFontEncodingCp874              THAI_CHARSET
##   wFontEncodingCp437              OEM_CHARSET
##   wFontEncodingCp850              OEM_CHARSET
##   ==============================  =============================================================

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

proc final*(self: wFont) =
  ## Default finalizer for wFont.
  self.delete()

proc initFromNative(self: wFont, lf: var LOGFONT) =
  self.wGdiObject.init()

  self.mHandle = CreateFontIndirect(lf)
  if self.mHandle == 0:
    raise newException(wFontError, "wFont creation failure")

  self.mPointSize = -(lf.lfHeight * 72 / wGetDPI())
  self.mWeight = lf.lfWeight
  self.mFaceName = $lf.lfFaceName
  self.mFaceName.nullTerminate()
  self.mEncoding = int lf.lfCharSet
  self.mFamily = int(lf.lfPitchAndFamily and 0b000)
  self.mItalic = (lf.lfItalic != 0)
  self.mUnderline = (lf.lfUnderline != 0)

proc init*(self: wFont, pointSize: float = NaN, family = wFontFamilyDefault,
    weight = wFontWeightNormal, italic = false, underline = false,
    faceName = "", encoding = wFontEncodingDefault) {.validate.} =
  ## Initializer.
  var
    nonclientMetrics = NONCLIENTMETRICS(cbSize: sizeof(NONCLIENTMETRICS).UINT)
    lf: LOGFONT

  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, addr nonclientMetrics, 0):
    lf = nonclientMetrics.lfMessageFont
  else:
    GetObject(GetStockObject(DEFAULT_GUI_FONT), sizeof(LOGFONT), addr lf)

  if pointSize.classify != fcNaN:
    lf.lfHeight = -round(pointSize * wGetDPI().float / 72'f).LONG

  if family != wFontFamilyDefault:
    lf.lfPitchAndFamily = family.ord.byte or DEFAULT_PITCH

  lf.lfItalic = italic.byte
  lf.lfUnderline = underline.byte
  lf.lfWeight = weight

  if encoding != wFontEncodingDefault:
    lf.lfCharSet = encoding.byte

  if faceName.len != 0:
    lf.lfFaceName <<< T(faceName)

  self.initFromNative(lf)

proc Font*(pointSize: float = NaN, family = wFontFamilyDefault,
    weight = wFontWeightNormal, italic = false, underline = false,
    faceName = "", encoding = wFontEncodingDefault): wFont {.inline.} =
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
  result.init(pointSize, family, weight, italic, underline, faceName, encoding)

proc init*(self: wFont, hFont: HANDLE) {.validate.} =
  ## Initializer.
  if GetObjectType(hFont) == 0:
    # maybe it means pointSize?
    self.init(float hFont)

  else:
    var lf: LOGFONT
    GetObject(hFont, sizeof(LOGFONT), cast[pointer](&lf))
    self.initFromNative(lf)

proc Font*(hFont: HANDLE): wFont {.inline.} =
  ## Construct wFont object from a system font handle.
  new(result, final)
  result.init(hFont)

proc init*(self: wFont, font: wFont) {.validate.} =
  ## Initializer.
  wValidate(font)
  self.init(font.mHandle)

proc Font*(font: wFont): wFont {.inline.} =
  ## Copy constructor
  wValidate(font)
  new(result, final)
  result.init(font)

proc getPointSize*(self: wFont): float {.validate, property, inline.} =
  ## Gets the point size.
  result = self.mPointSize

proc getFamily*(self: wFont): int {.validate, property, inline.} =
  ## Gets the font family if possible.
  result = self.mFamily

proc getWeight*(self: wFont): int {.validate, property, inline.} =
  ## Gets the font weight.
  result = self.mWeight

proc getItalic*(self: wFont): bool {.validate, property, inline.} =
  ## Gets true if font is italic.
  result = self.mItalic

proc getUnderlined*(self: wFont): bool {.validate, property, inline.} =
  ## Gets true if font is underlined.
  result = self.mUnderline

proc getFaceName*(self: wFont): string {.validate, property, inline.} =
  ## Gets the font family if possible.
  result = self.mFaceName

proc getEncoding*(self: wFont): int {.validate, property, inline.} =
  ## Gets the encoding of this font.
  result = self.mEncoding

proc setPointSize*(self: wFont, pointSize: float) {.validate, property.} =
  ## Sets the point size.
  DeleteObject(self.mHandle)
  self.init(pointSize=pointSize, family=self.mFamily, weight=self.mWeight,
    italic=self.mItalic, underline=self.mUnderline, faceName=self.mFaceName,
    encoding=self.mEncoding)

proc setFamily*(self: wFont, family: int) {.validate, property.} =
  ## Sets the font family.
  DeleteObject(self.mHandle)
  self.init(pointSize=self.mPointSize, family=family, weight=self.mWeight,
    italic=self.mItalic, underline=self.mUnderline, faceName=self.mFaceName,
    encoding=self.mEncoding)

proc setWeight*(self: wFont, weight: int) {.validate, property.} =
  ## Sets the font weight.
  DeleteObject(self.mHandle)
  self.init(pointSize=self.mPointSize, family=self.mFamily, weight=weight,
    italic=self.mItalic, underline=self.mUnderline, faceName=self.mFaceName,
    encoding=self.mEncoding)

proc setItalic*(self: wFont, italic: bool) {.validate, property.} =
  ## Sets the font italic style.
  DeleteObject(self.mHandle)
  self.init(pointSize=self.mPointSize, family=self.mFamily, weight=self.mWeight,
    italic=italic, underline=self.mUnderline, faceName=self.mFaceName,
    encoding=self.mEncoding)

proc setUnderlined*(self: wFont, underline: bool) {.validate, property.} =
  ## Sets underlining.
  DeleteObject(self.mHandle)
  self.init(pointSize=self.mPointSize, family=self.mFamily, weight=self.mWeight,
    italic=self.mItalic, underline=underline, faceName=self.mFaceName,
    encoding=self.mEncoding)

proc setFaceName*(self: wFont, faceName: string) {.validate, property.} =
  ## Sets the facename for the font.
  DeleteObject(self.mHandle)
  self.init(pointSize=self.mPointSize, family=self.mFamily, weight=self.mWeight,
    italic=self.mItalic, underline=self.mUnderline, faceName=faceName,
    encoding=self.mEncoding)

proc setEncoding*(self: wFont, encoding: int) {.validate, property.} =
  ## Sets the encoding for this font.
  DeleteObject(self.mHandle)
  self.init(pointSize=self.mPointSize, family=self.mFamily, weight=self.mWeight,
    italic=self.mItalic, underline=self.mUnderline, faceName=self.mFaceName,
    encoding=encoding)
