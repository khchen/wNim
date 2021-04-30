#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A dialog that shows a single or multi-line message, with a choice of
## OK, Yes, No and Cancel buttons. Only modal dialog is supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wOk                             The message box contains one push button: OK. This is the default.
##   wYesNo                          The message box contains two push buttons: Yes and No.
##   wOkCancel                       The message box contains two push buttons: OK and Cancel.
##   wYesNoCancel                    The message box contains three push buttons: Yes, No, and Cancel.
##   wRetryCancel                    The message box contains two push buttons: Retry and Cancel.
##   wAbortRetryIgnore               The message box contains three push buttons: Abort, Retry, and Ignore.
##   wCancelTryContinue              The message box contains three push buttons: Cancel, Try Again, Continue.
##   wIconHand                       A stop-sign icon appears in the message box.
##   wIconErr                        A stop-sign icon appears in the message box.
##   wIconStop                       A stop-sign icon appears in the message box.
##   wIconQuestion                   A question-mark icon appears in the message box.
##   wIconExclamation                An exclamation-point icon appears in the message box.
##   wIconWarning                    An exclamation-point icon appears in the message box.
##   wIconInformation                An icon consisting of a lowercase letter i in a circle appears in the message box.
##   wIconAsterisk                   An icon consisting of a lowercase letter i in a circle appears in the message box.
##   wButton1_Default                The first button is the default button. This is the default.
##   wButton2_Default                The second button is the default button.
##   wButton3_Default                The third button is the default button.
##   wButton4_Default                The fourth button is the default button.
##   wStayOnTop                      The message box will stay on top of all other windows.
##   ==============================  =============================================================

include ../pragma
import tables
import ../wBase, ../wFrame, wDialog
export wDialog, wFrame

var gMessageDialog {.threadvar.}: wMessageDialog

const
  # MessageDialog styles
  wOk* = MB_OK
  wYesNo* = MB_YESNO
  wOkCancel* = MB_OKCANCEL
  wYesNoCancel* = MB_YESNOCANCEL
  wRetryCancel* = MB_RETRYCANCEL
  wAbortRetryIgnore* = MB_ABORTRETRYIGNORE
  wCancelTryContinue* = MB_CANCELTRYCONTINUE
  wIconHand* = MB_ICONHAND
  wIconErr* = MB_ICONERROR
  wIconStop* = MB_ICONSTOP
  wIconQuestion* = MB_ICONQUESTION
  wIconExclamation* = MB_ICONEXCLAMATION
  wIconWarning* = MB_ICONWARNING
  wIconInformation* = MB_ICONINFORMATION
  wIconAsterisk* = MB_ICONASTERISK
  wButton1_Default* = MB_DEFBUTTON1
  wButton2_Default* = MB_DEFBUTTON2
  wButton3_Default* = MB_DEFBUTTON3
  wButton4_Default* = MB_DEFBUTTON4
  # defined in wFrame.nim
  # wStayOnTop* = WS_EX_TOPMOST.int64 shl 32

wClass(wMessageDialog of wDialog):

  proc init*(self: wMessageDialog, owner: wWindow = nil, message: string = "" ,
      caption: string = "", style: wStyle = wOK) {.validate.} =
    ## Initializer.
    self.wDialog.init(owner)
    self.mMessage = message
    self.mCaption = caption
    self.mStyle = style
    self.mLabelText = initTable[INT, string]()

