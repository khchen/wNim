
const
  wHlAlignLeft* = 0
  wHlAlignRight* = LWS_RIGHT

method getBestSize*(self: wHyperLinkCtrl): wSize =
  var size: SIZE
  SendMessage(mHwnd, LM_GETIDEALSIZE, 0, addr size)
  result.width = size.cx.int
  result.height = size.cy.int

method getDefaultSize*(self: wHyperLinkCtrl): wSize =
  result = getBestSize()

proc indexFocused(self: wHyperLinkCtrl, index: int): int32 =
  # if index == -1: get focused item
  # if focused item == -1: get first item
  if index >= 0: result = index.int32
  elif mFocused >= 0: result = mFocused.int32

proc getItem(self: wHyperLinkCtrl, index = -1): LITEM =
  result.iLink = indexFocused(index)
  result.mask = LIF_ITEMINDEX or LIF_STATE or LIF_ITEMID or LIF_URL
  result.stateMask = LIS_FOCUSED or LIS_ENABLED or LIS_VISITED or LIS_HOTTRACK or LIS_DEFAULTCOLORS
  discard SendMessage(mHwnd, LM_GETITEM, 0, addr result)

proc getUrl*(self: wHyperLinkCtrl, index = -1): string =
  var item = getItem(index)
  result = $(nullTerminated(+$(item.szUrl)))

proc getLinkId*(self: wHyperLinkCtrl, index = -1): string =
  var item = getItem(index)
  result = $(nullTerminated(+$(item.szID)))

proc getVisited*(self: wHyperLinkCtrl, index = -1): bool =
  var item = getItem(index)
  result = (item.state and LIS_VISITED) != 0

proc setUrl*(self: wHyperLinkCtrl, url: string, index = -1) =
  var item: LITEM
  item.iLink = indexFocused(index)
  item.mask = LIF_ITEMINDEX or LIF_URL
  item.szUrl << +$url
  SendMessage(mHwnd, LM_SETITEM, 0, addr item)

proc setLinkId*(self: wHyperLinkCtrl, linkId: string, index = -1) =
  var item: LITEM
  item.iLink = indexFocused(index)
  item.mask = LIF_ITEMINDEX or LIF_ITEMID
  item.szID << +$linkId
  SendMessage(mHwnd, LM_SETITEM, 0, addr item)

proc setVisited*(self: wHyperLinkCtrl, flag = true, index = 0) =
  var item: LITEM
  item.iLink = indexFocused(index)
  item.mask = LIF_ITEMINDEX or LIF_STATE
  item.stateMask = LIS_VISITED
  item.state = LIS_VISITED
  SendMessage(mHwnd, LM_SETITEM, 0, addr item)

proc getItemCount*(self: wHyperLinkCtrl): int =
  var item: LITEM
  # muse at least get state or return null
  item.mask = LIF_ITEMINDEX or LIF_STATE
  result = 0
  while true:
    item.iLink = result.int32
    if SendMessage(mHwnd, LM_GETITEM, 0, addr item) == 0: break
    result.inc

proc setFocused*(self: wHyperLinkCtrl, index: int) =
  mFocused = index
  var item: LITEM
  var i = 0
  item.mask = LIF_ITEMINDEX or LIF_STATE
  item.stateMask = LIS_FOCUSED

  while true:
    item.state = if index == i: item.stateMask else: 0
    item.iLink = i.int32
    if SendMessage(mHwnd, LM_SETITEM, 0, addr item) == 0: break
    i.inc

proc getFocused*(self: wHyperLinkCtrl): int =
  result = mFocused

# todo: event rewite?

method processNotify(self: wHyperLinkCtrl, code: INT, id: UINT_PTR, lParam: LPARAM, ret: var LRESULT): bool =
  if code == NM_CLICK or code == NM_RETURN:
    let nml = cast[PNMLINK](lparam)
    mFocused = nml.item.iLink
    return self.processMessage(wEvent_HyperLink, cast[WPARAM](id), lparam)

  return procCall wControl(self).processNotify(code, id, lParam, ret)

proc init(self: wHyperLinkCtrl, parent: wWindow, id: wCommandID = -1, label: string = "", url = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  self.wControl.init(className=WC_LINK, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  if url != nil and url.len != 0:
    setUrl(url, 0)

  mFocused = 0

  # syslink control has some unexceptable weird behavior for default tab/shift+tab handle
  # handle them by ourself
  systemConnect(WM_SETFOCUS) do (event: wEvent):
    let prevWin = wAppWindowFindByHwnd(event.mWparam.HWND)
    if prevWin != nil and prevWin != self:
      let thisIndex = mParent.mChildren.find(self)
      let prevIndex = mParent.mChildren.find(prevWin)
      if prevIndex != -1 and thisIndex != -1:
        if thisIndex >= prevIndex:
          mFocused = 0
        else:
          mFocused = self.getItemCount() - 1

    if mFocused >= 0:
      self.setFocused(mFocused)

  # hardConnect(WM_CHAR) do (event: wEvent):
  #   var processed = false
  #   defer: event.skip(if processed: false else: true)

  #   let keyCode = event.mWparam
  #   case self.eatKey(keyCode, processed)
  #   of wUSE_TAB:
  #     if mFocused == self.getItemCount() - 1:
  #       mFocused = -1
  #       let control = self.tabStop(forward=true)
  #       if control != nil: control.setFocus()
  #     else:
  #       mFocused.inc
  #       self.setFocus()

  #   of wUSE_SHIFT_TAB:
  #     if mFocused == 0:
  #       mFocused = -1
  #       let control = self.tabStop(forward=false)
  #       if control != nil: control.setFocus()
  #     else:
  #       mFocused.dec
  #       self.setFocus()

  #   else: discard

  hardConnect(wEvent_Navigation) do (event: wEvent):
    if event.keyCode == wKey_Enter:
      event.veto

proc HyperLinkCtrl*(parent: wWindow, id: wCommandID = wDefaultID, label: string = "", url = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wHyperLinkCtrl {.discardable.} =
  new(result)
  result.init(parent=parent, id=id, label=label, url=url, pos=pos, size=size, style=style)
