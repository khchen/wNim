#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wDC is a "device context" onto which graphics and text can be drawn.
## wDC is an abstract base class and cannot be created directly.
## Use **wPaintDC, wClientDC, wWindowDC, wScreenDC, or wMemoryDC**.
##
## Notice that device contexts which are associated with windows
## (i.e. wClientDC, wWindowDC and wPaintDC) use the window font and colors by
## default. But the other device context classes use system-default values
## so you always must set the appropriate fonts and colours before using them.
##
## In wNim, wDC and it's subclasses are defined as **object** instead
## **ref object**. So they need nim's destructors to release the resource.
#
## :Subclasses:
##   `wPaintDC <wPaintDC.html>`_
##   `wClientDC <wClientDC.html>`_
##   `wWindowDC <wWindowDC.html>`_
##   `wScreenDC <wScreenDC.html>`_
##   `wMemoryDC <wMemoryDC.html>`_
#
## :Seealso:
##   `wGdiObject <wGdiObject.html>`_
#
## :Consts:
##   Used in logical function and blit.
##   ==============================  =============================================================
##   Consts                          Description
##   ==============================  =============================================================
##   wClear                          0
##   wXor                            src XOR dst
##   wInvert                         NOT dst
##   wOrReverse                      src OR (NOT dst)
##   wAndReverse                     src AND (NOT dst)
##   wCopy                           src
##   wAnd                            src AND dst
##   wAndInvert                      (NOT src) AND dst
##   wNop                            dst
##   wNor                            (NOT src) AND (NOT dst)
##   wEquiv                          NOT src) XOR dst
##   wSrcInvert                      (NOT src)
##   wOrInvert                       (NOT src) OR dst
##   wNand                           (NOT src) OR (NOT dst)
##   wOr                             src OR dst
##   wSet                            1
##   ==============================  =============================================================
##
##   Polygon filling mode, used in drawPolygon and drawPolyPolygon.
##   ============================== =============================================================
##   Consts                         Description
##   ============================== =============================================================
##   wOddevenRule                   fills the area between odd-numbered and even-numbered polygon sides on each scan line
##   wWindingRule                   fills any region that has a nonzero winding value
##   ============================== =============================================================

include ../pragma
import strutils, math
import ../wBase, ../gdiobjects/[wPen, wBrush, wBitmap, wFont, wRegion]

const
  # for logicalFunction and blit, use logicalFunction value as default
  wClear* = R2_BLACK
  wXor* = R2_XORPEN
  wInvert* = R2_NOT
  wOrReverse* = R2_MERGEPENNOT
  wAndReverse* = R2_MASKPENNOT
  wCopy* = R2_COPYPEN
  wAnd* = R2_MASKPEN
  wAndInvert* = R2_MASKNOTPEN
  wNop* = R2_NOP
  wNor* = R2_NOTMERGEPEN
  wEquiv* = R2_NOTXORPEN
  wSrcInvert* = R2_NOTCOPYPEN
  wOrInvert* = R2_MERGENOTPEN
  wNand* = R2_NOTMASKPEN
  wOr* = R2_MERGEPEN
  wSet* = R2_WHITE

  # drawPolygon, drawPolyPolygon
  wOddevenRule* = ALTERNATE
  wWindingRule* = WINDING

proc dwRop(rop: int): DWORD =
  result = case rop
    of wCopy: SRCCOPY
    of wXOR: SRCINVERT
    of wINVERT: DSTINVERT
    of wOR_REVERSE: 0x00DD0228
    of wAND_REVERSE: SRCERASE
    of wCLEAR: BLACKNESS
    of wSET: WHITENESS
    of wOR_INVERT: MERGEPAINT
    of wAND: SRCAND
    of wOR: SRCPAINT
    of wEQUIV: 0x00990066
    of wNAND: 0x007700E6
    of wAND_INVERT: 0x00220326
    of wNOP: 0x00AA0029
    of wSRC_INVERT: NOTSRCCOPY
    of wNOR: NOTSRCCOPY
    else: SRCCOPY

proc drawPoint*(self: wDC, x, y: int) =
  ## Draws a point using the color of the current pen.
  SetPixel(self.mHdc, x, y, self.mPen.mColor)

proc drawPoint*(self: wDC, point: wPoint) =
  ## Draws a point using the color of the current pen.
  self.drawPoint(point.x, point.y)

proc drawLine*(self: wDC, x1, y1, x2, y2: int) =
  ## Draws a line from the first point to the second.
  MoveToEx(self.mHdc, x1, y1, nil)
  LineTo(self.mHdc, x2, y2)

proc drawLine*(self: wDC, point1, point2: wPoint) =
  ## Draws a line from the first point to the second.
  self.drawLine(point1.x, point1.y, point2.x, point2.y)

