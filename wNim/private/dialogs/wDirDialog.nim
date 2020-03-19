#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## This class represents the directory chooser dialog. Only modal dialog is
## supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wDdDirMustExist                 The dialog will allow the user to choose only an existing folder.
##   wDdChangeDir                    Change the current working directory to the directory chosen by the user.
##   ==============================  =============================================================

{.experimental, deadCodeElim: on.}
when defined(gcDestructors): {.push sinkInference: off.}

import ../wBase, wDialog
export wDialog

const
  wDdDirMustExist* = 1
  wDdChangeDir* = 2

wClass(wDirDialog of wDialog):

  proc init*(self: wDirDialog, owner: wWindow = nil, message = "",
      defaultPath = "", style: wStyle = 0) {.validate.} =
    ## Initializer.
    self.wDialog.init(owner)
    self.mMessage = message
    self.mPath = defaultPath
    self.mStyle = style

proc getPath*(self: wDirDialog): string {.validate, property, inline.} =
  ## Returns the default or user-selected path.
  result = self.mPath

proc getMessage*(self: wDirDialog): string {.validate, property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = self.mMessage

proc setPath*(self: wDirDialog, path: string) {.validate, property, inline.} =
  ## Sets the default path.
  self.mPath = path

proc setMessage*(self: wDirDialog, message: string) {.validate, property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  self.mMessage = message

proc showModal_VistaLaster(self: wDirDialog): wId =
  type SHCreateItemFromParsingName = proc (pszPath: PCWSTR, pbc: ptr IBindCtx, riid: REFIID, ppv: ptr pointer): HRESULT {.stdcall.}
  var shCreateItemFromParsingName {.global.}: SHCreateItemFromParsingName

  if shCreateItemFromParsingName.isNil:
    let hDll = LoadLibrary("shell32.dll")
    if hDll != 0:
      defer: FreeLibrary(hDll)
      shCreateItemFromParsingName = cast[SHCreateItemFromParsingName](GetProcAddress(hDll, "SHCreateItemFromParsingName"))
      if shCreateItemFromParsingName.isNil:
        return wIdCancel

  var
    dialog: ptr IFileOpenDialog
    item: ptr IShellItem
    folder: ptr IShellItem
    filePath: PWSTR

  block:
    if CoCreateInstance(&CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
      &IID_IFileOpenDialog, cast[ptr PVOID](&dialog)).FAILED: break

    if dialog.SetOptions(FOS_PICKFOLDERS or FOS_FORCEFILESYSTEM).FAILED: break

    if self.mMessage.len != 0:
      if dialog.SetTitle(self.mMessage).FAILED: break

    if self.mPath.len != 0:
      if shCreateItemFromParsingName(self.mPath, nil, &IID_IShellItem,
        cast[ptr PVOID](&folder)).FAILED: break

      if dialog.SetFolder(folder).FAILED: break

    # include HRESULT_FROM_WIN32(ERROR_CANCELLED)
    if dialog.Show(if self.mOwner == nil: 0 else: self.mOwner.mHwnd).FAILED: break

    if dialog.GetResult(&item).FAILED: break
    defer: item.Release()

    if item.GetDisplayName(SIGDN_FILESYSPATH, &filePath).FAILED: break
    defer: CoTaskMemFree(filePath)

    self.mPath = $filePath
    return wIdOk

  result = wIdCancel

when defined(useWinXP):

  proc wDirDialog_CallbackProc(hwnd: HWND, uMsg: UINT, lp: LPARAM, pData: LPARAM): INT {.stdcall.} =
    if uMsg == BFFM_INITIALIZED:
      SendMessage(hwnd, BFFM_SETSELECTION, TRUE, pData)

  proc showModal_XPCompatible(self: wDirDialog): wId =
    var bi = BROWSEINFO(ulFlags: BIF_RETURNONLYFSDIRS or BIF_USENEWUI)

    if self.mOwner != nil:
      bi.hwndOwner = self.mOwner.mHwnd

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

proc showModal*(self: wDirDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  when defined(useWinXP):
    if wAppWinVersion() >= 6.0:
      result = self.showModal_VistaLaster()
    else:
      result = self.showModal_XPCompatible()
  else:
    result = self.showModal_VistaLaster()

  self.dialogQuit()

  if result == wIdOk and (self.mStyle and wDdChangeDir) != 0:
    discard SetCurrentDirectory(self.mPath)

proc display*(self: wDirDialog): string {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the selected path or nil.
  if self.showModal() == wIdOk:
    result = self.getPath()
