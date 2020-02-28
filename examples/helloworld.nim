#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2020 Ward
#
#====================================================================

when defined(aio):
  import wNim
else:
  import wNim/[wApp, wFrame]

let app = App()
let frame = Frame(title="Hello World", size=(400, 300))

frame.center()
frame.show()
app.mainLoop()
