#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim,
  random, sets, strformat,
  mcts/[gamebase, engine_reversi]

type
  MenuId = enum idNew = 100, idExit, idAi1, idAi2,
    idAiTimeout1, idAiTimeout3, idAiTimeout5

  wBoard = ref object of wFrame
    mGame: Game[State]
    mMemDc: wMemoryDC
    mBoard: wImage
    mPiece1: wImage
    mPiece2: wImage
    mUseAi: array[Player, bool]
    mAiTimeout: float

proc information(self: wBoard) =
  if self.mGame.isFinish():
    case self.mGame.getWinner()
    of P1:
      self.statusBar.setStatusText("Black wins.")
    of P2:
      self.statusBar.setStatusText("White wins.")
    else:
      self.statusBar.setStatusText("Draw game.")
  else:
    if self.mGame.getRounds() != 0:
      let msg = fmt"{self.mGame.getRounds()} rounds, rate: {self.mGame.getRate():.4f}"
      self.statusBar.setStatusText(msg)

    var count: array[Player, int]
    for i in self.mGame.getBoard:
      count[i].inc

    self.statusBar.setStatusText(fmt"Black: {count[P1]}  White: {count[P2]}", 1)

proc tryStartAi(self: wBoard) =
  if not self.mGame.isFinish():
    if self.mUseAi[self.mGame.getNextPlayer()]:
      self.mGame.aiStart(self.mAiTimeout)
      self.startTimer(0.1)

proc drawBoard(self: wBoard) =
  let size = self.clientSize
  self.mMemDc.clear()
  self.mMemDc.drawImage(self.mBoard)

  var board = self.mGame.getBoard()
  for i in 1..8:
    for j in 1..8:
      var x = 37 + 50 * (i - 1)
      var y = 37 + 50 * (j - 1)
      if i > 4: x += 2

      case board[i * 10 + j]
      of P1:
        self.mMemDc.drawImage(self.mPiece1, x, y)
      of P2:
        self.mMemDc.drawImage(self.mPiece2, x, y)
      else: discard

  self.refresh(eraseBackground=false)
  self.information()

proc final(self: wBoard) =
  wFrame(self).final()

proc init(self: wBoard, title: string) =
  wFrame(self).init(title=title,
    style=wCaption or wSystemMenu or wMinimizeBox or wModalFrame)
  self.setIcon(Icon("", 0))

  const boardImg = staticRead(r"images\board2.png")
  const piece1Img = staticRead(r"images\black.png")
  const piece2Img = staticRead(r"images\white.png")
  self.mBoard = Image(boardImg)
  self.mPiece1 = Image(piece1Img)
  self.mPiece2 = Image(piece2Img)

  randomize()
  self.mGame = newGame[State]()
  self.mUseAi[P2] = true
  self.mAiTimeout = 1

  var statusbar = StatusBar(self)
  statusbar.setStatusWidths([-2, -1])

  var menubar = MenuBar(self)
  var menu = Menu(menubar, "&Game")
  menu.append(idNew, "&New Game")
  menu.appendSeparator()
  menu.appendCheckItem(idAi1, "Computer Play Black")
  menu.appendCheckItem(idAi2, "Computer Play White").check()
  menu.appendSeparator()
  menu.appendRadioItem(idAiTimeout1, "Computer Think 1 Second").check()
  menu.appendRadioItem(idAiTimeout3, "Computer Think 3 Seconds")
  menu.appendRadioItem(idAiTimeout5, "Computer Think 5 Seconds")
  menu.appendSeparator()
  menu.append(idExit, "E&xit")

  self.clientSize = self.mBoard.size

  self.mMemDc = MemoryDC()
  self.mMemDc.selectObject(Bmp(self.mBoard.size))
  self.mMemDc.setBackground(wWhiteBrush)
  self.drawBoard()

  self.idNew do ():
    self.mGame.reset()
    self.drawBoard()
    self.tryStartAi()

  self.idExit do ():
    self.delete()

  self.idAi1 do ():
    self.mUseAi[P1] = menu.isChecked(idAi1)
    self.tryStartAi()

  self.idAi2 do ():
    self.mUseAi[P2] = menu.isChecked(idAi2)
    self.tryStartAi()

  self.idAiTimeout1 do (): self.mAiTimeout = 1
  self.idAiTimeout3 do (): self.mAiTimeout = 3
  self.idAiTimeout5 do (): self.mAiTimeout = 5

  self.wEvent_Paint do ():
    var dc = PaintDC(self)
    let size = dc.size
    dc.blit(source=self.mMemDc, width=size.width, height=size.height)
    dc.delete

  self.wEvent_Size do (event: wEvent):
    self.drawBoard()

  self.wEvent_LeftDown do (event: wEvent):
    if not self.mUseAi[self.mGame.getNextPlayer]:
      let pos = event.getMousePos()
      let xx: float = (pos.x - 37) / 50
      let yy: float = (pos.y - 37) / 50
      let px = xx - xx.int.float
      let py = yy - yy.int.float
      let x = int xx + 1
      let y = int yy + 1

      if px > 0.1 and px < 0.9 and py > 0.1 and py < 0.9 and x in 1..8 and y in 1..8:
        let move = Move(x * 10 + y)

        if self.mGame.play(move):
          self.drawBoard()

          if not self.mGame.isFinish():
            self.tryStartAi()

  self.wEvent_Timer do (event: wEvent):
    if self.mGame.aiReady():
      self.stopTimer()
      self.mGame.aiPlay()
      self.drawBoard()

      if not self.mGame.isFinish():
        self.tryStartAi()

proc Board(title: string): wBoard {.inline.} =
  new(result, final)
  result.init(title)

let app = App()
let board = Board(title="wNim Reversi")

board.center()
board.show()
app.mainLoop()
