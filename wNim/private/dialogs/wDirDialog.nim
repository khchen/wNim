#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This class represents the directory chooser dialog.
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wDdDirMustExist                 The dialog will allow the user to choose only an existing folder.
##   wDdChangeDir                    Change the current working directory to the directory chosen by the user.
##   wDdXpCompatible                 Use the Windows XP compatible UI as the dialog.
##   ==============================  =============================================================

const
  wDdDirMustExist* = 1
  wDdChangeDir* = 2
  wDdXpCompatible* = 4

proc final*(self: wDirDialog) =
  ## Default finalizer for wDirDialog.
  discard

proc init*(self: wDirDialog, parent: wWindow = nil, message = "",
    defaultPath = "", style: wStyle = 0) {.validate.} =
  ## Initializer.
  self.mParent = parent
  self.mMessage = message
  self.mPath = defaultPath
  self.mStyle = style

proc DirDialog*(parent: wWindow = nil, message = "", defaultPath = "",
    style: wStyle = 0): wDirDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, message, defaultPath, style)

proc getPath*(self: wDirDialog): string {.validate, property, inline.} =
  ## Returns the default or user-selected path.
  result = self.mPath

proc getMessage*(self: wDirDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = self.mMessage

proc setPath*(self: wDirDialog, path: string) {.validate, property, inline.} =
  ## Sets the default path.
  self.mPath = path

proc setMessage*(self: var wDirDialog, message: string)
    {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  self.mMessage = message

when not defined(useWinXP):
  proc showModal_VistaLaster(self: wDirDialog): wId =
    var
      dialog: ptr IFileOpenDialog
      item: ptr IShellItem
      folder: ptr IShellItem
      filePath: PWSTR

    try:
      if CoCreateInstance(&CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
        &IID_IFileOpenDialog, cast[ptr PVOID](&dialog)).FAILED: raise
      defer: dialog.Release()

      if dialog.SetOptions(FOS_PICKFOLDERS or FOS_FORCEFILESYSTEM).FAILED: raise

      if self.mMessage.len != 0:
        if dialog.SetTitle(self.mMessage).FAILED: raise

      if self.mPath.len != 0:
        if SHCreateItemFromParsingName(self.mPath, nil, &IID_IShellItem,
          cast[ptr PVOID](&folder)).FAILED: raise

        if dialog.SetFolder(folder).FAILED: raise

      # include HRESULT_FROM_WIN32(ERROR_CANCELLED)
      if dialog.Show(if self.mParent == nil: 0 else: self.mParent.mHwnd).FAILED: raise

      if dialog.GetResult(&item).FAILED: raise
      defer: item.Release()

      if item.GetDisplayName(SIGDN_FILESYSPATH, &filePath).FAILED: raise
      defer: CoTaskMemFree(filePath)

      self.mPath = $filePath
      result = wIdOk

    except:
      result = wIdCancel

proc wDirDialog_CallbackProc(hwnd: HWND, uMsg: UINT, lp: LPARAM, pData: LPARAM): INT {.stdcall.} =
  if uMsg == BFFM_INITIALIZED:
    SendMessage(hwnd, BFFM_SETSELECTION, TRUE, pData)

proc showModal_XPCompatible(self: wDirDialog): wId =
  var bi = BROWSEINFO(ulFlags: BIF_RETURNONLYFSDIRS or BIF_USENEWUI)

  if self.mParent != nil:
    bi.hwndOwner = self.mParent.mHwnd

  if self.mMessage.len != 0:
    bi.lpszTitle = &T(self.mMessage)

  if self.mPath.len != 0:
    bi.lpfn = wDirDialog_CallbackProc
    bi.lParam = cast[LPARAM](&T(self.mPath))

  if (self.mStyle and wDdDirMustExist) != 0:
    bi.ulFlags = bi.ulFlags or BIF_NONEWFOLDERBUTTON

  var pidl = SHBrowseForFolder(bi)
  if pidl == nil:
    return wIdCancel

  var buffer = T(MAX_PATH + 2)
  SHGetPathFromIDList(pidl, &buffer)
  CoTaskMemFree(pidl)
  buffer.nullTerminate()
  self.mPath = $buffer
  result = wIdOk

proc showModal*(self: wDirDialog): wId {.discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  when defined(useWinXP):
    result = self.showModal_XPCompatible()
  else:
    if (self.mStyle and wDdXpCompatible) != 0:
      result = self.showModal_XPCompatible()
    else:
      result = self.showModal_VistaLaster()

  if result == wIdOk and (self.mStyle and wDdChangeDir) != 0:
    SetCurrentDirectory(self.mPath)

proc show*(self: wDirDialog): wId {.inline, discardable.} =
  ## The same as showModal().
  result = self.showModal()

proc showModalResult*(self: wDirDialog): string {.inline, discardable.} =
  ## Shows the dialog, returning the selected path or nil.
  if self.showModal() == wIdOk:
    result = self.getPath()

proc showResult*(self: wDirDialog): string {.inline, discardable.} =
  ## The same as showModalResult().
  if self.show() == wIdOk:
    result = self.getPath()
