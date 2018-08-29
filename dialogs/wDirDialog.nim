## This class represents the directory chooser dialog.
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wDdDirMustExist                 The dialog will allow the user to choose only an existing folder.
##    wDdChangeDir                    Change the current working directory to the directory chosen by the user.
##    wDdXpCompatible                 Use the Windows XP compatible UI as the dialog.
##    ==============================  =============================================================

const
  wDdDirMustExist* = 1
  wDdChangeDir* = 2
  wDdXpCompatible* = 4

proc DirDialog*(parent: wWindow = nil, message: string = nil, defaultPath: string = nil,
    style: wStyle = 0): wDirDialog =
  result.mParent = parent
  result.mMessage = message
  result.mStyle = style

  # must use ref type here so that we can write DirDialog().showModal()
  new(result.mPath)
  result.mPath[] = defaultPath

proc setPath*(self: wDirDialog, path: string) {.property, inline.} =
  ## Sets the default path.
  mPath[] = path

proc getPath*(self: wDirDialog): string {.property, inline.} =
  ## Returns the default or user-selected path.
  if mPath != nil:
    result = mPath[]

proc setMessage*(self: var wDirDialog, message: string) {.property, inline.} =
  ## Sets the message that will be displayed on the dialog.
  mMessage = message

proc getMessage*(self: wDirDialog): string {.property, inline.} =
  ## Returns the message that will be displayed on the dialog.
  result = mMessage

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

      if mMessage != nil:
        if dialog.SetTitle(mMessage).FAILED: raise

      if mPath[] != nil:
        if SHCreateItemFromParsingName(mPath[], nil, &IID_IShellItem,
          cast[ptr PVOID](&folder)).FAILED: raise

        if dialog.SetFolder(folder).FAILED: raise

      # include HRESULT_FROM_WIN32(ERROR_CANCELLED)
      if dialog.Show(if mParent == nil: 0 else: mParent.mHwnd).FAILED: raise

      if dialog.GetResult(&item).FAILED: raise
      defer: item.Release()

      if item.GetDisplayName(SIGDN_FILESYSPATH, &filePath).FAILED: raise
      defer: CoTaskMemFree(filePath)

      mPath[] = $filePath
      result = wID_OK

    except:
      result = wID_CANCEL

proc wDirDialog_CallbackProc(hwnd: HWND, uMsg: UINT, lp: LPARAM, pData: LPARAM): INT {.stdcall.} =
  if uMsg == BFFM_INITIALIZED:
    SendMessage(hwnd, BFFM_SETSELECTION, TRUE, pData)

proc showModal_XPCompatible(self: wDirDialog): wId =
  var bi = BROWSEINFO(ulFlags: BIF_RETURNONLYFSDIRS or BIF_USENEWUI)
  var buffer: TString

  if mParent != nil:
    bi.hwndOwner = mParent.mHwnd

  if mMessage != nil:
    bi.lpszTitle = &T(mMessage)

  if mPath[] != nil:
    buffer = T(mPath[])
    bi.lpfn = wDirDialog_CallbackProc
    bi.lParam = cast[LPARAM](&buffer)

  if (mStyle and wDdDirMustExist) != 0:
    bi.ulFlags = bi.ulFlags or BIF_NONEWFOLDERBUTTON

  var pidl = SHBrowseForFolder(bi)
  if pidl == nil:
    return wID_CANCEL

  buffer = T(MAX_PATH + 2)
  SHGetPathFromIDList(pidl, &buffer)
  CoTaskMemFree(pidl)
  buffer.nullTerminate()
  mPath[] = $buffer
  result = wID_OK

proc showModal*(self: wDirDialog): wId {.discardable.} =
  ## Shows the dialog, returning wID_OK if the user pressed OK, and wID_CANCEL otherwise.
  when defined(useWinXP):
    result = showModal_XPCompatible()
  else:
    if (mStyle and wDdXpCompatible) != 0:
      result = showModal_XPCompatible()
    else:
      result = showModal_VistaLaster()

  if result == wID_OK and (mStyle and wDdChangeDir) != 0:
    SetCurrentDirectory(mPath)

proc show*(self: wDirDialog): wId {.inline, discardable.} =
  ## The same as showModal().
  result = showModal()

proc showModalResult*(self: wDirDialog): string {.inline, discardable.} =
  ## Shows the dialog, returning the selected path or nil.
  if showModal() == wID_OK:
    result = getPath()

proc showResult*(self: wDirDialog): string {.inline, discardable.} =
  ## The same as showModalResult().
  if show() == wID_OK:
    result = getPath()
