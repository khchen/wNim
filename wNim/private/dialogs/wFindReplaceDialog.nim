#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## wFindReplaceDialog is a standard modeless dialog which is used to allow the
## user to search for some text (and possibly replace it with something else).
## Note that unlike for the other standard dialogs this one must have a parent
## window. Also note that there is no way to use this dialog in a modal way;
## it is always, by design and implementation, modeless.
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
##   `wFontDialog <wFontDialog.html>`_
##   `wTextEnterDialog <wTextEnterDialog.html>`_
##   `wPasswordEntryDialog <wPasswordEntryDialog.html>`_
#
## :Flags:
##   ==============================  =============================================================
##   Flags                           Description
##   ==============================  =============================================================
##   wFrReplace                      Replace dialog (otherwise find dialog).
##   wFrNoUpdown                     Disables the search direction radio buttons (find dialog).
##   wFrNoMatchcase                  Disables the match case check box.
##   wFrNoWholeword                  Disables the whole word check box.
##   wFrHideUpdown                   Hides the search direction radio buttons (find dialog).
##   wFrHideMatchcase                Hides the match case check box.
##   wFrHideWholeword                Hides the whole word check box.
##   wFrDown                         The down button of the direction radio buttons is selected.
##   wFrWholeword                    The whole word check box is selected.
##   wFrMatchcase                    The match case check box is selected.
##   ==============================  =============================================================

const
  wFrReplace* = 0x20000
  wFrNoUpdown* = FR_NOUPDOWN
  wFrNoMatchcase* = FR_NOMATCHCASE
  wFrNoWholeword* = FR_NOWHOLEWORD
  wFrHideUpdown* = FR_HIDEUPDOWN
  wFrHideMatchcase* = FR_HIDEMATCHCASE
  wFrHideWholeword* = FR_HIDEWHOLEWORD
  wFrDown* = FR_DOWN
  wFrWholeword* = FR_WHOLEWORD
  wFrMatchcase* = FR_MATCHCASE
  wFrMask = FR_NOUPDOWN or FR_NOMATCHCASE or FR_NOWHOLEWORD or FR_HIDEUPDOWN or
    FR_HIDEMATCHCASE or FR_HIDEWHOLEWORD or FR_DOWN or FR_WHOLEWORD or FR_MATCHCASE

proc final*(self: wFindReplaceDialog) =
  ## Default finalizer for wFindReplaceDialog.
  discard

proc wFindReplaceHookProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): UINT_PTR
    {.stdcall.} =
  case msg
  of WM_DESTROY:
    let pFr = cast[ptr FINDREPLACE](GetWindowLongPtr(hwnd, GWLP_USERDATA))
    let self = cast[wFindReplaceDialog](pFr.lCustData)

    let event = wDialogEvent Event(window=self.mFrame, msg=wEvent_DialogClosed)
    event.mDialog = self
    self.mFrame.processEvent(event)

  of WM_NCDESTROY:
    wAppWindowDelete(hwnd)

  of WM_INITDIALOG:
    # lParam point to FINDREPLACE
    SetWindowLongPtr(hwnd, GWLP_USERDATA, lParam)
    return TRUE

  else: discard

proc init*(self: wFindReplaceDialog, parent: wWindow, flags: int = 0) {.validate.} =
  ## Initializer.
  wValidate(parent)
  self.mParent = parent
  self.mFlags = flags
  self.mFindString = T(1024)
  self.mReplaceString = T(1024)

proc create(self: wFindReplaceDialog): wFrame =
  # create a dummy frame for the dialog
  let frame = Frame(owner=self.mParent)
  frame.setSize(self.mParent.getRect())

  let pFr = &self.mFindReplace
  zeroMem(pFr, sizeof(FINDREPLACE))
  pFr.lStructSize = sizeof(FINDREPLACE)
  pFr.hwndOwner = frame.mHwnd
  pFr.lpstrFindWhat = &self.mFindString
  pFr.lpstrReplaceWith = &self.mReplaceString
  pFr.wFindWhatLen = WORD self.mFindString.len
  pFr.wReplaceWithLen = WORD self.mReplaceString.len
  pFr.Flags = self.mFlags and wFrMask or FR_ENABLEHOOK
  pFr.lpfnHook = wFindReplaceHookProc
  pFr.lCustData = cast[LPARAM](self)

  let findMsgId = RegisterWindowMessage(FINDMSGSTRING)
  frame.systemConnect(findMsgId) do (event: wEvent):
    # save the current state.
    self.mFlags = (self.mFlags and wFrReplace) or (pFr.Flags and wFrMask)

    if (pFr.Flags and FR_DIALOGTERM) != 0:
      # delete the dummy frame will cause it's child, aka. the actually find
      # dialog also be deleted. and then it's WM_DESTROY occur.
      frame.delete()

    elif (pFr.Flags and FR_FINDNEXT) != 0:
      let event = wDialogEvent Event(window=frame, msg=wEvent_FindNext)
      event.mDialog = self
      frame.processEvent(event)

    elif (pFr.Flags and FR_REPLACE) != 0:
      let event = wDialogEvent Event(window=frame, msg=wEvent_Replace)
      event.mDialog = self
      frame.processEvent(event)

    elif (pFr.Flags and FR_REPLACEALL) != 0:
      let event = wDialogEvent Event(window=frame, msg=wEvent_ReplaceAll)
      event.mDialog = self
      frame.processEvent(event)

  if (self.mFlags and wFrReplace) != 0:
    self.mHdlg = ReplaceText(pFr)
  else:
    self.mHdlg = FindText(pFr)

  if self.mHdlg != 0:
    wAppTopLevelWindowAdd(self.mHdlg)
    result = frame

