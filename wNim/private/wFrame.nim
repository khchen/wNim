#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
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
## manually.
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
##   ==============================  =============================================================
#
## :Events:
##   - `wTrayEvent <wTrayEvent.html>`_
##   - `wCommandEvent <wCommandEvent.html>`_  - wEvent_Menu

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
  wStayOnTop* = int64 WS_EX_TOPMOST shl 32
  wModalFrame* = DS_MODALFRAME
  wFrameToolWindow* = int64 WS_EX_TOOLWINDOW shl 32
  wDefaultFrameStyle* = wMinimizeBox or wMaximizeBox or wResizeBorder or
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

proc setMenuBar*(self: wFrame, menuBar: wMenuBar) {.validate, property, inline.} =
  ## Tells the frame to show the given menu bar.
  menuBar.attach(self)

proc getMenuBar*(self: wFrame): wMenuBar {.validate, property, inline.} =
  ## Returns the menubar currently associated with the frame.
  result = self.mMenuBar

proc setTopMost*(self: wFrame, top = true) {.validate, property.} =
  ## Sets whether the frame top most to all windows.
  let flag = if top: HWND_TOPMOST else: HWND_NOTOPMOST
  SetWindowPos(self.mHwnd, flag, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE)

proc createStatusBar*(self: wFrame, number: int = 1, style: wStyle = 0,
    id: wCommandID = 0): wStatusBar {.validate, property, discardable.} =
  ## Creates a status bar at the bottom of the frame.
  result = StatusBar(parent=self)
  if number != 1:
    result.setFieldsCount(number)

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
    handler: wEventHandler): wEventConnection {.validate, discardable.} =
  ## Quickly bind a keyboard shortcut to an event handler.
  ## If this frame not yet have a accelerator table, it will create a new one.
  ## This function use wCommandID between 64257..65535.
  return self.connect(self.shortcutId(flag, keyCode), handler)

proc shortcut*(self: wFrame, flag: int, keyCode: int,
    handler: wEventNeatHandler): wEventConnection {.validate, discardable.} =
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

proc showModal*(self: wFrame): int {.validate, discardable.} =
  ## Shows the frame as an application-modal dialog.
  ## Program flow does not return until the dialog has been dismissed with endModal.
  self.mDisableList = newSeq[wWindow]()

  for topwin in wAppTopLevelWindows():
    if topwin != self and topwin.isEnabled():
      topwin.disable()
      self.mDisableList.add(topwin)

  self.show()
  result = MessageLoop(isMainLoop=false)

proc endModal*(self: wFrame, retCode: int = 0) =
  ## Ends a modal dialog, passing a value to be returned from the showModal()
  ## invocation.

  # MSDN: the application must enable the main window before destroying the
  # dialog box
  for topwin in self.mDisableList:
    topwin.enable()
  self.mDisableList = @[]

  self.hide()
  self.setReturnCode(retCode)

  # sometimes the owner window will lost the foreground unexpectedly
  # for example, call another system modal window in modal dialog
  let owner = GetWindow(self.mHwnd, GW_OWNER)
  if owner != 0:
    SetForegroundWindow(owner)

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
  wValidate(title, text)
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

proc wFrame_DoSize(event: wEvent) =
  # If the frame has exactly one child window, not counting the status and toolbar,
  # this child is resized to take the entire frame client area.
  # If two or more windows are present, they should be laid out explicitly by manually.
  let self = event.mWindow
  var childOne: wWindow

  for child in self.mChildren:
    if (not (child of wStatusBar)) and
        (not (child of wToolBar)) and
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

proc wFrame_OnSetFocus(event: wEvent) =
  # when a frame got focus, try to pass focus to mSaveFocus or first focusable
  # control
  let self = event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if self.mSaveFocus != nil:
    # sometimes, the saved focus window will not exist anymore
    # for example: textctrl for treectrl's rename editor
    var win = self.mSaveFocus
    while IsWindow(win.mHwnd) == 0:
      win = win.mParent
      if win == nil: return

    win.setFocus()
    processed = true

  else:
    # set focus to first focusable control
    let win = self.findFocusableChild()
    if win != nil:
      win.setFocus()
      self.mSaveFocus = win
      processed = true

proc wFrame_OnMenuHighlight(event: wEvent) =
  # The default handler for wEvent_MenuHighlight in wFrame displays help text
  # in the status bar.
  let self = wFrame event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if self.mStatusBar != nil and self.mMenuBar != nil:
    let
      hmenu = event.mLparam.HMENU
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

    self.mStatusBar.setStatusText(if selectedItem != nil: selectedItem.mHelp else: "")
    processed = true

