#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A frame is a top-level window in wNim. Since it is a top-level window,
## it cannot have a parent. However, it can has an owner. The frame will be
## minimized when its owner is minimized and restored when it is restored.
##
## A dialog is also a top-level window with the owner. So it can be designed
## in wNim by using a frame with a owner (another main frame), put a panel in it,
## and then adding some contorls inside.
##
## Notice that if a frame has exactly one child window, not counting the status
## and toolbar, this child is resized to take the entire frame client area.
## If two or more windows are present, they should be laid out explicitly by
## manually. **This behavior just a default wEvent_Size event
## handler for frame, and it can be overwrited (Since 0.7.0).**
#
## :Superclass:
##   `wWindow <wWindow.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wIconize                        Display the frame iconized (minimized).
##   wCaption                        Puts a caption on the frame.
##   wMinimize                       Identical to wIconize.
##   wMinimizeBox                    Displays a minimize box on the frame
##   wMaximize                       Displays the frame maximized
##   wMaximizeBox                    Displays a maximize box on the frame
##   wSystemMenu                     Displays a system menu containing the list of various windows
##                                   commands in the window title bar.
##   wResizeBorder                   Displays a resizable border around the window.
##   wStayOnTop                      Stay on top of all other windows.
##   wModalFrame                     Creates a frame with a modal dialog-box style.
##   wFrameToolWindow                Causes a frame with a small title bar to be created; the frame
##                                   does not appear in the taskbar.
##   wDefaultFrameStyle              The default style for a frame.
##   wDefaultDialogStyle             The default style for a dialog.
##   ==============================  =============================================================
#
## :Events:
##   - `wTrayEvent <wTrayEvent.html>`_
##   - `wCommandEvent <wCommandEvent.html>`_  - wEvent_Menu

include pragma
import wBase, wWindow, wAcceleratorTable
export wWindow, wAcceleratorTable

const
  # frame styles
  wIconize* = WS_ICONIC
  wCaption* = WS_CAPTION
  wMinimize* = WS_MINIMIZE
  wMinimizeBox* = WS_MINIMIZEBOX
  wMaximize* = WS_MAXIMIZE
  wMaximizeBox* = WS_MAXIMIZEBOX
  wSystemMenu* = WS_SYSMENU
  wResizeBorder* = WS_SIZEBOX
  wStayOnTop* = WS_EX_TOPMOST.int64 shl 32
  wModalFrame* = DS_MODALFRAME
  wFrameToolWindow* = WS_EX_TOOLWINDOW.int64 shl 32
  wDefaultFrameStyle* = wMinimizeBox or wMaximizeBox or wResizeBorder or
    wSystemMenu or wCaption
  wDefaultDialogStyle* = wBorderSimple or wBorderDouble or wBorderRaised or
    wSystemMenu or wCaption
  # balloon icon
  wBallonNone* = NIIF_NONE
  wBallonInfo* = NIIF_INFO
  wBallonWarning* = NIIF_WARNING
  wBallonError* = NIIF_ERROR

method getDefaultSize*(self: wFrame): wSize {.validate.} =
  ## Returns the system suggested size of a window (usually used for GUI controls).
  # a reasonable frame size
  result = (640, 480)

proc getMenuBar*(self: wFrame): wMenuBar {.validate, property, inline.} =
  ## Returns the menubar currently associated with the frame (if any).
  result = self.mMenuBar

proc setTopMost*(self: wFrame, top = true) {.validate, property.} =
  ## Sets whether the frame top most to all windows.
  let flag = if top: HWND_TOPMOST else: HWND_NOTOPMOST
  SetWindowPos(self.mHwnd, flag, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE)

proc setIcon*(self: wFrame, icon: wIcon) {.validate, property.} =
  ## Sets the icon for this frame.
  self.mIcon = icon
  SendMessage(self.mHwnd, WM_SETICON, ICON_SMALL, if icon != nil: icon.mHandle else: 0)

proc getIcon*(self: wFrame): wIcon {.validate, property, inline.} =
  ## Returns the standard icon.
  result = self.mIcon

proc minimize*(self: wFrame, flag = true) {.validate.} =
  ## Minimizes or restores the frame
  if self.isShownOnScreen():
    ShowWindow(self.mHwnd, if flag: SW_MINIMIZE else: SW_RESTORE)

proc iconize*(self: wFrame, flag = true) {.validate, inline.} =
  ## Iconizes or restores the frame. The same as minimize().
  self.minimize(flag)

