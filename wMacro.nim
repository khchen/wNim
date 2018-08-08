
proc wnimRename(x: NimNode, old, new: string): NimNode =
  result = x

  if x.kind == nnkIdent and $x == old:
    result = newIdentNode(new)

  else:
    for i in 0..<x.len:
      let node = wnimRename(x[i], old, new)
      x.del(i)
      x.insert(i, node)

proc wnimAdd(list: var NimNode, x: NimNode, parent: string, grandfather: string, count: var int) =
  if (x.kind == nnkCall and x.len == 2 and x[0].kind == nnkIdent and x[1].kind == nnkStmtList) or (x.kind == nnkIdent):
    let class = (if x.kind == nnkIdent: $x else: $x[0])
    var name = "anonymous_" & class.toLowerAscii() & $count
    var param = (if parent == nil: "" else: "parent = " & parent)
    count.inc

    if x.kind == nnkCall:
      for node in x[1]:
        if node.kind == nnkAsgn and node[0].kind == nnkIdent:
          if node[1].kind == nnkIdent and $node[0] == "name":
            name = $node[1]
          else:
            if param.len > 0: param &= ", "
            param &= node.repr

    list.add(parseExpr("let $1 = $2($3)" % [name, class, param]))

    if x.kind == nnkCall:
      for node in x[1]:
        if not (node.kind == nnkAsgn and node[0].kind == nnkIdent):
          list.wnimAdd(node, name, parent, count)

  else:
    list.add(x.wnimRename("this", parent).wnimRename("super", grandfather))

macro wnim*(x: untyped): untyped =
  result = newStmtList()
  var count = 1
  for node in x:
    result.wnimAdd(node, nil, nil, count)

  # echo result.repr

macro DefineIncrement(start: int, x: untyped): untyped =
  var index = int start.intVal
  result = newStmtList()
  for name in x:
    result.add newConstStmt(postfix(name, "*"), newLit(index))
    index.inc

macro property(x: untyped): untyped =
  when defined(wnimdoc):
    result = x
  else:
    var procname = $x.name
    var kind = procname.substr(0, 2)

    if kind == "get" or (kind == "set" and x.params.len == 3):
      var name = substr(procname, 3)
      name[0] = name[0].toLowerAscii

      var params = newSeq[NimNode]()
      var args = newSeq[NimNode]()

      for i, p in x.params:
        params.add p
        if i >= 1: # 0 is return type
          args.add p[0]

      var namenode: NimNode
      if kind == "get":
        namenode = newIdentNode(name)
      else:
        namenode = newNimNode(nnkAccQuoted)
        namenode.add newIdentNode(name)
        namenode.add newIdentNode("=")

      var newproc = newProc(
        name=postfix(namenode, "*"),
        params=params,
        body=newStmtList(newCall(x.name, args)),
        procType=x.kind)

      newProc.pragma = x.pragma
      # not harmful if always add another inline
      newProc.addPragma(newIdentNode("inline"))

      result = newStmtList()
      result.add x
      result.add newProc

    else:
      result = x

macro validate(x: untyped): untyped =
  when defined(wnimdoc):
    result = x
  else:
    var call = newCall(newIdentNode("wValidate"), newIdentNode("self"))
    if x.body[0].kind == nnkCommentStmt:
      x.body.insert(1, call)
    else:
      x.body.insert(0, call)

    result = x
