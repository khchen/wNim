#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

# Here we develop a wHyperLink GUI control as custom control example.

# wNim's class/object use following naming convention.
# 1. Class name starts with 'w' and define as ref object. e.g. wObject.
# 2. Every class have init(self: wObject) and final(self: wObject)
#    as initializer and finalizer.
# 3. Provides an Object() proc to quickly get the ref object.

import
  wNim,
  winim/inc/[winuser, shellapi]

# Define event message starting from wEvent_App.
const
  wEvent_OpenUrl* = wEvent_App + 1

# Use wStaticText as a base class to develop the contorl.
type
  wHyperLink* = ref object of wStaticText
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
# For example, if we have setFont(self: wHyperLink, font: wFont) {.property.},
# then we can just write self.font = Font(10)

proc getVisitedOrNormalColor(self: wHyperLink): wColor {.validate, property.} =
  result = if self.mIsVisited: self.mVisitedColor else: self.mNormalColor

proc setFont*(self: wHyperLink, font: wFont) {.validate, property.} =
  self.wWindow.setFont(font)
  self.mNormalFont = font
  self.fit()

proc getHoverFont*(self: wHyperLink): wFont {.validate, property.} =
  result = self.mHoverFont

proc setHoverFont*(self: wHyperLink, font: wFont) {.validate, property.} =
  self.mHoverFont = font
  if self.mIsMouseHover:
    self.wWindow.setFont(self.mHoverFont)
    self.fit()

proc getMarkedColor*(self: wHyperLink): wColor {.validate, property.} =
  result = self.mMarkedColor

proc setMarkedColor*(self: wHyperLink, color: wColor) {.validate, property.} =
  self.mMarkedColor = color
  if self.mIsPressed:
    self.setForegroundColor(self.mMarkedColor)
    self.refresh()

proc getNormalColor*(self: wHyperLink): wColor {.validate, property.} =
  result = self.mNormalColor

proc setNormalColor*(self: wHyperLink, color: wColor) {.validate, property.} =
  self.mNormalColor = color
  if not self.mIsPressed:
    self.setForegroundColor(self.visitedOrNormalColor)
    self.refresh()

proc getVisitedColor*(self: wHyperLink): wColor {.validate, property.} =
  result = self.mVisitedColor

proc setVisitedColor*(self: wHyperLink, color: wColor) {.validate, property.} =
  self.mVisitedColor = color
  if not self.mIsPressed:
    self.setForegroundColor(self.visitedOrNormalColor)
    self.refresh()

proc getUrl*(self: wHyperLink): string {.validate, property.} =
  result = self.mUrl

proc setUrl*(self: wHyperLink, url: string) {.validate, property.} =
  self.mUrl = url

proc setVisited*(self: wHyperLink, isVisited = true) {.validate, property.} =
  self.mIsVisited = isVisited

proc getVisited*(self: wHyperLink): bool {.validate, property.} =
  result = self.mIsVisited

proc final*(self: wHyperLink) =
  self.wStaticText.final()

proc init*(self: wHyperLink, parent: wWindow, id = wDefaultID, label: string,
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

  # Assume this event will propagated like other command event.
  wAppGetCurrentApp().setMessagePropagation(wEvent_OpenUrl)

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
    var isPressed = self.mIsPressed
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

proc HyperLink*(parent: wWindow, id = wDefaultID, label: string, url: string,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0): wHyperLink
    {.discardable.} =

  new(result, final)
  result.init(parent, id, label, url, pos, size, style)

when isMainModule:
  import resource/resource

  var app = App()
  var frame = Frame()
  frame.icon = Icon("", 0) # load icon from exe file.

  var statusBar = StatusBar(frame)
  var panel = Panel(frame)
  var hyperlink = HyperLink(panel, label="Google", url="https://www.google.com",
    pos=(20, 20))

  hyperlink.font = Font(18)
  hyperlink.hoverFont = Font(18, weight=wFontWeightBold, underline=true)

  hyperlink.wEvent_OpenUrl do (event: wEvent):
    if not event.ctrlDown:
      event.veto
      statusBar.setStatusText("press ctrl key and then click to open the url.")

  frame.show()
  app.mainLoop()
