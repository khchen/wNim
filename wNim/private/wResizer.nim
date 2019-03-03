#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
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
method getClientSize*(self: wResizable): wSize {.base.}

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

  if obj of wWindow:
    # Window's current layout as default, size should stronger than position
    if not self.mSolver.hasEditVariable(obj.mLeft):
      self.mSolver.addEditVariable(obj.mLeft, WEAKEST)

    if not self.mSolver.hasEditVariable(obj.mTop):
      self.mSolver.addEditVariable(obj.mTop, WEAKEST)

    if not self.mSolver.hasEditVariable(obj.mWidth):
      self.mSolver.addEditVariable(obj.mWidth, WEAKER)

    if not self.mSolver.hasEditVariable(obj.mHeight):
      self.mSolver.addEditVariable(obj.mHeight, WEAKER)

proc resolve*(self: wResizer) {.validate.} =
  ## Count the layout of the associated object.
  let panel = self.mParent
  if panel of wWindow:
    let size = panel.wWindow.getClientSize()
    self.mSolver.suggestValue(panel.mLeft, 0)
    self.mSolver.suggestValue(panel.mTop, 0)
    self.mSolver.suggestValue(panel.mWidth, float size.width)
    self.mSolver.suggestValue(panel.mHeight, float size.height)

  # Window's current layout as default, size should stronger than position
  for child in self.mObjects:
    if child of wWindow:
      let rect = child.wWindow.getRect()
      self.mSolver.suggestValue(child.mLeft, float rect.x)
      self.mSolver.suggestValue(child.mTop, float rect.y)
      self.mSolver.suggestValue(child.mWidth, float rect.width)
      self.mSolver.suggestValue(child.mHeight, float rect.height)

  self.mSolver.updateVariables()

proc rearrange*(self: wResizer) {.validate.} =
  ## Rearrange the layout of the associated window.
  for obj in self.mObjects:
    if obj of wWindow:
      let x = int round(obj.mLeft.value)
      let y = int round(obj.mTop.value)
      let width = int round(obj.mWidth.value)
      let height = int round(obj.mHeight.value)
      obj.wWindow.setSize(x, y, width, height)

iterator items*(self: wResizer): wResizable {.validate.} =
  ## Iterates over each associated object.
  for obj in self.mObjects:
    yield obj

proc final*(self: wResizer) =
  ## Default finalizer for wResizer.
  discard

proc init*(self: wResizer, parent: wResizable) {.inline.} =
  ## Initializer.
  wValidate(parent)
  self.mParent = parent
  self.mSolver = newSolver()
  # initSet is deprecated since v0.20
  when declared(initHashSet):
    self.mObjects = initHashSet[wResizable]()
  else:
    self.mObjects = initSet[wResizable]()

  self.mSolver.addEditVariable(parent.mLeft, REQUIRED-1)
  self.mSolver.addEditVariable(parent.mTop, REQUIRED-1)
  self.mSolver.addEditVariable(parent.mWidth, REQUIRED-1)
  self.mSolver.addEditVariable(parent.mHeight, REQUIRED-1)

proc Resizer*(parent: wResizable): wResizer {.inline.} =
  ## Constructor.
  wValidate(parent)
  new(result, final)
  result.init(parent)
