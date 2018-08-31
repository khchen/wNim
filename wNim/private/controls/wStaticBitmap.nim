#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

## A static bitmap control displays a bitmap.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wSbAuto                         Automatically sizes the control to accommodate the bitmap.
##    wSbFit                          Stretch or shrink the bitmap to fit the size.
##    wSbCenter                       Center the bitmap and clip if needed.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wCommandEvent                   Description
##    ==============================  =============================================================
##    wEvent_CommandLeftClick         Clicked the left mouse button within the control.
##    wEvent_CommandLeftDoubleClick   Double-clicked the left mouse button within the control.
##    ==============================  =============================================================

const
  # StaticBitmap styles
  wSbAuto* = 0
  wSbFit* = SS_REALSIZECONTROL
  wSbCenter* = SS_CENTERIMAGE

method getBestSize*(self: wStaticBitmap): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  if mBitmap != nil:
    result = mBitmap.getSize()

method getDefaultSize*(self: wStaticBitmap): wSize {.property, inline.} =
  ## Returns the default size for the control.
  if mBitmap != nil:
    result = mBitmap.getSize()

proc setBitmap*(self: wStaticBitmap, bitmap: wBitmap) {.validate, property.} =
  ## Sets the bitmap label.
  mBitmap = bitmap
  SendMessage(mHwnd, STM_SETIMAGE, IMAGE_BITMAP, if bitmap != nil: bitmap.mHandle else: 0)

proc getBitmap*(self: wStaticBitmap): wBitmap {.validate, property, inline.} =
  ## Returns the bitmap currently used in the control.
  result = mBitmap

proc final*(self: wStaticBitmap) =
  ## Default finalizer for wStaticBitmap.
  discard

proc init*(self: wStaticBitmap, parent: wWindow, id = wDefaultID,
    bitmap: wBitmap = nil, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wSbAuto) {.validate.} =

  wValidate(parent)
  self.wControl.init(className=WC_STATIC, parent=parent, id=id, label="", pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY or SS_BITMAP)

  setBitmap(bitmap)
  mFocusable = false

  # translate wEvent_CommandLeftClick and wEvent_CommandLeftDoubleClick
  parent.systemConnect(WM_COMMAND, wStaticText_DoCommand)

proc StaticBitmap*(parent: wWindow, id = wDefaultID,
    bitmap: wBitmap = nil, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wSbAuto): wStaticBitmap {.inline, discardable.} =
  ## Constructor, creating and showing a static bitmap control.
  # Acceptable nil bitmap for later assign.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, bitmap, pos, size, style=style)
