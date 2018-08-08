# toolbar's best size and default size are current size
method getBestSize*(self: wToolBar): wSize =
  result = getSize()

method getDefaultSize*(self: wToolBar): wSize =
  result = getSize()

proc getToolsCount*(self: wToolBar): int =
  result = SendMessage(mHwnd, TB_BUTTONCOUNT, 0, 0).int

proc getToolPos*(self: wToolBar, toolId: wCommandID): int =
  var buttonInfo = TBBUTTONINFO(cbSize: sizeof(TBBUTTONINFO).int32)
  result = SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, addr buttonInfo).int

proc deleteToolByPos*(self: wToolBar, pos: int) =
  if pos >= 0:
    if SendMessage(mHwnd, TB_DELETEBUTTON, pos, 0) != 0:
      #todo delete help string
      mToolList.delete(pos)

proc deleteTool*(self: wToolBar, toolId: wCommandID) =
  deleteToolByPos(getToolPos(toolId))

proc clearTools*(self: wToolBar) =
  for i in 1..getToolsCount():
    deleteToolByPos(0)

proc insertTool*(self: wToolBar, pos: int, toolId: wCommandID, label: string = nil, bitmap: wBitmap = nil,
    shortHelp: string = nil, longHelp: string = nil, kind: int = wItemNormal) =

  var button: TBBUTTON
  button.fsState = TBSTATE_ENABLED
  button.fsStyle = kind.uint8
  button.idCommand = toolId.int32

  if label != nil:
    button.iString = cast[INT_PTR](&(T(label)))

  if (kind and BTNS_SEP) != 0:
    button.iBitmap = 5

  elif bitmap != nil:
    let size = bitmap.getSize()
    SendMessage(mHwnd, TB_SETBITMAPSIZE, 0, MAKELONG(size.width, size.height))

    var addBitmap: TTBADDBITMAP
    addBitmap.nID = cast[UINT_PTR](bitmap.mHandle)
    button.iBitmap = SendMessage(mHwnd, TB_ADDBITMAP, 1, addr addBitmap).int32

  if SendMessage(mHwnd, TB_INSERTBUTTON, pos, addr button) != 0:
    SendMessage(mHwnd, TB_AUTOSIZE, 0, 0)

    if shortHelp != nil: mShortHelpTable[toolId] = shortHelp
    if longHelp != nil: mLongHelpTable[toolId] = longHelp
    mToolList.insert(wToolBarTool(mBitmap: bitmap), pos)

proc insertSeparator*(self: wToolBar, pos: int) =
  insertTool(pos=pos, toolId=0.wCommandID, kind=BTNS_SEP)

proc addTool*(self: wToolBar, toolId: wCommandID, label: string = nil, bitmap: wBitmap = nil,
    shortHelp: string = nil, longHelp: string = nil, kind: int = wItemNormal) =

  insertTool(getToolsCount(), toolId, label, bitmap, shortHelp, longHelp, kind)

proc addSeparator*(self: wToolBar) =
  insertTool(pos=getToolsCount(), toolId=0.wCommandID, kind=BTNS_SEP)

proc addCheckTool*(self: wToolBar, toolId: wCommandID, label: string = nil, bitmap: wBitmap = nil,
    shortHelp: string = nil, longHelp: string = nil) =

  insertTool(getToolsCount(), toolId, label, bitmap, shortHelp, longHelp, kind=wItemCheck)

proc addRadioTool*(self: wToolBar, toolId: wCommandID, label: string = nil, bitmap: wBitmap = nil,
    shortHelp: string = nil, longHelp: string = nil) =

  insertTool(getToolsCount(), toolId, label, bitmap, shortHelp, longHelp, kind=wItemRadio)

proc enableTool*(self: wToolBar, toolId: wCommandID, enable = true) =
  SendMessage(mHwnd, TB_ENABLEBUTTON, toolId, enable)

proc getToolEnabled*(self: wToolBar, toolId: wCommandID): bool =
  result = (SendMessage(mHwnd, TB_GETSTATE, toolId, 0) and TBSTATE_ENABLED) != 0

proc toggleTool*(self: wToolBar, toolId: wCommandID, toggle = true) =
  var state = SendMessage(mHwnd, TB_GETSTATE, toolId, 0).WORD
  if toggle:
    state = state or TBSTATE_CHECKED.WORD
  else:
    state = state and (not TBSTATE_CHECKED.WORD)
  SendMessage(mHwnd, TB_SETSTATE, toolId, state)

proc getToolState*(self: wToolBar, toolId: wCommandID): bool =
  result = (SendMessage(mHwnd, TB_GETSTATE, toolId, 0) and TBSTATE_CHECKED) != 0

proc setToolShortHelp*(self: wToolBar, toolId: wCommandID, shortHelp: string = nil) =
  if shortHelp != nil:
    mShortHelpTable[toolId] = shortHelp
  else:
    mShortHelpTable.del(toolId)

proc setToolLongHelp*(self: wToolBar, toolId: wCommandID, longHelp: string = nil) =
  if longHelp != nil:
    mLongHelpTable[toolId] = longHelp
  else:
    mLongHelpTable.del(toolId)

proc getToolShortHelp*(self: wToolBar, toolId: wCommandID): string =
  result = mShortHelpTable.getOrDefault(toolId)

proc getToolLongHelp*(self: wToolBar, toolId: wCommandID): string =
  result = mLongHelpTable.getOrDefault(toolId)

