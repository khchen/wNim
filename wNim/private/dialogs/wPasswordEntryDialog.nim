#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
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

include ../pragma
import ../wBase, ../wFrame, wDialog, wTextEntryDialog
export wDialog, wTextEntryDialog

wClass(wPasswordEntryDialog of wTextEntryDialog):

  proc init*(self: wPasswordEntryDialog, owner: wWindow = nil, message = "Input password",
      caption = "", value = "", style: wStyle = wDefaultDialogStyle,
      pos = wDefaultPoint) {.validate, inline.} =
    ## Initializer.
    self.wTextEntryDialog.init(owner, message, caption, value, style, pos)
