#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## A wPaintDC object must be constructed if an application wishes to paint on
## the client area of a window from within a wEvent_Paint event handler.
## To draw on a window from outside your wEvent_Paint event handler, construct
## a wClientDC object. To draw on the whole window including decorations,
## construct a wWindowDC object. A wPaintDC object is initialized to use the
## same font and colors as the window it is associated with.
##
## Like other DC object, wPaintDC need nim's destructors to release the resource.
## For nim version 0.18.0, you must compile with --newruntime option to get
## destructor works.
#
## :Superclass:
##   `wDC <wDC.html>`_

proc PaintDC*(canvas: wWindow): wPaintDC =
  ## Constructor. In wEvent_Paint event handler the wWindow object usually is
  ## event.window. For example:
  ##
  ## .. code-block:: Nim
  ##   frame.connect(wEvent_Paint) do (event: wEvent):
  ##     var dc = PaintDC(event.window)
  wValidate(canvas)
  result.mCanvas = canvas
  result.mHdc = BeginPaint(canvas.mHwnd, result.mPs)
  result.wDC.init(fgColor=canvas.mForegroundColor, bgColor=canvas.mBackgroundColor,
    background=canvas.mBackgroundBrush, font=canvas.mFont)

proc delete*(self: var wPaintDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  if self.mHdc != 0:
    self.wDC.final()
    EndPaint(self.mCanvas.mHwnd, self.mPs)
    self.mHdc = 0

proc `=destroy`(self: var wPaintDC) = self.delete()
