#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A menubar control is a toolbar that simulates the behavior of standard
## menubar but can be placed everywhere. For example, in the rebar control.
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Seealso:
##   `wMenuBar <wMenuBar.html>`_
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_Menu                      A menu item is selected.
##   ===============================  =============================================================

# Reference: https://github.com/mity/mctrl/blob/master/src/menubar.c

include ../pragma
import ../wBase, ../wApp, wControl
export wControl

const
  wMenuBarCtrlCustumDraw = defined(useWinXP) or defined(nores)
  wEvent_MenuBarCtrlDropdown = wEventId()

type
  wMenuBarCtrlGlobal = object
    ctrls: seq[wBase.wMenuBarCtrl]
    focused: wMenuBarCtrl
    self: wMenuBarCtrl

var g {.threadvar.}: wMenuBarCtrlGlobal

template passMessage(self: wMenuBarCtrl, msg: UINT; wparam, lparam: typed): untyped =
  CallWindowProc(self.mOldWndProc, self.mHwnd, msg, cast[WPARAM](wparam), cast[LPARAM](lparam))

proc resetRtl(self: wMenuBarCtrl) =
  self.mRtl = false
  let exStyle = GetWindowLongPtr(self.mHwnd, GWL_EXSTYLE)

  if (exStyle and WS_EX_LAYOUTRTL) != 0:
    self.mRtl = not self.mRtl

  if (exStyle and WS_EX_RTLREADING) != 0:
    self.mRtl = not self.mRtl

proc showAccel(self: wMenuBarCtrl, flag: bool) =
  # Show or hide keyboard accelerators
  let flag = if self.isEnabled(): flag else: false

  var action: WORD
  if flag:
    action = UIS_CLEAR

  else:
    var show: BOOL
    if SystemParametersInfo(SPI_GETMENUUNDERLINES, 0, &show, 0) == 0:
      action = UIS_CLEAR

    else:
      action = if show: UIS_CLEAR else: UIS_SET

  PostMessage(self.mHwnd, WM_CHANGEUISTATE, MAKELONG(action, UISF_HIDEACCEL), 0)

proc setHotItemOnCursor(self: wMenuBarCtrl) =
  # Reset HotItem on mouse cursor after menu disappear
  var pt: POINT
  GetCursorPos(&pt)
  MapWindowPoints(0, self.mHwnd, &pt, 1)
  let item = self.passMessage(TB_HITTEST, 0, &pt)
  self.passMessage(TB_SETHOTITEM, item, 0)

proc showDropdown(self: wMenuBarCtrl, item: int, fromKeyboard: bool) =
  # Prepare and show the dropdown menu
  let period = GetMessageTime() - self.mBlockerStart
  if -200 <= period and period <= 0:
    return

  self.mPressedItem = item
  self.mFromKeyboard = fromKeyboard
  if self.isEnabled() and self.mMenuBar != nil:
    PostMessage(self.mHwnd, wEvent_MenuBarCtrlDropdown, 0, 0)

proc displayHelp(self: wMenuBarCtrl, text: string) =
  # Display or clear help message on statusbar
  var display = false

  if text.len == 0 and self.mHelpDisplayed:
    display = true
    self.mHelpDisplayed = false

  elif text.len != 0:
    display = true
    self.mHelpDisplayed = true

  if display:
    SendMessage(self.mHelpStatusBar.mHwnd, SB_SETTEXT,
      LOBYTE(self.mHelpStatusBar.mHelpIndex), &T(text))

proc count(self: wMenuBarCtrl): int {.inline.} =
  result = int self.passMessage(TB_BUTTONCOUNT, 0, 0)

proc isItemEnabled(self: wMenuBarCtrl, item: int): bool =
  let state = self.passMessage(TB_GETSTATE, item, 0)
  result = (state and TBSTATE_ENABLED) != 0

proc nextItem(self: wMenuBarCtrl, item: int): int =
  result = item + 1
  if result >= self.count(): result = 0

proc nextEnabledItem(self: wMenuBarCtrl, item: int): int =
  result = item
  while true:
    result = self.nextItem(result)
    if self.isItemEnabled(result): return result
    if result == item: return -1

proc prevItem(self: wMenuBarCtrl, item: int): int =
  result = item - 1
  if result < 0: result = self.count() - 1

