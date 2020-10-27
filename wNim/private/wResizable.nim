#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## *wResizable* is the superclass of *wWindow* to handle layout DSL.
## It is based on yglukhov's constraint solving library -
## `kiwi <https://github.com/yglukhov/kiwi>`_.
##
## wNim's layout DSL looking like this:
##
## .. code-block:: Nim
##   panel.layout:
##     button1:
##       top = panel.top
##       left = panel.left
##     button2:
##       centerX = panel.centerX
##       centerY = panel.centerY
##       height = panel.height / 2
##       width = panel.width / 2
##
## Following identifiers can be used in the layout DSL as attributes:
## ================================  =============================================================
## Identifiers                       Description
## ================================  =============================================================
## left                              Left margin.
## right                             Right margin.
## top                               Top margin.
## bottom                            Bottom margin.
## width                             Width of object.
## height                            Height of object.
## up                                Alias for top.
## down                              Alias for bottom.
## centerX                           Center of X-axis.
## centerY                           Center of Y-axis.
## defaultWidth                      Default width of object.
## defaultHeight                     Default height of object.
## bestWidth                         Best width of object.
## bestHeight                        Best height of object.
## innerLeft                         Left margin of sibling's client area.
## innerTop                          Top margin of sibling's client area.
## innerRight                        Right margin of sibling's client area.
## innerBottom                       Bottom margin of sibling's client area.
## innerUp                           Alias for innerTop.
## innerDown                         Alias for innerBottom.
## innerWidth                        Width of sibling's client area.
## innerHeight                       Height of sibling's client area.
## ================================  =============================================================
##
## wNim also support Visual Format Language. For example:
##
## .. code-block:: Nim
##   panel.autolayout """
##     V:|-{col1:[child1(child2)]-[child2]}-|
##     V:|-{col2:[child3(child4,child5)]-[child4]-[child5]}-|
##     H:|-[col1(col2)]-[col2]-|
##   """
##
## See `autolayout <autolayout.html>`_ module for details.
#
## :Subclass:
##   `wWindow <wWindow.html>`_
#
## :Seealso:
##   `wResizer <wResizer.html>`_
##   `autolayout <autolayout.html>`_

{.experimental, deadCodeElim: on.}
when defined(gcDestructors): {.push sinkInference: off.}

import macros, math, strutils
import wBase, autolayout

proc getLayoutSize*(self: wResizable): wSize {.validate, property.} =
  ## Returns the current layout size.
  result.width = int round(self.mWidth.value)
  result.height = int round(self.mHeight.value)

proc getLayoutRect*(self: wResizable): wRect {.validate, property.} =
  ## Returns the current layout rect.
  result.x = int round(self.mLeft.value)
  result.y = int round(self.mTop.value)
  result.width = int round(self.mWidth.value)
  result.height = int round(self.mHeight.value)

proc setLayoutSize*(self: wResizable, size: wSize) {.validate, property.} =
  ## Sets the layout size.
  self.mWidth.value = float size.width
  self.mHeight.value = float size.height

proc setLayoutRect*(self: wResizable, rect: wRect) {.validate, property.} =
  ## Sets the layout rect.
  self.mLeft.value = float rect.x
  self.mTop.value = float rect.y
  self.mWidth.value = float rect.width
  self.mHeight.value = float rect.height

# Following base method used in wResizer.
# These methods should be not public, only the wWindow.xxx() is public.

method getClientMargin(self: wResizable, direction: int): int {.base, property, uknlock.} =
  result = 0

method getClientSize(self: wResizable): wSize {.base, property, uknlock.} =
  result = self.getLayoutSize()

method getDefaultSize(self: wResizable): wSize {.base, property, uknlock.} =
  result = self.getLayoutSize()

method getBestSize(self: wResizable): wSize {.base, property, uknlock.} =
  result = self.getLayoutSize()

wClass(wResizable):

  proc init*(self: wResizable) =
    ## Initializer.
    self.mLeft = newVariable()
    self.mTop = newVariable()
    self.mWidth = newVariable()
    self.mHeight = newVariable()

