#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class encapsulates a Windows icon image. Unlike wImage, wBitmap,
## wIcon, wCursor, etc., wIconImage doesn't store any Windows resource handle,
## but only an icon image in binary format. In addition to the binary image data,
## wIconImage also stores the hotspot for cursor if the icon image is created
## from a cursor resource.
##
## A wIconImage object can be created from Windows PE files (.exe or .dll)
## or icon files (.ico or .cur). It also can be created by wImage, wBitmap,
## wIcon, or wCursor. Furthermore, wIconImage can be converted to wImage,
## wBitmap, wIcon, wCursor, or .ico/.cur files. In summary, it is easy to deal
## with Windows' image-like resource and image files by wIconImage.
##
## The wIconImage class use the same binary format as an image inside the icon
## files. So there are two possible format of wIconImage object: BMP or PNG.
## Since Windows XP don't support PNG format icon files, it is recommend to
## use toBmp() before saving a wIconImage object to icon file if the icon file
## will be used under Windows XP.
#
## :Seealso:
##   `wImage <wImage.html>`_
##   `wBitmap <wBitmap.html>`_
##   `wIcon <wIcon.html>`_
##   `wCursor <wCursor.html>`_

# forward declarations
# proc Image*(iconImage: wIconImage): wImage {.inline.}
# proc Image*(data: pointer, length: int): wImage {.inline.}
# proc delete*(self: wImage)
# proc saveData*(self: wImage, fileType: string, quality: range[0..100] = 90): string

include pragma
import strutils
import wBase

# For recursive module dependencies.
proc isPng*(self: wIconImage): bool {.inline.}
proc getBitCount*(self: wIconImage): int
proc getSize*(self: wIconImage): wSize {.inline.}
proc save*(self: wIconImage, isIcon = true): string
proc IconImage*(icon: wIcon): wIconImage {.inline.}
proc IconImage*(cursor: wCursor): wIconImage {.inline.}

import wImage

type
  wIconImageError* = object of wError
    ## An error raised when wIconImage creation or operation failure.

  PNGHEADER {.pure, packed.} = object
    header: array[16, uint8]
    width: uint32
    height: uint32

  ICONDIRENTRY {.pure, packed.} = object
    bWidth: BYTE              #  Width, in pixels, of the image
    bHeight: BYTE             #  Height, in pixels, of the image
    bColorCount: BYTE         #  Number of colors in image (0 if >=8bpp)
    bReserved: BYTE           #  Reserved ( must be 0)
    wPlanes: WORD             #  Color Planes
    wBitCount: WORD           #  Bits per pixel
    dwBytesInRes: DWORD       #  How many bytes in this resource?
    dwImageOffset: DWORD      #  Where in the file is this image?

  GRPICONDIRENTRY {.pure, packed.} = object
    bWidth: BYTE              #  Width, in pixels, of the image
    bHeight: BYTE             #  Height, in pixels, of the image
    bColorCount: BYTE         #  Number of colors in image (0 if >=8bpp)
    bReserved: BYTE           #  Reserved
    wPlanes: WORD             #  Color Planes
    wBitCount: WORD           #  Bits per pixel
    dwBytesInRes: DWORD       #  how many bytes in this resource?
    nID: WORD                 #  the ID

  ICONDIR {.pure, packed.} = object
    idReserved: WORD          #  Reserved (must be 0)
    idType: WORD              #  Resource Type (1 for icons)
    idCount: WORD             #  How many images?
    idEntries: UncheckedArray[ICONDIRENTRY] #  An entry for each image (idCount of 'em)

  GRPICONDIR {.pure, packed.} = object
    idReserved: WORD          #  Reserved (must be 0)
    idType: WORD              #  Resource type (1 for icons)
    idCount: WORD             #  How many images?
    idEntries: UncheckedArray[GRPICONDIRENTRY] #  The entries for each image

  HOTSPOT {.pure, packed.} = object
    x: WORD
    y: WORD

