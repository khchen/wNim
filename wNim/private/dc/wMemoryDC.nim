#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A memory device context provides a means to draw graphics onto a bitmap.
## Notice that the memory DC must be deleted (or the bitmap selected out of it)
## before a bitmap can be reselected into another memory DC. And, before
## performing any other operations on the bitmap data, the bitmap must be
## selected out of the memory DC:
##
## .. code-block:: Nim
##   temp_dc.selectObject(wNilBitmap) # here wNilBitmap is a predefined bitmap
##
## Like other DC object, wMemoryDC need nim's destructors to release the resource.
## For nim version 0.18.0, you must compile with --newruntime option to get
## destructor works.
#
## :Superclass:
##   `wDC <wDC.html>`_

proc selectObject*(self: var wMemoryDC, bitmap: wBitmap) =
  ## Selects the given bitmap into the device context, to use as the memory bitmap.
  wValidate(bitmap)
  self.mBitmap = bitmap
  let hBmp = SelectObject(self.mHdc, bitmap.mHandle)
  if self.mhOldBitmap == 0: self.mhOldBitmap = hBmp

proc MemoryDC*(): wMemoryDC =
  ## Constructs a new memory device context.
  result.mHdc = CreateCompatibleDC(0)
  result.wDC.init()

proc delete*(self: var wMemoryDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  if self.mHdc != 0:
    self.wDC.final()
    DeleteDC(self.mHdc)
    self.mHdc = 0

proc `=destroy`(self: var wMemoryDC) = self.delete()
