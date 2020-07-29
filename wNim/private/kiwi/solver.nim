import tables
import symbol, constraint, variable, row, util, strength, expression, term

type
  Solver* = ref object
    cns: Table[Constraint, Tag]
    rows: Table[Symbol, Row]
    vars: Table[Variable, Symbol]
    edits: Table[Variable, EditInfo]
    infeasibleRows: seq[Symbol]
    objective: Row
    artificial: Row
    symbolIDCounter: uint32

  Tag = tuple
    marker: Symbol
    other: Symbol

  EditInfo = ref object
    tag: Tag
    constraint: Constraint
    constant: float

  DuplicateConstraintException = object of ValueError
  UnsatisfiableConstraintException = object of ValueError
  UnknownConstraintException = object of ValueError
  DuplicateEditVariableException = object of ValueError
  RequiredFailureException = object of ValueError
  UnknownEditVariableException = object of ValueError

template isNil(t: Tag): bool = t.marker.invalid

proc newEditInfo(constraint: Constraint, tag: Tag, constant: float): EditInfo =
  result.new()
  result.tag = tag
  result.constraint = constraint
  result.constant = constant

proc newSolver*(): Solver =
  result.new()
  result.cns = initTable[Constraint, Tag]()
  result.rows = initTable[Symbol, Row]()
  result.vars = initTable[Variable, Symbol]()
  result.edits = initTable[Variable, EditInfo]()
  result.infeasibleRows = @[]
  result.objective = newRow()

proc createRow(s: Solver, constraint: Constraint, tag: var Tag): Row
proc chooseSubject(row: Row, tag: Tag): Symbol
proc addWithArtificialVariable(s: Solver, row: Row): bool
proc substitute(s: Solver, symbol: Symbol, row: Row)
proc optimize(s: Solver, objective: Row)

proc allDummies(row: Row): bool =
  ## Test whether a row is composed of all dummy variables.
  for k, v in row.cells:
    if k.kind != DUMMY:
      return false
  return true

proc addConstraint*(s: Solver, constraint: Constraint) =
  if constraint in s.cns:
    raise newException(DuplicateConstraintException, "")

  var tag: Tag
  let row = s.createRow(constraint, tag)
  assert(not tag.isNil, "Internal error")

  var subject = chooseSubject(row, tag)

  if subject.invalid and allDummies(row):
    if not nearZero(row.constant):
      raise newException(UnsatisfiableConstraintException, "")
    else:
      subject = tag.marker

  if subject.invalid:
    if not s.addWithArtificialVariable(row):
      raise newException(UnsatisfiableConstraintException, "")
  else:
    row.solveFor(subject)
    s.substitute(subject, row)
    s.rows[subject] = row

  s.cns[constraint] = tag

  s.optimize(s.objective)

proc removeMarkerEffects(s: Solver, marker: Symbol, strength: float) =
  let row = s.rows.getOrDefault(marker)
  if row.isNil:
    s.objective.insert(marker, -strength)
  else:
    s.objective.insert(row, -strength)

proc removeConstraintEffects(s: Solver, constraint: Constraint, tag: Tag) =
  if tag.marker.kind == ERROR:
    s.removeMarkerEffects(tag.marker, constraint.strength)
  elif tag.other.kind == ERROR:
    s.removeMarkerEffects(tag.other, constraint.strength)

proc getMarkerLeavingRow(solver: Solver, marker: Symbol): Row =
  var r1 = Inf
  var r2 = Inf

  var first, second, third: Row
  for s, candidateRow in solver.rows:
    let c = candidateRow.coefficientFor(marker)
    if c == 0.0:
      continue

    if s.kind == EXTERNAL:
      third = candidateRow
    elif c < 0:
      let r = - candidateRow.constant / c
      if r < r1:
        r1 = r
        first = candidateRow
    else:
      let r = candidateRow.constant / c
      if r < r2:
        r2 = r
        second = candidateRow

  if first != nil: return first
  if second != nil: return second
  return third

