#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

when compileOption("threads"):
  import threadpool

import
  resource/resource,  os,
  strutils, math, strformat,
  wNim

const
  border = 20

type
  PreviewFrameMenuID = enum
    idPrev = wIdUser, idNext, idReset, wIdPreviewFrameUser

  Quality = enum
    qHigh, qNormal, qLow

  DataKind = enum
    dkNil, dkText, dkImage

  Data = object
    case kind: DataKind
    of dkText:
      lines: seq[string]
      lineHeight: int
      linesPerPage: int

    of dkImage:
      image: wImage

    else: discard

  PrintInfo = object
    bitmapSize: wSize           # real bitmap size to draw the preview, in pixel
    areaSize: wSize             # printable area size to set up clip region, in pixel
    x: int                      # left margin, aka. x to start draw preview, in pixel
    y: int                      # top margin, aka. y to start draw preview, in pixel
    printScaleX: float          # scaleX for printer DC
    printScaleY: float          # scaleY for printer DC
    printData: wPrintData
    margin: wDirection
    font: wFont
    data: Data
    filename: string

  wPreviewFrame = ref object of wFrame
    mMain: wPanel
    mCanvas: wPanel
    mSlider: wSlider
    mSliderText: wStaticText
    mPageNoText: wStaticText
    mPrintText: wStaticText
    mCancel: wButton
    mInfo: PrintInfo
    mPages: seq[wPanel]
    mBitmaps: seq[wBitmap]
    mQuality: Quality
    mIsDelay: bool
    mIsCancelPtr: ptr bool

proc drawTextPage(dc: wDC, info: PrintInfo, nPage: int) =
  assert info.data.kind == dkText

  var (x, y) = (info.x, info.y)
  for i in nPage * info.data.linesPerPage ..< (nPage + 1) * info.data.linesPerPage:
    if i < info.data.lines.len:
      dc.drawText(info.data.lines[i], x, y)
      y += info.data.lineHeight

proc drawImagePage(dc: wDC, info: PrintInfo) =
  assert info.data.kind == dkImage

  let size = info.data.image.size
  var newWidth = info.areaSize.width
  var newHeight = int(newWidth.float * size.height.float / size.width.float)

  if newHeight > info.areaSize.height:
    newHeight = info.areaSize.height
    newWidth = int(newHeight.float * size.width.float / size.height.float)

  let x = info.x + (info.areaSize.width - newWidth) div 2
  let y = info.y + (info.areaSize.height - newHeight) div 2

  let newImage = info.data.image.scale(newWidth, newHeight, wImageQualityBicubic)
  dc.drawImage(newImage, x, y)

proc pageShown(self: wPreviewFrame): tuple[min, max: int] =
  result.min = int.high
  result.max = 0
  let mainHeight = self.mMain.size.height

  for i, page in self.mPages:
    let top = page.position.y + self.mCanvas.position.y
    let bottom = top + page.size.height

    if top in 1..<mainHeight or bottom in 1..<mainHeight or
        (top <= 0 and bottom >= mainHeight):
      let n = i + 1
      if n > result.max: result.max = n
      if n < result.min: result.min = n

  if result.max == 0: result.min = 0

proc pageNoUpdate(self: wPreviewFrame) =
  let (min, max) = self.pageShown()

  if max != 0:
    if min == max:
      self.mPageNoText.label = fmt"{min} of {self.mPages.len}"
    else:
      self.mPageNoText.label = fmt"{min}-{max} of {self.mPages.len}"

  else:
    self.mPageNoText.label = ""

proc pageLayout(self: wPreviewFrame) =
  let ratio = self.mSlider.value.float * 5 / 100
  let width = int(self.mInfo.bitmapSize.width.float * ratio)
  let height = int(self.mInfo.bitmapSize.height.float * ratio)

  var x, y = border
  for i in 0..<self.mPages.len:
    self.mPages[i].size = (x, y, width, height)
    y.inc height + border

