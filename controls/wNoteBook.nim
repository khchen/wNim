method getClientSize*(self: wNoteBook): wSize =
  var r: RECT
  GetClientRect(mHwnd, r)
  SendMessage(mHwnd, TCM_ADJUSTRECT, false, addr r)
  result.width = r.right - r.left - mMarginX * 2
  result.height = r.bottom - r.top - mMarginY * 2

method getClientAreaOrigin*(self: wNoteBook): wPoint =
  result.x = mMarginX
  result.y = mMarginY

  var r: RECT
  GetClientRect(mHwnd, r)
  SendMessage(mHwnd, TCM_ADJUSTRECT, false, addr r)
  result.x += r.left.int
  result.y += r.top.int

proc updateSelection(self: wNoteBook, n: int) =
  assert n < mPages.len

  if mSelection != -1:
    mPages[mSelection].hide()

  mPages[n].show()
  mSelection = n
  SendMessage(mHwnd, TCM_SETCURSEL, n, 0)

proc adjustPageSize(self: wNoteBook) =
  let size = getClientSize()

  for i, page in mPages:
    page.setSize(0, 0, size.width, size.height)

proc getSelection*(self: wNoteBook): int =
  result = SendMessage(mHwnd, TCM_GETCURSEL, 0, 0).int

proc insertPage*(self: wNoteBook, n: int, page: wWindow = nil, text = "", isSelect = false) =
  var page = page
  if page == nil: page = Panel(self)

  assert page.mParent == self
  doassert n >= 0 and n <= mPages.len

  page.setBackgroundColor(mBackgroundColor)

  var tcitem: TCITEM
  tcitem.mask = TCIF_TEXT
  tcitem.pszText = T(text)
  SendMessage(mHwnd, TCM_INSERTITEM, n, addr tcitem)

  mPages.insert(page, n)
  page.hide()

  adjustPageSize()

  if n <= mSelection:
    mSelection.inc

  if isSelect or mSelection == -1:
    updateSelection(n)

proc addPage*(self: wNoteBook, page: wWindow = nil, text = "", isSelect = false) =
  let count = SendMessage(mHwnd, TCM_GETITEMCOUNT, 0, 0).int
  insertPage(count, page, text, isSelect)

proc getPageCount*(self: wNoteBook): int =
  # assert mPages.len == SendMessage(mHwnd, TCM_GETITEMCOUNT, 0, 0).int
  result = mPages.len

proc getPageText*(self: wNoteBook, n: int): string =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  var
    buffer = T(65536)
  #   pbuffer = allocWString(65536)
  #   buffer = cast[wstring](pbuffer)
  # defer: dealloc(pbuffer)

  var tcitem: TCITEM
  tcitem.mask = TCIF_TEXT
  tcitem.cchTextMax = 65536
  tcitem.pszText = &buffer
  SendMessage(mHwnd, TCM_GETITEM, n, addr tcitem)

  # buffer.setLen(lstrlen(&buffer))
  buffer.nullTerminate
  result = $buffer

proc setPageText*(self: wNoteBook, n: int, text: string) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  var tcitem: TCITEM
  tcitem.mask = TCIF_TEXT
  tcitem.pszText = &(T(text))
  SendMessage(mHwnd, TCM_SETITEM, n, addr tcItem)

# event generated
proc setSelection*(self: wNoteBook, n: int) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  if mSelection == -1 or mSelection != n:
    let id = getId()
    var ret: LRESULT
    var processed = self.processMessage(wEvent_NoteBookPageChanging, cast[WPARAM](id), 0, ret)

    # FALSE to allow the selection to change
    if not processed or ret == 0:
      SendMessage(mHwnd, TCM_SETCURSEL, n, 0)
      updateSelection(n)
      self.processMessage(wEvent_NoteBookPageChanged, cast[WPARAM](id), 0)

# no evnet generated
proc changeSelection*(self: wNoteBook, n: int) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  if mSelection == -1 or mSelection != n:
    SendMessage(mHwnd, TCM_SETCURSEL, n, 0)
    updateSelection(n)

proc getCurrentPage*(self: wNoteBook): wWindow =
  if mSelection != -1:
    result = mPages[mSelection]

proc getPage*(self: wNoteBook, n: int): wWindow =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  result = mPages[n]

