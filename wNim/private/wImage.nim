#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class encapsulates a platform-independent image. In wNim, wImage is
## a wrap of gdiplus image object.
#
## :Seealso:
##   `wImageList <wImageList.html>`_
##   `wBitmap <wBitmap.html>`_
##   `wIcon <wIcon.html>`_
##   `wCursor <wCursor.html>`_
##   `wIconImage <wIconImage.html>`_
#
## :Consts:
##
##   The quality used in scale, rescale, transform, and retransform.
##   ==============================  =============================================================
##   Consts                          Description
##   ==============================  =============================================================
##   wImageQualityNearest            Specifies nearest-neighbor interpolation.
##   wImageQualityBilinear           Specifies high-quality, bilinear interpolation.
##   wImageQualityBicubic            Specifies high-quality, bicubic interpolation.
##   wImageQualityNormal             Specifies the default interpolation mode.
##   wImageQualityHigh               Specifies a high-quality mode.
##   wImageQualityLow                Specifies a low-quality mode.
##   ==============================  =============================================================
##
##   Used in rotateFlip as flag.
##   ==============================  =============================================================
##   Consts                          Description
##   ==============================  =============================================================
##   wImageRotateNoneFlipNone        Specifies no rotation and no flipping.
##   wImageRotateNoneFlipX           Specifies no rotation and a horizontal flip.
##   wImageRotateNoneFlipY           Specifies no rotation and a vertical flip.
##   wImageRotateNoneFlipXY          Specifies no rotation, a horizontal flip, and then a vertical flip.
##   wImageRotate90FlipNone          Specifies a 90-degree rotation without flipping.
##   wImageRotate90FlipX             Specifies a 90-degree rotation followed by a horizontal flip.
##   wImageRotate90FlipY             Specifies a 90-degree rotation followed by a vertical flip.
##   wImageRotate90FlipXY            Specifies a 90-degree rotation followed by a horizontal flip and then a vertical flip.
##   wImageRotate180FlipNone         Specifies a 180-degree rotation without flipping.
##   wImageRotate180FlipX            Specifies a 180-degree rotation followed by a horizontal flip.
##   wImageRotate180FlipY            Specifies a 180-degree rotation followed by a vertical flip.
##   wImageRotate180FlipXY           Specifies a 180-degree rotation followed by a horizontal flip and then a vertical flip.
##   wImageRotate270FlipNone         Specifies a 270-degree rotation without flipping.
##   wImageRotate270FlipX            Specifies a 270-degree rotation followed by a horizontal flip.
##   wImageRotate270FlipY            Specifies a 270-degree rotation followed by a vertical flip.
##   wImageRotate270FlipXY           Specifies a 270-degree rotation followed by a horizontal flip and then a vertical flip.
##   ==============================  =============================================================

include pragma
import strutils, memlib/rtlib
import wBase

# For recursive module dependencies.
proc Image*(iconImage: wIconImage): wImage {.inline.}
proc delete*(self: wImage)
proc saveData*(self: wImage, fileType: string, quality: range[0..100] = 90): string
proc Image*(data: pointer, length: int): wImage {.inline.}

import wIconImage

type
  wImageError* = object of wError
    ## An error raised when wImage creation or operation failure.

  wPixelFormat* = enum
    wPixelFormat1bppIndexed ## Specifies that the format is 1 bit per pixel, indexed.
    wPixelFormat4bppIndexed ## Specifies that the format is 4 bits per pixel, indexed.
    wPixelFormat8bppIndexed ## Specifies that the format is 8 bits per pixel, indexed.
    wPixelFormat16bppARGB1555 ## Specifies that the format is 16 bits per pixel; 1 bit is used for the alpha component, and 5 bits each are used for the red, green, and blue components.
    wPixelFormat16bppGrayScale ## Specifies that the format is 16 bits per pixel, grayscale.
    wPixelFormat16bppRGB555 ## Specifies that the format is 16 bits per pixel; 5 bits each are used for the red, green, and blue components. The remaining bit is not used.
    wPixelFormat16bppRGB565 ## Specifies that the format is 16 bits per pixel; 5 bits are used for the red component, 6 bits are used for the green component, and 5 bits are used for the blue component.
    wPixelFormat24bppRGB ## Specifies that the format is 24 bits per pixel; 8 bits each are used for the red, green, and blue components.
    wPixelFormat32bppARGB ## Specifies that the format is 32 bits per pixel; 8 bits each are used for the alpha, red, green, and blue components.
    wPixelFormat32bppPARGB ## Specifies that the format is 32 bits per pixel; 8 bits each are used for the alpha, red, green, and blue components. The red, green, and blue components are premultiplied according to the alpha component.
    wPixelFormat32bppRGB ## Specifies that the format is 32 bits per pixel; 8 bits each are used for the red, green, and blue components. The remaining 8 bits are not used.
    wPixelFormat48bppRGB ## Specifies that the format is 48 bits per pixel; 16 bits each are used for the red, green, and blue components.
    wPixelFormat64bppARGB ## Specifies that the format is 64 bits per pixel; 16 bits each are used for the alpha, red, green, and blue components.
    wPixelFormat64bppPARGB ## Specifies that the format is 64 bits per pixel; 16 bits each are used for the alpha, red, green, and blue components. The red, green, and blue components are premultiplied according to the alpha component.

