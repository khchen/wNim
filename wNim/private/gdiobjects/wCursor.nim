#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## A cursor is a small bitmap usually used for denoting where the mouse pointer
## is. There are two special predefined cursor: wNilCursor and wDefaultCursor.
## See wWindow.setCursor() for details.
#
## :Superclass:
##    `wGdiObject <wGdiObject.html>`_
#
## :Seealso:
##    `wDC <wDC.html>`_
##    `wPredefined <wPredefined.html>`_
#
## :Consts:
##    ==============================  =============================================================
##    Cursor Identifier               Description
##    ==============================  =============================================================
##    wCursorArrow                    Standard arrow
##    wCursorIbeam                    I-beam
##    wCursorWait                     Hourglass
##    wCursorCross                    Crosshair
##    wCursorUpArrow                  Vertical arrow
##    wCursorSizeNwse                 Double-pointed arrow pointing northwest and southeast
##    wCursorSizeNesw                 Double-pointed arrow pointing northeast and southwest
##    wCursorSizeWe                   Double-pointed arrow pointing west and east
##    wCursorSizeNs                   Double-pointed arrow pointing north and south
##    wCursorSizeAll                  Four-pointed arrow pointing north, south, east, and west
##    wCursorNo                       Slashed circle
##    wCursorHand                     Hand
##    wCursorAppStarting              Standard arrow and small hourglass
##    wCursorHelp                     Arrow and question mark
##    ==============================  =============================================================

const
  wCursorArrow* = 32512
  wCursorIbeam* = 32513
  wCursorWait* = 32514
  wCursorCross* = 32515
  wCursorUpArrow* = 32516
  wCursorSize* = 32640
  wCursorIcon* = 32641
  wCursorSizeNwse* = 32642
  wCursorSizeNesw* = 32643
  wCursorSizeWe* = 32644
  wCursorSizeNs* = 32645
  wCursorSizeAll* = 32646
  wCursorNo* = 32648
  wCursorHand* = 32649
  wCursorAppStarting* = 32650
  wCursorHelp* = 32651

proc isNilCursor(self: wCursor): bool {.inline.} =
  result = self.mHandle == 0

proc isCustomCursor(self: wCursor): bool {.inline.} =
  result = self.mHandle != -1 and self.mHandle != 0

proc getHotSpot*(self: wCursor): wPoint {.validate, property.} =
  ## Returns the coordinates of the cursor hot spot.
  var iconInfo: ICONINFO
  if GetIconInfo(self.mHandle, iconInfo) != 0:
    result = (int iconInfo.xHotspot, int iconInfo.yHotspot)

proc getSize*(self: wCursor): wSize {.validate, property.} =
  ## Returns the size of the cursor.
  result = getIconSize(self.mHandle)

method delete*(self: wCursor) =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  if self.mDeletable:
    if self.mIconResource:
      DestroyIcon(self.mHandle)
    else:
      DestroyCursor(self.mHandle)
    self.mHandle = 0

proc final*(self: wCursor) =
  ## Default finalizer for wCursor.
  self.delete()

proc init*(self: wCursor) =
  ## Initializer.
  self.wGdiObject.init()
  self.mDeletable = false
  self.mHandle = 0

proc Cursor*(): wCursor {.inline.} =
  ## Creates a nil cursor.
  new(result, final)
  result.init()

proc init*(self: wCursor, id: int) =
  ## Initializer.
  self.init()
  if id == -1:
    self.mHandle = -1
  else:
    self.mHandle = LoadCursor(0, MAKEINTRESOURCE(id))

proc Cursor*(id: int): wCursor {.inline.} =
  ## Creates a cursor using a cursor identifier.
  new(result, final)
  result.init(id)

proc init*(self: wCursor, data: ptr byte, length: int, size=wDefaultSize) =
  ## Initializer.
  # here support .ico, .png, .cur, .ani
  wValidate(data)
  self.init()
  self.mHandle = createIconFromMemory(data, length, width=size.width,
    height=size.height, isIcon=false)

  if self.mHandle != 0:
    self.mDeletable = true
    self.mIconResource = true

proc Cursor*(data: ptr byte, length: int, size = wDefaultSize): wCursor {.inline.} =
  ## Creates a cursor from binary data of cursor file format.
  ## If size is specified, it searches the icon or cursor that best fits the size.
  ## Otherwise, it chooses the size for current display device.
  ## Supports .cur, .ani, and .ico.
  wValidate(data)
  new(result, final)
  result.init(data, length, size)

proc init*(self: wCursor, str: string) =
  ## Initializer.
  wValidate(str)
  self.init()
  if str.isVaildPath():
    self.mHandle = LoadCursorFromFile(str)
    self.mDeletable = false
    self.mIconResource = false
  else:
    self.init(cast[ptr byte](&str), str.len)

proc Cursor*(str: string): wCursor {.inline.} =
  ## Creates a cursor from a file. Supports .cur and .ani.
  ## If str is not a valid file path, it will be regarded as the binary data in memory.
  wValidate(str)
  new(result, final)
  result.init(str)

proc init*(self: wCursor, icon: wIcon, hotSpot = wDefaultPoint) =
  ## Initializer.
  wValidate(icon)
  self.init()
  self.mHandle = createIconFromHIcon(icon.mHandle, isIcon=false, hotSpot=hotSpot)
  if self.mHandle != 0:
    self.mDeletable = true
    self.mIconResource = true

proc Cursor*(icon: wIcon, hotSpot = wDefaultPoint): wCursor {.inline.} =
  ## Creates a cursor from the given wIcon object.
  wValidate(icon)
  new(result, final)
  result.init(icon, hotSpot)

proc init*(self: wCursor, image: wImage, hotSpot = wDefaultPoint) =
  ## Initializer.
  wValidate(image)
  self.init()
  try:
    var icon = Icon(image)
    self.init(icon, hotSpot)
  except:
    self.mHandle = 0

proc Cursor*(image: wImage, hotSpot = wDefaultPoint): wCursor {.inline.} =
  ## Creates a cursor from the given wImage object.
  wValidate(image)
  new(result, final)
  result.init(image, hotSpot)

proc init*(self: wCursor, cursor: wCursor, hotSpot = wDefaultPoint) =
  ## Initializer.
  wValidate(cursor)
  self.init()
  self.mHandle = createIconFromHIcon(cursor.mHandle, isIcon=false, hotSpot=hotSpot)
  if self.mHandle != 0:
    self.mDeletable = true
    self.mIconResource = true

proc Cursor*(cursor: wCursor, hotSpot = wDefaultPoint): wCursor {.inline.} =
  ## Copy constructor. HotSpot can be changed if needed.
  wValidate(cursor)
  new(result, final)
  result.init(cursor, hotSpot)
