
method getBestSize*(self: wStaticText): wSize =
  result = getTextFontSize(getLabel(), mFont.mHandle)
  result.width += 2
  result.height += 2

method getDefaultSize*(self: wStaticText): wSize =
  result = getBestSize()
  result.height = getLineControlDefaultHeight(mFont.mHandle)

proc wStaticTextInit(self: wStaticText, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  self.wControl.init(className=WC_STATIC, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY)
  mFocusable = false

  systemConnect(WM_SIZE) do (event: wEvent):
    # when size change, StaticText should refresh itself, but windows system don't do it
    self.refresh()

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd:
      let cmdEvent = case HIWORD(event.mWparam.int32)
        of STN_CLICKED: wEvent_CommandLeftClick
        of STN_DBLCLK: wEvent_CommandLeftDoubleClick
        else: 0

      if cmdEvent != 0:
        var processed: bool
        event.mResult = self.mMessageHandler(self, cmdEvent, event.mWparam, event.mLparam, processed)

proc StaticText*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wStaticText {.discardable.} =
  new(result)
  result.wStaticTextInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)
