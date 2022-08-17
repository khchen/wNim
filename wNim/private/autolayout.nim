#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
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
## * Arithmetic (+, -, \*, /) for both element length and distance.
## * Batch operation (H:\|{elems:[a][b][c]}\|, H:[elems(25)] = HV:[a,b,c(25)] )
## * Aliases (Alias: a=Apple, b=Ball, c=Cat H:[a][b][c])
## * "spacing:" to specify the default spacing.
## * "variable:" to specify the variable name used in equal size spacers.
## * "strength:" to specify the strength in output. Default is "STRONG, MEDIUM, WEAK".
## * "outer:" to specify the outer object (following rule align sibling instead of parent).
## * Nim variable or expression can be used by quoting with `'`.
## * Space and newline are allowed in all position.
##
## To see more examples and try VFL, run examples/autolayoutEditor.nim
#
## :Seealso:
##   `wResizable <wResizable.html>`_

import npeg, nimpack
import strutils,tables, strformat, sets

type
  Mode = enum mHorizontal, mVertical

  Strength = object
    strong: string # element width or height
    medium: string # distance between element and edge
    weak: string # distance between elements

  State = object
    mode: Mode
    outer: string
    inStack: bool
    inSibling: bool
    variablePrefix: string
    variableName: string
    variableUsed: bool
    spacing: Distance
    strength: Strength

  Rule = object
    key, op, value: string

  Outcome = object
    rules: OrderedTable[string, OrderedTable[string, seq[Rule]]]
    variables: OrderedSet[string]
    stacks: OrderedSet[string]
    constraints: OrderedTable[string, OrderedSet[string]]

  Distance = object
    raw, op, priority: string

  Item = object
    name: string
    widths: seq[Distance]
    children: Sequence

  Group = object
    items: seq[Item]
    gap: Distance
    isEdge: bool

  Sequence = seq[Group]

  Command = object
    key: string
    value: string
    sequence: Sequence

  Layout = seq[Command]

  VflResult = object
    layout: Layout
    ok: bool
    matchLen: int
    matchMax: int

  VflParser = object
    parent: string
    state: State
    layout: Layout
    outcome: Outcome
    aliases: Table[string, string]

  VflParseError* = object of CatchableError
    matchLen: int
    matchMax: int

grammar "":
  trim(x) <- *Space * >x * *Space

  skip(x) <- *Space * x * *Space

  commaList(item) <- item * *(skip(',') * item)

  quote <- '`' * *(1 - '`') * '`':
    push($0)

  unquote <- '`' * >*(1 - '`') * '`':
    push($1)

  Alnum <- {'A'..'Z','a'..'z','0'..'9','_'}

  Operator <- {'+', '-', '*', '/'}

  Number <- ?{'+', '-'} * +Digit * ?('.' * +Digit)

  Percentage <- Number * '%'

  Tilde <- skip('~')

  Ident <- Alpha * *Alnum

  Newlines <- +{'\n', '\r'} | !1

template `?`[T: object|seq|string](x: T): bool =
  x != default(type T)

template `|`[T](a, b: T): T =
  if ?a: a else: b

proc `$$`[T](x: T): string {.inline.} =
  x.pack()

proc to[T](data: string): T {.inline.} =
  data.unpack(T)

proc stripAll(s: string, chars: set[char] = Whitespace): string =
  for c in s:
    if c notin chars:
      result.add c

proc addRule(outcome: var Outcome, item: Item, key, value, op, priority: string, reverse=false) =
  let op = case op:
    of "<=", "<":
      if reverse: ">=" else: "<="
    of ">=", ">":
      if reverse: "<=" else: ">="
    else: "="

  outcome.rules
    .mgetOrPut(item.name, initOrderedTable[string, seq[Rule]]())
    .mgetOrPut(priority, @[]).add Rule(key: key, op: op, value: value)

