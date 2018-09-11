#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## A wNoteBook control manages multiple windows with associated tabs.
#
## :Appearance:
##   .. image:: images/wNoteBook.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wNbIconLeft                     Icons are aligned with the left edge.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_NoteBookPageChanged       The page selection was changed.
##   wEvent_NoteBookPageChanging      The page selection is about to be changed. This event can be vetoed.
##   ===============================  =============================================================

const
  wNbIconLeft* = TCS_FORCEICONLEFT

method getClientSize*(self: wNoteBook): wSize {.property.} =
  ## Returns the size of the notebook 'client area' in pixels.
  var r: RECT
  GetClientRect(mHwnd, r)
  SendMessage(mHwnd, TCM_ADJUSTRECT, false, &r)
  result.width = r.right - r.left - (mMargin.left + mMargin.right)
  result.height = r.bottom - r.top - (mMargin.up + mMargin.down)

method getClientAreaOrigin*(self: wNoteBook): wPoint {.property.} =
  ## Get the origin of the client area of the window relative to the window top left corner.
  result = (mMargin.left, mMargin.up)
  var r: RECT
  GetClientRect(mHwnd, r)
  SendMessage(mHwnd, TCM_ADJUSTRECT, false, &r)
  result.x += r.left
  result.y += r.top

proc getPageCount*(self: wNoteBook): int {.validate, property, inline.} =
  ## Returns the number of pages in the control.
  result = int SendMessage(mHwnd, TCM_GETITEMCOUNT, 0, 0)

proc len*(self: wNoteBook): int {.validate, inline.} =
  ## Returns the number of pages in the control.
  ## This shoud be equal to getPageCount() in most case.
  result = mPages.len

proc updateSelection(self: wNoteBook, n: Natural) =
  if mSelection != -1:
    mPages[mSelection].hide()

  mPages[n].show()
  mSelection = n
  SendMessage(mHwnd, TCM_SETCURSEL, n, 0)

proc adjustPageSize(self: wNoteBook) =
  let size = getClientSize()
  for page in mPages:
    page.setSize(0, 0, size.width, size.height)

proc getSelection*(self: wNoteBook): int {.validate, property, inline.} =
  ## Returns the currently selected page, or wNotFound if none was selected.
  result = int SendMessage(mHwnd, TCM_GETCURSEL, 0, 0)

proc insertPage*(self: wNoteBook, pos = -1, page: wPanel, text = "",
    select = false, image: wImage = nil, imageId: int = -1) {.validate.} =
  ## Inserts a page (wPanel object) at the specified position.
  ## Page's parent must be this control.
  ## Do not delete the page, it will be deleted by the wNoteBook control (if not removed).
  if page.mParent != self: return
  if page.isShownOnScreen(): page.hide()

  var
    pos = pos
    count = len()

  if pos < 0: pos = count
  elif pos > count: pos = count

  var tcitem = TCITEM(mask: TCIF_TEXT, pszText: T(text))
  if image != nil:
    tcitem.mask = tcitem.mask or TCIF_IMAGE
    tcitem.iImage = mImageList.add(image.scale(mImageList.getSize))
  elif imageId >= 0:
    tcitem.mask = tcitem.mask or TCIF_IMAGE
    tcitem.iImage = imageId

  SendMessage(mHwnd, TCM_INSERTITEM, pos, &tcitem)

  page.setBackgroundColor(mBackgroundColor)
  mPages.insert(page, pos)
  adjustPageSize()

  if pos <= mSelection:
    mSelection.inc

  if select or mSelection == -1:
    updateSelection(pos)

proc insertPage*(self: wNoteBook, pos = -1, text = "", select = false,
    image: wImage = nil, imageId: int = -1): wPanel {.validate, inline, discardable.} =
  ## Inserts a new page at the specified position. Return the new page (wPanel object).
  result = Panel(self, style=wInvisible)
  insertPage(pos=pos, page=result, text=text, select=select, image=image, imageId=imageId)

proc addPage*(self: wNoteBook, page: wPanel, text = "", select = false,
    image: wImage = nil, imageId: int = -1) {.validate, inline.} =
  ## Adds a page (wPanel object).
  ## Page's parent must be this control.
  ## Do not delete the page, it will be deleted by the wNoteBook control (if not removed).
  insertPage(page=page, text=text, select=select, image=image, imageId=imageId)

proc addPage*(self: wNoteBook, text = "", select = false,
    image: wImage = nil, imageId: int = -1): wPanel {.validate, inline, discardable.} =
  ## Adds a new page. Return the new page (wPanel object).
  result = insertPage(text=text, select=select, image=image, imageId=imageId)

