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

var button1 = Button(panel, label="Buton1")
var button2 = Button(panel, label="Buton2")
var button3 = Button(panel, label="Buton3")
var button4 = Button(panel, label="Buton4")
var button5 = Button(panel, label="Buton5")
var box = Resizable()

proc layout1() =
  panel.layout:
    button1: centerX = panel.centerX; top = panel.top + 8
    button2: centerX = panel.centerX; top = button1.bottom + 8
    button3: centerX = panel.centerX; top = button2.bottom + 8
    button4: centerX = panel.centerX; top = button3.bottom + 8
    button5: centerX = panel.centerX; top = button4.bottom + 8
    box:
      top = 0
      left = 0
      width = button5.width + 16
      bottom = button5.bottom + 8

  let boxSize = box.layoutSize
  frame.minClientSize = boxSize
  frame.maxClientSize = (wDefault, boxSize.height)

proc layout2() =
  panel.layout:
    button1: centerY = panel.centerY; left = panel.left + 8
    button2: centerY = panel.centerY; left = button1.right + 8
    button3: centerY = panel.centerY; left = button2.right + 8
    button4: centerY = panel.centerY; left = button3.right + 8
    button5: centerY = panel.centerY; left = button4.right + 8
    box:
      top = 0
      left = 0
      right = button5.right + 8
      height = button5.height + 16

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
