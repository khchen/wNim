#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This is the base class for a common dialogs.
#
## :Superclass:
##   `wWindow <wWindow.html>`_
#
## :Subclasses:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
##   `wFontDialog <wFontDialog.html>`_
##   `wTextEntryDialog <wTextEntryDialog.html>`_
##   `wPasswordEntryDialog <wPasswordEntryDialog.html>`_
##   `wFindReplaceDialog <wFindReplaceDialog.html>`_
##   `wPageSetupDialog <wPageSetupDialog.html>`_
##   `wPrintDialog <wPrintDialog.html>`_
#
## :Seealso:
##   `wDialogEvent <wDialogEvent.html>`_

{.experimental, deadCodeElim: on.}

import ../wBase, ../wWindow, ../gdiobjects/wFont
export wWindow

proc getOwner*(self: wDialog): wWindow {.validate, property, inline.} =
  ## Returns the owner window of the dialog. The result may be nil.
  result = self.mOwner

proc dialogQuit(self: wDialog) {.shield.} =
  # a dialog must post wEvent_AppQuit message (just like a wWindow does in wWindow_DoDestroy)
  # so that the app will end correctly when a "no owner" dialog closed.

  if self.mOwner == nil:
    PostMessage(0, wEvent_AppQuit, 0, self.mHwnd)

proc wDialogHookProc(self: wDialog, hwnd: HWND, msg: UINT, wParam: WPARAM,
    lParam: LPARAM): UINT_PTR {.shield.} =

  case msg
  of WM_INITDIALOG:
    self.mHwnd = hwnd
    let event = Event(window=self, msg=wEvent_DialogCreated)
    self.processEvent(event)

  of WM_COMMAND:
    # handle help button here is much better than "commdlg_help" message
    # 1. don't need connect/disconnect to owner's event table
    # 2. avoid but in PageSetupDlg (lparam don't point to TPAGESETUPDLG)
    # 3. don't even need a owner to work
    # only drawback is: wFileDialog not support becasue no way to hook
    if HIWORD(int32 wParam) == BN_CLICKED and LOWORD(int32 wParam) == 1038:
      let event = Event(self, wEvent_DialogHelp)
      self.processEvent(event)

  of WM_DESTROY:
    let event = Event(window=self, msg=wEvent_DialogClosed)
    self.processEvent(event)
    self.dialogQuit()

  of WM_NCDESTROY:
    self.release()

  else: discard

  # MSDN: If the hook procedure returns zero, the default dialog box procedure processes the message.
  # If the hook procedure returns a nonzero value, the default dialog box procedure ignores the message.
  if self.processMessage(msg, wParam, lParam):
    return TRUE

proc final(self: wDialog) {.shield.} =
  # Default finalizer for wDialog.
  discard

proc init(self: wDialog, owner: wWindow) {.shield.} =
  # Initializer.
  self.initBase()
  self.mOwner = owner # may be nil
  self.mBackgroundColor = wDefaultColor
  self.mForegroundColor = wDefaultColor
  self.mFont = wNormalFont
