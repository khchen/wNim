#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2021 Ward
#
#====================================================================

import std/[colors, tables]
import resource/resource

import wNim/[wApp, wMacros, wFrame, wPanel, wPaintDC, wBrush, wPen, wFont, wIcon,
  wMenuBar, wMenu, wUtils, wDataObject]

const
  wNimColorTable = {
    "wAquamarine": wAquamarine, "wBlack": wBlack, "wBlue": wBlue, "wBlueViolet": wBlueViolet,
    "wBrown": wBrown, "wCadetBlue": wCadetBlue, "wCoral": wCoral, "wCornflowerBlue": wCornflowerBlue,
    "wCyan": wCyan, "wDarkGreen": wDarkGreen, "wDarkGrey": wDarkGrey, "wDarkOliveGreen": wDarkOliveGreen,
    "wDarkOrchid": wDarkOrchid, "wDarkSlateBlue": wDarkSlateBlue, "wDarkSlateGrey": wDarkSlateGrey,
    "wDarkTurquoise": wDarkTurquoise, "wDimGrey": wDimGrey, "wFireBrick": wFireBrick,
    "wForestGreen": wForestGreen, "wGold": wGold, "wGoldenrod": wGoldenrod, "wGreen": wGreen,
    "wGreenYellow": wGreenYellow, "wGrey": wGrey, "wIndianRed": wIndianRed, "wKhaki": wKhaki,
    "wLightBlue": wLightBlue, "wLightGrey": wLightGrey, "wLightMagenta": wLightMagenta,
    "wLightSteelBlue": wLightSteelBlue, "wLimeGreen": wLimeGreen, "wMagenta": wMagenta,
    "wMaroon": wMaroon, "wMediumAquamarine": wMediumAquamarine, "wMediumBlue": wMediumBlue,
    "wMediumForestGreen": wMediumForestGreen, "wMediumGoldenrod": wMediumGoldenrod,
    "wMediumGrey": wMediumGrey, "wMediumOrchid": wMediumOrchid, "wMediumSeaGreen": wMediumSeaGreen,
    "wMediumSlateBlue": wMediumSlateBlue, "wMediumSpringGreen": wMediumSpringGreen,
    "wMediumTurquoise": wMediumTurquoise, "wMediumVioletRed": wMediumVioletRed,
    "wMidnightBlue": wMidnightBlue, "wNavy": wNavy, "wOrange": wOrange, "wOrangeRed": wOrangeRed,
    "wOrchid": wOrchid, "wPaleGreen": wPaleGreen, "wPink": wPink, "wPlum": wPlum, "wPurple": wPurple,
    "wRed": wRed, "wSalmon": wSalmon, "wSeaGreen": wSeaGreen, "wSienna": wSienna, "wSkyBlue": wSkyBlue,
    "wSlateBlue": wSlateBlue, "wSpringGreen": wSpringGreen, "wSteelBlue": wSteelBlue,
    "wTan": wTan, "wThistle": wThistle, "wTurquoise": wTurquoise, "wViolet": wViolet,
    "wVioletRed": wVioletRed, "wWheat": wWheat, "wWhite": wWhite, "wYellow": wYellow,
    "wYellowGreen": wYellowGreen
  }.toOrderedTable

  stdColorTable = {
    "colAliceBlue": colAliceBlue, "colAntiqueWhite": colAntiqueWhite, "colAqua": colAqua,
    "colAquamarine": colAquamarine, "colAzure": colAzure, "colBeige": colBeige,
    "colBisque": colBisque, "colBlack": colBlack, "colBlanchedAlmond": colBlanchedAlmond,
    "colBlue": colBlue,  "colBlueViolet": colBlueViolet, "colBrown": colBrown,
    "colBurlyWood": colBurlyWood, "colCadetBlue": colCadetBlue, "colChartreuse": colChartreuse,
    "colChocolate": colChocolate, "colCoral": colCoral, "colCornflowerBlue": colCornflowerBlue,
    "colCornsilk": colCornsilk, "colCrimson": colCrimson, "colCyan": colCyan,
    "colDarkBlue": colDarkBlue, "colDarkCyan": colDarkCyan, "colDarkGoldenRod": colDarkGoldenRod,
    "colDarkGray": colDarkGray, "colDarkGreen": colDarkGreen, "colDarkKhaki": colDarkKhaki,
    "colDarkMagenta": colDarkMagenta, "colDarkOliveGreen": colDarkOliveGreen,
    "colDarkorange": colDarkorange, "colDarkOrchid": colDarkOrchid, "colDarkRed": colDarkRed,
    "colDarkSalmon": colDarkSalmon, "colDarkSeaGreen": colDarkSeaGreen,
    "colDarkSlateBlue": colDarkSlateBlue, "colDarkSlateGray": colDarkSlateGray,
    "colDarkTurquoise": colDarkTurquoise, "colDarkViolet": colDarkViolet, "colDeepPink": colDeepPink,
    "colDeepSkyBlue": colDeepSkyBlue, "colDimGray": colDimGray, "colDodgerBlue": colDodgerBlue,
    "colFireBrick": colFireBrick, "colFloralWhite": colFloralWhite, "colForestGreen": colForestGreen,
    "colFuchsia": colFuchsia, "colGainsboro": colGainsboro, "colGhostWhite": colGhostWhite,
    "colGold": colGold, "colGoldenRod": colGoldenRod, "colGray": colGray, "colGreen": colGreen,
    "colGreenYellow": colGreenYellow, "colHoneyDew": colHoneyDew, "colHotPink": colHotPink,
    "colIndianRed": colIndianRed, "colIndigo": colIndigo, "colIvory": colIvory, "colKhaki": colKhaki,
    "colLavender": colLavender, "colLavenderBlush": colLavenderBlush, "colLawnGreen": colLawnGreen,
    "colLemonChiffon": colLemonChiffon, "colLightBlue": colLightBlue, "colLightCoral": colLightCoral,
    "colLightCyan": colLightCyan, "colLightGoldenRodYellow": colLightGoldenRodYellow,
    "colLightGrey": colLightGrey, "colLightGreen": colLightGreen, "colLightPink": colLightPink,
    "colLightSalmon": colLightSalmon, "colLightSeaGreen": colLightSeaGreen,
    "colLightSkyBlue": colLightSkyBlue, "colLightSlateGray": colLightSlateGray,
    "colLightSteelBlue": colLightSteelBlue, "colLightYellow": colLightYellow,
    "colLime": colLime, "colLimeGreen": colLimeGreen, "colLinen": colLinen, "colMagenta": colMagenta,
    "colMaroon": colMaroon, "colMediumAquaMarine": colMediumAquaMarine, "colMediumBlue": colMediumBlue,
    "colMediumOrchid": colMediumOrchid, "colMediumPurple": colMediumPurple,
    "colMediumSeaGreen": colMediumSeaGreen, "colMediumSlateBlue": colMediumSlateBlue,
    "colMediumSpringGreen": colMediumSpringGreen, "colMediumTurquoise": colMediumTurquoise,
    "colMediumVioletRed": colMediumVioletRed, "colMidnightBlue": colMidnightBlue,
    "colMintCream": colMintCream, "colMistyRose": colMistyRose,  "colMoccasin": colMoccasin,
    "colNavajoWhite": colNavajoWhite, "colNavy": colNavy, "colOldLace": colOldLace,
    "colOlive": colOlive, "colOliveDrab": colOliveDrab, "colOrange": colOrange,
    "colOrangeRed": colOrangeRed, "colOrchid": colOrchid, "colPaleGoldenRod": colPaleGoldenRod,
    "colPaleGreen": colPaleGreen, "colPaleTurquoise": colPaleTurquoise,
    "colPaleVioletRed": colPaleVioletRed, "colPapayaWhip": colPapayaWhip, "colPeachPuff": colPeachPuff,
    "colPeru": colPeru, "colPink": colPink, "colPlum": colPlum, "colPowderBlue": colPowderBlue,
    "colPurple": colPurple, "colRed": colRed, "colRosyBrown": colRosyBrown,
    "colRoyalBlue": colRoyalBlue, "colSaddleBrown": colSaddleBrown, "colSalmon": colSalmon,
    "colSandyBrown": colSandyBrown, "colSeaGreen": colSeaGreen, "colSeaShell": colSeaShell,
    "colSienna": colSienna, "colSilver": colSilver, "colSkyBlue": colSkyBlue,
    "colSlateBlue": colSlateBlue, "colSlateGray": colSlateGray, "colSnow": colSnow,
    "colSpringGreen": colSpringGreen, "colSteelBlue": colSteelBlue, "colTan": colTan,
    "colTeal": colTeal, "colThistle": colThistle, "colTomato": colTomato, "colTurquoise": colTurquoise,
    "colViolet": colViolet, "colWheat": colWheat, "colWhite": colWhite, "colWhiteSmoke": colWhiteSmoke,
    "colYellow": colYellow, "colYellowGreen": colYellowGreen
  }.toOrderedTable