proc FindReplaceDialog*(parent: wWindow, flags: int = 0): wFindReplaceDialog
    {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, flags)

proc setFlags*(self: wFindReplaceDialog, flags: int) {.validate, property, inline.} =
  ## Set the flags to use to initialize the controls of the dialog.
  self.mFlags = flags

proc getFlags*(self: wFindReplaceDialog): int {.validate, property, inline.} =
  ## Get the combination of flag values.
  result = self.mFlags

proc setFindString*(self: wFindReplaceDialog, str: string) {.validate, property, inline.} =
  ## Set the string to find (used as initial value by the dialog).
  self.mFindString <<< T(str)

proc getFindString*(self: wFindReplaceDialog): string {.validate, property, inline.} =
  ## Get the string to find.
  result = $self.mFindString
  result.nullTerminate

proc setReplaceString*(self: wFindReplaceDialog, str: string) {.validate, property, inline.} =
  ## Set the replacement string (used as initial value by the dialog).
  self.mReplaceString <<< T(str)

proc getReplaceString*(self: wFindReplaceDialog): string {.validate, property, inline.} =
  ## Get the replacement string.
  result = $self.mReplaceString
  result.nullTerminate

proc isDownward*(self: wFindReplaceDialog): bool {.validate, inline.} =
  ## Check whether downward search/replace selected.
  result = (self.mFlags and wFrDown) != 0

proc isWholeword*(self: wFindReplaceDialog): bool {.validate, inline.} =
  ## Check whether whole word search/replace selected.
  result = (self.mFlags and wFrWholeword) != 0

proc isMatchcase*(self: wFindReplaceDialog): bool {.validate, inline.} =
  ## Case whether sensitive search/replace selected.
  result = (self.mFlags and wFrMatchcase) != 0

proc showModaless*(self: wFindReplaceDialog) {.validate.} =
  ## Shows the dialog in modaless mode. The frame of this dialog will recieve
  ## wEvent_DialogClosed event when the dialog is closed.
  if self.mFrame == nil:
    self.mFrame = self.create()

    self.mFrame.systemConnect(wEvent_Destroy) do (event: wEvent):
      self.mFrame = nil

  if self.mHdlg != 0:
    ShowWindow(self.mHdlg, SW_SHOWNORMAL)

proc close*(self: wFindReplaceDialog) {.validate, inline.} =
  ## Close a modaless dialog.
  if self.mFrame != nil:
    self.mFrame.delete()

proc getFrame*(self: wFindReplaceDialog): wFrame {.validate, property, inline.} =
  ## Gets the wFrame object for a modaless dialog. For wFindReplaceDialog, the
  ## frame is just a dummy. So don't use this unless you know what you are doing.
  result = self.mFrame

proc getHandle*(self: wFindReplaceDialog): HWND {.validate, property, inline.} =
  ## Returns the system HWND of this dialog. This function seems useless, but
  ## maybe someday we need it, who knows?
  result = self.mHdlg

template connect*(self: wFindReplaceDialog, msg: UINT,
    handler: wEventHandler): untyped =
  ## Syntax sugar: dialog.frame.connect() => dialog.connect().
  self.mFrame.connect(msg, handler)

template connect*(self: wFindReplaceDialog, msg: UINT,
    handler: wEventNeatHandler): untyped =
  ## Syntax sugar: dialog.frame.connect() => dialog.connect().
  self.mFrame.connect(msg, handler)

template `.`*(self: wFindReplaceDialog, msg: UINT,
    handler: wEventHandler): untyped =
  ## Syntax sugar: dialog.frame.wEvent_DialogClosed => dialog.wEvent_DialogClosed.
  self.connect(msg, handler)

template `.`*(self: wFindReplaceDialog, msg: UINT,
    handler: wEventNeatHandler): untyped =
  ## Syntax sugar: dialog.frame.wEvent_DialogClosed => dialog.wEvent_DialogClosed.
  self.connect(msg, handler)

template disconnect*(self: wFindReplaceDialog, msg: UINT, limit = -1): untyped =
  ## Syntax sugar: dialog.frame.disconnect() => dialog.disconnect().
  self.mFrame.disconnect(msg, limit)

template disconnect*(self: wFindReplaceDialog, connection: wEventConnection): untyped =
  ## Syntax sugar: dialog.frame.disconnect() => dialog.disconnect().
  self.mFrame.disconnect(connection)
