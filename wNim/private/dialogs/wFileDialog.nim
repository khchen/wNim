#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class represents the file chooser dialog. Only modal dialog is supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wFdOpen                         This is an open dialog.
##   wFdSave                         This is a save dialog.
##   wFdOverwritePrompt              Pprompt for a confirmation if a file will be overwritten.
##   wFdCreatePrompt                 Pprompt for a confirmation if a file will be create.
##   wFdNoFollow                     Directs the dialog to return the path and file name of the selected
##                                   shortcut file, not its target as it does by default.
##   wFdFileMustExist                The user may only select files that actually exist.
##   wFdMultiple                     Allows selecting multiple files.
##   ==============================  =============================================================

include ../pragma
import strutils
import ../wBase, wDialog
export wDialog

const
  wFdOpen* = 0
  wFdSave* = 0x1.int64 shl 32
  wFdOverwritePrompt* = OFN_OVERWRITEPROMPT
  wFdCreatePrompt* = OFN_CREATEPROMPT
  wFdNoFollow* = OFN_NODEREFERENCELINKS
  wFdFileMustExist* = OFN_FILEMUSTEXIST
  wFdMultiple* = OFN_ALLOWMULTISELECT
  wFdMaxPath = 65536

wClass(wFileDialog of wDialog):

  proc init*(self: wFileDialog, owner: wWindow = nil, message = "", defaultDir = "",
      defaultFile = "", wildcard = "*.*", style: wStyle = wFdOpen) {.validate.} =
    ## Initializer.
    self.wDialog.init(owner)
    self.mMessage = message
    self.mDefaultDir = defaultDir
    self.mDefaultFile = defaultFile
    self.mWildcard = wildcard
    self.mStyle = style

proc getMessage*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = self.mMessage

proc getDirectory*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the default directory.
  result = self.mDefaultDir

proc getFilename*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the default filename.
  result = self.mDefaultFile

proc getWildcard*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the file dialog wildcard.
  result = self.mWildcard

proc getFilterIndex*(self: wFileDialog): int {.validate, property, inline.} =
  ## Returns the index into the list of filters supplied.
  ## Before the dialog is shown, this is the index which will be used.
  ## After the dialog is shown, this is the index selected by the user.
  result = self.mFilterIndex

proc getPath*(self: wFileDialog): string {.validate, property, inline.} =
  ## Returns the full path (directory and filename) of the selected file.
  ## If the user selects multiple files, this only return the directory.
  ## If the dialog is cancelled, the return value is nil.
  result = self.mPath

proc getPaths*(self: wFileDialog): seq[string] {.validate, property, inline.} =
  ## Returns a seq to full paths of the files chosen.
  ## If the dialog is cancelled, the return value is empty seq (@[]).
  result = self.mPaths

proc setMessage*(self: wFileDialog, message: string) {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  self.mMessage = message

proc setDirectory*(self: wFileDialog, defaultDir: string) {.validate, property, inline.} =
  ## Sets the default directory.
  self.mDefaultDir = defaultDir

proc setFilename*(self: wFileDialog, defaultFile: string) {.validate, property, inline.} =
  ## Sets the default filename.
  self.mDefaultFile = defaultFile

proc setWildcard*(self: wFileDialog, wildcard: string) {.validate, property, inline.} =
  ## Sets the wildcard, which can contain multiple file types,
  ## for example: "BMP files (\*.bmp)|\*.bmp|JPEG files (\*.jpg, \*.jpeg)|\*.jpg;\*.jpeg".
  self.mWildcard = wildcard

proc setFilterIndex*(self: wFileDialog, index: int) {.validate, property, inline.} =
  ## Sets the default filter index, starting from one.
  self.mFilterIndex = index

proc showModal*(self: wFileDialog): wId {.validate, discardable.} =
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
      nFilterIndex: self.mFilterIndex)

  buffer << T(self.mDefaultFile)

  ofn.Flags = OFN_EXPLORER or OFN_NOCHANGEDIR or
    cast[DWORD](self.mStyle and 0xffffffff)

  if self.mOwner != nil:
    ofn.hwndOwner = self.mOwner.mHwnd

  if self.mDefaultDir.len != 0:
    ofn.lpstrInitialDir = &T(self.mDefaultDir)

  if self.mMessage.len != 0:
    ofn.lpstrTitle = &T(self.mMessage)

  if self.mWildcard.len != 0:
    ofn.lpstrFilter = &T(self.mWildcard.replace('|', '\0') & '\0')

  var isOk =
    if (self.mStyle and wFdSave) != 0:
      GetSaveFileName(&ofn)
    else:
      GetOpenFileName(&ofn)

  self.dialogQuit()

  self.mPaths = @[]
  self.mPath = ""
  self.mFilterIndex = ofn.nFilterIndex

  if isOk:
    var str = $buffer # convert to utf8
    var first = true

    let term = if (ofn.Flags and OFN_ALLOWMULTISELECT) == 0: "\0" else: "\0\0"
    str.setLen(str.find(term))

    for name in str.split('\0'):
      if first:
        self.mPath = name
        first = false
      else:
        var path = self.mPath
        if path.len > 0 and path[^1] != '\\': path.add '\\'
        path.add name

        self.mPaths.add(path)

    # if only one file choosed, add it to paths
    if self.mPaths.len == 0:
      self.mPaths.add(self.mPath)

    result = wIdOk
  else:
    result = wIdCancel

proc display*(self: wFileDialog): seq[string] {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the selected files or @[].
  if self.showModal() == wIdOk:
    result = self.getPaths()