proc drawRectangle*(self: wDC, x, y, width, height: int) =
  ## Draws a rectangle with the given corner coordinate and size.
  var
    x2 = x + width
    y2 = y + height

  if (self.mPen.mStyle and wPenStyleMask) == wPenStyleTransparent:
    x2.inc
    y2.inc

  Rectangle(self.mHdc, x, y, x2, y2)

proc drawRectangle*(self: wDC, point: wPoint, size: wSize) =
  ## Draws a rectangle with the given corner coordinate and size.
  self.drawRectangle(point.x, point.y, size.width, size.height)

proc drawRectangle*(self: wDC, rect: wRect) =
  ## Draws a rectangle with the given corner coordinate and size.
  self.drawRectangle(rect.x, rect.y, rect.width, rect.height)

proc drawEllipse*(self: wDC, x, y, width, height: int) =
  ## Draws an ellipse contained in the rectangle.
  Ellipse(self.mHdc, x, y, x + width, y + height)

proc drawEllipse*(self: wDC, point: wPoint, size: wSize) =
  ## Draws an ellipse contained in the rectangle.
  self.drawEllipse(point.x, point.y, size.width, size.height)

proc drawEllipse*(self: wDC, rect: wRect) =
  ## Draws an ellipse contained in the rectangle.
  self.drawEllipse(rect.x, rect.y, rect.width, rect.height)

proc drawCircle*(self: wDC, x, y, radius: int) =
  ## Draws a circle with the given center and radius.
  self.drawEllipse(x - radius, y - radius, radius * 2, radius * 2)

proc drawCircle*(self: wDC, point: wPoint, radius: int) =
  ## Draws a circle with the given center and radius.
  self.drawCircle(point.x, point.y, radius)

proc drawTextWithDeg(self: wDC, text: string, x = 0, y = 0, deg: float) =
  var
    size: SIZE
    x = x
    y = y
    oldColor = SetBkColor(self.mHdc, self.mTextBackgroundColor)

  for line in text.splitLines:
    var line = T(line)
    GetTextExtentPoint32(self.mHdc, line, line.len, &size)
    TextOut(self.mHdc, x, y, line, line.len)
    x += int(sin(degToRad(deg)) * float size.cy)
    y += int(cos(degToRad(deg)) * float size.cy)
  SetBkColor(self.mHdc, oldColor)

proc drawText*(self: wDC, text: string, x = 0, y = 0) =
  ## Draws a text string at the specified point, using the current text font,
  ## and the current text foreground and background colors.
  ## The text can contain multiple lines separated by the new line ('\n')
  ## characters.
  self.drawTextWithDeg(text, x, y, 0.0)

proc drawText*(self: wDC, text: string, point: wPoint) =
  ## Draws a text string at the specified point, using the current text font,
  ## and the current text foreground and background colors.
  ## The text can contain multiple lines separated by the new line ('\n')
  ## characters.
  self.drawText(text, point.x, point.y)

proc drawRotatedText*(self: wDC, text: string, x = 0, y = 0, angle = 0.0) =
  ## Draws the text rotated by angle degrees (positive angles are counterclockwise;
  ## the full angle is 360 degrees). The text can contain multiple lines separated
  ## by the new line ('\n') characters.
  if angle == 0:
    self.drawText(text, x, y)
  else:
    var lf: LOGFONT
    GetObject(self.mFont.mHandle, sizeof(LOGFONT), addr lf)
    let angle10 = int32(angle * 10)
    lf.lfEscapement = angle10
    lf.lfOrientation = angle10
    let prev = SelectObject(self.mHdc, CreateFontIndirect(lf))
    self.drawTextWithDeg(text, x, y, angle)
    SelectObject(self.mHdc, prev)

proc drawRotatedText*(self: wDC, text: string, point: wPoint, angle: float = 0) =
  ## Draws the text rotated by angle degrees (positive angles are counterclockwise;
  ## the full angle is 360 degrees). The text can contain multiple lines separated
  ## by the new line ('\n') characters.
  self.drawRotatedText(text, point.x, point.y, angle)

proc drawLabel*(self: wDC, text: string, rect: wRect, align = wLeft or wTop) =
  ## Draw the text into the given rectangle and aligns it as specified by
  ## alignment parameter. *align* can be combine of wRight, wCenter, wLeft, wUp,
  ## wMiddle, wDown.
  var
    flag = DT_NOPREFIX or DT_SINGLELINE
    r = toRect(rect)
    oldColor = SetBkColor(self.mHdc, self.mTextBackgroundColor)

  if (align and wCenter) == wCenter:
    flag = flag or DT_CENTER
  elif (align and wRight) != 0:
    flag = flag or DT_RIGHT
  elif (align and wLeft) != 0:
    flag = flag or DT_LEFT

  if (align and wMiddle) == wMiddle:
    flag = flag or DT_VCENTER
  elif (align and wBottom) != 0:
    flag = flag or DT_BOTTOM
  elif (align and wTop) != 0:
    flag = flag or DT_TOP

  DrawText(self.mHdc, text, text.len, &r, flag)
  SetBkColor(self.mHdc, oldColor)

