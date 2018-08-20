## wView is the superclass of wWindow to handle layout DSL.

proc getSize*(self: wView): wSize {.validate, property.} =
  result.width = round(mRight.value - mLeft.value).int
  result.height = round(mBottom.value - mTop.value).int

proc getRect*(self: wView): wRect {.validate, property.} =
  result.x = round(mLeft.value).int
  result.y = round(mTop.value).int
  result.width = round(mRight.value - mLeft.value).int
  result.height = round(mBottom.value - mTop.value).int

proc init(self: wView) =
  mLeft = newVariable()
  mRight = newVariable()
  mTop = newVariable()
  mBottom = newVariable()

proc View*(): wView =
  new(result)
  result.init()

proc left*(self: wView): Variable {.inline.} = mLeft
proc right*(self: wView): Variable {.inline.} = mRight
proc top*(self: wView): Variable {.inline.} = mTop
proc bottom*(self: wView): Variable {.inline.} = mBottom

proc layoutDsl(parent, x: NimNode): NimNode =
  var code = "{.push hint[XDeclaredButNotUsed]: off.}\n"
  code &= "when not declaredInScope(wView_Solver):\n"
  code &= "  var wView_Solver = ViewSolver()\n"
  code &= "else:\n"
  code &= "  wView_Solver = ViewSolver()\n"
  code &= "block:\n"
  code &= "  let solver = wView_Solver\n"
  code &= "  var self: wView\n"
  code &= "  template width(name: wView): untyped = (name.right - name.left)\n"
  code &= "  template height(name: wView): untyped = (name.bottom - name.top)\n"
  code &= "  template up(name: wView): untyped = name.top\n"
  code &= "  template down(name: wView): untyped = name.bottom\n"
  code &= "  template centerX(name: wView): untyped = ((name.right - name.left) / 2 + name.left)\n"
  code &= "  template centerY(name: wView): untyped = ((name.bottom - name.top) / 2 + name.top)\n"
  code &= "  template defaultWidth(name: wView): untyped = name.wWindow.defaultSize.width.float\n"
  code &= "  template defaultHeight(name: wView): untyped = name.wWindow.defaultSize.height.float\n"

  # for align between siblings only, for example: StaticBox
  code &= "  template innerLeft(name: wView): untyped = name.left + name.wWindow.clientMargin(wLeft).float\n"
  code &= "  template innerTop(name: wView): untyped = name.top + name.wWindow.clientMargin(wTop).float\n"
  code &= "  template innerRight(name: wView): untyped = name.right - name.wWindow.clientMargin(wRight).float\n"
  code &= "  template innerBottom(name: wView): untyped = name.bottom - name.wWindow.clientMargin(wBottom).float\n"
  code &= "  template innerUp(name: wView): untyped = name.top + name.wWindow.clientMargin(wTop).float\n"
  code &= "  template innerDown(name: wView): untyped = name.bottom - name.wWindow.clientMargin(wBottom).float\n"
  code &= "  template innerWidth(name: wView): untyped = (name.innerRight - name.innerLeft)\n"
  code &= "  template innerHeight(name: wView): untyped = (name.innerBottom - name.innerTop)\n"

  const attributes = ["width", "height", "left", "top", "right", "bottom", "up", "down", "centerX", "centerY", "defaultWidth", "defaultHeight", "innerLeft", "innerTop", "innerRight", "innerBottom", "innerUp", "innerDown", "innerWidth", "innerHeight"]
  const strengthes = ["REQUIRED", "STRONG", "MEDIUM", "WEAK", "WEAKER", "WEAKEST"]

  proc addSelfDot(x: NimNode): NimNode =
    if x.kind == nnkIdent and $x in attributes:
      result = newDotExpr(newIdentNode("self"), x)
    else:
      result = x

    for i in 0..<x.len:
      if x[i].kind != nnkDotExpr:
        let new = addSelfDot(x[i])
        x.del(i)
        x.insert(i, new)

  proc int2float(x: NimNode): NimNode =
    if x.kind == nnkIntLit:
      result = newFloatLitNode(intVal(x).float)
    else:
      result = x

    for i in 0..<x.len:
      let new = int2float(x[i])
      x.del(i)
      x.insert(i, new)

  proc addConstraint(code: var string, x: NimNode, strength: string = nil) =
    if x.kind == nnkInfix:
      if strength.len == 0:
        code &= "  solver.addConstraint(" & x.int2float.repr & ")\n"
      else:
        code &= "  solver.addConstraint(($1) | $2)\n" % [x.int2float.repr, strength]

    elif x.kind == nnkBracket:
      for item in x:
        code.addConstraint(item, strength)

    elif x.kind == nnkCall and x.len == 2 and x[1].kind == nnkStmtList:
      if $x[0] in strengthes:
        for item in x[1]:
          code.addConstraint(item, $x[0])
      else:
        code &= "  self = $1\n" % [x[0].repr]
        code &= "  solver.addView($1)\n" % [x[0].repr]
        for item in x[1]:
          code.addConstraint(item, strength)

    elif x.kind == nnkStmtList:
      for item in x:
        code.addConstraint(item, strength)

  code.addConstraint(x.addSelfDot)

  if parent.kind != nnkNilLit:
    code &= "  let size = $1.getClientSize()\n" % [$parent]
    code &= "  solver.addConstraint($1.left == 0.0)\n" % [$parent]
    code &= "  solver.addConstraint($1.top == 0.0)\n" % [$parent]
    code &= "  solver.addConstraint($1.width == size.width.float)\n" % [$parent]
    code &= "  solver.addConstraint($1.height == size.height.float)\n" % [$parent]

  code &= "{.pop.}\n"
  parseStmt(code)

macro plan*(parent: wView, x: untyped): untyped =
  result = parent.layoutDsl(x)
  result.add newIdentNode("wView_Solver")

macro layout*(parent: wView, x: untyped): untyped =
  result = parent.layoutDsl(x)
  result.add newCall(newDotExpr(newIdentNode("wView_Solver"), newIdentNode("resolve")))
  result.add newCall(newDotExpr(newIdentNode("wView_Solver"), newIdentNode("rearrange")))

macro debug*(parent: wView, x: untyped): untyped =
  result = parent.layoutDsl(x)
  echo result.repr

