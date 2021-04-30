#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## *wSplitter* control is used to split a window into two resizable panel.
## The panels size and position can be changed by users or by
## setSize()/setPosition() programmatically.
##
## A splitter can also attach to one or both panel so that the panel's margin
## become draggable. Of course it only works if the margin size near to the splitter
## is not zero.
##
## Notice: To avoid flicker during resizing, add wDoubleBuffered or wClipChildren
## style depends on what controls you want to place into the panels. For most case,
## wDoubleBuffered is prefered, however, a few controls don't suppoort it. For
## example, report view mode of wListCtrl. Moreover, different version of Windows
## treats it differently. So please try and choose the best result by yourself.
#
## :Appearance:
##   .. image:: images/wSplitter.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wSpVertical                     Specifies a vertical splitter.
##   wSpHorizontal                   Specifies a horizontal splitter.
##   wSpNoBorder                     No border (default).
##   wSpButton                       Draws the splitter button style.
##   wSpBorder                       Draws a standard border.
##   wSp3dBorder                     Draws a 3D effect border around splitter.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_Splitter                  The position is dragging by user. This event can be vetoed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, ../wPanel, ../gdiobjects/wCursor, ../dc/wPaintDC
import wSpinButton, wControl
export wSpinButton, wControl # export wSpinButton for wSpHorizontal/wSpVertical

const
  # use the same define as wSpinButton
  # wSpHorizontal*
  # wSpVertical*
  wSpNoBorder* = 0
  wSpButton* = 0x10000000.int64 shl 32
  wSpBorder* = wBorderSimple
  wSp3dBorder* = wBorderStatic

proc doSetSize(self: wWindow, rect: wRect) =
  if self.getRect() != rect:
    var isShown = self.isShownOnScreen()
    if isShown:
      SendMessage(self.mHwnd, WM_SETREDRAW, FALSE, 0)

    self.setSize(rect)

    if isShown:
      SendMessage(self.mHwnd, WM_SETREDRAW, TRUE, 0)
      RedrawWindow(self.mHwnd, nil, 0, RDW_INVALIDATE or RDW_ERASE or
        RDW_ALLCHILDREN or RDW_UPDATENOW)

proc splitterResize(self: wSplitter, pos = wDefaultPoint) =
  self.mResizing = true
  defer: self.mResizing = false

  proc countLimit(delta: var int, limit: int) =
    delta = delta.clamp(self.mMin1.clamp(0, limit),
      (limit + self.mSize - self.mMin2).clamp(0, limit))

  var clientSize = self.mParent.getClientSize()
  var pos = if pos == wDefaultPoint: self.getPosition() else: pos

  if self.mIsVertical:
    var limit = clientSize.width - self.mSize
    var delta = if pos.x == wDefault: limit div 2 else: pos.x
    delta.countLimit(limit)
    self.doSetSize((delta, 0, self.mSize, clientSize.height))
    self.mPanel1.doSetSize((0, 0, delta, clientSize.height))
    self.mPanel2.doSetSize((delta + self.mSize, 0, limit - delta, clientSize.height))
  else:
    var limit = clientSize.height - self.mSize
    var delta = if pos.y == wDefault: limit div 2 else: pos.y
    delta.countLimit(limit)
    self.doSetSize((0, delta, clientSize.width, self.mSize))
    self.mPanel1.doSetSize((0, 0, clientSize.width, delta))
    self.mPanel2.doSetSize((0, delta + self.mSize, clientSize.width, limit - delta))

proc splitterResetCursor(self: wSplitter) =
  if self.mIsVertical:
    self.setCursor(wSizeWeCursor)
  else:
    self.setCursor(wSizeNsCursor)

proc wSplitter_DoMouseMove(self: wSplitter, event: wEvent, index: int) =
  if self.mDragging:
    let event = Event(window=self, msg=wEvent_Splitter)
    if not self.processEvent(event) or event.isAllowed:
      var pos = self.mParent.screenToClient(event.getMouseScreenPos()) - self.mPosOffset
      self.splitterResize(pos)

  elif index > 0:
    let panel = event.mWindow
    let pos = event.getMousePos()
    let size = panel.getClientSize()

    self.mInPanelMargin =
      if self.mIsVertical:
        if index == 1:
          pos.x > size.width
        else:
          pos.x < 0
      else:
        if index == 1:
          pos.y > size.height
        else:
          pos.y < 0

    if not self.isEnabled():
      self.mInPanelMargin = false

    if self.mInPanelMargin:
      panel.setOverrideCursor(if self.mIsVertical: wSizeWeCursor else: wSizeNsCursor)
    else:
      panel.setOverrideCursor(nil)

