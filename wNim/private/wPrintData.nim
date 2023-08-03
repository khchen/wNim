#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This class holds a variety of information related to printers. This class
## is also used to create the wPrinterDC object.
#
## :Seealso:
##   `wPrinterDC <wPrinterDC.html>`_
##   `wPrintDialog <wPrintDialog.html>`_
##   `wPageSetupDialog <wPageSetupDialog.html>`_

include pragma
import math
import wBase

converter converterDevmodePtrToVar(p: ptr DEVMODE): var DEVMODE = cast[var DEVMODE](p)

type
  wPrintDataError* = object of wError
    ## An error raised when wPrntData creation failed or error occurred.

  wOrientation* = enum
    wPortrait = DMORIENT_PORTRAIT
    wLandscape = DMORIENT_LANDSCAPE

  wDuplexMode* = enum
    wDuplexSimplex = DMDUP_SIMPLEX
    wDuplexVertical = DMDUP_VERTICAL
    wDuplexHorizontal = DMDUP_HORIZONTAL

  wPaper* = enum
    wPaperLetter = DMPAPER_LETTER
    wPaperLetterSmall = DMPAPER_LETTERSMALL
    wPaperTabloid = DMPAPER_TABLOID
    wPaperLedger = DMPAPER_LEDGER
    wPaperLegal = DMPAPER_LEGAL
    wPaperStatement = DMPAPER_STATEMENT
    wPaperExecutive = DMPAPER_EXECUTIVE
    wPaperA3 = DMPAPER_A3
    wPaperA4 = DMPAPER_A4
    wPaperA4Small = DMPAPER_A4SMALL
    wPaperA5 = DMPAPER_A5
    wPaperB4 = DMPAPER_B4
    wPaperB5 = DMPAPER_B5
    wPaperFolio = DMPAPER_FOLIO
    wPaperQuarto = DMPAPER_QUARTO
    wPaper10x14 = DMPAPER_10X14
    wPaper11x17 = DMPAPER_11X17
    wPaperNote = DMPAPER_NOTE
    wPaperEnv9 = DMPAPER_ENV_9
    wPaperEnv10 = DMPAPER_ENV_10
    wPaperEnv11 = DMPAPER_ENV_11
    wPaperEnv12 = DMPAPER_ENV_12
    wPaperEnv14 = DMPAPER_ENV_14
    wPaperCSheet = DMPAPER_CSHEET
    wPaperDSheet = DMPAPER_DSHEET
    wPaperESheet = DMPAPER_ESHEET
    wPaperEnvDl = DMPAPER_ENV_DL
    wPaperEnvC5 = DMPAPER_ENV_C5
    wPaperEnvC3 = DMPAPER_ENV_C3
    wPaperEnvC4 = DMPAPER_ENV_C4
    wPaperEnvC6 = DMPAPER_ENV_C6
    wPaperEnvC65 = DMPAPER_ENV_C65
    wPaperEnvB4 = DMPAPER_ENV_B4
    wPaperEnvB5 = DMPAPER_ENV_B5
    wPaperEnvB6 = DMPAPER_ENV_B6
    wPaperEnvItaly = DMPAPER_ENV_ITALY
    wPaperEnvMonarch = DMPAPER_ENV_MONARCH
    wPaperEnvPersonal = DMPAPER_ENV_PERSONAL
    wPaperFanfoldUs = DMPAPER_FANFOLD_US
    wPaperFanfoldStdGerman = DMPAPER_FANFOLD_STD_GERMAN
    wPaperFanfoldLglGerman = DMPAPER_FANFOLD_LGL_GERMAN
    wPaperIsoB4 = DMPAPER_ISO_B4
    wPaperJapanesePostcard = DMPAPER_JAPANESE_POSTCARD
    wPaper9x11 = DMPAPER_9X11
    wPaper10x11 = DMPAPER_10X11
    wPaper15x11 = DMPAPER_15X11
    wPaperEnvInvite = DMPAPER_ENV_INVITE
    wPaperReserved48 = DMPAPER_RESERVED_48
    wPaperReserved49 = DMPAPER_RESERVED_49
    wPaperLetterExtra = DMPAPER_LETTER_EXTRA
    wPaperLegalExtra = DMPAPER_LEGAL_EXTRA
    wPaperTabloidExtra = DMPAPER_TABLOID_EXTRA
    wPaperA4Extra = DMPAPER_A4_EXTRA
    wPaperLetterTransverse = DMPAPER_LETTER_TRANSVERSE
    wPaperA4Transverse = DMPAPER_A4_TRANSVERSE
    wPaperLetterExtraTransverse = DMPAPER_LETTER_EXTRA_TRANSVERSE
    wPaperAPlus = DMPAPER_A_PLUS
    wPaperBPlus = DMPAPER_B_PLUS
    wPaperLetterPlus = DMPAPER_LETTER_PLUS
    wPaperA4Plus = DMPAPER_A4_PLUS
    wPaperA5Transverse = DMPAPER_A5_TRANSVERSE
    wPaperB5Transverse = DMPAPER_B5_TRANSVERSE
    wPaperA3Extra = DMPAPER_A3_EXTRA
    wPaperA5Extra = DMPAPER_A5_EXTRA
    wPaperB5Extra = DMPAPER_B5_EXTRA
    wPaperA2 = DMPAPER_A2
    wPaperA3Transverse = DMPAPER_A3_TRANSVERSE
    wPaperA3ExtraTransverse = DMPAPER_A3_EXTRA_TRANSVERSE
    wPaperDblJapanesePostcard = DMPAPER_DBL_JAPANESE_POSTCARD
    wPaperA6 = DMPAPER_A6
    wPaperJenvKaku2 = DMPAPER_JENV_KAKU2
    wPaperJenvKaku3 = DMPAPER_JENV_KAKU3
    wPaperJenvChou3 = DMPAPER_JENV_CHOU3
    wPaperJenvChou4 = DMPAPER_JENV_CHOU4
    wPaperLetterRotated = DMPAPER_LETTER_ROTATED
    wPaperA3Rotated = DMPAPER_A3_ROTATED
    wPaperA4Rotated = DMPAPER_A4_ROTATED
    wPaperA5Rotated = DMPAPER_A5_ROTATED
    wPaperB4JisRotated = DMPAPER_B4_JIS_ROTATED
    wPaperB5JisRotated = DMPAPER_B5_JIS_ROTATED
    wPaperJapanesePostcardRotated = DMPAPER_JAPANESE_POSTCARD_ROTATED
    wPaperDblJapanesePostcardRotated = DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED
    wPaperA6Rotated = DMPAPER_A6_ROTATED
    wPaperJenvKaku2Rotated = DMPAPER_JENV_KAKU2_ROTATED
    wPaperJenvKaku3Rotated = DMPAPER_JENV_KAKU3_ROTATED
    wPaperJenvChou3Rotated = DMPAPER_JENV_CHOU3_ROTATED
    wPaperJenvChou4Rotated = DMPAPER_JENV_CHOU4_ROTATED
    wPaperB6Jis = DMPAPER_B6_JIS
    wPaperB6JisRotated = DMPAPER_B6_JIS_ROTATED
    wPaper12x11 = DMPAPER_12X11
    wPaperJenvYou4 = DMPAPER_JENV_YOU4
    wPaperJenvYou4Rotated = DMPAPER_JENV_YOU4_ROTATED
    wPaperP16k = DMPAPER_P16K
    wPaperP32k = DMPAPER_P32K
    wPaperP32kBig = DMPAPER_P32KBIG
    wPaperPenv1 = DMPAPER_PENV_1
    wPaperPenv2 = DMPAPER_PENV_2
    wPaperPenv3 = DMPAPER_PENV_3
    wPaperPenv4 = DMPAPER_PENV_4
    wPaperPenv5 = DMPAPER_PENV_5
    wPaperPenv6 = DMPAPER_PENV_6
    wPaperPenv7 = DMPAPER_PENV_7
    wPaperPenv8 = DMPAPER_PENV_8
    wPaperPenv9 = DMPAPER_PENV_9
    wPaperPenv10 = DMPAPER_PENV_10
    wPaperP16kRotated = DMPAPER_P16K_ROTATED
    wPaperP32kRotated = DMPAPER_P32K_ROTATED
    wPaperP32kBigRotated = DMPAPER_P32KBIG_ROTATED
    wPaperPenv1Rotated = DMPAPER_PENV_1_ROTATED
    wPaperPenv2Rotated = DMPAPER_PENV_2_ROTATED
    wPaperPenv3Rotated = DMPAPER_PENV_3_ROTATED
    wPaperPenv4Rotated = DMPAPER_PENV_4_ROTATED
    wPaperPenv5Rotated = DMPAPER_PENV_5_ROTATED
    wPaperPenv6Rotated = DMPAPER_PENV_6_ROTATED
    wPaperPenv7Rotated = DMPAPER_PENV_7_ROTATED
    wPaperPenv8Rotated = DMPAPER_PENV_8_ROTATED
    wPaperPenv9Rotated = DMPAPER_PENV_9_ROTATED
    wPaperPenv10Rotated = DMPAPER_PENV_10_ROTATED
    wPaperUser = DMPAPER_USER

