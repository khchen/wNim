import tables

import expression, strength, variable, util, term

type
  Constraint* = ref object
    expression*: Expression
    strength*: float
    op*: RelationalOperator

  RelationalOperator* = enum
    OP_LE
    OP_GE
    OP_EQ

proc reduce(e: Expression): Expression =
  var vars = initTable[Variable, float]()
  for term in e.terms:
    let v = term.variable
    var value = vars.getOrDefault(v)
    value += term.coefficient
    vars[v] = value

  var reducedTerms = newSeqOfCap[Term](vars.len)
  for variable, coef in vars:
    reducedTerms.add(newTerm(variable, coef))

  result = newExpression(reducedTerms, e.constant)

proc newConstraint*(e: Expression, op: RelationalOperator, strength: float): Constraint =
  result.new()
  result.expression = reduce(e)
  result.op = op
  result.strength = clipStrength(strength)

proc newConstraint*(e: Expression, op: RelationalOperator): Constraint =
  newConstraint(e, op, REQUIRED)

proc newConstraint*(other: Constraint, strength: float): Constraint =
  newConstraint(other.expression, other.op, strength)

proc `$`*(c: Constraint): string =
  "expression: (" & $c.expression & ") strength: " & $c.strength & " operator: " & $c.op
