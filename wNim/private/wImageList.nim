#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wImageList contains a list of images.
## It is used principally in conjunction with wTreeCtrl and wListCtrl.
#
## :Seealso:
##   `wImage <wImage.html>`_
##   `wBitmap <wBitmap.html>`_
##   `wIcon <wIcon.html>`_

include pragma
from winimx import nil # For BITMAP
import wBase, gdiobjects/[wBitmap, wIcon]

proc getHandle*(self: wImageList): HIMAGELIST {.validate, property, inline.} =
  ## Gets the real resource handle in system.
  result = self.mHandle

proc add*(self: wImageList, icon: wIcon): int {.validate, discardable.} =
  ## Adds a new image using an icon.
  ## Return the new zero-based image index.
  wValidate(icon)
  result = ImageList_AddIcon(self.mHandle, icon.mHandle)

proc add*(self: wImageList, bitmap: wBitmap, maskColor: wColor): int {.validate, discardable.} =
  ## Adds a new image using a bitmap and mask color.
  ## Return the new zero-based image index.
  wValidate(bitmap)
  result = ImageList_AddMasked(self.mHandle, bitmap.mHandle, maskColor)

proc add*(self: wImageList, bitmap: wBitmap, mask: wBitmap = nil): int {.validate, discardable.} =
  ## Adds a new image using a bitmap and optional mask bitmap.
  ## Return the new zero-based image index.
  wValidate(bitmap)
  let hbmpMask = if mask.isNil: 0 else: mask.mHandle
  result = ImageList_Add(self.mHandle, bitmap.mHandle, hbmpMask)

proc add*(self: wImageList, image: wImage): int {.validate, discardable.} =
  ## Adds a new image using a image.
  wValidate(image)
  result = self.add(Bitmap(image))

proc replace*(self: wImageList, index: int, icon: wIcon): bool {.validate, discardable.} =
  ## Replaces the existing image with the new image.
  wValidate(icon)
  result = (ImageList_ReplaceIcon(self.mHandle, index, icon.mHandle) != -1)

proc replace*(self: wImageList, index: int, bitmap: wBitmap, mask: wBitmap = nil): bool {.validate, discardable.} =
  ## Replaces the existing image with the new image.
  wValidate(bitmap)
  let hbmpMask = if mask.isNil: 0 else: mask.mHandle
  result = bool ImageList_Replace(self.mHandle, index, bitmap.mHandle, hbmpMask)

proc replace*(self: wImageList, index: int, image: wImage): bool {.validate, discardable.} =
  ## Replaces the existing image with the new image.
  wValidate(image)
  result = self.replace(index, Bitmap(image))

proc remove*(self: wImageList, index: int): bool {.validate, discardable.} =
  ## Removes the image at the given position.
  result = bool ImageList_Remove(self.mHandle, index)

proc removeAll*(self: wImageList): bool {.validate, discardable.} =
  ## Removes all the images in the list.
  result = self.remove(-1)

proc getImageCount*(self: wImageList): int {.validate, property.} =
  ## Returns the number of images in the list.
  result = ImageList_GetImageCount(self.mHandle)

proc getSize*(self: wImageList): wSize {.validate, property.} =
  ## Retrieves the size of the images in the list.
  var cx, cy: INT
  ImageList_GetIconSize(self.mHandle, &cx, &cy)
  result.width = cx
  result.height = cy

proc getBitmap*(self: wImageList, index: int): wBitmap {.validate, property.} =
  ## Create the bitmap from specified index.
  var
    width, height: int32
    info: IMAGEINFO
    bm: winimx.BITMAP

  # need to create new bitmap, don't just warp info.hbmImage
  if index <= self.getImageCount() and
      ImageList_GetIconSize(self.mHandle, &width, &height) != 0 and
      ImageList_GetImageInfo(self.mHandle, index, &info) != 0 and
      GetObject(info.hbmImage, sizeof(winimx.BITMAP), &bm) != 0:

    result = Bitmap(width, height, int bm.bmBitsPixel)
    let
      hdc = CreateCompatibleDC(0)
      prev = SelectObject(hdc, result.mHandle)

    defer:
      SelectObject(hdc, prev)
      DeleteDC(hdc)

    discard ImageList_Draw(self.mHandle, index, hdc, 0, 0, 0)

proc getIcon*(self: wImageList, index: int): wIcon {.validate, property.} =
  ## Create the icon from specified index.
  if index <= self.getImageCount():
    var hIcon = ImageList_GetIcon(self.mHandle, index, ILD_TRANSPARENT)
    result = Icon(hIcon, copy=false)

proc len*(self: wImageList): int {.validate.} =
  ## Returns the number of images in the list.
  result = self.getImageCount()

proc delete*(self: wImageList) {.validate.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  `=destroy`(self[])

wClass(wImageList):

  proc init*(self: wImageList, width: int, height: int, mask = false,
      initialCount = 1) {.validate, inline.} =
    ## Initializes an image list by specifying the image size, whether image masks
    ## should be created, and the initial size of the list.
    let flag = if mask: ILC_COLOR32 or ILC_MASK else: ILC_COLOR32
    self.mHandle = ImageList_Create(width, height, flag, initialCount, 1)

  proc init*(self: wImageList, size: wSize, mask = false,
      initialCount = 1) {.validate, inline.} =
    ## Initializes an image list by specifying the image size, whether image masks
    ## should be created, and the initial size of the list.
    self.init(size.width, size.height, mask, initialCount)
