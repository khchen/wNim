#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
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
##   wEvent_NoteBookPageChanging      The page selection is about to be changed. This event can be vetoed.
##   wEvent_NoteBookPageChanged       The page selection was changed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, ../wImageList, ../wImage, ../wPanel, ../dc/wPaintDC, wControl
export wControl

const
  wNbIconLeft* = TCS_FORCEICONLEFT

proc notebookPageOnPaint(event: wEvent) =
  let page = event.mWindow
  let self = wBase.wNoteBook page.mParent

  var clipRect, clientRect: RECT
  GetUpdateRect(page.mHwnd, clipRect, FALSE)
  GetClientRect(page.mHwnd, clientRect)

  var dc = PaintDC(page)
  DrawThemeBackground(self.mTheme, dc.mHdc, TABP_BODY, 0, clientRect, nil)
  dc.delete()

  # So that following event handler for wEvent_Paint can work.
  InvalidateRect(page.mHwnd, clipRect, FALSE)

method getClientSize*(self: wNoteBook): wSize {.property.} =
  ## Returns the size of the notebook 'client area' in pixels.
  var r: RECT
  GetClientRect(self.mHwnd, r)
  SendMessage(self.mHwnd, TCM_ADJUSTRECT, false, &r)
  result.width = r.right - r.left - (self.mMargin.left + self.mMargin.right)
  result.height = r.bottom - r.top - (self.mMargin.up + self.mMargin.down)

method getClientAreaOrigin*(self: wNoteBook): wPoint {.property.} =
  ## Get the origin of the client area of the window relative to the window top
  ## left corner.
  result = (self.mMargin.left, self.mMargin.up)
  var r: RECT
  GetClientRect(self.mHwnd, r)
  SendMessage(self.mHwnd, TCM_ADJUSTRECT, false, &r)
  result.x += r.left
  result.y += r.top

proc getPageCount*(self: wNoteBook): int {.validate, property, inline.} =
  ## Returns the number of pages in the control.
  result = int SendMessage(self.mHwnd, TCM_GETITEMCOUNT, 0, 0)

proc len*(self: wNoteBook): int {.validate, inline.} =
  ## Returns the number of pages in the control.
  ## This shoud be equal to getPageCount() in most case.
  result = self.mPages.len

proc updateSelection(self: wNoteBook, n: Natural) =
  if self.mSelection != -1:
    self.mPages[self.mSelection].hide()

  self.mPages[n].show()
  self.mSelection = n
  SendMessage(self.mHwnd, TCM_SETCURSEL, n, 0)

proc adjustPageSize(self: wNoteBook) =
  let size = self.getClientSize()
  for page in self.mPages:
    page.setSize(0, 0, size.width, size.height)

proc getSelection*(self: wNoteBook): int {.validate, property, inline.} =
  ## Returns the currently selected page, or wNotFound if none was selected.
  result = int SendMessage(self.mHwnd, TCM_GETCURSEL, 0, 0)

proc insertPage*(self: wNoteBook, pos = -1, page: wPanel, text = "",
    select = false, image: wImage = nil, imageId: int = -1) {.validate.} =
  ## Inserts a page (wPanel object) at the specified position.
  ## Page's parent must be this control.
  ## Do not delete the page, it will be deleted by the wNoteBook control
  ## (if not removed).
  if page.mParent != self: return
  if page.isShownOnScreen(): page.hide()

  var
    pos = pos
    count = self.len()

  if pos < 0: pos = count
  elif pos > count: pos = count

  var tcitem = TCITEM(mask: TCIF_TEXT, pszText: T(text))
  if image != nil:
    tcitem.mask = tcitem.mask or TCIF_IMAGE
    tcitem.iImage = self.mImageList.add(image.scale(self.mImageList.getSize))
  elif imageId >= 0:
    tcitem.mask = tcitem.mask or TCIF_IMAGE
    tcitem.iImage = imageId

  SendMessage(self.mHwnd, TCM_INSERTITEM, pos, &tcitem)

  page.setBackgroundColor(self.mBackgroundColor)
  self.mPages.insert(page, pos)
  self.adjustPageSize()

  if pos <= self.mSelection:
    self.mSelection.inc

  if select or self.mSelection == -1:
    self.updateSelection(pos)

  if wUsingTheme() and self.mTheme != 0:
    page.systemConnect(wEvent_Paint, notebookPageOnPaint)

proc insertPage*(self: wNoteBook, pos = -1, text = "", select = false,
    image: wImage = nil, imageId: int = -1): wPanel
    {.validate, inline, discardable.} =
  ## Inserts a new page at the specified position. Return the new page
  ## (wPanel object).
  result = Panel(self, style=wInvisible)
  self.insertPage(pos=pos, page=result, text=text, select=select, image=image,
    imageId=imageId)

