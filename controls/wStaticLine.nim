method getDefaultSize*(self: wStaticLine): wSize =
  let
    pos = getPosition()
    clientSize = mParent.getClientSize()
    isVertical = (GetWindowLongPtr(mHwnd, GWL_STYLE) and wLiVertical) != 0

  if isVertical:
    result.width = 2
    result.height = clientSize.height - pos.y * 2
  else:
    result.height = 2
    result.width = clientSize.width - pos.x * 2

method getBestSize*(self: wStaticLine): wSize =
  result = getDefaultSize()

proc wStaticLineInit*(self: wStaticLine, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  # wLiVertical == SS_RIGHT == 2
  # wLiHorizontal == SS_LEFT == 0

  var size = size
  if size != wDefaultSize:
    let isVertical = (style and wLiVertical) != 0
    if isVertical:
      size.width = 2
    else:
      size.height = 2

  self.wControl.init(className=WC_STATIC, parent=parent, id=id, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY or SS_SUNKEN)
  mFocusable = false

proc StaticLine*(parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wStaticLine =
  new(result)
  result.wStaticLineInit(parent=parent, id=id, pos=pos, size=size, style=style)
