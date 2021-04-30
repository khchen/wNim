#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A screen device context can be used to paint on the screen.
##
## Like other DC object, wScreenDC need nim's destructors to release the resource.
#
## :Superclass:
##   `wDC <wDC.html>`_

include ../pragma
import ../wBase, wDC
export wDC

proc ScreenDC*(): wScreenDC =
  ## Constructor.
  result.mHdc = GetDC(0)
  result.wDC.init()

proc delete*(self: var wScreenDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  `=destroy`(self)