proc addSequence(outcome: var Outcome, sequence: Sequence, state: State) =

  template Left: string {.used.} = ["left", "top"][state.mode.ord]
  template Right: string {.used.} = ["right", "bottom"][state.mode.ord]
  template Top: string {.used.} = ["top", "left"][state.mode.ord]
  template Bottom: string {.used.} = ["bottom", "right"][state.mode.ord]
  template Width: string {.used.} = ["width", "height"][state.mode.ord]

  template InnerLeft: string {.used.} = ["innerLeft", "innerTop"][state.mode.ord]
  template InnerRight: string {.used.} = ["innerRight", "innerBottom"][state.mode.ord]
  template InnerTop: string {.used.} = ["innerTop", "innerLeft"][state.mode.ord]
  template InnerBottom: string {.used.} = ["innerBottom", "innerRight"][state.mode.ord]

  var
    state = state
    currentSpacing: Distance

  proc setupVariable(outcome: var Outcome) =
    var i = 1
    while true:
      state.variableName = state.variablePrefix & $i
      if state.variableName notin outcome.variables:
        state.variableUsed = false
        break
      i.inc

  proc useVariable(outcome: var Outcome) =
    if state.variableUsed:
      outcome.variables.incl state.variableName

  proc translate(raw: string): string =
    let peg = peg("arithmetic"):
      arithmetic <- element * *(trim(Operator) * element):
        var
          output: string
          quoted = false

        for i in 1..<capture.len:
          if capture[i].s[0] in {'+', '-', '*', '/'}:
            output.add ' ' & capture[i].s & ' '
            if capture[i].s[0] in {'+', '-'}:
              quoted = true
          else:
            output.add capture[i].s

        push(if quoted: fmt"({output})" else: output)

      element <- attrib | ident | percentage | number | quote | tilde | parentheses:
        push($1)

      attrib <- >(Ident * +('.' * Ident))

      ident <- Ident:
        push($0 & "." & Width)

      percentage <- >Number * skip('%'):
        let (width, outer, value) = (Width, state.outer, $1)
        push(fmt"{outer}.{width} * {value.parseFloat() / 100}")

      number <- >Number

      tilde <- Tilde:
        push(state.variableName)
        state.variableUsed = true

      parentheses <- skip('(') * arithmetic * skip(')'):
        if ($1)[0] == '(' and ($1)[^1] == ')':
          push($1)
        else:
          push('(' & $1 & ')')

    let matches = peg.match(raw)
    assert matches.ok
    result = matches.captures[0]

  proc translate(distance: Distance): Distance =
    case distance.raw
    of "->":
      return Distance()
    of "":
      return Distance(
        raw: "0",
        op: distance.op,
        priority: distance.priority)
    of "-":
      if not ?currentSpacing:
        currentSpacing = Distance(
          raw: translate(state.spacing.raw),
          op: state.spacing.op,
          priority: state.spacing.priority)
      return currentSpacing
    else:
      return Distance(
        raw: translate(distance.raw),
        op: distance.op,
        priority: distance.priority)

  outcome.setupVariable()
  defer:
    outcome.useVariable()

  var lastGroup: Group
  for group in sequence:
    defer: lastGroup = group

    let gap = translate(group.gap)
    if group.isEdge:
      if ?gap:
        let
          subGap = if gap.raw != "0": fmt" - {gap.raw}" else: ""
          priority = gap.priority | state.strength.medium

        for item in lastGroup.items:
          let R = if state.inSibling: InnerRight else: Right
          outcome.addRule(item, Right, fmt"{state.outer}.{R}{subGap}", gap.op, priority, reverse=true)

    else:
      let addGap = if gap.raw != "0": fmt" + {gap.raw}" else: ""

      for item in group.items:
        if ?gap:
          if lastGroup.isEdge:
            let
              priority = gap.priority | state.strength.medium
              L = if state.inSibling: InnerLeft else: Left
            outcome.addRule(item, Left, fmt"{state.outer}.{L}{addGap}", gap.op, priority)

          else:
            let priority = gap.priority | state.strength.weak
            for last in lastGroup.items:
              outcome.addRule(item, Left, fmt"{last.name}.{Right}{addGap}", gap.op, priority)

        for width in item.widths:
          let
            width = translate(width)
            priority = width.priority | state.strength.strong
          outcome.addRule(item, Width, width.raw, width.op, priority)

        if item.children.len != 0:
          var subState = state
          subState.outer = item.name
          subState.inStack = true
          subState.inSibling = false

          outcome.addSequence(item.children, subState)
          outcome.stacks.incl item.name

        if state.inStack:
          outcome.addRule(item, Top, fmt"{state.outer}.{InnerTop}", "=", state.strength.weak)
          outcome.addRule(item, Bottom, fmt"{state.outer}.{InnerBottom}", "=", state.strength.weak)

