#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
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
##   `wIconImage <wIconImage.html>`_

include ../pragma
import ../wBase, ../wIconImage, ../wImage, wGdiObject
export wGdiObject

type
  wIconError* = object of wGdiObjectError
    ## An error raised when wIcon creation failed.

proc error(self: wIcon) {.inline.} =
  raise newException(wIconError, "wIcon creation failed")

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
  `=destroy`(self[])

wClass(wIcon of wGdiObject):

  proc init*(self: wIcon, iconImage: wIconImage, size = wDefaultSize) {.validate.} =
    ## Initializes an icon from a wIconImage object.
    wValidate(iconImage)
    self.wGdiObject.init()

    # Windows XP don't support PNG format. However, even under Vista or
    # Windows 7, the system still handle PNG icon with some error.
    # So we create a new iconimage and convert it to bmp format by ourself.
    try:
      var
        newIconImage = IconImage(iconImage)
        width = if size.width < 0: iconImage.getWidth() else: size.width
        height = if size.height < 0: iconImage.getHeight() else: size.height

      newIconImage.toBmp()

      self.mDeletable = true
      self.mHandle = CreateIconFromResourceEx(cast[PBYTE](&newIconImage.mIcon),
        newIconImage.mIcon.len, TRUE, 0x30000, width, height, 0)

      if self.mHandle == 0: self.error()
      (self.mWidth, self.mHeight) = (width, height)

    except wError:
      self.error()

  proc init*(self: wIcon, bmp: wBitmap, size = wDefaultSize) {.validate, inline.} =
    ## Initializes an icon from the given wBitmap object.
    wValidate(bmp)
    try:
      var iconImage = IconImage(bmp)
      self.init(iconImage, size)
    except wError:
      self.error()

  proc init*(self: wIcon, image: wImage, size = wDefaultSize) {.validate.} =
    ## Initializes an icon from the given wImage object.
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

  proc init*(self: wIcon, data: pointer, length: int, size = wDefaultSize)
      {.validate, inline.} =
    ## Initializes an icon from binary data of .ico or .cur file.
    wValidate(data)
    try:
      self.init(IconImage(data, length, size), size)
    except wError:
      self.error()

  proc init*(self: wIcon, str: string, size = wDefaultSize) {.validate, inline.} =
    ## Initializes an icon from a file. The file should be in format of .ico, .cur,
    ## or Windows PE file (.exe or .dll, etc). If str is not a valid file path,
    ## it will be regarded as the binary data of .ico or .cur file.
    ##
    ## For Windows PE file (.exe or .dll), you should use string like
    ## "shell32.dll,-10" to specifies the icon index or "shell32.dll:-1001" to
    ## to specifies the cursor index. Use zero-based index to specified the
    ## resource position, and negative value to specified the resource identifier.
    ## Empty filename (e.g. ",-1") to specified the current executable file.
    ##
    ## If *size* is wDefaultSize, it uses the SM_CXICON/SM_CXCURSOR system metric
    ## value as default value.
    try:
      self.init(IconImage(str, size), size)
    except wError:
      self.error()

  proc init*(self: wIcon, hIcon: HICON, copy = true, shared = false) {.validate.} =
    ## Initializes an icon from system icon handle.
    ## If *copy* is false, the function only wrap the handle to wIcon object.
    ## If *shared* is false, the handle will be destroyed together with wIcon
    ## object by the GC. Otherwise, the caller is responsible for destroying it.
    self.wGdiObject.init()

    var iconInfo: ICONINFO
    if GetIconInfo(hIcon, iconInfo) != 0:
      defer:
        DeleteObject(iconInfo.hbmColor)
        DeleteObject(iconInfo.hbmMask)

      iconInfo.fIcon = TRUE
      iconInfo.xHotspot = 0
      iconInfo.yHotspot = 0

      (self.mWidth, self.mHeight) = iconInfo.getSize()

      if copy:
        self.mHandle = CreateIconIndirect(iconInfo)
        self.mDeletable = true
      else:
        self.mHandle = hIcon
        self.mDeletable = not shared

    if self.mHandle == 0: self.error()

  proc init*(self: wIcon, icon: wIcon) {.validate.} =
    ## Initializes an icon from a wIcon object, aka. copy.
    wValidate(icon)
    self.init(icon.mHandle, copy=true)

  proc init*(self: wIcon, cursor: wCursor) {.validate.} =
    ## Initializes an icon from a wCursor object.
    wValidate(cursor)
    self.init(cursor.mHandle, copy=true)

  proc init*(self: wIcon, filename: string, index: int, size = wDefaultSize)
      {.validate, inline.} =
    ## Initializes an icon from a Windows PE file (.exe or .dll, etc). Use
    ## zero-based index to specified the resource position, and negative value
    ## to specified the resource identifier. Empty filename to specified the
    ## current executable file.
    ##
    ## If *size* is wDefaultSize, it uses the SM_CXICON/SM_CXCURSOR system metric
    ## value as default value.
    self.init(filename & "," & $index, size)
