#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2020 Ward
#
#====================================================================

# Here we develop a wHyperlink GUI control as custom control example.

# wNim's class/object use following naming convention.
# 1. Class name starts with 'w' and define as ref object. e.g. wObject.
# 2. Every class have init(self: wObject) as initializer.
# 3. Provides an Object() proc to quickly get the ref object.

# wClass (defined in wMacros) provides a convenient way to define wNim class.

import
  winim/[winstr, utils],
  winim/inc/[winuser, shellapi]

import wNim/[wApp, wMacros, wStaticText, wFont, wCursor]

# Define ourself event type, wCommandEvent-derived event by default propagate upward
type
  wMyLinkEvent = ref object of wCommandEvent

# Use wEventRegister macro to define the event message
wEventRegister(wMyLinkEvent):
  wEvent_OpenUrl

# Use wStaticText as a base class to develop the contorl.
type
  wHyperlink* = ref object of wStaticText
    mUrl: string
    mMarkedColor: wColor
    mVisitedColor: wColor
    mNormalColor: wColor
    mHoverFont: wFont
    mNormalFont: wFont
    mIsMouseHover: bool
    mIsPressed: bool
    mIsVisited: bool

# Add validate macro to ensure self is not nil.
# Add property macro so that getters/setters can access as nim's style.
# For example, if we have setFont(self: wHyperlink, font: wFont) {.property.},
# then we can just write self.font = Font(10)

wClass(wHyperlink of wStaticText):
  # Constructor is generated from initializer automatically.

  proc getVisitedOrNormalColor(self: wHyperlink): wColor {.validate, property.} =
    result = if self.mIsVisited: self.mVisitedColor else: self.mNormalColor

  proc setFont*(self: wHyperlink, font: wFont) {.validate, property.} =
    self.wWindow.setFont(font)
    self.mNormalFont = font
    self.fit()

  proc getHoverFont*(self: wHyperlink): wFont {.validate, property.} =
    result = self.mHoverFont

  proc setHoverFont*(self: wHyperlink, font: wFont) {.validate, property.} =
    self.mHoverFont = font
    if self.mIsMouseHover:
      self.wWindow.setFont(self.mHoverFont)
      self.fit()

  proc getMarkedColor*(self: wHyperlink): wColor {.validate, property.} =
    result = self.mMarkedColor

  proc setMarkedColor*(self: wHyperlink, color: wColor) {.validate, property.} =
    self.mMarkedColor = color
    if self.mIsPressed:
      self.setForegroundColor(self.mMarkedColor)
      self.refresh()

  proc getNormalColor*(self: wHyperlink): wColor {.validate, property.} =
    result = self.mNormalColor

  proc setNormalColor*(self: wHyperlink, color: wColor) {.validate, property.} =
    self.mNormalColor = color
    if not self.mIsPressed:
      self.setForegroundColor(self.visitedOrNormalColor)
      self.refresh()

  proc getVisitedColor*(self: wHyperlink): wColor {.validate, property.} =
    result = self.mVisitedColor

  proc setVisitedColor*(self: wHyperlink, color: wColor) {.validate, property.} =
    self.mVisitedColor = color
    if not self.mIsPressed:
      self.setForegroundColor(self.visitedOrNormalColor)
      self.refresh()

  proc getUrl*(self: wHyperlink): string {.validate, property.} =
    result = self.mUrl

  proc setUrl*(self: wHyperlink, url: string) {.validate, property.} =
    self.mUrl = url

  proc setVisited*(self: wHyperlink, isVisited = true) {.validate, property.} =
    self.mIsVisited = isVisited

  proc getVisited*(self: wHyperlink): bool {.validate, property.} =
    result = self.mIsVisited

  proc init*(self: wHyperlink, parent: wWindow, id = wDefaultID, label: string,
      url: string, pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

    self.wStaticText.init(parent, id, label, pos, size, style)
    self.mUrl = url
    self.mMarkedColor = wRed
    self.mVisitedColor = 0x8B1A55
    self.mNormalColor = wBlue
    self.mIsMouseHover = false
    self.mIsPressed = false
    self.mIsVisited = false

    self.fit()
    self.setCursor(wHandCursor)
    self.setForegroundColor(self.mNormalColor)

    self.mNormalFont = self.getFont()
    self.mHoverFont = Font(self.mNormalFont)
    self.mHoverFont.underlined = true

    self.wEvent_MouseEnter do ():
      self.mIsMouseHover = true
      self.wWindow.setFont(self.mHoverFont)
      if self.mIsPressed:
        self.setForegroundColor(self.mMarkedColor)
      else:
        self.setForegroundColor(self.visitedOrNormalColor)
      self.fit()
      self.refresh()

    self.wEvent_MouseLeave do ():
      self.mIsMouseHover = false
      self.wWindow.setFont(self.mNormalFont)
      self.setForegroundColor(self.visitedOrNormalColor)
      self.fit()
      self.refresh()

    self.wEvent_LeftDown do ():
      self.mIsPressed = true
      self.captureMouse()
      self.setForegroundColor(self.mMarkedColor)
      self.refresh()

    self.wEvent_LeftUp do ():
      let isPressed = self.mIsPressed
      self.mIsPressed = false
      self.releaseMouse()
      self.setForegroundColor(self.visitedOrNormalColor)
      self.refresh()

      if self.mIsMouseHover and isPressed:
        if self.mUrl.len != 0:
          # provide a chance let the user to veto the action.
          let event = Event(window=self, msg=wEvent_OpenUrl)
          if not self.processEvent(event) or event.isAllowed:
            ShellExecute(0, "open", self.mUrl, nil, nil, SW_SHOW)
        self.mIsVisited = true

when isMainModule:
  import resource/resource
  import wNim/[wApp, wFrame, wIcon, wStatusBar, wPanel, wFont]

  let app = App()
  let frame = Frame(title="wHyperlink custom control")
  frame.icon = Icon("", 0) # load icon from exe file.

  let statusBar = StatusBar(frame)
  let panel = Panel(frame)
  let hyperlink = Hyperlink(panel, label="Google", url="https://www.google.com",
    pos=(20, 20))

  hyperlink.font = Font(18)
  hyperlink.hoverFont = Font(18, weight=wFontWeightBold, underline=true)

  # wEvent_OpenUrl will propagate upward, so we can catch it from it's parent window.
  panel.wEvent_OpenUrl do (event: wEvent):
    if not event.ctrlDown:
      event.veto
      statusBar.setStatusText("press ctrl key and then click to open the url.")

  frame.show()
  app.mainLoop()
