#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A wWindowDC must be constructed if an application wishes to paint on the
## whole area of a window.
##
## Like other DC object, wWindowDC need nim's destructors to release the resource.
## For nim version 0.18.0, you must compile with --newruntime option to get
## destructor works.
#
## :Superclass:
##   `wDC <wDC.html>`_

proc WindowDC*(canvas: wWindow): wWindowDC =
  ## Constructor.
  wValidate(canvas)
  result.mCanvas = canvas
  result.mHdc = GetWindowDC(canvas.mHwnd)
  result.wDC.init(fgColor=canvas.mForegroundColor, bgColor=canvas.mBackgroundColor,
    background=canvas.mBackgroundBrush, font=canvas.mFont)

proc delete*(self: var wWindowDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  if self.mHdc != 0:
    self.wDC.final()
    ReleaseDC(self.mCanvas.mHwnd, self.mHdc)
    self.mHdc = 0

proc `=destroy`(self: var wWindowDC) = self.delete()
