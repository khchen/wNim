#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import wNim

# wNim's class/object use following naming convention.
# 1. Class name starts with 'w' and define as ref object. e.g. wObject.
# 2. Every class have init(self: wObject) and final(self: wObject)
#    as initializer and finalizer.
# 3. Provides na Object() proc to quickly get the ref object.

type
  wMyFrame = ref object of wFrame

proc final(self: wMyFrame) =
  wFrame(self).final()

proc init(self: wMyFrame, title: string) =
  wFrame(self).init(title=title, size=(350, 200))
  self.center()

  self.wEvent_Destroy do ():
    MessageDialog(self, "wMyFrame is about to destroy.",
      "wEvent_Destroy", wOk or wStayOnTop).showModal()

  self.wEvent_Close do (event: wEvent):
    let dlg = MessageDialog(self, "Do you really want to close this application?",
      "Confirm Exit", wOkCancel or wIconQuestion)

    if dlg.showModal() != wIdOk:
      event.veto()

proc MyFrame(title: string): wMyFrame {.inline.} =
  new(result, final)
  result.init(title)

when isMainModule:
  import resource/resource

  let app = App()
  let frame = MyFrame("Hello World")
  frame.icon = Icon("", 0) # load icon from exe file.

  frame.show()
  app.mainLoop()