proc canvasLayout(self: wPreviewFrame, x = wDefault, y = wDefault) =
  template main: untyped = self.mMain
  template canvas: untyped = self.mCanvas

  let pageCount = self.mPages.len
  if pageCount == 0:
    main.showScrollBar(wHorizontal, false)
    main.showScrollBar(wVertical, false)
    return

  let
    pageWidth = self.mPages[0].size.width
    pageHeight = self.mPages[0].size.height
    width = pageWidth + border * 2
    height = pageHeight * pageCount + border * (pageCount + 1)
    isHorizontal = main.size.width < width
    isVertical = main.size.height < height

  canvas.size = (width, height)
  main.showScrollBar(wHorizontal, isHorizontal)
  main.showScrollBar(wVertical, isVertical)

  if isHorizontal:
    var currentX = if x == wDefault: main.getScrollPos(wHorizontal) else: x
    # let hDiff = if isVertical: wGetSystemMetric(wSysVScrollX) else: 0

    # main.setScrollbar(wHorizontal, currentX, main.size.width - hDiff, width)
    main.setScrollbar(wHorizontal, currentX, pageWidth + border, width)
    currentX = main.getScrollPos(wHorizontal) # scrollpos chage after setScrollbar
    canvas.move(-currentX, wDefault)

  else:
    canvas.center(wHorizontal)

  if isVertical:
    var currentY = if y == wDefault: main.getScrollPos(wVertical) else: y
    # let vDiff = if isHorizontal: wGetSystemMetric(wSysHScrollY) else: 0

    # main.setScrollbar(wVertical, currentY, main.size.height - vDiff, height)
    main.setScrollbar(wVertical, currentY, pageHeight + border, height)
    currentY = main.getScrollPos(wVertical)
    canvas.move(wDefault, -currentY)

  else:
    canvas.move(wDefault, 0)

  self.pageNoUpdate()

proc infoDefault(self: wPreviewFrame) =
  template info: untyped = self.mInfo

  let ppi = ScreenDC().ppi
  let paperSize: wSize = (210, 297)

  info.margin = (25, 25, 25, 25)

  let right = int(info.margin.right.float / 10 / 2.54 * ppi.width.float)
  let bottom = int(info.margin.down.float / 10 / 2.54 * ppi.height.float)

  info.bitmapSize.width = int(paperSize.width.float / 10 / 2.54 * ppi.width.float)
  info.bitmapSize.height = int(paperSize.height.float / 10 / 2.54 * ppi.height.float)

  info.x = int(info.margin.left.float / 10 / 2.54 * ppi.width.float)
  info.y = int(info.margin.up.float / 10 / 2.54 * ppi.height.float)

  info.areaSize.width = info.bitmapSize.width - (info.x + right)
  info.areaSize.height = info.bitmapSize.height - (info.y + bottom)

proc infoUpdate(self: wPreviewFrame, printData: wPrintData = nil, psd: wPageSetupDialog = nil) =
  template info: untyped = self.mInfo

  let ppi = ScreenDC().ppi
  try:
    if printData != nil:
      info.printData = printData

    let printer = PrinterDC(info.printData)
    var paperSize = info.printData.paperSize

    if info.printData.orientation == wLandscape:
      (paperSize.width, paperSize.height) = (paperSize.height, paperSize.width)

    if psd != nil:
      info.margin = psd.margin

    let right = int(info.margin.right.float / 10 / 2.54 * ppi.width.float)
    let bottom = int(info.margin.down.float / 10 / 2.54 * ppi.height.float)

    info.bitmapSize.width = int(paperSize.width.float / 10 / 2.54 * ppi.width.float)
    info.bitmapSize.height = int(paperSize.height.float / 10 / 2.54 * ppi.height.float)

    info.x = int(info.margin.left.float / 10 / 2.54 * ppi.width.float)
    info.y = int(info.margin.up.float / 10 / 2.54 * ppi.height.float)

    info.printScaleX = printer.size.width.float / info.bitmapSize.width.float
    info.printScaleY = printer.size.height.float / info.bitmapSize.height.float

    info.areaSize.width = info.bitmapSize.width - (info.x + right)
    info.areaSize.height = info.bitmapSize.height - (info.y + bottom)

  except wError:
    discard

