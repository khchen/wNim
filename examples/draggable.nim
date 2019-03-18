#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim

type
  MenuID = enum
    idLayout1 = wIdUser, idLayout2, idEnable, idExit

var app = App()
var frame = Frame()
var statusBar = StatusBar(frame)
var menuBar = MenuBar(frame)
frame.margin = 10
frame.icon = Icon("", 0) # load icon from exe file.

var menu = Menu(menuBar, "&Action")
menu.appendRadioItem(idLayout1, "&Layout1", "Switch to layout 1.").check()
menu.appendRadioItem(idLayout2, "&Layout2", "Switch to layout 2.")
menu.appendSeparator()
menu.appendCheckItem(idEnable, "&Enable", "Enable or disable the splitter.").check()
menu.appendSeparator()
menu.append(idExit, "E&xit", "Exit the program.")

var splitter1 = Splitter(frame,
  style=wSpVertical or wClipChildren,
  pos=(100, 0), size=(10, 0))

var splitter2 = Splitter(splitter1.panel1,
  style=wSpHorizontal or wSpButton or wClipChildren,
  pos=(0, 100), size=(0, 10))

var panel1 = splitter2.getPanel1
var panel2 = splitter2.getPanel2
var panel3 = splitter1.getPanel2

panel1.margin = 10
panel2.margin = 10
panel3.margin = 10

panel1.backgroundColor = wWheat
panel2.backgroundColor = wWheat
panel3.backgroundColor = wThistle

# let splitter1 invisible, but can drag by window's margin
splitter1.setInvisible()
splitter1.attachPanel()

var button1 = Button(panel1, label="Button1")
var button2 = Button(panel2, label="Button2")
var button3 = Button(panel3, label="Button3")

# let buttons' size can be changed by user
button1.sizingBorder = (10, 10, 10, 10)
button2.sizingBorder = (10, 10, 10, 10)
button3.sizingBorder = (10, 10, 10, 10)

# let buttons' position can be changed by user
button1.setDraggable(true)
button2.setDraggable(true)
button3.setDraggable(true)

button1.wEvent_Button do (): splitter2.swap
button2.wEvent_Button do (): splitter2.swap
button3.wEvent_Button do (): splitter1.swap

proc layout() =
  button1.setSize((0, 0), panel1.clientSize)
  button2.setSize((0, 0), panel2.clientSize)
  button3.setSize((0, 0), panel3.clientSize)

panel1.wEvent_Size do (): layout()
panel2.wEvent_Size do (): layout()
panel3.wEvent_Size do (): layout()

frame.idExit do ():
  frame.delete()

frame.idLayout1 do ():
  splitter1.setSplitMode(wVertical)
  splitter2.setSplitMode(wHorizontal)
  splitter1.position = (150, 0)
  splitter2.position = (0, 100)

frame.idLayout2 do ():
  splitter1.setSplitMode(wHorizontal)
  splitter2.setSplitMode(wVertical)
  splitter1.position = (0, 150)
  splitter2.position = (100, 0)

frame.idEnable do ():
  splitter1.enable(menuBar.isChecked(idEnable))
  splitter2.enable(menuBar.isChecked(idEnable))

layout()
frame.show()
app.mainLoop()
