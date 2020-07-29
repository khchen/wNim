#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## *autolayout* is a separated module for *wNim* to parse the **Visual Format
## Language** and output the *wNim* layout DSL. This code is designed to be used
## at both compile time and runtime. For more information about VFL, see
## `AutoLayout.js <https://ijzerenhein.github.io/autolayout.js/>`_ and
## `Apple's Visual Format Language <https://tinyurl.com/y4gpqvrw>`_.
##
## Visual Format Language looking like this:
##
## .. code-block:: Nim
##   V:|-[col1:[child1(child2)]-[child2]]-|
##   V:|-[col2:[child3(child4,child5)]-[child4]-[child5]]-|
##   H:|-[col1(col2)]-[col2]-|
##
## Thanks to nim's powerful metaprogramming features. Now *wNim* can use Visual
## Format Language to design the GUI layout. And most the hard works are done
## at compile time.
##
## The parser supports most Visual Format Language features including:
## * Proportional size (H:\|-[view1(=50%)])
## * Operators (H:\|-[view1(=view2/2-10)]-[view2]-\|)
## * Attributes (V:\|[view2(view1.width)])
## * Equal size spacers/centering(H:\|~[center(100)]~\|)
## * View stacks (V:\|[column:[header(50)][content][footer(50)]]\|)
## * View ranges (spread operator) (H:[view1..8(10)]\|)
## * Multiple views (H:\|[text1,text2,text3]\|)
## * Multiple orientations (HV:\|[background]\|)
## * Disconnections (right/bottom alignment) (H:\|[view1(200)]->[view2(100)]\|)
## * Negative values (overlapping views) (H:\|[view1]-(-10)-[view2]\|)
## * Priority ([button(100@STRONG)] or [button(100@20)])
## * Explicit constraint syntax (C:view1.centerX = view2.centerX)
## * Comments (H:[view1(view1.height/3)] # enfore aspect ratio 1/3)
##
## Some more features:
## * Batch operation (H:\|{elems:[a][b][c]}\|, H:[elems(25)] = HV:[a,b,c(25)] )
## * Space and newline are allowed in most position.
## * Parse everything as much as posible and never throw an error.
## * "spacing:" to specify the default spacing.
## * "variable:" to specify the variable name used in equal size spacers.
## * "outer:" to specify the outer object.
##
## The name of the *view stack* will be injected into current scope as a wResizable
## object, so name conflict should be avoided.
## To see more examples and try VFL, run examples/autolayoutEditor.nim
#
## :Seealso:
##   `wResizable <wResizable.html>`_

import strutils, parseutils, tables, strformat, sets

type
  VflRule = object
    name: string
    value: string
    priority: string

  VflMode = enum modeH, modeV

  VlfStack = object
    mode: VflMode
    leftSpace: string
    rightSpace: string
    children: seq[string]

  VflParser = object
    rules: OrderedTable[string, seq[VflRule]]
    stacks: OrderedTable[string, VlfStack]
    batches: OrderedTable[string, HashSet[string]]
    aliases: Table[string, string]
    currentStack: string
    currentBatch: string
    rawRules: seq[string]
    lastItems: seq[string]
    lastSpace: string
    variableCount: int
    variableName: string
    variableUsed: bool
    parent: string
    outer: string
    defaultSpacing: string
    barSpacing: string
    leftEdge: bool
    hvPos: int
    hvStart: bool
    hvValue: string
    mode: VflMode

proc parse*(parser: var VflParser, input: string)
proc addChild(parser: var VflParser, child: string, value: string)

proc reverse(mode: VflMode): VflMode =
  result = if mode == modeH: modeV else: modeH

proc remove(str: string, chars = Whitespace): string =
  result = newStringOfCap(str.len)
  for c in str:
    if c notin chars:
      result.add c

proc replace(input: var string, replacements: seq[(int, int, string)]) =
  for i in countdown(replacements.len-1, 0):
    input[replacements[i][0]..replacements[i][1]] = replacements[i][2]

proc resetHV(parser: var VflParser, mode: VflMode, value = "") =
  parser.mode = mode
  parser.leftEdge = true
  parser.lastItems = @[]
  parser.lastSpace = "0"

  if parser.variableUsed:
    parser.variableCount.inc
    parser.variableUsed = false

  parser.barSpacing = if value.len != 0: value else: parser.defaultSpacing

