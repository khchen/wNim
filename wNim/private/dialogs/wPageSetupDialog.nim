#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class represents the page setup common dialog.The page setup dialog
## contains controls for paper size (letter, A4, A5 etc.), orientation
## (landscape or portrait), and left, top, right and bottom margin sizes.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Seealso:
##   `wPrinterDC <wPrinterDC.html>`_
##   `wPrintData <wPrintData.html>`_
##   `wPrintDialog <wPrintDialog.html>`_
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
import ../wBase, ../wPrintData, wDialog
export wDialog, wPrintData

type
  wPageSetupDialogError* = object of wError
    ## An error raised when wPageSetupDialog creation failed.

proc getPrintData*(self: wPageSetupDialog): wPrintData {.validate, property, inline.} =
  ## Returns the current wPrintData object for the dialog. The result may be nil.
  result = self.mPrintData

proc setPrintData*(self: wPageSetupDialog, printData: wPrintData) {.validate, property, inline.} =
  ## Sets a wPrintData object as default setting.
  self.mPrintData = printData

proc enableHelp*(self: wPageSetupDialog, flag = true) {.validate, inline.} =
  ## Display a Help button, the dialog got wEvent_DialogHelp event when the
  ## button pressed.
  if flag:
    self.mPsd.Flags = self.mPsd.Flags or PSD_SHOWHELP
  else:
    self.mPsd.Flags = self.mPsd.Flags and (not PSD_SHOWHELP)