proc removeConstraint*(s: Solver, constraint: Constraint) =
  let tag = s.cns.getOrDefault(constraint)
  if tag.isNil:
    raise newException(UnknownConstraintException, "")

  s.cns.del(constraint)
  s.removeConstraintEffects(constraint, tag)

  var row = s.rows.getOrDefault(tag.marker)
  if not row.isNil:
    s.rows.del(tag.marker)
  else:
    row = s.getMarkerLeavingRow(tag.marker)
    doAssert(not row.isNil, "internal solver error")

    #This looks wrong! changes made below
    #Symbol leaving = tag.marker;
    #rows.remove(tag.marker);

    var leaving: Symbol
    for sym, v in s.rows:
      if v == row:
        leaving = sym

    doAssert(not leaving.invalid, "internal solver error")

    s.rows.del(leaving)
    row.solveFor(leaving, tag.marker)
    s.substitute(tag.marker, row)

  s.optimize(s.objective)

proc hasConstraint*(s: Solver, constraint: Constraint): bool =
  constraint in s.cns

proc addEditVariable*(s: Solver, variable: Variable, strength: float) =
  if variable in s.edits:
    raise newException(DuplicateEditVariableException, "")

  let strength = clipStrength(strength)

  if strength == REQUIRED:
    raise newException(RequiredFailureException, "")

  let constraint = newConstraint(newExpression(newTerm(variable)), OP_EQ, strength)

  try:
    s.addConstraint(constraint)
  except:
    echo getCurrentException().getStackTrace()

  let info = newEditInfo(constraint, s.cns.getOrDefault(constraint), 0.0)
  s.edits[variable] = info

proc removeEditVariable*(s: Solver, variable: Variable) =
  let edit = s.edits.getOrDefault(variable)
  if edit.isNil:
    raise newException(UnknownEditVariableException, "")

  try:
    s.removeConstraint(edit.constraint)
  except UnknownConstraintException:
    echo getCurrentException().getStackTrace()

  s.edits.del(variable)

proc removeAllEditVariables*(s: Solver) =
  for k, edit in s.edits:
    try:
      s.removeConstraint(edit.constraint)
    except UnknownConstraintException:
      echo getCurrentException().getStackTrace()
  s.edits.clear()

proc hasEditVariable*(s: Solver, variable: Variable): bool =
  variable in s.edits

proc getDualEnteringSymbol(solver: Solver, row: Row): Symbol =
  var ratio = Inf
  for s, currentCell in row.cells:
    if s.kind != DUMMY:
      if currentCell > 0:
        let coefficient = solver.objective.coefficientFor(s)
        let r = coefficient / currentCell
        if r < ratio:
          ratio = r
          result = s

proc dualOptimize(s: Solver) =
  while s.infeasibleRows.len > 0:
    let leaving = s.infeasibleRows.pop()
    let row = s.rows.getOrDefault(leaving)
    if row != nil and row.constant < 0:
      let entering = s.getDualEnteringSymbol(row)
      # fix some strange bug here
      if entering.invalid: continue
      # doAssert(not entering.invalid, "internal solver error")

      s.rows.del(leaving)
      row.solveFor(leaving, entering)
      s.substitute(entering, row)
      s.rows[entering] = row

proc suggestValue*(s: Solver, variable: Variable, value: float) =
  let info = s.edits.getOrDefault(variable)
  if info.isNil:
    raise newException(UnknownEditVariableException, "")

  let delta = value - info.constant
  info.constant = value

  var row = s.rows.getOrDefault(info.tag.marker)
  if row != nil:
    if row.add(-delta) < 0:
      s.infeasibleRows.add(info.tag.marker)
    s.dualOptimize()
    return

  row = s.rows.getOrDefault(info.tag.other)
  if row != nil:
    if row.add(delta) < 0:
      s.infeasibleRows.add(info.tag.other)
    s.dualOptimize()
    return

  for sym, currentRow in s.rows:
    let coefficient = currentRow.coefficientFor(info.tag.marker)
    if coefficient != 0 and currentRow.add(delta * coefficient) < 0 and sym.kind != EXTERNAL:
      s.infeasibleRows.add(sym)

  s.dualOptimize()

