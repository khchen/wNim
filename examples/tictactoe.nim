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
  mcts/[gamebase, engine_tictactoe]

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
  if self.mGame.isFinish():
    case self.mGame.getWinner()
    of P1:
      self.statusBar.setStatusText("O wins.")
    of P2:
      self.statusBar.setStatusText("X wins.")
    else:
      self.statusBar.setStatusText("Draw game.")

  elif self.mGame.getRounds() != 0:
    let msg = fmt"{self.mGame.getRounds()} rounds, rate: {self.mGame.getRate():.4f}"
    self.statusBar.setStatusText(msg)

proc tryStartAi(self: wBoard) =
  if not self.mGame.isFinish():
    if self.mUseAi[self.mGame.getNextPlayer()]:
      self.mGame.aiStart(0.2)
      self.startTimer(0.1)

proc drawBoard(self: wBoard) =
  let size = self.clientSize
  self.mMemDc.clear()
  self.mMemDc.drawImage(self.mBoard.scale(size))

  let pieceSize: wSize = (size.width div 4, size.height div 4)
  var offset: wPoint
  offset.x = (size.width div 3 - pieceSize.width) div 2
  offset.y = (size.height div 3 - pieceSize.height) div 2

  var board = self.mGame.getBoard()
  for i in 0..2:
    for j in 0..2:
      let piece = board[i * 3 + j]
      if piece != NONE:
        var img = if piece == P1: self.mPiece1 else: self.mPiece2
        img = img.scale(pieceSize)

        var pos: wPoint
        pos.x = size.width div 3 * i + offset.x
        pos.y = size.height div 3 * j + offset.y
        self.mMemDc.drawImage(img, pos)

  self.refresh(eraseBackground=false)
  self.information()

proc final(self: wBoard) =
  wFrame(self).final()

proc init(self: wBoard, title: string) =
  wFrame(self).init(title=title,
    style=wCaption or wSystemMenu or wMinimizeBox or wModalFrame or wResizeBorder)

  const boardImg = staticRead(r"images\board1.png")
  const piece1Img = staticRead(r"images\o.png")
  const piece2Img = staticRead(r"images\x.png")
  self.mBoard = Image(boardImg)
  self.mPiece1 = Image(piece1Img)
  self.mPiece2 = Image(piece2Img)

  randomize()
  self.mGame = newGame[State]()
  self.mUseAi[P2] = true

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

  self.mMemDc = MemoryDC()
  self.mMemDc.selectObject(Bmp(wGetScreenSize()))
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

  self.wEvent_Paint do ():
    var dc = PaintDC(self)
    let size = dc.size
    dc.blit(source=self.mMemDc, width=size.width, height=size.height)
    dc.delete

  self.wEvent_Size do (event: wEvent):
    self.drawBoard()

  self.wEvent_LeftDown do (event: wEvent):
    if not self.mUseAi[self.mGame.getNextPlayer]:
      let size = self.clientSize
      let pos = event.getMousePos()
      let x = pos.x div (size.width div 3)
      let y = pos.y div (size.height div 3)
      let move = x * 3 + y

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
let board = Board(title="wNim Tic-Tac-Toe")

board.center()
board.show()
app.mainLoop()