proc maximize*(self: wFrame, flag = true) {.validate.} =
  ## Maximizes or restores the frame.
  if self.isShownOnScreen():
    ShowWindow(self.mHwnd, if flag: SW_MAXIMIZE else: SW_RESTORE)

proc restore*(self: wFrame) {.validate, inline.} =
  ## Restore a previously iconized or maximized frame to its normal state.
  ShowWindow(self.mHwnd, SW_RESTORE)

proc isIconized*(self: wFrame): bool {.validate, inline.} =
  ## Returns true if the frame is iconized.
  result = IsIconic(self.mHwnd) != 0

proc isMaximized*(self: wFrame): bool {.validate, inline.} =
  ## Returns true if the frame is maximized.
  result = IsZoomed(self.mHwnd) != 0

proc enableCloseButton*(self: wFrame, flag = true) {.validate.} =
  ## Enables or disables the Close button.
  var hmenu = GetSystemMenu(self.mHwnd, 0)
  EnableMenuItem(hmenu, SC_CLOSE, UINT(MF_BYCOMMAND or (if flag: MF_ENABLED else : MF_GRAYED)))
  DrawMenuBar(self.mHwnd)

proc disableCloseButton*(self: wFrame) {.validate, inline.} =
  ## Disables the Close button.
  self.enableCloseButton(false)

proc enableMaximizeButton*(self: wFrame, flag = true) {.validate.} =
  ## Enables or disables the Maximize button.
  var value = GetWindowLongPtr(self.mHwnd, GWL_STYLE)
  SetWindowLongPtr(self.mHwnd, GWL_STYLE, if flag: value or WS_MAXIMIZEBOX else: value and (not WS_MAXIMIZEBOX))

proc disableMaximizeButton*(self: wFrame) {.validate, inline.} =
  ## Disables the Maximize button.
  self.enableMaximizeButton(false)

proc enableMinimizeButton*(self: wFrame, flag = true) {.validate.} =
  ## Enables or disables the Minimize button.
  var value = GetWindowLongPtr(self.mHwnd, GWL_STYLE)
  SetWindowLongPtr(self.mHwnd, GWL_STYLE, if flag: value or WS_MINIMIZEBOX else: value and (not WS_MINIMIZEBOX))

proc disableMinimizeButton*(self: wFrame) {.validate, inline.} =
  ## Disables the Minimize button.
  self.enableMinimizeButton(false)

proc shortcutId(self: wFrame, flag: int, keyCode: int): wCommandID =
  var accel = self.getAcceleratorTable()
  if accel == nil:
    accel = AcceleratorTable()
    self.setAcceleratorTable(accel)

  var id = keyCode
  if (flag and wAccelCtrl) != 0: id = id or 0x100
  if (flag and wAccelAlt) != 0: id = id or 0x200
  if (flag and wAccelShift) != 0: id = id or 0x400
  id = 65536 - id

  accel.add(flag, keyCode, wCommandID id)
  result = wCommandID id

proc shortcut*(self: wFrame, flag: int, keyCode: int,
    handler: wEventProc): wEventConnection {.validate, discardable.} =
  ## Quickly bind a keyboard shortcut to an event handler.
  ## If this frame not yet have a accelerator table, it will create a new one.
  ## This function use wCommandID between 64257..65535.
  return self.connect(self.shortcutId(flag, keyCode), handler)

proc shortcut*(self: wFrame, flag: int, keyCode: int,
    handler: wEventNeatProc): wEventConnection {.validate, discardable.} =
  ## Quickly bind a keyboard shortcut to an event handler.
  ## If this frame not yet have a accelerator table, it will create a new one.
  ## This function use wCommandID between 64257..65535.
  return self.connect(self.shortcutId(flag, keyCode), handler)

proc setReturnCode*(self: wFrame, retCode: int) {.validate, property, inline.} =
  ## Sets the return code for this window.
  self.mRetCode = retCode

proc getReturnCode*(self: wFrame): int {.validate, property, inline.} =
  ## Gets the return code for this window.
  result = self.mRetCode

proc isModal*(self: wFrame): bool {.validate, inline.} =
  ## Returns true if the frame is modal, false otherwise.
  result = self.mIsModal