proc constraintsCount*(s: Solver): int {.inline.} = s.cns.len # Please dont use this!

# iterator variables*(s: Solver): Variable =
#   for v in keys(s.vars): yield v

proc updateVariables*(s: Solver) =
  ## Update the values of the external solver variables.
  for variable, sym in s.vars:
    let row = s.rows.getOrDefault(sym)
    if row.isNil:
      variable.value = 0
    else:
      variable.value = row.constant

proc newSymbol(s: Solver, kind: SymbolKind): Symbol =
  inc s.symbolIDCounter
  newSymbol(s.symbolIDCounter, kind)

proc getVarSymbol(s: Solver, variable: Variable): Symbol =
  ## Get the symbol for the given variable.
  ##
  ## If a symbol does not exist for the variable, one will be created.
  result = s.vars.getOrDefault(variable)
  if result.invalid:
    result = s.newSymbol(EXTERNAL)
    s.vars[variable] = result

proc createRow(s: Solver, constraint: Constraint, tag: var Tag): Row =
  ## Create a new Row object for the given constraint.
  ##
  ## The terms in the constraint will be converted to cells in the row.
  ## Any term in the constraint with a coefficient of zero is ignored.
  ## This method uses the `getVarSymbol` method to get the symbol for
  ## the variables added to the row. If the symbol for a given cell
  ## variable is basic, the cell variable will be substituted with the
  ## basic row.
  ##
  ## The necessary slack and error variables will be added to the row.
  ## If the constant for the row is negative, the sign for the row
  ## will be inverted so the constant becomes positive.
  ##
  ## The tag will be updated with the marker and error symbols to use
  ## for tracking the movement of the constraint in the tableau.
  let expression = constraint.expression
  let row = newRow(expression.constant)

  for term in expression.terms:
    if not nearZero(term.coefficient):
      let symbol = s.getVarSymbol(term.variable)

      let otherRow = s.rows.getOrDefault(symbol)

      if otherRow.isNil:
        row.insert(symbol, term.coefficient)
      else:
        row.insert(otherRow, term.coefficient)

  case constraint.op
  of OP_LE, OP_GE:
    let coeff = if constraint.op == OP_LE: 1.0 else: -1.0
    let slack = s.newSymbol(SLACK)
    tag.marker = slack
    row.insert(slack, coeff)
    if constraint.strength < REQUIRED:
      let error = s.newSymbol(ERROR)
      tag.other = error
      row.insert(error, -coeff)
      s.objective.insert(error, constraint.strength)
  of OP_EQ:
    if constraint.strength < REQUIRED:
      let errplus = s.newSymbol(ERROR)
      let errminus = s.newSymbol(ERROR)
      tag.marker = errplus
      tag.other = errminus
      row.insert(errplus, -1.0) # v = eplus - eminus
      row.insert(errminus, 1.0) # v - eplus + eminus = 0
      s.objective.insert(errplus, constraint.strength)
      s.objective.insert(errminus, constraint.strength)
    else:
      let dummy = s.newSymbol(DUMMY)
      tag.marker = dummy
      row.insert(dummy)

  # Ensure the row as a positive constant.
  if row.constant < 0:
    row.reverseSign()

  result = row

proc chooseSubject(row: Row, tag: Tag): Symbol =
  ## Choose the subject for solving for the row
  ## <p/>
  ## This method will choose the best subject for using as the solve
  ## target for the row. An invalid symbol will be returned if there
  ## is no valid target.
  ## The symbols are chosen according to the following precedence:
  ## 1) The first symbol representing an external variable.
  ## 2) A negative slack or error tag variable.
  ## If a subject cannot be found, an invalid symbol will be returned.

  for s in row.cells.keys:
    if s.kind == EXTERNAL:
      return s

  if tag.marker.kind == SLACK or tag.marker.kind == ERROR:
    if row.coefficientFor(tag.marker) < 0:
      return tag.marker

  if tag.other.valid and (tag.other.kind == SLACK or tag.other.kind == ERROR):
    if row.coefficientFor(tag.other) < 0:
      return tag.other

