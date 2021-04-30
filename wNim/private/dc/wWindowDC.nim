#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wWindowDC must be constructed if an application wishes to paint on the
## whole area of a window.
##
## Like other DC object, wWindowDC need nim's destructors to release the resource.
#
## :Superclass:
##   `wDC <wDC.html>`_

include ../pragma
import ../wBase, ../wWindow, wDC
export wDC

method getSize*(self: wWindowDC): wSize {.property.} =
  ## Gets the size of the device context.
  result = self.mCanvas.getSize()

proc WindowDC*(canvas: wWindow): wWindowDC =
  ## Constructor.
  wValidate(canvas)
  result.mCanvas = canvas
  result.mHdc = GetWindowDC(canvas.mHwnd)
  result.wDC.init(fgColor=canvas.mForegroundColor, bgColor=canvas.mBackgroundColor,
    background=canvas.mBackgroundColor, font=canvas.mFont)

proc delete*(self: var wWindowDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  `=destroy`(self)
