#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import threadpool, mcts, sets, strformat

type
  Game*[State] = ref object
    state: State
    fv: FlowVar[State]

proc newGame*[State](): Game[State] =
  new(result)
  result.state = State()
  result.state.init()

proc reset*[State](self: Game[State]) {.inline.} =
  self.state = State()
  self.state.init()

proc getBoard*[State](self: Game[State]): auto {.inline.} =
  result = self.state.board

proc getRounds*[State](self: Game[State]): int {.inline.} =
  result = self.state.rounds

proc getRate*[State](self: Game[State]): float {.inline.} =
  result = self.state.rate

proc isFinish*[State](self: Game[State]): bool {.inline.} =
  result = self.state.getMoves().card == 0

proc getNextPlayer*[State](self: Game[State]): auto =
  type
    Player = self.state.playerJustMoved.type

  if self.isFinish():
    result = Player(0)
  else:
    result = Player(3 - self.state.playerJustMoved.ord)

proc getWinner*[State](self: Game[State]): auto =
  type
    Player = self.state.playerJustMoved.type

  var score = self.state.getResult(Player(1))
  if score > 0.5:
    result = Player(1)
  elif score < 0.5:
    result = Player(2)
  else:
    result = Player(0)

proc play*[State, Move](self: Game[State], move: Move): bool {.discardable.} =
  if move in self.state.getMoves():
    self.state.doMove(move)
    result = true

proc aiStart*[State](self: Game[State], timeout: float) =
  self.fv = spawn mcts(self.state, itermax=int.high, timeout=timeout)

proc aiReady*[State](self: Game[State]): bool {.inline.} =
  result = isReady(self.fv)

proc aiPlay*[State](self: Game[State]) =
  var newState = ^self.fv
  self.state.move = newState.move
  self.state.rate = newState.rate
  self.state.rounds = newState.rounds
  self.state.doMove(newState.move)

when isMainModule:
  import os, random
  # import engine_nim
  # import engine_tictactoe
  import engine_reversi
  randomize()
  var game = newGame[State]()
  echo game.getBoard.repr

  while not game.isFinish():
    game.aiStart(0.5)
    while not game.aiReady():
      os.sleep(100)
    game.aiPlay()
    echo "rounds: ", game.getRounds()
    echo game.getBoard.repr

  echo game.getWinner()
