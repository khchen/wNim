proc MessageDialog*(parent: wWindow, message: string, caption: string, style: int64): wMessageDialog =
  result.mParent = parent
  result.mMessage = message
  result.mCaption = caption
  result.mStyle = style

proc ShowModal*(self: wMessageDialog): wCommandID =
  var
    sysStyle: DWORD = mStyle.int32 and 0x70'i32 and 0xFFFFFFFF'i32 # preserve style for icon
    hParent: HWND

  if mParent != nil:
    hParent = mParent.mHwnd
    sysStyle = sysStyle or MB_APPLMODAL
  else:
    sysStyle = sysStyle or MB_TASKMODAL

  if (mStyle and wYesNo) != 0:
    sysStyle = sysStyle or (if (mStyle and wCancel) != 0: MB_YESNOCANCEL else: MB_YESNO)
    if (mStyle and wNoDefault) != 0:
      sysStyle = sysStyle or MB_DEFBUTTON2

  if (mStyle and (wOk or wCancel)) == (wOk or wCancel):
    sysStyle = sysStyle or MB_OKCANCEL

  if (mStyle and wStayOnTop) != 0:
    sysStyle = sysStyle or MB_TOPMOST

  case MessageBox(hParent, mMessage, mCaption, sysStyle)
  of IDCANCEL:
    result = wID_CANCEL
  of IDYES:
    result = wID_YES
  of IDNO:
    result = wID_NO
  else: # of IDOK:
    result = wID_OK

proc wMessageBox*(parent: wWindow = nil, message, caption: string = "", style: int64 = 0): wCommandID {.discardable.} =
  result = MessageDialog(parent, message, caption, style).ShowModal()
