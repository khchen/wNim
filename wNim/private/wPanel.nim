#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A panel is a window on which controls are placed. It is usually placed within
## a frame.
#
## :Superclass:
##   `wWindow <wWindow.html>`_
#
## :Seealso:
##   `wControl <wControl.html>`_

proc final*(self: wPanel) =
  ## Default finalizer for wPanel.
  discard

proc init*(self: wPanel, parent: wWindow, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0, className = "wPanel") {.validate, inline.} =
  ## Initializer.
  wValidate(parent)
  self.wWindow.initVerbosely(parent=parent, pos=pos, size=size,
    style=style, className=className, bgColor=GetSysColor(COLOR_BTNFACE))

proc Panel*(parent: wWindow, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0, className = "wPanel"): wPanel {.inline, discardable.} =
  ## Constructor.
  wValidate(parent)
  new(result, final)
  result.init(parent, pos, size, style, className)