proc drawCheckMark*(self: wDC, x, y, width, height: int) =
  ## Draws a check mark inside the given rectangle.
  var rect: RECT
  rect.left = x
  rect.top  = y
  rect.right  = x + width
  rect.bottom = y + height
  DrawFrameControl(self.mHdc, rect, DFC_MENU, DFCS_MENUCHECK)

proc drawCheckMark*(self: wDC, point: wPoint, size: wSize) =
  ## Draws a check mark inside the given rectangle.
  self.drawCheckMark(point.x, point.y, size.width, size.height)

proc drawCheckMark*(self: wDC, rect: wRect) =
  ## Draws a check mark inside the given rectangle.
  self.drawCheckMark(rect.x, rect.y, rect.width, rect.height)

proc drawArc*(self: wDC, x1, y1, x2, y2, xc, yc: int) =
  ## Draws an arc from the given start to the given end point.
  let
    dx = float(xc - x1)
    dy = float(yc - y1)
    r = sqrt(dx*dx + dy*dy).int

  if x1 == x2 and y1 == y2:
    self.drawEllipse(xc - r, yc - r, r*2, r*2)

  else:
    let
      xx1 = xc - r
      yy1 = yc - r
      xx2 = xc + r
      yy2 = yc + r

    if (self.mBrush.mStyle and wBrushStyleMask) != wBrushStyleTransparent:
      Pie(self.mHdc, xx1, yy1, xx2 + 1, yy2 + 1, x1, y1, x2, y2)
    else:
      Arc(self.mHdc, xx1, yy1, xx2, yy2, x1, y1, x2, y2)

proc drawArc*(self: wDC, point1, point2, center: wPoint) =
  ## Draws an arc from the given start to the given end point.
  self.drawArc(point1.x, point1.y, point2.x, point2.y, center.x, center.y)

proc drawRoundedRectangle*(self: wDC, x, y, width, height: int, radius: float) =
  ## Draws a rectangle with the given top left corner, and with the given size.
  ## The corners are quarter-circles using the given radius.
  ## The current pen is used for the outline and the current brush for filling the shape.
  ## If radius is positive, the value is assumed to be the radius of the rounded corner.
  ## If radius is negative, the absolute value is assumed to be the proportion of the
  ## smallest dimension of the rectangle.
  var
    r = int radius
    x2 = x + width
    y2 = y + height

  if radius < 0:
    r = int(-radius * min(width, height).float)

  if (self.mPen.mStyle and wPenStyleMask) == wPenStyleTransparent:
    x2.inc
    y2.inc

  RoundRect(self.mHdc, x, y, x2, y2, r * 2, r * 2)

proc drawRoundedRectangle*(self: wDC, point: wPoint, size: wSize, radius: float) =
  ## Draws a rectangle with the given top left corner, and with the given size.
  ## The corners are quarter-circles using the given radius.
  self.drawRoundedRectangle(point.x, point.y, size.width, size.height, radius)

proc drawRoundedRectangle*(self: wDC, rect: wRect, radius: float) =
  ## Draws a rectangle with the given top left corner, and with the given size.
  ## The corners are quarter-circles using the given radius.
  self.drawRoundedRectangle(rect.x, rect.y, rect.width, rect.height, radius)

proc addPoints(pseq: var seq[POINT], points: openarray[wPoint], xoffset: int = 0,
    yoffset: int = 0) =

  for point in points:
    pseq.add POINT(x: point.x + xoffset, y: point.y + yoffset)

proc drawLines*(self: wDC, points: openarray[wPoint], xoffset: int = 0,
    yoffset: int = 0) =
  ## Draws lines using an array of points, adding the optional offset coordinate.
  var pseq = newSeqOfCap[POINT](points.len)
  pseq.addPoints(points, xoffset, yoffset)
  Polyline(self.mHdc, addr pseq[0], pseq.len)

proc drawLines*(self: wDC, xoffset: int, yoffset: int, points: varargs[wPoint]) =
  ## Draws lines using an array of points, adding the optional offset coordinate.
  ## Varargs version.
  self.drawLines(points, xoffset, yoffset)