proc bitmapUpdate(self: wPreviewFrame, count: int) =
  template info: untyped = self.mInfo
  template bitmaps: untyped = self.mBitmaps

  var memDc = MemoryDC()
  memDc.font = info.font

  proc prepare(memDc: var wMemoryDC) =
    memDc.region = wNilRegion
    memDc.setBackground(wWhite)
    memDc.clear()
    memDc.region = Region((info.x, info.y), info.areaSize)

  case info.data.kind
  of dkText:
    bitmaps.setLen(count)
    for i in 0..<count:
      bitmaps[i] = Bmp(info.bitmapSize)
      memDc.selectObject(bitmaps[i])
      memDc.prepare()
      memDc.drawTextPage(info, i)

  of dkImage:
    bitmaps.setLen(count)
    bitmaps[0] = Bmp(info.bitmapSize)
    memDc.selectObject(bitmaps[0])
    memDc.prepare()
    memDc.drawImagePage(info)

  else: discard

  memDc.selectObject(wNilBitmap)

proc pageUpdate(self: wPreviewFrame, count: int) =
  template bitmaps: untyped = self.mBitmaps
  template pages: untyped = self.mPages

  let ratio = self.mSlider.value.float * 5 / 100
  let w = int(self.mInfo.bitmapSize.width.float * ratio)
  let h = int(self.mInfo.bitmapSize.height.float * ratio)

  defer:
    self.pageLayout()
    self.mCanvas.refresh()

  if pages.len > count:
    for i in count..<pages.len:
      pages[i].delete()

    pages.setLen(count)

  elif count > pages.len:
    let oldLen = pages.len
    pages.setLen(count)

    for i in oldLen..<count:
      closureScope:
        let nPage = i
        pages[i] = Panel(self.mCanvas, size=(w, h), pos=(border, nPage * (h + border) + border))
        pages[i].backgroundColor = wWhite

        pages[i].wEvent_Paint do (event: wEvent):
          if bitmaps[nPage] == nil: return

          var dc = PaintDC(event.window)
          let size = dc.size

          case self.mQuality
          of qHigh:
            dc.drawImage(Image(bitmaps[nPage]).scale(size, wImageQualityBicubic))

          of qNormal, qLow:
            var memDc = MemoryDC()
            memDc.selectObject(bitmaps[nPage])

            let stretch =
              if self.mQuality == qNormal: stretchBlitQuality
              else: stretchBlit

            dc.stretch(0, 0, size.width, size.height, memDc, 0, 0,
              bitmaps[nPage].size.width, bitmaps[nPage].size.height)

            memDc.selectObject(wNilBitmap)

proc textMetricsUpdate(self: wPreviewFrame): int =
  template info: untyped = self.mInfo

  var bmp = Bmp(info.bitmapSize)
  var memDc = MemoryDC()
  memDc.font = info.font
  memDc.selectObject(bmp)

  info.data.lineHeight = memDc.charHeight
  info.data.linesPerPage = int floor(info.areaSize.height.float / info.data.lineHeight.float)

  result = info.data.lines.len div info.data.linesPerPage
  if info.data.lines.len mod info.data.linesPerPage > 0: result.inc

proc update(self: wPreviewFrame) =
  case self.mInfo.data.kind
  of dkText:
    let count = self.textMetricsUpdate()
    self.bitmapUpdate(count)
    self.pageUpdate(count)
    self.canvasLayout()
  of dkImage:
    self.bitmapUpdate(1)
    self.pageUpdate(1)
    self.canvasLayout()
  else: discard

proc load(self: wPreviewFrame, text: string) =
  self.mInfo.data = Data(kind: dkText)
  self.mInfo.data.lines = text.splitLines()
  self.update()

proc load(self: wPreviewFrame, image: wImage) =
  self.mInfo.data = Data(kind: dkImage)
  self.mInfo.data.image = image
  self.update()

