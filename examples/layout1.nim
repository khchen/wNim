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

const style = wAlignCentre or wAlignMiddle or wBorderSimple
var text1 = StaticText(panel, label="Text1", style=style)
var text2 = StaticText(panel, label="Text2", style=style)
var text3 = StaticText(panel, label="Text3", style=style)
var text4 = StaticText(panel, label="Text4", style=style)
var text5 = StaticText(panel, label="Text5", style=style)

proc layout1() =
  panel.layout:
    text1:
      left == panel.left + 8
      top == panel.top + 8
      right + 8 == text3.left
      bottom + 8 == text2.top

    text2:
      left == text1.left
      top == text1.bottom + 8
      right + 8 == text5.left
      bottom + 8 == panel.bottom
      height == text1.height

    text3:
      left == text1.right + 8
      top == panel.top + 8
      right + 8 == panel.right
      bottom + 8 == text4.top
      width == text1.width

    text4:
      left == text3.left
      top == text3.bottom + 8
      right == text3.right
      bottom + 8 == text5.top
      height == text3.height

    text5:
      left == text4.left
      top == text4.bottom + 8
      right == text4.right
      bottom + 8 == panel.bottom
      height == text4.height

proc layout2() =
  panel.layout:
    text1:
      centerX == panel.centerX
      centerY == panel.centerY
      WEAK:
        width == panel.width / 4
        height == panel.height / 3
      STRONG:
        width <= 200
        height <= 100

    text2:
      width == text1.width
      height == text1.height
      top == text1.top
      right + 8 == text1.left

    text3:
      width == text1.width
      height == text1.height
      top == text1.top
      left == text1.right + 8

    text4:
      left == text2.left
      right == text3.right
      height == text1.height * 0.66
      bottom + 8 == text1.top

    text5:
      left == text2.left
      right == text3.right
      height == text1.height * 0.66
      top == text1.bottom + 8

proc layout3() =
  panel.layout:
    text1:
      STRONG:
        width == 60
        left == panel.left + 8
        top == panel.top + 8
        bottom + 8 == panel.bottom

    text2:
      STRONG:
        left == text1.right + 8
        right + 8 == panel.right
        top == panel.top + 8
        bottom + 8 <= panel.bottom
      WEAK:
        height == 60

    text3:
      STRONG:
        width == 60
        top == text2.bottom + 8
        left == text1.right + 8
        bottom + 8 == panel.bottom

    text4:
      STRONG:
        left == text3.right + 8
        top == text2.bottom + 8
        right + 8 == panel.right
        bottom + 8 <= panel.bottom
      WEAK:
        height == 60

    text5:
      STRONG:
        top == text4.bottom + 8
        bottom + 8 == panel.bottom
        right + 8 == panel.right
        left >= text3.right + 8
      WEAK:
        height == width

type
  MenuID = enum
    idLayout1 = 1000
    idLayout2
    idLayout3
    idExit

var menuBar = MenuBar(frame)
var menu = Menu(menuBar, "Layout")
menu.appendRadioItem(idLayout1, "Layout1").check()
menu.appendRadioItem(idLayout2, "Layout2")
menu.appendRadioItem(idLayout3, "Layout3")
menu.appendSeparator()
menu.append(idExit, "Exit")

frame.idLayout1 do (): layout1()
frame.idLayout2 do (): layout2()
frame.idLayout3 do (): layout3()
frame.idExit do (): frame.delete()

frame.wEvent_Size do (event: wEvent):
  if menuBar.isChecked(idLayout1):
    layout1()

  elif menuBar.isChecked(idLayout2):
    layout2()

  elif menuBar.isChecked(idLayout3):
    layout3()

frame.center()
frame.show()
app.mainLoop()
