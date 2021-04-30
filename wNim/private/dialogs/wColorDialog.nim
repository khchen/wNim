#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class represents the color chooser dialog. Only modal dialog is
## supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wCdFullOpen                     Displays the full dialog with custom color selection controls.
##   wCdCenter                       Centers the window relative to it's owner.
##   wCdScreenCenter                 Centers the window on screen.
##   ==============================  =============================================================
#
## :Events:
##   `wDialogEvent <wDialogEvent.html>`_
##   ==============================   =============================================================
##   wDialogEvent                     Description
##   ==============================   =============================================================
##   wEvent_DialogCreated             When the dialog is created but not yet shown.
##   wEvent_DialogClosed              When the dialog is being closed.
##   wEvent_DialogHelp                When the Help button is pressed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, wDialog
export wDialog

const
  wCdFullOpen* = CC_FULLOPEN
  wCdCenter* = 0x10000000.int64 shl 32
  wCdScreenCenter* = 0x20000000.int64 shl 32

proc getColor*(self: wColorDialog): wColor {.validate, property, inline.} =
  ## Returns the default or user-selected color.
  result = self.mCc.rgbResult

proc getCustomColor*(self: wColorDialog, i: range[0..15]): wColor
    {.validate, property, inline.} =
  ## Returns custom colors associated with the color dialog.
  result = self.mCustomColor[i]

proc setColor*(self: wColorDialog, color: wColor) {.validate, property, inline.} =
  ## Sets the default color.
  self.mCc.rgbResult = color

proc setCustomColor*(self: wColorDialog, i: range[0..15], color: wColor)
    {.validate, property, inline.} =
  ## Sets custom colors for the color dialog.
  self.mCustomColor[i] = color

proc enableHelp*(self: wColorDialog, flag = true) =
  ## Display a Help button, the dialog got wEvent_DialogHelp event when the
  ## button pressed.
  if flag:
    self.mCc.Flags = self.mCc.Flags or CC_SHOWHELP
  else:
    self.mCc.Flags = self.mCc.Flags and (not CC_SHOWHELP)

proc wColorHookProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): UINT_PTR
    {.stdcall.} =

  var self = cast[wColorDialog](GetWindowLongPtr(hwnd, GWLP_USERDATA))

  if msg == WM_INITDIALOG:
    self = cast[wColorDialog](cast[ptr TCHOOSECOLOR](lParam).lCustData)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LPARAM](self))
    assert self != nil

    if (self.mStyle and wCdScreenCenter) != 0:
      centerWindow(hwnd, inScreen=true)

    elif (self.mStyle and wCdCenter) != 0:
      centerWindow(hwnd, inScreen=false)

  if self != nil:
    result = self.wDialogHookProc(hwnd, msg, wParam, lParam)

wClass(wColorDialog of wDialog):

  proc init*(self: wColorDialog, owner: wWindow = nil, defaultColor = wBlack,
      style: wStyle = 0) {.validate.} =
    ## Initializer.
    self.wDialog.init(owner)
    self.mStyle = style
    self.mCc = TCHOOSECOLOR(
      lStructSize: sizeof(TCHOOSECOLOR),
      rgbResult: defaultColor,
      lpCustColors: &self.mCustomColor[0],
      lpfnHook: wColorHookProc,
      lCustData: cast[LPARAM](self),
      Flags: CC_RGBINIT or CC_ANYCOLOR or CC_ENABLEHOOK)

    if owner != nil:
      self.mCc.hwndOwner = owner.mHwnd

proc showModal*(self: wColorDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  if ChooseColor(&self.mCc):
    result = wIdOk
  else:
    result = wIdCancel

proc display*(self: wColorDialog): wColor {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the user-selected color or -1.
  if self.showModal() == wIdOk:
    result = self.getColor()
  else:
    result = -1
