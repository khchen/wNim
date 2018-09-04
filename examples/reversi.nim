#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

{.this: self, passL: "wNim.res".}
import random, sets, strformat
import mcts/[gamebase, engine_reversi]
import wNim

type
  MenuId = enum idNew, idExit, idAi1, idAi2,
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
  if mGame.isFinish():
    case mGame.getWinner()
    of P1:
      self.statusBar.setStatusText("Black wins.")
    of P2:
      self.statusBar.setStatusText("White wins.")
    else:
      self.statusBar.setStatusText("Draw game.")
  else:
    if mGame.getRounds() != 0:
      let msg = fmt"{mGame.getRounds()} rounds, rate: {mGame.getRate():.4f}"
      self.statusBar.setStatusText(msg)

    var count: array[Player, int]
    for i in mGame.getBoard:
      count[i].inc

    self.statusBar.setStatusText(fmt"Black: {count[P1]}  White: {count[P2]}", 1)

proc tryStartAi(self: wBoard) =
  if not mGame.isFinish():
    if mUseAi[mGame.getNextPlayer()]:
      mGame.aiStart(mAiTimeout)
      self.startTimer(0.1)

proc drawBoard(self: wBoard) =
  let size = self.clientSize
  mMemDc.clear()
  mMemDc.drawImage(mBoard)

  var board = mGame.getBoard()
  for i in 1..8:
    for j in 1..8:
      var x = 37 + 50 * (i - 1)
      var y = 37 + 50 * (j - 1)
      if i > 4: x += 2

      case board[i * 10 + j]
      of P1:
        mMemDc.drawImage(mPiece1, x, y)
      of P2:
        mMemDc.drawImage(mPiece2, x, y)
      else: discard

  refresh(eraseBackground=false)
  information()

proc final(self: wBoard) =
  wFrame(self).final()

proc init(self: wBoard, title: string) =
  wFrame(self).init(title=title,
    style=wCaption or wSystemMenu or wMinimizeBox or wModalFrame)
  setIcon(Icon("", 0))

  const boardImg = staticRead(r"images\board2.png")
  const piece1Img = staticRead(r"images\black.png")
  const piece2Img = staticRead(r"images\white.png")
  mBoard = Image(boardImg)
  mPiece1 = Image(piece1Img)
  mPiece2 = Image(piece2Img)

  randomize()
  mGame = newGame[State]()
  mUseAi[P2] = true
  mAiTimeout = 1

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

  self.clientSize = mBoard.size

  mMemDc = MemoryDC()
  mMemDc.selectObject(Bmp(mBoard.size))
  mMemDc.setBackground(wWhiteBrush)
  drawBoard()

  self.idNew do ():
    mGame.reset()
    self.drawBoard()
    self.tryStartAi()

  self.idExit do ():
    self.delete()

  self.idAi1 do ():
    mUseAi[P1] = menu.isChecked(idAi1)
    self.tryStartAi()

  self.idAi2 do ():
    mUseAi[P2] = menu.isChecked(idAi2)
    self.tryStartAi()

  self.idAiTimeout1 do (): mAiTimeout = 1
  self.idAiTimeout3 do (): mAiTimeout = 3
  self.idAiTimeout5 do (): mAiTimeout = 5

  self.wEvent_Paint do ():
    var dc = PaintDC(self)
    let size = dc.size
    dc.blit(source=mMemDc, width=size.width, height=size.height)
    dc.delete

  self.wEvent_Size do (event: wEvent):
    self.drawBoard()

  self.wEvent_LeftDown do (event: wEvent):
    if not mUseAi[mGame.getNextPlayer]:
      let pos = event.getMousePos()
      let xx: float = (pos.x - 37) / 50
      let yy: float = (pos.y - 37) / 50
      let px = xx - xx.int.float
      let py = yy - yy.int.float
      let x = int xx + 1
      let y = int yy + 1

      if px > 0.1 and px < 0.9 and py > 0.1 and py < 0.9 and x in 1..8 and y in 1..8:
        let move = Move(x * 10 + y)

        if mGame.play(move):
          self.drawBoard()

          if not mGame.isFinish():
            self.tryStartAi()

  self.wEvent_Timer do (event: wEvent):
    if mGame.aiReady():
      self.stopTimer()
      mGame.aiPlay()
      self.drawBoard()

      if not mGame.isFinish():
        self.tryStartAi()

proc Board(title: string): wBoard {.inline.} =
  new(result, final)
  result.init(title)

let app = App()
let board = Board(title="wNim Reversi")

board.center()
board.show()
app.mainLoop()
