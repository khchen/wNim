#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 Copyright (c) Chen Kai-Hung, Ward
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
##   REQUIRED                        REQUIRED
##   STRONGEST                       20000000.0
##   STRONGER                        10000000.0
##   STRONG9                         9000000.0
##   STRONG8                         8000000.0
##   STRONG7                         7000000.0
##   STRONG6                         6000000.0
##   STRONG5                         1000000.0
##   STRONG4                         400000.0
##   STRONG3                         300000.0
##   STRONG2                         200000.0
##   STRONG1                         100000.0
##   MEDIUM9                         9000.0
##   MEDIUM8                         7000.0
##   MEDIUM7                         5000.0
##   MEDIUM6                         3000.0
##   MEDIUM5                         1000.0
##   MEDIUM4                         400.0
##   MEDIUM3                         300.0
##   MEDIUM2                         200.0
##   MEDIUM1                         100.0
##   WEAK9                           90.0
##   WEAK8                           80.0
##   WEAK7                           70.0
##   WEAK6                           60.0
##   WEAK5                           1.0
##   WEAK4                           0.4
##   WEAK3                           0.3
##   WEAK2                           0.2
##   WEAK1                           0.1
##   WEAKER                          0.05
##   WEAKEST                         0.01
##   STRONG                          STRONG5
##   MEDIUM                          MEDIUM5
##   WEAK                            WEAK5
##   ==============================  =============================================================

include pragma
import sets, math
import wBase, wWindow, kiwi/kiwi

export kiwi

const
  # REQUIRED* = createStrength(1000.0, 1000.0, 1000.0)
  # STRONG* = createStrength(1.0, 0.0, 0.0)
  # MEDIUM* = createStrength(0.0, 1.0, 0.0)
  # WEAK* = createStrength(0.0, 0.0, 1.0)
  STRONGEST* = 20000000.0
  STRONGER* = 10000000.0
  STRONG9* = 9000000.0
  STRONG8* = 8000000.0
  STRONG7* = 7000000.0
  STRONG6* = 6000000.0
  STRONG5* = 1000000.0
  STRONG4* = 400000.0
  STRONG3* = 300000.0
  STRONG2* = 200000.0
  STRONG1* = 100000.0
  MEDIUM9* = 9000.0
  MEDIUM8* = 7000.0
  MEDIUM7* = 5000.0
  MEDIUM6* = 3000.0
  MEDIUM5* = 1000.0
  MEDIUM4* = 400.0
  MEDIUM3* = 300.0
  MEDIUM2* = 200.0
  MEDIUM1* = 100.0
  WEAK9* = 90.0
  WEAK8* = 80.0
  WEAK7* = 70.0
  WEAK6* = 60.0
  WEAK5* = 1.0
  WEAK4* = 0.4
  WEAK3* = 0.3
  WEAK2* = 0.2
  WEAK1* = 0.1
  WEAKER* = 0.05
  WEAKEST* = 0.01

static:
  assert STRONG == STRONG5
  assert MEDIUM == MEDIUM5
  assert WEAK == WEAK5

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

  if obj of wBase.wWindow:
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
  if panel of wBase.wWindow:
    let size = panel.wWindow.getClientSize()
    self.mSolver.suggestValue(panel.mLeft, 0)
    self.mSolver.suggestValue(panel.mTop, 0)
    self.mSolver.suggestValue(panel.mWidth, float size.width)
    self.mSolver.suggestValue(panel.mHeight, float size.height)

  # Window's current layout as default, size should stronger than position
  for child in self.mObjects:
    if child of wBase.wWindow:
      let rect = child.wWindow.getRect()
      self.mSolver.suggestValue(child.mLeft, float rect.x)
      self.mSolver.suggestValue(child.mTop, float rect.y)
      self.mSolver.suggestValue(child.mWidth, float rect.width)
      self.mSolver.suggestValue(child.mHeight, float rect.height)

  self.mSolver.updateVariables()

proc rearrange*(self: wResizer) {.validate.} =
  ## Rearrange the layout of the associated window.
  for obj in self.mObjects:
    if obj of wBase.wWindow:
      let x = int round(obj.mLeft.value)
      let y = int round(obj.mTop.value)
      let width = int round(obj.mWidth.value)
      let height = int round(obj.mHeight.value)
      obj.wWindow.setSize(x, y, width, height)

iterator items*(self: wResizer): wResizable {.validate.} =
  ## Iterates over each associated object.
  for obj in self.mObjects:
    yield obj

wClass(wResizer):

  proc init*(self: wResizer, parent: wResizable) {.inline.} =
    ## Initializer.
    wValidate(parent)
    self.mParent = parent
    self.mSolver = newSolver()
    self.mObjects = initHashSet[wTypes.wResizable]()

    self.mSolver.addEditVariable(parent.mLeft, REQUIRED-1)
    self.mSolver.addEditVariable(parent.mTop, REQUIRED-1)
    self.mSolver.addEditVariable(parent.mWidth, REQUIRED-1)
    self.mSolver.addEditVariable(parent.mHeight, REQUIRED-1)
