#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class represents the font chooser dialog. Only modal dialog is
## supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Events:
##   `wDialogEvent <wDialogEvent.html>`_
##   ==============================   =============================================================
##   wDialogEvent                     Description
##   ==============================   =============================================================
##   wEvent_DialogCreated             When the dialog is created but not yet shown.
##   wEvent_DialogClosed              When the dialog is being closed.
##   wEvent_DialogApply               When the Apply button is pressed.
##   wEvent_DialogHelp                When the Help button is pressed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, ../gdiobjects/wFont, wDialog
export wDialog, wFont

proc getChosenFont*(self: wFontDialog): wFont {.validate, property, inline.} =
  ## Gets the font chosen by the user if the user pressed OK.
  result = self.mChosenFont

proc setInitialFont*(self: wFontDialog, font: wFont) {.validate, property, inline.} =
  ## Sets the font that will be initially used by the font dialog.
  self.mChosenFont = font
  if font != nil:
    self.mCf.Flags = self.mCf.Flags or CF_INITTOLOGFONTSTRUCT
    GetObject(font.mHandle, sizeof(LOGFONT), &self.mLf)
  else:
    self.mCf.Flags = self.mCf.Flags and (not CF_INITTOLOGFONTSTRUCT)

proc getColor*(self: wFontDialog): wColor {.validate, property, inline.} =
  ## Gets the color associated with the font dialog.
  result = self.mCf.rgbColors

proc setColor*(self: wFontDialog, color: wColor) {.validate, property, inline.} =
  ## Sets the color that will be used for the font foreground color.
  self.mCf.rgbColors = color

proc getRange*(self: wFontDialog): Slice[int] {.validate, property, inline.} =
  ## Returns the valid range for the font point size.
  result = self.mCf.nSizeMin.int..self.mCf.nSizeMax.int

proc setRange*(self: wFontDialog, min: int, max: int) {.validate, property, inline.} =
  ## Sets the valid range for the font point size, 0..0 means no limit.
  (self.mCf.nSizeMin, self.mCf.nSizeMax) = (min, max)
  if min == 0 and max == 0:
    self.mCf.Flags = self.mCf.Flags and (not CF_LIMITSIZE)
  else:
    self.mCf.Flags = self.mCf.Flags or CF_LIMITSIZE

proc setRange*(self: wFontDialog, range: Slice[int]) {.validate, property, inline.} =
  ## Sets the valid range for the font point size, 0..0 means no limit.
  self.setRange(range.a, range.b)

proc enableSymbols*(self: wFontDialog, flag = true) {.validate, inline.} =
  ## Enables or disables whether symbol fonts can be selected (by default yes).
  if flag:
    self.mCf.Flags = self.mCf.Flags and (not CF_SCRIPTSONLY)
  else:
    self.mCf.Flags = self.mCf.Flags or CF_SCRIPTSONLY

proc enableEffects*(self: wFontDialog, flag = true) {.validate, inline.} =
  ## Enables or disables effects (by default yes).
  if flag:
    self.mCf.Flags = self.mCf.Flags or CF_EFFECTS
  else:
    self.mCf.Flags = self.mCf.Flags and (not CF_EFFECTS)

proc enableApply*(self: wFontDialog, flag = true) =
  ## Display a Apply button, the dialog got wEvent_DialogApply event when the
  ## button pressed.
  if flag:
    self.mCf.Flags = self.mCf.Flags or CF_APPLY
  else:
    self.mCf.Flags = self.mCf.Flags and (not CF_APPLY)

proc enableHelp*(self: wFontDialog, flag = true) =
  ## Display a Help button, the dialog got wEvent_DialogHelp event when the
  ## button pressed.
  if flag:
    self.mCf.Flags = self.mCf.Flags or CF_SHOWHELP
  else:
    self.mCf.Flags = self.mCf.Flags and (not CF_SHOWHELP)

proc wFontHookProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): UINT_PTR
    {.stdcall.} =

  var self = cast[wFontDialog](GetWindowLongPtr(hwnd, GWLP_USERDATA))

  if msg == WM_INITDIALOG:
    self = cast[wFontDialog](cast[ptr TCHOOSEFONT](lParam).lCustData)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LPARAM](self))

  elif msg == WM_COMMAND:
    if HIWORD(int32 wParam) == BN_CLICKED and LOWORD(int32 wParam) == 1026:
      SendMessage(hwnd, WM_CHOOSEFONT_GETLOGFONT, 0, &self.mLf)
      self.mChosenFont = Font(&self.mLf)

      let event = Event(window=self, msg=wEvent_DialogApply)
      self.processEvent(event)

  if self != nil:
    result = self.wDialogHookProc(hwnd, msg, wParam, lParam)

wClass(wFontDialog of wDialog):

  proc init*(self: wFontDialog, owner: wWindow = nil, font: wFont = nil) {.validate.} =
    ## Initializer.
    self.wDialog.init(owner)
    self.mCf = TCHOOSEFONT(
      lStructSize: sizeof(TCHOOSEFONT),
      lpfnHook: wFontHookProc,
      lCustData: cast[LPARAM](self),
      lpLogFont: &self.mLf,
      Flags: CF_ENABLEHOOK)

    if owner != nil:
      self.mCf.hwndOwner = owner.mHwnd

    self.setInitialFont(font)
    self.enableEffects(true)

proc showModal*(self: wFontDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  if ChooseFont(&self.mCf):
    self.mChosenFont = Font(&self.mLf)
    result = wIdOk
  else:
    result = wIdCancel

proc display*(self: wFontDialog): wFont {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning the user-selected font or nil.
  if self.showModal() == wIdOk:
    result = self.getChosenFont()
