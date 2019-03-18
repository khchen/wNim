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

var button1 = Button(panel, label="Buton1")
var button2 = Button(panel, label="Buton2")
var button3 = Button(panel, label="Buton3")
var button4 = Button(panel, label="Buton4")
var button5 = Button(panel, label="Buton5")
var box = Resizable()

proc layout1() =
  panel.autolayout """
    spacing: 8
    H:|~[button1..5]~|
    V:|-[button1]-[button2]-[button3]-[button4]-[button5]
    H:[box(button1 + 8 * 2)]
    V:[box(button1 * 5 + 8 * 6)]
  """

  let boxSize = box.layoutSize
  frame.minClientSize = boxSize
  frame.maxClientSize = (wDefault, boxSize.height)

proc layout2() =
  panel.autolayout """
    spacing: 8
    V:|~[button1..5]~|
    H:|-[button1]-[button2]-[button3]-[button4]-[button5]
    V:[box(button1 + 8 * 2)]
    H:[box(button1 * 5 + 8 * 6)]
  """

  let boxSize = box.layoutSize
  frame.minClientSize = boxSize
  frame.maxClientSize = (boxSize.width, wDefault)

type
  MenuID = enum
    idLayout1 = 1000
    idLayout2
    idExit

var menuBar = MenuBar(frame)
var menu = Menu(menuBar, "Layout")
menu.appendRadioItem(idLayout1, "Vertical").check()
menu.appendRadioItem(idLayout2, "Horizontal")
menu.appendSeparator()
menu.append(idExit, "Exit")

frame.idLayout1 do (): layout1()
frame.idLayout2 do (): layout2()
frame.idExit do (): frame.delete()

frame.wEvent_Size do ():
  if menuBar.isChecked(idLayout1):
    layout1()

  elif menuBar.isChecked(idLayout2):
    layout2()

layout1() # this layout may change window size, so calculate it before call center
frame.center()
frame.show()
app.mainLoop()
