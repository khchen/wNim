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
##   `wTextEnterDialog <wTextEnterDialog.html>`_
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
##   `wFontDialog <wFontDialog.html>`_
##   `wFindReplaceDialog <wFindReplaceDialog.html>`_

proc final*(self: wPasswordEntryDialog) =
  ## Default finalizer for wPasswordEntryDialog.
  discard

proc PasswordEntryDialog*(parent: wWindow = nil, message = "Input password",
    caption = "", value = "", style: wStyle = wDefaultDialogStyle,
    pos = wDefaultPoint): wPasswordEntryDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, message, caption, value, style, pos)
