#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A static bitmap control displays a bitmap.
#
## :Appearance:
##   .. image:: images/wStaticBitmap.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wSbAuto                         Automatically sizes the control to accommodate the bitmap.
##   wSbFit                          Stretch or shrink the bitmap to fit the size.
##   wSbCenter                       Center the bitmap and clip if needed.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_CommandLeftClick          Clicked the left mouse button within the control.
##   wEvent_CommandLeftDoubleClick    Double-clicked the left mouse button within the control.
##   ===============================  =============================================================

include ../pragma
import ../wBase, ../gdiobjects/wBitmap, wControl, wStaticText
export wControl

const
  # StaticBitmap styles
  wSbAuto* = 0
  wSbFit* = SS_REALSIZECONTROL
  wSbCenter* = SS_CENTERIMAGE

method getBestSize*(self: wStaticBitmap): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  if self.mBitmap != nil:
    result = self.mBitmap.getSize()

method getDefaultSize*(self: wStaticBitmap): wSize {.property, inline.} =
  ## Returns the default size for the control.
  if self.mBitmap != nil:
    result = self.mBitmap.getSize()

proc setBitmap*(self: wStaticBitmap, bitmap: wBitmap) {.validate, property.} =
  ## Sets the bitmap label.
  self.mBitmap = bitmap
  SendMessage(self.mHwnd, STM_SETIMAGE, IMAGE_BITMAP,
    if bitmap != nil: bitmap.mHandle else: 0)

proc getBitmap*(self: wStaticBitmap): wBitmap {.validate, property, inline.} =
  ## Returns the bitmap currently used in the control.
  result = self.mBitmap

wClass(wStaticBitmap of wControl):

  method release*(self: wStaticBitmap) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mCommandConn)
    free(self[])

  proc init*(self: wStaticBitmap, parent: wWindow, id = wDefaultID,
      bitmap: wBitmap = nil, pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = wSbAuto) {.validate.} =
    ## Initializes static bitmap control.
    # Accepts nil bitmap for later assign.
    wValidate(parent)
    self.wControl.init(className=WC_STATIC, parent=parent, id=id, label="",
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY or SS_BITMAP)

    self.setBitmap(bitmap)
    self.mFocusable = false

    # translate wEvent_CommandLeftClick and wEvent_CommandLeftDoubleClick
    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      self.wStaticText_DoCommand(event)
