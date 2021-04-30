#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2021 Ward
#
#====================================================================

import
  strformat, math, strutils,
  resource/resource

import wNim/[wApp, wMacros, wFrame, wPanel, wEvent, wPrintData, wIcon, wUtils,
  wStaticBox, wButton, wRadioButton, wMessageDialog, wDirDialog, wFileDialog,
  wColorDialog, wFontDialog, wTextEntryDialog, wPasswordEntryDialog,
  wFindReplaceDialog, wPageSetupDialog, wPrintDialog]

wEventRegister(wEvent):
  wEvent_RadioButtonOn

wSetSysemDpiAware()
let app = App()
let frame = Frame(title="Dialog Demo", size=(500, 520))
frame.icon = Icon("", 0) # load icon from exe file.
frame.minSize = (500, 520)

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
let radioTextEntry = RadioButton(panel, label="wTextEntryDialog")
let radioPasswordEntry = RadioButton(panel, label="wPasswordEntryDialog")
let radioFindReplace = RadioButton(panel, label="wFindReplaceDialog")
let radioPageSetup = RadioButton(panel, label="wPageSetupDialog")
let radioPrint = RadioButton(panel, label="wPrintDialog")

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
    alias:
      b1 = buttonShow
      b2 = buttonClose
      b3 = buttonShowModal

    H:|-[staticbox]-|
    H:|->[b1]-[b2]-[b3]-|
    V:|-[staticbox]-[b1..3]-|

    outer: staticbox
    alias:
      r1 = radioMessage
      r2 = radioDir
      r3 = radioFile
      r4 = radioColor
      r5 = radioFont
      r6 = radioTextEntry
      r7 = radioPasswordEntry
      r8 = radioFindReplace
      r9 = radioPageSetup
      r10 = radioPrint

    H:|-[r1..10]-|
    V:|-[r1]-[r2]-[r3]-[r4]-[r5]-[r6]-[r7]-[r8]-[r9]-[r10]
    V: [r1(r1.defaultSize.height), r2..10(r1)]
  """

panel.wEvent_Size do ():
  layout()

panel.wEvent_RadioButton do (event: wEvent):
  let radioButton = wRadioButton event.window
  if radioButton.value == true:
    let event = Event(radioButton, msg=wEvent_RadioButtonOn)
    radioButton.processEvent(event)

radioMessage.wEvent_RadioButtonOn do ():
  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    let id = MessageDialog(frame, message="Yes or No?",
      caption="wMessageDialog", style=wYesNoCancel).display()
    if id != wIdCancel:
      MessageDialog(frame, $id, caption="Answer").display()

radioDir.wEvent_RadioButtonOn do ():
  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    let dir = DirDialog(frame, message="Select a dir").display()
    if dir.len != 0:
      MessageDialog(frame, dir, caption="Path").display()

radioFile.wEvent_RadioButtonOn do ():
  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    let files = FileDialog(frame, message="Select a file").display()
    if files.len != 0:
      MessageDialog(frame, files[0], caption="Path").display()

radioColor.wEvent_RadioButtonOn do ():
  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    let dialog = ColorDialog(frame)
    dialog.enableHelp()
    dialog.color = 0x80ffff

    dialog.wEvent_DialogHelp do ():
      MessageDialog(dialog, "Help!", caption="wColorDialog").display()

    if dialog.showModal() == wIdOk:
      MessageDialog(frame, toHex(dialog.color, 6), caption="Color Hex").display()

radioFont.wEvent_RadioButtonOn do ():
  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    let dialog = FontDialog(frame, font=wNormalFont)
    dialog.enableHelp()
    dialog.enableApply()

    dialog.wEvent_DialogHelp do ():
      MessageDialog(dialog, "Help!", caption="wFontDialog").display()

    dialog.wEvent_DialogApply do ():
      let font = dialog.chosenFont
      let text = fmt"{font.faceName} {font.pointSize.round.int}"
      MessageDialog(dialog, text, caption="Font").display()

    if dialog.showModal() == wIdOk:
      let font = dialog.chosenFont
      let text = fmt"{font.faceName} {font.pointSize.round.int}"
      MessageDialog(frame, text, caption="Font").display()

radioTextEntry.wEvent_RadioButtonOn do ():
  buttonReset(on, on)

  buttonShowModal.wEvent_Button do ():
    let dialog = TextEntryDialog(frame, message="Input text",
      caption="Modal TextEntryDialog", style=wDefaultDialogStyle)

    if dialog.showModal() == wIdOk and dialog.value.len != 0:
      MessageDialog(frame, dialog.value, caption="Text").display()

  buttonShow.wEvent_Button do ():
    let n = modalessDialogCount(1)
    let dialog = TextEntryDialog(frame, message="Input text",
      caption=fmt"Modaless TextEntryDialog {n}", style=wDefaultDialogStyle)

    dialog.wEvent_DialogClosed do ():
      modalessDialogCount(-1)
      if dialog.returnCode == wIdOk and dialog.value.len != 0:
        MessageDialog(frame, dialog.value, caption="Text").display()

    buttonClose.wEvent_Button do (event: wEvent):
      dialog.close()
      event.skip()

    dialog.showModaless()

radioPasswordEntry.wEvent_RadioButtonOn do ():
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

    dialog.wEvent_DialogClosed do ():
      modalessDialogCount(-1)
      if dialog.returnCode == wIdOk and dialog.value.len != 0:
        MessageDialog(frame, dialog.value, caption="Password").display()

    buttonClose.wEvent_Button do (event: wEvent):
      dialog.close()
      event.skip()

    dialog.showModaless()

radioFindReplace.wEvent_RadioButtonOn do ():
  buttonReset(on, off)

  buttonShow.wEvent_Button do ():
    let n = modalessDialogCount(1)
    let dialog = FindReplaceDialog(frame, wFrReplace)
    dialog.findString = fmt"Text {n}"
    dialog.enableHelp()

    dialog.wEvent_FindNext do ():
      MessageDialog(frame, dialog.findString, caption="Find").display()

    dialog.wEvent_DialogHelp do ():
      MessageDialog(dialog, "Help!", caption=fmt"wFontDialog {n}").display()

    dialog.wEvent_DialogClosed do ():
      modalessDialogCount(-1)

    buttonClose.wEvent_Button do (event: wEvent):
      dialog.close()
      event.skip()

    dialog.showModaless()

radioPageSetup.wEvent_RadioButtonOn do ():
  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    let dialog = PageSetupDialog(frame)
    dialog.enableHelp()

    dialog.wEvent_DialogHelp do ():
      MessageDialog(dialog, "Help!", caption="wPageSetupDialog").display()

    if dialog.showModal() == wIdOk:
      var printData = dialog.printData
      var name = printData.paperName
      if name.len == 0: name = $printData.paper
      var size = fmt"{dialog.paperSize.width}x{dialog.paperSize.height}"
      var ori = if printData.orientation == wPortrait: "Portrait" else: "Landscape"
      MessageDialog(frame, fmt"{name} {ori} ({size}mm)", caption="Page Setup").display()

radioPrint.wEvent_RadioButton do ():

  buttonReset(off, on)

  buttonShowModal.wEvent_Button do ():
    var printData {.global.}: wPrintData

    once:
      try: printData = PrintData() # If there is no printer, error will occurred.
      except wPrintDataError: discard

    let dialog = PrintDialog(frame, printData)

    case dialog.showModal():
    of wIdOk:
      printData = dialog.printData
      MessageDialog(frame, printData.device, caption="Print").display()

    of wIdApply:
      printData = dialog.printData
      MessageDialog(frame, printData.device, caption="Apply").display()

    else: discard

radioMessage.click()
layout()
frame.center()
frame.show()
app.mainLoop()
