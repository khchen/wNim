## wSplitter control is used to split a window into two resizable panel.
## The panels size and position can be changed by users or by setSize()/setPosition()
## programmatically.
##
## A splitter can also attach to one or both panel so that the panel's margin
## become draggable. Of course it only works if the margin size near to the splitter
## is not zero.
##
## Notice: wSplitter turns on double buffering of the both panels by default to avoid flicker.
## However, a few controls don't suppoort it, for example, report view mode of wListCtrl.
## You muse turn off it if you want to use these controls.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wSpNoBorder                     No border (default).
##    wSpBorder                       Draws a standard border.
##    wSp3dBorder                     Draws a 3D effect border around splitter.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wMoveEvent                      Description
##    ==============================  =============================================================
##    wEvent_Splitter                 The position is dragging by user. This event can be vetoed.
##    ==============================  =============================================================

const
  # use the same define as wSpinButton
  # wSpHorizontal*
  # wSpVertical*
  wSpNoBorder* = 0
  wSpBorder* = wBorderSimple
  wSp3dBorder* = wBorderStatic

proc doSetSize(self: wWindow, rect: wRect) =
  if getRect() != rect:
    var isShown = isShownOnScreen()
    if isShown:
      SendMessage(mHwnd, WM_SETREDRAW, FALSE, 0)

    setSize(rect)

    if isShown:
      SendMessage(mHwnd, WM_SETREDRAW, TRUE, 0)
      RedrawWindow(mHwnd, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW)

proc splitterResize(self: wSplitter, pos = wDefaultPoint) =
  mResizing = true
  defer: mResizing = false

  proc countLimit(delta: var int, limit: int) =
    delta = delta.clamp(mMin1.clamp(0, limit), (limit + mSize - mMin2).clamp(0, limit))

  var clientSize = mParent.getClientSize()
  var pos = if pos == wDefaultPoint: getPosition() else: pos

  if mIsVertical:
    var limit = clientSize.width - mSize
    var delta = if pos.x == wDefault: limit div 2 else: pos.x
    delta.countLimit(limit)
    doSetSize((delta, 0, mSize, clientSize.height))
    mPanel1.doSetSize((0, 0, delta, clientSize.height))
    mPanel2.doSetSize((delta + mSize, 0, limit - delta, clientSize.height))
  else:
    var limit = clientSize.height - mSize
    var delta = if pos.y == wDefault: limit div 2 else: pos.y
    delta.countLimit(limit)
    doSetSize((0, delta, clientSize.width, mSize))
    mPanel1.doSetSize((0, 0, clientSize.width, delta))
    mPanel2.doSetSize((0, delta + mSize, clientSize.width, limit - delta))

proc splitterResetCursor(self: wSplitter) =
  if mIsVertical:
    setCursor(wSizeWeCursor)
  else:
    setCursor(wSizeNsCursor)

proc wSplitter_DoMouseMove(self: wSplitter, event: wEvent, index: int) =
  if mDragging:
    let event = Event(window=self, msg=wEvent_Splitter)
    if not self.processEvent(event) or event.isAllowed:
      var pos = mParent.screenToClient(event.getMouseScreenPos()) - mPosOffset
      self.splitterResize(pos)

  elif index > 0:
    let panel = event.window
    let pos = event.getMousePos()
    let size = panel.getClientSize()

    mInPanelMargin =
      if mIsVertical:
        if index == 1:
          pos.x > size.width
        else:
          pos.x < 0
      else:
        if index == 1:
          pos.y > size.height
        else:
          pos.y < 0

    if not isEnabled():
      mInPanelMargin = false

    if mInPanelMargin:
      panel.setOverrideCursor(if mIsVertical: wSizeWeCursor else: wSizeNsCursor)
    else:
      panel.setOverrideCursor(nil)

proc wSplitter_DoMouseLeave(self: wSplitter, event: wEvent, index: int) =
  mInPanelMargin = false
  event.window.setOverrideCursor(nil)

proc wSplitter_DoLeftDown(self: wSplitter, event: wEvent, index: int) =
  if index == 0 or mInPanelMargin:
    let event = Event(window=self, msg=wEvent_Splitter)
    if not self.processEvent(event) or event.isAllowed:
      event.window.captureMouse()
      mDragging = true
      # Here can't just use getMousePos() because we need client pos relative to splitter.
      mPosOffset = self.screenToClient(event.getMouseScreenPos())

proc wSplitter_DoLeftUp(self: wSplitter, event: wEvent, index: int) =
  if mDragging:
    mDragging = false
    event.window.releaseMouse()

proc clearEventHandle(self: wSplitter) =
  for tup in mConnections:
    tup.win.disconnect(tup.conn)

  for tup in mSystemConnections:
    tup.win.systemDisconnect(tup.conn)

  mConnections.setLen(0)
  mSystemConnections.setLen(0)

proc bindEventHandle(self: wSplitter, index: int) =
  var win: wWindow
  case index
  of 0: win = self
  of 1: win = mPanel1
  of 2: win = mPanel2
  else: return

  var conn: wEventConnection
  conn = win.systemConnect(wEvent_MouseMove) do (event: wEvent):
    wSplitter_DoMouseMove(self, event, index)
  mSystemConnections.add((win, conn))

  conn = win.systemConnect(wEvent_LeftDown) do (event: wEvent):
    wSplitter_DoLeftDown(self, event, index)
  mSystemConnections.add((win, conn))

  conn = win.systemConnect(wEvent_LeftUp) do (event: wEvent):
    wSplitter_DoLeftUp(self, event, index)
  mSystemConnections.add((win, conn))

  if index in 1..2:
    conn = win.systemConnect(wEvent_MouseLeave) do (event: wEvent):
      wSplitter_DoMouseLeave(self, event, index)
    mSystemConnections.add((win, conn))

