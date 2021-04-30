#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This control shows a static text which links to one or more link.
## The label of this control can be marked-up text. For example:
## "<a href=\\"https\://github.com/khchen/wNim\\">click here</A> and
## <a id=\\"linkId\\">here</a>".
#
## :Appearance:
##   .. image:: images/wHyperlinkCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wHlAlignLeft                    Align the text to the left.
##   wHlAlignRight                   Align the text to the right.
##   ==============================  =============================================================
#
## :Events:
##   `wHyperlinkEvent <wHyperlinkEvent.html>`_

include ../pragma
import ../wBase, wControl
export wControl

const
  wHlAlignLeft* = 0
  wHlAlignRight* = LWS_RIGHT

method getBestSize*(self: wHyperlinkCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  var size: SIZE
  SendMessage(self.mHwnd, LM_GETIDEALSIZE, 0, &size)
  result.width = size.cx
  result.height = size.cy

method getDefaultSize*(self: wHyperlinkCtrl): wSize {.property, inline.} =
  ## Returns the default size for the control.
  result = self.getBestSize()

proc getItemCount*(self: wHyperlinkCtrl): int {.validate, property.} =
  ## Returns the number of items in the hyperlink control.
  # muse have LIF_STATE mask, otherwist the LM_GETITEM always return 0
  var item = LITEM(mask: LIF_ITEMINDEX or LIF_STATE, iLink: 0)
  while true:
    if SendMessage(self.mHwnd, LM_GETITEM, 0, &item) == 0: break
    item.iLink.inc
  result = item.iLink

proc len*(self: wHyperlinkCtrl): int {.validate, inline.} =
  ## Returns the number of items in the hyperlink control. The same as getItemCount().
  result = self.getItemCount()

proc getFocused*(self: wHyperlinkCtrl): int {.validate, property.} =
  ## Returns the index of current focused item.
  var item = LITEM(mask: LIF_ITEMINDEX or LIF_STATE, stateMask: LIS_FOCUSED)
  while true:
    if SendMessage(self.mHwnd, LM_GETITEM, 0, &item) == 0:
      return -1
    if (item.state and LIS_FOCUSED) != 0:
      return item.iLink
    item.iLink.inc

proc setFocused*(self: wHyperlinkCtrl, index: int) {.validate, property.} =
  ## Sets focused item.
  # must set focus after clear others, otherwise the setted focus will disappear
  var item = LITEM(
    mask: LIF_ITEMINDEX or LIF_STATE,
    stateMask: LIS_FOCUSED,
    state: 0,
    iLink: 0)

  while true:
    if SendMessage(self.mHwnd, LM_SETITEM, 0, &item) == 0: break
    item.iLink.inc

  item.iLink = index
  item.state = LIS_FOCUSED
  SendMessage(self.mHwnd, LM_SETITEM, 0, &item)

  # setfocus somehow clear the WS_TABSTOP style? add it back
  self.addWindowStyle(WS_TABSTOP)
  self.refresh()

proc getILink(self: wHyperlinkCtrl, index: int): int =
  # if index == -1: get focused item
  # if focused item == -1: get first item
  if index >= 0: result = index
  else: result = self.getFocused()
  if result < 0: result = 0

proc getItem(self: wHyperlinkCtrl, index = -1): LITEM =
  result.iLink = self.getILink(index)
  result.mask = LIF_ITEMINDEX or LIF_STATE or LIF_ITEMID or LIF_URL
  result.stateMask = LIS_FOCUSED or LIS_ENABLED or LIS_VISITED or LIS_HOTTRACK or LIS_DEFAULTCOLORS
  discard SendMessage(self.mHwnd, LM_GETITEM, 0, &result)

proc getUrl*(self: wHyperlinkCtrl, index = -1): string {.validate, property, inline.} =
  ## Returns the URL associated with the hyperlink.
  ## Index == -1 means the current focused item.
  var item = self.getItem(index)
  result = nullTerminated($$item.szUrl)

proc getLinkId*(self: wHyperlinkCtrl, index = -1): string {.validate, property, inline.} =
  ## Returns the link ID associated with the hyperlink.
  ## Index == -1 means the current focused item.
  var item = self.getItem(index)
  result = nullTerminated($$item.szID)

proc getVisited*(self: wHyperlinkCtrl, index = -1): bool {.validate, property, inline.} =
  ## Returns true if the hyperlink has already been clicked by the user at least one time.
  ## Index == -1 means the current focused item.
  var item = self.getItem(index)
  result = (item.state and LIS_VISITED) != 0

proc setUrl*(self: wHyperlinkCtrl, url: string, index = -1) {.validate, property.} =
  ## Sets the URL associated with the hyperlink.
  ## Index == -1 means the current focused item.
  var item = LITEM(iLink: self.getILink(index), mask: LIF_ITEMINDEX or LIF_URL)
  item.szUrl << +$url
  SendMessage(self.mHwnd, LM_SETITEM, 0, &item)

proc setLinkId*(self: wHyperlinkCtrl, linkId: string, index = -1) {.validate, property.} =
  ## Sets the link ID associated with the hyperlink.
  ## Index == -1 means the current focused item.
  var item = LITEM(iLink: self.getILink(index), mask: LIF_ITEMINDEX or LIF_ITEMID)
  item.szID << +$linkId
  SendMessage(self.mHwnd, LM_SETITEM, 0, &item)

proc setVisited*(self: wHyperlinkCtrl, flag = true, index = -1) {.validate, property.} =
  ## Marks the hyperlink as visited.
  ## Index == -1 means the current focused item.
  var item = LITEM(
    iLink: self.getILink(index),
    mask: LIF_ITEMINDEX or LIF_STATE,
    stateMask: LIS_VISITED,
    state: LIS_VISITED)
  SendMessage(self.mHwnd, LM_SETITEM, 0, &item)

method processNotify(self: wHyperlinkCtrl, code: INT, id: UINT_PTR,
    lParam: LPARAM, ret: var LRESULT): bool =

  if code == NM_CLICK or code == NM_RETURN:
    var event = wHyperlinkEvent Event(self, wEvent_Hyperlink, cast[WPARAM](id), lParam)
    event.mVisited = self.getVisited(event.getIndex())
    var processed = self.processEvent(event)
    self.setVisited(true, event.getIndex())
    return processed

  return procCall wControl(self).processNotify(code, id, lParam, ret)

wClass(wHyperlinkCtrl of wControl):

  method release*(self: wHyperlinkCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wHyperlinkCtrl, parent: wWindow, id = wDefaultID,
      label: string = "", pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = 0) {.validate.} =
    ## Initializes a hyperlink control.
    wValidate(parent)
    self.wControl.init(className=WC_LINK, parent=parent, id=id, label=label,
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      # use arrow key to navigate between links in control.
      var count = self.getItemCount()
      if count >= 2:
        var
          prevFocused = self.getFocused()
          focused = prevFocused

        if event.getKeyCode() in {wKey_Right, wKey_Down}:
          focused.inc
          if focused >= count: focused = 0

        elif event.getKeyCode() in {wKey_Left, wKey_Up}:
          focused.dec
          if focused < 0: focused = count - 1

        if prevFocused != focused:
          self.setFocused(focused)
          event.veto
