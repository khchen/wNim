#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim,
  strutils

type
  wScribble = ref object of wFrame
    mMemDc: wMemoryDC
    mPen: wPen
    mLastPos: wPoint
    mBmp: wBitmap

proc final(self: wScribble) =
  wFrame(self).final()

proc init(self: wScribble, title: string, size: wSize) =
  wFrame(self).init(title=title, size=size)
  self.setIcon(Icon("", 0))

  self.mPen = Pen(color=wBlack, width=5)
  self.mBmp = Bmp(wGetScreenSize())
  self.mMemDc = MemoryDC()
  self.mMemDc.selectObject(self.mBmp)
  self.mMemDc.setBackground(wWhiteBrush)
  self.mMemDc.setBrush(wWhiteBrush)
  self.mMemDc.setPen(self.mPen)
  self.mMemDc.clear()
  self.mLastPos = wDefaultPoint

  const penResource = staticRead(r"images\pen.png")
  let penImage = Image(penResource)
  penImage.rescale(24, 24)
  penImage.rotateFlip(wImageRotateNoneFlipY)
  self.setCursor(Cursor(penImage, hotSpot=(0, 0)))

  self.wEvent_Paint do ():
    var dc = PaintDC(self)
    let size = dc.size
    dc.blit(source=self.mMemDc, width=size.width, height=size.height)
    # In case that nim's destructors not works.
    dc.delete

  proc onLeftDown(event: wEvent) =
    let pos = event.mousePos()
    self.mMemDc.drawLine(if self.mLastPos == wDefaultPoint: pos else: self.mLastPos, pos)
    self.refresh(eraseBackground=false)
    self.mLastPos = pos

  proc onRightDown(event: wEvent) =
    let pos = event.mousePos()
    self.mMemDc.setPen(wTransparentPen)
    self.mMemDc.drawCircle(pos, 30)
    self.mMemDc.setPen(self.mPen)
    self.refresh(eraseBackground=false)

  self.connect(wEvent_LeftDown, onLeftDown)
  self.connect(wEvent_RightDown, onRightDown)

  self.wEvent_MouseLeave do (): self.mLastPos = wDefaultPoint
  self.wEvent_LeftUp do (): self.mLastPos = wDefaultPoint
  self.wEvent_MouseMove do (event: wEvent):
    if event.leftDown(): onLeftDown(event)
    elif event.rightDown(): onRightDown(event)

proc Scribble(title: string, size: wSize): wScribble {.inline.} =
  new(result, final)
  result.init(title, size)

proc clear(self: wScribble) =
  self.mMemDc.clear()
  self.refresh(eraseBackground=false)

proc setColor(self: wScribble, color: wColor) =
  self.mPen.setColor(color)
  self.mMemDc.setPen(self.mPen)

proc setWidth(self: wScribble, width: int) =
  self.mPen.setWidth(width)
  self.mMemDc.setPen(self.mPen)

proc loadFile(self: wScribble, filename: string) =
  var image = Image(filename)
  self.mMemDc.clear()
  self.mMemDc.drawImage(image)
  self.setClientSize(image.size)
  self.refresh(eraseBackground=false)

proc saveFile(self: wScribble, filename: string) =
  var size = self.getClientSize()
  var bmp = Bmp(size)
  var dc = self.ClientDC()
  var memdc = MemoryDC()
  memdc.selectObject(bmp)
  memdc.blit(0, 0, size.width, size.height, dc)
  memdc.selectObject(wNilBitmap)

  var image = Image(bmp)
  image.saveFile(filename)