const
  # Image styles and consts
  wImageQualityNearest* = interpolationModeNearestNeighbor
  wImageQualityBilinear* = interpolationModeHighQualityBilinear
  wImageQualityBicubic* = interpolationModeHighQualityBicubic
  wImageQualityNormal* = interpolationModeDefault
  wImageQualityHigh* = interpolationModeHighQuality
  wImageQualityLow* = interpolationModeLowQuality

  wImageRotateNoneFlipNone* = rotateNoneFlipNone
  wImageRotateNoneFlipX* = rotateNoneFlipX
  wImageRotateNoneFlipY* = rotateNoneFlipY
  wImageRotateNoneFlipXY* = rotateNoneFlipXY
  wImageRotate90FlipNone* = rotate90FlipNone
  wImageRotate90FlipX* = rotate90FlipX
  wImageRotate90FlipY* = rotate90FlipY
  wImageRotate90FlipXY* = rotate90FlipXY
  wImageRotate180FlipNone* = rotate180FlipNone
  wImageRotate180FlipX* = rotate180FlipX
  wImageRotate180FlipY* = rotate180FlipY
  wImageRotate180FlipXY* = rotate180FlipXY
  wImageRotate270FlipNone* = rotate270FlipNone
  wImageRotate270FlipX* = rotate270FlipX
  wImageRotate270FlipY* = rotate270FlipY
  wImageRotate270FlipXY* = rotate270FlipXY

  wImageTypeBmp* = "BMP"
  wImageTypeGif* = "GIF"
  wImageTypeJpeg* = "JPG"
  wImageTypePng* = "PNG"
  wImageTypeTiff* = "TIF"
  wImageTypeIco* = "ICO"
  wBitmapTypeBmp* = "BMP"
  wBitmapTypeGif* = "GIF"
  wBitmapTypeJpeg* = "JPG"
  wBitmapTypePng* = "PNG"
  wBitmapTypeTiff* = "TIF"
  wBitmapTypeIco* = "ICO"

proc error(self: wImage) {.inline.} =
  raise newException(wImageError, "wImage creation failed")

proc fail() {.inline.} =
  raise newException(wImageError, "")

var
  wGdiplusToken {.threadvar.}: ULONG_PTR

proc wGdipInit() =
  if wGdiplusToken == 0:
    var si = GdiplusStartupInput(GdiplusVersion: 1)
    GdiplusStartup(&wGdiplusToken, si, nil)

proc SHCreateMemStream(pInit: pointer, cbInit: UINT): ptr IStream
  {.checkedRtlib: "shlwapi", stdcall, importc: 12.}

proc wGdipCreateStreamOnMemory(data: pointer, length: int = 0): ptr IStream =
  try:
    result = SHCreateMemStream(data, UINT length)

  except LibraryError:
    discard

proc wGdipReadStream(stream: ptr IStream, data: var string) =
  var stg: STATSTG
  if stream.Stat(&stg, STATFLAG_NONAME) != S_OK: fail()

  var dlibMove = LARGE_INTEGER(QuadPart: 0)
  if stream.Seek(dlibMove, STREAM_SEEK_SET, nil) != S_OK: fail()

  var length = stg.cbSize.LowPart
  data = newString(length)

  var bytesRead: ULONG
  if stream.Read(&data, length, &bytesRead) != S_OK: fail()
  data.setLen(bytesRead)

proc wGdipAlign(x, y: var int32, width1, height1, width2, height2: int32, align: int) =
  if (align and wCenter) == wCenter:
    x = (width1 - width2) div 2
  elif (align and wRight) != 0:
    x = width1 - width2
  elif (align and wLeft) != 0:
    x = 0

  if (align and wMiddle) == wMiddle:
    y = (height1 - height2) div 2
  elif (align and wDown) != 0:
    y = height1 - height2
  elif (align and wUp) != 0:
    y = 0

iterator wGdipEncoderExtClsids(): tuple[ext: string, clsid: CLSID] =
  var count, size: UINT
  if GdipGetImageEncodersSize(&count, &size) != Ok: fail()

  var encoders = cast[ptr UncheckedArray[ImageCodecInfo]](alloc(size))
  defer: dealloc(encoders)

  if GdipGetImageEncoders(count, size, &encoders[0]) != Ok: fail()
  for i in 0..<count:
    for ext in ($encoders[i].FilenameExtension).split({';'}):
      yield (ext.replace("*.", ""), encoders[i].Clsid)