proc getPageText*(self: wNoteBook, pos: int): string {.validate, property.} =
  ## Returns the string for the given page.
  if pos >= 0 and pos < mPages.len:
    var buffer = T(65536)
    var tcitem = TCITEM(mask: TCIF_TEXT, cchTextMax: 65536, pszText: &buffer)
    SendMessage(mHwnd, TCM_GETITEM, pos, &tcitem)
    buffer.nullTerminate
    result = $buffer

proc setPageText*(self: wNoteBook, pos: int, text: string) {.validate, property.} =
  ## Sets the text for the given page.
  if pos >= 0 and pos < mPages.len:
    var tcitem = TCITEM(mask: TCIF_TEXT, pszText: &T(text))
    SendMessage(mHwnd, TCM_SETITEM, pos, &tcItem)

proc changeSelection*(self: wNoteBook, pos: int) {.validate.} =
  ## Changes the selection to the given page.
  ## This function behaves as setSelection() but does not generate the page changing events.
  if pos >= 0 and pos < mPages.len:
    if mSelection == -1 or mSelection != pos:
      SendMessage(mHwnd, TCM_SETCURSEL, pos, 0)
      updateSelection(pos)

proc setSelection*(self: wNoteBook, pos: int): int {.validate, property, discardable.}  =
  ## Sets the selection to the given page.
  ## Notice that this function generates the page changing events,
  ## use the changeSelection() if you don't want these events to be generated.
  if pos >= 0 and pos < mPages.len:
    if mSelection == -1 or mSelection != pos:
      # let the user have a change to veto the changing action
      let event = Event(window=self, msg=wEvent_NoteBookPageChanging)
      if not self.processEvent(event) or event.isAllowed:
        changeSelection(pos)
        self.processMessage(wEvent_NoteBookPageChanged)

proc getCurrentPage*(self: wNoteBook): wPanel {.validate, property, inline.} =
  ## Returns the currently selected page or nil.
  if mSelection != -1:
    result = mPages[mSelection]

proc getPage*(self: wNoteBook, pos: int): wPanel {.validate, property, inline.} =
  ## Returns the page at the given position or nil.
  if pos >= 0 and pos < mPages.len:
    result = mPages[pos]

proc `[]`*(self: wNoteBook, pos: int): wPanel {.validate, inline.} =
  ## Returns the page at the given position.
  ## Raise error if index out of bounds.
  result = mPages[pos]

iterator items*(self: wNoteBook): wPanel {.validate.} =
  ## Iterate each page in this notebook control.
  for page in mPages:
    yield page

proc removePageImpl(self: wNoteBook, pos: int, delete = false): wPanel {.discardable.} =
  if pos >= 0 and pos < mPages.len:
    if delete:
      mPages[pos].delete()
    else:
      mPages[pos].hide()
      result = mPages[pos]

    mPages.delete(pos)
    SendMessage(mHwnd, TCM_DELETEITEM, pos, 0)

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

proc removeAllPagesImpl(self: wNoteBook, delete = false) =
  for page in mPages:
    if delete:
      page.delete()
    else:
      page.hide()

  mPages.setLen(0)
  SendMessage(mHwnd, TCM_DELETEALLITEMS, 0, 0)
  mSelection = -1

proc removePage*(self: wNoteBook, pos: int): wPanel {.validate, inline, discardable.} =
  ## Removes the specified page, without deleting the associated panel object.
  ## Returns the removed panel object.
  result = removePageImpl(pos, delete=false)

proc deletePage*(self: wNoteBook, pos: int) {.validate, inline.} =
  ## Deletes the specified page, and the associated window.
  removePageImpl(pos, delete=true)

proc removeAllPages*(self: wNoteBook) {.validate, inline.} =
  ## Removes all pages.
  removeAllPagesImpl(delete=false)

proc deleteAllPages*(self: wNoteBook) {.validate, inline.} =
  ## Deletes all pages.
  removeAllPagesImpl(delete=true)

proc setImageList*(self: wNoteBook, imageList: wImageList) {.validate, property, inline.} =
  ## Sets the image list to use. By default, wNoteBook handle it's owns imagelist.
  ## However, you can decide to use another image list if needed.
  ## Assign imageId in insertPage()/addPage() to set the image index.
  wValidate(imageList)
  mImageList = imageList
  SendMessage(mHwnd, TCM_SETIMAGELIST, 0, imageList.mHandle)

proc getImageList*(self: wNoteBook): wImageList {.validate, property, inline.} =
  ## Returns the associated image list.
  result = mImageList

proc setPageImage*(self: wNoteBook, pos: int, image: int) {.validate, property.} =
  ## Sets the image index for the given page.
  ## Notice that this should only use to change the image index.
  ## If the page don't have a image when creation, don't set image index for it.
  if pos >= 0 and pos < mPages.len:
    var tcitem = TCITEM(mask: TCIF_IMAGE, iImage: image)
    SendMessage(mHwnd, TCM_SETITEM, pos, &tcItem)

