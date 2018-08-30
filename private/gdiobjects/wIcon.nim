## An icon is a small rectangular bitmap usually used for denoting a minimized application.
##
## :Superclass:
##    wGdiObject

type
  wIconError* = object of wGdiObjectError
    ## An error raised when wIcon creation failure.

proc error(self: wIcon) {.inline.} =
  raise newException(wIconError, "wIcon creation failure")

proc getSize*(self: wIcon): wSize {.validate, property, inline.} =
  ## Gets the size of the icon in pixels.
  result = (mWidth, mHeight)

proc getWidth*(self: wIcon): int {.validate, property, inline.} =
  ## Gets the width of the icon in pixels.
  result = mWidth

proc getHeight*(self: wIcon): int {.validate, property, inline.} =
  ## Gets the height of the icon in pixels.
  result = mHeight

method delete*(self: wIcon) {.inline.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  if mHandle != 0:
    DestroyIcon(mHandle)
    mHandle = 0

proc final*(self: wIcon) =
  ## Default finalizer for wIcon.
  delete()

proc wIcon_FromImage(self: wIcon, image: wImage, size = wDefaultSize) =
  # todo: GdipCreateHICONFromBitmap don't hanlde alpha channel very well

  var image = image
  var imgSize = image.getSize()
  var isResize = false

  if size.width > 0 and size.width != imgSize.width:
    isResize = true
    mWidth = size.width
  else:
    mWidth = imgSize.width

  if size.height > 0 and size.height != imgSize.height:
    isResize = true
    mHeight = size.height
  else:
    mHeight = imgSize.height

  if isResize:
    image = image.scale(mWidth, mHeight)

  if GdipCreateHICONFromBitmap(image.mGdipBmp, &mHandle) != Ok:
    error()

proc init*(self: wIcon, image: wImage, size = wDefaultSize) {.validate, inline.} =
  wValidate(image)
  self.wGdiObject.init()
  wIcon_FromImage(image, size)

proc Icon*(image: wImage, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from the given wImage object.
  wValidate(image)
  new(result, final)
  result.init(image, size)

proc init*(self: wIcon, data: ptr byte, length: int, size = wDefaultSize) {.validate.} =
  wValidate(data)
  self.wGdiObject.init()
  # createIconFromMemory better than Image() becasue it choose
  # best fits icon in icon group, and it supports .ani format.
  mHandle = createIconFromMemory(data, length, width=size.width,
    height=size.height, isIcon=true)

  if mHandle != 0:
    (mWidth, mHeight) = getIconSize(mHandle)
  else:
    wIcon_FromImage(Image(data, length), size)

proc Icon*(data: ptr byte, length: int, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from binary data of image file format.
  ## Supports .ico, .cur (choose best fits image from group), .ani (without animated),
  ## and other formats that wImage supported.
  wValidate(data)
  new(result, final)
  result.init(data, length, size)

proc init*(self: wIcon, str: string, size = wDefaultSize) {.validate.} =
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

  init(buffer, length, size)

proc Icon*(str: string, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from a image file.
  ## If str is not a valid file path, it will be regarded as the binary data in memory.
  wValidate(str)
  new(result, final)
  result.init(str, size)

proc init*(self: wIcon, file: string, index: int, size = wDefaultSize) {.validate.} =
  wValidate(file)
  self.wGdiObject.init()
  mHandle = createIconFromPE(file, index, size.width, size.height)
  if mHandle != 0:
    (mWidth, mHeight) = getIconSize(mHandle)
  else:
    error()

proc Icon*(file: string, index: int, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from a PE file (.exe or .dll).
  ## Empty string indicates the current executable file.
  ## Positive index indicates the icon position, and negative value for icon ID.
  wValidate(file)
  new(result, final)
  result.init(file, index, size)

proc init*(self: wIcon, hIcon: HICON, copy = true) {.validate.} =
  self.wGdiObject.init()
  if copy:
    mHandle = createIconFromHIcon(hIcon, isIcon=true)
  else:
    mHandle = hIcon

  if mHandle != 0:
    (mWidth, mHeight) = getIconSize(mHandle)
  else:
    error()

proc Icon*(hIcon: HICON, copy = true): wIcon {.inline.} =
  ## Creates an icon from Windows icon handle.
  ## If copy is false, this only wrap it to wIcon object.
  ## Notice this means the handle will be destroyed by wIcon when it is destroyed.
  new(result, final)
  result.init(hIcon, copy)

proc init*(self: wIcon, icon: wIcon) {.validate.} =
  wValidate(icon)
  init(icon.mHandle)

proc Icon*(icon: wIcon): wIcon {.inline.} =
  ## Creates an icon from wIcon object, aka. copy constructors.
  wValidate(icon)
  new(result, final)
  result.init(icon)
