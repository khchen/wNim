
method getBestSize*(self: wStaticBitmap): wSize =
  if mBitmap != nil:
    result = mBitmap.getSize()

method getDefaultSize*(self: wStaticBitmap): wSize =
  if mBitmap != nil:
    result = mBitmap.getSize()

proc setBitmap*(self: wStaticBitmap, bitmap: wBitmap) =
  mBitmap = bitmap
  SendMessage(mHwnd, STM_SETIMAGE, IMAGE_BITMAP, if bitmap != nil: bitmap.mHandle else: 0)

proc getBitmap*(self: wStaticBitmap): wBitmap =
  result = mBitmap

proc wStaticBitmapInit*(self: wStaticBitmap, parent: wWindow, id: wCommandID = -1, bitmap: wBitmap = nil, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  mBitmap = bitmap
  wControlInit(className=WC_STATIC, parent=parent, id=id, label="", pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY or SS_BITMAP)
  mFocusable = false

  setBitmap(bitmap)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd:
      let cmdEvent = case HIWORD(event.mWparam.int32)
        of STN_CLICKED: wEvent_CommandLeftClick
        of STN_DBLCLK: wEvent_CommandLeftDoubleClick
        else: 0

      if cmdEvent != 0:
        var processed: bool
        event.mResult = self.mMessageHandler(self, cmdEvent, event.mWparam, event.mLparam, processed)

proc StaticBitmap*(parent: wWindow, id: wCommandID = -1, bitmap: wBitmap = nil, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wStaticBitmap =
  new(result)
  result.wStaticBitmapInit(parent=parent, id=id, bitmap=bitmap, pos=pos, size=size, style=style)

# nim style getter/setter

proc `bitmap=`*(self: wStaticBitmap, bitmap: wBitmap) = setBitmap(bitmap)
proc bitmap*(self: wStaticBitmap): wBitmap = getBitmap()
