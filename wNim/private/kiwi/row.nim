import tables

import symbol, util

type Row* = ref object
  constant*: float
  cells*: Table[Symbol, float]

proc newRow*(constant: float = 0): Row =
  result.new()
  result.cells = initTable[Symbol, float]()
  result.constant = constant

proc newRow*(other: Row): Row =
  result.new()
  result.cells = other.cells
  result.constant = other.constant

proc add*(r: Row, value: float): float =
  ## Add a constant value to the row constant.
  r.constant += value
  result = r.constant

proc insert*(r: Row, symbol: Symbol, coefficient: float = 1.0) =
  ## Insert a symbol into the row with a given coefficient.
  ##
  ## If the symbol already exists in the row, the coefficient will be
  ## added to the existing coefficient. If the resulting coefficient
  ## is zero, the symbol will be removed from the row

  let coefficient = coefficient + r.cells.getOrDefault(symbol)
  if nearZero(coefficient):
    r.cells.del(symbol)
  else:
    r.cells[symbol] = coefficient

proc insert*(r, other: Row, coefficient: float = 1.0) =
  ## Insert a row into this row with a given coefficient.
  ## The constant and the cells of the other row will be multiplied by
  ## the coefficient and added to this row. Any cell with a resulting
  ## coefficient of zero will be removed from the row.

  r.constant += other.constant * coefficient

  for s, v in other.cells:
    let coeff = v * coefficient

    # r.insert(s, coeff)  this line looks different than the c++

    # changes start here
    let temp = r.cells.getOrDefault(s) + coeff
    if nearZero(temp):
      r.cells.del(s)
    else:
      r.cells[s] = temp

proc remove*(r: Row, symbol: Symbol) =
  ## Remove the given symbol from the row.
  r.cells.del(symbol)

proc reverseSign*(r: Row) =
  ## Reverse the sign of the constant and all cells in the row.
  r.constant = -r.constant
  for s, v in r.cells:
    r.cells[s] = -v

proc solveFor*(r: Row, symbol: Symbol) =
  ## Solve the row for the given symbol.
  ##
  ## This method assumes the row is of the form a * x + b * y + c = 0
  ## and (assuming solve for x) will modify the row to represent the
  ## right hand side of x = -b/a * y - c / a. The target symbol will
  ## be removed from the row, and the constant and other cells will
  ## be multiplied by the negative inverse of the target coefficient.
  ## The given symbol *must* exist in the row.

  let coeff = -1.0 / r.cells[symbol]
  r.cells.del(symbol)
  r.constant *= coeff

  for s, v in r.cells:
    r.cells[s] = v * coeff

proc solveFor*(r: Row, lhs, rhs: Symbol) =
  ## Solve the row for the given symbols.
  ##
  ## This method assumes the row is of the form x = b * y + c and will
  ## solve the row such that y = x / b - c / b. The rhs symbol will be
  ## removed from the row, the lhs added, and the result divided by the
  ## negative inverse of the rhs coefficient.
  ## The lhs symbol *must not* exist in the row, and the rhs symbol
  ## must* exist in the row.

  r.insert(lhs, -1.0)
  r.solveFor(rhs)

proc coefficientFor*(r: Row, symbol: Symbol): float {.inline.} =
  ## Get the coefficient for the given symbol.
  ##
  ## If the symbol does not exist in the row, zero will be returned.
  r.cells.getOrDefault(symbol)

proc substitute*(r: Row, symbol: Symbol, row: Row) =
  ## Substitute a symbol with the data from another row.
  ##
  ## Given a row of the form a * x + b and a substitution of the
  ## form x = 3 * y + c the row will be updated to reflect the
  ## expression 3 * a * y + a * c + b.
  ## If the symbol does not exist in the row, this is a no-op.
  if symbol in r.cells:
    let coefficient = r.cells[symbol]
    r.cells.del(symbol)
    r.insert(row, coefficient)
