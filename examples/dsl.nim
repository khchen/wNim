#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

when defined(cpu64):
  {.link: "wNim64.res".}
else:
  {.link: "wNim32.res".}

import wNim

# An experimental DSL for creation wNim GUI app.

wNim:
  App:
    defer:
      this.mainLoop()

  Frame:
    name = frame
    title = "Hello world"
    size = (350, 200)
    this.minSize = (300, 200)
    this.icon = Icon("", 0)

    StatusBar

    MenuBar:
      Menu:
        text = "&File"
        this.append(wIdExit, "E&xit\tAlt-F4", "Close window and exit program.")

    AcceleratorTable:
      this.add(wAccelAlt, wKey_F4, wIdExit)

    Panel:
      name = panel

      StaticText:
        name = staticText
        label = "Hello World!"
        this.font = Font(14, family=wFontFamilySwiss, weight=wFontWeightBold)

      Button:
        name = button
        label = "Close"

        this.wEvent_Button do ():
          frame.delete()

    defer:
      this.center()
      this.show()

    this.wEvent_Size do ():
      panel.layout:
        staticText:
          top = panel.top + 10
          left = panel.left + 10
        button:
          right + 10 = panel.right
          bottom + 10 = panel.bottom

    this.wIdExit do ():
      this.delete()