proc anyPivotableSymbol(s: Solver, row: Row): Symbol =
  ## Get the first Slack or Error symbol in the row.
  ##
  ## If no such symbol is present, and Invalid symbol will be returned.
  for k, v in row.cells:
    if k.kind == SLACK or k.kind == ERROR:
      return k

proc addWithArtificialVariable(s: Solver, row: Row): bool =
  ## Add the row to the tableau using an artificial variable.
  ##
  ## This will return false if the constraint cannot be satisfied.

  #TODO check this

  # Create and add the artificial variable to the tableau

  let art = s.newSymbol(SLACK)
  s.rows[art] = newRow(row)

  s.artificial = newRow(row)

  # Optimize the artificial objective. This is successful
  # only if the artificial objective is optimized to zero.
  s.optimize(s.artificial)
  let success = nearZero(s.artificial.constant)
  s.artificial = nil

  # If the artificial variable is basic, pivot the row so that
  # it becomes basic. If the row is constant, exit early.

  let rowptr = s.rows.getOrDefault(art)

  if rowptr != nil:
    #/**this looks wrong!!!*/
    #rows.remove(rowptr);

    var deleteQueue = newSeq[Symbol]()
    for sym, v in s.rows:
      if v == rowptr:
        deleteQueue.add(sym)
    for sym in deleteQueue:
      s.rows.del(sym)

    if rowptr.cells.len == 0:
      return success

    let entering = s.anyPivotableSymbol(rowptr)
    if entering.invalid:
      return false # unsatisfiable (will this ever happen?)

    rowptr.solveFor(art, entering)
    s.substitute(entering, rowptr)
    s.rows[entering] = rowptr

  # Remove the artificial variable from the tableau.
  for v in s.rows.values:
    v.remove(art)

  s.objective.remove(art)

  return success

proc substitute(s: Solver, symbol: Symbol, row: Row) =
  ## Substitute the parametric symbol with the given row.
  ##
  ## This method will substitute all instances of the parametric symbol
  ## in the tableau and the objective function with the given row.
  for sym, r in s.rows:
    r.substitute(symbol, row)
    if sym.kind != EXTERNAL and r.constant < 0:
      s.infeasibleRows.add(sym)

  s.objective.substitute(symbol, row)

  if s.artificial != nil:
    s.artificial.substitute(symbol, row)

proc getEnteringSymbol(objective: Row): Symbol =
  ## Compute the entering variable for a pivot operation.
  ##
  ## This method will return first symbol in the objective function which
  ## is non-dummy and has a coefficient less than zero. If no symbol meets
  ## the criteria, it means the objective function is at a minimum, and an
  ## invalid symbol is returned.

  for k, v in objective.cells:
    if k.kind != DUMMY and v < 0:
      return k

proc getLeavingRow(s: Solver, entering: Symbol): Row =
  ## Compute the row which holds the exit symbol for a pivot.
  ##
  ## This documentation is copied from the C++ version and is outdated
  ##
  ##
  ## This method will return an iterator to the row in the row map
  ## which holds the exit symbol. If no appropriate exit symbol is
  ## found, the end() iterator will be returned. This indicates that
  ## the objective function is unbounded.
  var ratio = Inf
  for key, candidateRow in s.rows:
    if key.kind != EXTERNAL:
      let temp = candidateRow.coefficientFor(entering)
      if temp < 0:
        let temp_ratio = (-candidateRow.constant / temp)
        if temp_ratio < ratio:
          ratio = temp_ratio
          result = candidateRow

proc optimize(s: Solver, objective: Row) =
  ## Optimize the system for the given objective function.
  ##
  ## This method performs iterations of Phase 2 of the simplex method
  ## until the objective function reaches a minimum.
  while true:
    let entering = getEnteringSymbol(objective)
    if entering.invalid:
      return

    let entry = s.getLeavingRow(entering)
    doAssert(not entry.isNil, "The objective is unbounded.")

    var entryKey: Symbol
    for key, v in s.rows:
      if v == entry:
        entryKey = key

    s.rows.del(entryKey)
    entry.solveFor(entryKey, entering)
    s.substitute(entering, entry)
    s.rows[entering] = entry
