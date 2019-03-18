#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  ../resource/resource,
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
  panel.autolayout """
    spacing: 10
    H:|[staticbox1(staticbox2)]-20-[staticbox2]|
    V:|[staticbox1..2]|

    outer: staticbox1
    H:|[button1..3]|
    V:|[button1(button2,button3)]-[button2]-[button3]|

    outer: staticbox2
    H:|[button4..5]|
    V:|[button4(button5)]-[button5]|
  """

  staticbox3.contain(staticbox1, staticbox2)

frame.wEvent_Size do (): layout()
frame.center()
frame.show()
app.mainLoop()
