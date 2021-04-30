#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class encapsulates the system bitmap.
##
## Notice: Because the constructor of wBitmap is Bitmap(), if you also import
## winim for BITMAP struct in Windows SDK, you may encounter a naming clash
## problem. Use winim.BITMAP or wNim.Bitmap() to resolve.
#
## :Superclass:
##   `wGdiObject <wGdiObject.html>`_
#
## :Seealso:
##   `wDC <wDC.html>`_
##   `wIconImage <wIconImage.html>`_

include ../pragma
from ../winimx import nil # For BITMAP
import ../wBase, ../wImage, wGdiObject
export wGdiObject

type
  wBitmapError* = object of wGdiObjectError
    ## An error raised when wBitmap creation failed.

proc error(self: wBitmap) {.inline.} =
  raise newException(wBitmapError, "wBitmap creation failed")

wClass(wBitmap of wGdiObject):

  proc init*(self: wBitmap, width, height: int, depth: int = 0) {.validate.} =
    ## Initializes a new bitmap. A depth of 0 indicates the depth of the current
    ## screen.
    assert depth == 0 or depth == 24 or depth == 32

    self.wGdiObject.init()

    self.mWidth = width
    self.mHeight = height
    self.mDepth = depth

    if depth == 0:
      let hdc = GetDC(0)
      self.mDepth = GetDeviceCaps(hdc, PLANES) * GetDeviceCaps(hdc, BITSPIXEL)
      self.mHandle = CreateCompatibleBitmap(hdc, width, height)
      ReleaseDC(0, hdc)
    else:
      self.mDepth = depth
      self.mHandle = CreateBitmap(width, height, 1, depth, nil)

    if self.mHandle == 0: self.error()

  proc init*(self: wBitmap, size: wSize, depth: int = 0) {.validate.} =
    ## Initializes a new bitmap. A depth of 0 indicates the depth of the current
    ## screen.
    self.init(size.width, size.height, depth)

  proc init*(self: wBitmap, gdipBmp: ptr GpBitmap) {.validate.} =
    ## Initializes a bitmap from a gdiplus bitmap handle.
    self.wGdiObject.init()
    # Here GdiplusStartupInput() should already called.
    if GdipCreateHBITMAPFromBitmap(gdipbmp, addr self.mHandle, 0) != Ok:
      self.error()

    self.mDepth = 32
    var width, height: UINT
    GdipGetImageWidth(gdipbmp, &width)
    GdipGetImageHeight(gdipbmp, &height)
    self.mWidth = width
    self.mHeight = height

  proc init*(self: wBitmap, image: wImage) {.validate.} =
    ## Initializes a bitmap from the given wImage object.
    wValidate(image)
    self.init(image.mGdipBmp)

  proc init*(self: wBitmap, iconImage: wIconImage) {.validate.} =
    ## Initializes a bitmap from the given wIconImage object.
    wValidate(iconImage)
    try:
      self.init(Image(iconImage))
    except wError:
      self.error()

  proc init*(self: wBitmap, icon: wIcon) {.validate.} =
    ## Initializes a bitmap from the given wIcon object.
    wValidate(icon)
    try:
      self.init(Image(icon))
    except wError:
      self.error()

  proc init*(self: wBitmap, cursor: wCursor) {.validate.} =
    ## Initializes a bitmap from the given wCursor object.
    wValidate(cursor)
    try:
      self.init(Image(cursor))
    except wError:
      self.error()

  proc init*(self: wBitmap, filename: string) {.validate.} =
    ## Initializes a bitmap from a image file.
    try:
      self.init(Image(filename))
    except wError:
      self.error()

  proc init*(self: wBitmap, data: pointer, length: int) {.validate.} =
    ## Initializes a bitmap from raw image data.
    try:
      self.init(Image(data, length))
    except wError:
      self.error()

  proc init*(self: wBitmap, handle: HBITMAP, copy = true, shared = false) {.validate.} =
    ## Initializes a bitmap from system bitmap handle.
    ## If *copy* is false, the function only wrap the handle to wBitmap object.
    ## If *shared* is false, the handle will be destroyed together with wBitmap
    ## object by the GC. Otherwise, the caller is responsible for destroying it.
    var bm: winimx.BITMAP
    if GetObject(handle, sizeof(winimx.BITMAP), &bm) == 0:
      self.error()

    if copy:
      self.init(bm.bmWidth, bm.bmHeight, 32)
      var
        hdcSrc = CreateCompatibleDC(0)
        hdcDst = CreateCompatibleDC(0)
        prevSrc = SelectObject(hdcSrc, handle)
        prevDst = SelectObject(hdcDst, self.mHandle)

      defer:
        SelectObject(hdcSrc, prevSrc)
        SelectObject(hdcDst, prevDst)
        DeleteDC(hdcSrc)
        DeleteDC(hdcDst)

      BitBlt(hdcDst, 0, 0, bm.bmWidth, bm.bmHeight, hdcSrc, 0, 0, SRCCOPY)

    else:
      self.wGdiObject.init()
      self.mHandle = handle
      self.mWidth = bm.bmWidth
      self.mHeight = bm.bmHeight
      self.mDepth = int bm.bmBitsPixel
      self.mDeletable = not shared

  proc init*(self: wBitmap, bmp: wBitmap) {.validate.} =
    ## Initializes a bitmap from wBitmap object, aka. copy.
    wValidate(bmp)
    self.init(bmp.mHandle, copy=true)

proc getSize*(self: wBitmap): wSize {.validate, property, inline.} =
  ## Returns the size of the bitmap in pixels.
  result = (self.mWidth, self.mHeight)

proc getWidth*(self: wBitmap): int {.validate, property, inline.} =
  ## Gets the width of the bitmap in pixels.
  result = self.mWidth

proc getHeight*(self: wBitmap): int {.validate, property, inline.} =
  ## Gets the height of the bitmap in pixels.
  result = self.mHeight

proc getDepth*(self: wBitmap): int {.validate, property, inline.} =
  ## Gets the color depth of the bitmap.
  result = self.mDepth

template wNilBitmap*(): untyped =
  ## Predefined empty bitmap. **Don't delete**.
  wGDIStock(wBitmap, NilBitmap):
    Bitmap(0, 0)