type
  wColorPanel = ref object of wPanel
    mColorTable: OrderedTable[string, wColor]
    mRects: Table[string, wRect]
    mBoxSize: wSize
    mBoxGap: int
    mFocusColor: string

wClass(wColorPanel of wPanel):

  proc onPaint(self: wColorPanel) =
    var dc = PaintDC(self)
    var currentY = 0
    if self.hasScrollbar(wVertical): currentY = self.getScrollPos(wVertical)

    let clientSize = self.clientSize
    var x, y = self.mBoxGap

    y -= currentY

    dc.clear()
    for name, color in self.mColorTable:
      let intensColor = wColor intensity(Color color, 0.4)

      if x + self.mBoxSize.width + self.mBoxGap >= clientSize.width:
        y += self.mBoxSize.height + self.mBoxGap
        x = self.mBoxGap

      self.mRects[name] = (x, y, self.mBoxSize.width, self.mBoxSize.height)

      if self.mFocusColor in [name, "all"]:
        dc.pen = Pen(intensColor, width=6, style=wPenStyleInsideFrame)
      else:
        dc.pen = wTransparentPen

      dc.brush = Brush(color)
      dc.drawRectangle((x, y), self.mBoxSize)

      if self.mFocusColor in [name, "all"]:
        let height = dc.fontMetrics.height + 4
        let rect: wRect = (x, y + self.mBoxSize.height - height - 6, self.mBoxSize.width, height)
        dc.brush = Brush(intensColor)
        dc.pen = wTransparentPen
        dc.drawRectangle(rect)

        dc.textForeground = wWhite
        dc.textBackground = intensColor
        dc.drawLabel(name, rect, wMiddle or wRight)

      x += self.mBoxSize.width + self.mBoxGap

    let scrollHeight = y + currentY + (self.mBoxSize.height) * 2 + self.mBoxGap - clientSize.height
    if scrollHeight >= self.mBoxSize.height:
      self.showScrollBar(wVertical, true)
      self.setScrollbar(wVertical, currentY, self.mBoxSize.height, scrollHeight)
      if self.getScrollPos(wVertical) != currentY:
        self.refresh(false)
    else:
      self.showScrollBar(wVertical, false)

  proc getColorName(self: wColorPanel, pos: wPoint): string =
    for name, rect in self.mRects:
      if pos.x in (rect.x .. rect.x + rect.width) and
          pos.y in (rect.y .. rect.y + rect.height):
        return name

  proc onKeyMouse(self: wColorPanel, event: wEvent) =
    let oldFocusColor = self.mFocusColor

    if event.shiftDown or event.ctrlDown:
      self.mFocusColor = "all"
    else:
      self.mFocusColor = self.getColorName(event.mousePos)

    if oldFocusColor != self.mFocusColor:
      self.refresh(false)

  proc setTable(self: wColorPanel, table: OrderedTable[string, wColor]) =
    self.mColorTable = table
    self.mRects.clear()
    self.refresh(false)

  proc setTable(self: wColorPanel, table: OrderedTable[string, Color]) =
    template towColor(r: untyped, g: untyped, b: untyped): wColor =
      wColor(wColor(r and 0xff) or (wColor(g and 0xff) shl 8) or (wColor(b and 0xff) shl 16))

    self.mColorTable.clear
    for name, color in table:
      let tup = color.extractRGB()
      self.mColorTable[name] = towColor(tup.r, tup.g, tup.b)
    self.mRects.clear()
    self.refresh(false)

  proc sortByName(self: wColorPanel) =
    self.mColorTable.sort do (x, y: (string, wColor)) -> int:
      result = system.cmp(x[0], y[0])
    self.refresh(false)

  proc sortByColor(self: wColorPanel) =
    self.mColorTable.sort do (x, y: (string, wColor)) -> int:
      result = system.cmp(x[1], y[1])
    self.refresh(false)

  proc init(self: wColorPanel, parent: wWindow) =
    wPanel(self).init(parent)
    self.backgroundColor = parent.backgroundColor
    self.setDoubleBuffered(true)
    self.disableFocus(false)

    self.font = Font(8.0, weight=wFontWeightNormal, faceName="Arial Bold")
    self.mBoxSize = (150, 100)
    self.mBoxGap = 10
    self.mRects = initTable[string, wRect]()
    self.mFocusColor = ""
    self.showScrollBar(wVertical, true)
    self.setTable(wNimColorTable)

    self.wEvent_Paint do (): self.onPaint()
    self.wEvent_Size do (): self.refresh(false)
    self.wEvent_ScrollWin do (): self.refresh(false)
    self.wEvent_MouseMove do (event: wEvent): self.onKeyMouse(event)
    self.wEvent_KeyDown do (event: wEvent): self.onKeyMouse(event)
    self.wEvent_KeyUp do (event: wEvent): self.onKeyMouse(event)

