## wGdiObject is the superclasses of all the GDI objects, such as wPen, wBrush and wFont.

type
  wGdiObjectError* = object of wError

proc getHandle*(self: wGdiObject): HANDLE {.validate, property, inline.} =
  ## Gets the real resource handle of windows system.
  result = mHandle

proc init(self: wGdiObject) =
  discard # do nothing for now

proc delete*(self: wGdiObject) {.validate.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  if mHandle != 0:
    DeleteObject(mHandle)
    mHandle = 0

proc final(self: wGdiObject) =
  delete()