wClass(wPrintData):

  proc init*(self: wPrintData, hDevMode: HGLOBAL, hDevNames: HGLOBAL) {.validate.} =
    ## Initializer by hDevMode and hDevNames, for internal use only.
    # MSDN: If the wDeviceOffset and dmDeviceName names are not the same, use
    # wDeviceOffset.
    if hDevNames != 0:
      let pDevNames = cast[ptr DEVNAMES](GlobalLock(hDevNames))
      if pDevNames != nil:
        let tstr = cast[ptr UncheckedArray[TCHAR]](pDevNames)
        self.mDevice = $(&tstr[int pDevNames.wDeviceOffset])
      GlobalUnlock(hDevNames)

    if hDevMode != 0:
      let pDevMode = cast[ptr DEVMODE](GlobalLock(hDevMode))
      if pDevMode != nil:
        let size = GlobalSize(hDevMode)
        self.mDevModeBuffer = newString(size)
        copyMem(&self.mDevModeBuffer, pDevMode, size)
        if self.mDevice.len == 0:
          self.mDevice = $(cast[ptr TChar](&pDevMode.dmDeviceName))
      GlobalUnlock(hDevMode)

  proc init*(self: wPrintData, device: string, devMode: string) {.validate.} =
    ## Initializer by devMode and device name, for internal use only.
    self.mDevice = device
    self.mDevModeBuffer = devMode

  proc init*(self: wPrintData) {.validate, inline.} =
    ## Initializes the data by default printer.
    var psd = TPAGESETUPDLG(lStructSize: sizeof(TPAGESETUPDLG),
      Flags: PSD_RETURNDEFAULT or PSD_INHUNDREDTHSOFMILLIMETERS)

    # If psd.hwndOwner is null, PageSetupDlg() will steal active window for a while.
    # It makes current top-level window flicker.
    if wBaseApp != nil:
      for hwnd in wAppTopLevelHwnd():
        psd.hwndOwner = hwnd
        break

    if PageSetupDlg(&psd) == 0:
      raise newException(wPrintDataError, "wPrintData creation failed")

    defer:
      GlobalFree(psd.hDevMode)
      GlobalFree(psd.hDevNames)

    self.init(psd.hDevMode, psd.hDevNames)

  proc init*(self: wPrintData, device: string) {.validate.} =
    ## Initializes the data by specific printer.
    var hPrinter: HANDLE
    if OpenPrinter(device, &hPrinter, nil) == 0:
      raise newException(wPrintDataError, "wPrintData creation failed")

    defer: ClosePrinter(hPrinter)

    var size = DocumentProperties(0, hPrinter, nil, nil, nil, 0)
    if size <= 0:
      raise newException(wPrintDataError, "wPrintData creation failed")

    size += 1024 # need extra memory for buggy printer driver
    self.mDevModeBuffer = newString(size)
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)

    if DocumentProperties(0, hPrinter, nil, pDevMode, nil, DM_OUT_BUFFER) < 0:
      raise newException(wPrintDataError, "wPrintData creation failed")

    self.mDevice = device

  proc init*(self: wPrintData, printData: wPrintData) {.validate.} =
    ## Initializer by wPrintData object, aka. copy.
    self.mDevice = printData.mDevice
    self.mDevModeBuffer = printData.mDevModeBuffer

