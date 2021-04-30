#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A printer device context allows access to any printer.
##
## Like other DC object, wPrinterDC need nim's destructors to release the resource.
#
## :Superclass:
##   `wDC <wDC.html>`_
#
## :Seealso:
##   `wPrintData <wPrintData.html>`_

include ../pragma
import ../wBase, ../wPrintData, wDC
export wDC

proc getPaperRect*(self: wPrinterDC): wRect {.property.} =
  ## Return the rectangle in device coordinates that corresponds to the full
  ## paper area, including the nonprinting regions of the paper. The point (0,0)
  ## in device coordinates is the top left corner of the page rectangle, which
  ## is the printable area. The coordinates of the top left corner of the paper
  ## rectangle will therefore have small negative values, while the bottom right
  ## coordinates will be somewhat larger than the values returned by wDC.GetSize().
  if self.mHdc != 0:
    result.x = -GetDeviceCaps(self.mHdc, PHYSICALOFFSETX)
    result.y = -GetDeviceCaps(self.mHdc, PHYSICALOFFSETY)
    result.width = GetDeviceCaps(self.mHdc, PHYSICALWIDTH)
    result.height = GetDeviceCaps(self.mHdc, PHYSICALHEIGHT)

proc startDoc*(self: wPrinterDC, message: string): bool {.discardable.} =
  ## Starts a document. Returns false if failed.
  var docinfo = DOCINFO(cbSize: sizeof(DOCINFO))
  docInfo.lpszDocName = message

  if self.mHdc != 0 and StartDoc(self.mHdc, &docInfo) > 0:
    result = true

proc endDoc*(self: wPrinterDC) =
  ## Ends a document.
  EndDoc(self.mHdc)

proc abortDoc*(self: wPrinterDC) =
  ## Stops the current print job.
  AbortDoc(self.mHdc)

proc startPage*(self: wPrinterDC) =
  ## Starts a document page.
  StartPage(self.mHdc)

proc endPage*(self: wPrinterDC) =
  ## Ends a document page.
  EndPage(self.mHdc)

proc PrinterDC*(printData: wPrintData): wPrinterDC =
  ## Create a wPrinterDC from given wPrintData object.
  wValidate(printData)

  if not printData.isOk():
    raise newException(wError, "wPrinterDC creation failed")

  let pDevMode = cast[ptr DEVMODE](&printData.mDevModeBuffer)
  result.mHdc = CreateDC(nil, printData.mDevice, nil, pDevMode)
  if result.mHdc == 0:
    raise newException(wError, "wPrinterDC creation failed")

  result.wDC.init()

proc delete*(self: var wPrinterDC) =
  ## Nim's destructors will delete this object by default.
  ## However, sometimes you maybe want to do that by yourself.
  ## (Nim's destructors don't work in some version?)
  `=destroy`(self)