const
  # 0.19 don't use sizeof(ICONDIR) because tcc don't supprot size of UncheckedArray
  # 0.20 support it, but still use const size for compatibility
  IcondirSize = 6
  GrpIcondirSize = 6

when defined(gcc):
  proc bswap32(a: uint32): uint32 {.importc: "__builtin_bswap32", nodecl, nosideeffect.}
else:
  proc bswap32(x: uint32): uint32 =
    (x shl 24) or ((x and 0xff00) shl 8) or ((x and 0xff0000) shr 8) or (x shr 24)

proc hasAlphaBit(colorBit: pointer, size: int): bool =
  let colorBit = cast[ptr UncheckedArray[uint32]](colorBit)
  for i in 0..<size:
    if (colorBit[i] and 0xff000000'u32) != 0:
      return true
  return false

proc setAlphaBit(colorBit: pointer, maskBit: pointer, size: int) =
  let
    colorBit = cast[ptr UncheckedArray[uint32]](colorBit)
    maskBit = cast[ptr UncheckedArray[uint32]](maskBit)
  for i in 0..<size:
    if maskBit[i] == 0:
      colorBit[i] = colorBit[i] or 0xff000000'u32

proc setMaskBit(colorBit: pointer, maskBit: pointer, size: int) =
  let
    colorBit = cast[ptr UncheckedArray[uint32]](colorBit)
    maskBit = cast[ptr UncheckedArray[uint32]](maskBit)
  for i in 0..<size:
    if (colorBit[i] and 0xff000000'u32) == 0:
      maskBit[i] = 0xffffffff'u32

proc createDibBitmap(width: int32, height: int32, bitCount: WORD): (HBITMAP, pointer) =
  type
    BITMAPINFO2 {.pure.} = object
      bmiHeader: BITMAPINFOHEADER
      bmiColors: array[2, DWORD]

  var
    bit: pointer
    bitmapInfo = BITMAPINFO2(
      bmiHeader: BITMAPINFOHEADER(
        biSize: 40,
        biWidth: width,
        biHeight: height,
        biPlanes: 1,
        biBitCount: bitCount))

  if bitCount == 1:
    bitmapInfo.bmiHeader.biClrUsed = 2
    bitmapinfo.bmiColors[0] = 0
    bitmapinfo.bmiColors[1] = 0xffffff

  return (CreateDIBSection(0, cast[ptr BITMAPINFO](&bitmapInfo), 0, &bit, 0, 0), bit)

proc toDefaultSize(size: wSize): wSize =
  # MSDN says if width or heigth is zero, LookupIconIdFromDirectoryEx uses the
  # SM_CXICON or SM_CXCURSOR system metric value. However, under my test, it don't.
  result.width = if size.width < 0: GetSystemMetrics(SM_CXICON) else: size.width
  result.height = if size.height < 0: GetSystemMetrics(SM_CYICON) else: size.height

proc loadIconLibrary(str: string): tuple[module: HMODULE, index: int, isIcon: bool] =
  var
    pefile: string
    index: int
    isIcon: bool

  proc splitBy(str: string, sep: char, pefile: var string, index: var int): bool =
    try:
      var tailSplit = rsplit(str, sep, maxsplit=1)
      if tailSplit.len >= 2:
        index = parseInt(tailSplit[1])
        pefile = tailSplit[0]
        return true

    except ValueError: discard
    return false

  if str.splitBy(',', pefile, index):
    isIcon = true

  elif str.splitBy(':', pefile, index):
    isIcon = false

  else:
    return (-1, 0, false)

  if pefile.len != 0:
    var module = LoadLibraryEx(pefile, 0, LOAD_LIBRARY_AS_DATAFILE)
    if module != 0:
      return (module, index, isIcon)

  else: # for current process.
    return (0, index, isIcon)

proc initRaw(self: wIconImage, width: int32, height: int32, bitCount: WORD,
  colorSize: int32, colorBit: pointer, maskSize: int32, maskBit: pointer,
  hotspot = wDefaultPoint) =

  var header = BITMAPINFOHEADER(
    biSize: 40,
    biPlanes: 1,
    biBitCount: bitCount,
    biWidth: width,
    biHeight: height * 2,
    biSizeImage: colorSize + maskSize)

  self.mIcon = newString(sizeof(header) + colorSize + maskSize)
  copyMem(&self.mIcon, &header, sizeof(header))
  copyMem(&self.mIcon[sizeof(header)], colorBit, colorSize)
  copyMem(&self.mIcon[sizeof(header) + colorSize], maskBit, maskSize)
  self.mHotspot = hotSpot

proc initRawHICON(self: wIconImage, hIcon: HICON) =
  var iconInfo: ICONINFO
  if GetIconInfo(hIcon, &iconInfo) == 0: return
  var
    colorBmp = CopyImage(iconInfo.hbmColor, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION or LR_COPYDELETEORG)
    maskBmp = CopyImage(iconInfo.hbmMask, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION or LR_COPYDELETEORG)
  defer:
    DeleteObject(colorBmp)
    DeleteObject(maskBmp)
  if colorBmp == 0 or maskBmp == 0: return

  var dibSection: DIBSECTION
  if GetObject(colorBmp, sizeof(dibSection), &dibSection) == 0: return
  var
    colorBit = dibSection.dsBm.bmBits
    colorSize = dibsection.dsBmih.biSizeImage
    bitCount =  dibSection.dsBm.bmBitsPixel
    width = dibsection.dsBm.bmWidth
    height = dibsection.dsBm.bmHeight

  if GetObject(maskBmp, sizeof(dibSection), &dibSection) == 0: return
  var
    maskBit = dibsection.dsBm.bmBits
    maskSize = dibsection.dsBmih.biSizeImage

  if bitCount == 32 and not hasAlphaBit(colorBit, width * height):
    var
      (newMaskBmp, newMaskBit) = createDibBitmap(width, height, 32)
      srcDc = CreateCompatibleDC(0)
      dstDc = CreateCompatibleDC(0)
      srcSv, dstSv: HGDIOBJ
    defer:
      DeleteObject(newMaskBmp)
      SelectObject(srcDc, srcSv)
      SelectObject(dstDc, dstSv)
      DeleteDC(srcDc)
      DeleteDC(dstDc)
    if newMaskBmp == 0: return

    srcSv = SelectObject(srcDc, maskBmp)
    dstSv = SelectObject(dstDc, newMaskBmp)
    BitBlt(dstDc, 0, 0, width, height, srcDc, 0, 0, MERGECOPY)
    setAlphaBit(colorBit, newMaskBit, width * height)

  var hotspot = if bool iconInfo.fIcon:
      wDefaultPoint
    else:
      (int iconInfo.xHotspot, int iconInfo.yHotspot)

  self.initRaw(width, height, bitCount, colorSize, colorBit, maskSize, maskBit, hotspot)

proc initRawHBITMAP(self: wIconImage, hbmp: HBITMAP) =
  var colorBmp = CopyImage(hbmp, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION)
  defer: DeleteObject(colorBmp)
  if colorBmp == 0: return

  var dibSection: DIBSECTION
  if GetObject(colorBmp, sizeof(dibSection), &dibSection) == 0: return
  var
    width = dibsection.dsBm.bmWidth
    height = dibsection.dsBm.bmHeight
    colorBit = dibSection.dsBm.bmBits
    colorSize = dibsection.dsBmih.biSizeImage
    bitCount =  dibSection.dsBm.bmBitsPixel
    (colorMaskBmp, colorMaskBit) = createDibBitmap(width, height, 32)
    (monoMaskBmp, monoMaskBit) = createDibBitmap(width, height, 1)
    srcDc = CreateCompatibleDC(0)
    dstDc = CreateCompatibleDC(0)
    srcSv, dstSv: HGDIOBJ
  defer:
    DeleteObject(colorMaskBmp)
    DeleteObject(monoMaskBmp)
    SelectObject(srcDc, srcSv)
    SelectObject(dstDc, dstSv)
    DeleteDC(srcDc)
    DeleteDC(dstDc)
  if colorMaskBmp == 0 or monoMaskBmp == 0: return

  if bitCount == 32 and hasAlphaBit(colorBit, width * height):
    setMaskBit(colorBit, colorMaskBit, width * height)
    SelectObject(srcDc, colorMaskBmp)
    SelectObject(dstDc, monoMaskBmp)
    BitBlt(dstDc, 0, 0, width, height, srcDc, 0, 0, MERGECOPY)

  if GetObject(monoMaskBmp, sizeof(dibSection), &dibSection) == 0: return
  var maskSize = dibsection.dsBmih.biSizeImage

  self.initRaw(width, height, bitCount, colorSize, colorBit, maskSize, monoMaskBit)

proc initRawGdipbmp(self: wIconImage, gdipbmp: ptr GpBitmap) =
  var width, height: int32
  if GdipGetImageWidth(gdipbmp, &width) != Ok: return
  if GdipGetImageHeight(gdipbmp, &height) != Ok: return

  var
    rect = GpRect(Width: width, Height: height)
    bitmapData: BitmapData
    (colorBmp, colorBit) = createDibBitmap(width, height, 32)
    (colorMaskBmp, colorMaskBit) = createDibBitmap(width, height, 32)
    (monoMaskBmp, monoMaskBit) = createDibBitmap(width, height, 1)
    srcDc = CreateCompatibleDC(0)
    dstDc = CreateCompatibleDC(0)
    srcSv, dstSv: HGDIOBJ
    dibSection: DIBSECTION
  defer:
    DeleteObject(colorBmp)
    DeleteObject(colorMaskBmp)
    DeleteObject(monoMaskBmp)
    SelectObject(srcDc, srcSv)
    SelectObject(dstDc, dstSv)
    DeleteDC(srcDc)
    DeleteDC(dstDc)
  if colorBmp == 0 or colorMaskBmp == 0 or monoMaskBmp == 0: return

  if GdipBitmapLockBits(gdipbmp, &rect, imageLockModeRead,
    pixelFormat32bppARGB, &bitmapData) != Ok: return

  if SetBitmapBits(colorBmp, width * height * 4, bitmapData.Scan0) == 0: return

  if GdipBitmapUnlockBits(gdipbmp, &bitmapData) != Ok: return

  setMaskBit(colorBit, colorMaskBit, width * height)
  SelectObject(srcDc, colorMaskBmp)
  SelectObject(dstDc, monoMaskBmp)
  BitBlt(dstDc, 0, 0, width, height, srcDc, 0, 0, MERGECOPY)

  if GetObject(colorBmp, sizeof(dibSection), &dibSection) == 0: return
  var colorSize = dibsection.dsBmih.biSizeImage

  if GetObject(monoMaskBmp, sizeof(dibSection), &dibSection) == 0: return
  var maskSize = dibsection.dsBmih.biSizeImage

  self.initRaw(width, height, 32, colorSize, colorBit, maskSize, monoMaskBit)

proc initRawModuleGroupId(self: wIconImage, module: HMODULE, groupId: LPTSTR, size: wSize, isIcon: bool) =
  var
    (width, height) = size.toDefaultSize()
    resource = FindResource(module, groupId, if isIcon: RT_GROUP_ICON else: RT_GROUP_CURSOR)
    handle = LoadResource(module, resource)
    p = LockResource(handle)

  if resource != 0 and handle != 0 and p != nil:
    var
      iconId = LookupIconIdFromDirectoryEx(cast[PBYTE](p), isIcon, width, height, 0)
      resource = FindResource(module, MAKEINTRESOURCE(iconId), if isIcon: RT_ICON else: RT_CURSOR)
      handle = LoadResource(module, resource)
      length = SizeofResource(module, resource)
      p = LockResource(handle)

    if resource != 0 and handle != 0 and length != 0 and p != nil:
      if isIcon:
        self.mHotspot = wDefaultPoint
      else:
        let hotspot = cast[ptr HOTSPOT](p)
        self.mHotspot.x = int hotspot.x
        self.mHotspot.y = int hotspot.y
        length -= sizeof(HOTSPOT)
        p = cast[pointer](cast[int](p) + sizeof(HOTSPOT))

      self.mIcon = newString(length)
      copyMem(&self.mIcon, p, length)

proc initRawModuleIndex(self: wIconImage, module: HMODULE, index: int, size: wSize, isIcon: bool) =
  type
    EnumInfo = object
      self: wIconImage
      index: int
      isIcon: bool
      size: wSize
      icon: string

  proc enumFunc(module: HMODULE, typ: LPTSTR, name: LPTSTR, lParam: LONG_PTR): WINBOOL {.stdcall.} =
    let info = cast[ptr EnumInfo](lParam)
    if info.index == 0:
      info.self.initRawModuleGroupId(module, name, info.size, info.isIcon)
      return 0
    else:
      info.index.dec
      return 1

  if index >= 0:
    var info = EnumInfo(self: self, index: index, size: size, isIcon: isIcon)
    EnumResourceNames(module, if isIcon: RT_GROUP_ICON else: RT_GROUP_CURSOR,
      enumFunc, cast[LONG_PTR](&info))
  else:
    self.initRawModuleGroupId(module, MAKEINTRESOURCE(-index), size, isIcon)

proc isIconBinary(data: pointer, length: int): bool =
  if length < IcondirSize: return false

  let iconDir = cast[ptr ICONDIR](data)
  if iconDir.idReserved != 0 or iconDir.idType notin {1, 2}: return false

  let count = int iconDir.idCount
  if length < IcondirSize + sizeof(ICONDIRENTRY) * count: return false

  let endOfData = iconDir.idEntries[count-1].dwBytesInRes + iconDir.idEntries[count-1].dwImageOffset
  if length < endOfData: return false

  return true

proc initRawBinary(self: wIconImage, data: pointer, length: int, size = wDefaultSize) =
  if not isIconBinary(data, length): return

  let
    (width, height) = size.toDefaultSize()
    iconDir = cast[ptr ICONDIR](data)
    count = int iconDir.idCount
    isIcon = iconDir.idType == 1
    buffer = newString(GrpIcondirSize + sizeof(GRPICONDIRENTRY) * count)
    grpIconDir = cast[ptr GRPICONDIR](&buffer)

  grpIconDir.idReserved = iconDir.idReserved
  grpIconDir.idType = iconDir.idType
  grpIconDir.idCount = iconDir.idCount

  for i in 0..<count:
    copyMem(&grpIconDir.idEntries[i], &iconDir.idEntries[i], sizeof(GRPICONDIRENTRY))
    grpIconDir.idEntries[i].nID = WORD(i + 1)

  var index = LookupIconIdFromDirectoryEx(cast[PBYTE](grpIconDir), isIcon, width, height, 0)
  if index != 0:
    index.dec
    let
      length = int iconDir.idEntries[index].dwBytesInRes
      p = cast[pointer](cast[int](data) + iconDir.idEntries[index].dwImageOffset)

    self.mIcon = newString(length)
    copyMem(&self.mIcon, p, length)

    if isIcon:
      self.mHotspot = wDefaultPoint
    else:
      self.mHotspot = (int iconDir.idEntries[index].wPlanes,
        int iconDir.idEntries[index].wBitCount)

proc error(self: wIconImage) {.inline.} =
  raise newException(wIconImageError, "wIconImage creation failed")

wClass(wIconImage):

  proc init*(self: wIconImage, icon: wIcon) {.validate.} =
    ## Initializes an icon image from a wIcon object.
    wValidate(icon)
    self.initRawHICON(icon.mHandle)
    if self.mIcon.len == 0: self.error()

  proc init*(self: wIconImage, cursor: wCursor) {.validate.} =
    ## Initializes an icon image from a wCursor object.
    wValidate(cursor)
    self.initRawHICON(cursor.mHandle)
    if self.mIcon.len == 0: self.error()

  proc init*(self: wIconImage, bmp: wBitmap) {.validate.} =
    ## Initializes an icon image from a wBitmap object.
    wValidate(bmp)
    self.initRawHBITMAP(bmp.mHandle)
    if self.mIcon.len == 0: self.error()

  proc init*(self: wIconImage, image: wImage) {.validate.} =
    ## Initializes an icon image from a wImage object.
    wValidate(image)
    self.initRawGdipbmp(image.mGdipBmp)
    if self.mIcon.len == 0: self.error()

  proc init*(self: wIconImage, data: pointer, length: int, size = wDefaultSize) {.validate.} =
    ## Initializes an icon image from binary data of .ico or .cur file. The
    ## extra *size* parameter can be used to specified the desired display
    ## size. The function uses Windows API to search and return the best fits
    ## icon, or uses the SM_CXICON/SM_CXCURSOR system metric value as default
    ## value.
    ##
    ## **Notice: The function will not resize the image, so the real
    ## size of retruned icon image may not equal to your desired size.**
    wValidate(data)
    self.initRawBinary(data, length, size)
    if self.mIcon.len == 0: self.error()

  proc init*(self: wIconImage, str: string, size = wDefaultSize) {.validate.} =
    ## Initializes an icon image from a file. The file should be in format of
    ## .ico, .cur, or Windows PE file (.exe or .dll, etc). If str is not a valid
    ## file path, it will be regarded as the binary data of .ico or .cur file.
    ##
    ## For Windows PE file (.exe or .dll), you should use string like
    ## "shell32.dll,-10" to specifies the icon index or "shell32.dll:-1001" to
    ## to specifies the cursor index. Use zero-based index to specified the
    ## resource position, and negative value to specified the resource identifier.
    ## Empty filename (e.g. ",-1") to specified the current executable file.
    ##
    ## If the resource is an icon/cursor group, the extra *size* parameter can be
    ## used to specified the desired display size. The function uses Windows API
    ## to search and return the best fits icon, or uses the SM_CXICON/SM_CXCURSOR
    ## system metric value as default value.
    ##
    ## **Notice: The function will not resize the image, so the real size of
    ## retruned icon image may not equal to your desired size.**
    let (module, index, isIcon) = loadIconLibrary(str)
    if module != -1:
      defer: FreeLibrary(module)
      self.initRawModuleIndex(module, index, size, isIcon)

    else:
      try:
        var data = readFile(str)
        self.initRawBinary(&data, data.len, size)

      except IOError:
        self.initRawBinary(&str, str.len, size)

    if self.mIcon.len == 0: self.error()

  proc init*(self: wIconImage, iconImage: wIconImage) {.validate, inline.} =
    ## Initializes an icon image from wIconImage object, aka. copy.
    wValidate(iconImage)
    self.mIcon = iconImage.mIcon
    self.mHotspot = iconImage.mHotspot
    if self.mIcon.len == 0: self.error()

proc isPng*(self: wIconImage): bool {.validate, inline.} =
  ## Returns true if this is a PNG format icon image.
  result = self.mIcon[0..7] == "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A"

proc isBmp*(self: wIconImage): bool {.validate, inline.} =
  ## Returns true if this is a bitmap format icon image.
  result = not self.isPng()

proc toPng*(self: wIconImage) {.validate.} =
  ## Convert this icon image to PNG format.
  if self.isBmp():
    var image = Image(self)
    defer: image.delete()
    self.mIcon = image.saveData("png")

proc toBmp*(self: wIconImage) {.validate.} =
  ## Convert this icon image to bitmap format.
  if self.isPng():
    var image = Image(&self.mIcon, self.mIcon.len)
    defer: image.delete()
    self.initRawGdipbmp(image.mGdipBmp)

proc getWidth*(self: wIconImage): int {.validate, property.} =
  ## Gets the width of the icon image in pixels.
  if self.isPng():
    let pPngHeader = cast[ptr PNGHEADER](&self.mIcon)
    result = int bswap32(pPngHeader.width)
  else:
    let pBmpHeader = cast[ptr BITMAPINFOHEADER](&self.mIcon)
    result = int pBmpHeader.biWidth

proc getHeight*(self: wIconImage): int {.validate, property.} =
  ## Gets the height of the icon image in pixels.
  if self.isPng():
    let pPngHeader = cast[ptr PNGHEADER](&self.mIcon)
    result = int bswap32(pPngHeader.height)
  else:
    let pBmpHeader = cast[ptr BITMAPINFOHEADER](&self.mIcon)
    result = int pBmpHeader.biHeight div 2

proc getSize*(self: wIconImage): wSize {.validate, property, inline.} =
  ## Returns the size of the icon image in pixels.
  result = (self.getWidth(), self.getHeight())

proc getBitCount*(self: wIconImage): int {.validate, property.} =
  ## Returns the bit count of the icon image.
  if self.isPng():
    result = 32
  else:
    let pBmpHeader = cast[ptr BITMAPINFOHEADER](&self.mIcon)
    result = int pBmpHeader.biBitCount

proc getHotspot*(self: wIconImage): wPoint {.validate, property.} =
  ## Returns the cursor's hotspot. If this icon image is created from icon
  ## resource instead of cursor resource, the value is wDefaultPoint.
  result = self.mHotspot

proc setHotspot*(self: wIconImage, hotspot: wPoint) {.validate, property.} =
  ## Set the coordinates of the cursor's hotspot.
  self.mHotspot = hotspot

proc IconImages*(data: pointer, length: int): seq[wIconImage] =
  ## Similar to IconImage() for binary data, but this function loads all image
  ## in the group and returns a seq.
  if not isIconBinary(data, length): return @[]

  let
    iconDir = cast[ptr ICONDIR](data)
    count = int iconDir.idCount
    isIcon = iconDir.idType == 1

  result = newSeq[wBase.wIconImage](count)

  for i in 0..<count:
    let
      length = int iconDir.idEntries[i].dwBytesInRes
      p = cast[pointer](cast[int](data) + iconDir.idEntries[i].dwImageOffset)

    new(result[i])
    result[i].mIcon = newString(length)
    copyMem(&result[i].mIcon, p, length)

    if isIcon:
      result[i].mHotspot = wDefaultPoint
    else:
      result[i].mHotspot = (int iconDir.idEntries[i].wPlanes,
        int iconDir.idEntries[i].wBitCount)

proc IconImagesModuleGroupId(module: HMODULE, groupId: LPTSTR, isIcon: bool): seq[wIconImage] =
  result = @[]
  var
    resource = FindResource(module, groupId, if isIcon: RT_GROUP_ICON else: RT_GROUP_CURSOR)
    handle = LoadResource(module, resource)
    p = LockResource(handle)

  if resource != 0 and handle != 0 and p != nil:
    var
      grpIconDir = cast[ptr GRPICONDIR](p)
      count = int grpIconDir.idCount

    for i in 0..<count:
      var
        resource = FindResource(module, MAKEINTRESOURCE(grpIconDir.idEntries[i].nID),
          if isIcon: RT_ICON else: RT_CURSOR)
        handle = LoadResource(module, resource)
        length = SizeofResource(module, resource)
        p = LockResource(handle)

      if resource != 0 and handle != 0 and length != 0 and p != nil:
        var iconImage: wIconImage
        new(iconImage)

        if isIcon:
          iconImage.mHotspot = wDefaultPoint
        else:
          let hotspot = cast[ptr HOTSPOT](p)
          iconImage.mHotspot.x = int hotspot.x
          iconImage.mHotspot.y = int hotspot.y
          length -= sizeof(HOTSPOT)
          p = cast[pointer](cast[int](p) + sizeof(HOTSPOT))

        iconImage.mIcon = newString(length)
        copyMem(&iconImage.mIcon, p, length)
        result.add iconImage

proc IconImagesModuleIndex(module: HMODULE, index: int, isIcon: bool): seq[wIconImage] =
  type
    EnumInfo = object
      index: int
      isIcon: bool
      result: seq[wIconImage]

  proc enumFunc(module: HMODULE, typ: LPTSTR, name: LPTSTR, lParam: LONG_PTR): WINBOOL {.stdcall.} =
    let info = cast[ptr EnumInfo](lParam)
    if info.index == 0:
      info.result = IconImagesModuleGroupId(module, name, info.isIcon)
      return 0
    else:
      info.index.dec
      return 1

  if index >= 0:
    var info = EnumInfo(index: index, isIcon: isIcon, result: @[])
    EnumResourceNames(module, if isIcon: RT_GROUP_ICON else: RT_GROUP_CURSOR,
      enumFunc, cast[LONG_PTR](&info))
    return info.result
  else:
    return IconImagesModuleGroupId(module, MAKEINTRESOURCE(-index), isIcon)

proc IconImages*(str: string): seq[wIconImage] =
  ## Similar to IconImage(), but this function loads all image in the group and
  ## returns a seq.
  let (module, index, isIcon) = loadIconLibrary(str)
  if module != -1:
    defer: FreeLibrary(module)
    result = IconImagesModuleIndex(module, index, isIcon)

  else:
    try:
      var data = readFile(str)
      result = IconImages(&data, data.len)

    except IOError:
      result = IconImages(&str, str.len)

proc save*(icons: openarray[wIconImage], isIcon = true): string =
  ## Stores multiple icon images to a .ico or .cur format data depends on
  ## *isIcon*.
  var headerSize = IcondirSize + icons.len * sizeof(ICONDIRENTRY)
  var header = newString(headerSize)
  var offset = headerSize

  var iconDir = cast[ptr ICONDIR](&header)
  iconDir.idReserved = 0
  iconDir.idType = if isIcon: 1 else: 2
  iconDir.idCount = WORD icons.len

  for i, icon in icons:
    var
      width = icon.getWidth()
      height = icon.getHeight()
      bitCount = icon.getBitCount()
      size = icon.mIcon.len

    if width >= 256: width = 0
    if height >= 256: height = 0

    icondir.idEntries[i].bWidth = uint8 width
    icondir.idEntries[i].bHeight = uint8 height
    icondir.idEntries[i].bReserved = 0
    icondir.idEntries[i].dwBytesInRes = int32 size
    icondir.idEntries[i].dwImageOffset = int32 offset
    icondir.idEntries[i].bColorCount = if bitCount < 8: uint8(1 shl bitCount) else: 0

    if isIcon:
      icondir.idEntries[i].wPlanes = 1
      icondir.idEntries[i].wBitCount = uint16 bitCount
    else:
      if icon.mHotspot == wDefaultPoint:
        icondir.idEntries[i].wPlanes = 0
        icondir.idEntries[i].wBitCount = 0
      else:
        icondir.idEntries[i].wPlanes = WORD icon.mHotspot.x
        icondir.idEntries[i].wBitCount = WORD icon.mHotspot.y

    offset += size

  result = newStringOfCap(offset)
  result.add header
  for icon in icons:
    result.add icon.mIcon

proc save*(self: wIconImage, isIcon = true): string {.validate.} =
  ## Stores single icon image to a .ico or .cur format data depends on *isIcon*.
  result = save([self], isIcon)

proc save*(icons: openarray[wIconImage], filename: string, isIcon = true) =
  ## Stores multiple icon images to a .ico or .cur format file depends on *isIcon*.
  writeFile(filename, icons.save(isIcon))

proc save*(self: wIconImage, filename: string, isIcon = true) {.validate.} =
  ## Stores single icon image to a .ico or .cur format file depends on *isIcon*.
  writeFile(filename, self.save(isIcon))
