#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import sets

type
  Player* = enum
    NONE = "."
    P1 = "O"
    P2 = "X"
  Move* = range[0..8]
  Board* = array[9, Player]
  State* = ref object
    move*: Move
    rate*: float
    rounds*: int
    playerJustMoved*: Player
    board*: Board

proc init*(state: State) =
  state.playerJustMoved = P2 # P1 first
  state.board = [NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE]

proc doMove*(state: State, move: Move) =
  state.playerJustMoved = Player(3 - state.playerJustMoved.ord)
  state.board[move] = state.playerJustMoved

proc checkBoard(state: State): Player =
  for tup in [(0, 1, 2), (3, 4, 5), (6, 7, 8), (0, 3, 6), (1, 4, 7), (2, 5, 8),
      (0, 4, 8), (2, 4, 6)]:

    let (x, y, z) = tup
    if state.board[x] != NONE and state.board[x] == state.board[y] and
        state.board[y] == state.board[z]:

      return state.board[x]
  return NONE

proc getMoves*(state: State): HashSet[Move] =
  result.init()
  if state.checkBoard() == NONE:
    for i, p in state.board:
      if p == NONE: result.incl(i)

proc getResult*(state: State, lastPlayer: Player): float =
  var win = state.checkBoard()
  if win == lastPlayer:
    result = 1
  elif win == NONE:
    result = 0.5
  else:
    result = 0

proc repr*(board: Board): string =
  result = ""
  for i, p in board:
    result.add($p)
    if i mod 3 == 2: result.add("\n")
