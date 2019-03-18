#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim,
  strformat

type
  MenuID = enum
    idText = wIdUser, idFile, idImage, idCopy, idPaste, idExit

const defaultText = "You can drop text, image, or files on drop target."
const defaultFile = ["dragdrop.exe"]
const defaultImage = staticRead(r"images\logo.png")

var app = App()
var data = DataObject(defaultText)

var frame = Frame(title="wNim Drag-Drop Demo", size=(600, 350),
  style=wDefaultFrameStyle or wDoubleBuffered)
frame.icon = Icon("", 0) # load icon from exe file.

var statusBar = StatusBar(frame)
var menuBar = MenuBar(frame)
var panel = Panel(frame)

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

var target = StaticText(panel, label="Drop Target",
  style=wBorderStatic or wAlignCentre or wAlignMiddle)
target.setDropTarget()

var source = StaticText(panel, label="Drag Source",
  style=wBorderStatic or wAlignCentre or wAlignMiddle)

var dataText = TextCtrl(panel,
  style=wInvisible or wBorderStatic or wTeMultiLine or wTeReadOnly or
  wTeRich or wTeDontWrap)

var dataList = ListBox(panel,
  style=wInvisible or wLbNoSel or wLbNeededScroll)

var dataBitmap = StaticBitmap(panel,
  style=wInvisible or wSbFit)

proc layout() =
  panel.autolayout """
    spacing: 20
    H:|-[target,source(100)]-[dataText,dataList,dataBitmap]-|
    V:|-[target]-[source(target)]-|
    V:|-[dataText,dataList,dataBitmap]-|
  """

proc displayData() =
  if data.isText():
    let text = data.getText()
    dataText.setValue(text)
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

frame.wEvent_Size do ():
  layout()

layout()
displayData()
frame.center()
frame.show()
app.mainLoop()