proc initVlfStack(mode = modeH): VlfStack =
  result.mode = mode
  result.leftSpace = "0"
  result.rightSpace = "0"
  result.children = @[]

proc initVflParser*(parent = "panel", spacing = 10, variable = "variable"): VflParser =
  ## Initializer.
  result.rules = initOrderedTable[string, seq[VflRule]]()
  result.stacks = initOrderedTable[string, VlfStack]()
  result.batches = initOrderedTable[string, HashSet[string]]()
  result.aliases = initTable[string, string]()
  result.currentStack = ""
  result.currentBatch = ""
  result.rawRules = @[]
  result.lastSpace = "0"
  result.parent = parent
  result.outer = ""
  result.defaultSpacing = $spacing
  result.variableName = variable
  result.variableCount = 0
  result.variableUsed = false
  result.hvPos = 0
  result.hvStart = false
  result.hvValue = ""
  result.resetHV(modeH)

proc left(parser: VflParser): string = ["left", "top"][parser.mode.ord]
proc innerLeft(parser: VflParser): string = ["innerLeft", "innerTop"][parser.mode.ord]
proc right(parser: VflParser): string = ["right", "bottom"][parser.mode.ord]
proc innerRight(parser: VflParser): string = ["innerRight", "innerBottom"][parser.mode.ord]
proc width(parser: VflParser): string = ["width", "height"][parser.mode.ord]
proc innerWidth(parser: VflParser): string = ["innerWidth", "innerHeight"][parser.mode.ord]

proc closeHV(parser: var VflParser, raw: string, pos: int) =
  if parser.hvStart:
    parser.hvStart = false
    parser.resetHV(modeV, parser.hvValue)
    parser.parse(raw[parser.hvPos..<pos])

iterator catchIdent(input: string, chars: set[char]): (int, int) =
  var pos = 0
  while pos < input.len:
    case input[pos]
    of IdentStartChars:
      let start = pos
      pos += input.skipWhile(chars, pos)
      if start != pos: yield (start, pos-1)
    else: pos.inc

proc setup(parser: var VflParser, input: string, raw: string, pos: int) =
  var
    tokens = input.split(':', maxsplit=1)
    cmd = tokens[0].toLowerAscii().strip()
    value = if tokens.len > 1 and tokens[1].len != 0: tokens[1].strip() else: ""

  parser.closeHV(raw, pos)

  case cmd
  of "h":
    parser.resetHV(modeH, value)
  of "v":
    parser.resetHV(modeV, value)
  of "hv", "vh":
    parser.resetHV(modeH, value)
    parser.hvStart = true
    parser.hvPos = pos + input.len
    parser.hvValue = value
  else: discard

  if value.len != 0:
    case cmd
    of "parent": parser.parent = value
    of "variable": parser.variableName = value
    of "spacing": parser.defaultSpacing = value
    of "outer": parser.outer = if value == "nil": "" else: value
    of "c": parser.rawRules.add value
    of "alias":
      var key = ""
      for start, last in value.catchIdent(IdentChars):
        if key.len == 0:
          key = value[start..last]
        else:
          parser.aliases[key] = value[start..last]
          key = ""
    else: discard

proc openStack(parser: var VflParser, name: string) =
  parser.currentStack = name
  parser.stacks[name] = initVlfStack(parser.mode)
  parser.addChild(name, "")
  parser.lastItems = @[]
  parser.lastSpace = "0"

proc closeStack(parser: var VflParser) =
  if parser.currentStack.len != 0:
    parser.stacks[parser.currentStack].rightSpace = parser.lastSpace
    parser.lastItems = @[parser.currentStack]
    parser.lastSpace = "0"
    parser.currentStack = ""

proc openBatch(parser: var VflParser, name: string) =
  parser.currentBatch = name
  parser.batches[name] = initHashSet[string]()

proc closeBatch(parser: var VflParser) =
  parser.currentBatch = ""

proc addNewChild(parser: var VflParser, item: string) =
  if item notin parser.rules:
    parser.rules[item] = @[]