when isMainModule:
  type
    MenuId = enum
      idNew = 100, idExit, idAbout, idOther, idLoad, idSave
      idBlack, idRed, idOrange, idYellow, idGreen, idBlue, idPurple
      idString, idThin, idNormal, idThick, idSuper

  const colorArray: array[idBlack..idPurple, wColor] =
    [wBlack, wRed, wOrange, wYellow, wGreen, wBlue, wPurple]

  const widthArray: array[idString..idSuper, int] =
    [1, 3, 7, 12, 180]

  let app = App()
  let scribble = Scribble(title="Scribble Demo", size=(400, 400))
  scribble.setColor(colorArray[idBlack])
  scribble.setWidth(widthArray[idNormal])
  var lastColorId = idBlack

  let statusBar = StatusBar(scribble)
  let menuBar = MenuBar(scribble)

  let menuFile = Menu(menuBar, "&File")
  menuFile.append(idNew, "&New")
  menuFile.append(idLoad, "&Load")
  menuFile.append(idSave, "&Save As...")
  menuFile.appendSeparator()
  menuFile.append(idExit, "E&xit", "Exit the program.")

  let menuColor = Menu(menuBar, "&Color")
  menuColor.appendRadioItem(idBlack, "Black").check()
  menuColor.appendRadioItem(idRed, "Red")
  menuColor.appendRadioItem(idOrange, "Orange")
  menuColor.appendRadioItem(idYellow, "Yellow")
  menuColor.appendRadioItem(idGreen, "Green")
  menuColor.appendRadioItem(idBlue, "Blue")
  menuColor.appendRadioItem(idPurple, "Purple")
  menuColor.appendRadioItem(idOther, "Other...")

  let menuWidth = Menu(menuBar, "&Width")
  menuWidth.appendRadioItem(idString, "String")
  menuWidth.appendRadioItem(idThin, "Thin")
  menuWidth.appendRadioItem(idNormal, "Normal").check()
  menuWidth.appendRadioItem(idThick, "Thick")
  menuWidth.appendRadioItem(idSuper, "Super !!")

  let menuAbout = Menu(menuBar, "&Help")
  menuAbout.append(idAbout, "&About...")

  scribble.idNew do ():
    scribble.clear()

  scribble.idExit do ():
    scribble.delete()

  scribble.idLoad do ():
    let wildcard = "PNG files (*.png)|*.png|BMP files (*.bmp)|*.bmp"
    let dlg = FileDialog(wildcard=wildcard, style=wFdOpen or wFdFileMustExist)
    if dlg.show() == wIdOk:
      try:
        scribble.loadFile(dlg.path)
        statusBar.setStatusText(dlg.path & " loaded.")
      except: discard

  scribble.idSave do ():
    let wildcard = "PNG files (*.png)|*.png|BMP files (*.bmp)|*.bmp"
    let dlg = FileDialog(wildcard=wildcard, style=wFdSave or wFdOverwritePrompt)
    if dlg.show() == wIdOk:
      var path = dlg.path
      if dlg.filterIndex == 1 and not path.toLowerAscii.endsWith(".png"):
        path.add ".png"
      elif dlg.filterIndex == 2 and not path.toLowerAscii.endsWith(".bmp"):
        path.add ".bmp"
      try:
        scribble.saveFile(path)
        statusBar.setStatusText(path & " saved.")
      except: discard

  scribble.idAbout do ():
    MessageDialog(scribble, caption="About...",
      message="Scribble, demo program for wNim",
      style=wOk or wIconInformation).show()

  scribble.idOther do ():
    let dlg = ColorDialog(scribble, colorArray[lastColorId],
        wCdCenter or wCdFullOpen)

    for i in 0..15:
      dlg.setCustomColor(i, wWhite)

    if dlg.show() == wIdOk:
      scribble.setColor(dlg.getColor())
    else:
      menuColor.check(lastColorId)

  scribble.wEvent_Menu do (event: wEvent):
    let menuId = MenuID event.id
    case menuId
    of idBlack..idPurple:
      scribble.setColor(colorArray[menuId])
      lastColorId = menuId

    of idString..idSuper:
      scribble.setWidth(widthArray[menuId])

    else:
      # skip to make sure not block the event if not processed
      event.skip()

  scribble.center()
  scribble.show()
  app.mainLoop()
