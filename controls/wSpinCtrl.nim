
method getWindowRect(self: wSpinCtrl, sizeOnly = false): wRect =
  result = procCall wWindow(self).getWindowRect()
  result.width += mUpdownWidth

method setWindowRect(self: wSpinCtrl, x, y, width, height, flag = 0) =
  var
    width = width
    height = height
    flag = flag
    noSize = false

  if mUpdownHwnd != 0:
    if (flag and SWP_NOSIZE) != 0:
      # move only, but we must set size so that UDM_SETBUDDY works
      let rect = getWindowRect(sizeOnly=true)
      width = rect.width
      height = rect.height
      flag = flag and (not SWP_NOSIZE)
      noSize = true

  # cache the event and resent them after UDM_SETBUDDY
  var cacheSizeEvent, cacheMoveEvent: wEvent
  connect(WM_SIZE) do (event: wEvent):
    cacheSizeEvent = wEvent(mWparam: event.mWparam, mLparam: event.mLparam)

  connect(WM_MOVE) do (event: wEvent):
    cacheMoveEvent = wEvent(mWparam: event.mWparam, mLparam: event.mLparam)

  procCall wWindow(self).setWindowRect(x, y, width, height, flag)

  if mUpdownHwnd != 0:
    # reset buddy control, edit control size will be modified by UDM_SETBUDDY
    SendMessage(mUpdownHwnd, UDM_SETBUDDY, mHwnd, 0)

  disconnect(WM_SIZE, 1)
  disconnect(WM_MOVE, 1)

  if cacheMoveEvent != nil:
    SendMessage(mHwnd, WM_MOVE, cacheMoveEvent.mWparam, cacheMoveEvent.mLparam)

  if cacheSizeEvent != nil and not noSize:
    SendMessage(mHwnd, WM_SIZE, cacheSizeEvent.mWparam, cacheSizeEvent.mLparam)

method show*(self: wSpinCtrl, flag = true) =
  procCall wWindow(self).show(flag)
  if flag:
    ShowWindow(mUpdownHwnd, SW_SHOWNORMAL)
  else:
    ShowWindow(mUpdownHwnd, SW_HIDE)

method getDefaultSize*(self: wSpinCtrl): wSize =
  result.width = 120
  result.height = getLineControlDefaultHeight(mFont.mHandle)

method getBestSize*(self: wSpinCtrl): wSize =
  result = getTextFontSize("0000  ", mFont.mHandle)
  result.height = getLineControlDefaultHeight(mFont.mHandle)
  result.width += mUpdownWidth

proc getBase*(self: wSpinCtrl): int =
  result = SendMessage(mUpdownHwnd, UDM_GETBASE, 0, 0).int

proc getMax*(self: wSpinCtrl): int =
  discard SendMessage(mUpdownHwnd, UDM_GETRANGE32, 0, addr result)

proc getMin*(self: wSpinCtrl): int =
  discard SendMessage(mUpdownHwnd, UDM_GETRANGE32, addr result, 0)

proc getValue*(self: wSpinCtrl): int =
  var flag: BOOL
  result = SendMessage(mUpdownHwnd, UDM_GETPOS32, 0, addr flag).int
  if flag != 0:
    raise newException(ValueError, "invalid value")

proc setBase*(self: wSpinCtrl, base: int) =
  SendMessage(mUpdownHwnd, UDM_SETBASE, base, 0)

proc getUpdownHandle*(self: wSpinCtrl): HANDLE =
  result = mUpdownHwnd

proc setRange*(self: wSpinCtrl, min, max: int) =
  SendMessage(mUpdownHwnd, UDM_SETRANGE32, min, max)

proc setRange*(self: wSpinCtrl, range: Slice[int]) =
  SendMessage(mUpdownHwnd, UDM_SETRANGE32, range.a, range.b)

proc setSelection*(self: wSpinCtrl, range: Slice[int]) =
  cast[wTextCtrl](self).setSelection(range)

proc setValue*(self: wSpinCtrl, text: string) =
  SetWindowText(mHwnd, text)

proc setValue*(self: wSpinCtrl, value: int) =
  SendMessage(mUpdownHwnd, UDM_SETPOS32, 0, value)

proc wSpinCtrlInit(self: wSpinCtrl, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  # wAlignCentre = SS_CENTER = ES_CENTER = UDS_WRAP = 1
  # wAlignRight = SS_RIGHT = ES_RIGHT = UDS_SETBUDDYINT = 2
  # wSpReadOnly = wTeReadOnly = ES_READONLY = 0x800
  # So (ES_CENTER or ES_RIGHT or ES_READONLY) are edit control styles

  # since UDS_WRAP = 1 is used by edit control, we define wSpWrap* = UDS_ALIGNRIGHT = 4
  # if warp is needed, use only "wSpWrap" and don't use "UDS_WRAP"

  let
    textStyle = style and (ES_CENTER or ES_RIGHT or ES_READONLY) or ES_AUTOHSCROLL or wBorderSunken
    isWarp = (style and wSpWrap) != 0
    msStyle = DWORD(style and (not (UDS_WRAP or ES_READONLY))) or (if isWarp: UDS_WRAP else: 0) or UDS_ALIGNRIGHT or UDS_SETBUDDYINT or UDS_HOTTRACK
    exStyle = DWORD(style shr 32)

  wControlInit(className=WC_EDIT, parent=parent, id=id, label=label, pos=pos, size=size, style=textStyle or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  mUpdownHwnd = CreateWindowEx(exStyle, UPDOWN_CLASS, nil, msStyle or WS_CHILD or WS_VISIBLE, 0, 0, 0, 0, parent.mHwnd, 0, wAppGetInstance(), nil)
  setRange(0, 100) # the default value is 100~0 ?

  # UDM_SETBUDDY will shorten the edit control, so we can count mUpdownWidth
  var rect1, rect2: RECT
  GetWindowRect(mHwnd, rect1)
  SendMessage(mUpdownHwnd, UDM_SETBUDDY, mHwnd, 0)
  GetWindowRect(mHwnd, rect2)
  mUpdownWidth = int(rect1.right - rect2.right)

  mKeyUsed = {wUSE_RIGHT, wUSE_LEFT}

  systemConnect(WM_NCDESTROY) do (event: wEvent):
    DestroyWindow(mUpdownHwnd)
    mUpdownHwnd = 0

proc SpinCtrl*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wSpinCtrl =
  new(result)
  result.wSpinCtrlInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)

# nim style getter/setter

proc base*(self: wSpinCtrl): int = getBase()
proc max*(self: wSpinCtrl): int = getMax()
proc min*(self: wSpinCtrl): int = getMin()
proc value*(self: wSpinCtrl): int = getValue()
proc updownHandle*(self: wSpinCtrl): HANDLE = getUpdownHandle()
proc `base=`*(self: wSpinCtrl, base: int) = setBase(base)
proc `range=`*(self: wSpinCtrl, range: Slice[int]) = setRange(range)
proc `selection=`*(self: wSpinCtrl, range: Slice[int]) = setSelection(range)
proc `value=`*(self: wSpinCtrl, text: string) = setValue(text)
proc `value=`*(self: wSpinCtrl, value: int) = setValue(value)
