import term, variable, expression, constraint

# Variable multiply, divide, and unary invert
template `*`*(variable: Variable, coefficient: float): Term = newTerm(variable, coefficient)
template `/`*(variable: Variable, denominator: float): Term = variable * (1 / denominator)
template `-`*(variable: Variable): Term = variable * (-1)

# Term multiply, divide, and unary invert
proc `*`*(term: Term, coefficient: float): Term = term.variable * (term.coefficient * coefficient)
template `/`*(term: Term, denominator: float): Term = term * (1 / denominator)
template `-`*(term: Term): Term = term * (-1)

# Expression multiply, divide, and unary invert
proc `*`*(expression: Expression, coefficient: float): Expression =
  var terms = newSeqOfCap[Term](expression.terms.len)
  for term in expression.terms:
    terms.add(term * coefficient)

  # TODO Do we need to make a copy of the term objects in the array?
  newExpression(terms, expression.constant * coefficient)

type NonlinearExpressionException* = object of ValueError

proc `*`*(expression1, expression2: Expression): Expression =
  if expression1.isConstant:
    return expression2 * expression1.constant
  elif expression2.isConstant:
    return expression1 * expression2.constant
  else:
    raise newException(NonlinearExpressionException, "")

template `/`*(expression: Expression, denominator: float): Expression = expression * (1 / denominator)

proc `/`*(expression1, expression2: Expression): Expression =
  if expression2.isConstant:
    return expression1 / expression2.constant
  else:
    raise newException(NonlinearExpressionException, "")

template `-`*(expression: Expression): Expression = expression * (-1)

# Double multiply
proc `*`*(lhs: float, rhs: Expression): Expression = rhs * lhs
proc `*`*(lhs: float, rhs: Term | Variable): Term = rhs * lhs

# Expression add and subtract
proc `+`*(first, second: Expression): Expression =
  #TODO do we need to copy term objects?
  newExpression(first.terms & second.terms, first.constant + second.constant)

proc `+`*(first: Expression , second: Term): Expression =
  #TODO do we need to copy term objects?
  newExpression(first.terms & second, first.constant)

template `+`*(expression: Expression, variable: Variable): Expression = expression + newTerm(variable)

proc `+`*(expression: Expression, constant: float): Expression =
  newExpression(expression.terms, expression.constant + constant)

template `-`*(lhs: Expression, rhs: Expression | Term | Variable): Expression = lhs + (-rhs)
template `-`*(lhs: Expression, rhs: float): Expression = lhs + (-rhs)

# Term add and subtract
template `+`*(term: Term, expression: Expression): Expression = expression + term
proc `+`*(first, second: Term): Expression = newExpression(@[first, second])
template `+`*(term: Term, variable: Variable): Expression = term + newTerm(variable)
template `+`*(term: Term, constant: float): Expression = newExpression(term, constant)

template `-`*(lhs: Term, rhs: Expression | Term | Variable): Expression = lhs + (-rhs)
template `-`*(lhs: Term, rhs: float): Expression = lhs + (-rhs)

# Variable add and subtract
template `+`*(variable: Variable, expression: Expression): Expression = expression + variable
template `+`*(variable: Variable, term: Term): Expression = term + variable
template `+`*(first, second: Variable): Expression = newTerm(first) + second
template `+`*(variable: Variable, constant: float): Expression = newTerm(variable) + constant

template `-`*(lhs: Variable, rhs: Expression | Term | Variable): Expression = lhs + (-rhs)
template `-`*(lhs: Variable, rhs: float): Expression = lhs + (-rhs)

# Double add and subtract

proc `+`*(lhs: float, rhs: Expression | Term | Variable): Expression = rhs + lhs
proc `-`*(lhs: float, rhs: Expression | Term | Variable): Expression = -rhs + lhs

# Expression relations
template `==`*(first, second: Expression): Constraint = newConstraint(first - second, OP_EQ)
template `==`*(expression: Expression, term: Term): Constraint = expression == newExpression(term)
template `==`*(expression: Expression, variable: Variable): Constraint = expression == newTerm(variable)
template `==`*(expression: Expression, constant: float): Constraint = expression == newExpression(constant)

template `<=`*(first, second: Expression): Constraint = newConstraint(first - second, OP_LE)
template `<=`*(expression: Expression, term: Term): Constraint = expression <= newExpression(term)
template `<=`*(expression: Expression, variable: Variable): Constraint = expression <= newTerm(variable)
template `<=`*(expression: Expression, constant: float): Constraint = expression <= newExpression(constant)

template `>=`*(first, second: Expression): Constraint = newConstraint(first - second, OP_GE)
template `>=`*(expression: Expression, term: Term): Constraint = expression >= newExpression(term)
template `>=`*(expression: Expression, variable: Variable): Constraint = expression >= newTerm(variable)
template `>=`*(expression: Expression, constant: float): Constraint = expression >= newExpression(constant)

# Term relations
template `==`*(lhs: Term, rhs: Expression): Constraint = rhs == lhs
template `==`*(lhs: Term, rhs: Term | Variable | float): Constraint = newExpression(lhs) == rhs

template `<=`*(lhs: Term, rhs: Expression | Term | Variable | float): Constraint = newExpression(lhs) <= rhs
template `>=`*(lhs: Term, rhs: Expression | Term | Variable | float): Constraint = newExpression(lhs) >= rhs

# Variable relations
template `==`*(variable: Variable, expression: Expression): Constraint = expression == variable
template `==`*(variable: Variable, term: Term): Constraint = term == variable
template `==`*(first, second: Variable): Constraint = newTerm(first) == second
proc `==`*(variable: Variable, constant: float): Constraint = newTerm(variable) == constant

template `<=`*(lhs: Variable, rhs: Expression | Term | Variable | float): Constraint = newTerm(lhs) <= rhs

template `>=`*(variable: Variable, expression: Expression): Constraint = newTerm(variable) >= expression
template `>=`*(variable: Variable, term: Term): Constraint = term >= variable
template `>=`*(first, second: Variable): Constraint = newTerm(first) >= second
proc `>=`*(variable: Variable, constant: float): Constraint = newTerm(variable) >= constant

# Double relations
proc `==`*(lhs: float, rhs: Expression | Term | Variable): Constraint = rhs == lhs

proc `<=`*(constant: float, expression: Expression): Constraint = newExpression(constant) <= expression
proc `<=`*(constant: float, term: Term): Constraint = constant <= newExpression(term)
proc `<=`*(constant: float, variable: Variable): Constraint = constant <= newTerm(variable)

proc `>=`*(constant: float, term: Term): Constraint = newExpression(constant) >= term
proc `>=`*(constant: float, variable: Variable): Constraint = constant >= newTerm(variable)

# Constraint strength modifier
proc modifyStrength*(constraint: Constraint, strength: float): Constraint =
  newConstraint(constraint, strength)

proc modifyStrength*(strength: float, constraint: Constraint): Constraint =
  modifyStrength(strength, constraint)