proc drawPolygon*(self: wDC, points: openarray[wPoint], xoffset: int = 0,
    yoffset: int = 0, style = wOddevenRule) =
  ## Draws a filled polygon using an array of points, adding the optional offset
  ## coordinate.
  let prev = SetPolyFillMode(self.mHdc, style)
  defer: SetPolyFillMode(self.mHdc, prev)

  var pseq = newSeqOfCap[POINT](points.len)
  pseq.addPoints(points, xoffset, yoffset)
  Polygon(self.mHdc, addr pseq[0], pseq.len)

proc drawPolygon*(self: wDC, xoffset: int, yoffset: int, style: int,
    points: varargs[wPoint]) =
  ## Draws a filled polygon using an array of points, adding the optional offset
  ## coordinate. Varargs version.
  self.drawPolygon(points, xoffset, yoffset, style)

proc drawPolyPolygon*(self: wDC, counts: openarray[int], points: openarray[wPoint],
    xoffset: int = 0, yoffset: int = 0, style=wOddevenRule) =
  ## Draws two or more filled polygons using an array of points, adding the
  ## optional offset coordinates.
  let prev = SetPolyFillMode(self.mHdc, style)
  defer: SetPolyFillMode(self.mHdc, prev)

  var iseq = newSeqOfCap[INT](counts.len)
  var pseq = newSeqOfCap[POINT](points.len)
  for i in counts: iseq.add i
  pseq.addPoints(points, xoffset, yoffset)
  PolyPolygon(self.mHdc, addr pseq[0], addr iseq[0], counts.len)

proc drawPolyPolygon*(self: wDC, points: openarray[seq[wPoint]], xoffset: int = 0,
    yoffset: int = 0, style=wOddevenRule) =
  ## Draws two or more filled polygons using an array of points, adding the
  ## optional offset coordinates.
  let prev = SetPolyFillMode(self.mHdc, style)
  defer: SetPolyFillMode(self.mHdc, prev)

  var iseq = newSeqOfCap[INT](points.len)
  var pseq = newSeq[POINT]()
  for wpseq in points:
    iseq.add wpseq.len
    pseq.addPoints(wpseq, xoffset, yoffset)
  PolyPolygon(self.mHdc, addr pseq[0], addr iseq[0], iseq.len)

proc drawPolyPolygon*(self: wDC, xoffset: int, yoffset: int, style: int,
    points: varargs[seq[wPoint], `@`]) =
  ## Draws two or more filled polygons using an array of points, adding the
  ## optional offset coordinates. Varargs version.
  self.drawPolyPolygon(points, xoffset, yoffset, style)

proc drawSpline*(self: wDC, points: varargs[wPoint]) =
  ## Draws a spline between all given points using the current pen.
  ## There are at least 3 points in the openarray.
  ## Hint: points is varargs so it can be array, seq, or list of points.
  if points.len <= 2: return

  template P(a, b: int32): untyped = POINT(x: a, y: b)
  var
    pseq = newSeqOfCap[POINT](points.len * 3 + 1)
    x1, y1, x2, y2, cx1, cy1, cx4, cy4: int32

  (x1, y1) = points[0]
  pseq.add(P(x1, y1))
  pseq.add(pseq[pseq.high])

  (x2, y2) = points[1]
  (cx1, cy1) = ((x1 + x2) div 2, (y1 + y2) div 2)
  pseq.add(P(cx1, cy1))
  pseq.add(pseq[pseq.high])

  for i in 2..<points.len:
    (x1, y1) = (x2, y2)
    (x2, y2) = points[i]
    (cx4, cy4) = ((x1 + x2) div 2, (y1 + y2) div 2)

    pseq.add(P((x1 * 2 + cx1) div 3, (y1 * 2 + cy1) div 3))
    pseq.add(P((x1 * 2 + cx4) div 3, (y1 * 2 + cy4) div 3))
    pseq.add(P(cx4, cy4))

    (cx1, cy1) = (cx4, cy4)

  pseq.add(pseq[pseq.high])
  pseq.add(P(x2, y2))
  pseq.add(pseq[pseq.high])

  PolyBezier(self.mHdc, addr pseq[0], pseq.len)

proc drawRegion*(self: wDC, region: wRegion, border = 0, borderBrush: wBrush = nil) =
  ## Draws a region. A custom border size and brush can be specified to draws the border.
  PaintRgn(self.mHdc, region.mHandle)
  if border != 0 and borderBrush != nil:
    FrameRgn(self.mHdc, region.mHandle, borderBrush.mHandle, border, border)

