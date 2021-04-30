#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wClientDC must be constructed if an application wishes to paint on the
## client area of a window.
##
## Like other DC object, wClientDC need nim's destructors to release the resource.
#
## :Superclass:
##   `wDC <wDC.html>`_

include ../pragma
import ../wBase, ../wWindow, wDC
export wDC

method getSize*(self: wClientDC): wSize {.property.} =
  ## Gets the size of the device context.
  result = self.mCanvas.getClientSize()

proc ClientDC*(canvas: wWindow): wClientDC =
  ## Constructor.
  wValidate(canvas)
  result.mCanvas = canvas
  result.mHdc = GetDC(canvas.mHwnd)
  result.wDC.init(fgColor=canvas.mForegroundColor, bgColor=canvas.mBackgroundColor,
    background=canvas.mBackgroundColor, font=canvas.mFont)

proc delete*(self: var wClientDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  `=destroy`(self)