when isMainModule:
  type
    MenuID = enum
      idSortByColor = wIdUser, idSortByName, idPaletteStd, idPalettewNim

  let app = App(wSystemDpiAware)
  let frame = Frame(title="wNim Colors")
  frame.icon = Icon("", 0)

  let colorPanel = ColorPanel(frame)

  let menuBar = MenuBar(frame)
  let menuSort = Menu(menuBar, "&Sort")
  menuSort.appendRadioItem(idSortByName, "Sort By &Name").check()
  menuSort.appendRadioItem(idSortByColor, "Sort By &Color")
  let menuPalette = Menu(menuBar, "&Palette")
  menuPalette.appendRadioItem(idPalettewNim, "wNim Colors").check()
  menuPalette.appendRadioItem(idPaletteStd, "Nim Std Colors")

  frame.idSortByName do ():
    colorPanel.sortByName()

  frame.idSortByColor do ():
    colorPanel.sortByColor()

  frame.idPalettewNim do ():
    colorPanel.setTable(wNimColorTable)
    menuSort.check(idSortByName)

  frame.idPaletteStd do ():
    colorPanel.setTable(stdColorTable)
    menuSort.check(idSortByName)

  colorPanel.wEvent_ContextMenu do (event: wEvent):
    let colorName = colorPanel.getColorName(event.mousePos)
    if colorName.len != 0:
      let menu = Menu()
      menu.append(1, "Copy")
      if colorPanel.popupMenu(menu, flag=wPopMenuReturnId) == 1:
        wSetClipboard(DataObject(colorName))

  frame.clientSize = (840, 670)

  frame.center()
  frame.show()
  app.mainLoop()