proc gradientFillLinear*(self: wDC, rect: wRect, initialColor: wColor,
    destColor: wColor, direction = wRight) =
  ## Fill the area specified by rect with a linear gradient, starting from
  ## initialColor and eventually fading to destColor. The direction can be one
  ## of wUp, wDown, wLeft, wRight.
  let
    nr1 = int initialColor.GetRValue()
    ng1 = int initialColor.GetGValue()
    nb1 = int initialColor.GetBValue()
    nr2 = int destColor.GetRValue()
    ng2 = int destColor.GetGValue()
    nb2 = int destColor.GetBValue()

  var
    p = (if direction == wUp or direction == wDown: rect.height else: rect.width)
    w = p
    delta = w div 256
    nr, ng, nb: byte

  if delta < 1: delta = 1
  while p >= 0:
    p -= delta
    nr = byte(nr1-(nr1-nr2)*(w-p) div w)
    ng = byte(ng1-(ng1-ng2)*(w-p) div w)
    nb = byte(nb1-(nb1-nb2)*(w-p) div w)

    let
      newColor = RGB(nr, ng, nb)
      newPen = Pen(color=newColor)
      newBrush = Brush(color=newColor)

    SelectObject(self.mHdc, newPen.mHandle)
    SelectObject(self.mHdc, newBrush.mHandle)

    case direction
    of wLeft:
      self.drawRectangle(rect.x + p, rect.y, delta, rect.height)
    of wUp:
      self.drawRectangle(rect.x, rect.y + p, rect.width, delta)
    of wDown:
      self.drawRectangle(rect.x, rect.y + rect.height - p - delta + 1, rect.width, delta)
    else: # wRight:
      self.drawRectangle(rect.x + rect.width - p - delta + 1, rect.y, delta, rect.height)

    # delete the GDIObject at first, GC will collect the memory later.
    SelectObject(self.mHdc, self.mPen.mHandle)
    SelectObject(self.mHdc, self.mBrush.mHandle)
    newPen.delete
    newBrush.delete

proc gradientFillConcentric*(self: wDC, rect: wRect, initialColor: wColor,
    destColor: wColor, center: wPoint) =
  ## Fill the area specified by rect with a radial gradient, starting from
  ## initialColor at the center of the circle and fading to destColor on the
  ## circle outside.
  let
    nr1 = float destColor.GetRValue()
    ng1 = float destColor.GetGValue()
    nb1 = float destColor.GetBValue()
    nr2 = float initialColor.GetRValue()
    ng2 = float initialColor.GetGValue()
    nb2 = float initialColor.GetBValue()
    cx: float = rect.width / 2
    cy: float = rect.height / 2
    radius: float = if cx < cy: cx else: cy
    offx = center.x.float - cx
    offy = center.y.float - cy
  var gradient, dx, dy: float

  for x in 0..<rect.width:
    for y in 0..<rect.height:
      dx = x.float
      dy = y.float
      gradient = ((radius - sqrt((dx - cx - offx) * (dx - cx - offx) +
        (dy - cy - offy) * (dy - cy - offy))) * 100) / radius

      if gradient < 0: gradient = 0
      let
        nr = byte(nr1 + ((nr2 - nr1) * gradient / 100))
        ng = byte(ng1 + ((ng2 - ng1) * gradient / 100))
        nb = byte(nb1 + ((nb2 - nb1) * gradient / 100))
      SetPixel(self.mHdc, x + rect.x, y + rect.y, RGB(nr, ng, nb))

proc gradientFillConcentric*(self: wDC, rect: wRect, initialColor: wColor,
    destColor: wColor) =
  ## Fill the area specified by rect with a radial gradient, starting from
  ## initialColor at the center of the circle and fading to destColor on the
  ## circle outside. The circle is placed at the center of rect.
  self.gradientFillConcentric(rect, initialColor, destColor,
    (rect.width div 2, rect.height div 2))

proc getHandle*(self: wDC): HANDLE {.inline, property.} =
  ## Returns a value that can be used as a handle to the native drawing context.
  result = self.mHdc

proc getHdc*(self: wDC): HANDLE {.inline, property.} =
  ## Returns a value that can be used as a handle to the native drawing context.
  result = self.mHdc

proc getDepth*(self: wDC): int {.inline, property.} =
  ## Returns the depth (number of bits/pixel) of this DC.
  result = GetDeviceCaps(self.mHdc, BITSPIXEL)

proc getPixel*(self: wDC, x: int, y: int): wColor {.inline, property.} =
  ## Gets the color at the specified location.
  result = GetPixel(self.mHdc, x, y)

proc getPpi*(self: wDC): wSize {.inline, property.} =
  ## Returns the resolution of the device in pixels per inch.
  result = (int GetDeviceCaps(self.mHdc, LOGPIXELSX), int GetDeviceCaps(self.mHdc, LOGPIXELSY))

proc getLogicalFunction*(self: wDC): int {.inline, property.} =
  ## Gets the current logical function.
  result = GetROP2(self.mHdc)

proc getPen*(self: wDC): wPen {.inline, property.} =
  ## Gets the current pen.
  result = self.mPen

