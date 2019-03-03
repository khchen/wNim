#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import sets, strformat

type
  Player* = enum
    NONE
    P1
    P2
  Move* = tuple[heap: int, n: int]
  Board* = seq[int]
  State* = ref object
    move*: Move
    rate*: float
    rounds*: int
    playerJustMoved*: Player
    board*: Board

proc init*(state: State) =
  state.playerJustMoved = P2 # P1 first
  state.board = @[3, 4, 5]

proc doMove*(state: State, move: Move) =
  state.playerJustMoved = Player(3 - state.playerJustMoved.ord)
  state.board[move.heap] -= move.n

proc getMoves*(state: State): HashSet[Move] =
  result.init()
  for i in 0..<state.board.len:
    for j in 1..state.board[i]:
      result.incl((i, j))

proc getResult*(state: State, lastPlayer: Player): float =
  result = 1

proc repr*(board: Board): string =
  result = ""
  for i in board:
    result.add($i & " ")
