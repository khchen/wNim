#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

{.this: self.}

# Here we develop a wHyperLink GUI control as custom control example.

# wNim's class/object use following naming convention.
# 1. Class name starts with 'w' and define as ref object. e.g. wObject.
# 2. Every class have init(self: wObject) and final(self: wObject)
#    as initializer and finalizer.
# 3. Provides an Object() proc to quickly get the ref object.

import wNim
import winim/inc/shellapi # for ShellExecute()

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
# For example, if we have setFont(sefl: wHyperLink, font: wFont) {.property.},
# then we can just write self.font = Font(10)

proc setFont*(self: wHyperLink, font: wFont) {.validate, property.} =
  self.wWindow.setFont(font)
  mNormalFont = font
  fit()

proc getHoverFont*(self: wHyperLink): wFont {.validate, property.} =
  result = mHoverFont

proc setHoverFont*(self: wHyperLink, font: wFont) {.validate, property.} =
  mHoverFont = font
  if mIsMouseHover:
    self.wWindow.setFont(mHoverFont)
    fit()

proc getMarkedColor*(self: wHyperLink): wColor {.validate, property.} =
  result = mMarkedColor

proc setMarkedColor*(self: wHyperLink, color: wColor) {.validate, property.} =
  mMarkedColor = color
  if mIsPressed:
    setForegroundColor(mMarkedColor)
    refresh()

proc getNormalColor*(self: wHyperLink): wColor {.validate, property.} =
  result = mNormalColor

proc setNormalColor*(self: wHyperLink, color: wColor) {.validate, property.} =
  mNormalColor = color
  if not mIsPressed:
    setForegroundColor(if mIsVisited: mVisitedColor else: mNormalColor)
    refresh()

proc getVisitedColour*(self: wHyperLink): wColor {.validate, property.} =
  result = mVisitedColor

proc setVisitedColour*(self: wHyperLink, color: wColor) {.validate, property.} =
  mVisitedColor = color
  if not mIsPressed:
    setForegroundColor(if mIsVisited: mVisitedColor else: mNormalColor)
    refresh()

proc getUrl*(self: wHyperLink): string {.validate, property.} =
  result = mUrl

proc setUrl*(self: wHyperLink, url: string) {.validate, property.} =
  mUrl = url

proc setVisited*(self: wHyperLink, isVisited = true) {.validate, property.} =
  mIsVisited = isVisited

proc getVisited*(self: wHyperLink): bool {.validate, property.} =
  result = mIsVisited

proc final*(self: wHyperLink) =
  self.wStaticText.final()

proc init*(self: wHyperLink, parent: wWindow, id = wDefaultID, label: string,
    url: string, pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  self.wStaticText.init(parent, id, label, pos, size, style)
  mUrl = url
  mMarkedColor = wRed
  mVisitedColor = 0x8B1A55
  mNormalColor = wBlue
  mIsMouseHover = false
  mIsPressed = false
  mIsVisited = false

  fit()
  setCursor(wHandCursor)
  setForegroundColor(mNormalColor)

  mNormalFont = getFont()
  mHoverFont = Font(mNormalFont)
  mHoverFont.underlined = true

  # Assume this event will propagated like other command event.
  wAppGetCurrentApp().setMessagePropagation(wEvent_OpenUrl)

  self.wEvent_MouseEnter do ():
    mIsMouseHover = true
    self.wWindow.setFont(mHoverFont)
    if mIsPressed:
      self.setForegroundColor(mMarkedColor)
    else:
      self.setForegroundColor(if mIsVisited: mVisitedColor else: mNormalColor)
    self.fit()
    self.refresh()

  self.wEvent_MouseLeave do ():
    mIsMouseHover = false
    self.wWindow.setFont(mNormalFont)
    self.setForegroundColor(if mIsVisited: mVisitedColor else: mNormalColor)
    self.fit()
    self.refresh()

  self.wEvent_LeftDown do ():
    mIsPressed = true
    self.captureMouse()
    self.setForegroundColor(mMarkedColor)
    self.refresh()

  self.wEvent_LeftUp do ():
    var isPressed = mIsPressed
    mIsPressed = false
    self.releaseMouse()
    self.setForegroundColor(if mIsVisited: mVisitedColor else: mNormalColor)
    self.refresh()

    if mIsMouseHover and isPressed:
      if mUrl != nil:
        # provide a chance let the user to veto the action.
        let event = Event(window=self, msg=wEvent_OpenUrl)
        if not self.processEvent(event) or event.isAllowed:
          ShellExecute(0, "open", mUrl, nil, nil, SW_SHOW)
      mIsVisited = true

proc HyperLink*(parent: wWindow, id = wDefaultID, label: string, url: string,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0): wHyperLink
    {.discardable.} =

  new(result, final)
  result.init(parent, id, label, url, pos, size, style)

when isMainModule:
  {.passL: "wNim.res".}

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
