#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim

let app = App()
let frame = Frame(title="Hello World", size=(350, 200))
frame.icon = Icon("", 0) # load icon from exe file.
frame.minSize = (300, 200)

let menuBar = MenuBar(frame)
let statusBar = StatusBar(frame)

let menu = Menu(menuBar, "&File")
menu.append(wIdExit, "E&xit\tAlt-F4", "Close window and exit program.")

let accel = AcceleratorTable(frame)
accel.add(wAccelAlt, wKey_F4, wIdExit)

let panel = Panel(frame)
let staticText = StaticText(panel, label="Hello World!")
staticText.font = Font(14, family=wFontFamilySwiss, weight=wFontWeightBold)
staticText.cursor = wHandCursor
staticText.fit()

let button = Button(panel, label="Font")

proc layout() =
  panel.autolayout """
    HV:|-[staticText]->[button]-|
  """

staticText.wEvent_CommandLeftClick do ():
  let textEnterDialog = TextEnterDialog(frame, value=staticText.label,
    caption="Change The Text")

  if textEnterDialog.showModal() == wIdOk:
    staticText.label = textEnterDialog.value
    staticText.fit()
    staticText.refresh()

button.wEvent_Button do ():
  let fontDialog = FontDialog(frame, staticText.font,
    color=staticText.foregroundColor, allowSymbols=false, range=0..24)

  if fontDialog.showModal() == wIdOk:
    staticText.font = fontDialog.chosenFont
    staticText.foregroundColor = fontDialog.color
    staticText.fit()
    staticText.refresh()

frame.wIdExit do ():
  frame.close()

frame.wEvent_Size do ():
  layout()

frame.center()
frame.show()
app.mainLoop()
