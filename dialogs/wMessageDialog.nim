## A dialog that shows a single or multi-line message, with a choice of OK, Yes, No and Cancel buttons.
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wOk                             The message box contains one push button: OK. This is the default.
##    wYesNo                          The message box contains two push buttons: Yes and No.
##    wOkCancel                       The message box contains two push buttons: OK and Cancel.
##    wYesNoCancel                    The message box contains three push buttons: Yes, No, and Cancel.
##    wRetryCancel                    The message box contains two push buttons: Retry and Cancel.
##    wAbortRetryIgnore               The message box contains three push buttons: Abort, Retry, and Ignore.
##    wCancelTryContinue              The message box contains three push buttons: Cancel, Try Again, Continue.
##    wIconHand                       A stop-sign icon appears in the message box.
##    wIconErr                        A stop-sign icon appears in the message box.
##    wIconStop                       A stop-sign icon appears in the message box.
##    wIconQuestion                   A question-mark icon appears in the message box.
##    wIconExclamation                An exclamation-point icon appears in the message box.
##    wIconWarning                    An exclamation-point icon appears in the message box.
##    wIconInformation                An icon consisting of a lowercase letter i in a circle appears in the message box.
##    wIconAsterisk                   An icon consisting of a lowercase letter i in a circle appears in the message box.
##    wButton1_Default                The first button is the default button. This is the default.
##    wButton2_Default                The second button is the default button.
##    wButton3_Default                The third button is the default button.
##    wButton4_Default                The fourth button is the default button.
##    wStayOnTop                      The message box will stay on top of all other windows.
##    ==============================  =============================================================

var wMessageDialogPtr {.threadvar.}: ptr wMessageDialog

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
  # wStayOnTop* = WS_EX_TOPMOST shl 32

proc MessageDialog*(parent: wWindow = nil, message: string = "" ,
    caption: string = "", style: wStyle = wOK): wMessageDialog =
  ## Constructor specifying the message box properties.
  wValidate(message, caption)
  result.mParent = parent
  result.mMessage = message
  result.mCaption = caption
  result.mStyle = style

  # must use ref type here so that we can write MessageDialog().ShowModal()
  # and also let dlg = MessageDialog()
  result.mLabelText = newTable[INT, string]()
  new(result.mHookRef)

proc setMessage*(self: var wMessageDialog, message: string) {.property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  wValidate(message)
  mMessage = message

proc setCaption*(self: var wMessageDialog, caption: string) {.property, inline.} =
  ## Sets the caption that will be displayed on the dialog.
  wValidate(caption)
  mCaption = caption

proc setStyle*(self: var wMessageDialog, style: wStyle) {.property, inline.} =
  ## Sets the style of the dialog.
  mStyle = style

proc getMessage*(self: wMessageDialog): string {.property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = mMessage

proc getCaption*(self: wMessageDialog): string {.property, inline.} =
  ## Gets the caption that will be displayed on the dialog.
  result = mCaption

proc getStyle*(self: wMessageDialog): wStyle {.property, inline.} =
  ## Gets the style.
  result = mStyle

proc setOKLabel*(self: wMessageDialog, ok: string) {.property, inline.} =
  ## Overrides the default labels of the OK button.
  wValidate(ok)
  self.mLabelText[IDOK] = ok

proc setOKCancelLabels*(self: wMessageDialog, ok: string,
    cancel: string) {.property, inline.} =
  ## Overrides the default labels of the OK and Cancel buttons.
  wValidate(ok, cancel)
  self.mLabelText[IDOK] = ok
  self.mLabelText[IDCANCEL] = cancel

proc setYesNoCancelLabels*(self: wMessageDialog, yes: string, no: string,
    cancel: string) {.property, inline.} =
  ## Overrides the default labels of the Yes, No and Cancel buttons.
  wValidate(yes, no, cancel)
  self.mLabelText[IDYES] = yes
  self.mLabelText[IDNO] = no
  self.mLabelText[IDCANCEL] = cancel

proc setYesNoLabels*(self: wMessageDialog, yes: string,
    no: string) {.property, inline.} =
  ## Overrides the default labels of the Yes and No buttons.
  wValidate(yes, no)
  self.mLabelText[IDYES] = yes
  self.mLabelText[IDNO] = no

proc setRetryCancelLabels*(self: wMessageDialog, retry: string,
    cancel: string) {.property, inline.} =
  ## Overrides the default labels of the Retry and Cancel buttons.
  wValidate(retry, cancel)
  self.mLabelText[IDRETRY] = retry
  self.mLabelText[IDCANCEL] = cancel

proc setAbortRetryIgnoreLabels*(self: wMessageDialog, abort: string,
    retry: string, ignore: string) {.property, inline.} =
  ## Overrides the default labels of the Abort, Retry and Ignore buttons.
  wValidate(abort, retry, ignore)
  self.mLabelText[IDABORT] = abort
  self.mLabelText[IDRETRY] = retry
  self.mLabelText[IDIGNORE] = ignore

proc setCancelTryContinueLabels*(self: wMessageDialog, cancel: string,
    tryagain: string, cont: string) {.property, inline.} =
  ## Overrides the default labels of the Cancel, Try Again and Continue buttons.
  wValidate(cancel, tryagain, cont)
  self.mLabelText[IDCANCEL] = cancel
  self.mLabelText[IDTRYAGAIN] = tryagain
  self.mLabelText[IDCONTINUE] = cont

proc wMessageDialog_CBTProc(nCode: INT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  let ret = CallNextHookEx(0, nCode, wParam, lParam)
  defer: result = ret # avoid contaminate result

  if nCode == HCBT_ACTIVATE:
    let self = wMessageDialogPtr[]
    UnhookWindowsHookEx(self.mHookRef[])

    for key, value in self.mLabelText:
      let buttonHwnd = GetDlgItem(HWND wParam, key)
      if buttonHwnd != 0:
        SetWindowText(buttonHwnd, value)

    # we can subclass this messagebox, but what to do?
    # let win = Window(HWND wParam)

proc showModal*(self: wMessageDialog): wId {.discardable.} =
  ## Shows the dialog, returning one of wID_OK, wID_YES, wID_NO, wID_CANCEL,
  ## wID_TRYAGAIN, wID_CONTINUE, wID_ABORT, wID_RETRY or wID_IGNORE.
  var
    hParent: HWND
    mbStyle = cast[DWORD](mStyle and 0xFFFFFFFF)

  if mParent != nil:
    hParent = mParent.mHwnd
    mbStyle = mbStyle or MB_APPLMODAL
  else:
    mbStyle = mbStyle or MB_TASKMODAL

  if (mStyle and wStayOnTop) != 0:
    mbStyle = mbStyle or MB_TOPMOST

  mHookRef[] = SetWindowsHookEx(WH_CBT, wMessageDialog_CBTProc, 0, GetCurrentThreadId())
  wMessageDialogPtr = &self
  result = case MessageBox(hParent, mMessage, mCaption, mbStyle)
  of IDABORT: wID_ABORT
  of IDCANCEL: wID_CANCEL
  of IDCONTINUE: wID_CONTINUE
  of IDIGNORE: wID_IGNORE
  of IDNO: wID_NO
  of IDRETRY: wID_RETRY
  of IDTRYAGAIN: wID_TRYAGAIN
  of IDYES: wID_YES
  else: wID_OK

proc show*(self: wMessageDialog): wId {.inline, discardable.} =
  ## The same as ShowModal().
  result = showModal()
