#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim

var app = App()
var frame = Frame(title="wNim Layout Example", size=(400, 300))
frame.icon = Icon("", 0) # load icon from exe file.

var statusbar = StatusBar(frame)
var panel = Panel(frame)
panel.margin = 40

var staticbox1 = StaticBox(panel, label="Static Box 1")
var staticbox2 = StaticBox(panel, label="Static Box 2")
var staticbox3 = StaticBox(panel, label="Static Box 3")
staticbox1.margin = 20
staticbox2.margin = 20
staticbox3.margin = 20

var button1 = Button(panel, label="Buton1")
var button2 = Button(panel, label="Buton2")
var button3 = Button(panel, label="Buton3")
var button4 = Button(panel, label="Buton4")
var button5 = Button(panel, label="Buton5")

proc layout() =
  panel.layout:
    staticbox1:
      left = panel.left
      right + 20 = staticbox2.left
      top = panel.top
      bottom = panel.bottom

    staticbox2:
      width = staticbox1.width
      right = panel.right
      top = panel.top
      bottom = panel.bottom

    button1:
      left = staticbox1.innerLeft
      right = staticbox1.innerRight
      top = staticbox1.innerTop
      bottom + 10 = button2.top

    button2:
      left = staticbox1.innerLeft
      right = staticbox1.innerRight
      height = button1.height
      bottom + 10 = button3.top

    button3:
      left = staticbox1.innerLeft
      right = staticbox1.innerRight
      height = button2.height
      bottom = staticbox1.innerBottom

    button4:
      left = staticbox2.innerLeft
      right = staticbox2.innerRight
      top = staticbox2.innerTop
      bottom + 10 = button5.top

    button5:
      left = staticbox2.innerLeft
      right = staticbox2.innerRight
      height = button4.height
      bottom = staticbox2.innerBottom

  staticbox3.contain(staticbox1, staticbox2)

frame.wEvent_Size do (): layout()
frame.center()
frame.show()
app.mainLoop()
