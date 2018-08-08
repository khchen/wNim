method getDefaultSize*(self: wButton): wSize =
  # button's default size is 50x14 DLUs
  # don't use GetDialogBaseUnits, it count by DEFAULT_GUI_FONT only
  # don't use tmAveCharWidth, it only only approximates

  result = getAverageASCIILetterSize(mFont.mHandle)
  result.width = MulDiv(result.width.int32, 50, 4).int
  result.height = MulDiv(result.height.int32, 14, 8).int

method getBestSize*(self: wButton): wSize =
  var size: SIZE
  if SendMessage(mHwnd, BCM_GETIDEALSIZE, 0, addr size) != 0:
    result.width = size.cx.int
    result.height = size.cy.int

  else: # fail, no visual styles ?
    result = getTextFontSize(getLabel(), mFont.mHandle)
    result.height += 2
    result.width += 2

proc setBitmapPosition*(self: wButton, direction: int) =
  mImgData.uAlign = case direction
    of wLeft: BUTTON_IMAGELIST_ALIGN_LEFT
    of wRight: BUTTON_IMAGELIST_ALIGN_RIGHT
    of wTop: BUTTON_IMAGELIST_ALIGN_TOP
    of wBottom: BUTTON_IMAGELIST_ALIGN_BOTTOM
    of wCenter, wMiddle: BUTTON_IMAGELIST_ALIGN_CENTER
    else: direction
  SendMessage(mHwnd, BCM_SETIMAGELIST, 0, addr mImgData)

proc setBitmapMargins*(self: wButton, x, y: int) =
  mImgData.margin.left = x.int32
  mImgData.margin.right = x.int32
  mImgData.margin.top = y.int32
  mImgData.margin.bottom = y.int32
  SendMessage(mHwnd, BCM_SETIMAGELIST, 0, addr mImgData)

proc setBitmapMargins*(self: wButton, size: wSize) =
  setBitmapMargins(size.width, size.height)

proc setBitmap*(self: wButton, bitmap: wBitmap, direction = -1) =
  assert bitmap != nil
  let direction = (if direction == -1: mImgData.uAlign.int else: wLeft)

  if mImgData.himl != 0:
    ImageList_Destroy(mImgData.himl)

  mImgData.himl = ImageList_Create(bitmap.mWidth.int32, bitmap.mHeight.int32, ILC_COLOR32, 1, 1)
  if mImgData.himl != 0:
    ImageList_Add(mImgData.himl, bitmap.mHandle, 0)
    setBitmapPosition(direction)

proc getBitmapPosition*(self: wButton): int =
  result = case mImgData.uAlign
    of BUTTON_IMAGELIST_ALIGN_LEFT: wLeft
    of BUTTON_IMAGELIST_ALIGN_RIGHT: wRight
    of BUTTON_IMAGELIST_ALIGN_TOP: wTop
    of BUTTON_IMAGELIST_ALIGN_BOTTOM: wBottom
    of BUTTON_IMAGELIST_ALIGN_CENTER: wCenter
    else: mImgData.uAlign.int

proc getBitmapMargins*(self: wButton): wSize =
  result.width = mImgData.margin.left.int
  result.height = mImgData.margin.top.int

proc getBitmap*(self: wButton): wBitmap =
  if mImgData.himl != 0:
    var
      width, height: int32
      info: IMAGEINFO
      bm: BITMAP

    ImageList_GetIconSize(mImgData.himl, addr width, addr height)
    ImageList_GetImageInfo(mImgData.himl, 0, addr info)
    # need to create new bitmap, don't just warp info.hbmImage

    GetObject(info.hbmImage, sizeof(BITMAP).int32, addr bm)

    result = Bmp(width.int, height.int, bm.bmBitsPixel.int)
    let hdc = CreateCompatibleDC(0)
    let prev = SelectObject(hdc, result.mHandle)
    ImageList_Draw(mImgData.himl, 0, hdc, 0, 0, 0)
    SelectObject(hdc, prev)
    DeleteDC(hdc)

proc setDefault*(self: wButton, flag = true) =
  mDefault = flag

  if flag:
    for win in self.siblings:
      if win of wButton:
        cast[wButton](win).mDefault = false

method delete*(self: wButton) =
  procCall wWindow(self).delete()
  if mImgData.himl != 0:
    ImageList_Destroy(mImgData.himl)
    mImgData.himl = 0

proc wButtonFinal(self: wButton) =
  delete()

proc wButtonInit(self: wButton, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
  let style = style and (not 0xF)

  self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_PUSHBUTTON)

  # default value of bitmap direction
  mImgData.uAlign = BUTTON_IMAGELIST_ALIGN_LEFT

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd and HIWORD(event.mWparam.int32) == BN_CLICKED:
      var processed: bool
      event.mResult = self.mMessageHandler(self, wEvent_Button, event.mWparam, event.mLparam, processed)

proc Button*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wButton =
  new(result, wButtonFinal)
  result.wButtonInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)

# nim style getter/setter

proc `bitmapPosition=`*(self: wButton, direction: int) = setBitmapPosition(direction)
proc `bitmapMargins=`*(self: wButton, size: wSize) = setBitmapMargins(size)
proc `bitmap=`*(self: wButton, bitmap: wBitmap) = setBitmap(bitmap)
proc bitmapPosition*(self: wButton): int = getBitmapPosition()
proc bitmapMargins*(self: wButton): wSize = getBitmapMargins()
proc bitmap*(self: wButton): wBitmap = getBitmap()
proc bestSize*(self:wButton): wSize = getBestSize()