proc `$`(distance: Distance): string =
  if distance.op notin ["", "=", "=="]:
    result.add distance.op

  result.add distance.raw

  if ?distance.priority:
    result.add '@' & distance.priority

proc `$`(sequence: Sequence, isChildren = false): string =
  for group in sequence:
    if ?group.gap:
      let gap = $group.gap
      if gap in ["-", "->", "~"]:
        result.add gap
      else:
        result.add "-(" & gap & ")-"

    if group.isEdge:
      if not isChildren:
        result.add '|'

    else:
      result.add '['
      defer:
        result.removeSuffix(',')
        result.add ']'

      for item in group.items:
        result.add item.name
        if ?item.widths:
          result.add '('
          result.add $item.widths[0]
          for i in 1..<item.widths.len:
            result.add ',' & $item.widths[i]
          result.add ')'

        if item.children.len != 0:
          result.add ':'
          result.add `$`(item.children, isChildren=true)
        result.add ','

proc `$`(layout: Layout): string =
  var aliases: seq[string]
  for cmd in layout:
    if cmd.key == "ALIAS":
      let alias = cmd.value.split(',', maxsplit=1)
      aliases.add fmt"{alias[0]}={alias[1]}"

  if aliases.len != 0:
    result.add "alias: " & aliases.join(", ") & "\n"

  for cmd in layout:
    case cmd.key
    of "SPACING":
      let spacing = to[Distance](cmd.value)
      result.add fmt"Spacing: {$spacing}" & "\n"

    of "OUTER":
      result.add fmt"Outer: {cmd.value}" & "\n"

    of "VARIABLE":
      result.add fmt"Variable: {cmd.value}" & "\n"

    of "STRENGTH":
      result.add fmt"Strength: {cmd.value}" & "\n"

    of "H", "V", "HV", "VH":
      result.add fmt"{cmd.key}: {$cmd.sequence}" & "\n"

    of "C":
      let constraint = cmd.value.split(',', maxsplit=1)
      if ?constraint[0]:
        result.add fmt"C: {constraint[0]}: {constraint[1]}" & "\n"
      else:
        result.add fmt"C: {constraint[1]}" & "\n"

    else: discard