proc loadFile(self: wPreviewFrame, filename: string) =
  try:
    let image = Image(filename)
    self.load(image)
    self.mInfo.filename = filename

  except:
    try:
      let text = readFile(filename)
      self.load(text)
      self.mInfo.filename = filename

    except: discard

proc PageSetupDialog(self: wPreviewFrame): wPageSetupDialog =
  result = PageSetupDialog(self, self.mInfo.printData)
  result.margin = self.mInfo.margin

proc PrintDialog(self: wPreviewFrame): wPrintDialog =
  result = PrintDialog(self, self.mInfo.printData)
  result.enableSelection(false)
  result.enableCurrentPage(false)
  result.enablePageRanges(true)
  result.minMaxPage = 1..self.mPages.len

proc setup(self: wPreviewFrame, psd: wPageSetupDialog) =
  self.infoUpdate(psd.printData, psd)
  self.update()

proc setup(self: wPreviewFrame, pd: wPrintDialog) =
  self.infoUpdate(pd.printData)
  self.update()

proc setScale(self: wPreviewFrame, scale: range[4..40]) =
  self.mSlidertext.label = $(scale * 5) & "%"
  self.mSlider.value = scale
  self.pageLayout()
  self.canvasLayout()

proc setQuality(self: wPreviewFrame, quality: Quality) =
  self.mQuality = quality
  self.mCanvas.refresh()

proc setFont(self: wPreviewFrame, font: wFont) =
  self.mInfo.font = font
  self.update()

proc getFont(self: wPreviewFrame): wFont =
  result = self.mInfo.font

proc print(self: wPreviewFrame, pd: wPrintDialog, delay: bool) {.thread.} =
  template info: untyped = self.mInfo

  if info.data.kind == dkNil: return

  # If run in another thread, must call App() to create a new wApp object.
  App()

  var ranges = pd.pageRanges
  if ranges.len == 0:
    ranges = @[1..self.mPages.len]

  var printer = PrinterDC(pd.printData)
  let x = int(info.x.float * info.printScaleX)
  let y = int(info.y.float * info.printScaleY)
  let width = int(info.areaSize.width.float * info.printScaleX)
  let height = int(info.areaSize.height.float * info.printScaleY)

  printer.setScale(info.printScaleX, info.printScaleX)
  printer.font = info.font

  if printer.startDoc(info.filename):
    self.mIsCancelPtr[] = false
    self.mPrintText.show()
    self.mCancel.show()

    defer:
      if self.mIsCancelPtr[]:
        printer.abortDoc()
      else:
        printer.endDoc()

      self.mPrintText.hide()
      self.mCancel.hide()

    for r in ranges:
      for i in r:
        if self.mIsCancelPtr[]: return

        self.mPrintText.label = fmt" Printing page {i}..."
        printer.startPage()
        if delay: os.sleep(1000)

        defer:
          printer.endPage()

        printer.region = Region(x, y, width, height)

        if info.data.kind == dkText:
          printer.drawTextPage(info, i - 1)

        else:
          printer.drawImagePage(info)

proc final(self: wPreviewFrame) =
  wFrame(self).final()