proc getMessage*(self: wMessageDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = self.mMessage

proc getCaption*(self: wMessageDialog): string {.validate, property, inline.} =
  ## Gets the caption that will be displayed on the dialog.
  result = self.mCaption

proc getStyle*(self: wMessageDialog): wStyle {.validate, property, inline.} =
  ## Gets the style.
  result = self.mStyle

proc setMessage*(self: var wMessageDialog, message: string) {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  self.mMessage = message

proc setCaption*(self: var wMessageDialog, caption: string) {.validate, property, inline.} =
  ## Sets the caption that will be displayed on the dialog.
  self.mCaption = caption

proc setStyle*(self: var wMessageDialog, style: wStyle) {.validate, property, inline.} =
  ## Sets the style of the dialog.
  self.mStyle = style

proc setOKLabel*(self: wMessageDialog, ok: string) {.validate, property, inline.} =
  ## Overrides the default labels of the OK button.
  self.mLabelText[IDOK] = ok

proc setOKCancelLabels*(self: wMessageDialog, ok: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the OK and Cancel buttons.
  self.mLabelText[IDOK] = ok
  self.mLabelText[IDCANCEL] = cancel

proc setYesNoCancelLabels*(self: wMessageDialog, yes: string, no: string,
    cancel: string) {.validate, property, inline.} =
  ## Overrides the default labels of the Yes, No and Cancel buttons.
  self.mLabelText[IDYES] = yes
  self.mLabelText[IDNO] = no
  self.mLabelText[IDCANCEL] = cancel

proc setYesNoLabels*(self: wMessageDialog, yes: string, no: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the Yes and No buttons.
  self.mLabelText[IDYES] = yes
  self.mLabelText[IDNO] = no

proc setRetryCancelLabels*(self: wMessageDialog, retry: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the Retry and Cancel buttons.
  self.mLabelText[IDRETRY] = retry
  self.mLabelText[IDCANCEL] = cancel

proc setAbortRetryIgnoreLabels*(self: wMessageDialog, abort: string,
    retry: string, ignore: string) {.validate, property, inline.} =
  ## Overrides the default labels of the Abort, Retry and Ignore buttons.
  self.mLabelText[IDABORT] = abort
  self.mLabelText[IDRETRY] = retry
  self.mLabelText[IDIGNORE] = ignore

proc setCancelTryContinueLabels*(self: wMessageDialog, cancel: string,
    tryagain: string, cont: string) {.validate, property, inline.} =
  ## Overrides the default labels of the Cancel, Try Again and Continue buttons.
  self.mLabelText[IDCANCEL] = cancel
  self.mLabelText[IDTRYAGAIN] = tryagain
  self.mLabelText[IDCONTINUE] = cont

proc wMessageDialog_CBTProc(nCode: INT, wParam: WPARAM, lParam: LPARAM): LRESULT
    {.stdcall.} =

  let ret = CallNextHookEx(0, nCode, wParam, lParam)
  defer: result = ret # avoid contaminate result

  if nCode == HCBT_ACTIVATE:
    let self = gMessageDialog
    UnhookWindowsHookEx(self.mHook)

    for key, value in self.mLabelText:
      let buttonHwnd = GetDlgItem(HWND wParam, key)
      if buttonHwnd != 0:
        SetWindowText(buttonHwnd, value)

    # we can subclass this messagebox, but what to do?
    # let win = Window(HWND wParam)

proc showModal*(self: wMessageDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning one of wIdOk, wIdYes, wIdNo, wIdCancel,
  ## wIdTryAgain, wIdContinue, wIdAbort, wIdRetry or wIdIgnore.
  var
    hOwner: HWND
    mbStyle = cast[DWORD](self.mStyle and 0xFFFFFFFF)

  if self.mOwner != nil:
    hOwner = self.mOwner.mHwnd
    mbStyle = mbStyle or MB_APPLMODAL
  else:
    mbStyle = mbStyle or MB_TASKMODAL

  if (self.mStyle and wStayOnTop) != 0:
    mbStyle = mbStyle or MB_TOPMOST

  gMessageDialog = self
  defer: gMessageDialog = nil

  self.mHook = SetWindowsHookEx(WH_CBT, wMessageDialog_CBTProc, 0, GetCurrentThreadId())
  result = case MessageBox(hOwner, self.mMessage, self.mCaption, mbStyle)
  of IDABORT: wIdAbort
  of IDCANCEL: wIdCancel
  of IDCONTINUE: wIdContinue
  of IDIGNORE: wIdIgnore
  of IDNO: wIdNo
  of IDRETRY: wIdRetry
  of IDTRYAGAIN: wIdTryAgain
  of IDYES: wIdYes
  else: wIdOk

  self.dialogQuit()

proc display*(self: wMessageDialog): wId {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the selected button id.
  ## For wMessageDialog class, this function is the same as showModal().
  result = self.showModal()
