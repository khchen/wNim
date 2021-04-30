#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wxRegion represents a simple or complex region on a device context or window.
#
## :Superclass:
##    `wGdiObject <wGdiObject.html>`_
#
## :Seealso:
##    `wDC <wDC.html>`_

include ../pragma
import ../wBase, ../wImage, wGdiObject
export wGdiObject

type
  wRegionOp* = enum
    wRegionAnd = RGN_AND
    wRegionOr = RGN_OR
    wRegionXor = RGN_XOR
    wRegionDiff = RGN_DIFF
    wRegionCopy = RGN_COPY

wClass(wRegion of wGdiObject):

  proc init*(self: wRegion) {.validate, inline.} =
    ## Initializes am empty region.
    self.wGdiObject.init()
    self.mHandle = 0 # An empty regin, let mHandle == 0

  proc init*(self: wRegion, x, y, width, height: int, elliptic = false) {.validate.} =
    ## Initializes a rectangular or elliptic region.
    self.wGdiObject.init()

    if elliptic:
      self.mHandle = CreateEllipticRgn(x, y, x + width, y + height)
    else:
      self.mHandle = CreateRectRgn(x, y, x + width, y + height)

  proc init*(self: wRegion, point: wPoint, size: wSize, elliptic = false) {.validate, inline.} =
    ## Initializes a rectangular or elliptic region.
    self.init(point.x, point.y, size.width, size.height, elliptic)

  proc init*(self: wRegion, rect: wRect, elliptic = false) {.validate, inline.} =
    ## Initializes a rectangular or elliptic region.
    self.init(rect.x, rect.y, rect.width, rect.height, elliptic)

  proc init*(self: wRegion, x, y, width, height: int, radius: float) {.validate.} =
    ## Initializes a rectangular region with rounded corners.
    ## If radius is positive, the value is assumed to be the radius of the rounded corner.
    ## If radius is negative, the absolute value is assumed to be the proportion of the
    ## smallest dimension of the rectangle
    self.wGdiObject.init()

    var
      r = int radius
      x2 = x + width
      y2 = y + height

    if radius < 0:
      r = int(-radius * min(width, height).float)

    self.mHandle = CreateRoundRectRgn(x, y, x2, y2, r * 2, r * 2)

  proc init*(self: wRegion, point: wPoint, size: wSize, radius: float) {.validate, inline.} =
    ## Initializes a rectangular region with rounded corners.
    ## If radius is positive, the value is assumed to be the radius of the rounded corner.
    ## If radius is negative, the absolute value is assumed to be the proportion of the
    ## smallest dimension of the rectangle
    self.init(point.x, point.y, size.width, size.height, radius)

  proc init*(self: wRegion, rect: wRect, radius: float) {.validate, inline.} =
    ## Initializes a rectangular region with rounded corners.
    ## If radius is positive, the value is assumed to be the radius of the rounded corner.
    ## If radius is negative, the absolute value is assumed to be the proportion of the
    ## smallest dimension of the rectangle
    self.init(rect.x, rect.y, rect.width, rect.height, radius)

  proc init*(self: wRegion, image: wImage) {.validate.} =
    ## Initializes a region from a wImage object.
    wValidate(image)
    self.wGdiObject.init()

    let size = image.getSize()
    self.mHandle = CreateRectRgn(0, 0, size.width, size.height)
    for x in 0..<size.width:
      for y in 0..<size.height:
        let pix = image.getPixel(x, y)
        if (pix and 0xff000000) == 0:
          var tmp = CreateRectRgn(x, y, x + 1, y + 1)
          CombineRgn(self.mHandle, self.mHandle, tmp, RGN_DIFF)
          DeleteObject(tmp)

  proc init*(self: wRegion, hRgn: HRGN, copy = true, shared = false) {.validate.} =
    ## Initializes a region from system region handle.
    ## If *copy* is false, the function only wrap the handle to wRegion object.
    ## If *shared* is false, the handle will be destroyed together with wRegion
    ## object by the GC. Otherwise, the caller is responsible for destroying it.
    self.wGdiObject.init()

    if copy:
      if hRgn != 0:
        self.mHandle = CreateRectRgn(0, 0, 0, 0)
        CombineRgn(self.mHandle, hRgn, 0, RGN_COPY)
      else:
        self.mHandle = 0

    else:
      self.mHandle = hRgn
      self.mDeletable = not shared

  proc init*(self: wRegion, region: wRegion) {.validate, inline.} =
    ## Initializes a region from a wRegion object, aka. copy.
    wValidate(region)
    self.init(region.mHandle, copy=true)

proc clear*(self: wRegion) {.validate.} =
  ## Clears the current region.
  self.delete()

