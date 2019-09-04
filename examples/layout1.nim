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
  import wNim/[wApp, wFrame, wIcon, wStatusBar, wPanel, wStaticText, wMenuBar, wMenu]

const
  UseAutoLayout = not defined(legacy)
  Title = if UseAutoLayout: "Autolayout Example 1" else: "Layout Example 1"

type
  MenuID = enum idLayout1 = wIdUser, idLayout2, idLayout3, idExit

let app = App()
let frame = Frame(title=Title, size=(400, 300))
frame.icon = Icon("", 0) # load icon from exe file.

let statusbar = StatusBar(frame)
let panel = Panel(frame)

const style = wAlignCentre or wAlignMiddle or wBorderSimple
let text1 = StaticText(panel, label="Text1", style=style)
let text2 = StaticText(panel, label="Text2", style=style)
let text3 = StaticText(panel, label="Text3", style=style)
let text4 = StaticText(panel, label="Text4", style=style)
let text5 = StaticText(panel, label="Text5", style=style)

let menuBar = MenuBar(frame)
let menu = Menu(menuBar, "Layout")
menu.appendRadioItem(idLayout1, "Layout1").check()
menu.appendRadioItem(idLayout2, "Layout2")
menu.appendRadioItem(idLayout3, "Layout3")
menu.appendSeparator()
menu.append(idExit, "Exit")

proc layout1() =
  when UseAutoLayout:
    panel.autolayout """
      spacing: 8
      H:|-[text1..2]-[text3..5(text1)]-|
      V:|-[text1]-[text2(text1)]-|
      V:|-[text3(text4,text5)]-[text4]-[text5]-|
    """

  else:
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
  when UseAutoLayout:
    panel.autolayout """
      spacing: 8
      H:|~[text4..5(text1+text2+text3+16)]~|
      H:|~[text2(text1)]-[text1(<=200@STRONG)]-[text3(text1)]~|
      V:|~[text4(text1*0.66)]-[text1..3(<=100@STRONG)]-[text5(text1*0.66)]~|
      C: WEAK: text1.width = panel.width / 4
      C: WEAK: text1.height = panel.height / 3
    """

  else:
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
  when UseAutoLayout:
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

  else:
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

proc layout() =
  if menu.isChecked(idLayout1): layout1()
  elif menu.isChecked(idLayout2): layout2()
  elif menu.isChecked(idLayout3): layout3()

frame.idLayout1 do (): layout()
frame.idLayout2 do (): layout()
frame.idLayout3 do (): layout()
frame.idExit do (): frame.close()
panel.wEvent_Size do (): layout()

layout()
frame.center()
frame.show()
app.mainLoop()
