## A static box is a rectangle drawn around other windows to denote a logical grouping of items.
##
## :Superclass:
##    wControl

proc getLabelSize(self: wStaticBox): wSize {.property.} =
  result = getTextFontSize(getLabel() & "  ", mFont.mHandle)

method getBestSize*(self: wStaticBox): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getLabelSize()
  result.width += 2
  result.height += 2

method getDefaultSize*(self: wStaticBox): wSize {.property.} =
  ## Returns the default size for the control.
  result.width = 120
  result.height = getLineControlDefaultHeight(mFont.mHandle)

method getClientAreaOrigin*(self: wStaticBox): wPoint {.property.} =
  ## Get the origin of the client area of the window relative to the window top left corner.
  result.x = mMargin.left
  result.y = mMargin.up
  let labelSize = getLabelSize()
  result.y += labelSize.height div 2

method getClientSize*(self: wStaticBox): wSize {.property.} =
  ## Returns the size of the window 'client area' in pixels.
  result = procCall wWindow(self).getClientSize()
  let labelSize = getLabelSize()
  result.height -= labelSize.height div 2

proc init(self: wStaticBox, parent: wWindow, id: wCommandID = -1, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  # staticbox need WS_CLIPSIBLINGS
  self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or BS_GROUPBOX or WS_CLIPSIBLINGS)

  mFocusable = false
  setMargin(12)

proc StaticBox*(parent: wWindow, id: wCommandID = wDefaultID, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0): wStaticBox {.discardable.} =
  ## Constructor, creating and showing a static box.
  wValidate(parent, label)
  new(result)
  result.init(parent=parent, label=label, pos=pos, size=size, style=style)
