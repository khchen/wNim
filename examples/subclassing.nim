{.this: self.}
import wNim

# wNim's class/object use following naming convention.
# 1. Class name starts with w and define as ref object. e.g. wObject.
# 2. Every class have init(self: wObject) and final(self: wObject)
#    as initiator and finalizer.
# 3. Provides a Object() proc to quickly get the ref object.

type
  wMyFrame = ref object of wFrame

proc final(self: wMyFrame) =
  wFrame(self).final()

proc init(self: wMyFrame, title: string) =
  wFrame(self).init(title=title, size=(350, 200))
  center()

  connect(wEvent_Destroy) do ():
    MessageDialog(self, "wMyFrame is about to destroy.",
      "wEvent_Destroy", wOk or wStayOnTop).showModal()

  connect(wEvent_Close) do (event: wEvent):
    let dlg = MessageDialog(self, "Do you really want to close this application?",
      "Confirm Exit", wOkCancel or wIconQuestion)

    if dlg.showModal() != wIdOk:
      event.veto()

proc MyFrame(title: string): wMyFrame {.inline.} =
  new(result, final)
  result.init(title)

when isMainModule:
  let app = App()
  let frame = MyFrame("Hello World")
  frame.show()
  app.mainLoop()
