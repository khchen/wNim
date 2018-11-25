#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## *wResizer* is the class for *wResizable* layout constraint solver.
## It is based on yglukhov's constraint solving library -
## `kiwi <https://github.com/yglukhov/kiwi>`_.
#
## :Seealso:
##   `wResizable <wResizable.html>`_
#
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

# forward declarations
proc setSize*(self: wWindow, x, y, width, height: int)
proc getRect*(self: wWindow): wRect

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

proc addConstraint*(self: wResizer, constraint: Constraint) {.validate, inline.} =
  ## Add a constraint to the solver.
  self.mSolver.addConstraint(constraint)

proc addObject*(self: wResizer, obj: wResizable) {.validate, inline.} =
  ## Add an associated resizable object to the solver.
  self.mObjects.incl obj

proc resolve*(self: wResizer) {.validate.} =
  ## Count the layout of the associated object.
  # window's current layout as default, size should stronger than position
  for child in self.mObjects:
    if child of wWindow:
      let rect = child.wWindow.getRect()
      self.mSolver.addConstraint((child.mLeft == rect.x) | WEAKEST)
      self.mSolver.addConstraint((child.mTop == rect.y) | WEAKEST)
      self.mSolver.addConstraint((child.mRight - child.mLeft == rect.width) | WEAKER)
      self.mSolver.addConstraint((child.mBottom - child.mTop == rect.height) | WEAKER)

  self.mSolver.updateVariables()

proc rearrange*(self: wResizer) {.validate.} =
  ## Rearrange the layout of the associated window.
  for obj in self.mObjects:
    if obj of wWindow:
      let x = round(obj.mLeft.value).int
      let y = round(obj.mTop.value).int
      let width = round(obj.mRight.value - obj.mLeft.value).int
      let height = round(obj.mBottom.value - obj.mTop.value).int
      obj.wWindow.setSize(x, y, width, height)

iterator items*(self: wResizer): wResizable {.validate.} =
  ## Iterates over each associated object.
  for obj in self.mObjects:
    yield obj

proc final*(self: wResizer) =
  ## Default finalizer for wResizer.
  discard

proc init*(self: wResizer) =
  self.mSolver = newSolver()
  self.mObjects = initSet[wResizable]()

proc Resizer*(): wResizer {.inline.} =
  ## Constructor.
  new(result, final)
  result.init()