proc reattach(self: wSplitter) =
  clearEventHandle()
  bindEventHandle(0)
  if mAttach1: bindEventHandle(1)
  if mAttach2: bindEventHandle(2)

proc getPanel1*(self: wSplitter): wPanel {.validate, property, inline.} =
  ## Returns the left/top panel.
  result = mPanel1

proc getPanel2*(self: wSplitter): wPanel {.validate, property, inline.} =
  ## Returns the right/bottom panel.
  result = mPanel2

proc setMinPanelSize1*(self: wSplitter, min = 0) {.validate, property, inline.} =
  ## Sets the minimum size of left/top panel.
  mMin1 = min
  splitterResize()

proc setMinPanelSize2*(self: wSplitter, min = 0) {.validate, property, inline.} =
  ## Sets the minimum size of right/bottom panel.
  mMin2 = min
  splitterResize()

proc setMinPanelSize*(self: wSplitter, min = 0) {.validate, property, inline.} =
  ## Sets the minimum size of both panels.
  mMin1 = min
  mMin2 = min
  splitterResize()

proc setInvisible*(self: wSplitter) {.validate, property, inline.} =
  ## Sets the splitter should be invisible. The same as setSize(0, 0).
  setSize(0, 0)

proc setPanel1*(self: wSplitter, panel: wPanel): wPanel {.validate, property, discardable.} =
  ## This function replaces the left/top panel with another one.
  ## New panel's parent must the same as splitter's parent. Otherwise, the function failure.
  ## Returns the old panel or nil.
  if panel.mParent == mParent:
    result = mPanel1
    mPanel1 = panel
    reattach()

proc setPanel2*(self: wSplitter, panel: wPanel): wPanel {.validate, property, discardable.} =
  ## This function replaces the right/bottom panel with another one.
  ## New panel's parent must the same as splitter's parent. Otherwise, the function failure.
  ## Returns the old panel or nil.
  if panel.mParent == mParent:
    result = mPanel2
    mPanel2 = panel
    reattach()

proc swap*(self: wSplitter) {.validate.} =
  ## Swaps two panel.
  swap(mPanel1, mPanel2)
  swap(mAttach1, mAttach2)
  reattach()
  splitterResize()

proc attachPanel1*(self: wSplitter, attach = true) {.validate, inline.} =
  ## Attach the splitter to left/top panel so that users can drag the
  ## margin of the panel to resize it.
  mAttach1 = attach
  reattach()

proc attachPanel2*(self: wSplitter, attach = true) {.validate, inline.} =
  ## Attach the splitter to right/bottom panel so that users can drag the
  ## margin of the panel to resize it.
  mAttach2 = attach
  reattach()

proc attachPanel*(self: wSplitter, attach = true) {.validate, inline.} =
  ## Attach splitter to both panels.
  mAttach1 = attach
  mAttach2 = attach
  reattach()

proc setSplitMode*(self: wSplitter, mode: int) {.validate, property, inline.} =
  ## Sets the split mode. Mode can be wSpHorizontal or wSpVertical.
  if mode in {wVertical, wSpVertical}:
    if not mIsVertical:
      mIsVertical = true
      splitterResize()
      splitterResetCursor()

  elif mode in {wHorizontal, wSpHorizontal}:
    if mIsVertical:
      mIsVertical = false
      splitterResize()
      splitterResetCursor()

proc final*(self: wSplitter) =
  ## Default finalizer for wSplitter.
  discard

proc init*(self: wSplitter, parent: wWindow, id = wDefaultID,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wSpVertical,
    className = "wSplitter") {.validate.} =

  wValidate(parent)
  mSize = 6
  mMin1 = 0
  mMin2 = 0
  mSystemConnections = @[]
  mConnections = @[]

  if (style and wSpHorizontal) == 0:
    mIsVertical = true
    if size.width != wDefault:
      mSize = size.width
  else:
    if size.height != wDefault:
      mSize = size.height

  self.wWindow.initVerbosely(parent=parent, id=id, style=style and wInvisible,
    className=className, bgColor=GetSysColor(COLOR_ACTIVEBORDER))

  mPanel1 = Panel(parent, style=wInvisible)
  mPanel2 = Panel(parent, style=wInvisible)
  splitterResize(pos)
  splitterResetCursor()

  # add dobule buffer to avoid flickering during resizing
  # however, listctrl not support, how to fix?
  mPanel1.setDoubleBuffered(true)
  mPanel2.setDoubleBuffered(true)

  if (style and wInvisible) == 0:
    show()
    mPanel1.show()
    mPanel2.show()

  bindEventHandle(0)

  parent.systemConnect(wEvent_Size) do (event: wEvent):
    self.splitterResize()

  # handle this message so that setPosition() works to change
  # splitter's position.
  systemConnect(WM_WINDOWPOSCHANGED) do (event: wEvent):
    let winpos = cast[LPWINDOWPOS](event.lParam)
    if not mResizing:
      mSize = if mIsVertical: winpos.cx else: winpos.cy
      self.splitterResize()

proc Splitter*(parent: wWindow, id = wDefaultID, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = wSpVertical,
    className = "wSplitter"): wSplitter {.inline, discardable.} =
  ## Constructor. For vertical splitter, settings of y-axis are ignored, vice versa.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, pos, size, style, className)