template attributeTempaltes(): untyped =
  template left(name: wResizable): untyped {.used.} = name.mLeft
  template top(name: wResizable): untyped {.used.} = name.mTop
  template right(name: wResizable): untyped {.used.} = name.mLeft + name.mWidth
  template bottom(name: wResizable): untyped {.used.} = name.mTop + name.mHeight
  template width(name: wResizable): untyped {.used.} = name.mWidth
  template height(name: wResizable): untyped {.used.} = name.mHeight
  template up(name: wResizable): untyped {.used.} = name.top
  template down(name: wResizable): untyped {.used.} = name.bottom
  template centerX(name: wResizable): untyped {.used.} = name.mWidth / 2 + name.mLeft
  template centerY(name: wResizable): untyped {.used.} = name.mHeight / 2 + name.mTop
  template defaultWidth(name: wResizable): untyped {.used.} = name.defaultSize.width
  template defaultHeight(name: wResizable): untyped {.used.} = name.defaultSize.height
  template bestWidth(name: wResizable): untyped {.used.} = name.bestSize.width
  template bestHeight(name: wResizable): untyped {.used.} = name.bestSize.height
  template innerLeft(name: wResizable): untyped {.used.} = name.left + name.clientMargin(wLeft)
  template innerTop(name: wResizable): untyped {.used.} = name.top + name.clientMargin(wTop)
  template innerRight(name: wResizable): untyped {.used.} = name.right - name.clientMargin(wRight)
  template innerBottom(name: wResizable): untyped {.used.} = name.bottom - name.clientMargin(wBottom)
  template innerUp(name: wResizable): untyped {.used.} = name.top + name.clientMargin(wTop)
  template innerDown(name: wResizable): untyped {.used.} = name.bottom - name.clientMargin(wBottom)
  template innerWidth(name: wResizable): untyped {.used.} = name.innerRight - name.innerLeft
  template innerHeight(name: wResizable): untyped {.used.} = name.innerBottom - name.innerTop

proc layoutParser(x: NimNode): string =
  const attributes = ["width", "height", "left", "top", "right", "bottom", "up",
    "down", "centerX", "centerY", "defaultWidth", "defaultHeight", "bestWidth",
    "bestHeight", "innerLeft", "innerTop", "innerRight", "innerBottom",
    "innerUp", "innerDown", "innerWidth", "innerHeight"]

  const strengthes = ["REQUIRED", "STRONG", "MEDIUM", "WEAK", "WEAKER"]

  proc addSelfDot(x: NimNode): NimNode =
    # Find all ident recursively, add "self." if the ident is a attribute
    if x.kind == nnkIdent and $x in attributes:
      result = newDotExpr(newIdentNode("self"), x)
    else:
      result = x

    for i in 0..<x.len:
      if x[i].kind != nnkDotExpr:
        let new = addSelfDot(x[i])
        x.del(i)
        x.insert(i, new)

  proc addConstraint(code: var string, x: NimNode, strength = "") =
    if x.kind == nnkInfix:
      # enconter infix operator  a == b, a < b, etc.
      if strength.len == 0:
        code.add "resizer.addConstraint(" & x.repr & ")\n"
      else:
        code.add "resizer.addConstraint(($1) | $2)\n" % [x.repr, strength]

    elif x.kind == nnkBracket:
      for item in x:
        code.addConstraint(item, strength)

    if x.kind == nnkAsgn:
      # enconter a = b, we should parse as a == b
      code.addConstraint(infix(x[0], "==", x[1]), strength)

    elif x.kind == nnkCall and x.len == 2 and x[1].kind == nnkStmtList:
      # enconter name: stmtlist or number: stmtlist
      # if name is not strength, it should be a resizable object.
      # if there is a number, consider it is the strength
      if x[0].kind in nnkCharLit..nnkUInt64Lit:
        for item in x[1]:
          code.addConstraint(item, $x[0].intVal)

      elif x[0].kind in nnkFloatLit..nnkFloat64Lit:
        for item in x[1]:
          code.addConstraint(item, $x[0].floatVal)

      elif $x[0] in strengthes:
        for item in x[1]:
          code.addConstraint(item, $x[0])

      else:
        code.add "self = $1\n" % [x[0].repr]
        code.add "resizer.addObject($1)\n" % [x[0].repr]
        for item in x[1]:
          code.addConstraint(item, strength)

    elif x.kind == nnkStmtList:
      for item in x:
        code.addConstraint(item, strength)

  var code = ""
  code.addConstraint(x.addSelfDot)
  return code

macro layoutRealize(x: untyped): untyped =
  parseStmt(layoutParser(x))

