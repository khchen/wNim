#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
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

include pragma
import wBase, wWindow
export wWindow

wClass(wPanel of wWindow):

  method release*(self: wPanel) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wPanel, parent: wWindow, pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = 0, className = "wPanel") {.validate, inline.} =
    ## Initializer.
    wValidate(parent)
    self.wWindow.initVerbosely(parent=parent, pos=pos, size=size,
      style=style, className=className, bgColor=GetSysColor(COLOR_BTNFACE))
