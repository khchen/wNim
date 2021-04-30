#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## wGdiObject is the superclasses of all the GDI objects, such as wPen, wBrush
## and wFont.
#
## :Subclasses:
##   `wPen <wPen.html>`_
##   `wBrusn <wBrusn.html>`_
##   `wFont <wFont.html>`_
##   `wBitmap <wBitmap.html>`_
##   `wIcon <wIcon.html>`_
##   `wCursor <wCursor.html>`_
##   `wRegion <wRegion.html>`_
#
## :Seealso:
##   `wDC <wDC.html>`_

include ../pragma
import ../wBase

type
  wGdiObjectError* = object of wError

proc getHandle*(self: wGdiObject): HANDLE {.validate, property, inline.} =
  ## Gets the real resource handle in system.
  result = self.mHandle

proc init*(self: wGdiObject) {.validate, inline.} =
  ## Initializer.
  self.mHandle = 0
  self.mDeletable = true

method delete*(self: wGdiObject) {.base, inline.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  `=destroy`(self[])

when not isMainModule: # hide from doc

  template wGDIStock*(typ: typedesc, sn: int, obj: wGdiObject): untyped =
    App()
    if sn > wBaseApp.mGDIStockSeq.high:
      wBaseApp.mGDIStockSeq.setlen(sn+1)

    if wBaseApp.mGDIStockSeq[sn] == nil:
      wBaseApp.mGDIStockSeq[sn] = obj

    typ(wBaseApp.mGDIStockSeq[sn])

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
    NilRegion
