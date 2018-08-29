
proc realize(self: wTrayIcon) =
  var nid = NOTIFYICONDATA(
    cbSize: sizeof(NOTIFYICONDATA),
    hWnd: mWindow.mHwnd,
    uFlags: NIF_MESSAGE,
    uCallbackMessage: wEvent_TrayIcon)

  if mIcon != nil:
    nid.uFlags = nid.uFlags or NIF_ICON
    nid.hIcon = mIcon.mHandle

  if mToolTip.len != 0:
    nid.uFlags = nid.uFlags or NIF_TIP
    nid.szTip << T(mToolTip)

  if Shell_NotifyIcon(if mIconAdded: NIM_MODIFY else: NIM_ADD, &nid):
    mIconAdded = true

proc removeIcon*(self: wTrayIcon) =
  var nid = NOTIFYICONDATA(cbSize: sizeof(NOTIFYICONDATA), hWnd: mWindow.mHwnd)
  Shell_NotifyIcon(NIM_DELETE, &nid)

proc delete*(self: wTrayIcon) =
  removeIcon()
  mWindow.delete()

proc final(self: wTrayIcon) =
  delete()

proc init*(self: wTrayIcon, icon: wIcon = nil, tooltip: string = nil) {.validate.} =
  mIconAdded = false
  mIcon = icon
  mToolTip = tooltip
  mWindow = Frame(className="wTrayIconWindow")
  mRestartTaskbar = RegisterWindowMessage("TaskbarCreated")

  mWindow.hardConnect(wEvent_TrayIcon) do (event: wEvent):
    let msg = case event.lParam
    of WM_LBUTTONDOWN: wEvent_TrayLeftDown
    of WM_LBUTTONUP: wEvent_TrayLeftUp
    of WM_RBUTTONDOWN: wEvent_TrayRightDown
    of WM_RBUTTONUP: wEvent_TrayRightUp
    of WM_LBUTTONDBLCLK: wEvent_TrayLeftDoubleClick
    of WM_RBUTTONDBLCLK: wEvent_TrayRightDoubleClick
    of WM_MOUSEMOVE: wEvent_TrayMove
    of NIN_BALLOONTIMEOUT: wEvent_TrayBalloonTimeout
    of NIN_BALLOONUSERCLICK: wEvent_TrayBalloonClick
    else: 0
    if msg != 0:
      # sends event to every to level windows, stop when someone process it.
      for topwin in wAppTopLevelWindows():
        if topwin.processEvent(Event(window=topwin, msg=msg)):
          break

  realize()

proc TaskBarIcon*(icon: wIcon = nil, tooltip: string = nil): wTrayIcon {.discardable.} =
  new(result, final)
  result.init(icon, tooltip)
