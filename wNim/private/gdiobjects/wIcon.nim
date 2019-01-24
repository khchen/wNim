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
  if self.mHandle != 0 and self.mDeletable:
    DestroyIcon(self.mHandle)

  self.mHandle = 0

proc final*(self: wIcon) =
  ## Default finalizer for wIcon.
  self.delete()

proc init*(self: wIcon, iconImage: wIconImage, size = wDefaultSize) {.validate.} =
  ## Initializer.
  wValidate(iconImage)
  self.wGdiObject.init()

  # Windows XP don't support PNG format. However, even under Vista or
  # Windows 7, the system still handle PNG icon with some error.
  # So we create a new iconimage and convert it to bmp format by ourself.
  var
    newIconImage = IconImage(iconImage)
    width = if size.width < 0: iconImage.getWidth() else: size.width
    height = if size.height < 0: iconImage.getHeight() else: size.height

  newIconImage.toBmp()

  self.mHandle = CreateIconFromResourceEx(cast[PBYTE](&newIconImage.mIcon),
    newIconImage.mIcon.len, TRUE, 0x30000, width, height, 0)

  if self.mHandle == 0: self.error()
  (self.mWidth, self.mHeight) = (width, height)

proc Icon*(iconImage: wIconImage, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from a wIconImage object.
  wValidate(iconImage)
  new(result, final)
  result.init(iconImage, size)

proc init*(self: wIcon, bmp: wBitmap, size = wDefaultSize) {.validate, inline.} =
  ## Initializer.
  wValidate(bmp)
  var iconImage = IconImage(bmp)
  self.init(iconImage, size)

proc Icon*(bmp: wBitmap, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from the given wBitmap object.
  wValidate(bmp)
  new(result, final)
  result.init(bmp)

proc init*(self: wIcon, image: wImage, size = wDefaultSize) {.validate.} =
  ## Initializer.
  wValidate(image)

  try:
    var
      image = image
      isRescale = false
      (width, height) = image.getSize()

    if size.width > 0 and size.width != width:
      isRescale = true
      width = size.width

    if size.height > 0 and size.height != height:
      isRescale = true
      height = size.height

    if isRescale:
      image = image.scale(width, height)

    defer:
      if isRescale: image.delete()

    self.init(IconImage(image))

  except wError:
    self.error()

proc Icon*(image: wImage, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from the given wImage object.
  wValidate(image)
  new(result, final)
  result.init(image, size)

proc init*(self: wIcon, data: pointer, length: int, size = wDefaultSize)
    {.validate, inline.} =
  ## Initializer.
  wValidate(data)
  self.init(IconImage(data, length, size), size)

proc Icon*(data: pointer, length: int, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from binary data of .ico or .cur file.
  wValidate(data)
  new(result, final)
  result.init(data, length, size)

proc init*(self: wIcon, str: string, size = wDefaultSize) {.validate, inline.} =
  ## Initializer.
  wValidate(str)
  self.init(IconImage(str, size), size)

proc Icon*(str: string, size = wDefaultSize): wIcon {.inline.} =
  ## Creates an icon from a file. The file should be format of .ico, .cur,
  ## or 32-bit executable files (.exe or .dll, etc). If str is not a valid file
  ## path, it will be regarded as the binary data of .ico or .cur file.
  ##
  ## For 32-bit executable files (.exe or .dll), it allows string like
  ## "shell32.dll,-10" to specifies the icon index or "shell32.dll:-1001" to
  ## to specifies the cursor index. Use zero-based index to specified the
  ## resource position, and negative value to specified the resource identifier.
  wValidate(str)
  new(result, final)
  result.init(str, size)

proc init*(self: wIcon, hIcon: HICON, copy = true, shared = false) {.validate.} =
  ## Initializer.
  self.wGdiObject.init()
  var
    iconInfo: ICONINFO
    bitmapInfo: BITMAP

  if GetIconInfo(hIcon, iconInfo) != 0:
    defer:
      DeleteObject(iconInfo.hbmColor)
      DeleteObject(iconInfo.hbmMask)

    iconInfo.fIcon = TRUE
    iconInfo.xHotspot = 0
    iconInfo.yHotspot = 0

    if GetObject(iconInfo.hbmColor, sizeof(bitmapInfo), cast[LPVOID](&bitmapInfo)) != 0:
      self.mWidth = int bitmapInfo.bmWidth
      self.mHeight = int bitmapInfo.bmHeight

      if copy:
        self.mHandle = CreateIconIndirect(iconInfo)
        self.mDeletable = true
      else:
        self.mHandle = hIcon
        self.mDeletable = not shared

  if self.mHandle == 0: self.error()

proc Icon*(hIcon: HICON, copy = true, shared = false): wIcon {.inline.} =
  ## Creates an icon from Windows icon handle.
  ## If copy is false, this only wrap it to wIcon object. It means the handle
  ## will be destroyed by wIcon when it is destroyed. So if you wrap a
  ## shared icon handle into wIcon, you must set *shared* = true to avoid
  ## the handle being destroyed.
  new(result, final)
  result.init(hIcon, copy, shared)

proc init*(self: wIcon, icon: wIcon) {.validate.} =
  ## Initializer.
  wValidate(icon)
  self.init(icon.mHandle, copy=true)

proc Icon*(icon: wIcon): wIcon {.inline.} =
  ## Creates an icon from a wIcon object, aka. copy constructors.
  wValidate(icon)
  new(result, final)
  result.init(icon)

proc init*(self: wIcon, cursor: wCursor) {.validate.} =
  ## Initializer.
  wValidate(cursor)
  self.init(cursor.mHandle, copy=true)

proc Icon*(cursor: wCursor): wIcon {.inline.} =
  ## Creates an icon from a wCursor object
  wValidate(cursor)
  new(result, final)
  result.init(cursor)