proc init(self: wPreviewFrame, title: string, size: wSize = (1024, 768)) =
  wFrame(self).init(title=title, size=size)
  self.setIcon(Icon("", 0))
  self.minSize = (640, 480)

  StatusBar(self)
  self.statusBar.minHeight = 30
  self.mMain = Panel(self, style=wDoubleBuffered)
  self.mCanvas = Panel(self.mMain)
  self.mSlider = Slider(self.statusBar)
  self.mSliderText = StaticText(self.statusBar, label="100%", style=wAlignMiddle)
  self.mPageNoText = StaticText(self.statusBar, label="999-999 of 999", style=wAlignMiddle or wAlignRight)
  self.mPrintText = StaticText(self.statusBar, label=" Printing page 999...", style=wAlignMiddle)
  self.mCancel = Button(self.statusBar, label="Cancel")
  self.mIsCancelPtr = createShared(bool)

  let panelColor = self.mMain.backgroundColor
  self.mMain.backgroundColor = self.backgroundColor
  self.mCanvas.backgroundColor = self.backgroundColor
  self.mSlider.backgroundColor = panelColor
  self.mSliderText.backgroundColor = panelColor
  self.mPageNoText.backgroundColor = panelColor
  self.mPrintText.backgroundColor = panelColor

  self.mSlider.disableFocus()
  self.mSlider.range = 4..40 # 20~100 / 5
  self.mSlider.value = 20 # 100 / 5
  self.mCancel.hide()
  self.mPrintText.hide()

  let toolbar = ToolBar(self.statusBar, style=wTbDefaultStyle or wTbNoDivider or wTbNoAlign or wTbNoResize)
  let imgPrev = Image(Icon("shell32.dll,137", (24, 24))).scale(24, 24)
  let imgNext = Image(Icon("shell32.dll,137", (24, 24))).scale(24, 24)
  let imgReset = Image(Icon("shell32.dll,22", (24, 24))).scale(24, 24)
  imgPrev.rotateFlip(wImageRotateNoneFlipX)

  toolbar.addTool(idReset, "", Bmp(imgReset), longHelp="100%")
  toolbar.addTool(idPrev, "", Bmp(imgPrev), longHelp="Previous page")
  toolbar.addTool(idNext, "", Bmp(imgNext), longHelp="Next page")

  defer:
    self.mIsDelay = false
    self.mQuality = qNormal
    self.mInfo.font = Font(12, faceName="Consolas")
    self.setScale(9)
    self.pageNoUpdate()

    try:
      let psd = PageSetupDialog(self, initDefault=true)
      self.infoUpdate(psd.printData, psd)

    except wError: # if ther is no printer
      self.infoDefault()

  self.statusBar.wEvent_Size do ():
    let
      statusBar = self.statusBar
      slider = self.mSlider
      pageNoText = self.mPageNoText
      sliderText = self.mSliderText
      printText = self.mPrintText
      cancel = self.mCancel

    statusBar.autolayout """
      H:|[printText][cancel]->[pageNoText]-[slider(150)][sliderText]-[toolbar(90)]-30-|
      V:|-2-[cancel,printText,pageNoText,slider,sliderText,toolbar]-2-|
    """

  self.mMain.wEvent_Size do ():
    self.canvasLayout()

  self.mMain.wEvent_ScrollWin do (event: wEvent):
    template main: untyped = self.mMain
    template canvas: untyped = self.mCanvas
    template orientation: untyped = event.orientation

    case event.kind
    of wEvent_ScrollWinLineUp:
      main.setScrollPos(orientation, main.getScrollPos(orientation) - border)

    of wEvent_ScrollWinLineDown:
      main.setScrollPos(orientation, main.getScrollPos(orientation) + border)

    else: discard

    case orientation:
    of wHorizontal:
      canvas.move(-main.getScrollPos(wHorizontal), wDefault)

    of wVertical:
      canvas.move(wDefault, -main.getScrollPos(wVertical))

    else: discard

    self.pageNoUpdate()

  self.mMain.wEvent_MouseWheel do (event: wEvent):
    template main: untyped = self.mMain
    template canvas: untyped = self.mCanvas
    template slider: untyped = self.mSlider

    if event.ctrlDown:
      if event.wheelRotation < 0 and slider.value > 4:
        self.setScale(slider.value - 1)

      elif event.wheelRotation > 0 and slider.value < 40:
        self.setScale(slider.value + 1)

    elif self.mPages.len != 0:
      if main.hasScrollbar(wVertical):
        if event.wheelRotation < 0:
          if event.altDown: main.scrollPages(1)
          else: main.scrollLines(3)

        else:
          if event.altDown: main.scrollPages(-1)
          else: main.scrollLines(-3)

        canvas.move(wDefault, -main.getScrollPos(wVertical))

  self.mSlider.wEvent_Slider do (event: wEvent):
    self.setScale(event.scrollPos)

  self.mCancel.wEvent_Button do ():
    self.mIsCancelPtr[] = true
    self.mPrintText.label = " Canceling..."
    self.mCancel.hide()

  self.idReset do ():
    self.setScale(20)

  self.idNext do ():
    var (min, max) = self.pageShown()
    if max != 0:
      let i = if min == max: max else: max - 1
      if i < self.mPages.len:
        self.canvasLayout(y = self.mPages[i].position.y - border)

  self.idPrev do ():
    var (i, _) = self.pageShown()
    if i != 0:
      i.dec
      if self.mPages[i].position.y + self.mCanvas.position.y >= border: i.dec

      if i >= 0:
        self.canvasLayout(y = self.mPages[i].position.y - border)

