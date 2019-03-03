#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A brush is a drawing tool for filling in areas.
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
##   wBrushStyleSolid                Solid.
##   wBrushStyleTransparent          Transparent (no fill).
##   wBrushStyleMask                 Brush style mask.
##   wBrushStyleBdiagonalHatch       Backward diagonal hatch.
##   wBrushStyleCrossdiagHatch       Cross-diagonal hatch.
##   wBrushStyleFdiagonalHatch       Forward diagonal hatch.
##   wBrushStyleCrossHatch           Cross hatch.
##   wBrushStyleHorizontalHatch      Horizontal hatch.
##   wBrushStyleVerticalHatch        Vertical hatch.
##   wBrushStyleMaskHatch            Brush hatch style mask.
##   ==============================  =============================================================

type
  wBrushError* = object of wGdiObjectError
    ## An error raised when wBrush creation failure.

const
  wBrushStyleSolid* = PS_SOLID
  wBrushStyleTransparent* = PS_NULL
  wBrushStyleMask* = PS_STYLE_MASK
  wBrushStyleBdiagonalHatch* = HS_BDIAGONAL shl 16
  wBrushStyleCrossdiagHatch* = HS_DIAGCROSS shl 16
  wBrushStyleFdiagonalHatch* = HS_FDIAGONAL shl 16
  wBrushStyleCrossHatch* = HS_CROSS shl 16
  wBrushStyleHorizontalHatch* = HS_HORIZONTAL shl 16
  wBrushStyleVerticalHatch* = HS_VERTICAL shl 16
  wBrushStyleMaskHatch* = 0x00ff0000

proc final*(self: wBrush) =
  ## Default finalizer for wBrush.
  self.delete()

proc initFromNative(self: wBrush, lb: var LOGBRUSH) =
  self.wGdiObject.init()

  self.mHandle = CreateBrushIndirect(lb)
  if self.mHandle == 0:
    raise newException(wBrushError, "wBrush creation failure")

  self.mColor = lb.lbColor
  self.mStyle = lb.lbStyle or (lb.lbHatch.DWORD shl 16)

proc init*(self: wBrush, color: wColor = wWHITE, style = wBrushStyleSolid) {.validate.} =
  ## Initializer.
  let hatch = style shr 16
  var lb: LOGBRUSH
  lb.lbColor = color

  if (style and wBrushStyleMask) == wBrushStyleTransparent:
    lb.lbStyle = BS_HOLLOW
  elif hatch != 0:
    lb.lbStyle = BS_HATCHED
    lb.lbHatch = ULONG_PTR hatch
  else:
    lb.lbStyle = BS_SOLID

  self.initFromNative(lb)

proc Brush*(color: wColor = wWHITE, style = wBrushStyleSolid): wBrush {.inline.} =
  ## Constructs a brush from a color and style.
  new(result, final)
  result.init(color, style)

proc init*(self: wBrush, hBrush: HANDLE) {.validate.} =
  ## Initializer.
  var lb: LOGBRUSH
  GetObject(hBrush, sizeof(lb), &lb)
  self.initFromNative(lb)

proc Brush*(hBrush: HANDLE): wBrush {.inline.} =
  ## Construct wBrush object from a system brush handle.
  new(result, final)
  result.init(hBrush)

proc init*(self: wBrush, brush: wBrush) {.validate.} =
  ## Initializer.
  self.init(brush.mHandle)

proc Brush*(brush: wBrush): wBrush {.inline.} =
  ## Copy constructor
  wValidate(brush)
  new(result, final)
  result.init(brush)

proc getColor*(self: wBrush): wColor {.validate, property, inline.} =
  ## Returns a reference to the brush color.
  result = self.mColor

proc getStyle*(self: wBrush): DWORD {.validate, property, inline.} =
  ## Returns the brush style.
  result = self.mStyle

proc setColor*(self: wBrush, color: wColor) {.validate, property.} =
  ## Sets the brush color.
  DeleteObject(self.mHandle)
  self.init(color=color, style=self.mStyle)

proc setStyle*(self: wBrush, style: DWORD) {.validate, property.} =
  ## Sets the brush style.
  DeleteObject(self.mHandle)
  self.init(color=self.mColor, style=style)
