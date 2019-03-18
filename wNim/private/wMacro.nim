#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## Some macros used in wNim.

macro DefineIncrement(start: int, x: untyped): untyped =
  var index = int start.intVal
  result = newStmtList()
  for name in x:
    result.add newConstStmt(postfix(name, "*"), newLit(index))
    index.inc

macro property*(x: untyped): untyped =
  ## Add property macro to proc as pragma so that getters/setters can access
  ## as nim's style.
  when defined(Nimdoc):
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

macro validate*(x: untyped): untyped =
  ## Add validate macro to a proc as pragma to ensure *self* is not nil.
  when defined(Nimdoc):
    result = x
  else:
    var call = newCall(newIdentNode("wValidate"), newIdentNode("self"))
    if x.body[0].kind == nnkCommentStmt:
      x.body.insert(1, call)
    else:
      x.body.insert(0, call)

    result = x

# add wValidate(self, frame, text, etc) at beginning of static object proc
# method don't need self check becasue it's checked by dispatcher
# not nil don't work will on 0.18.0 and 0.18.1

when not defined(release):
  import typetraits

  proc wValidateToPointer*(x: ref): (pointer, string) =
    (cast[pointer](unsafeaddr x[]), x.type.name)
  proc wValidateToPointer*(x: pointer): (pointer, string) =
    (x, x.type.name)
  proc wValidateToPointer*(x: string): (pointer, string) =
    # don't check string isnil anymore (for v0.19)
    (cast[pointer](1), x.type.name)
  proc wValidateToPointer*[T](x: seq[T]): (pointer, string) =
    # don't check seq isnil anymore (for v0.19)
    (cast[pointer](1), x.type.name)

  template wValidate*(vargs: varargs[(pointer, string), wValidateToPointer]): untyped =
    for tup in vargs:
      if tup[0] == nil:
        raise newException(NilAccessError, " not allow nil " & tup[1])

else:
  proc wValidateToPointer*[T](x: T): pointer = nil
  template wValidate*(vargs: varargs[pointer, wValidateToPointer]): untyped = discard