proc enablePaper*(self: wPageSetupDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the paper size control.
  if flag:
    self.mPsd.Flags = self.mPsd.Flags and (not PSD_DISABLEPAPER)
  else:
    self.mPsd.Flags = self.mPsd.Flags or PSD_DISABLEPAPER

proc enableMargins*(self: wPageSetupDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the margin controls.
  if flag:
    self.mPsd.Flags = self.mPsd.Flags and (not PSD_DISABLEMARGINS)
  else:
    self.mPsd.Flags = self.mPsd.Flags or PSD_DISABLEMARGINS

proc enableOrientation*(self: wPageSetupDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the orientation control.
  if flag:
    self.mPsd.Flags = self.mPsd.Flags and (not PSD_DISABLEORIENTATION)
  else:
    self.mPsd.Flags = self.mPsd.Flags or PSD_DISABLEORIENTATION

proc enablePrinter*(self: wPageSetupDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the "Printer" button (Windows XP only).
  if flag:
    self.mPsd.Flags = self.mPsd.Flags and (not PSD_DISABLEPRINTER)
  else:
    self.mPsd.Flags = self.mPsd.Flags or PSD_DISABLEPRINTER

proc getPaperSize*(self: wPageSetupDialog): wSize {.validate, property, inline.} =
  ## Returns the paper size selected by the user, in millimetres.
  result.width = self.mPsd.ptPaperSize.x div 100
  result.height = self.mPsd.ptPaperSize.y div 100

proc getMinMargin*(self: wPageSetupDialog): wDirection {.validate, property.} =
  ## Returns the minimum margins the user can enter, in millimetres.
  result.left = self.mPsd.rtMinMargin.left div 100
  result.up = self.mPsd.rtMinMargin.top div 100
  result.right = self.mPsd.rtMinMargin.right div 100
  result.down = self.mPsd.rtMinMargin.bottom div 100

proc setMinMargin*(self: wPageSetupDialog, margin: wDirection) {.validate, property.} =
  ## Sets the minimum margins the user can enter, in millimetres.
  self.mPsd.rtMinMargin.left = margin.left * 100
  self.mPsd.rtMinMargin.top = margin.up * 100
  self.mPsd.rtMinMargin.right = margin.right * 100
  self.mPsd.rtMinMargin.bottom = margin.down * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MINMARGINS

proc setMinMargin*(self: wPageSetupDialog, margin: int) {.validate, property.} =
  ## Sets the minimum margins the user can enter to the same value, in millimetres.
  self.mPsd.rtMinMargin.left = margin * 100
  self.mPsd.rtMinMargin.top = margin * 100
  self.mPsd.rtMinMargin.right = margin * 100
  self.mPsd.rtMinMargin.bottom = margin * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MINMARGINS

proc getMinMarginTopLeft*(self: wPageSetupDialog): wPoint {.validate, property.} =
  ## Returns the left (x) and top (y) minimum margins the user can enter, in millimetres.
  result.x = self.mPsd.rtMinMargin.left div 100
  result.y = self.mPsd.rtMinMargin.top div 100

proc getMinMarginBottomRight*(self: wPageSetupDialog): wPoint {.validate, property.} =
  ## Returns the right (x) and bottom (y) minimum margins the user can enter, in millimetres.
  result.x = self.mPsd.rtMinMargin.right div 100
  result.y = self.mPsd.rtMinMargin.bottom div 100

proc setMinMarginTopLeft*(self: wPageSetupDialog, point: wPoint)
    {.validate, property, inline.} =
  ## Sets the left (x) and top (y) minimum margins the user can enter, in millimetres.
  self.mPsd.rtMinMargin.left = point.x * 100
  self.mPsd.rtMinMargin.top = point.y * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MINMARGINS

proc setMinMarginBottomRight*(self: wPageSetupDialog, point: wPoint)
    {.validate, property, inline.} =
  ## Sets the right (x) and bottom (y) minimum margins the user can enter, in millimetres.
  self.mPsd.rtMinMargin.right = point.x * 100
  self.mPsd.rtMinMargin.bottom = point.y * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MINMARGINS

proc getMargin*(self: wPageSetupDialog): wDirection {.validate, property.} =
  ## Returns the margins in millimetres.
  result.left = self.mPsd.rtMargin.left div 100
  result.up = self.mPsd.rtMargin.top div 100
  result.right = self.mPsd.rtMargin.right div 100
  result.down = self.mPsd.rtMargin.bottom div 100

proc setMargin*(self: wPageSetupDialog, margin: wDirection) {.validate, property.} =
  ## Sets the margins in millimetres.
  self.mPsd.rtMargin.left = margin.left * 100
  self.mPsd.rtMargin.top = margin.up * 100
  self.mPsd.rtMargin.right = margin.right * 100
  self.mPsd.rtMargin.bottom = margin.down * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MARGINS

proc setMargin*(self: wPageSetupDialog, margin: int) {.validate, property.} =
  ## Sets the margins to the same value in millimetres.
  self.mPsd.rtMargin.left = margin * 100
  self.mPsd.rtMargin.top = margin * 100
  self.mPsd.rtMargin.right = margin * 100
  self.mPsd.rtMargin.bottom = margin * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MARGINS

proc getMarginTopLeft*(self: wPageSetupDialog): wPoint {.validate, property.} =
  ## Returns the left (x) and top (y) margins in millimetres.
  result.x = self.mPsd.rtMargin.left div 100
  result.y = self.mPsd.rtMargin.top div 100

proc getMarginBottomRight*(self: wPageSetupDialog): wPoint {.validate, property.} =
  ## Returns the right (x) and bottom (y) margins in millimetres.
  result.x = self.mPsd.rtMargin.right div 100
  result.y = self.mPsd.rtMargin.bottom div 100

proc setMarginTopLeft*(self: wPageSetupDialog, point: wPoint) {.validate, property.} =
  ## Sets the left (x) and top (y) margins in millimetres.
  self.mPsd.rtMargin.left = point.x * 100
  self.mPsd.rtMargin.top = point.y * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MARGINS

proc setMarginBottomRight*(self: wPageSetupDialog, point: wPoint) {.validate, property.} =
  ## Sets the right (x) and bottom (y) margins in millimetres.
  self.mPsd.rtMargin.right = point.x * 100
  self.mPsd.rtMargin.bottom = point.y * 100
  self.mPsd.Flags = self.mPsd.Flags or PSD_MARGINS

proc wPageSetupHookProc(hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): UINT_PTR
    {.stdcall.} =

  var self = cast[wPageSetupDialog](GetWindowLongPtr(hWnd, GWLP_USERDATA))

  if msg == WM_INITDIALOG:
    self = cast[wPageSetupDialog](cast[ptr TPAGESETUPDLG](lParam).lCustData)
    SetWindowLongPtr(hWnd, GWLP_USERDATA, cast[LPARAM](self))

  if self != nil:
    result = self.wDialogHookProc(hWnd, msg, wParam, lParam)

wClass(wPageSetupDialog of wDialog):

  proc init*(self: wPageSetupDialog, owner: wWindow, initDefault = false) {.validate.} =
    ## Initializer. If initDefault is true, the dialog is initialized for the
    ## system default printer.
    wValidate(owner)
    self.wDialog.init(owner)
    self.mPsd.lStructSize = sizeof(TPAGESETUPDLG)
    self.mPsd.lCustData = cast[LPARAM](self)
    self.mPsd.Flags = PSD_INHUNDREDTHSOFMILLIMETERS or PSD_ENABLEPAGESETUPHOOK
    self.mPsd.lpfnPageSetupHook = wPageSetupHookProc
    self.mPsd.hwndOwner = owner.mHwnd

    if initDefault:
      self.mPsd.Flags = self.mPsd.Flags or PSD_RETURNDEFAULT
      if PageSetupDlg(&self.mPsd) == 0:
        raise newException(wPageSetupDialogError, "wPageSetupDialog creation failed")

      self.mPsd.Flags = self.mPsd.Flags and (not PSD_RETURNDEFAULT)
      self.mPrintData = PrintData(self.mPsd.hDevMode, self.mPsd.hDevNames)

  proc init*(self: wPageSetupDialog, owner: wWindow, data: wPrintData) {.validate.} =
    ## Initializer. Uses specified printData as default setting. Nil to reset to
    ## the system default setting.
    self.init(owner)
    self.setPrintData(data)

proc showModal*(self: wPageSetupDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  if self.mPrintData != nil:
    self.mPsd.hDevMode = self.mPrintData.getDevMode()

  if PageSetupDlg(&self.mPsd) != 0:
    result = wIdOk
    self.mPrintData = PrintData(self.mPsd.hDevMode, self.mPsd.hDevNames)
  else:
    result = wIdCancel

proc display*(self: wPageSetupDialog): wPrintData {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning a wPrintData object or nil.
  if self.showModal() == wIdOk:
    result = self.getPrintData()
