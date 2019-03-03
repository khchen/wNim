#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A static line is just a line which may be used to separate the groups of
## controls.
#
## :Appearance:
##   .. image:: images/wStaticLine.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wLiHorizontal                   Creates a horizontal line.
##   wLiVertical                     Creates a vertical line.
##   ==============================  =============================================================

const
  wLiHorizontal* = SS_LEFT # 0
  wLiVertical* = SS_RIGHT # 2

method getDefaultSize*(self: wStaticLine): wSize {.property.} =
  ## Returns the default size for the control.
  let
    pos = self.getPosition()
    clientSize = self.mParent.getClientSize()
    isVertical = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and wLiVertical) != 0

  if isVertical:
    result.width = 2
    result.height = clientSize.height - pos.y * 2
  else:
    result.height = 2
    result.width = clientSize.width - pos.x * 2

method getBestSize*(self: wStaticLine): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = self.getDefaultSize()

proc isVertical*(self: wStaticLine): bool {.validate.} =
  ## Returns true if the line is vertical, false if horizontal.
  result = (self.getWindowStyle() and wLiVertical) != 0

proc final*(self: wStaticLine) =
  ## Default finalizer for wStaticLine.
  discard

proc init*(self: wStaticLine, parent: wWindow, id = wDefaultID, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = wLiHorizontal) {.validate.} =
  ## Initializer.
  wValidate(parent)
  var size = size
  if size != wDefaultSize:
    if (style and wLiVertical) != 0:
      size.width = 2
    else:
      size.height = 2

  self.wControl.init(className=WC_STATIC, parent=parent, id=id,
    pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY or SS_SUNKEN)

  self.mFocusable = false

proc StaticLine*(parent: wWindow, id = wDefaultID, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = wLiHorizontal): wStaticLine
    {.inline, discardable.} =
  ## Constructor, creating and showing a static line.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, pos, size, style)