proc wSplitter_DoMouseLeave(self: wSplitter, event: wEvent, index: int) =
  self.mInPanelMargin = false
  event.mWindow.setOverrideCursor(nil)

proc wSplitter_DoLeftDown(self: wSplitter, event: wEvent, index: int) =
  if index == 0 or self.mInPanelMargin:
    let event = Event(window=self, msg=wEvent_Splitter)
    if not self.processEvent(event) or event.isAllowed:
      event.mWindow.captureMouse()
      self.mDragging = true
      # Here can't just use getMousePos() because we need client pos relative to splitter.
      self.mPosOffset = self.screenToClient(event.getMouseScreenPos())

proc wSplitter_DoLeftUp(self: wSplitter, event: wEvent, index: int) =
  if self.mDragging:
    self.mDragging = false
    event.mWindow.releaseMouse()

proc clearEventHandle(self: wSplitter) =
  for tup in self.mConnections:
    tup.win.disconnect(tup.conn)

  for tup in self.mSystemConnections:
    tup.win.systemDisconnect(tup.conn)

  self.mConnections.setLen(0)
  self.mSystemConnections.setLen(0)

proc bindEventHandle(self: wSplitter, index: int) =
  var win: wWindow
  case index
  of 0: win = self
  of 1: win = self.mPanel1
  of 2: win = self.mPanel2
  else: return

  var conn: wEventConnection
  conn = win.systemConnect(wEvent_MouseMove) do (event: wEvent):
    wSplitter_DoMouseMove(self, event, index)
  self.mSystemConnections.add((win, conn))

  conn = win.systemConnect(wEvent_LeftDown) do (event: wEvent):
    wSplitter_DoLeftDown(self, event, index)
  self.mSystemConnections.add((win, conn))

  conn = win.systemConnect(wEvent_LeftUp) do (event: wEvent):
    wSplitter_DoLeftUp(self, event, index)
  self.mSystemConnections.add((win, conn))

  if index in 1..2:
    conn = win.systemConnect(wEvent_MouseLeave) do (event: wEvent):
      wSplitter_DoMouseLeave(self, event, index)
    self.mSystemConnections.add((win, conn))

proc reattach(self: wSplitter) =
  self.clearEventHandle()
  self.bindEventHandle(0)
  if self.mAttach1: self.bindEventHandle(1)
  if self.mAttach2: self.bindEventHandle(2)

proc isVertical*(self: wSplitter): bool {.validate, inline.} =
  ## Returns true if the splitter is vertical and false otherwise.
  result = self.mIsVertical

proc getPanel1*(self: wSplitter): wPanel {.validate, property, inline.} =
  ## Returns the left/top panel.
  result = self.mPanel1

proc getPanel2*(self: wSplitter): wPanel {.validate, property, inline.} =
  ## Returns the right/bottom panel.
  result = self.mPanel2

proc setMinPanelSize1*(self: wSplitter, min = 0) {.validate, property, inline.} =
  ## Sets the minimum size of left/top panel.
  self.mMin1 = min
  self.splitterResize()

proc setMinPanelSize2*(self: wSplitter, min = 0) {.validate, property, inline.} =
  ## Sets the minimum size of right/bottom panel.
  self.mMin2 = min
  self.splitterResize()

proc setMinPanelSize*(self: wSplitter, min = 0) {.validate, property, inline.} =
  ## Sets the minimum size of both panels.
  self.mMin1 = min
  self.mMin2 = min
  self.splitterResize()

proc setInvisible*(self: wSplitter) {.validate, property, inline.} =
  ## Sets the splitter should be invisible. The same as setSize(0, 0).
  self.setSize(0, 0)

proc setPanel1*(self: wSplitter, panel: wPanel): wPanel
    {.validate, property, discardable.} =
  ## This function replaces the left/top panel with another one.
  ## New panel's parent must the same as splitter's parent. Otherwise,
  ## the function failure. Returns the old panel or nil.
  if panel.mParent == self.mParent:
    result = self.mPanel1
    self.mPanel1 = panel
    self.reattach()

proc setPanel2*(self: wSplitter, panel: wPanel): wPanel
    {.validate, property, discardable.} =
  ## This function replaces the right/bottom panel with another one.
  ## New panel's parent must the same as splitter's parent. Otherwise,
  ## the function failure. Returns the old panel or nil.
  if panel.mParent == self.mParent:
    result = self.mPanel2
    self.mPanel2 = panel
    self.reattach()

