#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## This class represents the file chooser dialog.
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wFdOpen                         This is an open dialog.
##   wFdSave                         This is a save dialog.
##   wFdOverwritePrompt              Pprompt for a confirmation if a file will be overwritten.
##   wFdCreatePrompt                 Pprompt for a confirmation if a file will be create.
##   wFdNoFollow                     Directs the dialog to return the path and file name of the selected shortcut file, not its target as it does by default.
##   wFdFileMustExist                The user may only select files that actually exist.
##   wFdMultiple                     Allows selecting multiple files.
##   ==============================  =============================================================

const
  wFdOpen* = 0
  wFdSave* = 0x1 shl 32
  wFdOverwritePrompt* = OFN_OVERWRITEPROMPT
  wFdCreatePrompt* = OFN_CREATEPROMPT
  wFdNoFollow* = OFN_NODEREFERENCELINKS
  wFdFileMustExist* = OFN_FILEMUSTEXIST
  wFdMultiple* = OFN_ALLOWMULTISELECT
  wFdMaxPath = 65536

proc final*(self: wFileDialog) =
  ## Default finalizer for wFileDialog.
  discard

proc init*(self: wFileDialog, parent: wWindow = nil, message: string = nil,
    defaultDir: string = nil, defaultFile: string = nil, wildcard = "*.*",
    style: wStyle = wFdOpen) {.validate.} =
  ## Initializer.
  mParent = parent
  mMessage = message
  mDefaultDir = defaultDir
  mDefaultFile = defaultFile
  mWildcard = wildcard
  mStyle = style

proc FileDialog*(parent: wWindow = nil, message: string = nil,
    defaultDir: string = nil, defaultFile: string = nil, wildcard = "*.*",
    style: wStyle = wFdOpen): wFileDialog
    {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, message, defaultDir, defaultFile, wildcard, style)

proc getMessage*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = mMessage

proc getDirectory*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the default directory.
  result = mDefaultDir

proc getFilename*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the default filename.
  result = mDefaultFile

proc getWildcard*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the file dialog wildcard.
  result = mWildcard

proc getFilterIndex*(self: wFileDialog): int {.validate, property, inline.} =
  ## Returns the index into the list of filters supplied.
  ## Before the dialog is shown, this is the index which will be used.
  ## After the dialog is shown, this is the index selected by the user.
  result = mFilterIndex

proc getPath*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the full path (directory and filename) of the selected file.
  ## If the user selects multiple files, this only return the directory.
  ## If the dialog is cancelled, the return value is nil.
  result = mPath

proc getPaths*(self: wFileDialog): seq[string] {.validate, property, inline.} =
  ## Returns a seq to full paths of the files chosen.
  ## If the dialog is cancelled, the return value is empty seq (@[]).
  result = mPaths

proc setMessage*(self: wFileDialog, message: string) {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  mMessage = message

proc setDirectory*(self: wFileDialog, defaultDir: string) {.validate, property, inline.} =
  ## Sets the default directory.
  mDefaultDir = defaultDir

proc setFilename*(self: wFileDialog, defaultFile: string) {.validate, property, inline.} =
  ## Sets the default filename.
  mDefaultFile = defaultFile

proc setWildcard*(self: wFileDialog, wildcard: string) {.validate, property, inline.} =
  ## Sets the wildcard, which can contain multiple file types,
  ## for example: "BMP files (*.bmp)|*.bmp|GIF files (*.gif)|*.gif".
  mWildcard = wildcard

proc setFilterIndex*(self: wFileDialog, index: int) {.validate, property, inline.} =
  ## Sets the default filter index, starting from one.
  mFilterIndex = index

proc showModal*(self: wFileDialog): wId {.discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.

  # If use OFN_EXPLORER without OFN_ENABLEHOOK flag, the system in fact use
  # "Common Item Dialog" instaed of Explorer-style (test under windows 10).

  # There seems no way to hook the "Common Item Dialog", so we just let
  # the system decide the position of this dialog.
  # todo: provide hook to center this dialog in winxp?

  var
    buffer = T(wFdMaxPath)
    ofn = OPENFILENAME(
      lStructSize: sizeof(OPENFILENAME),
      lpstrFile: &buffer,
      nMaxFile: wFdMaxPath,
      nFilterIndex: mFilterIndex)

  ofn.Flags = OFN_EXPLORER or
    cast[DWORD](mStyle and 0xffffffff)

  if mParent != nil:
    ofn.hwndOwner = mParent.mHwnd

  if mDefaultDir != nil:
    ofn.lpstrInitialDir = &T(mDefaultDir)

  if mMessage != nil:
    ofn.lpstrTitle = &T(mMessage)

  if mWildcard != nil:
    ofn.lpstrFilter = &T(mWildcard.replace('|', '\0') & '\0')

  var isOk =
    if (mStyle and wFdSave) != 0:
      GetSaveFileName(&ofn)
    else:
      GetOpenFileName(&ofn)

  mPaths = @[]
  mPath = nil
  mFilterIndex = ofn.nFilterIndex

  if isOk:
    var str = $buffer # convert to utf8
    var first = true

    str.setLen(str.find("\0\0"))
    for name in str.split('\0'):
      if first:
        mPath = name
        first = false
      else:
        mPaths.add(mPath & "\\" & name)

    # if only one file choosed, add it to paths
    if mPaths.len == 0:
      mPaths.add(mPath)

    result = wIdOk
  else:
    result = wIdCancel

proc show*(self: wFileDialog): wId {.inline, discardable.} =
  ## The same as ShowModal().
  result = showModal()

proc showModalResult*(self: wFileDialog): seq[string] {.inline, discardable.} =
  ## Shows the dialog, returning the selected files or @[].
  if showModal() == wIdOk:
    result = getPaths()

proc showResult*(self: wFileDialog): seq[string] {.inline, discardable.} =
  ## The same as showModalResult().
  if show() == wIdOk:
    result = getPaths()
