#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## Creates a standalone tooltip anywhere on the screen.
#
## :Superclass:
##   `wWindow <wWindow.html>`_

include pragma
import wBase, wWindow
export wWindow

method show*(self: wToolTip, flag = true) {.inline.} =
  ## Shows or hides the tooltip.
  SendMessage(self.mHwnd, TTM_TRACKACTIVATE, if flag: 1 else: 0, cast[LPARAM](&self.mToolInfo))

proc setBalloon*(self: wToolTip, flag = true) {.validate, property.} =
  ## Indicates that the tooltip control has the appearance of a cartoon "balloon".
  if flag:
    self.addWindowStyle(TTS_BALLOON)
  else:
    self.clearWindowStyle(TTS_BALLOON)

proc setTip*(self: wToolTip, text = "", pos = wDefaultPoint, title = "",
    icon: wIcon = nil) {.validate, property.} =
  ## Sets the tip by given text, pos, title and icon.
  if text.len == 0:
    self.hide()

  else:
    self.setLabel(text)
    self.move(pos)

    if title.len != 0:
      # MSDN: When calling TTM_SETTITLE, the string pointed to by lParam must not
      # exceed 100 TCHARs in length
      if icon.isNil:
        SendMessage(self.mHwnd, TTM_SETTITLE, TTI_INFO, &T(title.substr(0, 99)))
      else:
        SendMessage(self.mHwnd, TTM_SETTITLE, icon.mHandle, &T(title.substr(0, 99)))

    self.show()

    if pos == wDefaultPoint:
      # get the default pos (near mouse cursor, count by system)
      self.mToolInfo.uFlags = 0
      SendMessage(self.mHwnd, TTM_SETTOOLINFO, 0, cast[LPARAM](&self.mToolInfo))
      self.move(self.getPosition())

proc setToolTip*(self: wToolTip, maxWidth = wDefault, autoPop = wDefault,
    delay = wDefault, reshow = wDefault) {.validate, property.} =
  ## Sets the parameters of the tooltip. -1 to restore the default.
  if maxWidth != wDefault:
    SendMessage(self.mHwnd, TTM_SETMAXTIPWIDTH, 0, maxWidth)

  if autoPop != wDefault:
    SendMessage(self.mHwnd, TTM_SETDELAYTIME, TTDT_AUTOPOP, autoPop and 0xffff)

  if delay != wDefault:
    SendMessage(self.mHwnd, TTM_SETDELAYTIME, TTDT_INITIAL, delay and 0xffff)

  if reshow != wDefault:
    SendMessage(self.mHwnd, TTM_SETDELAYTIME, TTDT_RESHOW, reshow and 0xffff)

wClass(wToolTip of wWindow):

  method release*(self: wToolTip) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wToolTip, text = "", pos = wDefaultPoint, title = "",
      icon: wIcon = nil) {.validate.} =
    ## Initializer.
    self.mText = text
    self.mToolInfo = TOOLINFO(cbSize: sizeof(TOOLINFO),
      uFlags: 0, lpszText: self.mText)

    let hwnd = CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil,
      WS_POPUP or TTS_NOPREFIX or TTS_ALWAYSTIP, CW_USEDEFAULT, CW_USEDEFAULT,
      CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, wAppGetInstance(), nil)

    SendMessage(hwnd, TTM_ADDTOOL, 0, cast[LPARAM](&self.mToolInfo))
    self.init(hwnd)

    # This handler let tooltip close.
    self.systemDisconnect(WM_MOUSEMOVE, wWindow_DoMouseMove)
    self.systemDisconnect(WM_MOUSELEAVE, wWindow_DoMouseLeave)

    # So that SetWindowText() and GetWindowText() work.
    self.systemConnect(WM_SETTEXT) do (event: wEvent):
      self.mText = $(cast[LPTSTR](event.mLparam))
      self.mToolInfo.lpszText = self.mText
      SendMessage(self.mHwnd, TTM_UPDATETIPTEXT, 0, cast[LPARAM](&self.mToolInfo))

    # So that move() works.
    var inMove = false
    self.systemConnect(WM_MOVE) do (event: wEvent):
      if not inMove:
        inMove = true
        self.mToolInfo.uFlags = TTF_TRACK
        SendMessage(self.mHwnd, TTM_SETTOOLINFO, 0, cast[LPARAM](&self.mToolInfo))
        SendMessage(self.mHwnd, TTM_TRACKPOSITION, 0, event.mLparam)
        inMove = false

    self.setTip(text, pos, title, icon)
