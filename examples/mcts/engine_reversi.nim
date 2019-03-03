#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import sets

const BoardSize = 8
const Edge = BoardSize + 2

type
  Player* = enum
    NONE = "."
    P1 = "O"
    P2 = "X"
    BLOCK = " "
  Move* = uint8
  Board* = array[Edge * Edge, Player]
  State* = ref object
    move*: Move
    rate*: float
    rounds*: int
    playerJustMoved*: Player
    board*: Board

proc init*(state: State) =
  state.playerJustMoved = P2 # P1 first

  for i in 0..<Edge * Edge:
    state.board[i] = NONE

  for i in 0..<Edge:
    state.board[i] = BLOCK
    state.board[i * Edge] = BLOCK
    state.board[i * Edge + (Edge - 1)] = BLOCK
    state.board[i + (Edge * (Edge - 1))] = BLOCK

  state.board[Edge * Edge div 2 - Edge div 2] = P1
  state.board[Edge * Edge div 2 - Edge div 2 - 1] = P2

  state.board[Edge * Edge div 2 + Edge div 2] = P2
  state.board[Edge * Edge div 2 + Edge div 2 - 1] = P1

proc doMove*(state: State, move: Move) =
  let enemy = state.playerJustMoved
  state.playerJustMoved = Player(3 - state.playerJustMoved.ord)
  let me = state.playerJustMoved

  assert move < Edge * Edge
  if move == 0: return # null move

  assert state.board[move] == NONE

  state.board[move] = me
  var eats: array[Edge, Move]

  for dx in [1, -1, Edge, -Edge, -Edge + 1, -Edge - 1, Edge + 1, Edge - 1]:
    if state.board[move + Move dx] == enemy:
      var m = move
      var index = 0

      while true:
        m.inc(dx)
        if state.board[m] == me:
          for i in 0..<index:
            state.board[eats[i]] = me
          break

        elif state.board[m] == enemy:
          eats[index] = m
          index.inc
          continue

        else: # NONE or BLOCK
          break

proc getMoves(state: State, enemy: Player): HashSet[Move] =
  result.init()
  let me = Player(3 - enemy.ord)

  for i in Edge..Edge * (Edge - 1):
    if state.board[i] == NONE:
      for dx in [1, -1, Edge, -Edge, -Edge + 1, -Edge - 1, Edge + 1, Edge - 1]:
        if state.board[i + dx] == enemy:
          var m = i
          while true:
            m.inc(dx)
            if state.board[m] == me:
              result.incl(MOVE i)
              break

            elif state.board[m] == enemy:
              continue

            else: # NONE or BLOCK
              break

proc getMoves*(state: State): HashSet[Move] =
  result = state.getMoves(state.playerJustMoved)
  if result.card == 0:
    var enemyMoves = state.getMoves(Player(3 - state.playerJustMoved.ord))
    if enemyMoves.card != 0:
      result.incl(0)

proc getResult*(state: State, lastPlayer: Player): float =
  let enemy = Player(3 - lastPlayer.ord)
  var winCount = 0

  for i in Edge..Edge * (Edge - 1):
    if state.board[i] == lastPlayer: winCount.inc
    elif state.board[i] == enemy: winCount.dec

  if winCount > 0:
    return 1
  elif winCount == 0:
    return 0.5
  else:
    return 0

proc repr*(board: Board): string =
  result = ""
  for i in 1..BoardSize:
    for j in 1..BoardSize:
      result.add($board[i * Edge + j])
    result.add("\n")
