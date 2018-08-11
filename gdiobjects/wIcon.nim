## An icon is a small rectangular bitmap usually used for denoting a minimized application.
##
## :Superclass:
##    wGdiObject

type
  wIconError* = object of wGdiObjectError
    ## An error raised when wIcon creation failure.

#todo:
# load from resource
# load from .ico file
# load from exe/dll, etc
# create for file or path?

proc error(self: wIcon) {.inline.} =
  raise newException(wIconError, "wIcon creation failure")

proc init(self: wIcon, image: wImage) =
  self.wGdiObject.init()

  # todo: GdipCreateHICONFromBitmap don't hanlde alpha channel well
  # write some code to do it by self
  if GdipCreateHICONFromBitmap(image.mGdipBmp, addr mHandle) != Ok:
    error()

  var width, height: UINT
  GdipGetImageWidth(image.mGdipBmp, addr width)
  GdipGetImageHeight(image.mGdipBmp, addr height)
  mWidth = width.int
  mHeight = height.int

proc init(self: wIcon, filename: string) =
  try:
    init(Image(filename))
  except:
    error()

proc init(self: wIcon, data: ptr byte, length: int) =
  try:
    init(Image(data, length))
  except:
    error()

proc final(self: wIcon) =
  self.wGdiObject.final()

proc getSize*(self: wIcon): wSize {.validate, property, inline.} =
  ## Gets the size of the icon in pixels.
  result = (mWidth, mHeight)

proc getWidth*(self: wIcon): int {.validate, property, inline.} =
  ## Gets the width of the icon in pixels.
  result = mWidth

proc getHeight*(self: wIcon): int {.validate, property, inline.} =
  ## Gets the height of the icon in pixels.
  result = mHeight

proc Icon*(image: wImage): wIcon =
  ## Creates an icon from the given wImage object.
  wValidate(image)
  new(result, final)
  result.init(image)

proc Icon*(filename: string): wIcon =
  ## Creates an icon from a image file.
  wValidate(filename)
  new(result, final)
  result.init(filename)

proc Icon*(data: ptr byte|ptr char|cstring, length: int): wIcon =
  ## Creates an icon from raw image data.
  wValidate(data)
  new(result, final)
  result.init(cast[ptr byte](data), length)

#todo: Copy constructor