proc parse(input: string): VflResult =

  template `?`(n: int): bool =
    capture.len > n and capture[n].s != ""

  var
    currentMode = "H"
    currentBatch: string
    batches: OrderedTable[string, OrderedSet[string]]

  template joinCaptures(start = 1): string =
    var output: string
    for i in start..<capture.len:
      output.add capture[i].s
    output

  proc removeComment(input: string): string =
    for line in input.splitLines:
      for c in line:
        if c == '#': break
        result.add c
      result.add '\n'

  let peg = peg("vfl", vr: VflResult):

    vfl <- +command * &skip(!1)

    command <- hv | spacing | outer | variable | strength | constraints | aliases | batches | omitMode

    header(x) <- trim(x) * skip(':')

    hv <- header(i"HV" | i"VH" | i"H" | i"V") * line:
      let sequence = to[Sequence]($2)
      currentMode = toUpperAscii($1)
      vr.layout.add Command(key: currentMode, sequence: sequence)

    spacing <- header(i"SPACING") * distance:
      vr.layout.add Command(key: "SPACING", value: $2)

    outer <- header(i"OUTER") * (name | quote):
      vr.layout.add Command(key: "OUTER", value: $2)

    variable <- header(i"VARIABLE") * >Ident:
      vr.layout.add Command(key: "VARIABLE", value: $2)

    strength <- header(i"STRENGTH") * (trim(priority) * ?skip(','))[3]:
      # allow: A, B, C or A, B, C, or A B C
      vr.layout.add Command(key: "STRENGTH", value: $2 & ',' & $3 & ',' & $4)

    constraints <- header(i"C") * +skip(constraint):
      # allow: a=b, c=d or a=b, c=d, or a=b c=d
      var index = 2
      while ?index:
        let list = to[seq[(string, string)]](capture[index].s)
        for (priority, c) in list:
          vr.layout.add Command(key: "C", value: fmt"{priority},{c}")
        index.inc

    constraint <- >?(>priority * skip(':')) * +skip((equation * ?skip(','))):
      var
        (priority, index) = if ?1: ($2, 3) else: ("", 2)
        list: seq[(string, string)]

      while ?index:
        list.add (priority, capture[index].s)
        index.inc

      push($$list)

    equation <- arithmetic * >relation * arithmetic:
      push($1 & ' ' & stripAll($2) & ' ' & $3)

    aliases <- header(i"alias") * +(trim(Ident) * skip('=') * (trim(Ident) | quote) * ?skip(',')):
      # allow: A=B, C=D or A=B, C=D, or A=B C=D
      for i in countup(2, capture.len-1, 2):
        vr.layout.add Command(key: "ALIAS", value: fmt"{capture[i].s},{capture[i+1].s}")

    batches <- header(i"batch") * +(trim(Ident) * skip('=') * identList):
      # allow: A=B,C,D not allow extra ',' (A=B,C,D,)
      # allow: abc=a,b,c def=d,e,f
      for i in countup(2, capture.len-1, 2):
        let
          id = capture[i].s
          list = to[seq[string]](capture[i+1].s)

        batches[id] = initOrderedSet[string]()
        for i in list:
          batches[id].incl i

    omitMode <- line:
      let sequence = to[Sequence]($1)
      vr.layout.add Command(key: currentMode, sequence: sequence)

    line <- >?skip('|') * sequence * ?(?gap *  trim('|')) * ?skip(','):
      var sequence = to[Sequence]($2)

      if ?1:
        sequence.insert Group(isEdge: true)

      if ?4:
        sequence.add Group(isEdge: true, gap: to[Distance]($3))

      elif ?3:
        sequence.add Group(isEdge: true)

      push($$sequence)

    group <- >?gap * ?batchStart * skip('[') * items * *(skip(',') * items) * skip(']') * ?batchEnd:
      var (gap, index) = if ?1: (to[Distance]($2), 3) else: (Distance(), 2)

      var allItems: seq[Item]
      while ?index:
        case capture[index].s[0]
        of '{':
          currentBatch = capture[index + 1].s
          batches[currentBatch] = initOrderedSet[string]()
          index.inc
        of '}':
          currentBatch = ""
        else:
          let items = to[seq[Item]](capture[index].s)
          for item in items:
            if item.name in batches and batches[item.name].len != 0:
              for name in batches[item.name]:
                let batchItem = Item(name: name, widths: item.widths, children: item.children)
                allItems.add batchItem

            else:
              if ?currentBatch: batches[currentBatch].incl item.name
              allItems.add item

        index.inc

      let group = Group(items: allItems, gap: gap)
      push($$group)

    batchStart <- trim('{') * trim(Ident) * skip(':')

    batchEnd <- trim('}')

    items <- identRange * >?widths * >?cascaded:
      var
        children: Sequence
        names = to[seq[string]]($1)
        (widths, index) = if ?2: (to[seq[Distance]]($3), 4) else: (@[], 3)

      if ?index:
        children = to[Sequence](capture[index + 1].s)

      var items: seq[Item]
      for name in names:
        var item = Item(name: name, widths: widths, children: children)
        items.add item

      push($$items)

    widths <- skip('(') * distance * *(skip(',') * distance) * skip(')'):
      var
        index = 1
        widths: seq[Distance]

      while ?index:
        widths.add to[Distance](capture[index].s)
        index.inc

      push($$widths)

    cascaded <- skip(':') * sequence * >?gap:
      var
        sequence = to[Sequence]($1)
        gap = if ?2: to[Distance]($3) else: Distance()

      # Always add both edge to cascaded views
      sequence.insert Group(isEdge: true)
      sequence.add Group(isEdge: true, gap: gap)
      push($$sequence)

    sequence <- +group:
      var
        sequence: Sequence
        index = 1

      while ?index:
        sequence.add to[Group](capture[index].s)
        index.inc

      push($$sequence)

    gap <- skip('-') * skip('>') | skip('-') * skip('(') * distance * skip(')') * skip('-') |
        skip("-") * distance * skip("-") | skip({'-', '~'}):

      if ?1: # has distance already
        push($1)

      else:
        push($$Distance(raw: stripAll($0)))

    distance <- >?relation * arithmetic * ?(skip('@') * >priority):
      let op = case stripAll($1)
      of "<=", "<": "<="
      of ">=", ">": ">="
      else: "="
      push($$Distance(op: op, raw: stripAll($2), priority: if ?3: $3 else: ""))

    relation <- skip('=')[1..2] | skip({'<', '>'}) * ?skip('=')

    priority <- Number | "STRONGEST" | "STRONGER" | "WEAKEST" | "WEAKER" | "REQUIRED" |
      "STRONG" * ?{'1'..'9'} | "MEDIUM" * ?{'1'..'9'} | "WEAK" * ?{'1'..'9'}

    identRange <- >(Alpha * *(Alnum - range)) * range | name | quote:
      var names: seq[string]
      if ?3:
        var r = parseInt($2)..parseInt($3)
        if r.a > r.b: swap(r.a, r.b)
        for i in r:
          names.add $1 & $i
      else:
        names.add $1

      push($$names)

    range <- >+Digit * skip("..") * >+Digit

    operator <- Operator:
      push(' ' & stripAll($0) & ' ')

    arithmetic <- element * *(skip(operator) * element):
      push(joinCaptures())

    element <- name * >+('.' * Ident) | name | >Percentage | >Number | quote | >Tilde | trim('(') * arithmetic * trim(')'):
      push(joinCaptures())

    name <- Ident:
      push($0)

    identList <- commaList(trim(Ident)):
      var
        index = 1
        list: seq[string]

      while ?index:
        list.add capture[index].s
        index.inc

      push($$list)

  let mr = peg.match(input.removeComment(), result)
  result.ok = mr.ok
  result.matchLen =  mr.matchLen
  result.matchMax = mr.matchMax

