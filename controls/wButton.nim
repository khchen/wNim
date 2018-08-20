## A button is a control that contains a text string, and is one of the most common elements of a GUI.
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
##    wEvent_Button                   The button is clicked.
##    wEvent_ButtonEnter              The mouse is entering the button.
##    wEvent_ButtonLeave              The mouse is leaving the button.
##    ==============================  =============================================================

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
  result = getAverageASCIILetterSize(mFont.mHandle)
  result.width = MulDiv(result.width, 50, 4)
  result.height = MulDiv(result.height, 14, 8)

method getBestSize*(self: wButton): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  var size: SIZE
  if SendMessage(mHwnd, BCM_GETIDEALSIZE, 0, &size) != 0:
    result.width = size.cx
    result.height = size.cy

  else: # fail, no visual styles ?
    result = getTextFontSize(getLabel(), mFont.mHandle)
    result.height += 2
    result.width += 2

proc setBitmapPosition*(self: wButton, direction: int) {.validate, property.} =
  ## Set the position at which the bitmap is displayed.
  ## Direction can be one of wLeft, wRight, wTop, wBottom, or wCenter.
  mImgData.uAlign = case direction
    of wLeft: BUTTON_IMAGELIST_ALIGN_LEFT
    of wRight: BUTTON_IMAGELIST_ALIGN_RIGHT
    of wTop: BUTTON_IMAGELIST_ALIGN_TOP
    of wBottom: BUTTON_IMAGELIST_ALIGN_BOTTOM
    of wCenter, wMiddle: BUTTON_IMAGELIST_ALIGN_CENTER
    else: BUTTON_IMAGELIST_ALIGN_LEFT
  SendMessage(mHwnd, BCM_SETIMAGELIST, 0, &mImgData)

proc getBitmapPosition*(self: wButton): int {.validate, property.} =
  ## Get the position at which the bitmap is displayed.
  ## Returned direction can be one of wLeft, wRight, wTop, wBottom, or wCenter.
  result = case mImgData.uAlign
    of BUTTON_IMAGELIST_ALIGN_LEFT: wLeft
    of BUTTON_IMAGELIST_ALIGN_RIGHT: wRight
    of BUTTON_IMAGELIST_ALIGN_TOP: wTop
    of BUTTON_IMAGELIST_ALIGN_BOTTOM: wBottom
    of BUTTON_IMAGELIST_ALIGN_CENTER: wCenter
    else: wLeft

proc setBitmapMargins*(self: wButton, x: int, y: int) {.validate, property.} =
  ## Set the margins between the bitmap and the text of the button.
  mImgData.margin.left = x
  mImgData.margin.right = x
  mImgData.margin.top = y
  mImgData.margin.bottom = y
  SendMessage(mHwnd, BCM_SETIMAGELIST, 0, &mImgData)

proc setBitmapMargins*(self: wButton, size: wSize) {.validate, property, inline.} =
  ## Set the margins between the bitmap and the text of the button.
  setBitmapMargins(size.width, size.height)

proc getBitmapMargins*(self: wButton): wSize {.validate, property.} =
  ## Get the margins between the bitmap and the text of the button.
  result.width = mImgData.margin.left
  result.height = mImgData.margin.top

proc setBitmap4Margins*(self: wButton, left: int, top: int, right: int, bottom: int) {.validate, property.} =
  ## Set the margins between the bitmap and the text of the button.
  mImgData.margin.left = left
  mImgData.margin.top = top
  mImgData.margin.right = right
  mImgData.margin.bottom = bottom
  SendMessage(mHwnd, BCM_SETIMAGELIST, 0, &mImgData)

proc setBitmap4Margins*(self: wButton, margins: tuple[left: int, top: int, right: int, bottom: int]) {.validate, property, inline.} =
  ## Set the margins between the bitmap and the text of the button.
  setBitmap4Margins(margins.left, margins.top, margins.right, margins.bottom)

proc getBitmap4Margins*(self: wButton): tuple[left: int, top: int, right: int, bottom: int] {.validate, property.} =
  ## Get the margins between the bitmap and the text of the button.
  result.left = mImgData.margin.left
  result.top = mImgData.margin.top
  result.right = mImgData.margin.right
  result.bottom = mImgData.margin.bottom

proc setBitmap*(self: wButton, bitmap: wBitmap, direction = -1) {.validate, property.} =
  ## Sets the bitmap to display in the button.
  wValidate(bitmap)
  let direction = (if direction == -1: mImgData.uAlign else: wLeft)

  if mImgData.himl != 0:
    ImageList_Destroy(mImgData.himl)

  mImgData.himl = ImageList_Create(bitmap.mWidth, bitmap.mHeight, ILC_COLOR32, 1, 1)
  if mImgData.himl != 0:
    ImageList_Add(mImgData.himl, bitmap.mHandle, 0)
    setBitmapPosition(direction)

proc getBitmap*(self: wButton): wBitmap {.validate, property.} =
  ## Return the bitmap shown by the button. Notice: it create a copy of the bitmap.
  if mImgData.himl != 0:
    var
      width, height: int32
      info: IMAGEINFO
      bm: BITMAP

    ImageList_GetIconSize(mImgData.himl, &width, &height)
    ImageList_GetImageInfo(mImgData.himl, 0, &info)
    # need to create new bitmap, don't just warp info.hbmImage

    GetObject(info.hbmImage, sizeof(BITMAP), &bm)

    result = Bmp(width, height, int bm.bmBitsPixel)
    let hdc = CreateCompatibleDC(0)
    let prev = SelectObject(hdc, result.mHandle)
    ImageList_Draw(mImgData.himl, 0, hdc, 0, 0, 0)
    SelectObject(hdc, prev)
    DeleteDC(hdc)

proc setDefault*(self: wButton, flag = true) {.validate, property.} =
  ## This sets the button to be the default item.
  mDefault = flag
  addWindowStyle(BS_DEFPUSHBUTTON)

  if flag:
    for win in self.siblings:
      if win of wButton:
        wButton(win).mDefault = false

proc setDropdownMenu*(self: wButton, menu: wMenu = nil) {.validate, property.} =
  if menu != nil:
    addWindowStyle(BS_SPLITBUTTON)
    mMenu = menu
  else:
    clearWindowStyle(BS_SPLITBUTTON)
    mMenu = nil

proc click*(self: wButton) {.validate, inline.} =
  ## Simulates the user clicking a button.
  SendMessage(mHwnd, BM_CLICK, 0, 0)

method release(self: wButton) =
  if mImgData.himl != 0:
    ImageList_Destroy(mImgData.himl)
    mImgData.himl = 0

method processNotify(self: wButton, code: INT, id: UINT_PTR, lParam: LPARAM, ret: var LRESULT): bool =
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

proc init(self: wButton, parent: wWindow, id: wCommandID = -1, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
  let style = style and (not 0xF)

  self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos,
    size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_PUSHBUTTON)

  # default value of bitmap direction
  mImgData.uAlign = BUTTON_IMAGELIST_ALIGN_LEFT

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd and HIWORD(int32 event.mWparam) == BN_CLICKED:
      self.processMessage(wEvent_Button, event.mWparam, event.mLparam)

proc Button*(parent: wWindow, id: wCommandID = wDefaultID, label: string = "", pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = 0): wButton {.discardable.} =
  ## Constructor, creating and showing a button.
  wValidate(parent)
  new(result)
  result.init(parent=parent, id=id, label=label, pos=pos, size=size, style=style)