proc showModal*(self: wFrame): int {.validate, discardable.} =
  ## Shows the frame as an application-modal dialog.
  ## Program flow does not return until the dialog has been dismissed with endModal.
  self.mIsModal = true
  self.mDisableList = @[]
  for hwnd in wAppTopLevelHwnd():
    if hwnd != self.mHwnd and IsWindowEnabled(hwnd) != 0:
      EnableWindow(hwnd, false)
      self.mDisableList.add(hwnd)

  self.show()
  result = messageLoop(self.mHwnd)

proc showWindowModal*(self: wFrame): int {.validate, discardable.} =
  ## Shows a dialog modal to the parent top level window only.
  ## Program flow does not return until the dialog has been dismissed with endModal.
  self.mIsModal = true
  self.mDisableList = @[]
  let owner = GetWindow(self.mHwnd, GW_OWNER)
  if owner != 0:
    for hwnd in wAppTopLevelHwnd():
      if hwnd != self.mHwnd and IsWindowEnabled(hwnd) != 0:
        if hwnd == owner or IsChild(hwnd, owner) != 0:
          EnableWindow(hwnd, false)
          self.mDisableList.add(hwnd)

  self.show()
  result = messageLoop(self.mHwnd)

proc endModal*(self: wFrame, retCode: int = 0) =
  ## Ends a modal dialog, passing a value to be returned from the showModal()
  ## invocation.

  # MSDN: the application must enable the main window before destroying the
  # dialog box
  for hwnd in self.mDisableList:
    EnableWindow(hwnd, true)
  self.mDisableList = @[]

  # sometimes the owner window will lost the foreground unexpectedly
  # for example, call another system modal window in modal dialog
  let owner = GetWindow(self.mHwnd, GW_OWNER)
  if owner != 0:
    forceForegroundWindow(owner)

  self.hide()
  self.setReturnCode(retCode)

  self.mIsModal = false

proc setTrayIcon*(self: wFrame, icon: wIcon, tooltip = "") {.validate, property.} =
  ## Creates the system tray icon.
  wValidate(icon)
  if icon != nil:
    self.mTrayIcon = icon
    self.mTrayToolTip = tooltip

    var nid = NOTIFYICONDATA(
      cbSize: sizeof(NOTIFYICONDATA),
      hWnd: self.mHwnd,
      uFlags: NIF_MESSAGE or NIF_ICON,
      hIcon: icon.mHandle,
      uCallbackMessage: wEvent_TrayIcon)

    if tooltip.len != 0:
      nid.uFlags = nid.uFlags or NIF_TIP
      nid.szTip << T(tooltip)

    if Shell_NotifyIcon(if self.mTrayIconAdded: NIM_MODIFY else: NIM_ADD, &nid):
      if not self.mTrayIconAdded:
        self.mTrayIconAdded = true

        let msgTaskbarCreated = RegisterWindowMessage("TaskbarCreated")
        self.mCreateConn = self.systemConnect(msgTaskbarCreated) do (event: wEvent):
          # taskbar crash, recreate trayicon
          self.mTrayIconAdded = false
          self.setTrayIcon(self.mTrayIcon, self.mTrayToolTip)

        self.mTrayConn = self.systemConnect(wEvent_TrayIcon) do (event: wEvent):
          let msg = case event.mLparam
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
          if msg != 0: self.processMessage(msg)

proc removeTrayIcon*(self: wFrame) {.validate.} =
  ## Removes the system tray icon.
  if self.mTrayIconAdded:
    var nid = NOTIFYICONDATA(cbSize: sizeof(NOTIFYICONDATA), hWnd: self.mHwnd)
    Shell_NotifyIcon(NIM_DELETE, &nid)
    self.mTrayIconAdded = false
    self.mTrayIcon = nil
    self.mTrayToolTip = ""
    self.systemDisconnect(self.mCreateConn)
    self.systemDisconnect(self.mTrayConn)

proc showBalloon*(self: wFrame, title: string, text: string, timeout: int = 3000,
    flag = wBallonNone) {.validate.} =
  ## Display a balloon notification. Only works when the frame already have a
  ## tray icon. *flag* is one of wBallonNone, wBallonInfo, wBallonWarning or
  ## wBallonError.
  if self.mTrayIconAdded:
    # uVersion and uTimeout in the union, need setter
    var nid = NOTIFYICONDATA(cbSize: sizeof(NOTIFYICONDATA), hWnd: self.mHwnd)
    nid.uVersion = 3
    Shell_NotifyIcon(NIM_SETVERSION, &nid)

    nid = NOTIFYICONDATA(
      cbSize: sizeof(NOTIFYICONDATA),
      hWnd: self.mHwnd,
      uFlags: NIF_INFO)

    nid.uTimeout = timeout
    nid.szInfo << T(text)
    nid.szInfoTitle << T(title)
    nid.dwInfoFlags = flag
    Shell_NotifyIcon(NIM_MODIFY, &nid)

