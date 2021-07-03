#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2021 Ward
#
#====================================================================

import resource/resource
import wNim/[wApp, wFrame, wIcon, wStatusBar, wPanel, wStaticBox, wButton]

const
  UseAutoLayout = not defined(legacy)
  Title = if UseAutoLayout: "Autolayout Example 3" else: "Layout Example 3"

let app = App(wSystemDpiAware)
let frame = Frame(title=Title, size=(400, 300))
frame.icon = Icon("", 0) # load icon from exe file.

let statusbar = StatusBar(frame)
let panel = Panel(frame)
panel.margin = 40

let staticbox1 = StaticBox(panel, label="Static Box 1")
let staticbox2 = StaticBox(panel, label="Static Box 2")
let staticbox3 = StaticBox(panel, label="Static Box 3")
staticbox1.margin = 20
staticbox2.margin = 20
staticbox3.margin = 20

let button1 = Button(panel, label="Buton1")
let button2 = Button(panel, label="Buton2")
let button3 = Button(panel, label="Buton3")
let button4 = Button(panel, label="Buton4")
let button5 = Button(panel, label="Buton5")

proc layout() =
  when UseAutoLayout:
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

  else:
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

panel.wEvent_Size do (): layout()

layout()
frame.center()
frame.show()
app.mainLoop()
