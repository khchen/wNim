#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class represents a dialog that requests a one-line text string from
## the user. Both modal or modaless dialog are supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Subclass:
##   `wPasswordEntryDialog <wPasswordEntryDialog.html>`_
#
## :Events:
##   `wDialogEvent <wDialogEvent.html>`_
##   ==============================   =============================================================
##   wDialogEvent                     Description
##   ==============================   =============================================================
##   wEvent_DialogCreated             When the dialog is created but not yet shown.
##   wEvent_DialogClosed              When the dialog is being closed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, ../wFrame, ../wPanel, ../wAcceleratorTable, wDialog,
  ../controls/[wTextCtrl, wStaticText, wButton, wStaticLine]

# wResizer should already export by wWindow, and wWindow export by wDialog
# However, maybe due to unknow bug? the compiler cannot find wResizer sometimes.
import ../wResizer

export wDialog

proc getValue*(self: wTextEntryDialog): string {.validate, property, inline.} =
  ## Returns the text that the user has entered if the user has pressed OK,
  ## or the original value if the user has pressed Cancel.
  result = self.mValue

proc setValue*(self: wTextEntryDialog, value: string) {.validate, property, inline.} =
  ## Sets the default text value.
  self.mValue = value

proc getMaxLength*(self: wTextEntryDialog): int {.validate, property, inline.} =
  ## Returns the maximum number of characters.
  result = self.mMaxLength

proc setMaxLength*(self: wTextEntryDialog, length: int) {.validate, property, inline.} =
  ## Sets the maximum number of characters the user can enter into this dialog.
  self.mMaxLength = length

proc getMessage*(self: wTextEntryDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = self.mMessage

proc setMessage*(self: wTextEntryDialog, message: string) {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  self.mMessage = message

proc getCaption*(self: wTextEntryDialog): string {.validate, property, inline.} =
  ## Gets the caption that will be displayed on the dialog.
  result = self.mCaption

proc setCaption*(self: wTextEntryDialog, caption: string) {.validate, property, inline.} =
  ## Sets the caption that will be displayed on the dialog.
  self.mCaption = caption

proc getStyle*(self: wTextEntryDialog): wStyle {.validate, property, inline.} =
  ## Gets the window style of the dialog.
  result = self.mStyle

proc setStyle*(self: wTextEntryDialog, style: wStyle) {.validate, property, inline.} =
  ## Sets the window style of the dialog.
  ## The styles for wWindow and wFrame can be use here.
  self.mStyle = style

proc getPosition*(self: wTextEntryDialog): wPoint {.validate, property, inline.} =
  ## Gets the initial position of the dialog.
  result = self.mPos

proc setPosition*(self: wTextEntryDialog, pos: wPoint) {.validate, property, inline.} =
  ## Sets the position of the dialog. Using wDefaultPoint to centre the dialog.
  self.mPos = pos

proc setOKCancelLabels*(self: wTextEntryDialog, ok: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the OK and Cancel buttons.
  self.mOkLabel = ok
  self.mCancelLabe = cancel

wClass(wTextEntryDialog of wDialog):

  proc init*(self: wTextEntryDialog, owner: wWindow = nil, message = "Input text",
      caption = "", value = "", style: wStyle = wDefaultDialogStyle,
      pos = wDefaultPoint) {.validate.} =
    ## Initializer.
    self.wDialog.init(owner)
    self.mMessage = message
    self.mCaption = caption
    self.mValue = value
    self.mStyle = style
    self.mPos = pos
    self.mOkLabel = "&OK"
    self.mCancelLabe = "&Cancel"

proc wTextEntryHookProc(win: wWindow, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool =
  let self = cast[wTextEntryDialog](GetWindowLongPtr(win.mHwnd, GWLP_USERDATA))
  let frame = wFrame win
  assert frame != nil and self != nil

  if msg == WM_DESTROY:
    if frame.isModal: frame.endModal()
    # a very strange memory leak for WC_EDIT under windows 10 found here !!
    # in theory, the system will delete all child of frame
    # but under window 10, if we don't manually delete textctrl or panel here
    # the system don't release the memory of WC_EDIT
    # if we add wTeRich to use rich edit, then it works fine
    # even winxp or win7 don't have this bug
    # memory leak only apper in "WC_EDIT" under "win10"
    frame.mChildren[0].delete # mChildren[0] is wPanel here

  # wDialogHookProc sent wEvent_DialogClosed if msg == WM_DESTROY
  # Send that after endModal()
  result = bool self.wDialogHookProc(frame.mHwnd, msg, wParam, lParam)

  # notice: mHookProc cannot handle WM_NCDESTROY
  # so clear the resource in WM_DESTROY
  if msg == WM_DESTROY:
    self.mFrame = nil

proc create(self: wTextEntryDialog): wFrame =
  let
    passwordStyle = if self of wPasswordEntryDialog: wTePassword else: 0
    frame = Frame(owner=self.mOwner, title=self.mCaption, style=self.mStyle)
    panel = Panel(frame)
    statictext = StaticText(panel, label=self.mMessage)
    textctrl = TextCtrl(panel, style=wBorderSunken or passwordStyle)
    buttonOk = Button(panel, label=self.mOkLabel)
    buttonCancel = Button(panel, label=self.mCancelLabe)
    staticline = StaticLine(panel)

  buttonOk.setDefault()
  statictext.fit()

  var
    size = statictext.getSize()
    width = (size.width + 15 * 2)
    height = size.height + textctrl.getSize().height +
      buttonOk.getSize().height + 2 + 15 * 5

  if width < 350: width = 350
  frame.setClientSize(width, height)
  frame.setMinClientSize(width, height)

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

  textctrl.wEvent_Text do ():
    self.mValue = textctrl.getValue()

  buttonOk.wEvent_Button do ():
    self.mReturnId = wIdOk
    frame.close()

  buttonCancel.wEvent_Button do ():
    frame.close()

  layout()
  frame.center()
  if self.mPos != wDefaultPoint:
    frame.move(self.mPos)

  if self.mValue.len != 0:
    textctrl.setValue(self.mValue)
    textctrl.selectAll()

  SetWindowLongPtr(frame.mHwnd, GWLP_USERDATA, cast[LPARAM](self))
  frame.mHookProc = wTextEntryHookProc
  SendMessage(frame.mHwnd, WM_INITDIALOG, 0, 0)

  result = frame

proc showModal*(self: wTextEntryDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  self.mFrame = self.create()

  # use showWindowModal insted of showModal, like other system common dialogs do.
  self.mReturnId = wIdCancel
  self.mFrame.showWindowModal()
  result = self.mReturnId

proc display*(self: wTextEntryDialog): string {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the user-entered text or empty
  ## string.
  if self.showModal() == wIdOk:
    result = self.getValue()

proc showModaless*(self: wTextEntryDialog) {.validate.} =
  ## Shows the dialog in modaless mode. The dialog will recieve
  ## wEvent_DialogClosed event when the dialog is closed.
  if self.mFrame == nil:
    self.mFrame = self.create()

  self.mReturnId = wIdCancel
  self.mFrame.show()

proc close*(self: wTextEntryDialog) {.validate, inline.} =
  ## Close a modaless dialog.
  if self.mFrame != nil:
    self.mFrame.close()

proc getReturnCode*(self: wTextEntryDialog): wId {.validate, property, inline.} =
  ## Gets the return code for a modaless dialog. Returning wIdOk if the user
  ## pressed OK, and wIdCancel otherwise.
  result = self.mReturnId

proc getReturnId*(self: wTextEntryDialog): wId {.validate, property, inline.} =
  ## The same as getReturnCode().
  result = self.getReturnCode()