proc `$`*(parser: VflParser): string =
  ## Output the current layout as visual format language.
  result = $parser.layout

proc generateOutcome(parser: VflParser): Outcome =

  template `?`(n: int): bool =
    capture.len > n and capture[n].s != ""

  proc `**`(input: string): string # unpacking alias and quote

  var cache: Table[string, string]

  proc rename(name: string): string =
    cache.withValue(name, newName):
      result = newName[]
    do:
      if name in parser.aliases:
        result = **parser.aliases[name]
      else:
        result = name
      cache[name] = result

  proc depar(input: string): string =
    result =
      if input[0] == '(' and input[^1] == ')': input[1..^2]
      else: input

  proc `**`(input: string): string =
    let peg = peg("equation"):

      equation <- arithmetic * >?(trim('='[1..2] | {'<', '>'} * ?'=') * arithmetic):
        if ?4:
          push(depar($1) & ' ' & $3 & ' ' & depar($4))
        else:
          push(depar($1))

      arithmetic <- element * *(trim(Operator) * element):
        var
          output: string
          quoted = false

        for i in 1..<capture.len:
          if capture[i].s[0] in {'+', '-', '*', '/'}:
            output.add ' ' & capture[i].s & ' '
            if capture[i].s[0] in {'+', '-'}:
              quoted = true
          else:
            output.add capture[i].s

        push(if quoted: fmt"({output})" else: output)

      element <- attrib | unquote | ident | number | parentheses:
        push($1)

      attrib <- (unquote | ident) * >+('.' * Ident):
        push($1 & $2)

      ident <- >Ident:
        push(rename($1))

      number <- >Number

      parentheses <- skip('(') * arithmetic * skip(')'):
        if ($1)[0] == '(' and ($1)[^1] == ')':
          push($1)
        else:
          push('(' & $1 & ')')

    let matches = peg.match(input)
    assert matches.ok
    result = matches.captures[0]

  result.variables = parser.outcome.variables
  result.stacks = parser.outcome.stacks

  for item, priorities in parser.outcome.rules:
    for priority, rules in priorities:
      for rule in rules:
        result.rules
          .mgetOrPut(**item, initOrderedTable[string, seq[Rule]]())
          .mgetOrPut(priority, @[]).add Rule(key: rule.key, op: rule.op, value: **rule.value)

  for priority, rules in parser.outcome.constraints:
    for rule in rules:
      result.constraints
        .mgetOrPut(priority, initOrderedSet[string]())
        .incl **rule

