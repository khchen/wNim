#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A pen is a drawing tool for drawing outlines.
#
## :Superclass:
##   `wGdiObject <wGdiObject.html>`_
#
## :Seealso:
##   `wDC <wDC.html>`_
#
## :Consts:
##   ==============================  =============================================================
##   Pen Styles                      Description
##   ==============================  =============================================================
##   wPenJoinBevel                   Joins are beveled.
##   wPenJoinMiter                   Joins are mitered.
##   wPenJoinRound                   Joins are round.
##   wPenJoinMask                    Joins mask.
##   wPenCapRound                    End caps are round.
##   wPenCapProjecting               End caps are square.
##   wPenCapButt                     End caps are flat.
##   wPenCapMask                     End caps mask.
##   wPenStyleSolid                  Solid style.
##   wPenStyleDot                    Dotted style.
##   wPenStyleDash                   Dashed style.
##   wPenStyleDotDash                Dot and dash style.
##   wPenStyleInsideFrame            Drawing inside frame.
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

include ../pragma
import ../wBase, wGdiObject
export wGdiObject

type
  wPenError* = object of wGdiObjectError
    ## An error raised when wPen creation failed.

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
  wPenStyleDotDash* = PS_DASHDOT
  wPenStyleInsideFrame* = PS_INSIDEFRAME
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

proc setup(self: wPen, elp: EXTLOGPEN) =
  self.mColor = elp.elpColor
  self.mStyle = elp.elpPenStyle or (DWORD elp.elpHatch shl 16)
  self.mWidth = elp.elpWidth

wClass(wPen of wGdiObject):

  proc init*(self: wPen, elp: EXTLOGPEN) {.validate.} =
    ## Initializes a pen from EXTLOGPEN struct. Used internally.
    self.wGdiObject.init()

    var lb: LOGBRUSH
    lb.lbStyle = elp.elpBrushStyle
    lb.lbColor = elp.elpColor
    lb.lbHatch = elp.elpHatch
    self.mHandle = ExtCreatePen(elp.elpPenStyle or PS_GEOMETRIC,
      elp.elpWidth, lb, 0, nil)

    if self.mHandle == 0:
      raise newException(wPenError, "wPen creation failed")

    self.setup(elp)

  proc init*(self: wPen, color = wBlack, style = 0, width = 1) {.validate.} =
    ## Initializes a pen from color, width, and style.
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

    self.init(elp)

  proc init*(self: wPen, hPen: HANDLE, copy = true, shared = false) {.validate.} =
    ## Initializes a pen from system pen handle.
    ## If *copy* is false, the function only wrap the handle to wPen object.
    ## If *shared* is false, the handle will be destroyed together with wPen
    ## object by the GC. Otherwise, the caller is responsible for destroying it.
    var elp: EXTLOGPEN
    if GetObject(hPen, sizeof(elp), &elp) == 0:
      raise newException(wPenError, "wPen creation failed")

    if copy:
      self.init(elp)
    else:
      self.wGdiObject.init()
      self.mHandle = hPen
      self.mDeletable = not shared
      self.setup(elp)

  proc init*(self: wPen, pen: wPen) {.validate.} =
    ## Initializes a pen from a wPen object, aka. copy.
    wValidate(pen)
    self.init(pen.mHandle, copy=true)

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

template wBlackPen*(): untyped =
  ## Predefined black pen. **Don't delete**.
  wGDIStock(wPen, BlackPen):
    Pen(color=wBlack)

template wWhitePen*(): untyped =
  ## Predefined white pen. **Don't delete**.
  wGDIStock(wPen, WhitePen):
    Pen(color=wWhite)

template wTransparentPen*(): untyped =
  ## Predefined transparent pen. **Don't delete**.
  wGDIStock(wPen, TransparentPen):
    Pen(style=wPenStyleTransparent)

template wRedPen*(): untyped =
  ## Predefined red pen. **Don't delete**.
  wGDIStock(wPen, RedPen):
    Pen(color=wRed)

template wCyanPen*(): untyped =
  ## Predefined cyan pen. **Don't delete**.
  wGDIStock(wPen, CyanPen):
    Pen(color=wCyan)

template wGreenPen*(): untyped =
  ## Predefined green pen. **Don't delete**.
  wGDIStock(wPen, GreenPen):
    Pen(color=wGreen)

template wGreyPen*(): untyped =
  ## Predefined grey pen. **Don't delete**.
  wGDIStock(wPen, GreyPen):
    Pen(color=wGrey)

template wMediumGreyPen*(): untyped =
  ## Predefined medium grey pen. **Don't delete**.
  wGDIStock(wPen, MediumGreyPen):
    Pen(color=wMediumGrey)

template wLightGreyPen*(): untyped =
  ## Predefined light grey pen. **Don't delete**.
  wGDIStock(wPen, LightGreyPen):
    Pen(color=wLightGrey)

template wBlackDashedPen*(): untyped =
  ## Predefined black dashed pen. **Don't delete**.
  wGDIStock(wPen, BlackDashedPen):
    Pen(color=wBlack, style=wPenStyleDash)

template wDefaultPen*(): untyped =
  ## Predefined default (black) pen. **Don't delete**.
  wBlackPen()
