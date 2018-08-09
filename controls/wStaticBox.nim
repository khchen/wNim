proc getLabelSize(self: wStaticBox): wSize =
  result = getTextFontSize(getLabel() & "  ", mFont.mHandle)

method getBestSize*(self: wStaticBox): wSize =
  result = getLabelSize()
  result.width += 2
  result.height += 2

method getDefaultSize*(self: wStaticBox): wSize =
  result.width = 120
  result.height = getLineControlDefaultHeight(mFont.mHandle)

method getClientAreaOrigin*(self: wStaticBox): wPoint =
  result.x = mMarginX
  result.y = mMarginY
  let labelSize = getLabelSize()
  result.y += labelSize.height div 2

method getClientSize*(self: wStaticBox): wSize =
  result = procCall wWindow(self).getClientSize()
  let labelSize = getLabelSize()
  result.height -= labelSize.height div 2

proc wStaticBoxInit(self: wStaticBox, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  # staticbox need WS_CLIPSIBLINGS
  self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or BS_GROUPBOX or WS_CLIPSIBLINGS)
  mFocusable = false
  mMarginX = 12
  mMarginY = 12

proc StaticBox*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wStaticBox {.discardable.} =
  new(result)
  result.wStaticBoxInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)