proc wFrame_OnSize(event: wEvent) =
  # If the frame has exactly one child window, not counting the status and toolbar,
  # this child is resized to take the entire frame client area.
  # If two or more windows are present, they should be laid out explicitly by manually.
  let self = event.mWindow
  var childOne: wWindow

  for child in self.mChildren:
    if (not (child of wStatusBar)) and
        (not (child of wToolBar)) and
        (not (child of wMenuBarCtrl)) and
        (not (child of wRebar)):
      if childOne == nil:
        childOne = child
      else: # more the one child, nothing to do
        return

  if childOne != nil:
    let clientSize = self.getClientSize()
    childOne.setSize(0, 0, clientSize.width, clientSize.height)

proc findFocusableChild(self: wWindow): wWindow =
  for win in self.mChildren:
    if win.isFocusable():
      return win
    elif win.mChildren.len > 0:
      result = win.findFocusableChild()
      if result != nil: return

proc findFirstExistsParentWin(hwnd: HWND): wWindow {.inline.} =
  var hwnd = hwnd
  while hwnd != 0:
    result = wAppWindowFindByHwnd(hwnd)
    if result != nil: return
    hwnd = GetAncestor(hwnd, GA_PARENT) # not include the owner

proc wFrame_OnSetFocus(event: wEvent) =
  # when a frame got focus, try to pass focus to mSaveFocusHwnd or first focusable
  # control
  let self = event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  var win = findFirstExistsParentWin(self.mSaveFocusHwnd)
  if win != nil:
    # sometimes, the saved focus window will not exist anymore
    # for example: textctrl for treectrl's rename editor
    while IsWindow(win.mHwnd) == 0:
      win = win.mParent
      if win == nil: break

  if win != nil:
    win.setFocus()
    processed = true

  else:
    # set focus to first focusable control
    let win = self.findFocusableChild()
    if win != nil:
      win.setFocus()
      self.mSaveFocusHwnd = win.mHwnd
      processed = true

proc wFrame_OnMenuHighlight(event: wEvent) =
  # The default handler for wEvent_MenuHighlight in wFrame displays help text
  # in the status bar.
  let self = wBase.wFrame event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if self.mStatusBar != nil and self.mMenuBar != nil:
    let
      hmenu = HMENU event.mLparam
      flag = HIWORD(event.mWparam)
      menuId = LOWORD(event.mWparam)

    var selectedItem: wMenuItem
    block loop:
      for menu in self.mMenuBar.mMenuList:
        if menu.mHmenu == hmenu:
          if (flag and MF_POPUP) != 0:
            let hSubMenu = GetSubMenu(hmenu, int32 menuId)
            for item in menu.mItemList:
              if item.mSubmenu != nil and item.mSubmenu.mHmenu == hSubMenu:
                selectedItem = item
                break loop
          else:
            for item in menu.mItemList:
              if item.mId == menuId.wCommandID:
                selectedItem = item
                break loop

    # self.mStatusBar.setStatusText(if selectedItem != nil: selectedItem.mHelp else: "")
    let text = if selectedItem != nil: selectedItem.mHelp else: ""
    SendMessage(self.mStatusBar.mHwnd, SB_SETTEXT, LOBYTE(self.mStatusBar.mHelpIndex), &T(text))
    processed = true

wClass(wFrame of wWindow):

  method release*(self: wFrame) =
    ## Release all the resources during destroying. Used internally.
    self.removeTrayIcon() # delete the tray icon (if any)
    free(self[])

  proc init*(self: wFrame, owner: wWindow = nil, title = "", pos = wDefaultPoint,
      size = wDefaultSize, style: wStyle = wDefaultFrameStyle,
      className = "wFrame") {.validate.} =
    ## Initializes a frame.
    self.wWindow.initVerbosely(title=title, pos=pos, size=size,
      style=style or WS_CLIPCHILDREN, owner=owner, className=className,
      bgColor=GetSysColor(COLOR_APPWORKSPACE))

    self.hardConnect(wEvent_Size, wFrame_OnSize)
    self.hardConnect(wEvent_SetFocus, wFrame_OnSetFocus)
    self.hardConnect(wEvent_MenuHighlight, wFrame_OnMenuHighlight)
