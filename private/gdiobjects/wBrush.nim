## A brush is a drawing tool for filling in areas.
##
## :Superclass:
##    wGdiObject
## :Consts:
##    ==============================  =============================================================
##    Font Family                     Description
##    ==============================  =============================================================
##    wBrushStyleSolid                Solid.
##    wBrushStyleTransparent          Transparent (no fill).
##    wBrushStyleMask                 Brush style mask.
##    wBrushStyleBdiagonalHatch       Backward diagonal hatch.
##    wBrushStyleCrossdiagHatch       Cross-diagonal hatch.
##    wBrushStyleFdiagonalHatch       Forward diagonal hatch.
##    wBrushStyleCrossHatch           Cross hatch.
##    wBrushStyleHorizontalHatch      Horizontal hatch.
##    wBrushStyleVerticalHatch        Vertical hatch.
##    wBrushStyleMaskHatch            Brush hatch style mask.
##    ==============================  =============================================================

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

proc initFromNative(self: wBrush, lb: var LOGBRUSH) =
  self.wGdiObject.init()

  mHandle = CreateBrushIndirect(lb)
  if mHandle == 0:
    raise newException(wFontError, "wBrush creation failure")

  mColor = lb.lbColor
  mStyle = lb.lbStyle or (lb.lbHatch.DWORD shl 16)

proc init(self: wBrush, color: wColor, style: DWORD) =
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

  initFromNative(lb)

proc final(self: wBrush) =
  delete()

proc getColor*(self: wBrush): wColor {.validate, property, inline.} =
  ## Returns a reference to the brush color.
  result = mColor

proc getStyle*(self: wBrush): DWORD {.validate, property, inline.} =
  ## Returns the brush style.
  result = mStyle

proc setColor*(self: wBrush, color: wColor) {.validate, property.} =
  ## Sets the brush color.
  DeleteObject(mHandle)
  init(color=color, style=mStyle)

proc setStyle*(self: wBrush, style: DWORD) {.validate, property.} =
  ## Sets the brush style.
  DeleteObject(mHandle)
  init(color=mColor, style=style)

proc Brush*(color: wColor = wWHITE , style: DWORD = wBrushStyleSolid): wBrush =
  ## Constructs a brush from a color and style.
  new(result, final)
  result.init(color=color, style=style)

proc Brush*(hBrush: HANDLE): wBrush =
  ## Construct wBrush object from a system brush handle.
  new(result, final)
  var lb: LOGBRUSH
  GetObject(hBrush, sizeof(lb), addr lb)
  result.initFromNative(lb)

proc Brush*(brush: wBrush): wBrush {.inline.} =
  ## Copy constructor
  wValidate(brush)
  result = Brush(brush.mHandle)
