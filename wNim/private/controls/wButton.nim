#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A button is a control that contains a text string, and is one of the most
## common elements of a GUI.
#
## :Appearance:
##   .. image:: images/wButton.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wBuLeft                         Left-justifies the label.
##   wBuTop                          Aligns the label to the top of the button.
##   wBuRight                        Right-justifies the bitmap label.
##   wBuBottom                       Aligns the label to the bottom of the button.
##   wBuNoBorder                     Creates a button without border.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_Button                    The button is clicked.
##   wEvent_ButtonEnter               The mouse is entering the button.
##   wEvent_ButtonLeave               The mouse is leaving the button.
##   ===============================  =============================================================

include ../pragma
from ../winimx import nil # For BITMAP
import ../wBase, ../gdiobjects/[wBitmap, wIcon], wControl
export wControl

const
  # Button styles
  wBuLeft* = BS_LEFT
  wBuTop* = BS_TOP
  wBuRight* = BS_RIGHT
  wBuBottom* = BS_BOTTOM
  wBuNoBorder* = BS_FLAT

method getDefaultSize*(self: wButton): wSize {.property.} =
  ## Returns the default size for the control.
  # button's default size is 50x14 DLUs
  # don't use GetDialogBaseUnits, it count by DEFAULT_GUI_FONT only
  # don't use tmAveCharWidth, it only approximates
  result = getAverageASCIILetterSize(self.mFont.mHandle, self.mHwnd)
  result.width = MulDiv(result.width, 50, 4)
  result.height = MulDiv(result.height, 14, 8)

method getBestSize*(self: wButton): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  var size: SIZE
  if SendMessage(self.mHwnd, BCM_GETIDEALSIZE, 0, &size) != 0:
    result.width = size.cx
    result.height = size.cy

  else: # fail, no visual styles ?
    result = getTextFontSize(self.getLabel(), self.mFont.mHandle, self.mHwnd)
    result.height += 2
    result.width += 2

proc setBitmapPosition*(self: wButton, direction: int) {.validate, property.} =
  ## Set the position at which the bitmap is displayed.
  ## Direction can be one of wLeft, wRight, wTop, wBottom, or wCenter.
  self.mImgData.uAlign = case direction
    of wLeft: BUTTON_IMAGELIST_ALIGN_LEFT
    of wRight: BUTTON_IMAGELIST_ALIGN_RIGHT
    of wTop: BUTTON_IMAGELIST_ALIGN_TOP
    of wBottom: BUTTON_IMAGELIST_ALIGN_BOTTOM
    of wCenter, wMiddle: BUTTON_IMAGELIST_ALIGN_CENTER
    else: BUTTON_IMAGELIST_ALIGN_LEFT
  SendMessage(self.mHwnd, BCM_SETIMAGELIST, 0, &self.mImgData)

proc getBitmapPosition*(self: wButton): int {.validate, property.} =
  ## Get the position at which the bitmap is displayed.
  ## Returned direction can be one of wLeft, wRight, wTop, wBottom, or wCenter.
  result = case self.mImgData.uAlign
    of BUTTON_IMAGELIST_ALIGN_LEFT: wLeft
    of BUTTON_IMAGELIST_ALIGN_RIGHT: wRight
    of BUTTON_IMAGELIST_ALIGN_TOP: wTop
    of BUTTON_IMAGELIST_ALIGN_BOTTOM: wBottom
    of BUTTON_IMAGELIST_ALIGN_CENTER: wCenter
    else: wLeft

proc setBitmapMargins*(self: wButton, x: int, y: int) {.validate, property.} =
  ## Set the margins between the bitmap and the text of the button.
  self.mImgData.margin.left = x
  self.mImgData.margin.right = x
  self.mImgData.margin.top = y
  self.mImgData.margin.bottom = y
  SendMessage(self.mHwnd, BCM_SETIMAGELIST, 0, &self.mImgData)

proc setBitmapMargins*(self: wButton, size: wSize) {.validate, property, inline.} =
  ## Set the margins between the bitmap and the text of the button.
  self.setBitmapMargins(size.width, size.height)

proc getBitmapMargins*(self: wButton): wSize {.validate, property.} =
  ## Get the margins between the bitmap and the text of the button.
  result.width = self.mImgData.margin.left
  result.height = self.mImgData.margin.top

proc setBitmap4Margins*(self: wButton, left: int, top: int, right: int,
    bottom: int) {.validate, property.} =
  ## Set the margins between the bitmap and the text of the button.
  self.mImgData.margin.left = left
  self.mImgData.margin.top = top
  self.mImgData.margin.right = right
  self.mImgData.margin.bottom = bottom
  SendMessage(self.mHwnd, BCM_SETIMAGELIST, 0, &self.mImgData)

proc setBitmap4Margins*(self: wButton, margins: tuple[left: int, top: int,
    right: int, bottom: int]) {.validate, property, inline.} =
  ## Set the margins between the bitmap and the text of the button.
  self.setBitmap4Margins(margins.left, margins.top, margins.right, margins.bottom)

proc getBitmap4Margins*(self: wButton): tuple[left: int, top: int, right: int,
    bottom: int] {.validate, property.} =
  ## Get the margins between the bitmap and the text of the button.
  result.left = self.mImgData.margin.left
  result.top = self.mImgData.margin.top
  result.right = self.mImgData.margin.right
  result.bottom = self.mImgData.margin.bottom