proc removePage*(self: wNoteBook, n: int, delete = false) =
  if n >= mPages.len:
    raise newException(IndexError, "index out of bounds")

  mPages[n].hide()
  if delete: mPages[n].delete()
  mPages.delete(n)
  SendMessage(mHwnd, TCM_DELETEITEM, n, 0)

  if mPages.len == 0:
    mSelection = -1

  else:
    var newSel = getSelection()
    if newSel != -1:
      mSelection = newSel
      mPages[mSelection].refresh()

    else: # selected page was deleted
      newSel = mSelection
      if newSel == mPages.len: newSel.dec

      mSelection = -1 # make sure setSelection do something
      setSelection(newSel)

proc deletePage*(self: wNoteBook, n: int) =
  removePage(n, delete=true)

proc removeAllPages*(self: wNoteBook, delete = false) =
  for page in mPages:
    page.hide()
    if delete: page.delete()

  mPages.setLen(0)
  SendMessage(mHwnd, TCM_DELETEALLITEMS, 0, 0)
  mSelection = -1

proc deleteAllPages*(self: wNoteBook) =
  removeAllPages(delete=true)

proc setFocusAt(self: wNoteBook, index: int) =
  setSelection(index)
  setFocus()
  SendMessage(mHwnd, TCM_SETCURFOCUS, index, 0)

proc focusNext(self: wNoteBook): bool =
  if mPages.len >= 0:
    var index = mSelection + 1
    if index >= mPages.len: index = 0
    setFocusAt(index)
    return true

proc focusPrev(self: wNoteBook): bool =
  if mPages.len >= 0:
    var index = mSelection - 1
    if index < 0: index = mPages.len - 1
    setFocusAt(index)
    return true

method processNotify(self: wNoteBook, code: INT, id: UINT_PTR, lParam: LPARAM, ret: var LRESULT): bool =
  var eventKind: UINT
  case code
  of TCN_SELCHANGE:
    updateSelection(getSelection())
    return self.processMessage(wEvent_NoteBookPageChanged, cast[WPARAM](id), lparam)

  of TCN_SELCHANGING:
    return self.processMessage(wEvent_NoteBookPageChanging, cast[WPARAM](id), lparam)

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

proc init(self: wNoteBook, parent: wWindow, id: wCommandID = -1, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  # don't allow TCS_MULTILINE -> too many windows system bug to hack away
  self.wControl.init(className=WC_TABCONTROL, parent=parent, id=id, label=label,
    pos=pos, size=size, style=style or TCS_FOCUSONBUTTONDOWN or WS_CHILD or
    WS_VISIBLE or TCS_FIXEDWIDTH or WS_TABSTOP)

  mPages = newSeq[wWindow]()
  mSelection = -1

  let bkColor = getThemeBackgroundColor(mHwnd)
  if bkColor != wDefaultColor:
    self.setBackgroundColor(bkColor)

  systemConnect(WM_SIZE) do (event: wEvent):
    self.adjustPageSize()


  hardConnect(WM_KEYDOWN) do (event: wEvent):
    var processed = false
    defer: event.skip(if processed: false else: true)
    case event.keyCode
    # up and down to pass focus to child
    # We don't handle in wEvent_Navigation becasue
    # we want to block the event at all.
    of VK_DOWN:
      for win in mPages[mSelection].mChildren:
        if win of wControl and win.isFocusable():
          win.setFocus()
          processed = true
          break

    of VK_UP:
      for i in countdown(mPages[mSelection].mChildren.len - 1, 0):
        let win = mPages[mSelection].mChildren[i]
        if win of wControl and win.isFocusable():
          win.setFocus()
          processed = true
          break

    else: discard

  hardConnect(wEvent_Navigation) do (event: wEvent):
    # left and right to navigate between tabs, let system do that
    if event.keyCode in {wKey_Left, wKey_Right}:
      event.veto

    # ctrl+tab in wNoteBook self also navigate between tabs
    if event.ctrlDown and event.keyCode == VK_TAB:
      if event.shiftDown:
        if self.focusPrev():
          event.veto
      else:
        if self.focusNext():
          event.veto

proc NoteBook*(parent: wWindow, id: wCommandID = wDefaultID, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0): wNoteBook {.discardable.} =

  new(result)
  result.init(parent=parent, id=id, label=label, pos=pos, size=size, style=style)
