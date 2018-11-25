#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## An icon is a small rectangular bitmap usually used for denoting a minimized
## application.
#
## :Superclass:
##   `wGdiObject <wGdiObject.html>`_
#
## :Seealso:
##   `wDC <wDC.html>`_
##   `wPredefined <wPredefined.html>`_

type
  wIconError* = object of wGdiObjectError
    ## An error raised when wIcon creation failure.

proc error(self: wIcon) {.inline.} =
  raise newException(wIconError, "wIcon creation failure")

proc getSize*(self: wIcon): wSize {.validate, property, inline.} =
  ## Gets the size of the icon in pixels.
  result = (self.mWidth, self.mHeight)

proc getWidth*(self: wIcon): int {.validate, property, inline.} =
  ## Gets the width of the icon in pixels.
  result = self.mWidth

proc getHeight*(self: wIcon): int {.validate, property, inline.} =
  ## Gets the height of the icon in pixels.
  result = self.mHeight

method delete*(self: wIcon) {.inline.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  if self.mHandle != 0:
    DestroyIcon(self.mHandle)
    self.mHandle = 0

proc final*(self: wIcon) =
  ## Default finalizer for wIcon.
  self.delete()

proc wIcon_FromImage(self: wIcon, image: wImage, size = wDefaultSize) =
  # todo: GdipCreateHICONFromBitmap don't hanlde alpha channel very well.

  var image = image
  var imgSize = image.getSize()
  var isResize = false

  if size.width > 0 and size.width != imgSize.width:
    isResize = true
    self.mWidth = size.width
  else:
    self.mWidth = imgSize.width

  if size.height > 0 and size.height != imgSize.height:
    isResize = true
    self.mHeight = size.height
  else:
    self.mHeight = imgSize.height

  if isResize:
    image = image.scale(self.mWidth, self.mHeight)

  if GdipCreateHICONFromBitmap(image.mGdipBmp, &self.mHandle) != Ok:
    self.error()

proc init*(self: wIcon, image: wImage, size = wDefaultSize) {.validate, inline.} =
  ## Initializer.
  wValidate(image)
  self.wGdiObject.init()
  self.wIcon_FromImage(image, size)

proc Icon*(image: wImage, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from the given wImage object.
  wValidate(image)
  new(result, final)
  result.init(image, size)

proc init*(self: wIcon, data: ptr byte, length: int, size = wDefaultSize) {.validate.} =
  ## Initializer.
  wValidate(data)
  self.wGdiObject.init()
  # createIconFromMemory better than Image() becasue it choose
  # best fits icon in icon group, and it supports .ani format.
  self.mHandle = createIconFromMemory(data, length, width=size.width,
    height=size.height, isIcon=true)

  if self.mHandle != 0:
    (self.mWidth, self.mHeight) = getIconSize(self.mHandle)
  else:
    self.wIcon_FromImage(Image(data, length), size)

proc Icon*(data: ptr byte, length: int, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from binary data of image file format.
  ## Supports .ico, .cur (choose best fits image from group), .ani (without animated),
  ## and other formats that wImage supported.
  wValidate(data)
  new(result, final)
  result.init(data, length, size)

proc init*(self: wIcon, str: string, size = wDefaultSize) {.validate.} =
  ## Initializer.
  wValidate(str)
  var
    buffer: ptr byte
    length: int
    data: string

  if str.isVaildPath():
    data = readFile(str)
    buffer = cast[ptr byte](&data)
    length = data.len
  else:
    buffer = cast[ptr byte](&str)
    length = str.len

  self.init(buffer, length, size)

proc Icon*(str: string, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from a image file.
  ## If str is not a valid file path, it will be regarded as the binary data in memory.
  wValidate(str)
  new(result, final)
  result.init(str, size)

proc init*(self: wIcon, file: string, index: int, size = wDefaultSize) {.validate.} =
  ## Initializer.
  wValidate(file)
  self.wGdiObject.init()
  self.mHandle = createIconFromPE(file, index, size.width, size.height)
  if self.mHandle != 0:
    (self.mWidth, self.mHeight) = getIconSize(self.mHandle)
  else:
    self.error()

proc Icon*(file: string, index: int, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from a PE file (.exe or .dll).
  ## Empty string indicates the current executable file.
  ## Positive index indicates the icon position, and negative value indicates the
  ## icon ID.
  wValidate(file)
  new(result, final)
  result.init(file, index, size)

proc init*(self: wIcon, hIcon: HICON, copy = true) {.validate.} =
  ## Initializer.
  self.wGdiObject.init()
  if copy:
    self.mHandle = createIconFromHIcon(hIcon, isIcon=true)
  else:
    self.mHandle = hIcon

  if self.mHandle != 0:
    (self.mWidth, self.mHeight) = getIconSize(self.mHandle)
  else:
    self.error()

proc Icon*(hIcon: HICON, copy = true): wIcon {.inline.} =
  ## Creates an icon from Windows icon handle.
  ## If copy is false, this only wrap it to wIcon object.
  ## Notice this means the handle will be destroyed by wIcon when it is destroyed.
  new(result, final)
  result.init(hIcon, copy)

proc init*(self: wIcon, icon: wIcon) {.validate.} =
  ## Initializer.
  wValidate(icon)
  self.init(icon.mHandle)

proc Icon*(icon: wIcon): wIcon {.inline.} =
  ## Creates an icon from wIcon object, aka. copy constructors.
  wValidate(icon)
  new(result, final)
  result.init(icon)
