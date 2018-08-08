## A pen is a drawing tool for drawing outlines.
##
## :Superclass:
##    wGdiObject
## :Consts:
##    ==============================  =============================================================
##    Pen Styles                      Description
##    ==============================  =============================================================
##    wPenJoinBevel                   PS_JOIN_BEVEL
##    wPenJoinMiter                   PS_JOIN_MITER
##    wPenJoinRound                   PS_JOIN_ROUND
##    wPenJoinMask                    PS_JOIN_MASK
##    wPenCapRound                    PS_ENDCAP_ROUND
##    wPenCapProjecting               PS_ENDCAP_SQUARE
##    wPenCapButt                     PS_ENDCAP_FLAT
##    wPenCapMask                     PS_ENDCAP_MASK
##    wPenStyleSolid                  Solid style.
##    wPenStyleDot                    Dotted style.
##    wPenStyleDash                   Dashed style.
##    wPenStyleDot_DASH               Dot and dash style.
##    wPenStyleTransparent            No pen is used.
##    wPenStyleMask                   Pen style mask.
##    wPenStyleBdiagonalHatch         Backward diagonal hatch.
##    wPenStyleCrossdiagHatch         Cross-diagonal hatch.
##    wPenStyleFdiagonalHatch         Forward diagonal hatch.
##    wPenStyleCrossHatch             Cross hatch.
##    wPenStyleHorizontalHatch        Horizontal hatch.
##    wPenStyleVerticalHatch          Vertical hatch.
##    wPenStyleMaskHatch              Hatch style mask.
##    ==============================  =============================================================

type
  wPenError* = object of wGdiObjectError
    ## An error raised when wPen creation failure.

const
  # wPen styles
  wPenJoinBevel* = PS_JOIN_BEVEL
  wPenJoinMiter* = PS_JOIN_MITER
  wPenJoinRound* = PS_JOIN_ROUND
  wPenJoinMask* = PS_JOIN_MASK
  wPenCapRound* = PS_ENDCAP_ROUND
  wPenCapProjecting* = PS_ENDCAP_SQUARE
  wPenCapButt* = PS_ENDCAP_FLAT
  wPenCapMask* = PS_ENDCAP_MASK
  wPenStyleSolid* = PS_SOLID
  wPenStyleDot* = PS_DOT
  wPenStyleDash* = PS_DASH
  wPenStyleDot_DASH* = PS_DASHDOT
  wPenStyleTransparent* = PS_NULL
  wPenStyleMask* = PS_STYLE_MASK

  # all PS_ style <= 0xFFFF
  wPenStyleBdiagonalHatch* = HS_BDIAGONAL shl 16
  wPenStyleCrossdiagHatch* = HS_DIAGCROSS shl 16
  wPenStyleFdiagonalHatch* = HS_FDIAGONAL shl 16
  wPenStyleCrossHatch* = HS_CROSS shl 16
  wPenStyleHorizontalHatch* = HS_HORIZONTAL shl 16
  wPenStyleVerticalHatch* = HS_VERTICAL shl 16
  wPenStyleMaskHatch* = 0x00ff0000

proc initFromNative(self: wPen, elp: EXTLOGPEN) =
  self.wGdiObject.init()

  var lb: LOGBRUSH
  lb.lbStyle = elp.elpBrushStyle
  lb.lbColor = elp.elpColor
  lb.lbHatch = elp.elpHatch
  mHandle = ExtCreatePen(elp.elpPenStyle, elp.elpWidth, lb, 0, nil)
  if mHandle == 0:
    raise newException(wFontError, "wPen creation failure")

  mColor = elp.elpColor
  mStyle = elp.elpPenStyle or (DWORD elp.elpHatch shl 16)
  mWidth = elp.elpWidth

proc init(self: wPen, color: wColor = wBLACK, style: DWORD = wPenStyleSolid, width: int = 1) =
  let hatch = style shr 16
  var elp: EXTLOGPEN
  elp.elpPenStyle = PS_GEOMETRIC or (style and 0xFFFF)
  elp.elpWidth = width
  elp.elpColor = color

  if (style and wPenStyleMask) == wPenStyleTransparent:
    elp.elpBrushStyle = BS_HOLLOW
  elif hatch != 0:
    elp.elpBrushStyle = BS_HATCHED
    elp.elpHatch = ULONG_PTR hatch
  else:
    elp.elpBrushStyle = BS_SOLID

  initFromNative(elp)

proc final(self: wPen) =
  self.wGdiObject.final()

proc getColor*(self: wPen): wColor {.validate, property, inline.} =
  ## Returns a reference to the pen color.
  result = mColor

proc getStyle*(self: wPen): DWORD {.validate, property, inline.} =
  ## Returns the pen style.
  result = mStyle

proc getWidth*(self: wPen): int {.validate, property, inline.} =
  ## Returns the pen width.
  result = mWidth

proc setColor*(self: wPen, color: wColor) {.validate, property.} =
  ## Set the pen color.
  DeleteObject(mHandle)
  init(color=color, style=mStyle, width=mWidth)

proc setStyle*(self: wPen, style: DWORD) {.validate, property.} =
  ## Set the pen style.
  DeleteObject(mHandle)
  init(color=mColor, style=style, width=mWidth)

proc setWidth*(self: wPen, width: int) {.validate, property.} =
  ## Sets the pen width.
  DeleteObject(mHandle)
  init(color=mColor, style=mStyle, width=width)

proc Pen*(color: wColor = wBLACK, style: DWORD = wPenStyleSolid or wPenCapRound, width: int = 1): wPen =
  ## Constructs a pen from color, width, and style.
  new(result, final)
  result.init(color=color, style=style, width=width)

proc Pen*(hPen: HANDLE): wPen =
  ## Construct wPen object from a system pen handle.
  new(result, final)
  var elp: EXTLOGPEN
  GetObject(hPen, sizeof(elp), addr elp)
  result.initFromNative(elp)
