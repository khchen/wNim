## A gauge is a horizontal or vertical bar which shows a quantity.
## wGauge supports two working modes: determinate and indeterminate progress.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wGaHorizontal                   Creates a horizontal gauge.
##    wGaVertical                     Creates a vertical gauge.
##    wGaSmooth                       Creates smooth progress bar with one pixel wide update step.
##    wGaProgress                     Reflect the value of gauge in the taskbar button under Windows 7 and later.
##    ==============================  =============================================================

const
  # Gauge styles
  wGaHorizontal* = 0
  wGaVertical* = PBS_VERTICAL
  wGaSmooth* = PBS_SMOOTH
  wGaProgress* = 0x10000000 shl 32

method getDefaultSize*(self: wGauge): wSize {.property.} =
  ## Returns the default size for the control.
  result = getAverageASCIILetterSize(mFont.mHandle)
  result.width = MulDiv(result.width.int32, 107, 4)
  result.height = MulDiv(result.height.int32, 8, 8)

method getBestSize*(self: wGauge): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = getDefaultSize()

proc setIndeterminateMode(self: wGauge) =
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and PBS_MARQUEE) == 0:
    SetWindowLongPtr(mHwnd, GWL_STYLE, style or PBS_MARQUEE)
    SendMessage(mHwnd, PBM_SETMARQUEE, 1, 0)

    if mTaskBar != nil:
      mTaskBar.SetProgressState(getTopParent().mHwnd, TBPF_INDETERMINATE)

proc setDeterminateMode(self: wGauge) =
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and PBS_MARQUEE) != 0:
    SendMessage(mHwnd, PBM_SETMARQUEE, 0, 0)
    SetWindowLongPtr(mHwnd, GWL_STYLE, style and (not PBS_MARQUEE))

    if mTaskBar != nil:
      mTaskBar.SetProgressState(getTopParent().mHwnd, TBPF_NORMAL)

proc setRange*(self: wGauge, range: int) {.validate, property, inline.} =
  ## Sets the range (maximum value) of the gauge.
  setDeterminateMode()
  SendMessage(mHwnd, PBM_SETRANGE32, 0, range)

proc getRange*(self: wGauge): int {.validate, property, inline.} =
  ## Returns the maximum position of the gauge.
  result = int SendMessage(mHwnd, PBM_GETRANGE, FALSE, 0)

proc setValue*(self: wGauge, value: int) {.validate, property.} =
  ## Sets the position of the gauge. Use a value >= maximum to clear the taskbar progress.
  setDeterminateMode()
  SendMessage(mHwnd, PBM_SETPOS, value, 0)

  if mTaskBar != nil:
    let
      range = getRange()
      topParentHwnd = getTopParent().mHwnd

    if value >= range:
      mTaskBar.SetProgressState(topParentHwnd, TBPF_NOPROGRESS)
    else:
      echo mTaskBar.SetProgressValue(topParentHwnd, value.ULONGLONG, range.ULONGLONG)

proc getValue*(self: wGauge): int {.validate, property, inline.} =
  ## Returns the current position of the gauge
  result = int SendMessage(mHwnd, PBM_GETPOS, 0, 0)

proc pulse*(self: wGauge) {.validate, inline.} =
  ## Switch the gauge to indeterminate mode.
  setIndeterminateMode()
  SendMessage(mHwnd, PBM_STEPIT, 0, 0)

proc pause*(self: wGauge) {.validate, inline.} =
  ## Pause the taskbar progress.
  if mTaskBar != nil:
    mTaskBar.SetProgressState(getTopParent().mHwnd, TBPF_PAUSED)

proc error*(self: wGauge) {.validate, inline.} =
  ## Stop the taskbar progress and indicate an error.
  if mTaskBar != nil:
    mTaskBar.SetProgressState(getTopParent().mHwnd, TBPF_ERROR)

proc isVertical*(self: wGauge): bool {.validate, inline.} =
  ## Returns true if the gauge is vertical and false otherwise.
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and PBS_VERTICAL) != 0

proc init(self: wGauge, parent: wWindow, id: wCommandID = -1, range = 100, value = 0,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  let
    taskBarProgress = ((style and wGaProgress) != 0)
    style = style and (not wGaProgress)

  self.wControl.init(className=PROGRESS_CLASS, parent=parent, id=id, pos=pos,
    size=size, style=style or WS_CHILD or WS_VISIBLE)

  mFocusable = false
  setRange(range)
  setValue(value)

  if taskBarProgress:
    let
      messageId = RegisterWindowMessage("TaskbarButtonCreated")
      topParent = getTopParent()

    topParent.systemConnect(messageId) do (event: wEvent):
      if CoCreateInstance(&CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER,
          &IID_ITaskbarList3, cast[ptr pointer](&mTaskBar)).SUCCEEDED:
        mTaskBar.SetProgressState(topParent.mHwnd, TBPF_NORMAL)

    systemConnect(WM_NCDESTROY) do (event: wEvent):
      if mTaskBar != nil:
        mTaskBar.Release()

proc Gauge*(parent: wWindow, id: wCommandID = wDefaultID, range = 100, value = 0,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wGaHorizontal): wGauge {.discardable.} =
  ## Constructor, creating and showing a gauge.
  wValidate(parent)
  new(result)
  result.init(parent=parent, id=id, range=range, value=value, pos=pos, size=size, style=style)
