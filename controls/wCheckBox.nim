method getBestSize*(self: wCheckBox): wSize =
  # BCM_GETIDEALSIZE not works correct on BS_AUTO3STATE

  result = getTextFontSizeWithCheckMark(getLabel(), mFont.mHandle)
  result.height += 2

method getDefaultSize*(self: wCheckBox): wSize =
  result = getBestSize()
  result.height = getLineControlDefaultHeight(mFont.mHandle)

proc getValue*(self: wCheckBox): bool =
  result = SendMessage(mHwnd, BM_GETCHECK, 0, 0) == BST_CHECKED

proc isChecked*(self: wCheckBox): bool =
  result = getValue()

proc is3State*(self: wCheckBox): bool =
  result = case getWindowStyle() and 0xF
    of BS_3STATE, BS_AUTO3STATE: true
    else: false

proc get3StateValue*(self: wCheckBox): int =
  result = SendMessage(mHwnd, BM_GETCHECK, 0, 0).int

proc set3StateValue*(self: wCheckBox, state: int) =
  SendMessage(mHwnd, BM_SETCHECK, state, 0)

proc setValue*(self: wCheckBox, state: bool) =
  SendMessage(mHwnd, BM_SETCHECK, if state: BST_CHECKED else: BST_UNCHECKED, 0)

proc wCheckBoxInit(self: wCheckBox, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  let checkType = if (style and wChk3State) != 0: BS_AUTO3STATE else: BS_AUTOCHECKBOX

  # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
  let style = (style and (not 0xF)) or checkType

  wControlInit(self, className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd and HIWORD(event.mWparam.int32) == BN_CLICKED:
      var processed: bool
      event.mResult = self.mMessageHandler(self, wEvent_CheckBox, event.mWparam, event.mLparam, processed)

proc CheckBox*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wCheckBox =
  new(result)
  result.wCheckBoxInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)

# nim style getter/setter

proc value*(self: wCheckBox): bool = getValue()
proc `value=`*(self: wCheckBox, state: bool) = setValue(state)
