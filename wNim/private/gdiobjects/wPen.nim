#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A pen is a drawing tool for drawing outlines.
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
##   Pen Styles                      Description
##   ==============================  =============================================================
##   wPenJoinBevel                   PS_JOIN_BEVEL
##   wPenJoinMiter                   PS_JOIN_MITER
##   wPenJoinRound                   PS_JOIN_ROUND
##   wPenJoinMask                    PS_JOIN_MASK
##   wPenCapRound                    PS_ENDCAP_ROUND
##   wPenCapProjecting               PS_ENDCAP_SQUARE
##   wPenCapButt                     PS_ENDCAP_FLAT
##   wPenCapMask                     PS_ENDCAP_MASK
##   wPenStyleSolid                  Solid style.
##   wPenStyleDot                    Dotted style.
##   wPenStyleDash                   Dashed style.
##   wPenStyleDot_DASH               Dot and dash style.
##   wPenStyleTransparent            No pen is used.
##   wPenStyleMask                   Pen style mask.
##   wPenStyleBdiagonalHatch         Backward diagonal hatch.
##   wPenStyleCrossdiagHatch         Cross-diagonal hatch.
##   wPenStyleFdiagonalHatch         Forward diagonal hatch.
##   wPenStyleCrossHatch             Cross hatch.
##   wPenStyleHorizontalHatch        Horizontal hatch.
##   wPenStyleVerticalHatch          Vertical hatch.
##   wPenStyleMaskHatch              Hatch style mask.
##   ==============================  =============================================================

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

proc final*(self: wPen) =
  ## Default finalizer for wPen.
  self.delete()

proc initFromNative(self: wPen, elp: EXTLOGPEN) =
  self.wGdiObject.init()

  var lb: LOGBRUSH
  lb.lbStyle = elp.elpBrushStyle
  lb.lbColor = elp.elpColor
  lb.lbHatch = elp.elpHatch
  self.mHandle = ExtCreatePen(elp.elpPenStyle or PS_GEOMETRIC,
    elp.elpWidth, lb, 0, nil)

  if self.mHandle == 0:
    raise newException(wPenError, "wPen creation failure")

  self.mColor = elp.elpColor
  self.mStyle = elp.elpPenStyle or (DWORD elp.elpHatch shl 16)
  self.mWidth = elp.elpWidth

proc init*(self: wPen, color = wBlack, style = wPenStyleSolid or wPenCapRound,
    width = 1) {.validate.} =
  ## Initializer.
  let hatch = style shr 16
  var elp: EXTLOGPEN
  elp.elpPenStyle = style and 0xFFFF
  elp.elpWidth = width
  elp.elpColor = color

  if (style and wPenStyleMask) == wPenStyleTransparent:
    elp.elpBrushStyle = BS_HOLLOW
  elif hatch != 0:
    elp.elpBrushStyle = BS_HATCHED
    elp.elpHatch = ULONG_PTR hatch
  else:
    elp.elpBrushStyle = BS_SOLID

  self.initFromNative(elp)

proc Pen*(color = wBlack, style = wPenStyleSolid or wPenCapRound, width = 1): wPen
    {.inline.} =
  ## Constructs a pen from color, width, and style.
  new(result, final)
  result.init(color, style, width)

proc init*(self: wPen, hPen: HANDLE) {.validate.} =
  ## Initializer.
  var elp: EXTLOGPEN
  GetObject(hPen, sizeof(elp), &elp)
  self.initFromNative(elp)

proc Pen*(hPen: HANDLE): wPen {.inline.} =
  ## Construct wPen object from a system pen handle.
  new(result, final)
  result.init(hPen)

proc init*(self: wPen, pen: wPen) {.validate.} =
  ## Initializer.
  wValidate(pen)
  self.init(pen.mHandle)

proc Pen*(pen: wPen): wPen {.inline.} =
  ## Copy constructor
  wValidate(pen)
  result.init(pen)

proc getColor*(self: wPen): wColor {.validate, property, inline.} =
  ## Returns a reference to the pen color.
  result = self.mColor

proc getStyle*(self: wPen): DWORD {.validate, property, inline.} =
  ## Returns the pen style.
  result = self.mStyle

proc getWidth*(self: wPen): int {.validate, property, inline.} =
  ## Returns the pen width.
  result = self.mWidth

proc setColor*(self: wPen, color: wColor) {.validate, property.} =
  ## Set the pen color.
  DeleteObject(self.mHandle)
  self.init(color=color, style=self.mStyle, width=self.mWidth)

proc setStyle*(self: wPen, style: DWORD) {.validate, property.} =
  ## Set the pen style.
  DeleteObject(self.mHandle)
  self.init(color=self.mColor, style=style, width=self.mWidth)

proc setWidth*(self: wPen, width: int) {.validate, property.} =
  ## Sets the pen width.
  DeleteObject(self.mHandle)
  self.init(color=self.mColor, style=self.mStyle, width=width)
