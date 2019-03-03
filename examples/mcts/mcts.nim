#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import random, algorithm, math, strutils, sets, times, hashes, strformat

# http://mcts.ai/code/python.html

proc mcts*[State](rootState: State, itermax: int, timeout: float = 0,
    verbos = false): State {.discardable.} =

  type
    Move = rootState.move.type
    Node = ref object
      move: Move
      parent: Node
      childNodes: seq[Node]
      wins: float
      visits: float
      untriedMoves: HashSet[Move]
      playerJustMoved: Player

  proc `[]`[T](x: HashSet[T], i: int): T {.inline.} =
    var index = i
    for n in x:
      if index == 0:
        result = n
        break
      index.dec

  proc newNode(state: State): Node {.inline.} =
    new(result)
    result.childNodes = @[]
    result.wins = 0
    result.visits = 0
    result.untriedMoves = state.getMoves()
    result.playerJustMoved = state.playerJustMoved

  proc selectChild(node: Node): Node {.inline.} =
    var best = -1'f
    if node.childNodes.len == 1:
      return node.childNodes[0]

    for n in node.childNodes:
      var value = (n.wins / n.visits) + sqrt(2 * ln(node.visits) / n.visits)
      if value > best:
        best = value
        result = n

  proc addChild(node: var Node, move: Move, state: State): Node {.inline.} =
    result = newNode(state)
    result.move = move
    result.parent = node
    node.untriedMoves.excl(move)
    node.childNodes.add(result)

  proc update(node: var Node, result: float) {.inline.} =
    node.visits += 1
    node.wins += result

  proc clone[T](x: T): T {.inline.} =
    var tmp: T
    deepCopy(tmp, x)
    tmp

  var moves = rootState.getMoves()
  if moves.card == 1:
    rootState.move = moves[0]
    rootState.rate = 0'f64
    rootState.rounds = 0
    return rootState

  var rootNode = newNode(rootState)
  var start = cpuTime()
  var rounds = 0
  var isTimeout = false

  for i in 0..<itermax:
    rounds.inc

    var node = rootNode
    var state = rootState.clone # needs deepcopy here

    # "Select"
    while node.untriedMoves.card == 0 and node.childNodes.len != 0:
      # node is fully expanded and non-terminal
      node = node.selectChild()
      state.doMove(node.move)

    # "Expand"
    if node.untriedMoves.card != 0:
      var move = node.untriedMoves[rand(node.untriedMoves.card-1)]
      state.doMove(move)
      node = node.addChild(move, state)

    # "Rollout"
    while true:
      moves = state.getMoves()
      if moves.card == 0: break
      state.doMove(moves[rand(moves.card-1)])

    # "Backpropagate"
    var score = state.getResult(node.playerJustMoved)
    while node != nil:
      node.update(score)
      node = node.parent
      score = 1 - score

    if timeout > 0 and cpuTime() - start > timeout:
      isTimeout = true
      break

  var sortedNodes: seq[tuple[rate: float, node: Node]]
  newSeq(sortedNodes, rootNode.childNodes.len)

  for i, n in rootNode.childNodes:
    sortedNodes[i].node = n
    sortedNodes[i].rate = (n.wins + 1) / (n.visits + 2)

  sortedNodes.sort do (x, y: tuple[rate: float, node: Node]) -> int:
    if x.rate > y.rate: return 1
    elif x.rate < y.rate: return -1
    return 0

  if verbos:
    for i in sortedNodes:
      echo fmt"{i.node.move.repr} {int i.node.wins}/{int i.node.visits} {i.rate:.4f}"

  rootState.move = sortedNodes[^1].node.move
  rootState.rate = float sortedNodes[^1].rate
  rootState.rounds = rounds
  return rootState

when isMainModule:
  # import engine_nim
  # import engine_tictactoe
  import engine_reversi
  randomize()
  var state = State()
  state.init()
  echo state.board.repr

  while state.getMoves().card != 0:
    mcts(state, int.high, timeout=0.1)
    echo "rounds: ", state.rounds
    state.doMove(state.move)
    echo state.board.repr
