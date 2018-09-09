#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

{.passL: "wNim.res".}
import strformat
import ../wNim

type
  MenuID = enum
    idText = wIdUser, idFile, idImage, idCopy, idPaste, idExit

const defaultText = "You can drop text, image, or files on drop target."
const defaultFile = ["dragdrop.exe"]
const defaultImage = staticRead(r"images\logo.png")

var app = App()
var data = DataObject(defaultText)

var frame = Frame(title="wNim Drag-Drop Demo", style=wCaption or wSystemMenu or
  wMinimizeBox or wModalFrame)

frame.setIcon(Icon("", 0))

var statusBar = StatusBar(frame)
var menuBar = MenuBar(frame)
var panel = Panel(frame)
panel.margin = 20

var menu = Menu(menuBar, "&File")
menu.append(idText, "Load &Text", "Loads default text as current data.")
menu.append(idFile, "Load &File", "Loads exefile as current data.")
menu.append(idImage, "Load &Image", "Loads default image as current data.")
menu.appendSeparator()
menu.append(idCopy, "&Copy\tCtrl+C", "Copy current data to clipboard.")
menu.append(idPaste, "&Paste\tCtrl+V", "Paste data from clipboard.")
menu.appendSeparator()
menu.append(idExit, "E&xit", "Exit the program.")

var accel = AcceleratorTable()
accel.add(wAccelCtrl, wKey_C, idCopy)
accel.add(wAccelCtrl, wKey_V, idPaste)
frame.acceleratorTable = accel

var target = StaticText(panel, label="Drop Target", size=(100, 100),
  style=wBorderStatic or wAlignCentre or wAlignMiddle)
target.setDropTarget()

var source = StaticText(panel, label="Drag Source", size=(100, 100), pos=(0, 120),
  style=wBorderStatic or wAlignCentre or wAlignMiddle)

var dataText = TextCtrl(panel, size=(400, 220), pos=(120, 0),
  style=wInvisible or wBorderStatic or wTeMultiLine or wTeReadOnly or
  wTeRich or wTeDontWrap)

var dataList = ListBox(panel, size=(400, 220), pos=(120, 0),
  style=wInvisible or wLbNoSel or wLbNeededScroll)

var dataBitmap = StaticBitmap(panel, size=(400, 220), pos=(120, 0),
  style=wInvisible or wSbFit)


proc displayData() =
  if data.isText():
    let text = data.getText()
    dataText.setLabel(text)
    statusBar.setStatusText(fmt"Got {text.len} characters.")

    dataText.show()
    dataList.hide()
    dataBitmap.hide()

  elif data.isFiles():
    dataList.clear()
    for file in data.getFiles():
      dataList.append(file)
    statusBar.setStatusText(fmt"Got {dataList.len} files.")

    dataList.show()
    dataText.hide()
    dataBitmap.hide()

  elif data.isBitmap():
    let bmp = data.getBitmap()
    dataBitmap.setBitmap(bmp)
    statusBar.setStatusText(fmt"Got a {bmp.width}x{bmp.height} image.")

    dataBitmap.show()
    dataList.hide()
    dataText.hide()

displayData()

source.wEvent_MouseMove do (event: wEvent):
  if event.leftDown():
    data.doDragDrop()

target.wEvent_DragEnter do (event: wEvent):
  var dataObject = event.getDataObject()
  if dataObject.isText() or dataObject.isFiles() or dataObject.isBitmap():
    event.setEffect(wDragCopy)
  else:
    event.setEffect(wDragNone)

target.wEvent_DragOver do (event: wEvent):
  if event.getEffect() != wDragNone:
    if event.ctrlDown:
      event.setEffect(wDragMove)
    else:
      event.setEffect(wDragCopy)

target.wEvent_Drop do (event: wEvent):
  var dataObject = event.getDataObject()
  if dataObject.isText() or dataObject.isFiles() or dataObject.isBitmap():
    # use copy constructor to copy the data.
    data = DataObject(dataObject)
    displayData()
  else:
    event.setEffect(wDragNone)

frame.idExit do ():
  delete frame

frame.idText do ():
  data = DataObject(defaultText)
  displayData()

frame.idFile do ():
  data = DataObject(defaultFile)
  displayData()

frame.idImage do ():
  data = DataObject(Bmp(defaultImage))
  displayData()

frame.idCopy do ():
  wSetClipboard(data)
  if data.isText():
    statusBar.setStatusText(fmt"Copied {data.getText().len} characters.")

  elif data.isFiles():
    statusBar.setStatusText(fmt"Copied {data.getFiles().len} files.")

  elif data.isBitmap():
    let bmp = data.getBitmap()
    statusBar.setStatusText(fmt"Copied a {bmp.width}x{bmp.height} image.")

frame.idPaste do ():
  data = wGetClipboard()
  displayData()

frame.clientSize = (560, 260)
frame.center()
frame.show()
app.mainLoop()