template layout*(parent: wResizable, x: untyped) =
  ## Parses the layout DSL and rearrange the objects. This function only
  ## evaluate the DSL and creates the constraints once.

  # Note: resizer and self need {.inject.} so that layoutRealize works.
  # Moreover, they must be in sub-scope for identifier hygiene.
  # Also add workaround for https://github.com/nim-lang/Nim/issues/15005.

  var globalResizer {.global.}: wResizer
  if globalResizer == nil or globalResizer.mParent != parent:
    var resizer {.inject.} = Resizer(parent)
    var self {.inject.}: wResizable
    attributeTempaltes()

    layoutRealize(x)
    globalResizer = resizer

  globalResizer.resolve()
  globalResizer.rearrange()

template relayout*(parent: wResizable, x: untyped) =
  ## Parses the layout DSL and rearrange the objects. This function evaluate
  ## the DSL and creates the constraints every time.
  ## If the value in the constraints is not constant (For example, if there is
  ## object.bestWidth in DSL and the label of the object will change every
  ## time), use this function instead of *layout*.
  block:
    var resizer {.inject.} = Resizer(parent)
    var self {.inject.}: wResizable
    attributeTempaltes()

    layoutRealize(x)
    resizer.resolve()
    resizer.rearrange()

template plan*(parent: wResizable, x: untyped): untyped =
  ## Similar to *layout*, but return the wResizer object.
  ## Calls wResizer.resolve() and then wResizer.rearrange() to change the layout
  ## in reality later. This function provides a chance to modify the resolved
  ## values.

  # There is NO workaround for https://github.com/nim-lang/Nim/issues/15005.
  # The only way to avoid the resizer being destroyed after scope is using
  # {.global.} in user's code, not in this template.

  var globalResizer {.global.}: wResizer
  if globalResizer == nil or globalResizer.mParent != parent:
    var resizer {.inject.} = Resizer(parent)
    var self {.inject.}: wResizable
    attributeTempaltes()

    layoutRealize(x)
    globalResizer = resizer

  globalResizer

template replan*(parent: wResizable, x: untyped): untyped =
  ## Similar to *relayout*, but return the wResizer object.
  ## Calls wResizer.resolve() and then wResizer.rearrange() to change the layout
  ## in reality later. This function provides a chance to modify the resolved
  ## values.
  block:
    var resizer {.inject.} = Resizer(parent)
    var self{.inject.}: wResizable
    attributeTempaltes()

    layoutRealize(x)
    resizer

macro autolayout*(parent: wResizable, input: static[string]): untyped =
  ## Parses the layout VFL (Visual Format Language), and then use *layout*
  ## function to deal with the result.
  var parser = initVflParser(parent.repr)
  parser.parse(input)
  parseStmt(parser.toString(templ="layout"))

macro autorelayout*(parent: wResizable, input: static[string]): untyped =
  ## Parses the layout VFL (Visual Format Language), and then use *relayout*
  ## function to deal with the result.
  var parser = initVflParser(parent.repr)
  parser.parse(input)
  parseStmt(parser.toString(templ="relayout"))

macro autoplan*(parent: wResizable, input: static[string]): untyped =
  ## Parses the layout VFL (Visual Format Language), and then use *plan*
  ## function to deal with the result.
  var parser = initVflParser(parent.repr)
  parser.parse(input)
  parseStmt(parser.toString(templ="plan"))

macro autoreplan*(parent: wResizable, input: static[string]): untyped =
  ## Parses the layout VFL (Visual Format Language), and then use *replan*
  ## function to deal with the result.
  var parser = initVflParser(parent.repr)
  parser.parse(input)
  parseStmt(parser.toString(templ="replan"))

macro layoutDebug*(parent: wResizable, x: untyped): untyped =
  ## Parses the layout DSL and returns the constraints in string literal for
  ## debugging.
  result = newStrLitNode(layoutParser(x))

macro layoutDump*(parent: wResizable, x: untyped): untyped =
  ## Parses the layout DSL and displays the constraints at compile time for
  ## debugging.
  echo layoutParser(x)

macro autolayoutDebug*(parent: wResizable, input: static[string]): untyped =
  ## Parses the VFL (Visual Format Language) and returns the result in string
  ## literal for debugging.
  var parser = initVflParser(parent.repr)
  parser.parse(input)
  result = newStrLitNode(parser.toString(templ="layout"))

macro autolayoutDump*(parent: wResizable, input: static[string]): untyped =
  ## Parses the VFL (Visual Format Language) and displays the result at compile
  ## time for debugging.
  var parser = initVflParser(parent.repr)
  parser.parse(input)
  echo parser.toString(templ="layout")