proc getPageImage*(self: wNoteBook, pos: int): int {.validate, property.} =
  ## Returns the image index for the given page.
  if pos >= 0 and pos < mPages.len:
    var tcitem = TCITEM(mask: TCIF_IMAGE)
    SendMessage(mHwnd, TCM_GETITEM, pos, &tcItem)
    result = tcitem.iImage

proc setPadding*(self: wNoteBook, size: wSize) {.validate, property, inline.} =
  ## Sets the amount of space around each page's icon and label, in pixels.
  SendMessage(mHwnd, TCM_SETPADDING, 0, MAKELPARAM(size.width, size.height))

proc focusNext(self: wNoteBook): bool =
  if mPages.len >= 1:
    var index = mSelection + 1
    if index >= mPages.len: index = 0
    setFocus()
    # MSDN: Changing the focus also changes the selected tab.
    # In this case, the tab control sends the TCN_SELCHANGING and TCN_SELCHANGE
    # notification codes to its parent window.
    SendMessage(mHwnd, TCM_SETCURFOCUS, index, 0)
    return true

proc focusPrev(self: wNoteBook): bool =
  if mPages.len >= 1:
    var index = mSelection - 1
    if index < 0: index = mPages.len - 1
    setFocus()
    SendMessage(mHwnd, TCM_SETCURFOCUS, index, 0)
    return true

method release(self: wNoteBook) =
  # Don't need to delete mImageList
  # let GC to delete it is ok.
  mImageList = nil
  for page in mPages:
    page.delete()

method processNotify(self: wNoteBook, code: INT, id: UINT_PTR, lParam: LPARAM, ret: var LRESULT): bool =
  case code
  of TCN_SELCHANGE:
    updateSelection(getSelection())
    return self.processMessage(wEvent_NoteBookPageChanged)

  of TCN_SELCHANGING:
    # It's no way to find the page which is going to be selected here.
    # So, no reason to add a wNoteBookEvent class to handle getOldSelection, getSelection etc.

    # Returns TRUE to prevent the selection from changing
    let event = Event(window=self, msg=wEvent_NoteBookPageChanging)
    var processed = self.processEvent(event)
    if processed and not event.isAllowed: ret = TRUE
    return processed

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

proc final*(self: wNoteBook) =
  ## Default finalizer for wNoteBook.
  discard

proc init*(self: wNoteBook, parent: wWindow, id = wDefaultID,
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) {.validate.} =
  ## Initializer.
  wValidate(parent)
  # don't allow TCS_MULTILINE -> too many windows system bug to hack away
  # don't allow TCS_BUTTONS style -> it have different behavior with normal style, it's hard to deal with
  var style = style and (not (TCS_BUTTONS or TCS_MULTILINE))

  self.wControl.init(className=WC_TABCONTROL, parent=parent, id=id, pos=pos, size=size,
    style=style or TCS_FOCUSONBUTTONDOWN or WS_CHILD or WS_VISIBLE or TCS_FIXEDWIDTH or WS_TABSTOP)

  mPages = newSeq[wPanel]()
  mSelection = -1

  mImageList = ImageList(GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON))
  SendMessage(mHwnd, TCM_SETIMAGELIST, 0, mImageList.mHandle)

  let bkColor = getThemeBackgroundColor(mHwnd)
  if bkColor != wDefaultColor:
    self.setBackgroundColor(bkColor)

  systemConnect(WM_SIZE) do (event: wEvent):
    self.adjustPageSize()

  hardConnect(WM_KEYDOWN) do (event: wEvent):
    # up and down to pass focus to child
    # We don't handle in wEvent_Navigation becasue
    # we want to block the event at all.
    var processed = false
    defer: event.skip(if processed: false else: true)

    proc trySetFocus(win: wWindow): bool =
      if win of wControl and win.isFocusable():
        win.setFocus()
        processed = true
        return true

    case event.keyCode
    of VK_DOWN:
      for win in mPages[mSelection].mChildren:
        if win.trySetFocus(): break

    of VK_UP:
      for i in countdown(mPages[mSelection].mChildren.len - 1, 0):
        let win = mPages[mSelection].mChildren[i]
        if win.trySetFocus(): break

    else: discard

  hardConnect(wEvent_Navigation) do (event: wEvent):
    # left and right to navigate between tabs, let system do that
    if event.keyCode in {wKey_Left, wKey_Right}:
      event.veto

proc NoteBook*(parent: wWindow, id = wDefaultID, pos = wDefaultPoint,
    size = wDefaultSize, style: wStyle = 0): wNoteBook {.inline, discardable.} =
  ## Constructs a notebook control.
  wValidate(parent)
  new(result, final)
  result.init(parent, id, pos, size, style)