proc addRule(parser: var VflParser, item: string, key: string, value: string, priority = "") =
  parser.addNewChild(item)
  parser.rules[item].add VflRule(name: key, value: value, priority: priority)

proc parseEqual(parser: var VflParser, input: string): (string, string) =
  var token: string
  if input.parseWhile(token, {'=', '>', '<'}) != 0:
    result = (token, input.substr(token.len))
  else:
    result = ("=", input)

proc parsePriority(parser: var VflParser, input: string): (string, string) =
  var tokens = input.rsplit('@', maxsplit=1)
  result = ((if tokens.len > 1: tokens[1] else: ""), tokens[0])

proc parseValue(parser: var VflParser, input: string): string =

  proc addAttrib(parser: var VflParser, input: var string) =
    var replacements = newSeq[(int, int, string)]()
    for start, last in input.catchIdent(IdentChars + {'.'}):
      let token = input[start..last]
      if '.' notin token: replacements.add (start, last, fmt"{token}.{parser.width}")

    input.replace(replacements)

  proc replacePercent(parser: var VflParser, input: var string) =
    iterator catchPercent(input: string): (int, int, float) =
      var
        pos = 0
        number: float

      while pos < input.len:
        case input[pos]
        of Digits:
          let start = pos
          pos += input.parseFloat(number, pos)
          if start != pos and pos < input.len and input[pos] == '%':
            yield (start, pos, number)
        else: pos.inc

    var replacements = newSeq[(int, int, string)]()
    for start, last, number in input.catchPercent():
      if parser.outer.len == 0:
        replacements.add (start, last, fmt"{parser.parent}.{parser.width}*{number/100}")
      else:
        replacements.add (start, last, fmt"{parser.outer}.{parser.innerWidth}*{number/100}")

    input.replace(replacements)

  result = input
  parser.addAttrib(result)
  parser.replacePercent(result)

  result = result.multiReplace(("+", " + "), ("-", " - "), ("*", " * "), ("/", " / "))

proc parseExpr(parser: var VflParser, input: string, quote = false, reverse = false):
    tuple[op: string, value: string, priority: string] =

  (result.op, result.value) = parser.parseEqual(input)
  (result.priority, result.value) = parser.parsePriority(result.value)
  result.value = parser.parseValue(result.value)

  if quote and result.value.find({'+', '-', '*', '/'}) != -1:
    result.value = fmt"({result.value})"

  if reverse:
    result.op = result.op.multiReplace(("<", ">"), (">", "<"))

proc parseEdge(parser: var VflParser) =
  defer: parser.lastSpace = "0"

  if parser.leftEdge:
    parser.lastItems = @[""]
    parser.leftEdge = false

  else: # close edge
    if not (parser.lastItems.len == 1 and parser.lastItems[0] == ""):
      var (op, space, priority) = parser.parseExpr(parser.lastSpace, quote=true, reverse=true)
      if space.len != 0:
        let edge =
          if parser.outer.len != 0:
            fmt"{parser.outer}.{parser.innerRight}"
          else:
            fmt"{parser.parent}.{parser.right}"

        for item in parser.lastItems:
          if space == "0":
            parser.addRule(item, parser.right, fmt" {op} {edge}", priority)

          else:
            parser.addRule(item, parser.right, fmt" {op} {edge} - {space}", priority)

    parser.resetHV(parser.mode)

proc addChild(parser: var VflParser, child: string, value: string) =
  parser.leftEdge = false
  parser.addNewChild(child)

  var (op, space, priority) = parser.parseExpr(parser.lastSpace, quote=true)
  if space.len != 0:
    for item in parser.lastItems:
      let edge =
        if item == "":
          if parser.outer.len == 0:
            fmt"{parser.parent}.{parser.left}"
          else:
            fmt"{parser.outer}.{parser.innerLeft}"
        else:
          fmt"{item}.{parser.right}"

      if space == "0":
        parser.addRule(child, parser.left, fmt" {op} {edge}", priority)
      else:
        parser.addRule(child, parser.left, fmt" {op} {edge} + {space}", priority)

  if value.len != 0:
    for part in value.split(','):
      var (op, value, priority) = parser.parseExpr(part)
      parser.addRule(child, parser.width, fmt" {op} {value}", priority)