proc addPage*(self: wNoteBook, page: wPanel, text = "", select = false,
    image: wImage = nil, imageId: int = -1) {.validate, inline.} =
  ## Adds a page (wPanel object).
  ## Page's parent must be this control.
  ## Do not delete the page, it will be deleted by the wNoteBook control
  ## (if not removed).
  self.insertPage(page=page, text=text, select=select, image=image, imageId=imageId)

proc addPage*(self: wNoteBook, text = "", select = false,
    image: wImage = nil, imageId: int = -1): wPanel
    {.validate, inline, discardable.} =
  ## Adds a new page. Return the new page (wPanel object).
  result = self.insertPage(text=text, select=select, image=image, imageId=imageId)

proc getPageText*(self: wNoteBook, pos: int): string {.validate, property.} =
  ## Returns the string for the given page.
  if pos >= 0 and pos < self.mPages.len:
    var buffer = T(65536)
    var tcitem = TCITEM(mask: TCIF_TEXT, cchTextMax: 65536, pszText: &buffer)
    SendMessage(self.mHwnd, TCM_GETITEM, pos, &tcitem)
    buffer.nullTerminate
    result = $buffer

proc setPageText*(self: wNoteBook, pos: int, text: string) {.validate, property.} =
  ## Sets the text for the given page.
  if pos >= 0 and pos < self.mPages.len:
    var tcitem = TCITEM(mask: TCIF_TEXT, pszText: &T(text))
    SendMessage(self.mHwnd, TCM_SETITEM, pos, &tcItem)

proc changeSelection*(self: wNoteBook, pos: int) {.validate.} =
  ## Changes the selection to the given page.
  ## This function behaves as setSelection() but does not generate the page
  ## changing events.
  if pos >= 0 and pos < self.mPages.len:
    if self.mSelection == -1 or self.mSelection != pos:
      SendMessage(self.mHwnd, TCM_SETCURSEL, pos, 0)
      self.updateSelection(pos)

proc setSelection*(self: wNoteBook, pos: int): int
    {.validate, property, discardable.}  =
  ## Sets the selection to the given page.
  ## Notice that this function generates the page changing events,
  ## use the changeSelection() if you don't want these events to be generated.
  if pos >= 0 and pos < self.mPages.len:
    if self.mSelection == -1 or self.mSelection != pos:
      # let the user have a change to veto the changing action
      let event = Event(window=self, msg=wEvent_NoteBookPageChanging)
      if not self.processEvent(event) or event.isAllowed:
        self.changeSelection(pos)
        self.processMessage(wEvent_NoteBookPageChanged)

proc getCurrentPage*(self: wNoteBook): wPanel {.validate, property, inline.} =
  ## Returns the currently selected page or nil.
  if self.mSelection != -1:
    result = self.mPages[self.mSelection]

proc getPage*(self: wNoteBook, pos: int): wPanel {.validate, property, inline.} =
  ## Returns the page at the given position or nil.
  if pos >= 0 and pos < self.mPages.len:
    result = self.mPages[pos]

proc `[]`*(self: wNoteBook, pos: int): wPanel {.validate, inline.} =
  ## Returns the page at the given position.
  ## Raise error if index out of bounds.
  result = self.mPages[pos]

iterator items*(self: wNoteBook): wPanel {.validate.} =
  ## Iterate each page in this notebook control.
  for page in self.mPages:
    yield page

proc removePageImpl(self: wNoteBook, pos: int, delete = false): wPanel
    {.discardable.} =

  if pos >= 0 and pos < self.mPages.len:
    if delete:
      self.mPages[pos].delete()
    else:
      self.mPages[pos].hide()
      self.mPages[pos].systemDisconnect(wEvent_Paint, notebookPageOnPaint)
      result = self.mPages[pos]

    self.mPages.delete(pos)
    SendMessage(self.mHwnd, TCM_DELETEITEM, pos, 0)

    if self.mPages.len == 0:
      self.mSelection = -1

    else:
      var newSel = self.getSelection()
      if newSel != -1:
        self.mSelection = newSel
        self.mPages[self.mSelection].refresh()

      else: # selected page was deleted
        newSel = self.mSelection
        if newSel == self.mPages.len: newSel.dec

        self.mSelection = -1 # make sure setSelection do something
        self.setSelection(newSel)

proc removeAllPagesImpl(self: wNoteBook, delete = false) =
  for page in self.mPages:
    if delete:
      page.delete()
    else:
      page.hide()
      page.systemDisconnect(wEvent_Paint, notebookPageOnPaint)

  self.mPages.setLen(0)
  SendMessage(self.mHwnd, TCM_DELETEALLITEMS, 0, 0)
  self.mSelection = -1

proc removePage*(self: wNoteBook, pos: int): wPanel
    {.validate, inline, discardable.} =
  ## Removes the specified page, without deleting the associated panel object.
  ## Returns the removed panel object.
  result = self.removePageImpl(pos, delete=false)

