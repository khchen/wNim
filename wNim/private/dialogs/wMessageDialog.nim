#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A dialog that shows a single or multi-line message, with a choice of OK, Yes,
## No and Cancel buttons.
#
## :Seealso:
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
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
  # wStayOnTop* = int64 WS_EX_TOPMOST shl 32

proc final*(self: wMessageDialog) =
  ## Default finalizer for wMessageDialog.
  discard

proc init*(self: wMessageDialog, parent: wWindow = nil, message: string = "" ,
    caption: string = "", style: wStyle = wOK) {.validate.} =
  ## Initializer.
  wValidate(message, caption)
  self.mParent = parent
  self.mMessage = message
  self.mCaption = caption
  self.mStyle = style
  self.mLabelText = initTable[INT, string]()

proc MessageDialog*(parent: wWindow = nil, message: string = "" ,
    caption: string = "", style: wStyle = wOK): wMessageDialog {.inline.} =
  ## Constructor specifying the message box properties.
  wValidate(message, caption)
  new(result, final)
  result.init(parent, message, caption, style)

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
  wValidate(message)
  self.mMessage = message

proc setCaption*(self: var wMessageDialog, caption: string) {.validate, property, inline.} =
  ## Sets the caption that will be displayed on the dialog.
  wValidate(caption)
  self.mCaption = caption

proc setStyle*(self: var wMessageDialog, style: wStyle) {.validate, property, inline.} =
  ## Sets the style of the dialog.
  self.mStyle = style

proc setOKLabel*(self: wMessageDialog, ok: string) {.validate, property, inline.} =
  ## Overrides the default labels of the OK button.
  wValidate(ok)
  self.mLabelText[IDOK] = ok

proc setOKCancelLabels*(self: wMessageDialog, ok: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the OK and Cancel buttons.
  wValidate(ok, cancel)
  self.mLabelText[IDOK] = ok
  self.mLabelText[IDCANCEL] = cancel

proc setYesNoCancelLabels*(self: wMessageDialog, yes: string, no: string,
    cancel: string) {.validate, property, inline.} =
  ## Overrides the default labels of the Yes, No and Cancel buttons.
  wValidate(yes, no, cancel)
  self.mLabelText[IDYES] = yes
  self.mLabelText[IDNO] = no
  self.mLabelText[IDCANCEL] = cancel

proc setYesNoLabels*(self: wMessageDialog, yes: string, no: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the Yes and No buttons.
  wValidate(yes, no)
  self.mLabelText[IDYES] = yes
  self.mLabelText[IDNO] = no

proc setRetryCancelLabels*(self: wMessageDialog, retry: string, cancel: string)
    {.validate, property, inline.} =
  ## Overrides the default labels of the Retry and Cancel buttons.
  wValidate(retry, cancel)
  self.mLabelText[IDRETRY] = retry
  self.mLabelText[IDCANCEL] = cancel

proc setAbortRetryIgnoreLabels*(self: wMessageDialog, abort: string,
    retry: string, ignore: string) {.validate, property, inline.} =
  ## Overrides the default labels of the Abort, Retry and Ignore buttons.
  wValidate(abort, retry, ignore)
  self.mLabelText[IDABORT] = abort
  self.mLabelText[IDRETRY] = retry
  self.mLabelText[IDIGNORE] = ignore

proc setCancelTryContinueLabels*(self: wMessageDialog, cancel: string,
    tryagain: string, cont: string) {.validate, property, inline.} =
  ## Overrides the default labels of the Cancel, Try Again and Continue buttons.
  wValidate(cancel, tryagain, cont)
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

proc showModal*(self: wMessageDialog): wId {.discardable.} =
  ## Shows the dialog, returning one of wIdOk, wIdYes, wIdNo, wIdCancel,
  ## wIdTryAgain, wIdContinue, wIdAbort, wIdRetry or wIdIgnore.
  var
    hParent: HWND
    mbStyle = cast[DWORD](self.mStyle and 0xFFFFFFFF)

  if self.mParent != nil:
    hParent = self.mParent.mHwnd
    mbStyle = mbStyle or MB_APPLMODAL
  else:
    mbStyle = mbStyle or MB_TASKMODAL

  if (self.mStyle and wStayOnTop) != 0:
    mbStyle = mbStyle or MB_TOPMOST

  gMessageDialog = self
  defer: gMessageDialog = nil

  self.mHook = SetWindowsHookEx(WH_CBT, wMessageDialog_CBTProc, 0, GetCurrentThreadId())
  result = case MessageBox(hParent, self.mMessage, self.mCaption, mbStyle)
  of IDABORT: wIdAbort
  of IDCANCEL: wIdCancel
  of IDCONTINUE: wIdContinue
  of IDIGNORE: wIdIgnore
  of IDNO: wIdNo
  of IDRETRY: wIdRetry
  of IDTRYAGAIN: wIdTryAgain
  of IDYES: wIdYes
  else: wIdOk

proc show*(self: wMessageDialog): wId {.inline, discardable.} =
  ## The same as ShowModal().
  result = self.showModal()
