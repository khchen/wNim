#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## A wImageList contains a list of images.
## It is used principally in conjunction with wTreeCtrl and wListCtrl.
#
## :Seealso:
##   `wImageList <wImageList.html>`_
##   `wBitmap <wBitmap.html>`_
##   `wIcon <wIcon.html>`_

proc add*(self: wImageList, icon: wIcon): int {.validate, discardable.} =
  ## Adds a new image using an icon.
  ## Return the new zero-based image index.
  wValidate(icon)
  result = ImageList_AddIcon(mHandle, icon.mHandle)

proc add*(self: wImageList, bitmap: wBitmap, maskColor: wColor): int {.validate, discardable.} =
  ## Adds a new image using a bitmap and mask color.
  ## Return the new zero-based image index.
  wValidate(bitmap)
  result = ImageList_AddMasked(mHandle, bitmap.mHandle, maskColor)

proc add*(self: wImageList, bitmap: wBitmap, mask: wBitmap = nil): int {.validate, discardable.} =
  ## Adds a new image using a bitmap and optional mask bitmap.
  ## Return the new zero-based image index.
  wValidate(bitmap)
  let hbmpMask = if mask.isNil: 0 else: mask.mHandle
  result = ImageList_Add(mHandle, bitmap.mHandle, hbmpMask)

proc add*(self: wImageList, image: wImage): int {.validate, discardable.} =
  ## Adds a new image using a image.
  wValidate(image)
  result = add(Bmp(image))

proc replace*(self: wImageList, index: int, icon: wIcon): bool {.validate, discardable.} =
  ## Replaces the existing image with the new image.
  wValidate(icon)
  result = (ImageList_ReplaceIcon(mHandle, index, icon.mHandle) != -1)

proc replace*(self: wImageList, index: int, bitmap: wBitmap, mask: wBitmap = nil): bool {.validate, discardable.} =
  ## Replaces the existing image with the new image.
  wValidate(bitmap)
  let hbmpMask = if mask.isNil: 0 else: mask.mHandle
  result = bool ImageList_Replace(mHandle, index, bitmap.mHandle, hbmpMask)

proc replace*(self: wImageList, index: int, image: wImage): bool {.validate, discardable.} =
  ## Replaces the existing image with the new image.
  wValidate(image)
  result = replace(index, Bmp(image))

proc remove*(self: wImageList, index: int): bool {.validate, discardable.} =
  ## Removes the image at the given position.
  result = bool ImageList_Remove(mHandle, index)

proc removeAll*(self: wImageList): bool {.validate, discardable.} =
  ## Removes all the images in the list.
  result = remove(-1)

proc getImageCount*(self: wImageList): int {.validate, property.} =
  ## Returns the number of images in the list.
  result = ImageList_GetImageCount(mHandle)

proc getSize*(self: wImageList): wSize {.validate, property.} =
  ## Retrieves the size of the images in the list.
  var cx, cy: INT
  ImageList_GetIconSize(mHandle, &cx, &cy)
  result.width = cx
  result.height = cy

proc len*(self: wImageList): int {.validate.} =
  result = getImageCount()

proc delete*(self: wImageList) {.validate.} =
  ## Delete the imagelist.
  if mHandle != 0:
    ImageList_Destroy(mHandle)
    mHandle = 0

proc final*(self: wImageList) {.validate.} =
  ## Default finalizer for wImageList.
  delete()

proc init*(self: wImageList, width: int, height: int, mask = false,
    initialCount = 1) {.validate, inline.} =
  let flag = if mask: ILC_COLOR32 or ILC_MASK else: ILC_COLOR32
  mHandle = ImageList_Create(width, height, flag, initialCount, 1)

proc ImageList*(width: int, height: int, mask = false,
    initialCount = 1): wImageList {.inline.} =
  ## Constructor specifying the image size, whether image masks should be created,
  ## and the initial size of the list.
  new(result, final)
  result.init(width, height, mask, initialCount)

proc init*(self: wImageList, size: wSize, mask = false,
    initialCount = 1) {.validate, inline.} =
  init(size.width, size.height, mask, initialCount)

proc ImageList*(size: wSize, mask = false,
    initialCount = 1): wImageList {.inline.} =
  ## Constructor specifying the image size, whether image masks should be created,
  ## and the initial size of the list.
  new(result, final)
  result.init(size, mask, initialCount)