proc prevEnabledItem(self: wMenuBarCtrl, item: int): int =
  result = item
  while true:
    result = self.prevItem(result)
    if self.isItemEnabled(result): return result
    if result == item: return -1

proc gprev(index: int): int =
  result = index - 1
  if result < 0: result = g.ctrls.len - 1

proc gnext(index: int): int =
  result = index + 1
  if result >= g.ctrls.len: result = 0

proc nextEnabledMenuBarCtrl(self: wMenuBarCtrl): wMenuBarCtrl =
  var last, index: int
  if self.isNil:
    (index, last) = (0, gprev(0))
  else:
    index = g.ctrls.find(self)
    (index, last) = if index < 0: (0, gprev(0)) else: (gnext(index), gprev(index))

  while true:
    let mbc = g.ctrls[index]
    if mbc.isEnabled() and mbc.mMenuBar != nil: return mbc
    if index == last: return nil
    index = gnext(index)

proc prevEnabledMenuBarCtrl(self: wMenuBarCtrl): wMenuBarCtrl =
  var last, index: int
  if self.isNil:
    (index, last) = (gprev(0), 0)
  else:
    index = g.ctrls.find(self)
    (index, last) = if index < 0: (gprev(0), 0) else: (gprev(index), gnext(index))

  while true:
    let mbc = g.ctrls[index]
    if mbc.isEnabled() and mbc.mMenuBar != nil: return mbc
    if index == last: return nil
    index = gprev(index)

proc changeDropdown(self: wMenuBarCtrl, item: int, fromKeyboard: bool) =
  # Change or close(-1) specified dropdown menu
  self.mFromKeyboard = fromKeyboard
  self.mContinueHotTrack = true
  self.mPressedItem = item
  self.passMessage(WM_CANCELMODE, 0, 0)

