#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

import wNim/[wApp, wFrame]

let app = App(wSystemDpiAware)
let frame = Frame(title="Hello World", size=(400, 300))

frame.center()
frame.show()
app.mainLoop()
