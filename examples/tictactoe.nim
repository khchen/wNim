#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

{.this: self.}

when defined(cpu64):
  {.link: "wNim64.res".}
else:
  {.link: "wNim32.res".}

import random, sets, strformat
import mcts/[gamebase, engine_tictactoe]
import wNim

type
  MenuId = enum idNew = 100, idExit, idAi1, idAi2
  wBoard = ref object of wFrame
    mGame: Game[State]
    mMemDc: wMemoryDC
    mBoard: wImage
    mPiece1: wImage
    mPiece2: wImage
    mUseAi: array[Player, bool]

proc information(self: wBoard) =
  if mGame.isFinish():
    case mGame.getWinner()
    of P1:
      self.statusBar.setStatusText("O wins.")
    of P2:
      self.statusBar.setStatusText("X wins.")
    else:
      self.statusBar.setStatusText("Draw game.")

  elif mGame.getRounds() != 0:
    let msg = fmt"{mGame.getRounds()} rounds, rate: {mGame.getRate():.4f}"
    self.statusBar.setStatusText(msg)

proc tryStartAi(self: wBoard) =
  if not mGame.isFinish():
    if mUseAi[mGame.getNextPlayer()]:
      mGame.aiStart(0.2)
      self.startTimer(0.1)

proc drawBoard(self: wBoard) =
  let size = self.clientSize
  mMemDc.clear()
  mMemDc.drawImage(mBoard.scale(size))

  let pieceSize: wSize = (size.width div 4, size.height div 4)
  var offset: wPoint
  offset.x = (size.width div 3 - pieceSize.width) div 2
  offset.y = (size.height div 3 - pieceSize.height) div 2

  var board = mGame.getBoard()
  for i in 0..2:
    for j in 0..2:
      let piece = board[i * 3 + j]
      if piece != NONE:
        var img = if piece == P1: mPiece1 else: mPiece2
        img = img.scale(pieceSize)

        var pos: wPoint
        pos.x = size.width div 3 * i + offset.x
        pos.y = size.height div 3 * j + offset.y
        mMemDc.drawImage(img, pos)

  refresh(eraseBackground=false)
  information()

proc final(self: wBoard) =
  wFrame(self).final()

proc init(self: wBoard, title: string) =
  wFrame(self).init(title=title,
    style=wCaption or wSystemMenu or wMinimizeBox or wModalFrame or wResizeBorder)

  const boardImg = staticRead(r"images\board1.png")
  const piece1Img = staticRead(r"images\o.png")
  const piece2Img = staticRead(r"images\x.png")
  mBoard = Image(boardImg)
  mPiece1 = Image(piece1Img)
  mPiece2 = Image(piece2Img)

  randomize()
  mGame = newGame[State]()
  mUseAi[P2] = true

  StatusBar(self)
  var menubar = MenuBar(self)
  var menu = Menu(menubar, "&Game")
  menu.append(idNew, "&New Game")
  menu.appendSeparator()
  menu.appendCheckItem(idAi1, "Computer Paly O")
  menu.appendCheckItem(idAi2, "Computer Paly X").check()
  menu.appendSeparator()
  menu.append(idExit, "E&xit")

  self.clientSize = (400, 400)
  self.icon = Icon("", 0)

  mMemDc = MemoryDC()
  mMemDc.selectObject(Bmp(wGetScreenSize()))
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

  self.wEvent_Paint do ():
    var dc = PaintDC(self)
    let size = dc.size
    dc.blit(source=mMemDc, width=size.width, height=size.height)
    dc.delete

  self.wEvent_Size do (event: wEvent):
    self.drawBoard()

  self.wEvent_LeftDown do (event: wEvent):
    if not mUseAi[mGame.getNextPlayer]:
      let size = self.clientSize
      let pos = event.getMousePos()
      let x = pos.x div (size.width div 3)
      let y = pos.y div (size.height div 3)
      let move = x * 3 + y

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
let board = Board(title="wNim Tic-Tac-Toe")

board.center()
board.show()
app.mainLoop()
