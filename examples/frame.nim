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

let button = Button(panel, label="Close")

proc layout() =
  panel.layout:
    staticText:
      top = panel.top + 10
      left = panel.left + 10
    button:
      right + 10 = panel.right
      bottom + 10 = panel.bottom

button.wEvent_Button do ():
  frame.delete()

frame.wIdExit do ():
  frame.delete()

frame.wEvent_Size do ():
  layout()

frame.center()
frame.show()
app.mainLoop()