proc getDevMode(self: wPrintData): HGLOBAL {.shield.} =
  # convert wPrintData to movable block of memory. Used internally.
  if self.mDevModeBuffer.len != 0:
    result = GlobalAlloc(GHND, SIZE_T self.mDevModeBuffer.len)
    if result != 0:
      let pDevMode = GlobalLock(result)
      if pDevMode != nil:
        copyMem(pDevMode, &self.mDevModeBuffer, self.mDevModeBuffer.len)
        discard GlobalUnlock(result)
      else:
        GlobalFree(result)
        result = 0

proc isOk*(self: wPrintData): bool {.validate, inline.} =
  ## Returns true if the print data is valid for using in print dialogs.
  result = (self.mDevice.len != 0 and self.mDevModeBuffer.len != 0)

proc getDevice*(self: wPrintData): string {.validate, property, inline.} =
  ## Returns the device name.
  result = self.mDevice

proc getPrinterName*(self: wPrintData): string {.validate, property, inline.} =
  ## Returns the printer name. The same as getDevice().
  result = self.getDevice()

proc getPaper*(self: wPrintData): wPaper {.validate, property, inline.} =
  ## Returns the paper kind.
  result = wPaperA4
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = cast[wPaper](pDevMode.dmPaperSize)

proc getPaperName*(self: wPrintData): string {.validate, property, inline.} =
  ## Returns the paper name, if any.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = $(cast[ptr TChar](&pDevMode.dmFormName))

