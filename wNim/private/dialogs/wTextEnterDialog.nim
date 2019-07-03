#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This class represents a dialog that requests a one-line text or password
## string from the user.
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
##   `wFontDialog <wFontDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wTedPassword                    The text will be echoed as asterisks.
##   ==============================  =============================================================

const
  wTedPassword* = wTePassword

proc getValue*(self: wTextEnterDialog): string {.validate, property, inline.} =
  ## Returns the text that the user has entered if the user has pressed OK,
  ## or the original value if the user has pressed Cancel.
  result = self.mValue

proc setValue*(self: wTextEnterDialog, value: string) {.validate, property, inline.} =
  ## Sets the default text value.
  self.mValue = value

proc getMaxLength*(self: wTextEnterDialog): int {.validate, property, inline.} =
  ## Returns the maximum number of characters.
  result = self.mMaxLength

proc setMaxLength*(self: wTextEnterDialog, length: int) {.validate, property, inline.} =
  ## Sets the maximum number of characters the user can enter into this dialog.
  self.mMaxLength = length

proc getMessage*(self: wTextEnterDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = self.mMessage

proc setMessage*(self: wTextEnterDialog, message: string) {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  self.mMessage = message

proc getCaption*(self: wTextEnterDialog): string {.validate, property, inline.} =
  ## Gets the caption that will be displayed on the dialog.
  result = self.mCaption

proc setCaption*(self: wTextEnterDialog, caption: string) {.validate, property, inline.} =
  ## Sets the caption that will be displayed on the dialog.
  self.mCaption = caption

proc getStyle*(self: wTextEnterDialog): wStyle {.validate, property, inline.} =
  ## Gets the window style of the dialog.
  result = self.mStyle

proc setStyle*(self: wTextEnterDialog, style: wStyle) {.validate, property, inline.} =
  ## Sets the window style of the dialog.
  ## The styles for wWindow and wFrame can be use here.
  self.mStyle = style

proc getPosition*(self: wTextEnterDialog): wPoint {.validate, property, inline.} =
  ## Gets the initial position of the dialog.
  result = self.mPos

proc setPosition*(self: wTextEnterDialog, pos: wPoint) {.validate, property, inline.} =
  ## Sets the position of the dialog. Using wDefaultPoint to centre the dialog.
  self.mPos = pos

proc getFrame*(self: wTextEnterDialog): wFrame {.validate, property, inline.} =
  ## Gets the wFrame object for the dialog. This function let the parent window
  ## be able to connect wEvent_Close event to a modaless dialog.
  result = self.mFrame

proc getReturnId*(self: wTextEnterDialog): wId {.validate, property, inline.} =
  ## Returning wIdOk if the user pressed OK, and wIdCancel otherwise.
  result = self.mReturnId

proc setOKCancelLabels*(self: wTextEnterDialog, ok: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the OK and Cancel buttons.
  self.mOkLabel = ok
  self.mCancelLabe = cancel

proc final*(self: wTextEnterDialog) =
  ## Default finalizer for wTextEnterDialog.
  discard

proc init*(self: wTextEnterDialog, parent: wWindow = nil, message = "Input text",
    caption = "", value = "", style: wStyle = 0, pos = wDefaultPoint) {.validate.} =
  ## Initializer.
  self.mParent = parent
  self.mMessage = message
  self.mCaption = caption
  self.mValue = value
  self.mStyle = style
  self.mPos = pos
  self.mOkLabel = "&OK"
  self.mCancelLabe = "&Cancel"
  self.mFrame = nil
  self.mReturnId = wIdCancel

proc TextEnterDialog*(parent: wWindow = nil, message = "Input text",
    caption = "", value = "", style: wStyle = 0, pos = wDefaultPoint): wTextEnterDialog
    {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, message, caption, value, style, pos)

proc create(self: wTextEnterDialog): wFrame =
  let
    style = self.mStyle and (not wTePassword)
    dialog = Frame(owner=self.mParent, title=self.mCaption, style=style)
    panel = Panel(dialog)
    statictext = StaticText(panel, label=self.mMessage)
    textctrl = TextCtrl(panel, style=wBorderSunken or (self.mStyle and wTedPassword))
    buttonOk = Button(panel, label=self.mOkLabel)
    buttonCancel = Button(panel, label=self.mCancelLabe)
    staticline = StaticLine(panel)

  buttonOk.setDefault()
  statictext.fit()

  var
    width = (statictext.size.width + 15 * 2)
    height = statictext.size.height + textctrl.size.height +
      buttonOk.size.height + 2 + 15 * 5

  if width < 350: width = 350
  dialog.clientSize = (width, height)
  dialog.minClientSize = (width, height)

  proc layout() =
    panel.autolayout """
      spacing: 15
      H:|-[statictext,staticline]-|
      H:|-20-[textctrl]-20-|
      H:|~[buttonOk]-[buttonCancel]~|
      V:|-[statictext]-[textctrl]->[staticline(2)]-[buttonOk,buttonCancel]-|
    """

  dialog.shortcut(wAccelNormal, wKey_Esc) do ():
    buttonCancel.click()

  dialog.wEvent_Size do ():
    layout()

  buttonOk.wEvent_Button do ():
    self.mValue = textctrl.value
    self.mReturnId = wIdOk
    dialog.close()

  buttonCancel.wEvent_Button do ():
    dialog.close()

  layout()
  dialog.center()
  if self.mPos != wDefaultPoint:
    dialog.move(self.mPos)

  if self.mValue.len != 0:
    textctrl.value = self.mValue
    textctrl.selectAll()

  result = dialog

proc showModal*(self: wTextEnterDialog): wId {.discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  self.mFrame = self.create()

  self.mFrame.wEvent_Destroy do ():
    self.mFrame = nil

  self.mFrame.wEvent_Close do ():
    self.mFrame.endModal()

  self.mFrame.showModal()
  result = self.mReturnId

proc show*(self: wTextEnterDialog): wId {.inline, discardable.} =
  ## The same as showModal().
  result = self.showModal()

proc showModalResult*(self: wTextEnterDialog): string {.inline, discardable.} =
  ## Shows the dialog, returning the user-entered text or empty string.
  if self.showModal() == wIdOk:
    result = self.mValue

proc showResult*(self: wTextEnterDialog): string {.inline, discardable.} =
  ## The same as showModalResult().
  if self.show() == wIdOk:
    result = self.mValue

proc showModaless*(self: wTextEnterDialog): wId {.discardable.} =
  ## Shows the dialog in modaless mode. We can use *getFrame() to know when the
  ## dialog is closed, and use *getReturnId() to get the result. For example:
  ##
  ## .. code-block:: Nim
  ##   let ted = TextEnterDialog(frame)
  ##   ted.showModaless()
  ##   ted.frame.wEvent_Close do ():
  ##     if ted.returnId == wIdOk:
  ##       echo ted.value
  if self.mFrame == nil:
    self.mFrame = self.create()

    self.mFrame.wEvent_Destroy do ():
      self.mFrame = nil

  self.mFrame.show()
