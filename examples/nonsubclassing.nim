#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim

let app = App()
let frame = Frame(title="Hello World", size=(350, 200))
frame.icon = Icon("", 0) # load icon from exe file.

frame.wEvent_Destroy do ():
  MessageDialog(frame, "wMyFrame is about to destroy.",
    "wEvent_Destroy", wOk or wStayOnTop).showModal()

frame.wEvent_Close do (event: wEvent):
  let dlg = MessageDialog(frame, "Do you really want to close this application?",
    "Confirm Exit", wOkCancel or wIconQuestion)

  if dlg.showModal() != wIdOk:
    event.veto()

frame.center()
frame.show()
app.mainLoop()