proc setBitmap*(self: wButton, bitmap: wBitmap, direction = -1)
    {.validate, property.} =
  ## Sets the bitmap to display in the button.
  wValidate(bitmap)
  let direction = (if direction == -1: self.mImgData.uAlign else: wLeft)

  if self.mImgData.himl != 0:
    ImageList_Destroy(self.mImgData.himl)

  self.mImgData.himl = ImageList_Create(bitmap.mWidth, bitmap.mHeight,
      ILC_COLOR32, 1, 1)

  if self.mImgData.himl != 0:
    ImageList_Add(self.mImgData.himl, bitmap.mHandle, 0)
    self.setBitmapPosition(direction)

proc getBitmap*(self: wButton): wBitmap {.validate, property.} =
  ## Return the bitmap shown by the button. Notice: it create a copy of the bitmap.
  if self.mImgData.himl != 0:
    var
      width, height: int32
      info: IMAGEINFO
      bm: winimx.BITMAP

    ImageList_GetIconSize(self.mImgData.himl, &width, &height)
    ImageList_GetImageInfo(self.mImgData.himl, 0, &info)
    # need to create new bitmap, don't just warp info.hbmImage

    GetObject(info.hbmImage, sizeof(winimx.BITMAP), &bm)

    result = Bitmap(width, height, int bm.bmBitsPixel)
    let hdc = CreateCompatibleDC(0)
    let prev = SelectObject(hdc, result.mHandle)
    ImageList_Draw(self.mImgData.himl, 0, hdc, 0, 0, 0)
    SelectObject(hdc, prev)
    DeleteDC(hdc)

proc setIcon*(self: wButton, icon: wIcon, direction = -1)
    {.validate, property.} =
  ## Sets the icon to display in the button.
  wValidate(icon)
  let direction = (if direction == -1: self.mImgData.uAlign else: wLeft)

  if self.mImgData.himl != 0:
    ImageList_Destroy(self.mImgData.himl)

  self.mImgData.himl = ImageList_Create(icon.mWidth, icon.mHeight,
      ILC_COLOR32, 1, 1)

  if self.mImgData.himl != 0:
    ImageList_ReplaceIcon(self.mImgData.himl, -1, icon.mHandle)
    self.setBitmapPosition(direction)

proc getIcon*(self: wButton): wIcon {.validate, property.} =
  ## Return the icon shown by the button. Notice: it create a copy of the icon.
  if self.mImgData.himl != 0:
    var hIcon = ImageList_GetIcon(self.mImgData.himl, 0, ILD_TRANSPARENT)
    result = Icon(hIcon, copy=false)

proc setDefault*(self: wButton, flag = true) {.validate, property.} =
  ## This sets the button to be the default item.
  self.mDefault = flag
  self.addWindowStyle(BS_DEFPUSHBUTTON)

  if flag:
    for win in self.siblings:
      if win of wBase.wButton:
        wBase.wButton(win).mDefault = false

proc setDropdownMenu*(self: wButton, menu: wMenu = nil) {.validate, property.} =
  ## Sets a dropdown menu for a button, or nil to cancel it.
  if menu != nil:
    # when not defined(useWinXP):
    if wAppWinVersion() >= 6.0:
      self.addWindowStyle(BS_SPLITBUTTON)
    self.mMenu = menu
  else:
    # when not defined(useWinXP):
    if wAppWinVersion() >= 6.0:
      self.clearWindowStyle(BS_SPLITBUTTON)
    self.mMenu = nil

proc showDropdownMenu*(self: wButton) {.validate.} =
  ## Show a dropdown menu for a button.
  if self.mMenu != nil:
    let rect = self.getWindowRect(sizeOnly=true)
    self.popupMenu(self.mMenu, 0, rect.height)

proc click*(self: wButton) {.validate, inline.} =
  ## Simulates the user clicking a button.
  SendMessage(self.mHwnd, BM_CLICK, 0, 0)

method processNotify(self: wButton, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code
  of BCN_DROPDOWN:
    if self.mMenu != nil:
      let pnmdropdown = cast[LPNMBCDROPDOWN](lParam)
      let rect = pnmdropdown.rcButton
      self.popupMenu(self.mMenu, rect.left, rect.bottom)
      return true

  of BCN_HOTITEMCHANGE:
    let pnmbchotitem = cast[LPNMBCHOTITEM](lParam)
    if (pnmbchotitem.dwFlags and HICF_ENTERING) != 0:
      return self.processMessage(wEvent_ButtonEnter, id, lparam, ret)

    elif (pnmbchotitem.dwFlags and HICF_LEAVING) != 0:
      return self.processMessage(wEvent_ButtonLeave, id, lparam, ret)

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

wClass(wButton of wControl):

  method release*(self: wButton) =
    ## Release all the resources during destroying. Used internally.
    if self.mImgData.himl != 0:
      ImageList_Destroy(self.mImgData.himl)
      self.mImgData.himl = 0

    self.mParent.systemDisconnect(self.mCommandConn)
    free(self[])

  proc init*(self: wButton, parent: wWindow, id = wDefaultID,
      label: string = "", pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = 0) {.validate.} =
    ## Initializes a button.
    wValidate(parent)
    # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
    let style = style and (not 0xF)

    self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label,
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or
      BS_PUSHBUTTON)

    # default value of bitmap direction
    self.mImgData.uAlign = BUTTON_IMAGELIST_ALIGN_LEFT

    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      if event.mLparam == self.mHwnd and HIWORD(int32 event.mWparam) == BN_CLICKED:
        self.processMessage(wEvent_Button, event.mWparam, event.mLparam)