proc PreviewFrame(title: string, size: wSize = (1024, 768)): wPreviewFrame {.inline.} =
  new(result, final)
  result.init(title, size)


when isMainModule:

  type
    # A menu ID in wNim is type of wCommandID (distinct int) or any enum type.
    MenuID = enum
      idOpen = wIdPreviewFrameUser, idPrint, idSetup, idFont, idExit, idDelay
      idHigh, idNormal, idLow

  let app = App()
  let frame = PreviewFrame(title="Print and Preview Demo")
  let menuBar = MenuBar(frame)

  let menuFile = Menu(menuBar, "&File")
  menuFile.append(idOpen, "&Open\tCtrl + O", "Open a file")
  menuFile.append(idPrint, "Print\tCtrl + P", "Print the file")
  menuFile.append(idSetup, "Page Setup", "Setup the page")
  menuFile.append(idFont, "Font Setup", "Setup the font")
  menuFile.appendSeparator()
  menuFile.append(idExit, "E&xit\tAlt + F4", "Exit the program")

  let menuQuality = Menu(menuBar, "&Quality")
  menuQuality.appendRadioItem(idHigh, "&High")
  menuQuality.appendRadioItem(idNormal, "&Normal").check()
  menuQuality.appendRadioItem(idLow, "&Low")

  frame.idOpen do ():
    let files = FileDialog(frame, style=wFdOpen or wFdFileMustExist).display()
    if files.len > 0:
      frame.loadFile(files[0])

  frame.idFont do ():
    let fontDialog = FontDialog(frame, frame.getFont())
    fontDialog.enableApply()

    fontDialog.wEvent_DialogApply do ():
      frame.setFont(fontDialog.chosenFont)

    if fontDialog.showModal() == wIdOk:
      frame.setFont(fontDialog.chosenFont)

  frame.idSetup do ():
    let psd = PageSetupDialog(frame)
    if psd.showModal() == wIdOk:
      frame.setup(psd)

  frame.idPrint do ():
    let pd = PrintDialog(frame)
    case pd.showModal()
    of wIdApply:
      frame.setup(pd)

    of wIdOk:
      when compileOption("threads"):
        case MessageDialog(frame, "Delay between each page to test cancel ?",
          "Print and Preview Demo", wIconQuestion or wYesNo or wButton2Default).display()

        of wIdYes:
          spawn frame.print(pd, true)

        of wIdNo:
          spawn frame.print(pd, false)

        else: discard

      else:
        frame.print(pd, false)

    else: discard

  frame.idExit do ():
    frame.close()

  frame.idHigh do (): frame.setQuality(qHigh)
  frame.idNormal do (): frame.setQuality(qNormal)
  frame.idLow do (): frame.setQuality(qLow)

  var accel = AcceleratorTable()
  accel.add(wAccelCtrl, wKey_O, idOpen)
  accel.add(wAccelCtrl, wKey_P, idPrint)
  frame.acceleratorTable = accel

  # frame.loadFile("printpreview.nim")

  frame.center()
  frame.show()

  when not compileOption("threads"):
    MessageDialog(frame, "This demo can be compiled with the --threads:on command line switch",
      "Print and Preview Demo", wIconInformation).display()

  app.mainLoop()