proc getToolLabel*(self: wToolBar, toolId: wCommandID): string =
  var buffer = T(65536)
  var buttonInfo = TBBUTTONINFO(cbSize: sizeof(TBBUTTONINFO))
  buttonInfo.dwMask = TBIF_TEXT
  buttonInfo.cchText = 65536
  buttonInfo.pszText = &buffer

  SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, addr buttonInfo)
  buffer.nullTerminate
  result = $buffer

proc setToolLabel*(self: wToolBar, toolId: wCommandID, label: string) =
  # need to recreate a button so that TB_AUTOSIZE works
  let pos = getToolPos(toolId)
  if pos >= 0:
    var buttonInfo = TBBUTTONINFO(cbSize: sizeof(TBBUTTONINFO).int32)
    buttonInfo.dwMask = TBIF_IMAGE or TBIF_STATE or TBIF_STYLE
    SendMessage(mHwnd, TB_GETBUTTONINFO, toolId, addr buttonInfo)

    var button: TBBUTTON
    button.fsState = buttonInfo.fsState
    button.fsStyle = buttonInfo.fsStyle
    button.iBitmap = buttonInfo.iImage
    button.idCommand = toolId.int32

    if label != nil:
      button.iString = cast[INT_PTR](&(T(label)))

    SendMessage(mHwnd, TB_DELETEBUTTON, pos, 0)
    SendMessage(mHwnd, TB_INSERTBUTTON, pos, addr button)
    SendMessage(mHwnd, TB_AUTOSIZE, 0, 0)

proc setDropdownMenu*(self: wToolBar, toolId: wCommandID, menu: wMenu = nil) =
  if menu != nil:
    mMenuTable[toolId] = menu
  else:
    mMenuTable.del(toolId)

proc getDropdownMenu*(self: wToolBar, toolId: wCommandID): wMenu =
  result = mMenuTable.getOrDefault(toolId)

proc wToolBarNotifyHandler(self: wToolBar, code: INT, id: UINT_PTR, lparam: LPARAM, processed: var bool): LRESULT =
  case code
  of TTN_GETDISPINFO:
    var
      text = mShortHelpTable.getOrDefault(id.wCommandID)
      pNMTTDISPINFO = cast[LPNMTTDISPINFO](lparam)

    pNMTTDISPINFO.lpszText = T(text)

  of TBN_HOTITEMCHANGE:
    var
      pNMTBHOTITEM = cast[LPNMTBHOTITEM](lparam)
      statusBar: wStatusBar
      parent = mParent

    while parent != nil:
      if parent.mStatusBar != nil:
        statusBar = parent.mStatusBar
        break
      parent = parent.mParent

    if statusBar != nil:
      var text = mLongHelpTable.getOrDefault(pNMTBHOTITEM.idNew.wCommandID)
      statusBar.setStatusText(text)

    return self.mMessageHandler(self, wEvent_ToolEnter, cast[WPARAM](pNMTBHOTITEM.idNew), lparam, processed)

  of TBN_DROPDOWN:
    let pNMTOOLBAR = cast[LPNMTOOLBAR](lparam)
    return self.mMessageHandler(self, wEvent_ToolDropDown, cast[WPARAM](pNMTOOLBAR.iItem), lparam, processed)

  of NM_RCLICK:
    let pNMMOUSE = cast[LPNMMOUSE](lparam)
    if getToolPos(pNMMOUSE.dwItemSpec.wCommandID) >= 0:
      return self.mMessageHandler(self, wEvent_ToolRightClicked, cast[WPARAM](pNMMOUSE.dwItemSpec), lparam, processed)

  else: discard

  return self.wControlNotifyHandler(code, id, lparam, processed)

proc wToolBarInit(self: wToolBar, parent: wWindow, id: wCommandID = -1, style: int64 = wTbDefaultStyle) =
  mShortHelpTable = newTable[wCommandID, string]()
  mLongHelpTable = newTable[wCommandID, string]()
  mMenuTable = newTable[wCommandID, wMenu]()
  mToolList = @[]

  wControlInit(className=TOOLBARCLASSNAME, parent=parent, id=id, style=style or WS_CHILD or WS_VISIBLE or TBSTYLE_TRANSPARENT or TBSTYLE_TOOLTIPS)
  SendMessage(mHwnd, TB_BUTTONSTRUCTSIZE, sizeof(TBBUTTON), 0)
  SendMessage(mHwnd, TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_DRAWDDARROWS)

  parent.mToolBar = self
  mFocusable = false

  wToolBar.setNotifyHandler(wToolBarNotifyHandler)

  parent.systemConnect(WM_SIZE) do (event: wEvent):
    SendMessage(mHwnd, TB_AUTOSIZE, 0, 0)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd and HIWORD(event.mWparam.int32) == 0:
      var processed: bool
      event.mResult = self.mMessageHandler(self, wEventTool, event.mWparam, event.mLparam, processed)

  hardConnect(wEvent_ToolDropDown) do (event: wEvent):
    var processed = false
    defer: event.mSkip = not processed
    if mHwnd == event.mWindow.mHwnd:

      let
        id = event.getId()
        menu = self.getDropdownMenu(id)

      if menu != nil:
        var rect: RECT
        SendMessage(self.mHwnd, TB_GETITEMRECT, self.getToolPos(id), addr rect)
        self.popupMenu(menu, rect.left.int, rect.bottom.int)
        processed = true

proc ToolBar*(parent: wWindow, id: wCommandID = -1, style: int64 = wTbDefaultStyle): wToolBar =
  new(result)
  result.wToolBarInit(parent=parent, id=id, style=style)
