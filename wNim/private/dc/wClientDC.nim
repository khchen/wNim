#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## A wClientDC must be constructed if an application wishes to paint on the
## client area of a window.
##
## Like other DC object, wClientDC need nim's destructors to release the resource.
#
## :Superclass:
##   `wDC <wDC.html>`_

{.experimental, deadCodeElim: on.}

import ../wBase, ../wWindow, wDC
export wDC

when not isMainModule: # hide from doc
  type
    wClientDC* = object of wDC
      mCanvas*: wWindow
else:
  type
    wClientDC = object of wDC
      mCanvas: wWindow

proc `=destroy`(self: var wClientDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  if self.mHdc != 0:
    self.wDC.final()
    ReleaseDC(self.mCanvas.mHwnd, self.mHdc)
    self.mHdc = 0

method getSize*(self: wClientDC): wSize {.property, uknlock.} =
  ## Gets the size of the device context.
  result = self.mCanvas.getClientSize()

proc ClientDC*(canvas: wWindow): wClientDC =
  ## Constructor.
  wValidate(canvas)
  result.mCanvas = canvas
  result.mHdc = GetDC(canvas.mHwnd)
  result.wDC.init(fgColor=canvas.mForegroundColor, bgColor=canvas.mBackgroundColor,
    background=canvas.mBackgroundBrush, font=canvas.mFont)

proc delete*(self: var wClientDC) =
  self.`=destroy`()
