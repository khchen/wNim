#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
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

{.experimental, deadCodeElim: on.}

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
  if self.mHandle != 0 and self.mDeletable:
    DeleteObject(self.mHandle)

  self.mHandle = 0

when not isMainModule: # hide from doc

  template wGDIStock*(typ: typedesc, sn: int, obj: wGdiObject): untyped =
    if sn > wAppGetCurrentApp.mGDIStockSeq.high:
      wAppGetCurrentApp.mGDIStockSeq.setlen(sn+1)

    if wAppGetCurrentApp.mGDIStockSeq[sn] == nil:
      wAppGetCurrentApp.mGDIStockSeq[sn] = obj

    typ(wAppGetCurrentApp.mGDIStockSeq[sn])

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