iterator wGdipDecoderExt(): string =
  var count, size: UINT
  if GdipGetImageDecodersSize(&count, &size) != Ok: fail()

  var decoders = cast[ptr UncheckedArray[ImageCodecInfo]](alloc(size))
  defer: dealloc(decoders)

  if GdipGetImageDecoders(count, size, &decoders[0]) != Ok: fail()
  for i in 0..<count:
    for ext in ($decoders[i].FilenameExtension).split({';'}):
      yield ext.replace("*.", "")

proc wGdipGetEncoderCLSID(fileType: string): CLSID =
  for tup in wGdipEncoderExtClsids():
    if fileType.cmpIgnoreCase(tup.ext) == 0:
      return tup.clsid

  fail()

proc wGdipScale(gdipbmp: ptr GpBitmap, width, height: int,
    quality: InterpolationMode): ptr GpBitmap =

  var graphic: ptr GpGraphics
  try:
    if GdipCreateBitmapFromScan0(width, height, 4 * width,
        pixelFormat32bppARGB, nil, &result) != Ok: fail()
    if GdipGetImageGraphicsContext(result, &graphic) != Ok: fail()
    if GdipSetInterpolationMode(graphic, quality) != Ok: fail()
    if GdipDrawImageRectI(graphic, gdipbmp, 0, 0, width, height) != Ok: fail()
  except:
    if result != nil:
      GdipDisposeImage(result)
      result = nil
  finally:
    if graphic != nil:
      GdipDeleteGraphics(graphic)

proc wGdipSize(gdipbmp: ptr GpBitmap, size: wSize, pos: wPoint,
    align: int = 0): ptr GpBitmap =

  var graphic: ptr GpGraphics
  try:
    var
      width = int32 size.width
      height = int32 size.height
      width2, height2: int32
      x = int32 pos.x
      y = int32 pos.y

    if GdipGetImageWidth(gdipbmp, cast[ptr UINT](&width2)) != Ok: fail()
    if GdipGetImageHeight(gdipbmp, cast[ptr UINT](&height2)) != Ok: fail()

    if width2 <= 0 or height2 <= 0: fail()
    if align != 0: wGdipAlign(x, y, width, height, width2, height2, align)

    if GdipCreateBitmapFromScan0(width, height, 4 * width, pixelFormat32bppARGB,
      nil, &result) != Ok: fail()
    if GdipGetImageGraphicsContext(result, &graphic) != Ok: fail()
    if GdipDrawImageRectI(graphic, gdipbmp, x, y, width2, height2) != Ok: fail()
  except:
    if result != nil:
      GdipDisposeImage(result)
      result = nil
  finally:
    if graphic != nil:
      GdipDeleteGraphics(graphic)

proc wGdipTransform(gdipbmp: ptr GpBitmap, scaleX, scaleY, angle,
    deltaX, deltaY: float, quality: InterpolationMode): ptr GpBitmap =

  var graphic: ptr GpGraphics
  try:
    var width, height: int32
    if GdipGetImageWidth(gdipbmp, cast[ptr UINT](&width)) != Ok: fail()
    if GdipGetImageHeight(gdipbmp, cast[ptr UINT](&height)) != Ok: fail()
    if width <= 0 or height <= 0: fail()

    if GdipCreateBitmapFromScan0(width, height, 4 * width, pixelFormat32bppARGB,
      nil, &result) != Ok: fail()
    if GdipGetImageGraphicsContext(result, &graphic) != Ok: fail()
    if GdipSetInterpolationMode(graphic, quality) != Ok: fail()

    var
      newWidth = int32(width.float * scaleX)
      newHeight = int32(height.float * scaleY)
      diffX = width - newWidth
      diffY = height - newHeight
      centerX = width / 2
      centerY = height / 2

    if GdipTranslateWorldTransform(graphic, centerX + deltaX, centerY + deltaY,
      matrixOrderPrepend) != Ok: fail()
    if GdipRotateWorldTransform(graphic, angle, matrixOrderPrepend) != Ok: fail()
    if GdipTranslateWorldTransform(graphic, -centerX, -centerY,
      matrixOrderPrepend) != Ok: fail()
    if GdipDrawImageRectI(graphic, gdipbmp, diffX div 2, diffY div 2,
      newWidth, newHeight) != Ok: fail()

  except:
    if result != nil:
      GdipDisposeImage(result)
      result = nil
  finally:
    if graphic != nil:
      GdipDeleteGraphics(graphic)