proc deletePage*(self: wNoteBook, pos: int) {.validate, inline.} =
  ## Deletes the specified page, and the associated window.
  self.removePageImpl(pos, delete=true)

proc removeAllPages*(self: wNoteBook) {.validate, inline.} =
  ## Removes all pages.
  self.removeAllPagesImpl(delete=false)

proc deleteAllPages*(self: wNoteBook) {.validate, inline.} =
  ## Deletes all pages.
  self.removeAllPagesImpl(delete=true)

proc setImageList*(self: wNoteBook, imageList: wImageList)
    {.validate, property, inline.} =
  ## Sets the image list to use. By default, wNoteBook handle it's owns imagelist.
  ## However, you can decide to use another image list if needed.
  ## Assign imageId in insertPage()/addPage() to set the image index.
  wValidate(imageList)
  self.mImageList = imageList
  SendMessage(self.mHwnd, TCM_SETIMAGELIST, 0, imageList.mHandle)

proc getImageList*(self: wNoteBook): wImageList {.validate, property, inline.} =
  ## Returns the associated image list.
  result = self.mImageList

proc setPageImage*(self: wNoteBook, pos: int, image: int) {.validate, property.} =
  ## Sets the image index for the given page.
  ## Notice that this should only use to change the image index.
  ## If the page don't have a image when creation, don't set image index for it.
  if pos >= 0 and pos < self.mPages.len:
    var tcitem = TCITEM(mask: TCIF_IMAGE, iImage: image)
    SendMessage(self.mHwnd, TCM_SETITEM, pos, &tcItem)

proc getPageImage*(self: wNoteBook, pos: int): int {.validate, property.} =
  ## Returns the image index for the given page.
  if pos >= 0 and pos < self.mPages.len:
    var tcitem = TCITEM(mask: TCIF_IMAGE)
    SendMessage(self.mHwnd, TCM_GETITEM, pos, &tcItem)
    result = tcitem.iImage

proc setPadding*(self: wNoteBook, size: wSize) {.validate, property, inline.} =
  ## Sets the amount of space around each page's icon and label, in pixels.
  SendMessage(self.mHwnd, TCM_SETPADDING, 0, MAKELPARAM(size.width, size.height))

method processNotify(self: wNoteBook, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code
  of TCN_SELCHANGE:
    self.updateSelection(self.getSelection())
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

wClass(wNoteBook of wControl):

  method release*(self: wNoteBook) =
    ## Release all the resources during destroying. Used internally.
    for page in self.mPages:
      page.delete()

    if self.mTheme != 0:
      CloseThemeData(self.mTheme)
      self.mTheme = 0

    free(self[])

  proc init*(self: wNoteBook, parent: wWindow, id = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) {.validate.} =
    ## Initializes a notebook control.
    wValidate(parent)
    # don't allow TCS_MULTILINE -> too many windows system bug to hack away
    # don't allow TCS_BUTTONS style -> it have different behavior with normal style, it's hard to deal with
    var style = style and (not (TCS_BUTTONS or TCS_MULTILINE))

    self.wControl.init(className=WC_TABCONTROL, parent=parent, id=id, pos=pos,
      size=size, style=style or TCS_FOCUSONBUTTONDOWN or WS_CHILD or WS_VISIBLE or
      TCS_FIXEDWIDTH or WS_TABSTOP)

    self.mPages = newSeq[wBase.wPanel]()
    self.mSelection = -1

    self.mImageList = ImageList(GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON))
    SendMessage(self.mHwnd, TCM_SETIMAGELIST, 0, self.mImageList.mHandle)

    self.setBackgroundColor(GetSysColor(COLOR_BTNFACE))
    if wUsingTheme():
      self.mTheme = OpenThemeData(self.mHwnd, "TAB")

    self.systemConnect(WM_SIZE) do (event: wEvent):
      self.adjustPageSize()

    self.hardConnect(WM_KEYDOWN) do (event: wEvent):
      # up and down to pass focus to child
      # We don't handle in wEvent_Navigation becasue
      # we want to block the event at all.
      var processed = false
      defer: event.skip(if processed: false else: true)

      proc trySetFocus(win: wWindow): bool =
        if win of wBase.wControl and win.isFocusable():
          win.setFocus()
          processed = true
          return true

      case event.getKeyCode()
      of VK_DOWN:
        for win in self.mPages[self.mSelection].mChildren:
          if win.trySetFocus(): break

      of VK_UP:
        for i in countdown(self.mPages[self.mSelection].mChildren.len - 1, 0):
          let win = self.mPages[self.mSelection].mChildren[i]
          if win.trySetFocus(): break

      else: discard

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      # left and right to navigate between tabs, let system do that
      if event.getKeyCode() in {wKey_Left, wKey_Right}:
        event.veto
