## A static line is just a line which may be used to separate the groups of controls.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wLiHorizontal                   Creates a horizontal line.
##    wLiVertical                     Creates a vertical line.
##    ==============================  =============================================================

const
  wLiHorizontal* = SS_LEFT
  wLiVertical* = SS_RIGHT

method getDefaultSize*(self: wStaticLine): wSize {.property.} =
  ## Returns the default size for the control.
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

method getBestSize*(self: wStaticLine): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = getDefaultSize()

proc isVertical*(self: wStaticLine): bool {.validate.} =
  ## Returns true if the line is vertical, false if horizontal.
  result = (getWindowStyle() and wLiVertical) != 0

proc init(self: wStaticLine, parent: wWindow, id: wCommandID = -1,
  pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  # wLiVertical == SS_RIGHT == 2
  # wLiHorizontal == SS_LEFT == 0

  var size = size
  if size != wDefaultSize:
    let isVertical = (style and wLiVertical) != 0
    if isVertical:
      size.width = 2
    else:
      size.height = 2

  self.wControl.init(className=WC_STATIC, parent=parent, id=id,
    pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY or SS_SUNKEN)

  mFocusable = false

proc StaticLine*(parent: wWindow, id: wCommandID = wDefaultID, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = 0): wStaticLine {.discardable.} =
  ## Constructor, creating and showing a static line.
  wValidate(parent)
  new(result)
  result.init(parent=parent, pos=pos, size=size, style=style)
