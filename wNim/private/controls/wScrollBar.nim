#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wScrollBar is a control that represents a horizontal or vertical scrollbar.
#
## :Appearance:
##   .. image:: images/wScrollBar.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wSbHorizontal                   Specifies a horizontal scrollbar.
##   wSbVertical                     Specifies a vertical scrollbar.
##   ==============================  =============================================================
#
## :Events:
##   `wScrollEvent <wScrollEvent.html>`_

include ../pragma
import ../wBase, wControl
export wControl

const
  # ScrollBar styles
  wSbHorizontal* = SBS_HORZ
  wSbVertical* = SBS_VERT

proc isVertical*(self: wScrollBar): bool {.validate, inline.} =
  ## Returns true for scrollbars that have the vertical style set.
  result = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and SBS_VERT) != 0

method getDefaultSize*(self: wScrollBar): wSize {.property.} =
  ## Returns the default size for the control.
  result = getAverageASCIILetterSize(self.mFont.mHandle, self.mHwnd)

  if self.isVertical():
    result.width = GetSystemMetrics(SM_CXVSCROLL)
    result.height = MulDiv(result.height, 107, 8)
  else:
    result.height = GetSystemMetrics(SM_CXHSCROLL)
    result.width = MulDiv(result.width, 107, 4)

method getBestSize*(self: wScrollBar): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = self.getDefaultSize()

proc setScrollbar*(self: wScrollBar, position: Natural, pageSize: Positive,
    range: Positive) {.validate, property.} =
  ## Sets the scrollbar properties.
  var info = SCROLLINFO(
    cbSize: sizeof(SCROLLINFO),
    fMask: SIF_POS or SIF_PAGE or SIF_RANGE,
    nPos: int32 position,
    nPage: int32 pageSize,
    nMin: 0,
    nMax: int32 range)
  SetScrollInfo(self.mHwnd, SB_CTL, &info, true) # true for redraw

proc setScrollPos*(self: wScrollBar, position: int) {.validate, property.} =
  ## Sets the position of the scrollbar.
  self.wWindow.setScrollPos(0, position)

proc getPageSize*(self: wScrollBar): int {.validate, property, inline.} =
  ## Returns the page size.
  let info = self.getScrollInfo()
  result = info.nPage

proc getRange*(self: wScrollBar): int {.validate, property, inline.} =
  ## Returns the length of the scrollbar.
  let info = self.getScrollInfo()
  result = info.nMax

proc getScrollPos*(self: wScrollBar): int {.validate, property, inline.} =
  ## Returns the current position of the scrollbar.
  let info = self.getScrollInfo()
  result = info.nPos

wClass(wScrollBar of wControl):

  method release*(self: wScrollBar) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mHScrollConn)
    self.mParent.systemDisconnect(self.mVScrollConn)
    free(self[])

  proc init*(self: wScrollBar, parent: wWindow, id = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) {.validate.} =
    ## Initializes a scrollbar.
    wValidate(parent)
    self.wControl.init(className=WC_SCROLLBAR, parent=parent, id=id, pos=pos,
      size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    self.setScrollbar(0, 1, 2)

    proc wScroll_DoScroll(event: wEvent) =
      var processed = false
      if event.mLparam == self.mHwnd:
        let orientation = if self.isVertical(): wVertical else: wHorizontal
        self.wScroll_DoScrollImpl(orientation, event.mWparam, isControl=true, processed)

    self.mHScrollConn = parent.systemConnect(WM_HSCROLL, wScroll_DoScroll)
    self.mVScrollConn = parent.systemConnect(WM_VSCROLL, wScroll_DoScroll)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if self.isVertical():
        if event.getKeyCode() in {wKey_Up, wKey_Down}:
          event.veto
      else:
        if event.getKeyCode() in {wKey_Right, wKey_Left}:
          event.veto
