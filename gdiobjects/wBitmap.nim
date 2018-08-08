## This class encapsulates the system bitmap.
##
## :Superclass:
##    wGdiObject

type
  wBitmapError* = object of wGdiObjectError
    ## An error raised when wBitmap creation failure.

proc error(self: wBitmap) {.inline.} =
  raise newException(wBitmapError, "wBitmap creation failure")

proc init(self: wBitmap, width, height: int, depth: int = 0) =
  assert depth == 0 or depth == 24 or depth == 32
  self.wGdiObject.init()

  mWidth = width
  mHeight = height
  mDepth = depth

  if depth == 0:
    let hdc = GetDC(0)
    mDepth = GetDeviceCaps(hdc, PLANES) * GetDeviceCaps(hdc, BITSPIXEL)
    mHandle = CreateCompatibleBitmap(hdc, width, height)
    ReleaseDC(0, hdc)
  else:
    mDepth = depth
    mHandle = CreateBitmap(width, height, 1, depth, nil)

  if mHandle == 0: error()

proc init(self: wBitmap, gdipbmp: ptr GpBitmap) =
  self.wGdiObject.init()

  # Here GdiplusStartupInput() already called.
  if GdipCreateHBITMAPFromBitmap(gdipbmp, addr mHandle, 0) != Ok:
    error()

  mDepth = 32
  var width, height: UINT
  GdipGetImageWidth(gdipbmp, addr width)
  GdipGetImageHeight(gdipbmp, addr height)
  mWidth = width
  mHeight = height

proc init(self: wBitmap, image: wImage) =
  init(image.mGdipBmp)

proc init(self: wBitmap, filename: string) =
  try:
    init(Image(filename))
  except:
    error()

proc init(self: wBitmap, data: ptr byte, length: int) =
  try:
    init(Image(data, length))
  except:
    error()

proc init(self: wBitmap, handle: HBITMAP, copy=true) =
  var bm: BITMAP
  if GetObject(handle, sizeof(BITMAP), addr bm) == 0:
    error()

  if copy:
    init(bm.bmWidth, bm.bmHeight, 32)
    var
      hdcSrc = CreateCompatibleDC(0)
      hdcDst = CreateCompatibleDC(0)
      prevSrc = SelectObject(hdcSrc, handle)
      prevDst = SelectObject(hdcDst, mHandle)

    defer:
      SelectObject(hdcSrc, prevSrc)
      SelectObject(hdcDst, prevDst)
      DeleteDC(hdcSrc)
      DeleteDC(hdcDst)

    BitBlt(hdcDst, 0, 0, bm.bmWidth, bm.bmHeight, hdcSrc, 0, 0, SRCCOPY)

  else:
    self.wGdiObject.init()
    mHandle = handle
    mWidth = bm.bmWidth
    mHeight = bm.bmHeight
    mDepth = int bm.bmBitsPixel

proc final(self: wBitmap) =
  self.wGdiObject.final()

proc getSize*(self: wBitmap): wSize {.validate, property, inline.} =
  ## Returns the size of the bitmap in pixels.
  result = (mWidth, mHeight)

proc getWidth*(self: wBitmap): int {.validate, property, inline.} =
  ## Gets the width of the bitmap in pixels.
  result = mWidth

proc getHeight*(self: wBitmap): int {.validate, property, inline.} =
  ## Gets the height of the bitmap in pixels.
  result = mHeight

proc getDepth*(self: wBitmap): int {.validate, property, inline.} =
  ## Gets the color depth of the bitmap.
  result = mDepth

# Bitmap name clash
proc Bmp*(width: int, height: int, depth: int = 0): wBitmap =
  ## Creates a new bitmap. A depth of 0 indicates the depth of the current screen.
  new(result, final)
  result.init(width=width, height=height, depth=depth)

proc Bmp*(size: wSize, depth: int = 0): wBitmap =
  ## Creates a new bitmap. A depth of 0 indicates the depth of the current screen.
  result = Bmp(size.width, size.height, depth)

proc Bmp*(handle: HBITMAP, copy=true): wBitmap =
  ## Creates a bitmap from a system bitmap handle.
  ## If copy is false, this only wrap it to wBitmap object.
  new(result, final)
  result.init(handle, copy)

proc Bmp*(image: wImage): wBitmap =
  ## Creates a bitmap object from the given wImage object.
  wValidate(image)
  new(result, final)
  result.init(image)

proc Bmp*(filename: string): wBitmap =
  ## Creates a bitmap object from a image file.
  wValidate(filename)
  new(result, final)
  result.init(filename)

proc Bmp*(data: ptr byte|ptr char|cstring, length: int): wBitmap =
  ## Creates a bitmap object from raw image data.
  wValidate(data)
  new(result, final)
  result.init(cast[ptr byte](data), length)