proc parseChild(parser: var VflParser, input: string) =
  proc replaceBatch(parser: var VflParser, input: var string) =
    var replacements = newSeq[(int, int, string)]()
    for start, last in input.catchIdent(IdentChars + {'.'}):
      var
        token = input[start..last]
        dot = token.find('.')
        attrib = ""
        items = newSeq[string]()

      if dot >= 0:
        attrib = token[dot..^1]
        token = token[0..<dot]

      if token in parser.batches:
        for name in parser.batches[token]:
          items.add name & attrib

        replacements.add (start, last, items.join(","))

    input.replace(replacements)

  proc replaceRange(parser: var VflParser, input: var string) =
    iterator catchRange(input: string): (int, int, string, int, int) =
      var
        pos = 0
        name: string
        a, b, count: int

      while pos < input.len:
        case input[pos]
        of IdentStartChars:
          let start = pos
          pos += input.parseWhile(name, IdentStartChars, pos)
          if (count = input.parseSaturatedNatural(a, pos); pos += count; count) == 0: continue
          if (count = input.skip("..", pos); pos += count; count) == 0: continue
          if (count = input.parseSaturatedNatural(b, pos); pos += count; count) == 0: continue
          if a > b: swap(a, b)
          yield (start, pos-1, name, a, b)
        else: pos.inc

    var replacements = newSeq[(int, int, string)]()
    for start, last, name, a, b in input.catchRange():
      var items = newSeq[string]()
      for i in a..b:
        items.add fmt"{name}{i}"
      replacements.add (start, last, items.join(","))

    input.replace(replacements)

  var input = input
  parser.replaceRange(input)
  parser.replaceBatch(input)

  var
    open = input.find('(')
    close = input.rfind(')')
    value = ""

  if open != -1 and close != -1:
    value = input[open+1..close-1]
    input = input[0..<open]

  var
    pos = 0
    token: string
    items = newSeq[string]()

  while pos < input.len:
    case input[pos]
    of IdentStartChars:
      pos += input.parseWhile(token, IdentChars, pos)
      items.add token

      if parser.currentStack.len != 0:
        if parser.stacks[parser.currentStack].children.len == 0:
          parser.stacks[parser.currentStack].leftSpace = parser.lastSpace
        parser.stacks[parser.currentStack].children.add token

      if parser.currentBatch.len != 0:
        parser.batches[parser.currentBatch].incl token

      parser.addChild(token, value)

    else: pos.inc

  parser.lastItems = items
  if items.len != 0:
    parser.lastSpace = "0"

proc parseSpace(parser: var VflParser, input: string) =
  var
    input = input.remove(Whitespace)
    open = input.find('(')
    close = input.rfind(')')

  if open != -1 and close != -1:
    parser.lastSpace = input[open+1..close-1]

  else:
    input = input.remove({'-'})
    if input.len == 0:
      parser.lastSpace = parser.barSpacing

    elif input[0] == '>': # Disconnections
      parser.lastSpace = ""

    elif input[0] == '~': # Equal size spacers
      parser.lastSpace = "{" & $parser.variableCount & "}"
      parser.variableUsed = true

    else:
      parser.lastSpace = input

proc addStackRules(parser: var VflParser) =
  for name, stack in parser.stacks:
    if stack.children.len == 0: continue

    parser.mode = stack.mode
    var (op, space, priority) = parser.parseExpr(stack.leftSpace, quote=true, reverse=false)
    if space.len != 0:
      let edge = fmt"{name}.{parser.left}"
      if space == "0":
        parser.addRule(stack.children[0], parser.left, fmt" {op} {edge}", priority)
      else:
        parser.addRule(stack.children[0], parser.left, fmt" {op} {edge} + {space}", priority)

    (op, space, priority) = parser.parseExpr(stack.rightSpace, quote=true, reverse=true)
    if space.len != 0:
      let edge = fmt"{name}.{parser.right}"
      if space == "0":
        parser.addRule(stack.children[^1], parser.right, fmt" {op} {edge}", priority)
      else:
        parser.addRule(stack.children[^1], parser.right, fmt" {op} {edge} - {space}", priority)

    parser.mode = stack.mode.reverse()
    for child in stack.children:
      parser.addRule(child, parser.left, fmt" = {name}.{parser.left}")
      parser.addRule(child, parser.right, fmt" = {name}.{parser.right}")

