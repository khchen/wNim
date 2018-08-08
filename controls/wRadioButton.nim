method getBestSize*(self: wRadioButton): wSize =
  result = getTextFontSizeWithCheckMark(getLabel(), mFont.mHandle)
  result.height += 2

method getDefaultSize*(self: wRadioButton): wSize =
  result = getBestSize()
  result.height = getLineControlDefaultHeight(mFont.mHandle)

proc getValue*(self: wRadioButton): bool =
  result = SendMessage(mHwnd, BM_GETCHECK, 0, 0) == BST_CHECKED

proc setValue*(self: wRadioButton, state: bool) =
  SendMessage(mHwnd, BM_SETCHECK, if state: BST_CHECKED else: BST_UNCHECKED, 0)

proc wRadioButtonInit(self: wRadioButton, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
  let style = (style and (not 0xF)) or BS_AUTORADIOBUTTON

  wControlInit(self, className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd and HIWORD(event.mWparam.int32) == BN_CLICKED:
      var processed: bool
      event.mResult = self.mMessageHandler(self, wEvent_RadioButton, event.mWparam, event.mLparam, processed)

proc RadioButton*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wRadioButton =
  new(result)
  result.wRadioButtonInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)

# nim style getter/setter

proc value*(self: wRadioButton): bool = getValue()
proc `value=`*(self: wRadioButton, state: bool) = setValue(state)
