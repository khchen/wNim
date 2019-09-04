#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This class represents a dialog that requests a one-line password string
## from the user. Both modal or modaless dialog are supported.
#
## :Superclass:
##   `wTextEntryDialog <wTextEntryDialog.html>`_
#
## :Events:
##   `wDialogEvent <wDialogEvent.html>`_
##   ==============================   =============================================================
##   wDialogEvent                     Description
##   ==============================   =============================================================
##   wEvent_DialogCreated             When the dialog is created but not yet shown.
##   wEvent_DialogClosed              When the dialog is being closed.
##   ===============================  =============================================================

{.experimental, deadCodeElim: on.}

import ../wBase, ../wFrame, wDialog, wTextEntryDialog
export wDialog, wTextEntryDialog

proc final*(self: wPasswordEntryDialog) =
  ## Default finalizer for wPasswordEntryDialog.
  wTextEntryDialog(self).final()

proc init*(self: wPasswordEntryDialog, owner: wWindow = nil, message = "Input password",
    caption = "", value = "", style: wStyle = wDefaultDialogStyle,
    pos = wDefaultPoint) {.validate, inline.} =
  ## Initializer.
  self.wTextEntryDialog.init(owner, message, caption, value, style, pos)

proc PasswordEntryDialog*(owner: wWindow = nil, message = "Input password",
    caption = "", value = "", style: wStyle = wDefaultDialogStyle,
    pos = wDefaultPoint): wPasswordEntryDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(owner, message, caption, value, style, pos)
