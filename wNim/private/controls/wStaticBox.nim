#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A static box is a rectangle drawn around other windows to denote a logical
## grouping of items.
#
## :Appearance:
##   .. image:: images/wStaticBox.png
#
## :Superclass:
##   `wControl <wControl.html>`_

include ../pragma
import ../wBase, wControl
export wControl

proc getLabelSize(self: wStaticBox): wSize {.property.} =
  result = getTextFontSize(self.getLabel() & "  ", self.mFont.mHandle, self.mHwnd)

method getBestSize*(self: wStaticBox): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = self.getLabelSize()
  result.width += 2
  result.height += 2

method getDefaultSize*(self: wStaticBox): wSize {.property.} =
  ## Returns the default size for the control.
  result.width = 120
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)

method getClientAreaOrigin*(self: wStaticBox): wPoint {.property.} =
  ## Get the origin of the client area of the window relative to the window top
  ## left corner.
  result.x = self.mMargin.left
  result.y = self.mMargin.up
  let labelSize = self.getLabelSize()
  result.y += labelSize.height div 2

method getClientSize*(self: wStaticBox): wSize {.property.} =
  ## Returns the size of the window 'client area' in pixels.
  result = procCall wWindow(self).getClientSize()
  let labelSize = self.getLabelSize()
  result.height -= labelSize.height div 2

wClass(wStaticBox of wControl):

  method release*(self: wStaticBox) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wStaticBox, parent: wWindow, id = wDefaultID, label: string = "",
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) {.validate.} =
    ## Initializes a static box.
    wValidate(parent, label)
    # staticbox need WS_CLIPSIBLINGS
    self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label,
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or BS_GROUPBOX or
      WS_CLIPSIBLINGS)

    self.mFocusable = false
    self.setMargin(12)
