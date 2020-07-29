import term, variable

type Expression* = ref object
  terms*: seq[Term]
  constant*: float

proc newExpression*(terms: seq[Term], constant: float = 0): Expression =
  result.new()
  result.terms = terms
  result.constant = constant

proc newExpression*(constant: float = 0): Expression =
  newExpression(@[], constant)

proc newExpression*(term: Term, constant: float = 0): Expression =
  newExpression(@[term], constant)

proc newExpression*(v: Variable): Expression =
  newExpression(newTerm(v))

proc value*(e: Expression): float =
  result = e.constant
  for t in e.terms:
    result += t.value

proc isConstant*(e: Expression): bool = e.terms.len == 0

proc `$`*(e: Expression): string =
  result = "isConstant: " & $e.isConstant & " constant: " & $e.constant
  if not e.isConstant:
    result &= " terms: ["
    for term in e.terms:
      result &= "("
      result &= $term
      result &= ")"
    result &= "]"