proc getBrush*(self: wDC): wBrush {.inline, property.} =
  ## Gets the current brush.
  result = self.mBrush

proc getFont*(self: wDC): wFont {.inline, property.} =
  ## Gets the current font.
  result = self.mFont

proc getRegion*(self: wDC): wRegion {.inline, property.} =
  ## Gets the current region.
  result = self.mRegion

proc getTextForeground*(self: wDC): wColor {.inline, property.} =
  ## Gets the current text foreground color.
  result = GetTextColor(self.mHdc)

proc getTextBackground*(self: wDC): wColor {.inline, property.} =
  ## Gets the current text background color.
  result = self.mTextBackgroundColor

proc getBackground*(self: wDC): wColor {.inline, property.} =
  ## Gets the color used for painting the background.
  result = GetBkColor(self.mHdc)

proc getBackgroundMode*(self: wDC): int {.inline, property.} =
  ## Returns the current background mode: wPenStyleSolid or wPenStyleTransparent.
  result = (if GetBkMode(self.mHdc) == OPAQUE: wPenStyleSolid else: wPenStyleTransparent)

proc getBackgroundTransparent*(self: wDC): bool {.inline, property.} =
  ## Returns ture if the current background mode is transparent.
  result = (if GetBkMode(self.mHdc) == OPAQUE: false else: true)

proc getOrigin*(self: wDC): wPoint {.property.} =
  ## Returns the current origin.
  var p: POINT
  GetViewportOrgEx(self.mHdc, p)
  result.x = p.x
  result.y = p.y

proc getScale*(self: wDC): tuple[x, y: float] {.inline, property.} =
  ## Gets the current scale factor.
  result = self.mScale

method getSize*(self: wDC): wSize {.base, property.} =
  ## Gets the size of the device context.
  result.width = GetDeviceCaps(self.mHdc, HORZRES)
  result.height = GetDeviceCaps(self.mHdc, VERTRES)

proc setLogicalFunction*(self: var wDC, mode: int) {.inline, property.} =
  ## Sets the current logical function for the device context.
  SetROP2(self.mHdc, mode)

proc setPen*(self: var wDC, pen: wPen) {.inline, property.} =
  ## Sets the current pen for the DC.
  wValidate(pen)
  self.mPen = pen
  let hPen = SelectObject(self.mHdc, pen.mHandle)
  if self.mhOldPen == 0: self.mhOldPen = hPen

proc setBrush*(self: var wDC, brush: wBrush) {.inline, property.} =
  ## Sets the current brush for the DC.
  wValidate(brush)
  self.mBrush = brush
  let hBrush = SelectObject(self.mHdc, brush.mHandle)
  if self.mhOldBrush == 0: self.mhOldBrush = hBrush

proc setFont*(self: var wDC, font: wFont) {.inline, property.} =
  ## Sets the current font for the DC.
  wValidate(font)
  self.mFont = font
  let hFont = SelectObject(self.mHdc, font.mHandle)
  if self.mhOldFont == 0: self.mhOldFont = hFont

proc setRegion*(self: var wDC, region: wRegion) {.inline, property.} =
  ## Sets the current region for the DC.
  wValidate(region)
  self.mRegion = region
  # if region.mHandle == 0: just clear the clipping region
  SelectClipRgn(self.mHdc, region.mHandle)

proc setTextBackground*(self: var wDC, color: wColor) {.inline, property.} =
  ## Sets the current text background color for the DC.
  self.mTextBackgroundColor = color

proc setTextForeground*(self: var wDC, color: wColor) {.inline, property.} =
  ## Sets the current text foreground color for the DC.
  SetTextColor(self.mHdc, color)

proc setBackground*(self: var wDC, color: wColor) {.inline, property.} =
  ## Sets the current background color for the DC.
  SetBkColor(self.mHdc, color)

proc setBackground*(self: var wDC, brush: wBrush) {.inline, property.} =
  ## Sets the current background color by a sold brush for the DC.
  wValidate(brush)
  self.setBackground(brush.mColor)

proc setBackgroundMode*(self: var wDC, mode: int) {.inline, property.} =
  ## *mode* may be one of wPenStyleSolid and wPenStyleTransparent. This setting
  ## determines whether text will be drawn with a background color or not.
  SetBkMode(self.mHdc, (if mode == wPenStyleTransparent: TRANSPARENT else: OPAQUE))

proc setBackgroundTransparent*(self: var wDC, flag: bool) {.inline, property.} =
  ## This setting determines whether text will be drawn with a background color
  ## or not.
  SetBkMode(self.mHdc, (if flag: TRANSPARENT else: OPAQUE))

proc setOrigin*(self: var wDC, x: int, y: int) {.inline, property.} =
  ## Sets the origin.
  SetViewportOrgEx(self.mHdc, x, y, nil)

