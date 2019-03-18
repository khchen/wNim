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

const style = wAlignCentre or wAlignMiddle or wBorderSimple
var text1 = StaticText(panel, label="Text1", style=style)
var text2 = StaticText(panel, label="Text2", style=style)
var text3 = StaticText(panel, label="Text3", style=style)
var text4 = StaticText(panel, label="Text4", style=style)
var text5 = StaticText(panel, label="Text5", style=style)

proc layout1() =
  panel.autolayout """
    spacing: 8
    H:|-[text1..2]-[text3..5(text1)]-|
    V:|-[text1]-[text2(text1)]-|
    V:|-[text3(text4,text5)]-[text4]-[text5]-|
  """

proc layout2() =
  panel.autolayout """
    spacing: 8
    H:|~[text4..5(text1+text2+text3+16)]~|
    H:|~[text2(text1)]-[text1(<=200@STRONG)]-[text3(text1)]~|
    V:|~[text4(text1*0.66)]-[text1..3(<=100@STRONG)]-[text5(text1*0.66)]~|
    C: WEAK: text1.width = panel.width / 4
    C: WEAK: text1.height = panel.height / 3
  """

proc layout3() =
  panel.autolayout """
    spacing: 8
    H:|-[text1(60)]-[text2]-|
    H:|-[text1]-[text3(60)]-[text4]-|
    H:|-[text1]-[text3]-(>=8)-[text5(text5.height@WEAK)]-|
    V:|-[text1]-|
    V:|-[text2(60@WEAK)]-[text3]-|
    V:|-[text2]-[text4(60@WEAK)]-[text5]-|
    V:[text4]-(>=8)-|
  """

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
