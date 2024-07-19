#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

import resource/resource
import wNim/[wApp, wFrame, wIcon, wStatusBar, wPanel, wButton, wResizable,
  wMenuBar, wMenu]

const
  UseAutoLayout = not defined(legacy)
  Title = if UseAutoLayout: "Autolayout Example 2" else: "Layout Example 2"

type
  MenuID = enum idLayout1 = wIdUser, idLayout2, idExit

let app = App(wSystemDpiAware)
let frame = Frame(title=Title, size=(400, 300))
frame.icon = Icon("", 0) # load icon from exe file.

let statusbar = StatusBar(frame)
let panel = Panel(frame)

let button1 = Button(panel, label="Buton1")
let button2 = Button(panel, label="Buton2")
let button3 = Button(panel, label="Buton3")
let button4 = Button(panel, label="Buton4")
let button5 = Button(panel, label="Buton5")
let box = Resizable()

let menuBar = MenuBar(frame)
let menu = Menu(menuBar, "Layout")
menu.appendRadioItem(idLayout1, "Vertical").check()
menu.appendRadioItem(idLayout2, "Horizontal")
menu.appendSeparator()
menu.append(idExit, "Exit")

proc layout1() =
  when UseAutoLayout:
    panel.autolayout """
      spacing: 8
      H:|~[button1..5]~|
      V:|-[button1]-[button2]-[button3]-[button4]-[button5]
      H:[box(button1 + 8 * 2)]
      V:[box(button1 * 5 + 8 * 6)]
    """

  else:
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
  when UseAutoLayout:
    panel.autolayout """
      spacing: 8
      V:|~[button1..5]~|
      H:|-[button1]-[button2]-[button3]-[button4]-[button5]
      V:[box(button1 + 8 * 2)]
      H:[box(button1 * 5 + 8 * 6)]
    """

  else:
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

proc layout() =
  if menu.isChecked(idLayout1): layout1()
  elif menu.isChecked(idLayout2): layout2()

frame.idLayout1 do (): layout1()
frame.idLayout2 do (): layout2()
frame.idExit do (): frame.close()
panel.wEvent_Size do (): layout()

layout()
frame.center()
frame.show()
app.mainLoop()