proc wMenuBarCtrl_MsgFilter(nCode: int32, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  # Deal with message during dropdown menu is active.
  if nCode >= 0:
    let
      self = g.self
      msg = cast[ptr MSG](lParam)

    case msg.message
    of WM_MOUSEMOVE:
      var doHotTract = true

      # Avoid hot tract if cursor is in the menu
      let menuHwnd = FindWindow("#32768", nil)
      if IsWindow(menuHwnd):
        var rect: RECT
        GetWindowRect(menuHwnd, rect)
        if PtInRect(rect, msg.pt): doHotTract = false

      # Mouse hot track, able to across different menubars
      if doHotTract:
        for mbc in g.ctrls:
          if not mbc.isEnabled(): continue
          var pt = msg.pt
          MapWindowPoints(0, mbc.mHwnd, &pt, 1)

          let item = int mbc.passMessage(TB_HITTEST, 0, &pt)
          if mbc.mLastPos != pt:
            mbc.mLastPos = pt
            if item in 0..<self.count():
              self.displayHelp("")

              if mbc.isItemEnabled(item):
                if mbc != self:
                  self.changeDropdown(-1, false)
                  mbc.showDropdown(item, true)
                elif item != self.mPressedItem:
                  self.changeDropdown(item, false)
              break

    of WM_KEYDOWN, WM_SYSKEYDOWN:
      var vk = msg.wParam
      if self.mRtl:
        if vk == VK_LEFT: vk = VK_RIGHT
        elif vk == VK_RIGHT: vk = VK_LEFT

      case vk
      of VK_MENU, VK_F10:
        self.changeDropdown(-1, true)
        return 1

      of VK_LEFT:
        self.changeDropdown(self.prevEnabledItem(self.mPressedItem), true)
        return 1

      of VK_RIGHT:
        self.changeDropdown(self.nextEnabledItem(self.mPressedItem), true)
        return 1

      of VK_TAB:
        # <Tab>, <Shift>+<Tab> to across menubars
        var mbc: wMenuBarCtrl
        if (GetKeyState(VK_SHIFT) and 0x8000) != 0:
          mbc = self.prevEnabledMenuBarCtrl()
        else:
          mbc = self.nextEnabledMenuBarCtrl()

        if mbc != nil:
          self.changeDropdown(-1, true)
          mbc.showDropdown(mbc.mLastItem, true)
          return 1

      else: discard

    else: discard

  result = CallNextHookEx(0, nCode, wParam, lParam)

proc unhook(self: wMenuBarCtrl) =
  if self.mHook != 0:
    UnhookWindowsHookEx(self.mHook)
    self.mHook = 0

  if g.self == self:
    g.self = nil

proc hook(self: wMenuBarCtrl) =
  self.unhook()
  self.mHook = SetWindowsHookEx(WH_MSGFILTER, wMenuBarCtrl_MsgFilter, wAppGetInstance(),
    GetCurrentThreadId())

  if self.mHook != 0:
    g.self = self
    GetCursorPos(&self.mLastPos)
    MapWindowPoints(0, self.mHwnd, &self.mLastPos, 1)

proc wMenuBarCtrl_OnDropdown(self: wMenuBarCtrl) =
  # Loop to show and change dropdown
  var params = TPMPARAMS(cbSize: sizeof(TPMPARAMS))

  self.hook()
  self.setFocus()

  self.mContinueHotTrack = true
  while self.mContinueHotTrack:
    let item = self.mPressedItem

    if self.mFromKeyboard:
      keybd_event(VK_DOWN, 0, 0, 0)
      keybd_event(VK_DOWN, 0, KEYEVENTF_KEYUP, 0)

    self.mFromKeyboard = false

    let state = self.passMessage(TB_GETSTATE, item, 0)
    self.passMessage(TB_SETHOTITEM, item, 0)
    self.passMessage(TB_SETSTATE, item, MAKELONG(state or TBSTATE_PRESSED, 0))
    self.passMessage(TB_GETITEMRECT, item, &params.rcExclude)

    if wAppWinVersion() >= 6.0 and wUsingTheme():
      # Fix for consistency with a native menu on newer Windows
      # when styles are enabled.
      params.rcExclude.bottom.dec

    MapWindowPoints(self.mHwnd, HWND_DESKTOP, cast[ptr POINT](&params.rcExclude), 2)

    let pmflags = TPM_LEFTBUTTON or TPM_VERTICAL or (if self.mRtl: TPM_LAYOUTRTL else: 0)
    let hMenu = GetSubMenu(self.mMenuBar.mHmenu, item)
    let x = if self.mRtl: params.rcExclude.right else: params.rcExclude.left
    self.mContinueHotTrack = false

    if (state and TBSTATE_ENABLED) != 0:
      if item >= 0: self.mLastItem = item
      TrackPopupMenuEx(hMenu, pmflags, x, params.rcExclude.bottom, self.mHwnd, &params)

    self.passMessage(TB_SETSTATE, item, MAKELONG(state, 0))

  self.mBlockerStart = GetTickCount()
  self.unhook()
  self.setHotItemOnCursor()
  SetFocus(self.mOldFocus)

proc wMenuBarCtrl_HookProc(self: wWindow, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool =
  # Superclassed toolbar
  let self = wBase.wMenuBarCtrl(self)
  case msg
  of WM_UPDATEUISTATE:
    # to avoid disabled menubar control shows the accelerators
    if not self.isEnabled() and wParam == MAKELONG(UIS_CLEAR, UISF_HIDEACCEL):
      return true

  of WM_MENUSELECT:
    if self.mHelpStatusBar != nil and self.mMenuBar != nil:
      let
        hmenu = HMENU lParam
        flag = HIWORD(wParam)
        menuId = LOWORD(wParam)

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

      let text = if selectedItem != nil: selectedItem.mHelp else: ""
      self.displayHelp(text)
      return true

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    var vk = wParam
    if self.mRtl:
      if vk == VK_LEFT: vk = VK_RIGHT
      elif vk == VK_RIGHT: vk = VK_LEFT

    case vk
    of VK_ESCAPE, VK_F10, VK_MENU:
      SetFocus(self.mOldFocus)
      self.setHotItemOnCursor()
      g.focused = nil
      self.showAccel(false)
      return true

    of VK_LEFT:
      if self.mHotItem >= 0:
        self.passMessage(TB_SETHOTITEM, self.prevEnabledItem(self.mHotItem), 0)
        self.showAccel(true)
        return true

    of VK_RIGHT:
      if self.mHotItem >= 0:
        self.passMessage(TB_SETHOTITEM, self.nextEnabledItem(self.mHotItem), 0)
        self.showAccel(true)
        return true

    of VK_TAB:
      # <Tab>, <Shift>+<Tab> to across menubars
      var mbc: wMenuBarCtrl
      if (GetKeyState(VK_SHIFT) and 0x8000) != 0:
        mbc = self.prevEnabledMenuBarCtrl()
      else:
        mbc = self.nextEnabledMenuBarCtrl()

      if mbc != nil:
        self.mLastItem = self.mHotItem
        mbc.passMessage(TB_SETHOTITEM, mbc.mLastItem, 0)
        mbc.setFocus()
        mbc.showAccel(true)
        return true

    else: discard

  of WM_SETFOCUS:
    if self.mHwnd != wParam:
      # make sure the mOldFocus is not a menubar control
      let win = wAppWindowFindByHwnd(HWND wParam)
      if win != nil and win of wBase.wMenuBarCtrl:
        self.mOldFocus = wBase.wMenuBarCtrl(win).mOldFocus

      else:
        self.mOldFocus = HWND wParam

    g.focused = self

  of WM_KILLFOCUS:
    self.passMessage(TB_SETHOTITEM, -1, 0)
    self.showAccel(false)
    g.focused = nil

  of WM_STYLECHANGED:
    if wParam == GWL_EXSTYLE:
      self.resetRtl()
      self.refresh()

  of wEvent_MenuBarCtrlDropdown:
    self.wMenuBarCtrl_OnDropdown()
    return true

  else: discard

method processNotify(self: wMenuBarCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool {.shield.} =

  case code
  of NM_CUSTOMDRAW:
    let info = cast[LPNMTBCUSTOMDRAW](lparam)
    var custumDraw = false

    when wMenuBarCtrlCustumDraw:
      custumDraw = not (wAppWinVersion() >= 6.0 and wUsingTheme())

    if info.nmcd.dwDrawStage == CDDS_PREERASE and not custumDraw:
      if self.mBackgroundColor != -1:
        let hdc = info.nmcd.hdc
        var rect = info.nmcd.rc
        let oldcr = SetBkColor(hdc, self.mBackgroundColor)
        ExtTextOut(hdc, 0, 0, ETO_OPAQUE, rect, "", 0, nil)
        SetBkColor(hdc, oldcr)
        ret = CDRF_SKIPDEFAULT
        return true

    when wMenuBarCtrlCustumDraw:
      case info.nmcd.dwDrawStage
      of CDDS_PREPAINT:
        ret = if custumDraw: CDRF_NOTIFYITEMDRAW else: CDRF_DODEFAULT
        return true

      of CDDS_ITEMPREPAINT:
        var fgColor, bgColor: int
        let hdc = info.nmcd.hdc

        if (info.nmcd.uItemState and (CDIS_HOT or CDIS_SELECTED)) != 0:
          fgColor = COLOR_HIGHLIGHTTEXT
          bgColor = COLOR_HIGHLIGHT
        else:
          fgColor = COLOR_MENUTEXT
          bgColor = -1

        var buffer = T(65536)
        var btn = TBBUTTONINFO(
          cbSize: sizeof(TBBUTTONINFO),
          dwMask: TBIF_TEXT,
          pszText: &buffer,
          cchText: buffer.len)

        var flags = DT_CENTER or DT_VCENTER or DT_SINGLELINE

        self.passMessage(TB_GETBUTTONINFO, info.nmcd.dwItemSpec, &btn)
        if (self.passMessage(WM_QUERYUISTATE, 0, 0) and UISF_HIDEACCEL) != 0:
          flags = flags or DT_HIDEPREFIX

        if bgColor >= 0:
          FillRect(hdc, &info.nmcd.rc, bgColor + 1)

        elif self.mBackgroundColor != -1:
          FillRect(hdc, &info.nmcd.rc, self.mBackgroundBrush.mHandle)

        SetTextColor(hdc, GetSysColor(fgColor))
        let old_font = SelectObject(hdc, self.passMessage(WM_GETFONT, 0, 0))
        SetBkMode(hdc, TRANSPARENT)
        DrawText(hdc, &buffer, -1, &info.nmcd.rc, flags)
        SelectObject(hdc, old_font)
        ret = CDRF_SKIPDEFAULT
        return true

      else: discard

  of TBN_DROPDOWN:
    let info = cast[LPNMTOOLBAR](lparam)
    self.showDropdown(info.iItem, false)
    ret = TBDDRET_DEFAULT
    return true

  of TBN_HOTITEMCHANGE:
    let info = cast[LPNMTBHOTITEM](lParam)
    self.mHotItem = if (info.dwFlags and HICF_LEAVING) != 0: -1 else: info.idNew

  else: discard
  return procCall wControl(self).processNotify(code, id, lParam, ret)

proc wMenuBarCtrl_ProcessMenuKey(msg: var wMsg, modalHwnd: HWND = 0): int =
  # Deal with message about <F10>, <ALT>, and accelerator keys
  var delayedActivation {.threadvar.}: bool

  if modalHwnd != 0 or g.ctrls.len == 0: return 0 # nothing to do

  block okay:
    case msg.message
    of WM_SYSKEYDOWN, WM_KEYDOWN:
      # Only interested in <F10> and <ALT>
      if msg.wParam notin {VK_F10, VK_MENU}: break okay
      # Ignore if a menubar is already focused
      if g.focused != nil or delayedActivation: break okay
      # Ignore <SHIFT>+<F10>
      if msg.wParam == VK_F10 and (GetKeyState(VK_SHIFT) and 0x8000) != 0: break okay
      # Ignore auto-repeat messages
      if (msg.lParam and 0x40000000) != 0: break okay

      # For standard menubar, Windows does update UI state now for <ALT>,
      # but for <F10> this is delayed into WM_(SYS)KEYUP
      if msg.wParam == VK_MENU:
        for mbc in g.ctrls: mbc.showAccel(true)

      # The actual activation is delayed into WM_(SYS)KEYUP
      delayedActivation = true
      return 1

    of WM_SYSKEYUP, WM_KEYUP:
      # Only interested in <F10> and <ALT>
      if msg.wParam notin {VK_F10, VK_MENU}: break okay
      # Only messages related to nice WM_(SYS)KEYDOWN are relevant
      if not delayedActivation:
        for mbc in g.ctrls: mbc.showAccel(false)
        break okay

      # Activate the menubar
      let mbc = nextEnabledMenuBarCtrl(nil)
      if mbc != nil:
        mbc.setFocus()
        mbc.passMessage(TB_SETHOTITEM, 0, 0)

      for mbc in g.ctrls:
        mbc.mLastItem = 0
        mbc.showAccel(true)

      delayedActivation = false
      return 1

    of WM_SYSCHAR:
      # Handle hot keys (<ALT> + something)
      if msg.wParam != VK_MENU and (msg.lParam and 0x20000000) != 0:
        var item: UINT
        for mbc in g.ctrls:
          if mbc.isEnabled() and mbc.passMessage(TB_MAPACCELERATOR, msg.wParam, &item) != 0:
            mbc.setFocus()
            mbc.showAccel(true)
            mbc.showDropdown(item, true)
            return 1

        delayedActivation = false
        break okay

    of WM_LBUTTONDOWN, WM_RBUTTONDOWN:
      # Click outside of menubar contorl can kill the focus
      if g.focused != nil:
        var pt = msg.pt
        MapWindowPoints(0, g.focused.mHwnd, &pt, 1)
        let item = g.focused.passMessage(TB_HITTEST, 0, &pt)
        if item <= 0:
          SetFocus(g.focused.mOldFocus)

    else: discard

proc wMenuBarCtrlEnableMenuKey*(flag = true) =
  ## A static method that enables or disables <F10>, <ALT>, and accelerator keys
  ## on all menubar controls. By default, the standard menubar (if exists) will
  ## deal with these events.
  var hooked {.threadvar.}: bool
  if flag and not hooked:
    App().addMessageLoopHook(wMenuBarCtrl_ProcessMenuKey)
    hooked = true
  elif not flag and hooked:
    App().removeMessageLoopHook(wMenuBarCtrl_ProcessMenuKey)
    hooked = false

method getBestSize*(self: wMenuBarCtrl): wSize {.property, inline.} =
  ## Returns the best size for the tool bar.
  var size: SIZE
  self.passMessage(TB_GETIDEALSIZE, FALSE, &size)
  result.width = int size.cx

  let ret = self.passMessage(TB_GETBUTTONSIZE, 0, 0)
  result.height = int HIWORD(ret)

method getDefaultSize*(self: wMenuBarCtrl): wSize {.property, inline.} =
  ## Returns the default size for the tool bar.
  var size: SIZE
  self.passMessage(TB_GETIDEALSIZE, FALSE, &size)
  result.width = int size.cx

  let ret = self.passMessage(TB_GETBUTTONSIZE, 0, 0)
  let ret2 = self.passMessage(TB_GETPADDING, 0, 0)
  result.height = int(HIWORD(ret) + HIWORD(ret2))

proc setStatusBar*(self: wMenuBarCtrl, statusBar: wStatusBar) {.validate, property, inline.} =
  ## Associates a status bar with the menubar control to display the help text.
  self.mHelpStatusBar = statusBar

proc setMenuBar*(self: wMenuBarCtrl, menuBar: wMenuBar) {.validate, property.} =
  ## Tells the menubar control to show the given menubar.
  wValidate(menuBar)

  if self.mPressedItem >= 0:
    self.unhook()
    self.passMessage(WM_CANCELMODE, 0, 0)

  if self.mMenuBar != nil:
    let n = self.passMessage(TB_BUTTONCOUNT, 0, 0)
    for i in 0..<n:
      self.passMessage(TB_DELETEBUTTON, 0, 0)

  self.mMenuBar = menuBar
  let hMenu = menuBar.mHmenu

  let n = GetMenuItemCount(hMenu)
  if n == 0: return

  var
    buttons = newSeq[TBBUTTON](n)
    buffers = newSeq[TString](n)

  for i in 0..<n:
    let state = GetMenuState(hMenu, i, MF_BYPOSITION)
    buttons[i].iBitmap = I_IMAGENONE

    if (state and (MF_DISABLED or MF_GRAYED)) == 0:
      buttons[i].fsState = buttons[i].fsState or TBSTATE_ENABLED

    if (state and (MF_MENUBREAK or MF_MENUBARBREAK)) != 0 and i > 0:
      buttons[i - 1].fsState = buttons[i - 1].fsState or TBSTATE_WRAP

    if (state and MF_POPUP) != 0:
      buffers[i] = T(65536)
      if wGetMenuItemString(hMenu, i, buffers[i]) != 0:
        buttons[i].iString = cast[INT_PTR](&buffers[i])

      buttons[i].fsStyle = BTNS_AUTOSIZE or BTNS_DROPDOWN or BTNS_SHOWTEXT
      buttons[i].dwData = i
      buttons[i].idCommand = i

    else:
      buttons[i].dwData = 0xffff
      buttons[i].idCommand = 0xffff
      if (state and MF_SEPARATOR) != 0:
        buttons[i].fsStyle = BTNS_SEP
        buttons[i].iBitmap = 10

  self.passMessage(TB_ADDBUTTONS, n, &buttons[0])

wClass(wMenuBarCtrl of wControl):

  method release*(self: wMenuBarCtrl) =
    ## Release all the resources during destroying. Used internally.
    let index = g.ctrls.find(self)
    if index >= 0: g.ctrls.delete(index)
    free(self[])

  proc init*(self: wMenuBarCtrl, parent: wWindow, id = wDefaultID,
      menuBar: wMenuBar = nil, statusBar: wStatusBar = nil,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) {.validate.} =
    ## Initializes a menubar control.
    wValidate(parent)

    var wc: WNDCLASS
    GetClassInfo(0, TOOLBARCLASSNAME, &wc)
    self.mOldWndProc = wc.lpfnWndProc

    self.wControl.init(className=TOOLBARCLASSNAME, parent=parent, id=id,
      style=style or WS_CHILD or WS_VISIBLE or TBSTYLE_FLAT or TBSTYLE_TRANSPARENT or
        CCS_NODIVIDER or CCS_NOPARENTALIGN or CCS_NORESIZE or TBSTYLE_CUSTOMERASE)

    self.resetRtl()
    self.mHookProc = wMenuBarCtrl_HookProc
    self.mFocusable = false
    g.ctrls.add self

    self.setBackgroundColor(-1) # default transparent instead of parent's color
    self.passMessage(TB_BUTTONSTRUCTSIZE, sizeof(TBBUTTON), 0)
    self.passMessage(TB_SETBITMAPSIZE, 0, MAKELONG(0, -2))
    self.passMessage(TB_SETPADDING, 0, MAKELONG(10, 6))
    self.passMessage(TB_SETDRAWTEXTFLAGS, DT_CENTER or DT_VCENTER or DT_SINGLELINE,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE)

    self.showAccel(false)
    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      event.veto

    if menuBar != nil:
      self.setMenuBar(menuBar)

    if statusBar != nil:
      self.setStatusBar(statusBar)
