#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
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
  mParent = parent
  mMessage = message
  mPath = defaultPath
  mStyle = style

proc DirDialog*(parent: wWindow = nil, message = "", defaultPath = "",
    style: wStyle = 0): wDirDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, message, defaultPath, style)

proc getPath*(self: wDirDialog): string {.validate, property, inline.} =
  ## Returns the default or user-selected path.
  result = mPath

proc getMessage*(self: wDirDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = mMessage

proc setPath*(self: wDirDialog, path: string) {.validate, property, inline.} =
  ## Sets the default path.
  mPath = path

proc setMessage*(self: var wDirDialog, message: string)
    {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  mMessage = message

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

      if mMessage.len != 0:
        if dialog.SetTitle(mMessage).FAILED: raise

      if mPath.len != 0:
        if SHCreateItemFromParsingName(mPath, nil, &IID_IShellItem,
          cast[ptr PVOID](&folder)).FAILED: raise

        if dialog.SetFolder(folder).FAILED: raise

      # include HRESULT_FROM_WIN32(ERROR_CANCELLED)
      if dialog.Show(if mParent == nil: 0 else: mParent.mHwnd).FAILED: raise

      if dialog.GetResult(&item).FAILED: raise
      defer: item.Release()

      if item.GetDisplayName(SIGDN_FILESYSPATH, &filePath).FAILED: raise
      defer: CoTaskMemFree(filePath)

      mPath = $filePath
      result = wIdOk

    except:
      result = wIdCancel

proc wDirDialog_CallbackProc(hwnd: HWND, uMsg: UINT, lp: LPARAM, pData: LPARAM): INT {.stdcall.} =
  if uMsg == BFFM_INITIALIZED:
    SendMessage(hwnd, BFFM_SETSELECTION, TRUE, pData)

proc showModal_XPCompatible(self: wDirDialog): wId =
  var bi = BROWSEINFO(ulFlags: BIF_RETURNONLYFSDIRS or BIF_USENEWUI)

  if mParent != nil:
    bi.hwndOwner = mParent.mHwnd

  if mMessage.len != 0:
    bi.lpszTitle = &T(mMessage)

  if mPath.len != 0:
    bi.lpfn = wDirDialog_CallbackProc
    bi.lParam = cast[LPARAM](&T(mPath))

  if (mStyle and wDdDirMustExist) != 0:
    bi.ulFlags = bi.ulFlags or BIF_NONEWFOLDERBUTTON

  var pidl = SHBrowseForFolder(bi)
  if pidl == nil:
    return wIdCancel

  var buffer = T(MAX_PATH + 2)
  SHGetPathFromIDList(pidl, &buffer)
  CoTaskMemFree(pidl)
  buffer.nullTerminate()
  mPath = $buffer
  result = wIdOk

proc showModal*(self: wDirDialog): wId {.discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  when defined(useWinXP):
    result = showModal_XPCompatible()
  else:
    if (mStyle and wDdXpCompatible) != 0:
      result = showModal_XPCompatible()
    else:
      result = showModal_VistaLaster()

  if result == wIdOk and (mStyle and wDdChangeDir) != 0:
    SetCurrentDirectory(mPath)

proc show*(self: wDirDialog): wId {.inline, discardable.} =
  ## The same as showModal().
  result = showModal()

proc showModalResult*(self: wDirDialog): string {.inline, discardable.} =
  ## Shows the dialog, returning the selected path or nil.
  if showModal() == wIdOk:
    result = getPath()

proc showResult*(self: wDirDialog): string {.inline, discardable.} =
  ## The same as showModalResult().
  if show() == wIdOk:
    result = getPath()
