#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## Here are some predefined objects ready to be use.
## These objects share there handle globally, **don't delete it**.
#
## :Seealso:
##   `wPen <wPen.html>`_
##   `wBrusn <wBrusn.html>`_
##   `wFont <wFont.html>`_
##   `wBitmap <wBitmap.html>`_
##   `wIcon <wIcon.html>`_
##   `wCursor <wCursor.html>`_

DefineIncrement(0):
  NormalFont
  SmallFont
  LargeFont
  ItalicFont
  BoldFont
  BlackPen
  WhitePen
  TransparentPen
  RedPen
  CyanPen
  GreenPen
  GreyPen
  MediumGreyPen
  LightGreyPen
  BlackDashedPen
  BlackBrush
  WhiteBrush
  GreyBrush
  TransparentBrush
  LightGreyBrush
  MediumGreyBrush
  BlueBrush
  GreenBrush
  CyanBrush
  RedBrush
  NilBitmap
  NilCursor
  DefaultCursor
  ArrorCursor
  SizeAllCursor
  SizeWeCursor
  SizeNsCursor
  HandCursor

template wNormalFont*(): untyped =
  wAppGDIStock(wFont, NormalFont):
    Font()

template wSmallFont*(): untyped =
  wAppGDIStock(wFont, SmallFont):
    let font = Font()
    Font(pointSize=font.pointSize - 2)

template wLargeFont*(): untyped =
  wAppGDIStock(wFont, LargeFont):
    let font = Font()
    Font(pointSize=font.pointSize + 2)

template wItalicFont*(): untyped =
  wAppGDIStock(wFont, ItalicFont):
    Font(family=wFontFamilyRoman, italic=true)

template wBoldFont*(): untyped =
  wAppGDIStock(wFont, BoldFont):
    Font(weight=wFontWeightBold)

template wDefaultFont*(): untyped =
  wNormalFont()

template wBlackPen*(): untyped =
  wAppGDIStock(wPen, BlackPen):
    Pen(color=wBLACK)

template wWhitePen*(): untyped =
  wAppGDIStock(wPen, WhitePen):
    Pen(color=wWHITE)

template wTransparentPen*(): untyped =
  wAppGDIStock(wPen, TransparentPen):
    Pen(style=wPenStyleTransparent)

template wRedPen*(): untyped =
  wAppGDIStock(wPen, RedPen):
    Pen(color=wRED)

template wCyanPen*(): untyped =
  wAppGDIStock(wPen, CyanPen):
    Pen(color=wCYAN)

template wGreenPen*(): untyped =
  wAppGDIStock(wPen, GreenPen):
    Pen(color=wGREEN)

template wGreyPen*(): untyped =
  wAppGDIStock(wPen, GreyPen):
    Pen(color=wGREY)

template wMediumGreyPen*(): untyped =
  wAppGDIStock(wPen, MediumGreyPen):
    Pen(color=wMEDIUMGREY)

template wLightGreyPen*(): untyped =
  wAppGDIStock(wPen, LightGreyPen):
    Pen(color=wLIGHTGREY)

template wBlackDashedPen*(): untyped =
  wAppGDIStock(wPen, BlackDashedPen):
    Pen(color=wBLACK, style=wPENSTYLE_SHORT_DASH)

template wDefaultPen*(): untyped =
  wBlackPen()

template wBlackBrush*(): untyped =
  wAppGDIStock(wBrush, BlackBrush):
    Brush(color=wBLACK)

template wWhiteBrush*(): untyped =
  wAppGDIStock(wBrush, WhiteBrush):
    Brush(color=wWHITE)

template wGreyBrush*(): untyped =
  wAppGDIStock(wBrush, GreyBrush):
    Brush(color=wGREY)

template wTransparentBrush*(): untyped =
  wAppGDIStock(wBrush, TransparentBrush):
    Brush(style=wBrushStyleTransparent)

template wLightGreyBrush*(): untyped =
  wAppGDIStock(wBrush, LightGreyBrush):
    Brush(color=wLIGHTGREY)

template wMediumGreyBrush*(): untyped =
  wAppGDIStock(wBrush, MediumGreyBrush):
    Brush(color=wMEDIUMGREY)

template wBlueBrush*(): untyped =
  wAppGDIStock(wBrush, BlueBrush):
    Brush(color=wBLUE)

template wGreenBrush*(): untyped =
  wAppGDIStock(wBrush, GreenBrush):
    Brush(color=wGREEN)

template wCyanBrush*(): untyped =
  wAppGDIStock(wBrush, CyanBrush):
    Brush(color=wCYAN)

template wRedBrush*(): untyped =
  wAppGDIStock(wBrush, RedBrush):
    Brush(color=wRED)

template wDefaultBrush*(): untyped =
  wWhiteBrush()

template wNilBitmap*(): untyped =
  wAppGDIStock(wBitmap, NilBitmap):
    Bmp(0, 0)

template wNilCursor*(): untyped =
  wAppGDIStock(wCursor, NilCursor):
    Cursor(0)

template wDefaultCursor*(): untyped =
  wAppGDIStock(wCursor, DefaultCursor):
    Cursor(-1)

template wArrorCursor*(): untyped =
  wAppGDIStock(wCursor, ArrorCursor):
    Cursor(wCursorArrow)

template wSizeAllCursor*(): untyped =
  wAppGDIStock(wCursor, SizeAllCursor):
    Cursor(wCursorSizeAll)

template wSizeWeCursor*(): untyped =
  wAppGDIStock(wCursor, SizeWeCursor):
    Cursor(wCursorSizeWe)

template wSizeNsCursor*(): untyped =
  wAppGDIStock(wCursor, SizeNsCursor):
    Cursor(wCursorSizeNs)

template wHandCursor*(): untyped =
  wAppGDIStock(wCursor, HandCursor):
    Cursor(wCursorHand)