proc wFrame_OnMenuCommand(event: wEvent) =
  let self = event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  let
    pos = int event.mWparam
    hmenu = cast[HMENU](event.mLparam)

  var menuInfo = MENUINFO(cbSize: sizeof(MENUINFO), fMask: MIM_MENUDATA)
  GetMenuInfo(hmenu, menuInfo)
  if menuInfo.dwMenuData != 0:
    let
      menu = cast[wMenu](menuInfo.dwMenuData)
      item = menu.mItemList[pos]

    if item.mKind == wMenuItemCheck:
      menu.toggle(pos)

    elif item.mKind == wMenuItemRadio:
      menu.check(pos)

    # convet to wEvent_Menu message.
    processed = self.processMessage(wEvent_Menu, cast[WPARAM](item.mId), 0,
      event.mResult)

when defined(useWinXP):
  # under Windows XP, menu icon must draw by outself
  proc wFrame_OnMeasureItem(event: wEvent) =
    var processed = false
    defer: event.skip(if processed: false else: true)

    var pStruct = cast[LPMEASUREITEMSTRUCT](event.mLparam)
    if pStruct.CtlType == ODT_MENU and pStruct.itemData != 0:
      # here pStruct.itemData maybe a wMenu or a wMenuItem
      let
        menu = cast[wMenu](pStruct.itemData)
        bmp = (if IsMenu(menu.mHmenu): menu.mBitmap else: cast[wMenuItem](pStruct.itemData).mBitmap)
        iconHeight = GetSystemMetrics(SM_CYMENUSIZE)
        iconWidth = GetSystemMetrics(SM_CXMENUSIZE)

      if bmp != nil:
        pStruct.itemHeight = max(bmp.mHeight + 2, iconHeight)
        pStruct.itemWidth = max(bmp.mWidth + 4, iconWidth)
        event.mResult = TRUE
        processed = true

  proc wFrame_OndrawItem(event: wEvent) =
    var processed = false
    defer: event.skip(if processed: false else: true)

    var pStruct = cast[LPDRAWITEMSTRUCT](event.mLparam)
    if pStruct.CtlType == ODT_MENU and pStruct.itemData != 0:
      let
        menu = cast[wMenu](pStruct.itemData)
        bmp = (if IsMenu(menu.mHmenu): menu.mBitmap else: cast[wMenuItem](pStruct.itemData).mBitmap)

      if bmp != nil:
        let
          width = bmp.mWidth
          height = bmp.mHeight
          memdc = CreateCompatibleDC(0)
          prev = SelectObject(memdc, bmp.mHandle)
          x = (pStruct.rcItem.right - pStruct.rcItem.left - width) div 2
          y = (pStruct.rcItem.bottom - pStruct.rcItem.top - height) div 2

        var bf = BLENDFUNCTION(BlendOp: AC_SRC_OVER, SourceConstantAlpha: 255,
          AlphaFormat: AC_SRC_ALPHA)

        AlphaBlend(pStruct.hDC, x, y, width, height, memdc, 0, 0, width, height, bf)

        SelectObject(memdc, prev)
        DeleteDC(memdc)
        event.mResult = TRUE
        processed = true

proc final*(self: wFrame) =
  ## Default finalizer for wFrame.
  discard

method release(self: wFrame) =
  # delete the tray icon (if any)
  self.removeTrayIcon()

proc init*(self: wFrame, owner: wWindow = nil, title = "", pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = wDefaultFrameStyle,
    className = "wFrame") {.validate.} =
  ## Initializer.
  self.wWindow.initVerbosely(title=title, pos=pos, size=size,
    style=style or WS_CLIPCHILDREN, owner=owner, className=className,
    bgColor=GetSysColor(COLOR_APPWORKSPACE))

  self.systemConnect(wEvent_Size, wFrame_DoSize)

  self.hardConnect(wEvent_SetFocus, wFrame_OnSetFocus)
  self.hardConnect(wEvent_MenuHighlight, wFrame_OnMenuHighlight)
  self.hardConnect(WM_MENUCOMMAND, wFrame_OnMenuCommand)

  when defined(useWinXP):
    self.hardConnect(WM_MEASUREITEM, wFrame_OnMeasureItem)
    self.hardConnect(WM_DRAWITEM, wFrame_OndrawItem)

proc Frame*(owner: wWindow = nil, title = "", pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = wDefaultFrameStyle,
    className = "wFrame"): wFrame {.inline, discardable.} =
  ## Constructor, creating the frame.
  new(result, final)
  result.init(owner, title, pos, size, style, className)
