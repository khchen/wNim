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
  import wNim/[wApp, wImage, wFrame, wRegion, wMenu, wPaintDC]

let app = App()

const logo = staticRead(r"images\logo.png")
let image = Image(logo)

let frame = Frame(size=image.size, style=0)

# The system add wCaption automatically for a top-level window,
# We must clear it for a shaped window.
frame.clearWindowStyle(wCaption)

frame.setDraggable(true)
frame.shape = Region(image)

let menu = Menu()
menu.append(wIdExit, "E&xit")

frame.wIdExit do ():
  frame.close()

frame.wEvent_ContextMenu do (event: wEvent):
  frame.popupMenu(menu)

frame.wEvent_Paint do (event: wEvent):
  var dc = PaintDC(frame)
  dc.drawImage(image)

frame.center()
frame.show()
app.mainLoop()