proc getPaperSize*(self: wPrintData): wSize {.validate, property, inline.} =
  ## Returns the paper size, in millimetres.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)

    # some printer driver returned wrong value, we fix it here
    if pDevMode.dmPaperSize != 0:
      let n = DeviceCapabilities(self.mDevice, nil, DC_PAPERS, nil, nil)
      if n != 0:
        var papers = newSeq[int16](n)
        var paperSizes = newSeq[POINT](n)
        DeviceCapabilities(self.mDevice, nil, DC_PAPERS, cast[LPTSTR](&(papers[0])), nil)
        DeviceCapabilities(self.mDevice, nil, DC_PAPERSIZE, cast[LPTSTR](&(paperSizes[0])), nil)

        for i, id in papers:
          if id == pDevMode.dmPaperSize:
            pDevMode.dmPaperWidth = int16 paperSizes[i].x
            pDevMode.dmPaperLength = int16 paperSizes[i].y
            break

    result.width = int round(pDevMode.dmPaperWidth.float / 10)
    result.height = int round(pDevMode.dmPaperLength.float / 10)

proc getOrientation*(self: wPrintData): wOrientation {.validate, property, inline.} =
  ## Gets the orientation.
  result = wPortrait
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = wOrientation pDevMode.dmOrientation

proc getCopies*(self: wPrintData): int {.validate, property, inline.} =
  ## Returns the number of copies.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = int pDevMode.dmCopies

proc getCollate*(self: wPrintData): bool {.validate, property, inline.} =
  ## Returns true if collation is on.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = pDevMode.dmCollate != DMCOLLATE_FALSE

proc getColor*(self: wPrintData): bool {.validate, property, inline.} =
  ## Returns true if colour printing is on.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = pDevMode.dmColor == DMCOLOR_COLOR

proc getDuplex*(self: wPrintData): wDuplexMode {.validate, property, inline.} =
  ## Returns the duplex mode.
  result = wDuplexSimplex
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    result = wDuplexMode pDevMode.dmDuplex

proc setPaper*(self: wPrintData, paper: wPaper) {.validate, property, inline.} =
  ## Sets the paper kind.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    pDevMode.dmPaperSize = int16 paper
    pDevMode.dmFields = (pDevMode.dmFields or DM_PAPERSIZE) and
      (not (DM_PAPERLENGTH or DM_PAPERWIDTH))

proc setPaperSize*(self: wPrintData, size: wSize) {.validate, property, inline.} =
  ## Sets the custom paper size, in millimetres.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    pDevMode.dmPaperWidth = int16 size.width * 10
    pDevMode.dmPaperLength = int16 size.height * 10
    pDevMode.dmPaperSize = DMPAPER_USER
    pDevMode.dmFields = (pDevMode.dmFields or DM_PAPERLENGTH or DM_PAPERWIDTH or DM_PAPERSIZE)

proc setOrientation*(self: wPrintData, orientation: wOrientation)
    {.validate, property, inline.} =
  ## Sets the orientation. This can be wLandscape or wPortrait.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    pDevMode.dmOrientation = int16 orientation
    pDevMode.dmFields = pDevMode.dmFields or DM_ORIENTATION

proc setCopies*(self: wPrintData, copies: int) {.validate, property, inline.} =
  ## Sets the copies.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    pDevMode.dmCopies = int16 copies
    pDevMode.dmFields = pDevMode.dmFields or DM_COPIES

proc setColor*(self: wPrintData, flag: bool) {.validate, property, inline.} =
  ## Sets color printing on or off.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    pDevMode.dmColor = if flag: DMCOLOR_COLOR else: DMCOLOR_MONOCHROME
    pDevMode.dmFields = pDevMode.dmFields or DM_COLOR

proc setDuplex*(self: wPrintData, mode: wDuplexMode) {.validate, property, inline.} =
  ## Sets the duplex mode. This can be wDuplexSimplex, wDuplexVertical,
  ## or wDuplexHorizontal.
  if self.isOk():
    let pDevMode = cast[ptr DEVMODE](&self.mDevModeBuffer)
    pDevMode.dmDuplex = int16 mode
    pDevMode.dmFields = pDevMode.dmFields or DM_DUPLEX
