# statusbar's best size and default size are current size
method getBestSize*(self: wStatusBar): wSize =
  result = getSize()

method getDefaultSize*(self: wStatusBar): wSize =
  result = getSize()

proc resize(self: wStatusBar) =
  var
    width = self.getSize().width
    setWidths: array[256, int32]
    denominator = 0
    fixedSize = 0

  for i in 0..<mFiledNumbers:
    setWidths[i] = mWidths[i]
    if setWidths[i] >= 0:
      fixedSize += setWidths[i]
    else:
      denominator -= setWidths[i]

  var leftWidth = width - fixedSize
  for i in 0..<mFiledNumbers:
    if setWidths[i] < 0:
      setWidths[i] = (-setWidths[i].int * leftWidth div denominator).int32
    if i > 0: setWidths[i] += setWidths[i - 1]

  SendMessage(mHwnd, SB_SETPARTS, mFiledNumbers, addr setWidths)

proc setFieldsCount*(self: wStatusBar, number: int, setWidths: openarray[int] = []) =
  assert number <= 256 and number > 0
  mFiledNumbers = number

  for i in 0..<number:
    if i >= setWidths.len:
      mWidths[i] = -1
    else:
      mWidths[i] = setWidths[i].int32

  self.resize()

proc SetStatusWidths*(self: wStatusBar, number: int, setWidths: openarray[int]) =
  self.setFieldsCount(number, setWidths)

proc setStatusText*(self: wStatusBar, text = "", index = 0) =
  SendMessage(mHwnd, SB_SETTEXT, index, text.LPWSTR)

proc wStatusBarInit(self: wStatusBar, parent: wWindow, style: int64 = 0, id: wCommandID = -1) =
  assert parent != nil

  wControlInit(className=STATUSCLASSNAME, parent=parent, id=id, pos=(0, 0), size=(0, 0), style=style or WS_CHILD or WS_VISIBLE)
  mFiledNumbers = 1
  mWidths[0] = -1
  parent.mStatusBar = self
  mFocusable = false

  parent.systemConnect(WM_SIZE) do (event: wEvent):
    # send WM_SIZE to statubar to resize itself
    SendMessage(self.mHwnd, WM_SIZE, 0, 0)
    self.resize()

proc StatusBar*(parent: wWindow, style: int64 = 0, id: wCommandID = -1): wStatusBar =
  new(result)
  result.wStatusBarInit(parent=parent, style=style, id=id)