proc getBox*(self: wRegion): wRect {.validate, property.} =
  ## Returns the outer bounds of the region.
  if self.mHandle != 0:
    var rect: RECT
    GetRgnBox(self.mHandle, rect)
    result = toWRect(rect)

proc isEmpty*(self: wRegion): bool {.validate.} =
  ## Returns true if the region is empty, false otherwise
  let box = self.getBox()
  result = (box.width == 0 and box.height == 0)

proc isEqual*(self: wRegion, region: wRegion): bool {.validate.} =
  ## Returns true if the region is equal to another one.
  wValidate(region)
  if self.mHandle == 0 and region.mHandle == 0:
    result = true

  elif (self.mHandle == 0 and region.mHandle != 0) or
      (self.mHandle != 0 and region.mHandle == 0):
    result = false

  else:
    result = (EqualRgn(self.mHandle, region.mHandle) != 0)

proc offset*(self: wRegion, x, y: int) {.validate.} =
  ## Moves the region by the specified offsets in horizontal and vertical directions.
  if self.mHandle != 0 and (x != 0 or y != 0):
    OffsetRgn(self.mHandle, x, y)

proc combine*(self: wRegion, region: wRegion, op: wRegionOp) {.validate.} =
  ## Combine another region with this one. *op* can be wRegionAnd, wRegionOr,
  ## wRegionXor, wRegionDiff, or wRegionCopy.
  wValidate(region)
  if self.mHandle == 0:
    case op
    of wRegionCopy, wRegionOr, wRegionXor:
      # dup a region, just use the initializer.
      self.init(region)

    of wRegionAnd, wRegionDiff:
      discard # leave empty

  else:
    if region.mHandle == 0:
      case op
      of wRegionAnd, wRegionCopy:
        self.delete() # become empty
      of wRegionOr, wRegionXor, wRegionDiff:
        discard
    else:
      let src1 = if op == wRegionCopy: region.mHandle else: self.mHandle
      CombineRgn(self.mHandle, src1, region.mHandle, int32 op)

proc contains*(self: wRegion, x: int, y: int): bool {.validate.} =
  ## Returns true if the given point is contained within the region.
  if self.mHandle != 0 and PtInRegion(self.mHandle, x, y) != 0:
    result = true

proc contains*(self: wRegion, point: wPoint): bool {.validate, inline.} =
  ## Returns true if the given point is contained within the region.
  result = self.contains(point.x, point.y)

proc contains*(self: wRegion, rect: wRect): bool {.validate.} =
  ## Returns true if the given rect is contained within the region.
  var r = toRect(rect)
  if self.mHandle != 0 and RectInRegion(self.mHandle, r) != 0:
    result = true

proc contains*(self: wRegion, x, y, width, height: int): bool {.validate, inline.} =
  ## Returns true if the given rect is contained within the region.
  result = self.contains((x, y, width, height))

proc contains*(self: wRegion, point: wPoint, size: wSize): bool {.validate, inline.} =
  ## Returns true if the given rect is contained within the region.
  result = self.contains((point.x, point.y, size.width, size.height))

proc `or`*(region1, region2: wRegion): wRegion =
  ## Or operator for regions.
  wValidate(region1, region2)
  result = Region(region1)
  result.combine(region2, wRegionOr)

proc `and`*(region1, region2: wRegion): wRegion =
  ## And operator for regions.
  wValidate(region1, region2)
  result = Region(region1)
  result.combine(region2, wRegionAnd)

proc `xor`*(region1, region2: wRegion): wRegion =
  ## Xor operator for regions.
  wValidate(region1, region2)
  result = Region(region1)
  result.combine(region2, wRegionXor)

proc `-`*(region1, region2: wRegion): wRegion =
  ## Subtract operator for regions.
  wValidate(region1, region2)
  result = Region(region1)
  result.combine(region2, wRegionDiff)

proc `|=`*(region1, region2: wRegion) {.inline.} =
  ## Or in place operator for regions.
  wValidate(region1, region2)
  region1.combine(region2, wRegionOr)

proc `&=`*(region1, region2: wRegion) {.inline.} =
  ## And in place operator for regions.
  wValidate(region1, region2)
  region1.combine(region2, wRegionAnd)

proc `^=`*(region1, region2: wRegion) {.inline.} =
  ## Xor in place operator for regions.
  wValidate(region1, region2)
  region1.combine(region2, wRegionXor)

proc `-=`*(region1, region2: wRegion) {.inline.} =
  ## Subtract in place operator for regions.
  wValidate(region1, region2)
  region1.combine(region2, wRegionDiff)

proc `==`*(region1, region2: wRegion): bool {.inline.} =
  ## == operator for regions.
  wValidate(region1, region2)
  result = region1.isEqual(region2)

template wNilRegion*(): untyped =
  ## Predefined empty regin. **Don't delete**.
  wGDIStock(wRegion, NilRegion):
    Region()
