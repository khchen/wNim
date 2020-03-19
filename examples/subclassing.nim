#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2020 Ward
#
#====================================================================

import resource/resource
import wNim/[wApp, wMacros, wFrame, wMessageDialog, wIcon]

# wNim's class/object use following naming convention.
# 1. Class name starts with 'w' and define as ref object. e.g. wObject.
# 2. Every class have init(self: wObject) as initializer.
# 3. Provides an Object() proc to quickly get the ref object.

# wClass (defined in wMacros) provides a convenient way to define wNim class.

wClass(wMyFrame of wFrame):
  # Constructor is generated from initializer and finalizer automatically.

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

  proc final(self: wMyFrame) =
    # Don't need to call parent's final()
    MessageDialog(nil, "A custom finalizer is optional.", "Finalizer").display()

when isMainModule:

  let app = App()
  let frame = MyFrame("Hello World")
  frame.icon = Icon("", 0) # load icon from exe file.

  frame.show()
  app.mainLoop()