proc setOrigin*(self: var wDC, point: wPoint) {.inline, property.} =
  ## Sets the origin.
  self.setOrigin(point.x, point.y)

proc setScale*(self: var wDC, x: float, y: float) {.property.} =
  ## Sets the scaling factor.
  proc calc(s: float, top, bottom: var int32) =
    let sabs = s.abs
    if sabs == 1:
      bottom = 1
      top = int32(1'f * s)
    elif sabs < 1:
      bottom = 134217727
      top = int32(134217727'f * s)
    else: # > 1
      top = 134217727
      bottom = int32(134217727'f / s)

  self.mScale = (x, y)
  if x == 1.0 and y == 1.0:
    SetMapMode(self.mHdc, MM_TEXT)
  else:
    var topx, topy, bottomx, bottomy: int32
    calc(x, topx, bottomx)
    calc(y, topy, bottomy)

    SetMapMode(self.mHdc, MM_ANISOTROPIC)
    SetViewportExtEx(self.mHdc, topx, topy, nil)
    SetWindowExtEx(self.mHdc, bottomx, bottomy, nil)

proc setScale*(self: var wDC, scale: (float, float)) {.inline, property.} =
  ## Sets the scaling factor.
  self.setScale(scale[0], scale[1])

proc crossHair*(self: var wDC, x: int, y: int) =
  ## Displays a cross hair using the current pen.
  let
    cxScreen = GetSystemMetrics(SM_CXSCREEN)
    cyScreen = GetSystemMetrics(SM_CYSCREEN)

  let prev = SetMapMode(self.mHdc, MM_TEXT)
  self.drawLine(x - cxScreen, y, x + cxScreen, y)
  self.drawLine(x, y - cyScreen, x, y + cyScreen)

  if prev != MM_TEXT:
    self.setScale(self.mScale)

proc crossHair*(self: var wDC, point: wPoint) =
  ## Displays a cross hair using the current pen.
  self.crossHair(point.x, point.y)

proc clear*(self: var wDC, brush: wBrush = nil) =
  ## Clears the device context using the current background color.
  ## A custom brush can be use to fill the background.
  var rect: RECT
  let
    origin = self.getOrigin()
    size = self.getSize()

  rect.left = - origin.x
  rect.top = - origin.y
  rect.right = size.width
  rect.bottom = size.height

  let prev = SetMapMode(self.mHdc, MM_TEXT)
  if brush.isNil:
    ExtTextOut(self.mHdc, 0, 0, ETO_OPAQUE, rect, nil, 0, nil)
  else:
    FillRect(self.mHdc, rect, brush.mHandle)

  if prev != MM_TEXT:
    self.setScale(self.mScale)

proc blit*(self: wDC, xdest = 0, ydest = 0, width = 0, height = 0, source: wDC,
    xsrc = 0, ysrc = 0, rop = wCopy) =
  ## Copy from a source DC to this DC. *rop* is the raster operation.
  BitBlt(self.mHdc, xdest, ydest, width, height, source.mHdc, xsrc, ysrc, rop.dwRop)

proc stretchBlit*(self: wDC, xdest = 0, ydest = 0, dstWidth = 0, dstHeight = 0,
    source: wDC, xsrc = 0, ysrc = 0, srcWidth = 0, srcHeight = 0, rop = wCopy) =
  ## Copy from a source DC to this DC possibly changing the scale.
  ## *rop* is the raster operation.
  StretchBlt(self.mHdc, xdest, ydest, dstWidth, dstHeight, source.mHdc, xsrc, ysrc,
    srcWidth, srcHeight, rop.dwRop)

proc stretchBlitQuality*(self: wDC, xdest = 0, ydest = 0, dstWidth = 0, dstHeight = 0,
    source: wDC, xsrc = 0, ysrc = 0, srcWidth = 0, srcHeight = 0, rop = wCopy) =
  ## Copy from a source DC to this DC possibly changing the scale.
  ## *rop* is the raster operation. Using halftone mode for higher quality.
  var prevPoint: POINT
  let prevMode = SetStretchBltMode(self.mHdc, HALFTONE)
  SetBrushOrgEx(self.mHdc, 0, 0, &prevPoint)

  StretchBlt(self.mHdc, xdest, ydest, dstWidth, dstHeight, source.mHdc, xsrc, ysrc,
    srcWidth, srcHeight, rop.dwRop)

  SetStretchBltMode(self.mHdc, prevMode)
  SetBrushOrgEx(self.mHdc, prevPoint.x, prevPoint.y, nil)

proc alphaBlit*(self: wDC, xdest = 0, ydest = 0, dstWidth = 0, dstHeight = 0,
    source: wDC, xsrc = 0, ysrc = 0, srcWidth = 0, srcHeight = 0, alpha = 255) =
  ## Copy from a source DC to this DC transparently.
  ## The bitmap selected in the source DC must have a transparency mask.
  var bf = BLENDFUNCTION(BlendOp: AC_SRC_OVER, SourceConstantAlpha: alpha.byte,
    AlphaFormat: AC_SRC_ALPHA)

  AlphaBlend(self.mHdc, xdest, ydest, dstWidth, dstHeight, source.mHdc, xsrc, ysrc,
    srcWidth, srcHeight, bf)

proc transparentBlit*(self: wDC, xdest = 0, ydest = 0, dstWidth = 0, dstHeight = 0,
    source: wDC, xsrc = 0, ysrc = 0, srcWidth = 0, srcHeight = 0, transparent = wWhite) =
  ## Copy from a source DC to this DC and treat a RGB color as transparent.
  TransparentBlt(self.mHdc, xdest, ydest, dstWidth, dstHeight, source.mHdc,
    xsrc, ysrc, srcWidth, srcHeight, transparent)

proc drawBitmap*(self: wDC, bmp: wBitmap, x = 0, y = 0, transparent = true) =
  ## Draw a bitmap on the device context at the specified point. If *transparent*
  ## is true and the bitmap has a transparency mask, the bitmap will be drawn
  ## transparently.
  wValidate(bmp)
  let
    memdc = CreateCompatibleDC(0)
    prev = SelectObject(memdc, bmp.mHandle)
  defer:
    SelectObject(memdc, prev)
    DeleteDC(memdc)

  if transparent:
    var bf = BLENDFUNCTION(BlendOp: AC_SRC_OVER, SourceConstantAlpha: 255,
      AlphaFormat: AC_SRC_ALPHA)

    AlphaBlend(self.mHdc, x, y, bmp.mWidth, bmp.mHeight, memdc, 0, 0,
      bmp.mWidth, bmp.mHeight, bf)

  else:
    BitBlt(self.mHdc, x, y, bmp.mWidth, bmp.mHeight, memdc, 0, 0, SRCCOPY)

proc drawBitmap*(self: wDC, bmp: wBitmap, pos: wPoint, transparent = true) =
  ## Draw a bitmap on the device context at the specified point.
  wValidate(bmp)
  self.drawBitmap(bmp, pos.x, pos.y)

proc drawImage*(self: wDC, image: wImage, x = 0, y = 0) =
  ## Draw a image on the device context at the specified point.
  wValidate(image)
  self.drawBitmap(Bitmap(image), x, y)

proc drawImage*(self: wDC, image: wImage, pos: wPoint) =
  ## Draw a image on the device context at the specified point.
  wValidate(image)
  self.drawBitmap(Bitmap(image), pos.x, pos.y)

proc drawIcon*(self: wDC, icon: wIcon, x = 0, y = 0) =
  ## Draw an icon at the specified point.
  wValidate(icon)
  DrawIconEx(self.mHdc, x, y, icon.mHandle, icon.mWidth, icon.mHeight, 0, 0, DI_NORMAL)

proc getCharHeight*(self: wDC): int {.property.} =
  ## Gets the character height of the currently set font.
  var textMetric: TEXTMETRIC
  GetTextMetrics(self.mHdc, &textMetric)
  result = textMetric.tmHeight

proc getCharWidth*(self: wDC): int {.property.} =
  ## Gets the average character width of the currently set font.
  var textMetric: TEXTMETRIC
  GetTextMetrics(self.mHdc, &textMetric)
  result = textMetric.tmAveCharWidth

proc getFontMetrics*(self: wDC): tuple[height, ascent, descent, internalLeading,
  externalLeading, averageWidth: int] {.property.} =
  ## Returns the various font characteristics.
  var textMetric: TEXTMETRIC
  GetTextMetrics(self.mHdc, &textMetric)
  result.height = textMetric.tmHeight
  result.ascent = textMetric.tmAscent
  result.descent = textMetric.tmDescent
  result.internalLeading = textMetric.tmInternalLeading
  result.externalLeading = textMetric.tmExternalLeading
  result.averageWidth = textMetric.tmAveCharWidth

proc init*(self: var wDC, fgColor: wColor = wBlack, bgColor: wColor = wWhite,
    font = wDefaultFont, pen = wDefaultPen, brush = wDefaultBrush,
    background = wWhite) =
  ## Initializer.
  self.setTextForeground(fgColor)
  self.setTextBackground(bgColor)
  self.setFont(if font != nil: font else: wDefaultFont)
  self.setPen(if pen != nil: pen else: wDefaultPen)
  self.setBrush(if brush != nil: brush else: wDefaultBrush)
  self.setBackground(background)
  self.setRegion(wNilRegion)
