#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class represents the print and print setup common dialogs. You may
## obtain a wPrintData object from a successfully dismissed print dialog.
## And then you can use it to create wPrinterDC object. Only modal dialog is
## supported.
#
## :Superclass:
##   `wDialog <wDialog.html>`_
#
## :Seealso:
##   `wPrinterDC <wPrinterDC.html>`_
##   `wPrintData <wPrintData.html>`_
##   `wPageSetupDialog <wPageSetupDialog.html>`_
#
## :Events:
##   `wDialogEvent <wDialogEvent.html>`_
##   ==============================   =============================================================
##   wDialogEvent                     Description
##   ==============================   =============================================================
##   wEvent_DialogCreated             When the dialog is created but not yet shown.
##   wEvent_DialogClosed              When the dialog is being closed.
##   wEvent_DialogHelp                When the Help button is pressed.
##   wEvent_PrinterChanged            When the selected printer is changed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, ../wPrintData, wDialog
export wDialog, wPrintData

proc getPrintData*(self: wPrintDialog): wPrintData {.validate, property, inline.} =
  ## Returns the current wPrintData object for the dialog. The result may be nil.
  result = self.mPrintData

proc setPrintData*(self: wPrintDialog, printData: wPrintData) {.validate, property, inline.} =
  ## Sets a wPrintData object as default setting.
  self.mPrintData = printData

proc getMinMaxPage*(self: wPrintDialog): Slice[int] {.validate, property, inline.} =
  ## Returns the page number range.
  result.a = self.mPd.nMinPage
  result.b = self.mPd.nMaxPage

proc setMinMaxPage*(self: wPrintDialog, minmax: Slice[int]) {.validate, property, inline.} =
  ## Sets the minimum..maximum number range.
  self.mPd.nMinPage = minmax.a
  self.mPd.nMaxPage = minmax.b

proc getPrintToFile*(self: wPrintDialog): bool {.validate, property, inline.} =
  ## Returns true if the user has selected printing to a file.
  result = (self.mPd.Flags and PD_PRINTTOFILE) != 0

proc setPrintToFile*(self: wPrintDialog, flag: bool) {.validate, property, inline.} =
  ## Sets the "Print to file" checkbox to true or false.
  if flag:
    self.mPd.Flags = self.mPd.Flags or PD_PRINTTOFILE
  else:
    self.mPd.Flags = self.mPd.Flags and (not PD_PRINTTOFILE)

