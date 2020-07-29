type
  SymbolKind* = enum
    EXTERNAL,
    SLACK,
    ERROR,
    DUMMY

  Symbol* = distinct uint32

proc newSymbol*(uniqueId: uint32, kind: SymbolKind): Symbol {.inline.} =
  Symbol(uint32(uniqueId and 0x3fffffff'u32) or (ord(kind).uint32 shl 30))

proc `==`*(a, b: Symbol): bool {.borrow.}

template kind*(s: Symbol): SymbolKind = SymbolKind(s.uint32 shr 30)
template invalid*(s: Symbol): bool = s.uint32 == 0
template valid*(s: Symbol): bool = s.uint32 != 0
