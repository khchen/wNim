method getDefaultSize*(self: wGauge): wSize =
  result = getAverageASCIILetterSize(mFont.mHandle)
  result.width = MulDiv(result.width.int32, 107, 4).int
  result.height = MulDiv(result.height.int32, 8, 8).int

method getBestSize*(self: wGauge): wSize =
  result = getDefaultSize()

proc setIndeterminateMode(self: wGauge) =
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and PBS_MARQUEE) == 0:
    SetWindowLongPtr(mHwnd, GWL_STYLE, style or PBS_MARQUEE)
    SendMessage(mHwnd, PBM_SETMARQUEE, 1, 0)

    if taskbar != nil:
      taskbar.SetProgressState(getTopParent().mHwnd, TBPF_INDETERMINATE)

proc setDeterminateMode(self: wGauge) =
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and PBS_MARQUEE) != 0:
    SendMessage(mHwnd, PBM_SETMARQUEE, 0, 0)
    SetWindowLongPtr(mHwnd, GWL_STYLE, style and (not PBS_MARQUEE))

    if taskbar != nil:
      taskbar.SetProgressState(getTopParent().mHwnd, TBPF_NORMAL)

proc setRange*(self: wGauge, range: int) =
  setDeterminateMode()
  SendMessage(mHwnd, PBM_SETRANGE32, 0, range)

proc getRange*(self: wGauge): int =
  result = SendMessage(mHwnd, PBM_GETRANGE, FALSE, 0).int

proc setValue*(self: wGauge, value: int) =
  setDeterminateMode()
  SendMessage(mHwnd, PBM_SETPOS, value, 0)

  if taskbar != nil:
    let
      range = getRange()
      topParentHwnd = getTopParent().mHwnd

    if value >= range:
      taskbar.SetProgressState(topParentHwnd, TBPF_NOPROGRESS)
    else:
      taskbar.SetProgressValue(topParentHwnd, value.ULONGLONG, range.ULONGLONG)

proc getValue*(self: wGauge): int =
  result = SendMessage(mHwnd, PBM_GETPOS, 0, 0).int

proc pulse*(self: wGauge) =
  setIndeterminateMode()
  SendMessage(mHwnd, PBM_STEPIT, 0, 0)

proc pause*(self: wGauge) =
  if taskbar != nil:
    taskbar.SetProgressState(getTopParent().mHwnd, TBPF_PAUSED)

proc error*(self: wGauge) =
  if taskbar != nil:
    taskbar.SetProgressState(getTopParent().mHwnd, TBPF_ERROR)

proc isVertical*(self: wGauge): bool =
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and PBS_VERTICAL) != 0

proc wGaugeInit(self: wGauge, parent: wWindow, id: wCommandID = -1, range = 100, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  let
    taskBarProgress = ((style and wGaProgress) != 0)
    style = style and (not wGaProgress)

  self.wControl.init(className=PROGRESS_CLASS, parent=parent, id=id, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE)
  mFocusable = false

  setRange(range)

  if taskBarProgress:
    let
      messageId = RegisterWindowMessage("TaskbarButtonCreated")
      topParent = getTopParent()

    topParent.systemConnect(messageId) do (event: wEvent):
      CoInitialize(nil)
      coInit = true
      if CoCreateInstance(&CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER, &IID_ITaskbarList3, cast[ptr pointer](&taskbar)).SUCCEEDED:
        taskbar.SetProgressState(topParent.mHwnd, TBPF_NORMAL)

    systemConnect(WM_NCDESTROY) do (event: wEvent):
      if coInit:
        if taskbar != nil:
          taskbar.Release()
        CoUninitialize()

proc Gauge*(parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wGauge {.discardable.} =
  new(result)
  result.wGaugeInit(parent=parent, id=id, pos=pos, size=size, style=style)

# nim style getter/setter

proc range*(self: wGauge): int = getRange()
proc value*(self: wGauge): int = getValue()
proc `range=`*(self: wGauge, range: int) = setRange(range)
proc `value=`*(self: wGauge, value: int) = setValue(value)