proc toString*(parser: VflParser, indent = 2, extraIndent = 0, templ = "layout"): string =
  ## Generates the wNim layout DSL.
  let outcome = parser.generateOutcome()

  for n in outcome.stacks:
    result.add spaces(extraIndent)
    result.add fmt"when not declaredInScope({n}):" & "\n"
    result.add fmt"{spaces(indent)}var {n} = Resizable()" & "\n\n"

  for variable in outcome.variables:
    result.add spaces(extraIndent)
    result.add fmt"var {variable} = newVariable()" & "\n"
  if outcome.variables.len != 0: result.add "\n"

  if outcome.rules.len != 0 or outcome.constraints.len != 0:
    result.add spaces(extraIndent)
    result.add fmt"{parser.parent}.{templ}:" & "\n"

  for item, priorities in outcome.rules:
    result.add spaces(indent + extraIndent)
    result.add item & ":\n"
    for priority, rules in priorities:
      result.add spaces(indent * 2 + extraIndent)
      result.add fmt"{priority}:" & "\n"
      for rule in rules:
        result.add spaces(indent * 3 + extraIndent)
        result.add fmt"{rule.key} {rule.op} {rule.value}" & "\n"

  if outcome.constraints.len != 0 and outcome.rules.len != 0: result.add "\n"

  if "" in outcome.constraints:
    for rule in outcome.constraints[""]:
      result.add spaces(indent + extraIndent)
      result.add rule & "\n"

  for priority, rules in outcome.constraints:
    if priority == "": continue
    result.add spaces(indent + extraIndent)
    result.add fmt"{priority}:" & "\n"
    for rule in rules:
      result.add spaces(indent * 2 + extraIndent)
      result.add rule & "\n"

proc initVflParser*(parent = "panel", spacing = 10, variable = "variable"): VflParser =
  ## Initializer.
  result.parent = parent
  result.state.spacing = Distance(raw: $spacing, op: "=")
  result.state.variablePrefix = variable
  result.state.outer = fmt"`{parent}`"
  result.state.inSibling = false
  result.state.strength = Strength(strong: "STRONG", medium: "MEDIUM", weak: "WEAK")

