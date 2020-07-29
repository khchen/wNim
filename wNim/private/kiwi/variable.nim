type Variable* = ref object
  mName: string
  value*: float

proc newVariable*(name: string, value: float = 0): Variable =
  result.new()
  result.mName = name
  result.value = value

proc newVariable*(value: float = 0): Variable =
  result.new()
  result.mName = ":anonymous"
  result.value = value

proc name*(v: Variable): string = v.mName

proc `$`*(v: Variable): string =
  "name: " & v.name & " value: " & $v.value
