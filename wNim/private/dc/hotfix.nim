#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

# This hotfix is just a walkaround for destructor bug in nim 0.20.0.
# Related issue: https://github.com/nim-lang/Nim/issues/11489

proc copy(dest: var wDC; src: wDC) =
  dest.mHdc = src.mHdc
  dest.mTextBackgroundColor = src.mTextBackgroundColor
  dest.mTextForegroundColor = src.mTextForegroundColor
  dest.mFont = src.mFont
  dest.mPen = src.mPen
  dest.mBrush = src.mBrush
  dest.mBackground = src.mBackground
  dest.mBitmap = src.mBitmap
  dest.mRegion = src.mRegion
  dest.mScale = src.mScale
  dest.mCanvas = src.mCanvas
  dest.mhOldFont = src.mhOldFont
  dest.mhOldPen = src.mhOldPen
  dest.mhOldBrush = src.mhOldBrush
  dest.mhOldBitmap = src.mhOldBitmap

proc `=sink`(dest: var wPaintDC; src: wPaintDC) =
  copy(dest, src)
  dest.mPs = src.mPs

proc `=sink`(dest: var wScreenDC; src: wScreenDC) =
  copy(dest, src)

proc `=sink`(dest: var wWindowDC; src: wWindowDC) =
  copy(dest, src)

proc `=sink`(dest: var wClientDC; src: wClientDC) =
  copy(dest, src)

proc `=sink`(dest: var wMemoryDC; src: wMemoryDC) =
  copy(dest, src)

proc `=sink`(dest: var wPrinterDC; src: wPrinterDC) =
  copy(dest, src)
