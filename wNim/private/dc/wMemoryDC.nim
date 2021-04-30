#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A memory device context provides a means to draw graphics onto a bitmap.
## Notice that the memory DC must be deleted (or the bitmap selected out of it)
## before a bitmap can be reselected into another memory DC. And, before
## performing any other operations on the bitmap data, the bitmap must be
## selected out of the memory DC:
##
## .. code-block:: Nim
##   tempdc.selectObject(wNilBitmap) # here wNilBitmap is a predefined bitmap
##
## Like other DC object, wMemoryDC need nim's destructors to release the resource.
#
## :Superclass:
##   `wDC <wDC.html>`_

include ../pragma
import ../wBase, ../gdiobjects/wBitmap, wDC
export wDC

proc selectObject*(self: var wMemoryDC, bitmap: wBitmap) =
  ## Selects the given bitmap into the device context, to use as the memory bitmap.
  wValidate(bitmap)
  self.mBitmap = bitmap
  let hBmp = SelectObject(self.mHdc, bitmap.mHandle)
  if self.mhOldBitmap == 0: self.mhOldBitmap = hBmp

method getSize*(self: wMemoryDC): wSize {.property.} =
  ## Gets the size of the device context.
  result = self.mBitmap.getSize()

proc MemoryDC*(): wMemoryDC =
  ## Constructs a new memory device context.
  result.mHdc = CreateCompatibleDC(0)
  result.wDC.init()

proc MemoryDC*(dc: wDC): wMemoryDC =
  ## Constructs a new memory device context compatible with the specified device.
  result.mHdc = CreateCompatibleDC(dc.mHdc)
  result.wDC.init()

proc delete*(self: var wMemoryDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  `=destroy`(self)
