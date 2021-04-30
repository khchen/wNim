#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

# Serialization and deserialization of arbitrary data structures.
# Use binary format and can be used at compile-time.

import typetraits

proc `[]`[T](x: T, U: typedesc): U =
  cast[U](x)

proc add(s: var string, x: SomeInteger) {.inline.} =
  when nimvm:
    when sizeof(x) == 8:
      s.add chr(x[byte]) & chr((x shr 8)[byte]) & chr((x shr 16)[byte]) & chr((x shr 24)[byte]) &
        chr((x shr 32)[byte]) & chr((x shr 40)[byte]) & chr((x shr 48)[byte]) & chr((x shr 56)[byte])
    elif sizeof(x) == 4:
      s.add chr(x[byte]) & chr((x shr 8)[byte]) & chr((x shr 16)[byte]) & chr((x shr 24)[byte])
    elif sizeof(x) == 2:
      s.add chr((x[byte])) & chr((x shr 8)[byte])
    else:
      s.add chr(x[byte])
  else:
    let L = s.len
    s.setLen(L + sizeof(x))
    ((addr s[0])[int] + L)[ptr x.type][] = x

proc extract(s: string, T: type[SomeInteger], i: var int): T {.inline.} =
  when nimvm:
    when sizeof(T) == 8:
      result = (s[i].ord[T]) or (s[i+1].ord[T] shl 8) or (s[i+2].ord[T] shl 16) or (s[i+3].ord[T] shl 24) or
        (s[i+4].ord[T] shl 32) or (s[i+5].ord[T] shl 40) or (s[i+6].ord[T] shl 48) or (s[i+7].ord[T] shl 56)
    elif sizeof(T) == 4:
      result = (s[i].ord[T]) or (s[i+1].ord[T] shl 8) or (s[i+2].ord[T] shl 16) or (s[i+3].ord[T] shl 24)
    elif sizeof(T) == 2:
      result = (s[i].ord[T]) or (s[i+1].ord[T] shl 8)
    else:
      result = s[i].ord[T]
    i.inc(sizeof(T))
  else:
    result = ((unsafeaddr s[0])[int] + i)[ptr T][]
    i.inc(sizeof(T))

proc pack(s: var string, x: bool)
proc pack(s: var string, x: SomeInteger)
proc pack(s: var string, x: SomeFloat)
proc pack(s: var string, x: enum)
proc pack(s: var string, x: string)
proc pack(s: var string, x: char)
proc pack[S, T](s: var string, x: array[S, T])
proc pack[T](s: var string, x: seq[T])
proc pack(s: var string, x: tuple)
proc pack[T](s: var string, x: set[T])
proc pack(s: var string, x: object)
proc pack(s: var string, x: ref)
proc pack(s: var string, x: distinct)
proc pack(s: var string, x: ptr|pointer)

proc unpack(s: string, i: var int, x: var bool)
proc unpack[T: SomeInteger](s: string, i: var int, x: var T)
proc unpack[T: SomeFloat](s: string, i: var int, x: var T)
proc unpack[T: enum](s: string, i: var int, x: var T)
proc unpack[T: string](s: string, i: var int, x: var T)
proc unpack[T: char](s: string, i: var int, x: var T)
proc unpack[S, T](s: string, i: var int, x: var array[S, T])
proc unpack[T](s: string, i: var int, x: var seq[T])
proc unpack(s: string, i: var int, x: var tuple)
proc unpack[T](s: string, i: var int, x: var set[T])
proc unpack[T: object](s: string, i: var int, x: var T)
proc unpack[T: ref](s: string, i: var int, x: var T)
proc unpack[T: distinct](s: string, i: var int, x: var T)
proc unpack[T: ptr|pointer](s: string, i: var int, x: var T)

proc pack(s: var string, x: bool) =
  s.add if x: chr(1) else: chr(0)

proc unpack(s: string, i: var int, x: var bool) =
  if s[i] == chr(0):
    x = false
  else:
    x = true
  i.inc

proc pack(s: var string, x: SomeInteger) =
  s.add x

proc unpack[T: SomeInteger](s: string, i: var int, x: var T) =
  x = s.extract(T, i)

