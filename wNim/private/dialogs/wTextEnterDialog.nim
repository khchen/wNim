#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This class represents a dialog that requests a one-line text string from
## the user. Both modal or modaless dialog are supported.
#
## :Subclass:
##   `wPasswordEntryDialog <wPasswordEntryDialog.html>`_
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
##   `wFontDialog <wFontDialog.html>`_
##   `wFindReplaceDialog <wFindReplaceDialog.html>`_

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

proc setOKCancelLabels*(self: wTextEnterDialog, ok: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the OK and Cancel buttons.
  self.mOkLabel = ok
  self.mCancelLabe = cancel

proc final*(self: wTextEnterDialog) =
  ## Default finalizer for wTextEnterDialog.
  discard

proc init*(self: wTextEnterDialog, parent: wWindow = nil, message = "Input text",
    caption = "", value = "", style: wStyle = wDefaultDialogStyle,
    pos = wDefaultPoint) {.validate.} =
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
    caption = "", value = "", style: wStyle = wDefaultDialogStyle,
    pos = wDefaultPoint): wTextEnterDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, message, caption, value, style, pos)

proc create(self: wTextEnterDialog): wFrame =
  let
    passwordStyle = if self of wPasswordEntryDialog: wTePassword else: 0
    frame = Frame(owner=self.mParent, title=self.mCaption, style=self.mStyle)
    panel = Panel(frame)
    statictext = StaticText(panel, label=self.mMessage)
    textctrl = TextCtrl(panel, style=wBorderSunken or passwordStyle)
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
  frame.clientSize = (width, height)
  frame.minClientSize = (width, height)

  proc layout() =
    panel.autolayout """
      spacing: 15
      H:|-[statictext,staticline]-|
      H:|-20-[textctrl]-20-|
      H:|~[buttonOk]-[buttonCancel]~|
      V:|-[statictext]-[textctrl]->[staticline(2)]-[buttonOk,buttonCancel]-|
    """

  frame.shortcut(wAccelNormal, wKey_Esc) do ():
    buttonCancel.click()

  frame.wEvent_Size do ():
    layout()

  frame.systemConnect(wEvent_Destroy) do (event: wEvent):
    let event = wDialogEvent Event(window=frame, msg=wEvent_DialogClosed,
      wParam=WPARAM self.mReturnId)
    event.mDialog = self
    frame.processEvent(event)

  buttonOk.wEvent_Button do ():
    self.mValue = textctrl.value
    self.mReturnId = wIdOk
    frame.close()

  buttonCancel.wEvent_Button do ():
    frame.close()

  layout()
  frame.center()
  if self.mPos != wDefaultPoint:
    frame.move(self.mPos)

  if self.mValue.len != 0:
    textctrl.value = self.mValue
    textctrl.selectAll()

  result = frame

proc showModal*(self: wTextEnterDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  self.mFrame = self.create()

  self.mFrame.systemConnect(wEvent_Destroy) do (event: wEvent):
    self.mFrame = nil

  self.mFrame.systemConnect(wEvent_Close) do (event: wEvent):
    self.mFrame.endModal()

  # use showWindowModal insted of showModal, like other system common dialogs do.
  self.mFrame.showWindowModal()
  result = self.mReturnId

proc display*(self: wTextEnterDialog): string {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the user-entered text or empty
  ## string.
  if self.showModal() == wIdOk:
    result = self.getValue()

proc showModaless*(self: wTextEnterDialog) {.validate.} =
  ## Shows the dialog in modaless mode. The frame of this dialog will recieve
  ## wEvent_DialogClosed event when the dialog is closed.
  if self.mFrame == nil:
    self.mFrame = self.create()

    self.mFrame.systemConnect(wEvent_Destroy) do (event: wEvent):
      self.mFrame = nil

  self.mFrame.show()

proc close*(self: wTextEnterDialog) {.validate, inline.} =
  ## Close a modaless dialog.
  if self.mFrame != nil:
    self.mFrame.close()

proc getReturnCode*(self: wTextEnterDialog): wId {.validate, property, inline.} =
  ## Gets the return code for a modaless dialog. Returning wIdOk if the user
  ## pressed OK, and wIdCancel otherwise.
  result = self.mReturnId

proc getReturnId*(self: wTextEnterDialog): wId {.validate, property, inline.} =
  ## The same as getReturnCode().
  result = self.getReturnCode()

proc getFrame*(self: wTextEnterDialog): wFrame {.validate, property, inline.} =
  ## Gets the wFrame object for a modaless dialog. This function let a modaless
  ## dialog can be controlled as a wWindow/wFrame object.
  result = self.mFrame

# cannot use wEventHandler|wEventNeatHandler -> seems compiler's bug

template connect*(self: wTextEnterDialog, msg: UINT,
    handler: wEventHandler): untyped =
  ## Syntax sugar: dialog.frame.connect() => dialog.connect().
  self.mFrame.connect(msg, handler)

template connect*(self: wTextEnterDialog, msg: UINT,
    handler: wEventNeatHandler): untyped =
  ## Syntax sugar: dialog.frame.connect() => dialog.connect().
  self.mFrame.connect(msg, handler)

template `.`*(self: wTextEnterDialog, msg: UINT,
    handler: wEventHandler): untyped =
  ## Syntax sugar: dialog.frame.wEvent_DialogClosed => dialog.wEvent_DialogClosed.
  self.connect(msg, handler)

template `.`*(self: wTextEnterDialog, msg: UINT,
    handler: wEventNeatHandler): untyped =
  ## Syntax sugar: dialog.frame.wEvent_DialogClosed => dialog.wEvent_DialogClosed.
  self.connect(msg, handler)

template disconnect*(self: wTextEnterDialog, msg: UINT, limit = -1): untyped =
  ## Syntax sugar: dialog.frame.disconnect() => dialog.disconnect().
  self.mFrame.disconnect(msg, limit)

template disconnect*(self: wTextEnterDialog, connection: wEventConnection): untyped =
  ## Syntax sugar: dialog.frame.disconnect() => dialog.disconnect().
  self.mFrame.disconnect(connection)