proc swap*(self: wSplitter) {.validate.} =
  ## Swaps two panel.
  swap(self.mPanel1, self.mPanel2)
  swap(self.mAttach1, self.mAttach2)
  self.reattach()
  self.splitterResize()

proc attachPanel1*(self: wSplitter, attach = true) {.validate, inline.} =
  ## Attach the splitter to left/top panel so that users can drag the
  ## margin of the panel to resize it.
  self.mAttach1 = attach
  self.reattach()

proc attachPanel2*(self: wSplitter, attach = true) {.validate, inline.} =
  ## Attach the splitter to right/bottom panel so that users can drag the
  ## margin of the panel to resize it.
  self.mAttach2 = attach
  self.reattach()

proc attachPanel*(self: wSplitter, attach = true) {.validate, inline.} =
  ## Attach splitter to both panels.
  self.mAttach1 = attach
  self.mAttach2 = attach
  self.reattach()

proc setSplitMode*(self: wSplitter, mode: int) {.validate, property.} =
  ## Sets the split mode. Mode can be wSpHorizontal or wSpVertical.
  if mode in {wVertical, wSpVertical}:
    if not self.mIsVertical:
      self.mIsVertical = true
      self.splitterResize()
      self.splitterResetCursor()

  elif mode in {wHorizontal, wSpHorizontal}:
    if self.mIsVertical:
      self.mIsVertical = false
      self.splitterResize()
      self.splitterResetCursor()

proc wSplitter_DoPaint(event: wEvent) =
  let self = wBase.wSplitter event.mWindow
  if not self.mIsDrawButton:
    event.skip
    return

  let size = self.getClientSize()
  let bkColor = self.getBackgroundColor()

  var dc = PaintDC(self)
  defer: dc.delete()

  if self.isVertical():
    let dot = (size.width - 4).clamp(4, 8)
    let x = size.width div 2 - dot div 4
    let y = size.height div 2 - dot div 2 - dot

    for i in 0..3:
      dc.gradientFillConcentric((x, y + dot * i, dot, dot),
        wDarkGrey, bkColor, (0, 0))

  else:
    let dot = (size.height - 4).clamp(4, 8)
    let x = size.width div 2 - dot div 2 - dot
    let y = size.height div 2 - dot div 4

    for i in 0..3:
      dc.gradientFillConcentric((x + dot * i, y, dot, dot),
        wDarkGrey, bkColor, (0, 0))

wClass(wSplitter of wControl):

  method release*(self: wSplitter) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mSizeConn)
    self.clearEventHandle()
    free(self[])

  proc init*(self: wSplitter, parent: wWindow, id = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wSpVertical,
      className = "wSplitter") {.validate.} =
    ## Initializes a splitter. For vertical splitter, settings of y-axis are
    ## ignored, vice versa.
    wValidate(parent)
    self.mSize = 6
    self.mMin1 = 0
    self.mMin2 = 0
    self.mSystemConnections = @[]
    self.mConnections = @[]

    if (style and wSpHorizontal) == 0:
      self.mIsVertical = true
      if size.width != wDefault:
        self.mSize = size.width
    else:
      if size.height != wDefault:
        self.mSize = size.height

    if (style and wSpButton) != 0:
      self.mIsDrawButton = true

    self.wWindow.initVerbosely(parent=parent, id=id, style=style and wInvisible,
      className=className, bgColor=GetSysColor(COLOR_ACTIVEBORDER))

    var panelStyle = wInvisible
    if (style and wClipChildren) != 0: panelStyle = panelStyle or wClipChildren
    if (style and wDoubleBuffered) != 0: panelStyle = panelStyle or wDoubleBuffered
    self.mPanel1 = Panel(parent, style=panelStyle)
    self.mPanel2 = Panel(parent, style=panelStyle)

    self.splitterResize(pos)
    self.splitterResetCursor()

    if (style and wInvisible) == 0:
      self.show()
      self.mPanel1.show()
      self.mPanel2.show()

    self.bindEventHandle(0)

    self.mSizeConn = parent.systemConnect(wEvent_Size) do (event: wEvent):
      self.splitterResize()

    # handle this message so that setPosition() works to change
    # splitter's position.
    self.systemConnect(WM_WINDOWPOSCHANGED) do (event: wEvent):
      let winpos = cast[LPWINDOWPOS](event.mLparam)
      if not self.mResizing:
        self.mSize = if self.mIsVertical: winpos.cx else: winpos.cy
        self.splitterResize()

    self.systemConnect(wEvent_Paint, wSplitter_DoPaint)