proc pack(s: var string, x: SomeFloat) =
  s.add (float64 x)[uint64]

proc unpack[T: SomeFloat](s: string, i: var int, x: var T) =
  x = T s.extract(uint64, i)[float64]

proc pack(s: var string, x: enum) =
  s.pack(x.ord)

proc unpack[T: enum](s: string, i: var int, x: var T) =
  var y: int
  s.unpack(i, y)
  x = T y

proc pack(s: var string, x: string) =
  s.add uint32(x.len)
  s.add x

proc unpack[T: string](s: string, i: var int, x: var T) =
  let L = int s.extract(uint32, i)
  x = s[i..<i+L]
  i.inc(L)

proc pack(s: var string, x: char) =
  s.add x

proc unpack[T: char](s: string, i: var int, x: var T) =
  x = s[i]
  i.inc

proc pack[S, T](s: var string, x: array[S, T]) =
  for i in x:
    s.pack i

proc unpack[S, T](s: string, i: var int, x: var array[S, T]) =
  for j in x.mitems:
    s.unpack(i, j)

proc pack[T](s: var string, x: seq[T]) =
  s.add uint32(x.len)
  for i in x:
    s.pack i

proc unpack[T](s: string, i: var int, x: var seq[T]) =
  let L = int s.extract(uint32, i)
  x.setLen(L)
  for j in x.mitems:
    s.unpack(i, j)

proc pack(s: var string, x: tuple) =
  for y in x.fields:
    s.pack(y)

proc unpack(s: string, i: var int, x: var tuple) =
  for y in x.fields:
    s.unpack(i, y)

proc pack[T](s: var string, x: set[T]) =
  s.add uint32(x.len)
  for i in x:
    s.pack i

proc unpack[T](s: string, i: var int, x: var set[T]) =
  x = {}
  let L = int s.extract(uint32, i)
  var y: T
  for j in 0..<L:
    s.unpack(i, y)
    x.incl y

proc pack(s: var string, x: object) =
  for y in x.fields:
    s.pack(y)

proc unpack[T: object](s: string, i: var int, x: var T) =
  for y in x.fields:
    s.unpack(i, y)

proc pack(s: var string, x: ref) =
  if x.isNil:
    s.pack(false)
  else:
    s.pack(true)
    s.pack(x[])

proc unpack[T: ref](s: string, i: var int, x: var T) =
  var notNil: bool
  s.unpack(i, notNil)

  if notNil:
    new(x)
    s.unpack(i, x[])
  else:
    x = nil

proc pack(s: var string, x: distinct) =
  s.pack(x.distinctBase)

proc unpack[T: distinct](s: string, i: var int, x: var T) =
  when nimvm:
    # bug of nimvm?
    var y: x.distinctBase.type
    s.unpack(i, y)
    x = T y
  else:
    s.unpack(i, x.distinctBase)

proc pack(s: var string, x: ptr|pointer) =
  s.pack(x[int])

proc unpack[T: ptr|pointer](s: string, i: var int, x: var T) =
  var y: int
  s.unpack(i, y)
  x = y[T]

proc pack*[T](x: T): string {.inline.} =
  ## Returns a string representation of x (serialization, marshalling).
  result.pack(x)

proc unpack*[T](x: string): T {.inline.} =
  ## Reads data and transforms it to a type T (deserialization, unmarshalling).
  var i: int
  x.unpack(i, result)

proc unpack*[T](x: string, t: typedesc[T]): T {.inline.} =
  ## Reads data and transforms it to a type T (deserialization, unmarshalling).
  var i: int
  x.unpack(i, result)

when isMainModule:
  proc test(typ: typedesc) =
    var
      s: string
      index: int
      n: typ
      nlow = typ.low
      nhigh = typ.high

    s.add nlow
    n = s.extract(typ, index)
    assert n == nlow

    s.add nhigh
    n = s.extract(typ, index)
    assert n == nhigh

  static:
    test(int)
    test(uint)
    test(int8)
    test(uint8)
    test(int16)
    test(uint16)
    test(int32)
    test(uint32)
    test(int64)
    test(uint64)
