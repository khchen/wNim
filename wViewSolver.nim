## wViewSolver is the class for wView layout constraint solver.
##
## :Consts:
##   The strength of the constraint.
##   ==============================  =============================================================
##   Consts                          Description
##   ==============================  =============================================================
##   REQUIRED                        createStrength(1000.0, 1000.0, 1000.0)
##   STRONG                          createStrength(1.0, 0.0, 0.0)
##   MEDIUM                          createStrength(0.0, 1.0, 0.0)
##   WEAK                            createStrength(0.0, 0.0, 1.0)
##   WEAKER                          createStrength(0.0, 0.0, 0.1)
##   WEAKEST                         createStrength(0.0, 0.0, 0.01)
##   ==============================  =============================================================

# const REQUIRED* = createStrength(1000.0, 1000.0, 1000.0)
# const STRONG* = createStrength(1.0, 0.0, 0.0)
# const MEDIUM* = createStrength(0.0, 1.0, 0.0)
# const WEAK* = createStrength(0.0, 0.0, 1.0)
const WEAKER* = createStrength(0.0, 0.0, 0.1)
const WEAKEST* = createStrength(0.0, 0.0, 0.01)

proc `|`*(constraint: Constraint, strength: float): Constraint {.inline.} =
  ## Modify a constraint by specified strength
  newConstraint(constraint, strength)

proc `|`*(strength: float, constraint: Constraint): Constraint {.inline.} =
  ## Modify a constraint by specified strength
  constraint | strength

proc init(self: wViewSolver) =
  mSolver = newSolver()
  mViews = initSet[wView]()

# forward declaration
proc setSize*(self: wWindow, x, y, width, height: int)
proc getRect*(self: wWindow): wRect

proc addConstraint*(self: wViewSolver, constraint: Constraint) {.validate, inline.} =
  ## Add a constraint to the solver.
  mSolver.addConstraint(constraint)

proc addView*(self: wViewSolver, view: wView) {.validate, inline.} =
  ## Add an associated view to the solver.
  mViews.incl view

proc resolve*(self: wViewSolver) {.validate.} =
  ## Count the layout of the associated view.
  # window's current layout as default, size should stronger than position
  for child in mViews:
    if child of wWindow:
      let rect = child.wWindow.getRect()
      mSolver.addConstraint((child.mLeft == rect.x.float) | WEAKEST)
      mSolver.addConstraint((child.mTop == rect.y.float) | WEAKEST)
      mSolver.addConstraint((child.mRight - child.mLeft == rect.width.float) | WEAKER)
      mSolver.addConstraint((child.mBottom - child.mTop == rect.height.float) | WEAKER)

  mSolver.updateVariables()

proc rearrange*(self: wViewSolver) {.validate.} =
  ## Rearrange the layout of the associated view by the result.
  for view in mViews:
    if view of wWindow:
      let x = round(view.mLeft.value).int
      let y = round(view.mTop.value).int
      let width = round(view.mRight.value - view.mLeft.value).int
      let height = round(view.mBottom.value - view.mTop.value).int
      view.wWindow.setSize(x, y, width, height)

iterator items*(self: wViewSolver): wView {.validate.} =
  ## Iterates over each associated view.
  for view in mViews:
    yield view

proc ViewSolver*(): wViewSolver =
  ## Constructor.
  new(result)
  result.init()
