#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## wFindReplaceDialog is a standard modeless dialog which is used to allow the
## user to search for some text (and possibly replace it with something else).
## Note that unlike for the other standard dialogs this one must have a owner
## window. Also note that there is no way to use this dialog in a modal way;
## it is always, by design and implementation, modeless.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
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
#
## :Events:
##   `wDialogEvent <wDialogEvent.html>`_
##   ==============================   =============================================================
##   wDialogEvent                     Description
##   ==============================   =============================================================
##   wEvent_DialogCreated             When the dialog is created but not yet shown.
##   wEvent_DialogClosed              When the dialog is being closed.
##   wEvent_DialogHelp                When the Help button is pressed.
##   wEvent_FindNext                  When find next button was pressed.
##   wEvent_Replace                   When replace button was pressed.
##   wEvent_ReplaceAll                When replace all button was pressed .
##   ===============================  =============================================================

include ../pragma
import ../wBase, wDialog
export wDialog

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

proc setFlags*(self: wFindReplaceDialog, flags: int) {.validate, property, inline.} =
  ## Set the flags to use to initialize the controls of the dialog.
  self.mFr.Flags = (flags and (not wFrReplace)) or FR_ENABLEHOOK
  self.mIsReplace = (flags and wFrReplace) != 0

proc getFlags*(self: wFindReplaceDialog): int {.validate, property, inline.} =
  ## Get the combination of flag values.
  result = self.mFr.Flags or (if self.mIsReplace: wFrReplace else: 0)

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
  result = (self.mFr.Flags and wFrDown) != 0

proc isWholeword*(self: wFindReplaceDialog): bool {.validate, inline.} =
  ## Check whether whole word search/replace selected.
  result = (self.mFr.Flags and wFrWholeword) != 0

proc isMatchcase*(self: wFindReplaceDialog): bool {.validate, inline.} =
  ## Case whether sensitive search/replace selected.
  result = (self.mFr.Flags and wFrMatchcase) != 0

proc enableHelp*(self: wFindReplaceDialog, flag = true) =
  ## Display a Help button, the dialog got wEvent_DialogHelp event when the
  ## button pressed.
  if flag:
    self.mFr.Flags = self.mFr.Flags or FR_SHOWHELP
  else:
    self.mFr.Flags = self.mFr.Flags and (not FR_SHOWHELP)

proc enableFindEvent(self: wFindReplaceDialog, flag = true) =
  # enable must be called when WM_INITDIALOG, and disable when WM_NCDESTROY
  # so that gc will collect "self" object and destructor will be called.
  assert self.mOwner != nil
  if flag:
    let findMsgId = RegisterWindowMessage(FINDMSGSTRING)
    self.mMsgConn = self.mOwner.systemConnect(findMsgId) do (event: wEvent):
      let pFr = &self.mFr
      if event.mLparam != cast[LPARAM](pFr): return

      if (pFr.Flags and FR_DIALOGTERM) != 0:
        # the system won't delete the dialog, let's do it by ourself, so that
        # WM_DESTROY/WM_NCDESTROY occur
        DestroyWindow(self.mHwnd)

      elif (pFr.Flags and FR_FINDNEXT) != 0:
        let event = Event(window=self, msg=wEvent_FindNext)
        self.processEvent(event)

      elif (pFr.Flags and FR_REPLACE) != 0:
        let event = Event(window=self, msg=wEvent_Replace)
        self.processEvent(event)

      elif (pFr.Flags and FR_REPLACEALL) != 0:
        let event = Event(window=self, msg=wEvent_ReplaceAll)
        self.processEvent(event)

  else:
    self.mOwner.systemDisconnect(self.mMsgConn)
    free(self[])

proc wFindReplaceHookProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): UINT_PTR
    {.stdcall.} =
  var self = cast[wFindReplaceDialog](GetWindowLongPtr(hwnd, GWLP_USERDATA))

  case msg
  of WM_INITDIALOG:
    self = cast[wFindReplaceDialog](cast[ptr FINDREPLACE](lParam).lCustData)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LPARAM](self))
    assert self != nil

    # add to wnim's top level window table so that wnim's modal works
    wAppTopLevelWindowAdd(hwnd)

    # handle FINDMSGSTRING event
    self.enableFindEvent(true)

  of WM_DESTROY:
    # WM_DESTROY instead of WM_NCDESTROY so that the following codes run before dialogQuit()
    assert self != nil
    self.enableFindEvent(false)
    wAppWindowDelete(hwnd)
    self.mHwnd = 0

  else: discard

  if self != nil:
    result = self.wDialogHookProc(hwnd, msg, wParam, lParam)

wClass(wFindReplaceDialog of wDialog):

  proc init*(self: wFindReplaceDialog, owner: wWindow, flags: int = 0) {.validate.} =
    ## Initializer.
    wValidate(owner)
    self.wDialog.init(owner)
    self.mFindString = T(1024)
    self.mReplaceString = T(1024)
    self.mFr = FINDREPLACE(
      lStructSize: sizeof(FINDREPLACE),
      lpfnHook: wFindReplaceHookProc,
      lCustData: cast[LPARAM](self),
      lpstrFindWhat: &self.mFindString,
      lpstrReplaceWith: &self.mReplaceString,
      wFindWhatLen: WORD self.mFindString.len,
      wReplaceWithLen: WORD self.mReplaceString.len,
      hwndOwner: owner.mHwnd)

    self.setFlags(flags)

proc showModaless*(self: wFindReplaceDialog) {.validate.} =
  ## Shows the dialog in modaless mode. The frame of this dialog will recieve
  ## wEvent_DialogClosed event when the dialog is closed.
  if self.mHwnd == 0:
    if self.mIsReplace:
      self.mHwnd = ReplaceText(&self.mFr)
    else:
      self.mHwnd = FindText(&self.mFr)

  ShowWindow(self.mHwnd, SW_SHOWNORMAL)