proc wGdipPaste(gdipbmp1, gdipbmp2: ptr GpBitmap, x, y: int32, align: int = 0): bool =
  var
    width1, height1, width2, height2: int32
    graphic: ptr GpGraphics
    x = x
    y = y

  if GdipGetImageWidth(gdipbmp1, cast[ptr UINT](&width1)) != Ok: return false
  if GdipGetImageHeight(gdipbmp1, cast[ptr UINT](&height1)) != Ok: return false
  if GdipGetImageWidth(gdipbmp2, cast[ptr UINT](&width2)) != Ok: return false
  if GdipGetImageHeight(gdipbmp2, cast[ptr UINT](&height2)) != Ok: return false

  if width1 <= 0 or height1 <= 0 or width2 <= 0 or height2 <= 0: return false
  if align != 0: wGdipAlign(x, y, width1, height1, width2, height2, align)

  if GdipGetImageGraphicsContext(gdipbmp1, &graphic) != Ok: return false
  defer: GdipDeleteGraphics(graphic)

  if GdipDrawImageRectI(graphic, gdipbmp2, x, y, width2, height2) != Ok: return false
  return true

proc wGdipGetQualityParameters(quality: var LONG): EncoderParameters =
  result.Count = 1
  result.Parameter[0].Guid = EncoderQuality
  result.Parameter[0].Type = encoderParameterValueTypeLong.ord
  result.Parameter[0].NumberOfValues = 1;
  result.Parameter[0].Value = &quality

