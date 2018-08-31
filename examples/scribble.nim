{.this: self.}
import wNim

type
  wScribble = ref object of wFrame
    mMemDc: wMemoryDC
    mPen: wPen
    mLastPos: wPoint

proc final(self: wScribble) =
  wFrame(self).final()

proc init(self: wScribble, title: string, size: wSize) =
  wFrame(self).init(title=title, size=size)

  mPen = Pen(color=wBlack, width=5)
  mMemDc = MemoryDC()
  mMemDc.selectObject(Bmp(wGetScreenSize()))
  mMemDc.setBackground(wWhiteBrush)
  mMemDc.setBrush(wWhiteBrush)
  mMemDc.setPen(mPen)
  mMemDc.clear()
  mLastPos = wDefaultPoint

  const penResource = staticRead(r"images\3.png")
  let penImage = Image(penResource)
  penImage.rescale(24, 24)
  penImage.rotateFlip(wImageRotateNoneFlipY)
  setCursor(Cursor(penImage, hotSpot=(0, 0)))

  connect(wEvent_Paint) do ():
    var dc = PaintDC(self)
    let size = dc.size
    dc.blit(source=mMemDc, width=size.width, height=size.height)
    # In case that nim's destructors not works.
    dc.delete

  proc onLeftDown(event: wEvent) =
    let pos = event.mousePos()
    mMemDc.drawLine(if mLastPos == wDefaultPoint: pos else: mLastPos, pos)
    self.refresh(eraseBackground=false)
    mLastPos = pos

  proc onRightDown(event: wEvent) =
    let pos = event.mousePos()
    mMemDc.setPen(wTransparentPen)
    mMemDc.drawCircle(pos, 30)
    mMemDc.setPen(mPen)
    self.refresh(eraseBackground=false)

  connect(wEvent_LeftDown, onLeftDown)
  connect(wEvent_RightDown, onRightDown)
  connect(wEvent_MouseLeave) do (): mLastPos = wDefaultPoint
  connect(wEvent_LeftUp) do (): mLastPos = wDefaultPoint
  connect(wEvent_MouseMove) do (event: wEvent):
    if event.leftDown(): onLeftDown(event)
    elif event.rightDown(): onRightDown(event)

proc Scribble(title: string, size: wSize): wScribble {.inline.} =
  new(result, final)
  result.init(title, size)

proc clear(self: wScribble) =
  mMemDc.clear()
  refresh(eraseBackground=false)

proc setColor(self: wScribble, color: wColor) =
  mPen.setColor(color)
  mMemDc.setPen(mPen)

proc setWidth(self: wScribble, width: int) =
  mPen.setWidth(width)
  mMemDc.setPen(mPen)

when isMainModule:
  type
    MenuId = enum
      idNew = 100, idExit, idAbout, idOther
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
