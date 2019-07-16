#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  strformat, math,
  resource/resource,
  wNim

let app = App()
let frame = Frame(title="Dialog Demo", size=(500, 450))
frame.icon = Icon("", 0) # load icon from exe file.
frame.minSize = (500, 450)

let panel = Panel(frame)
let staticbox = StaticBox(panel, label="Dialog Type")
let buttonShow = Button(panel, label="Show")
let buttonClose  = Button(panel, label="Close")
let buttonShowModal = Button(panel, label="ShowModal")
let radioMessage = RadioButton(panel, label="wMessageDialog")
let radioDir = RadioButton(panel, label="wDirDialog")
let radioFile = RadioButton(panel, label="wFileDialog")
let radioColor = RadioButton(panel, label="wColorDialog")
let radioFont = RadioButton(panel, label="wFontDialog")
let radioTextEnter = RadioButton(panel, label="wTextEnterDialog")
let radioPasswordEnter = RadioButton(panel, label="wPasswordEnterDialog")
let radioFindReplace = RadioButton(panel, label="wFindReplaceDialog")

proc modalessDialogCount(i: range[-1..1]): int {.discardable.} =
  var counter {.global.} = 0

  counter.inc(i)
  if counter != 0:
    buttonClose.enable()
  else:
    buttonClose.disable()
    buttonClose.disconnect(wEvent_Button)

  result = counter

proc buttonReset(a, b: bool) =
  buttonShow.enable(a)
  buttonShowModal.enable(b)
  buttonShow.disconnect(wEvent_Button)
  buttonShowModal.disconnect(wEvent_Button)
  modalessDialogCount(0)

proc layout() =
  panel.autolayout """
    H:|-[staticbox]-|
    H:|->[buttonShow]-[buttonClose]-[buttonShowModal]-|
    V:|-[staticbox]-[buttonShow,buttonClose,buttonShowModal]-|

    outer: staticbox
    H:|-[radioMessage,radioDir,radioFile,radioColor,radioFont,radioTextEnter,
      radioPasswordEnter,radioFindReplace]-|
    V:|-[radioMessage]-[radioDir]-[radioFile]-[radioColor]-[radioFont]-
      [radioTextEnter]-[radioPasswordEnter]-[radioFindReplace]
  """

panel.wEvent_Size do ():
  layout()

radioMessage.wEvent_RadioButton do ():
  if radioMessage.value == true:
    buttonReset(off, on)

    buttonShowModal.wEvent_Button do ():
      let id = MessageDialog(frame, message="Yes or No?",
        caption="wMessageDialog", style=wYesNoCancel).display()
      if id != wIdCancel:
        MessageDialog(frame, $id, caption="Answer").display()

radioDir.wEvent_RadioButton do ():
  if radioDir.value == true:
    buttonReset(off, on)

    buttonShowModal.wEvent_Button do ():
      let dir = DirDialog(frame, message="Select a dir").display()
      if dir.len != 0:
        MessageDialog(frame, dir, caption="Path").display()

radioFile.wEvent_RadioButton do ():
  if radioFile.value == true:
    buttonReset(off, on)

    buttonShowModal.wEvent_Button do ():
      let files = FileDialog(frame, message="Select a file").display()
      if files.len != 0:
        MessageDialog(frame, files[0], caption="Path").display()

radioColor.wEvent_RadioButton do ():
  if radioColor.value == true:
    buttonReset(off, on)

    buttonShowModal.wEvent_Button do ():
      let color = ColorDialog(frame).display()
      if color > 0:
        MessageDialog(frame, toHex(color, 6), caption="Color Hex").display()

radioFont.wEvent_RadioButton do ():
  if radioFont.value == true:
    buttonReset(off, on)

    buttonShowModal.wEvent_Button do ():
      let font = FontDialog(frame, font=wDefaultFont).display()
      if font != nil:
        let text = fmt"{font.faceName} {font.pointSize.round.int}"
        MessageDialog(frame, text, caption="Color Hex").display()

radioTextEnter.wEvent_RadioButton do ():
  if radioTextEnter.value == true:
    buttonReset(on, on)

    buttonShowModal.wEvent_Button do ():
      let dialog = TextEnterDialog(frame, message="Input text",
        caption="Modal TextEnterDialog", style=wDefaultDialogStyle)

      if dialog.showModal() == wIdOk and dialog.value.len != 0:
        MessageDialog(frame, dialog.value, caption="Text").display()

    buttonShow.wEvent_Button do ():
      let n = modalessDialogCount(1)
      let dialog = TextEnterDialog(frame, message="Input text",
        caption=fmt"Modaless TextEnterDialog {n}", style=wDefaultDialogStyle)

      dialog.showModaless()

      dialog.wEvent_DialogClosed do ():
        modalessDialogCount(-1)
        if dialog.returnCode == wIdOk and dialog.value.len != 0:
          MessageDialog(frame, dialog.value, caption="Text").display()

      buttonClose.wEvent_Button do (event: wEvent):
        dialog.close()
        event.skip()

radioPasswordEnter.wEvent_RadioButton do ():
  if radioPasswordEnter.value == true:
    buttonReset(on, on)

    buttonShowModal.wEvent_Button do ():
      let dialog = PasswordEntryDialog(frame, message="Input password",
        caption="Modal PasswordEntryDialog", style=wDefaultDialogStyle)

      if dialog.showModal() == wIdOk and dialog.value.len != 0:
        MessageDialog(frame, dialog.value, caption="Password").display()

    buttonShow.wEvent_Button do ():
      let n = modalessDialogCount(1)
      let dialog = PasswordEntryDialog(frame, message="Input password",
        caption=fmt"Modaless PasswordEntryDialog {n}", style=wDefaultDialogStyle)

      dialog.showModaless()

      dialog.wEvent_DialogClosed do ():
        modalessDialogCount(-1)
        if dialog.returnCode == wIdOk and dialog.value.len != 0:
          MessageDialog(frame, dialog.value, caption="Password").display()

      buttonClose.wEvent_Button do (event: wEvent):
        dialog.close()
        event.skip()

radioFindReplace.wEvent_RadioButton do ():
  if radioFindReplace.value == true:
    buttonReset(on, off)

    buttonShow.wEvent_Button do ():
      let n = modalessDialogCount(1)
      let dialog = FindReplaceDialog(frame)
      dialog.findString = fmt"Text {n}"

      dialog.showModaless()

      dialog.wEvent_FindNext do ():
        MessageDialog(frame, dialog.findString, caption="Find").display()

      dialog.wEvent_DialogClosed do ():
        modalessDialogCount(-1)

      buttonClose.wEvent_Button do (event: wEvent):
        dialog.close()
        event.skip()

radioMessage.click()
layout()
frame.center()
frame.show()
app.mainLoop()