proc enablePrintToFile*(self: wPrintDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the "Print to file" checkbox.
  if flag:
    self.mPd.Flags = self.mPd.Flags and (not PD_DISABLEPRINTTOFILE)
  else:
    self.mPd.Flags = self.mPd.Flags or PD_DISABLEPRINTTOFILE

proc getSelection*(self: wPrintDialog): bool {.validate, property, inline.} =
  ## Returns true if the user requested that the selection be printed.
  result = (self.mPd.Flags and PD_SELECTION) != 0

proc setSelection*(self: wPrintDialog, flag: bool) {.validate, property, inline.} =
  ## Selects the "Selection" radio button.
  if flag:
    self.mPd.Flags = self.mPd.Flags or PD_SELECTION
  else:
    self.mPd.Flags = self.mPd.Flags and (not PD_SELECTION)

proc enableSelection*(self: wPrintDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the "Selection" radio button.
  if flag:
    self.mPd.Flags = self.mPd.Flags and (not PD_NOSELECTION)
  else:
    self.mPd.Flags = self.mPd.Flags or PD_NOSELECTION

proc getCurrentPage*(self: wPrintDialog): bool {.validate, property, inline.} =
  ## Returns true if the user requested that the current page be printed.
  result = (self.mPd.Flags and PD_CURRENTPAGE) != 0

proc setCurrentPage*(self: wPrintDialog, flag: bool) {.validate, property, inline.} =
  ## Selects the "Current Page" radio button.
  if flag:
    self.mPd.Flags = self.mPd.Flags or PD_CURRENTPAGE
  else:
    self.mPd.Flags = self.mPd.Flags and (not PD_CURRENTPAGE)

proc enableCurrentPage*(self: wPrintDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the "Current Page" radio button.
  if flag:
    self.mPd.Flags = self.mPd.Flags and (not PD_NOCURRENTPAGE)
  else:
    self.mPd.Flags = self.mPd.Flags or PD_NOCURRENTPAGE

proc getPageRanges*(self: wPrintDialog): seq[Slice[int]] {.validate, property.} =
  ## Returns page ranges specified by the user.
  result = @[]
  for i in 0..<self.mPd.nPageRanges.int:
    result.add(self.mRanges[i].nFromPage.int..self.mRanges[i].nToPage.int)

proc setPageRanges*(self: wPrintDialog, ranges: openarray[Slice[int]]) {.validate, property.} =
  ## Sets default page ranges.
  self.mPd.nPageRanges = min(ranges.len, self.mRanges.len)
  if ranges.len != 0:
    self.mPd.Flags = self.mPd.Flags or PD_PAGENUMS
    for i in 0..<self.mPd.nPageRanges:
      self.mRanges[i].nFromPage = ranges[i].a
      self.mRanges[i].nToPage = ranges[i].b
  else:
    self.mPd.Flags = self.mPd.Flags and (not PD_PAGENUMS)

proc enablePageRanges*(self: wPrintDialog, flag = true) {.validate, inline.} =
  ## Enables or disables the page ranges edit controls.
  if flag:
    self.mPd.Flags = self.mPd.Flags and (not PD_NOPAGENUMS)
  else:
    self.mPd.Flags = self.mPd.Flags or PD_NOPAGENUMS

proc getCopies*(self: wPrintDialog): int {.validate, property, inline.} =
  ## Returns the number of copies requested by the user.
  result = self.mPd.nCopies

proc setCopies*(self: wPrintDialog, copies: int) {.validate, property, inline.} =
  ## Sets the default number of copies the user has requested to be printed out.
  self.mPd.nCopies = copies

proc getCollate*(self: wPrintDialog): bool {.validate, property, inline.} =
  ## Returns true if the user requested that the document(s) be collated.
  result = (self.mPd.Flags and PD_COLLATE) != 0

proc setCollate*(self: wPrintDialog, flag: bool) {.validate, property, inline.} =
  ## Sets the "Collate" checkbox to true or false.
  if flag:
    self.mPd.Flags = self.mPd.Flags or PD_COLLATE
  else:
    self.mPd.Flags = self.mPd.Flags and (not PD_COLLATE)

wClass(wPrintDialog of wDialog):

  proc init*(self: wPrintDialog, owner: wWindow) {.validate.} =
    ## Initializer.
    wValidate(owner)
    self.wDialog.init(owner)
    self.mPd.lStructSize = sizeof(TPRINTDLGEX)
    self.mPd.nMaxPageRanges = self.mRanges.len
    self.mPd.lpPageRanges = &self.mRanges[0]
    self.mPd.nStartPage = START_PAGE_GENERAL
    self.mPd.hwndOwner = owner.mHwnd

    # IPrintDialogCallback + IObjectWithSite

    # 1.0.0 bug: output c source cannot be compiled. devel don't has this problem.
    # var withSiteVtbl {.global.} = IObjectWithSiteVtbl(

    var withSiteVtbl {.global.}: IObjectWithSiteVtbl
    if withSiteVtbl.QueryInterface.isNil:
      withSiteVtbl = IObjectWithSiteVtbl(
        QueryInterface: proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} = E_NOINTERFACE,
        AddRef: proc(self: ptr IUnknown): ULONG {.stdcall.} = 1,
        Release: proc(self: ptr IUnknown): ULONG {.stdcall.} = 1,
        GetSite: proc(self: ptr IObjectWithSite, riid: REFIID, ppvSite: ptr pointer): HRESULT {.stdcall.} = E_NOTIMPL,
        SetSite: proc(self: ptr IObjectWithSite, pUnkSite: ptr IUnknown): HRESULT {.stdcall.} =
          let callBack = cast[ptr wPrintDialogCallback](cast[int](self) - objectOffset(wPrintDialogCallback, withSite))
          callBack.services = cast[ptr IPrintDialogServices](pUnkSite)
        )

    self.mPd.lpCallback = cast[ptr IUnknown](&self.mCallBack)
    self.mCallBack.lpVtbl = &self.mCallBack.vtbl
    self.mCallBack.withSite.lpVtbl = &withSiteVtbl

    self.mCallBack.vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
      if ppvObject.isNil:
        return E_POINTER

      elif IsEqualIID(riid, &IID_IObjectWithSite):
        let callBack = cast[ptr wPrintDialogCallback](self)
        ppvObject[] = &callBack.withSite
        return S_OK

      elif IsEqualIID(riid, &IID_IPrintDialogCallback):
        ppvObject[] = self
        self.AddRef()
        return S_OK

      else:
        ppvObject[] = nil
        return E_NOINTERFACE

    self.mCallBack.vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} = 1

    self.mCallBack.vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} = 1

    self.mCallBack.vtbl.InitDone = proc (self: ptr IPrintDialogCallback): HRESULT {.stdcall.} = E_NOTIMPL

    self.mCallBack.vtbl.SelectionChange = proc (self: ptr IPrintDialogCallback): HRESULT {.stdcall.} =
      let dialog = cast[wBase.wPrintDialog](cast[int](self) - objectOffset(wBase.wPrintDialog, mCallBack))
      let services = dialog.mCallBack.services

      if services != nil:
        var pcchSize, pcbSize: UINT
        var device, devMode: string

        if services.GetCurrentPrinterName(nil, &pcchSize) == S_OK:
          var buffer = T(pcchSize)
          if services.GetCurrentPrinterName(&buffer, &pcchSize) == S_OK:
            device = $buffer

        if services.GetCurrentDevMode(nil, &pcbSize) == S_OK:
          var buffer = newString(pcbSize)
          if services.GetCurrentDevMode(cast[ptr DEVMODE](&buffer), &pcbSize) == S_OK:
            devMode = buffer

        if device.len != 0 and devMode.len != 0:
          dialog.mPrintData = PrintData(device, devMode)
          # only trigger the event if everything is right, so that dialog.getPrintData()
          # can be used to get the current selected printer.
          let event = Event(window=dialog, msg=wEvent_PrinterChanged)
          dialog.processEvent(event)

      # MSDN: Return S_FALSE to allow PrintDlgEx to perform its default actions
      return S_FALSE

    self.mCallBack.vtbl.HandleMessage = proc (self: ptr IPrintDialogCallback, hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM, pResult: ptr LRESULT): HRESULT {.stdcall.} =
      let dialog = cast[wBase.wPrintDialog](cast[int](self) - objectOffset(wBase.wPrintDialog, mCallBack))
      # wDialogHookProc return TRUE means processed
      # MSDN:
      #  pResult: The value pointed to should be TRUE if you process the message
      #  HRESULT: Return S_FALSE to perform its default message handling.
      pResult[] = LRESULT dialog.wDialogHookProc(hWnd, msg, wParam, lParam)
      result = (if pResult[] == 0: S_FALSE else: S_OK)

  proc init*(self: wPrintDialog, owner: wWindow, data: wPrintData) {.validate.} =
    ## Initializer. Uses specified printData as default setting. Nil to reset to
    ## the system default setting.
    self.init(owner)
    self.setPrintData(data)

proc showModal*(self: wPrintDialog): wId {.validate, discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed Print, wIdApply if
  ## the user pressed Apply, and wIdCancel otherwise.
  var defaultPrintData = self.mPrintData
  if defaultPrintData != nil:
    self.mPd.hDevMode = defaultPrintData.getDevMode()

  result = wIdCancel
  if PrintDlgEx(&self.mPd) == S_OK:
    if self.mPd.dwResultAction == PD_RESULT_APPLY:
      result = wIdApply

    elif self.mPd.dwResultAction == PD_RESULT_PRINT:
      result = wIdOk

  if result in {wIdOk, wIdApply}:
    self.mPrintData = PrintData(self.mPd.hDevMode, self.mPd.hDevNames)
  else:
    # the "SelectionChange" handler may modify self.mPrintData. So reset it to
    # user's default or nil.
    self.mPrintData = defaultPrintData

proc display*(self: wPrintDialog): wPrintData {.validate, inline, discardable.} =
  ## Shows the dialog in modal mode, returning a wPrintData object if the user
  ## pressed Print, and nil otherwise.
  if self.showModal() == wIdOk:
    result = self.getPrintData()
