#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2021 Ward
#
#====================================================================

import wNim/[wApp, wFrame]

let app = App(wSystemDpiAware)
let frame = Frame(title="Hello World", size=(400, 300))

frame.center()
frame.show()
app.mainLoop()