proc parse*(parser: var VflParser, input: string) =
  ## The main parser function. Raise `VflParseError` if enconter an error.
  if input.len == 0:
    return

  var vr = input.parse()
  for cmd in vr.layout:
    case cmd.key
    of "SPACING":
      parser.state.spacing = to[Distance](cmd.value)

    of "OUTER":
      parser.state.outer = cmd.value
      parser.state.inSibling = true

    of "VARIABLE":
      parser.state.variablePrefix = cmd.value

    of "STRENGTH":
      let s = cmd.value.split(',')
      parser.state.strength = Strength(strong: s[0], medium: s[1], weak: s[2])

    of "ALIAS":
      let alias = cmd.value.split(',', maxsplit=1)
      parser.aliases[alias[0]] = alias[1]

    of "H":
      parser.state.mode = mHorizontal
      parser.outcome.addSequence(cmd.sequence, parser.state)

    of "V":
      parser.state.mode = mVertical
      parser.outcome.addSequence(cmd.sequence, parser.state)

    of "HV":
      parser.state.mode = mHorizontal
      parser.outcome.addSequence(cmd.sequence, parser.state)
      parser.state.mode = mVertical
      parser.outcome.addSequence(cmd.sequence, parser.state)

    of "VH":
      parser.state.mode = mVertical
      parser.outcome.addSequence(cmd.sequence, parser.state)
      parser.state.mode = mHorizontal
      parser.outcome.addSequence(cmd.sequence, parser.state)

    of "C":
      let
        constraint = cmd.value.split(',', maxsplit=1)
        priority = constraint[0]
        rule = constraint[1]

      parser.outcome.constraints
        .mgetOrPut(priority, initOrderedSet[string]())
        .incl rule

  parser.layout &= vr.layout

  if not vr.ok:
    var max = vr.matchMax
    while max != 0 and (max >= input.len or input[max] in Whitespace):
      max.dec

    var error = newException(VflParseError,
      fmt"unexpected char: '{input[max]}' at position {max}")

    error.matchMax = vr.matchMax
    error.matchLen = vr.matchLen
    raise error

iterator names*(parser: VflParser, skipStacks = true): string =
  ## Iterates over item names in the parser.
  for key in parser.outcome.rules.keys:
    if skipStacks and key in parser.outcome.stacks: continue

    if key in parser.aliases:
      yield parser.aliases[key]
    else:
      yield key

iterator variables*(parser: VflParser): string =
  ## Iterates over variable names in the parser.
  for variable in parser.outcome.variables:
    echo variable

proc autolayout*(input: string, indent = 2, extraIndent = 0, templ = "layout"): string =
  ## Parse the Visual Format Language and output the layout DSL in one action.
  var parser = initVflParser()
  try:
    parser.parse($input)
  except VflParseError:
    discard

  result = parser.toString(indent, extraIndent, templ)

when isMainModule:
  var parser = initVflParser()
  parser.parse("HV:|~[col:-1-[a,b,c(=50%/2-10@STRONG)]-(-2@20)-[d1..3(>e,=f,<g,h.width)]-3-]~|")
  assert $parser == "HV: |~[col:-(1)-[a,b,c(50%/2-10@STRONG)]-(-2@20)-[d1(>=e,f,<=g,h.width),d2(>=e,f,<=g,h.width),d3(>=e,f,<=g,h.width)]-(3)-]~|" & "\n"

  parser = initVflParser()
  parser.parse """
  H:|-[staticbox]-|
  H:|->[buttonShow]-[buttonClose]-[buttonShowModal]-|
  V:|-[staticbox]-[buttonShow,buttonClose,buttonShowModal]-|

  outer: staticbox
  H:|-[radioMessage,radioDir,radioFile,radioColor,radioFont,radioTextEntry,
    radioPasswordEntry,radioFindReplace,radioPageSetup,radioPrint]-|
  V:|-[radioMessage]-[radioDir]-[radioFile]-[radioColor]-[radioFont]-
    [radioTextEntry]-[radioPasswordEntry]-[radioFindReplace]-
    [radioPageSetup]-[radioPrint]
  """
  echo parser