proc parseEnd(parser: var VflParser) =
  if parser.variableUsed: parser.variableCount.inc

  for i in 0..<parser.variableCount:
    let
      v = "{" & $i & "}"
      n = parser.variableName & $(i + 1)

    for name, rules in parser.rules.mpairs:
      for rule in rules.mitems:
        if v in rule.value:
          rule.value = rule.value.replace(v, n)

proc parseIdentColon(input: string, token: var string, start = 0): int =
  var pos = start
  pos += input.skipWhitespace(pos)
  pos += input.parseIdent(token, pos)
  pos += input.skipWhitespace(pos)
  if pos < input.len and input[pos] == ':':
    result = pos - start + 1
  else:
    token = ""
    result = 0

proc parse*(parser: var VflParser, input: string) =
  ## The main parser function.
  var
    pos = 0
    token: string
    count: int

  defer:
    parser.closeHV(input, pos)
    parser.addStackRules()
    parser.parseEnd()

  while pos < input.len:
    case input[pos]
    of IdentStartChars:
      count = input.parseUntil(token, {'|', '[', '{', '\n', '\r'}, pos)
      pos += count
      parser.setup(token, input, pos-count)
    of '|':
      pos.inc
      parser.parseEdge()
    of '{':
      pos.inc
      pos += input.parseIdentColon(token, pos)
      if token != "":
        parser.openBatch(token)
    of '}':
      pos.inc
      parser.closeBatch()
    of '[':
      pos.inc
      pos += input.parseIdentColon(token, pos)
      if token != "":
        parser.openStack(token)
      else:
        count = input.parseUntil(token, {']'}, pos)
        pos += count + 1
        parser.parseChild(token)
    of ']':
      pos.inc
      parser.closeStack()
    of '-', '~':
      count = input.parseUntil(token, {'|', '[', '{', '\n', '\r', ']'}, pos)
      pos += count
      parser.parseSpace(token)
    of '#', '/':
      pos.inc input.skipUntil({'\n', '\r'}, pos)
    else: pos.inc

iterator names*(parser: VflParser, skipStacks = true): string =
  ## Iterates over item names in the parser.
  for key in parser.rules.keys:
    if skipStacks and key in parser.stacks: continue
    yield key

proc toString*(parser: VflParser, indent = 2, extraIndent = 0, templ = "layout"): string =
  ## Generates the layout DSL result.
  result = ""
  if parser.rules.len != 0:
    for i in 0..<parser.variableCount:
      let n = parser.variableName & $(i + 1)
      result.add spaces(extraIndent)
      result.add fmt"var {n} = newVariable()" & "\n"

    if parser.variableCount != 0:
      result.add "\n"

    for n in parser.stacks.keys:
      result.add spaces(extraIndent)
      result.add fmt"when not declaredInScope({n}):" & "\n"
      result.add fmt"  var {n} = Resizable()" & "\n\n"

    result.add spaces(extraIndent)
    result.add parser.parent & "." & templ & ":\n"
    for name, rules in parser.rules:
      if rules.len == 0:
        result.add spaces(indent + extraIndent)
        result.add name & ": discard"
      else:
        result.add spaces(indent + extraIndent)
        result.add name & ":\n"
        for rule in rules:
          result.add spaces(indent * 2 + extraIndent)
          if rule.priority.len != 0:
            result.add rule.priority & ": " & rule.name & rule.value & "\n"
          else:
            result.add rule.name & rule.value & "\n"
      result.add "\n"

  for rule in parser.rawRules:
    result.add spaces(indent + extraIndent)
    result.add rule
    result.add "\n"

  var replacements = newSeq[(int, int, string)]()
  for start, last in result.catchIdent(IdentChars):
    let token = result[start..last]
    if token in parser.aliases:
      replacements.add (start, last, parser.aliases[token])

  result.replace(replacements)

proc autolayout*(input: string, indent = 2, extraIndent = 0, templ = "layout"): string =
  ## Parse the Visual Format Language and output the layout DSL in one action.
  var parser = initVflParser()
  parser.parse($input)
  result = parser.toString(indent, extraIndent, templ)
