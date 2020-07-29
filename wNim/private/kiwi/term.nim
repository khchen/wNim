import variable

type Term* = object
  variable*: Variable
  coefficient*: float

proc newTerm*(variable: Variable, coefficient: float = 1): Term {.inline.} =
  result.variable = variable
  result.coefficient = coefficient

proc value*(t: Term): float {.inline.} =
  t.coefficient * t.variable.value

proc `$`*(t: Term): string =
  "variable: (" & $t.variable & ") coefficient: " & $t.coefficient
