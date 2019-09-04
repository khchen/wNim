#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import resource/resource

when defined(aio):
  import wNim
else:
  import wNim/[wApp, wIcon, wFont, wCursor, wAcceleratorTable, wFrame, wPanel,
    wMenu, wMenuBar, wButton, wStatusBar, wStaticText, wTextEntryDialog, wFontDialog]

let app = App()
let frame = Frame(title="wNim Frame Demo")
frame.icon = Icon("", 0) # load icon from exe file.

frame.dpiAutoScale:
  frame.minSize = (300, 200)
  frame.size = (350, 200)

let menuBar = MenuBar(frame)
let statusBar = StatusBar(frame)

let menu = Menu(menuBar, "&File")
menu.append(wIdExit, "E&xit\tAlt-F4", "Close window and exit program.")

let accel = AcceleratorTable(frame)
accel.add(wAccelAlt, wKey_F4, wIdExit)

let panel = Panel(frame)
let staticText = StaticText(panel, label="Hello, World!")
staticText.font = Font(14, family=wFontFamilySwiss, weight=wFontWeightBold)
staticText.cursor = wHandCursor
staticText.fit()

let button = Button(panel, label="Font")

proc layout() =
  panel.autolayout """
    HV:|-[staticText]->[button]-|
  """

staticText.wEvent_CommandLeftClick do ():
  let textEntryDialog = TextEntryDialog(frame, value=staticText.label,
    caption="Change The Text")

  if textEntryDialog.showModal() == wIdOk:
    staticText.label = textEntryDialog.value
    staticText.fit()
    staticText.refresh()

button.wEvent_Button do ():
  let fontDialog = FontDialog(frame, staticText.font)
  fontDialog.color = staticText.foregroundColor
  fontDialog.enableSymbols(false)
  fontDialog.range = 0..24

  if fontDialog.showModal() == wIdOk:
    staticText.font = fontDialog.chosenFont
    staticText.foregroundColor = fontDialog.color
    staticText.fit()
    staticText.refresh()

frame.wIdExit do ():
  frame.close()

panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()
