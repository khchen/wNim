#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This class represents the color chooser dialog.
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wCdFullOpen                     Displays the full dialog with custom color selection controls.
##   wCdCenter                       Centers the window relative to it's owner.
##   wCdScreenCenter                 Centers the window on screen.
##   ==============================  =============================================================

const
  wCdFullOpen* = CC_FULLOPEN
  wCdCenter* = int64 0x10000000 shl 32
  wCdScreenCenter* = int64 0x20000000 shl 32

proc final*(self: wColorDialog) =
  ## Default finalizer for wColorDialog.
  discard

proc init*(self: wColorDialog, parent: wWindow = nil, defaultColor = wBlack,
    style: wStyle = 0) {.validate.} =
  ## Initializer.
  self.mParent = parent
  self.mColor = defaultColor
  self.mStyle = style

proc ColorDialog*(parent: wWindow = nil, defaultColor = wBlack,
    style: wStyle = 0): wColorDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, defaultColor, style)

proc getColor*(self: wColorDialog): wColor {.validate, property, inline.} =
  ## Returns the default or user-selected color.
  result = self.mColor

proc getCustomColor*(self: wColorDialog, i: range[0..15]): wColor
    {.validate, property, inline.} =
  ## Returns custom colors associated with the color dialog.
  result = self.mCustomColor[i]

proc setColor*(self: wColorDialog, color: wColor) {.validate, property, inline.} =
  ## Sets the default color.
  self.mColor = color

proc setCustomColor*(self: wColorDialog, i: range[0..15], color: wColor)
    {.validate, property, inline.} =
  ## Sets custom colors for the color dialog.
  self.mCustomColor[i] = color

proc wColorHookProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): UINT_PTR
    {.stdcall.} =

  if msg == WM_INITDIALOG:
    let pcc = cast[ptr TCHOOSECOLOR](lParam)
    let self = cast[wColorDialog](pcc.lCustData)

    if (self.mStyle and wCdScreenCenter) != 0:
      centerWindow(hwnd, inScreen=true)

    elif (self.mStyle and wCdCenter) != 0:
      centerWindow(hwnd, inScreen=false)


proc showModal*(self: wColorDialog): wId {.discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  var cc = TCHOOSECOLOR(
    lStructSize: sizeof(TCHOOSECOLOR),
    rgbResult: self.mColor,
    lpCustColors: &self.mCustomColor[0],
    lpfnHook: wColorHookProc,
    lCustData: cast[LPARAM](self))

  cc.Flags = CC_RGBINIT or CC_ANYCOLOR or CC_ENABLEHOOK or
    cast[DWORD](self.mStyle and 0xffffffff)

  if self.mParent != nil:
    cc.hwndOwner = self.mParent.mHwnd

  if ChooseColor(&cc):
    self.mColor = cc.rgbResult
    result = wIdOk
  else:
    result = wIdCancel

proc show*(self: wColorDialog): wId {.inline, discardable.} =
  ## The same as showModal().
  result = self.showModal()

proc showModalResult*(self: wColorDialog): wColor {.inline, discardable.} =
  ## Shows the dialog, returning the user-selected color.
  if self.showModal() == wIdOk:
    result = self.getColor()

proc showResult*(self: wColorDialog): wColor {.inline, discardable.} =
  ## The same as showModalResult().
  if self.show() == wIdOk:
    result = self.getColor()