proc delete*(self: wImage) {.validate.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  `=destroy`(self[])

proc getHandle*(self: wImage): ptr GpBitmap {.validate, property, inline.} =
  ## Gets the real resource handle of gdiplus bitmap.
  result = self.mGdipBmp

proc getWidth*(self: wImage): int {.validate, property.} =
  ## Gets the width of the image in pixels.
  var width: UINT
  if GdipGetImageWidth(self.mGdipBmp, &width) != Ok:
    raise newException(wImageError, "wImage getWidth failure")
  result = int width

proc getHeight*(self: wImage): int {.validate, property.} =
  ## Gets the height of the image in pixels.
  var height: UINT
  if GdipGetImageHeight(self.mGdipBmp, &height) != Ok:
    raise newException(wImageError, "wImage getHeight failure")
  result = int height

proc getSize*(self: wImage): wSize {.validate, property, inline.} =
  ## Returns the size of the image in pixels.
  result.width = self.getWidth()
  result.height = self.getHeight()

proc getPixel*(self: wImage, x: int, y: int): ARGB {.validate, property.} =
  ## Return the ARGB value at given pixel location.
  if GdipBitmapGetPixel(self.mGdipBmp, x, y, &result) != Ok:
    raise newException(wImageError, "wImage getPixel failure")

proc getPixel*(self: wImage, pos: wPoint): ARGB {.validate, property.} =
  ## Return the ARGB value at given pixel location.
  result = self.getPixel(pos.x, pos.y)

proc setPixel*(self: wImage, x: int, y: int, color: ARGB) {.validate, property.} =
  ## Set the ARGB value at given pixel location.
  if GdipBitmapSetPixel(self.mGdipBmp, x, y, color) != Ok:
    raise newException(wImageError, "wImage setPixel failure")

proc setPixel*(self: wImage, pos: wPoint, color: ARGB) {.validate, property.} =
  ## Set the ARGB value at given pixel location.
  self.setPixel(pos.x, pos.y, color)

proc getRed*(self: wImage, x: int, y: int): byte {.validate, property.} =
  ## Returns the red intensity at the given coordinate.
  try:
    result = GetRValue(self.getPixel(x, y))
  except:
    raise newException(wImageError, "wImage getRed failure")

proc getRed*(self: wImage, pos: wPoint): byte {.validate, property.} =
  ## Returns the red intensity at the given coordinate.
  result = self.getRed(pos.x, pos.y)

proc getGreen*(self: wImage, x: int, y: int): byte {.validate, property.} =
  ## Returns the green intensity at the given coordinate.
  try:
    result = GetGValue(self.getPixel(x, y))
  except:
    raise newException(wImageError, "wImage getGreen failure")

proc getGreen*(self: wImage, pos: wPoint): byte {.validate, property.} =
  ## Returns the green intensity at the given coordinate.
  result = self.getGreen(pos.x, pos.y)

proc getBlue*(self: wImage, x: int, y: int): byte {.validate, property.} =
  ## Returns the blue intensity at the given coordinate.
  try:
    result = GetBValue(self.getPixel(x, y))
  except:
    raise newException(wImageError, "wImage getBlue failure")

proc getBlue*(self: wImage, pos: wPoint): byte {.validate, property.} =
  ## Returns the blue intensity at the given coordinate.
  result = self.getBlue(pos.x, pos.y)

proc getAlpha*(self: wImage, x: int, y: int): byte {.validate, property.} =
  ## Return alpha value at given pixel location.
  try:
    result = cast[byte](self.getPixel(x, y) shr 24)
  except:
    raise newException(wImageError, "wImage getAlpha failure")

proc getAlpha*(self: wImage, pos: wPoint): byte {.validate, property.} =
  ## Return alpha value at given pixel location.
  result = self.getAlpha(pos.x, pos.y)

iterator getEncoders*(self: wImage): string {.validate.} =
  ## Iterates over each available image encoder on system.
  # also use validate pragma to ensure wGdipInit() was called.
  try:
    for tup in wGdipEncoderExtClsids():
      yield tup.ext
  except:
    raise newException(wImageError, "wImage getEncoders failure")

iterator getDecoders*(self: wImage): string {.validate.} =
  ## Iterates over each available image decoder on system.
  # also use validate pragma to ensure wGdipInit() was called.
  try:
    for ext in wGdipDecoderExt():
      yield ext
  except:
    raise newException(wImageError, "wImage getEncoders failure")

proc saveFile*(self: wImage, filename: string, fileType = "",
    quality: range[0..100] = 90) {.validate.} =
  ## Saves an image into the file. If fileType is empty, use extension name as
  ## fileType. Use getEncoders iterator to list the supported format.
  try:
    var ext = fileType
    if ext.len == 0:
      let dot = filename.rfind('.')
      if dot == -1: fail()

      ext = filename.substr(dot + 1)
      if ext.len == 0: fail()

    var
      quality: LONG = quality
      encoderParameters = wGdipGetQualityParameters(quality)
      clsid = wGdipGetEncoderCLSID(ext)

    if GdipSaveImageToFile(self.mGdipBmp, +$filename, clsid, &encoderParameters) != Ok: fail()

  except:
    raise newException(wImageError, "wImage saveFile failure")

proc saveData*(self: wImage, fileType: string, quality: range[0..100] = 90): string
    {.validate.} =
  ## Saves an image into binary data (stored as string).
  ## Use getEncoders iterator to list the supported format.
  try:
    var
      quality: LONG = quality
      encoderParameters = wGdipGetQualityParameters(quality)
      clsid = wGdipGetEncoderCLSID(fileType)

    let stream = wGdipCreateStreamOnMemory(nil)
    defer:
      if stream != nil: stream.Release()

    if stream == nil or GdipSaveImageToStream(self.mGdipBmp, stream, clsid,
      &encoderParameters) != Ok: fail()
    wGdipReadStream(stream, result)

  except:
    raise newException(wImageError, "wImage saveData failure")

wClass(wImage):

  proc init*(self: wImage, gdip: ptr GpBitmap, copy = true) {.validate.} =
    ## Initializes an image from a gdiplus bitmap handle.
    ## If copy is false, this only wrap it to wImage object. It means the handle
    ## will be destroyed by wImage when it is destroyed.
    wValidate(gdip)
    wGdipInit()
    if copy:
      if GdipCloneImage(gdip, cast[ptr ptr GpImage](&self.mGdipBmp)) != Ok:
        self.error()
    else:
      self.mGdipBmp = gdip

  proc init*(self: wImage, image: wImage) {.validate, inline.} =
    ## Initializes an image from wImage object, aka. copy constructors.
    wValidate(image)
    self.init(image.mGdipBmp, copy=true)

  proc init*(self: wImage, bmp: wBitmap) {.validate.} =
    ## Initializes an image from wBitmap object.
    wValidate(bmp)
    wGdipInit()

    # if the bmp is 32bit argb format, don't use GdipCreateBitmapFromHBITMAP
    # otherwise the result will loss the alpha channel data.
    try:
      var dibSection: DIBSECTION
      if GetObject(bmp.mHandle, sizeof(dibSection), &dibSection) == 0: fail()

      var
        scan0 = cast[ptr BYTE](dibSection.dsBm.bmBits)
        bitCount = dibSection.dsBm.bmBitsPixel
        width = dibSection.dsBmih.biWidth
        height = dibSection.dsBmih.biHeight

      if bitCount != 32: fail()

      if GdipCreateBitmapFromScan0(width, height, 4 * width, pixelFormat32bppARGB,
        scan0, &self.mGdipBmp) != Ok: fail()

      if GdipImageRotateFlip(self.mGdipBmp, rotateNoneFlipY) != Ok: fail()

    except:
      if GdipCreateBitmapFromHBITMAP(bmp.mHandle, 0, &self.mGdipBmp) != Ok:
        self.error()

  proc init*(self: wImage, data: pointer, length: int) {.validate.} =
    ## Initializes an image from binary image data.
    ## Use getDecoders iterator to list the supported format.
    wValidate(data)
    wGdipInit()
    let stream = wGdipCreateStreamOnMemory(data, length)
    defer:
      if stream != nil: stream.Release()

    if stream == nil or GdipCreateBitmapFromStream(stream, &self.mGdipBmp) != Ok:
      self.error()

  proc init*(self: wImage, str: string) {.validate.} =
    ## Initializes an image from a file.
    ## Use getDecoders iterator to list the supported format.
    ## If str is not a valid file path, it will be regarded as the binary data in memory.
    ## For example:
    ##
    ## .. code-block:: Nim
    ##   const data = staticRead("test.png")
    ##   var image = Image(data)
    wGdipInit()
    if str.isVaildPath():
      if GdipCreateBitmapFromFile(str, &self.mGdipBmp) != Ok:
        self.error()
    else:
      self.init(&str, str.len)

  proc init*(self: wImage, width: int, height: int) {.validate.} =
    ## Initializes an empty image with the given size.
    wGdipInit()
    if GdipCreateBitmapFromScan0(width, height, 4 * width, pixelFormat32bppARGB,
        nil, &self.mGdipBmp) != Ok:
      self.error()

  proc init*(self: wImage, size: wSize) {.validate, inline.} =
    ## Initializes an empty image with the given size.
    self.init(size.width, size.height)

  proc init*(self: wImage, iconImage: wIconImage) {.validate.} =
    ## Initializes an image from a wIconImage object.
    wValidate(iconImage)
    if iconImage.isPng():
      self.init(&iconImage.mIcon, iconImage.mIcon.len)

    else:
      if iconImage.getBitCount() == 32:
        wGdipInit()
        var
          (width, height) = iconImage.getSize()
          scan0 = cast[ptr BYTE](cast[int](&iconImage.mIcon) + sizeof(BITMAPINFOHEADER))

        if GdipCreateBitmapFromScan0(width, height, 4 * width, pixelFormat32bppARGB,
          scan0, &self.mGdipBmp) != Ok: self.error()

        if GdipImageRotateFlip(self.mGdipBmp, rotateNoneFlipY) != Ok: self.error()

      else:
        var data = iconImage.save()
        self.init(&data, data.len)

  proc init*(self: wImage, icon: wIcon) {.validate.} =
    ## Initializes an image from wIcon object.
    wValidate(icon)
    try:
      self.init(IconImage(icon))
    except wError:
      self.error()

  proc init*(self: wImage, cursor: wCursor) {.validate.} =
    ## Initializes an image from wCursor object.
    wValidate(cursor)
    try:
      self.init(IconImage(cursor))
    except wError:
      self.error()

  proc init*(self: wImage, width: int, height: int, stride: int, format: wPixelFormat,
      scan0: pointer) {.validate.} =
    ## Initializes an image based on binary bytes along with size and format information.
    let format = case format
      of wPixelFormat1bppIndexed: pixelFormat1bppIndexed
      of wPixelFormat4bppIndexed: pixelFormat4bppIndexed
      of wPixelFormat8bppIndexed: pixelFormat8bppIndexed
      of wPixelFormat16bppARGB1555: pixelFormat16bppARGB1555
      of wPixelFormat16bppGrayScale: pixelFormat16bppGrayScale
      of wPixelFormat16bppRGB555: pixelFormat16bppRGB555
      of wPixelFormat16bppRGB565: pixelFormat16bppRGB565
      of wPixelFormat24bppRGB: pixelFormat24bppRGB
      of wPixelFormat32bppARGB: pixelFormat32bppARGB
      of wPixelFormat32bppPARGB: pixelFormat32bppPARGB
      of wPixelFormat32bppRGB: pixelFormat32bppRGB
      of wPixelFormat48bppRGB: pixelFormat48bppRGB
      of wPixelFormat64bppARGB: pixelFormat64bppARGB
      of wPixelFormat64bppPARGB: pixelFormat64bppPARGB

    if GdipCreateBitmapFromScan0(width, height, stride, format,
      cast[ptr BYTE](scan0), &self.mGdipBmp) != Ok: self.error()

proc scale*(self: wImage, width, height: int, quality = wImageQualityNormal): wImage
    {.validate.} =
  ## Returns a scaled version of the image.
  let newGdipbmp = wGdipScale(self.mGdipBmp, width, height, quality)
  if newGdipbmp.isNil: raise newException(wImageError, "wImage scale failure")
  result = Image(newGdipbmp, copy=false)

proc scale*(self: wImage, size: wSize, quality = wImageQualityNormal): wImage
    {.validate, inline.} =
  ## Returns a scaled version of the image.
  result = self.scale(size.width, size.height, quality)

proc rescale*(self: wImage, width, height: int, quality = wImageQualityNormal)
    {.validate, discardable.} =
  ## Changes the size of the image in-place by scaling it.
  let newGdipbmp = wGdipScale(self.mGdipBmp, width, height, quality)
  if newGdipbmp.isNil: raise newException(wImageError, "wImage rescale failure")
  GdipDisposeImage(self.mGdipBmp)
  self.mGdipBmp = newGdipbmp

proc rescale*(self: wImage, size: wSize, quality = wImageQualityNormal)
    {.validate, inline, discardable.} =
  ## Changes the size of the image in-place by scaling it.
  self.rescale(size.width, size.height, quality)

proc size*(self: wImage, size: wSize, pos: wPoint = (0, 0), align = 0): wImage
    {.validate.} =
  ## Returns a resized version of this image without scaling it.
  ## The image is pasted into a new image at the position pos or by given align.
  ## *align* can be combine of wRight, wCenter, wLeft, wUp, wMiddle, wDown.
  let newGdipbmp = wGdipSize(self.mGdipBmp, size, pos, align)
  if newGdipbmp.isNil: raise newException(wImageError, "wImage size failure")
  result = Image(newGdipbmp, copy=false)

proc size*(self: wImage, width, height: int, x = 0, y = 0, align = 0): wImage
    {.validate, inline.} =
  ## Returns a resized version of this image without scaling it.
  result = self.size((width, height), (x, y), align)

proc resize*(self: wImage, size: wSize, pos: wPoint = (0, 0), align = 0)
    {.validate, discardable.} =
  ## Changes the size of the image in-place without scaling it.
  let newGdipbmp = wGdipSize(self.mGdipBmp, size, pos, align)
  if newGdipbmp.isNil: raise newException(wImageError, "wImage resize failure")
  GdipDisposeImage(self.mGdipBmp)
  self.mGdipBmp = newGdipbmp

proc resize*(self: wImage, width, height: int, x = 0, y = 0, align = 0)
    {.validate, discardable.} =
  ## Changes the size of the image in-place without scaling it.
  self.resize((width, height), (x, y), align)

proc transform*(self: wImage, scaleX = 1.0, scaleY = 1.0,
    angle = 0.0, deltaX = 0.0, deltaY = 0.0,
    quality = wImageQualityNormal): wImage {.validate.} =
  ## Returned a transformed version of this image by given parameters.
  let newGdipbmp = wGdipTransform(self.mGdipBmp, scaleX, scaleY, angle, deltaX, deltaY, quality)
  if newGdipbmp.isNil: raise newException(wImageError, "wImage transform failure")
  result = Image(newGdipbmp, copy=false)

proc retransform*(self: wImage, scaleX = 1.0, scaleY = 1.0,
    angle = 0.0, deltaX = 0.0, deltaY = 0.0,
    quality = wImageQualityNormal) {.validate, discardable.} =
  ## Transforms the image in-place.
  let newGdipbmp = wGdipTransform(self.mGdipBmp, scaleX, scaleY, angle, deltaX, deltaY, quality)
  if newGdipbmp.isNil: raise newException(wImageError, "wImage transform failure")
  GdipDisposeImage(self.mGdipBmp)
  self.mGdipBmp = newGdipbmp

proc paste*(self: wImage, image: wImage, x = 0, y = 0, align = 0)
    {.validate, discardable.} =
  ## Copy the data of the given image to the specified position in this image.
  wValidate(image)
  if not wGdipPaste(self.mGdipBmp, image.mGdipBmp, x, y, align):
    raise newException(wImageError, "wImage paste failure")

proc paste*(self: wImage, image: wImage, pos: wPoint, align = 0)
    {.validate, discardable.} =
  ## Copy the data of the given image to the specified position in this image.
  wValidate(image)
  self.paste(image, pos.x, pos.y, align)

proc rotateFlip*(self: wImage, flag: int) {.validate, discardable.} =
  ## Rotates or flip the image.
  if GdipImageRotateFlip(self.mGdipBmp, flag) != Ok:
    raise newException(wImageError, "wImage rotateFlip failure")

proc rotateFlip*(self: wImage, angle: int, flipX: bool, flipY: bool)
    {.validate, discardable.} =
  ## Rotates or flip the image. Angle should be one of 0, 90, 180, 270.
  type Flip = enum NONE, X, Y, XY
  var flip: Flip
  if flipX and flipY: flip = XY
  if flipX and not flipY: flip = X
  if not flipX and flipY: flip = Y
  if not flipX and not flipY: flip = NONE

  var flag: RotateFlipType
  case angle:
  of 0:
    flag = case flip:
    of NONE: wImageRotateNoneFlipNone
    of X: wImageRotateNoneFlipX
    of Y: wImageRotateNoneFlipY
    of XY: wImageRotateNoneFlipXY
  of 90:
    flag = case flip:
    of NONE: wImageRotate90FlipNone
    of X: wImageRotate90FlipX
    of Y: wImageRotate90FlipY
    of XY: wImageRotate90FlipXY
  of 180:
    flag = case flip:
    of NONE: wImageRotate180FlipNone
    of X: wImageRotate180FlipX
    of Y: wImageRotate180FlipY
    of XY: wImageRotate180FlipXY
  of 270:
    flag = case flip:
    of NONE: wImageRotate270FlipNone
    of X: wImageRotate270FlipX
    of Y: wImageRotate270FlipY
    of XY: wImageRotate270FlipXY
  else: raise newException(wImageError, "wImage rotateFlip failure")
  self.rotateFlip(flag)

proc getSubImage*(self: wImage, rect: wRect): wImage {.validate.} =
  ## Returns a sub image of the current one as long as the rect belongs entirely
  ## to the image.
  try:
    result = self.size((rect.width, rect.height), (-rect.x, -rect.y))
  except:
    raise newException(wImageError, "wImage getSubImage failure")

proc crop*(self: wImage, x, y, width, height: int): wImage {.validate.} =
  ## Returns a cropped image of the current one as long as the rect belongs
  ## entirely to the image.
  try:
    result = self.size((width, height), (-x, -y))
  except:
    raise newException(wImageError, "wImage crop failure")

when not defined(useWinXP):
  # need GDI+ 1.1, vista later
  proc effect(self: wImage, guid: GUID, pParam: pointer, size: int) {.validate.} =
    var
      effect: ptr CGpEffect
      rect: RECT
      newGdipbmp: ptr GpBitmap

    rect.right = self.getWidth()
    rect.bottom = self.getHeight()

    if GdipCreateEffect(guid, &effect) != Ok: fail()
    defer: GdipDeleteEffect(effect)

    if GdipSetEffectParameters(effect, pParam, size.UINT) != Ok: fail()
    # if GdipBitmapApplyEffect(mGdipBmp, effect, nil, false, nil, nil) != Ok: fail()
    # GdipBitmapApplyEffect sometimes crash due to unknow reason (only 64bit)

    # if don't set rect, the image size will change?
    if GdipBitmapCreateApplyEffect(&self.mGdipBmp, 1, effect, &rect, nil, &newGdipbmp,
      false, nil, nil) != Ok: fail()

    GdipDisposeImage(self.mGdipBmp)
    self.mGdipBmp = newGdipbmp

  proc blur*(self: wImage, radius: range[0..255] = 0, expandEdge = true)
      {.validate.} =
    ## Blur effect (Windows Vista or later).
    var param = BlurParams(radius: radius.float32, expandEdge: expandEdge)
    try:
      self.effect(BlurEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage blur failure")

  proc brightnessContrast*(self: wImage, brightness: range[-255..255] = 0,
      contrast: range[-100..100] = 0) {.validate.} =
    ## Brightness or contrast adjustment (Windows Vista or later).
    var param = BrightnessContrastParams(brightnessLevel: brightness,
      contrastLevel: contrast)

    try:
      self.effect(BrightnessContrastEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage brightnessContrast failure")

  proc sharpen*(self: wImage, radius: range[0..255] = 0, amount: range[0..100] = 0)
      {.validate.} =
    ## Sharpen effect (Windows Vista or later).
    var param = SharpenParams(radius: radius.float32, amount: amount.float32)
    try:
      self.effect(SharpenEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage sharpen failure")

  proc tint*(self: wImage, hue: range[-180..180] = 0, amount: range[0..100] = 0)
      {.validate.} =
    ## Tint effect (Windows Vista or later).
    var param = TintParams(hue: hue, amount: amount)
    try:
      self.effect(TintEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage tint failure")

  proc hueSaturationLightness*(self: wImage, hue: range[-180..180] = 0,
      saturation: range[-100..100] = 0, lightness: range[-100..100] = 0)
      {.validate.} =
    ## Hue, saturation, or lightness adjustment (Windows Vista or later).
    var param = HueSaturationLightnessParams(hueLevel: hue,
      saturationLevel: saturation, lightnessLevel: lightness)

    try:
      self.effect(HueSaturationLightnessEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage hueSaturationLightness failure")

  proc colorBalance*(self: wImage, cyanRed: range[-100..100] = 0,
      magentaGreen: range[-100..100] = 0, yellowBlue: range[-100..100] = 0)
      {.validate.} =
    ## Color balance adjustment (Windows Vista or later).
    var param = ColorBalanceParams(cyanRed: cyanRed, magentaGreen: magentaGreen,
      yellowBlue: yellowBlue)

    try:
      self.effect(ColorBalanceEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage colorBalance failure")

  proc levels*(self: wImage, highlight: range[0..100] = 0,
      midtone: range[-100..100] = 0, shadow: range[0..100] = 0) {.validate.} =
    ## Light, midtone, or dark adjustment (Windows Vista or later).
    var param = LevelsParams(highlight: highlight, midtone: midtone, shadow: shadow)
    try:
      self.effect(LevelsEffectGuid, &param, sizeof(param))
    except:
      raise newException(wImageError, "wImage levels failure")
