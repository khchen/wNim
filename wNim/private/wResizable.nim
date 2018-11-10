#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
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
## Following identifiers can be used in the layout DSL:
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
#
## :Subclass:
##   `wWindow <wWindow.html>`_
#
## :Seealso:
##   `wResizer <wResizer.html>`_

proc getSize*(self: wResizable): wSize {.validate, property.} =
  ## Returns the current size.
  result.width = int round(mRight.value - mLeft.value)
  result.height = int round(mBottom.value - mTop.value)

proc getRect*(self: wResizable): wRect {.validate, property.} =
  ## Returns the current rect.
  result.x = int round(mLeft.value)
  result.y = int round(mTop.value)
  result.width = int round(mRight.value - mLeft.value)
  result.height = int round(mBottom.value - mTop.value)

proc final*(self: wResizable) =
  ## Default finalizer for wResizable.
  discard

proc init(self: wResizable) =
  mLeft = newVariable()
  mRight = newVariable()
  mTop = newVariable()
  mBottom = newVariable()

proc Resizable*(): wResizable {.inline.} =
  ## Constructor.
  new(result, final)
  result.init()

proc left*(self: wResizable): Variable {.inline.} = mLeft
proc right*(self: wResizable): Variable {.inline.} = mRight
proc top*(self: wResizable): Variable {.inline.} = mTop
proc bottom*(self: wResizable): Variable {.inline.} = mBottom

when not defined(wnimdoc): # this code crash nim doc generator, I don't know why
  proc dslParser(parent: NimNode, x: NimNode): NimNode =
    var code = "{.push hint[XDeclaredButNotUsed]: off.}\n"
    code &= "when not declaredInScope(wNimResizer):\n"
    code &= "  var wNimResizer = Resizer()\n"
    code &= "else:\n"
    code &= "  wNimResizer = Resizer()\n"
    code &= "block:\n"
    code &= "  let resizer = wNimResizer\n"
    code &= "  var self: wResizable\n"
    code &= "  template width(name: wResizable): untyped = (name.right - name.left)\n"
    code &= "  template height(name: wResizable): untyped = (name.bottom - name.top)\n"
    code &= "  template up(name: wResizable): untyped = name.top\n"
    code &= "  template down(name: wResizable): untyped = name.bottom\n"
    code &= "  template centerX(name: wResizable): untyped = ((name.right - name.left) / 2 + name.left)\n"
    code &= "  template centerY(name: wResizable): untyped = ((name.bottom - name.top) / 2 + name.top)\n"
    code &= "  template defaultWidth(name: wResizable): untyped = name.wWindow.defaultSize.width\n"
    code &= "  template defaultHeight(name: wResizable): untyped = name.wWindow.defaultSize.height\n"
    code &= "  template bestWidth(name: wResizable): untyped = name.wWindow.bestSize.width\n"
    code &= "  template bestHeight(name: wResizable): untyped = name.wWindow.bestSize.height\n"

    # for align between siblings only, for example: StaticBox
    code &= "  template innerLeft(name: wResizable): untyped = name.left + name.wWindow.clientMargin(wLeft)\n"
    code &= "  template innerTop(name: wResizable): untyped = name.top + name.wWindow.clientMargin(wTop)\n"
    code &= "  template innerRight(name: wResizable): untyped = name.right - name.wWindow.clientMargin(wRight)\n"
    code &= "  template innerBottom(name: wResizable): untyped = name.bottom - name.wWindow.clientMargin(wBottom)\n"
    code &= "  template innerUp(name: wResizable): untyped = name.top + name.wWindow.clientMargin(wTop)\n"
    code &= "  template innerDown(name: wResizable): untyped = name.bottom - name.wWindow.clientMargin(wBottom)\n"
    code &= "  template innerWidth(name: wResizable): untyped = (name.innerRight - name.innerLeft)\n"
    code &= "  template innerHeight(name: wResizable): untyped = (name.innerBottom - name.innerTop)\n"

    const attributes = ["width", "height", "left", "top", "right", "bottom", "up",
      "down", "centerX", "centerY", "defaultWidth", "defaultHeight", "bestWidth",
      "bestHeight", "innerLeft", "innerTop", "innerRight", "innerBottom",
      "innerUp", "innerDown", "innerWidth", "innerHeight"]

    const strengthes = ["REQUIRED", "STRONG", "MEDIUM", "WEAK", "WEAKER", "WEAKEST"]

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
        ## enconter infix operator  a == b, a < b, etc.
        if strength.len == 0:
          code &= "  resizer.addConstraint(" & x.repr & ")\n"
        else:
          code &= "  resizer.addConstraint(($1) | $2)\n" % [x.repr, strength]

      elif x.kind == nnkBracket:
        for item in x:
          code.addConstraint(item, strength)

      if x.kind == nnkAsgn:
        ## enconter a = b, we should parse as a == b
        code.addConstraint(infix(x[0], "==", x[1]), strength)

      elif x.kind == nnkCall and x.len == 2 and x[1].kind == nnkStmtList:
        # enconter name: stmtlist
        # if name is not strength, it should be a resizable object.
        if $x[0] in strengthes:
          for item in x[1]:
            code.addConstraint(item, $x[0])
        else:
          code &= "  self = $1\n" % [x[0].repr]
          code &= "  resizer.addObject($1)\n" % [x[0].repr]
          for item in x[1]:
            code.addConstraint(item, strength)

      elif x.kind == nnkStmtList:
        for item in x:
          code.addConstraint(item, strength)

    code.addConstraint(x.addSelfDot)

    if parent.kind != nnkNilLit:
      code &= "  let size = $1.getClientSize()\n" % [$parent]
      code &= "  resizer.addConstraint($1.left == 0)\n" % [$parent]
      code &= "  resizer.addConstraint($1.top == 0)\n" % [$parent]
      code &= "  resizer.addConstraint($1.width == size.width)\n" % [$parent]
      code &= "  resizer.addConstraint($1.height == size.height)\n" % [$parent]

    code &= "{.pop.}\n"
    parseStmt(code)

macro plan*(parent: wResizable, x: untyped): untyped =
  ## Parses the layout DSL and return the wResizer object.
  ## Use wResizer.resolve() and wResizer.rearrange() to do the change.
  result = parent.dslParser(x)
  result.add newIdentNode("wNimResizer")

macro layout*(parent: wResizable, x: untyped): untyped =
  ## Parses the layout DSL and rearrange the object.
  result = parent.dslParser(x)
  result.add newCall(newDotExpr(newIdentNode("wNimResizer"), newIdentNode("resolve")))
  result.add newCall(newDotExpr(newIdentNode("wNimResizer"), newIdentNode("rearrange")))

macro debug*(parent: wResizable, x: untyped): untyped =
  ## Output the parsing result for debugging.
  result = parent.dslParser(x)
  echo result.repr
