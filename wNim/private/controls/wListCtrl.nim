#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A list control presents lists in a number of formats: list view, report view,
## icon view and small icon view.
#
## :Appearance:
##   .. image:: images/wListCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wLcList                         Multicolumn list view.
##   wLcReport                       Single or multicolumn report view, with optional header.
##   wLcIcon                         Large icon view, with optional labels.
##   wLcSmallIcon                    Small icon view, with optional labels.
##   wLcAlignTop                     Icons align to the top. Win32 default, Win32 only.
##   wLcAlignLeft                    Icons align to the left.
##   wLcAutoArrange                  Icons arrange themselves. Win32 only.
##   wLcNoSortHeader                 Column headers do not work like buttons.
##   wLcNoHeader                     No header in report mode.
##   wLcEditLabels                   Labels are editable.
##   wLcSingleSel                    Single selection (default is multiple).
##   wLcSortAscending                Sort in ascending order.
##   wLcSortDescending               Sort in descending order.
##   ==============================  =============================================================
#
## :Events:
##   `wListEvent <wListEvent.html>`_

include ../pragma
import ../wBase, wControl, wTextCtrl
export wControl, wTextCtrl

const
  # ListCtrl styles
  wLcList* = LVS_LIST
  wLcReport* = LVS_REPORT
  wLcIcon* = LVS_ICON
  wLcSmallIcon* = LVS_SMALLICON
  wLcAlignTop* = LVS_ALIGNTOP
  wLcAlignLeft* = LVS_ALIGNLEFT
  wLcAutoArrange* = LVS_AUTOARRANGE
  wLcNoSortHeader* = LVS_NOSORTHEADER
  wLcNoHeader* = LVS_NOCOLUMNHEADER
  wLcEditLabels* = LVS_EDITLABELS
  wLcSingleSel* = LVS_SINGLESEL
  wLcSortAscending* = LVS_SORTASCENDING
  wLcSortDescending* = LVS_SORTDESCENDING
  # Image and size
  wListImageCallback* = I_IMAGECALLBACK # -1
  wListImageNone* = I_IMAGENONE # -2
  wListAutosize* = LVSCW_AUTOSIZE # -1
  wListAutosizeUseHeader* = LVSCW_AUTOSIZE_USEHEADER # -2
  wListIgnore* = -3
  # Imagelist styles and consts
  wImageListNormal* = LVSIL_NORMAL
  wImageListSmall* = LVSIL_SMALL
  wImageListState* = LVSIL_STATE
  # Column format
  wListFormatLeft* = LVCFMT_LEFT
  wListFormatRight* = LVCFMT_RIGHT
  wListFormatCenter* = LVCFMT_CENTER
  # list states
  wListStateFocused* = LVIS_FOCUSED
  wListStateSelected* = LVIS_SELECTED
  wListStateDropHighlighted* = LVIS_DROPHILITED
  wListStateCut* = LVIS_CUT
  # code for getItemRect()
  wListRectBounds* = LVIR_BOUNDS
  wListRectIcon* = LVIR_ICON
  wListRectLabel* = LVIR_LABEL
  wListRectSelectBounds* = LVIR_SELECTBOUNDS
  # Hit test flags
  wListHittestAbove* = LVHT_ABOVE
  wListHittestBelow* = LVHT_BELOW
  wListHittestToLeft* = LVHT_TOLEFT
  wListHittestToRight* = LVHT_TORIGHT
  wListHittestNoWhere* = LVHT_NOWHERE
  wListHittestOnItemLabel* = LVHT_ONITEMLABEL
  wListHittestOnItemIcon* = LVHT_ONITEMICON
  wListHittestOnItemStateIcon* = LVHT_ONITEMSTATEICON
  # Arrange flags
  wListAlignDefault* = LVA_DEFAULT
  wListAlignLeft* = LVA_ALIGNLEFT
  wListAlignTop* = LVA_ALIGNTOP
  wListAlignSnapToGrid* = LVA_SNAPTOGRID
  # getNextItem geometry and state
  wListNextAll* = LVNI_ALL
  wListNextPrevious* = LVNI_PREVIOUS
  wListNextAbove* = LVNI_ABOVE
  wListNextBelow* = LVNI_BELOW
  wListNextLeft* = LVNI_TOLEFT
  wListNextRight* = LVNI_TORIGHT
  wListStateDontCare* = 0
  # Because LVNIXXX equal to LVISXXX, here is safe to use the same const value
  # wListStateDropHilited* = LVNI_DROPHILITED = LVIS_DROPHILITED
  # wListStateFocused* = LVNI_FOCUSED = LVIS_FOCUSED
  # wListStateSelected* = LVNI_SELECTED = LVIS_SELECTED
  # wListStateCut* = LVNI_CUT = LVIS_CUT

proc setColumnWidth*(self: wListCtrl, col: int, width: int)
    {.validate, property.} =
  ## Sets the column width.
  ## *width* can be a width in pixels or wListAutosize (-1)
  ## or wListAutosizeUseHeader (-2).
  ## For wLcList mode, col must be set to 0.
  SendMessage(self.mHwnd, LVM_SETCOLUMNWIDTH, col, width)

proc insertColumn*(self: wListCtrl, col: int, text = "",
    format = wListFormatLeft, width = wListAutosize,
    image = wListImageNone): int {.validate, discardable.} =
  ## For report view mode (only), inserts a column.
  ## Notice that in case of wListAutosize fixed width is used as there are no
  ## items in this column to use for determining its best size yet.
  ## If you want to fit the column to its contents, use setColumnWidth() after
  ## adding the items with values in this column.
  var lvcol = LVCOLUMN(
    mask: LVCF_FMT or LVCF_WIDTH or LVCF_IMAGE,
    iImage: image,
    fmt: format,
    cx: if width < 0: 80 else: width)

  if text.len != 0:
    lvcol.mask = lvcol.mask or LVCF_TEXT
    lvcol.pszText = &T(text)

  result = int SendMessage(self.mHwnd, LVM_INSERTCOLUMN, col, &lvcol)
  if result != -1:
    self.mColCount.inc

    if width == wListAutosizeUseHeader:
      self.setColumnWidth(result, LVSCW_AUTOSIZE_USEHEADER)

proc appendColumn*(self: wListCtrl, text = "", format = wListFormatLeft,
    width = wListAutosize, image = wListImageNone): int
    {.validate, inline, discardable.} =
  ## Adds a new column to the list control in report view mode.
  self.insertColumn(self.mColCount, text, format, width, image)

proc setColumn*(self: wListCtrl, col: int, text = "", format = wListIgnore,
    width = wListIgnore, image = wListIgnore) {.validate, property.} =
  ## Sets information about this column.
  ## ==========  ===============================================================
  ## Parameters  Description
  ## ==========  ===============================================================
  ## col         The index where the column should be inserted.
  ## text        The string specifying the column heading.
  ## format      The flags specifying the control heading text alignment.
  ##             wListFormatLeft, wListFormatRight or wListFormatCenter.
  ## width       If positive, the width of the column in pixels. Otherwise
  ##             it can be wListAutosize to choose the default size for the
  ##             column or wListAutosizeUseHeader to fit the column width to
  ##             heading or to extend to fill all the remaining space for the
  ##             last column.
  ## image       Zero-based index of the image associated with the item into the
  ##             image list.
  if width != wListIgnore:
    self.setColumnWidth(col, width)

  var lvcol: LVCOLUMN
  if text.len != 0:
    lvcol.mask = lvcol.mask or LVCF_TEXT
    lvcol.pszText = &T(text)

  if format != wListIgnore:
    lvcol.mask = lvcol.mask or LVCF_FMT
    lvcol.fmt = format

  if image != wListIgnore:
    lvcol.mask = lvcol.mask or LVCF_IMAGE
    lvcol.iImage = image

  SendMessage(self.mHwnd, LVM_SETCOLUMN, col, &lvcol)

proc setColumnText*(self: wListCtrl, col: int, text: string)
    {.validate, property, inline.} =
  ## Sets the column text.
  self.setColumn(col, text=text)

proc setColumnFormat*(self: wListCtrl, col: int, format: int)
    {.validate, property, inline.} =
  ## Sets the column format.
  self.setColumn(col, format=format)

proc setColumnImage*(self: wListCtrl, col: int, image: int)
  {.validate, property, inline.} =
  ## Sets the column image.
  self.setColumn(col, image=image)

proc getColumnCount*(self: wListCtrl): int {.validate, property, inline.} =
  ## Returns the number of columns.
  result = self.mColCount

proc getColumnWidth*(self: wListCtrl, col: int): int
    {.validate, property.} =
  ## Gets the column width.
  result = int SendMessage(self.mHwnd, LVM_GETCOLUMNWIDTH, col, 0)

proc getColumnFormat*(self: wListCtrl, col: int): int
    {.validate, property.} =
  ## Gets the column format.
  var lvcol = LVCOLUMN(mask: LVCF_FMT)
  SendMessage(self.mHwnd, LVM_GETCOLUMN, col, &lvcol)
  result = lvcol.fmt

proc getColumnImage*(self: wListCtrl, col: int): int
    {.validate, property.} =
  ## Gets the column format.
  var lvcol = LVCOLUMN(mask: LVCF_IMAGE)
  SendMessage(self.mHwnd, LVM_GETCOLUMN, col, &lvcol)
  result = lvcol.iImage

proc getColumnText*(self: wListCtrl, col: int): string {.validate, property.} =
  ## Gets the column text.
  var buffer = T(65536)
  var lvcol = LVCOLUMN(mask: LVCF_TEXT, cchTextMax: 65536, pszText: &buffer)
  if SendMessage(self.mHwnd, LVM_GETCOLUMN, col, &lvcol) != 0:
    buffer.nullTerminate
    result = $buffer

proc getItemCount*(self: wListCtrl): int {.validate, property.} =
  ## Returns the number of items in the list control.
  result = int SendMessage(self.mHwnd, LVM_GETITEMCOUNT, 0, 0)

proc deleteColumn*(self: wListCtrl, col: int) {.validate.} =
  ## Deletes a column.
  if SendMessage(self.mHwnd, LVM_DELETECOLUMN, col, 0) != 0:
    self.mColCount.dec

proc deleteAllColumns*(self: wListCtrl) {.validate.} =
  ## Delete all columns in the list control.
  while self.mColCount > 0:
    self.deleteColumn(0)

proc insertItem*(self: wListCtrl, index: int, text = "", image = wListImageNone,
    data: int = 0): int {.validate, discardable.} =
  ## Inserts an item, returning the index of the new item if successful, -1 otherwise
  # it not set I_IMAGENONE, it will use image 0
  var item = LVITEM(iItem: index, mask: LVIF_IMAGE, iImage: image)

  if text.len != 0:
    item.mask = item.mask or LVIF_TEXT
    item.pszText = &T(text)

  if data != 0:
    item.mask = item.mask or LVIF_PARAM
    item.lParam = data

  result = int SendMessage(self.mHwnd, LVM_INSERTITEM, 0, &item)

proc appendItem*(self: wListCtrl, text = "", image = wListImageNone,
    data: int = 0): int {.validate, inline, discardable.} =
  ## Adds an item.
  result = self.insertItem(self.getItemCount(), text, image, data)

proc setItem*(self: wListCtrl, index: int, col: int = 0, text = "",
    image = wListIgnore, state = 0, flag = true) {.validate, property.} =
  ## Sets the data of an item.
  ## ==========  ===============================================================
  ## Parameters  Description
  ## ==========  ===============================================================
  ## index       Zero based item position.
  ## col         One-based index of column, or zero refers to an item rather than
  ##             a subitem.
  ## text        The label.
  ## image       The zero based index into an image list.
  ## state       The state of the item. This is a bitlist of the following flags:
  ##             - wListStateFocused: The item has the focus.
  ##             - wListStateSelected: The item is selected
  ##             - wListStateDropHighlighted: The item is highlighted.
  ##             - wListStateCut: The item is in the cut state
  ## flag        Set state to true or false.
  var item = LVITEM(iItem: index, iSubItem: col)

  if text.len != 0:
    item.mask = item.mask or LVIF_TEXT
    item.pszText = &T(text)

  if image != wListIgnore:
    item.mask = item.mask or LVIF_IMAGE
    item.iImage = image

  if state != 0:
    item.mask = item.mask or LVIF_STATE
    item.stateMask = state
    item.state = if flag: state else: 0

  SendMessage(self.mHwnd, LVM_SETITEM, 0, &item)

proc setItemText*(self: wListCtrl, index: int, col: int = 0, text: string)
    {.validate, property, inline.} =
  ## Sets the text of an item.
  self.setItem(index, col, text=text)

proc setItemState*(self: wListCtrl, index: int, col: int = 0, state: int,
    flag = true) {.validate, property, inline.} =
  ## Sets the state of an item.
  self.setItem(index, col, state=state, flag=flag)

proc setItemImage*(self: wListCtrl, index: int, col: int = 0, image: int)
    {.validate, property, inline.} =
  ## Sets the image of an item.
  self.setItem(index, col, image=image)

proc setItemData*(self: wListCtrl, index: int, data: int)
    {.validate, property, inline.} =
  ## Associates application-defined data with this item.
  # lParam can only associated with an item,
  # If iSubItem != 0, lParam have no use.
  var item = LVITEM(iItem: index, mask: LVIF_PARAM, lParam: data)
  SendMessage(self.mHwnd, LVM_SETITEM, 0, &item)

proc getItemText*(self: wListCtrl, index: int, col: int = 0): string
    {.validate, property.} =
  ## Gets the item text.
  var buffer = T(65536)
  var item = LVITEM(mask: LVIF_TEXT, iItem: index, iSubItem: col,
    cchTextMax: 65536, pszText: &buffer)

  if SendMessage(self.mHwnd, LVM_GETITEM, 0, &item) != 0:
    buffer.nullTerminate
    result = $buffer

proc getItemState*(self: wListCtrl, index: int, col: int = 0): int
    {.validate, property.} =
  ## Gets the item state.
  var item = LVITEM(mask: LVIF_STATE, iItem: index, iSubItem: col, stateMask: -1)
  SendMessage(self.mHwnd, LVM_GETITEM, 0, &item)
  result = item.state

proc getItemImage*(self: wListCtrl, index: int, col: int = 0): int
    {.validate, property.} =
  ## Gets the item image.
  var item = LVITEM(mask: LVIF_IMAGE, iItem: index, iSubItem: col)
  SendMessage(self.mHwnd, LVM_GETITEM, 0, &item)
  result = item.iImage

proc getItemData*(self: wListCtrl, index: int): int
    {.validate, property.} =
  ## Gets the application-defined data associated with this item.
  var item = LVITEM(mask: LVIF_PARAM, iItem: index)
  SendMessage(self.mHwnd, LVM_GETITEM, 0, &item)
  result = int item.lParam

proc insertItem*(self: wListCtrl, index: int, texts: openarray[string],
    image = wListImageNone, data: int = 0): int {.validate, discardable.} =
  ## Inserts an item, and sets the text of subitems in the mean time.
  if texts.len >= 1:
    result = self.insertItem(index, texts[0], image, data)
    for i in 1..<texts.len:
      self.setItem(result, i, texts[i])

proc appendItem*(self: wListCtrl, texts: openarray[string],
    image = wListImageNone, data: int = 0): int {.validate, discardable.} =
  ## Adds an item, and sets the text of subitems in the mean time.
  self.insertItem(self.getItemCount(), texts, image, data)

proc deleteItem*(self: wListCtrl, index: int) {.validate.} =
  ## Deletes the specified item.
  SendMessage(self.mHwnd, LVM_DELETEITEM, index, 0)

proc deleteAllItems*(self: wListCtrl) {.validate.} =
  ## Deletes all items in the list control.
  SendMessage(self.mHwnd, LVM_DELETEALLITEMS, 0, 0)

proc clearAll*(self: wListCtrl) {.validate, inline.} =
  ## Deletes all items and all columns.
  self.deleteAllItems()
  self.deleteAllColumns()

iterator items*(self: wListCtrl): string {.validate.} =
  ## Iterate each item in this list control.
  let count = self.getItemCount()
  var i = 0
  while i < count:
    yield self.getItemText(i, 0)
    i.inc

iterator pairs*(self: wListCtrl): (int, string) {.validate.} =
  ## Iterates over each item in list control. Yields ``(index, [index])`` pairs.
  let count = self.getItemCount()
  var i = 0
  while i < count:
    yield (i, self.getItemText(i, 0))
    i.inc

proc len*(self: wListCtrl): int {.validate, inline.} =
  ## Returns the number of items in the list control. The same as getItemCount().
  result = self.getItemCount()

proc findItem*(self: wListCtrl, text: string, start: int = 0, partial = false): int
    {.validate.} =
  ## Find an item whose label matches this string.
  ## If partial is true then this method will look for items which begin with text.
  var findInfo = LVFINDINFO(
    flags: if partial: LVFI_PARTIAL else: LVFI_STRING,
    psz: T(text))

  # LVM_FINDITEM: The specified item is itself excluded from the search, so dec 1
  result = int SendMessage(self.mHwnd, LVM_FINDITEM, start - 1, &findInfo)

proc findItem*(self: wListCtrl, data: int, start: int = 0): int {.validate.} =
  ## Find an item whose data matches this data.
  var findInfo = LVFINDINFO(flags: LVFI_PARAM, lParam: data)
  # LVM_FINDITEM: The specified item is itself excluded from the search, so dec 1
  result = int SendMessage(self.mHwnd, LVM_FINDITEM, start - 1, &findInfo)

proc getItemPosition*(self: wListCtrl, index: int): wPoint
    {.validate, property.} =
  ## Returns the position of the item, in icon or small icon view.
  var pt: POINT
  SendMessage(self.mHwnd, LVM_GETITEMPOSITION, index, &pt)
  result.x = pt.x
  result.y = pt.y

proc setItemPosition*(self: wListCtrl, index: int, pos: wPoint)
    {.validate, property.} =
  ## Sets the position of the item, in icon or small icon view.
  var pt: POINT
  pt.x = pos.x
  pt.y = pos.y
  SendMessage(self.mHwnd, LVM_SETITEMPOSITION32, index, &pt)

proc getItemSpacing*(self: wListCtrl): wSize {.validate, property.} =
  ## Retrieves the spacing between icons in pixels
  let isSmall = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and LVS_SMALLICON) != 0
  let spacing = SendMessage(self.mHwnd, LVM_GETITEMSPACING, isSmall, 0)
  result.width = int LOWORD(spacing)
  result.height = int HIWORD(spacing)

proc setItemSpacing*(self: wListCtrl, width: int, height: int) {.validate, property.} =
  ## Sets the spacing between icons.
  SendMessage(self.mHwnd, LVM_SETICONSPACING, 0, MAKELONG(width, height))

proc setItemSpacing*(self: wListCtrl, size: wSize) {.validate, property, inline.} =
  ## Sets the spacing between icons.
  self.setItemSpacing(size.width, size.height)

proc getTopItem*(self: wListCtrl): int {.validate, property.} =
  ## Gets the index of the topmost visible item when in list or report view.
  result = int SendMessage(self.mHwnd, LVM_GETTOPINDEX, 0, 0)

proc getCountPerPage*(self: wListCtrl): int {.validate, property.} =
  ## Gets the number of items that can fit vertically in the visible area
  ## of the list control (list or report view) or the total number of items
  ## in the list control (icon or small icon view).
  result = int SendMessage(self.mHwnd, LVM_GETCOUNTPERPAGE, 0, 0)

proc getItemRect*(self: wListCtrl, index: int, code = wListRectBounds): wRect
    {.validate, property.} =
  ## Returns the rectangle representing the item's size and position,
  ## in physical coordinates. *code* is one of wListRectBounds, wListRectIcon,
  ## wListRectLabel or wListRectSelectBounds.
  var rect = RECT(left: code)
  SendMessage(self.mHwnd, LVM_GETITEMRECT, index, &rect)
  result = toWRect(rect)

proc getSubItemRect*(self: wListCtrl, index, col: int,
    code = wListRectBounds): wRect {.validate, property.} =
  ## Returns the rectangle representing the size and position, in physical
  ## coordinates, of the given subitem. This method is only meaningful when the
  ## wListCtrl is in the report mode. *code* can be one wListRectBounds,
  ## wListRectIcon or wListRectLabel.
  var rect = RECT(top: col, left: code)
  SendMessage(self.mHwnd, LVM_GETSUBITEMRECT, index, &rect)
  result = toWRect(rect)

  if col == 0 and code == wListRectBounds:
    # fix width if col = 0, it will return full row width
    result.width = self.getColumnWidth(0)

proc getViewRect*(self: wListCtrl): wRect {.validate, property.} =
  ## Returns the rectangle taken by all items in the control.
  ## Note that this function only works in the icon views, small icon views, and
  ## reprot views.

  if (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and LVS_REPORT) != 0:
    let count = self.getItemCount()
    if count > 0:
      result = self.getItemRect(min(self.getTopItem() + self.getCountPerPage(), count - 1))
      result.height += result.y
      result.y = 0
  else:
    # LVM_GETVIEWRECT only works for icon or small icon view.
    var rect: RECT
    SendMessage(self.mHwnd, LVM_GETVIEWRECT, 0, &rect)
    result = toWRect(rect)

proc getView*(self: wListCtrl): int {.validate, property.} =
  ## Gets the view style of list control. wLcIcon, wLcSmallIcon, wLcList or wLcReport.
  result = int SendMessage(self.mHwnd, LVM_GETVIEW, 0, 0)

proc setView*(self: wListCtrl, style: int) {.validate, property.} =
  ## Sets the view style of list contorl.
  SendMessage(self.mHwnd, LVM_SETVIEW, style, 0)

proc setImageList*(self: wListCtrl, imageList: wImageList,
    which = wImageListSmall) {.validate, property.} =
  ## Sets the image list associated with the control.
  ## *which* is one of wImageListNormal, wImageListSmall, wImageListState.
  wValidate(imageList)
  case which
  of LVSIL_NORMAL: self.mImageListNormal = imageList
  of LVSIL_SMALL: self.mImageListSmall = imageList
  of LVSIL_STATE: self.mImageListState = imageList
  else: return
  SendMessage(self.mHwnd, LVM_SETIMAGELIST, which, imageList.mHandle)

proc getImageList*(self: wListCtrl, which = wImageListNormal): wImageList
    {.validate, property.} =
  ## Returns the specified image list.
  ## *which* is one of wImageListNormal, wImageListSmall, wImageListState.
  result = case which
  of LVSIL_NORMAL: self.mImageListNormal
  of LVSIL_SMALL: self.mImageListSmall
  of LVSIL_STATE: self.mImageListState
  else: nil

proc setTextColor*(self: wListCtrl, color: wColor) {.validate, property.} =
  ## Sets the text color of the list control.
  SendMessage(self.mHwnd, LVM_SETTEXTCOLOR, 0, color)

proc getTextColor*(self: wListCtrl): wColor {.validate, property.} =
  ## Gets the text color of the list control.
  result = wColor SendMessage(self.mHwnd, LVM_GETTEXTCOLOR, 0, 0)

method setBackgroundColor*(self: wListCtrl, color: wColor) {.property} =
  ## Sets the background color of the control.
  procCall wWindow(self).setBackgroundColor(color)
  SendMessage(self.mHwnd, LVM_SETTEXTBKCOLOR, 0, color)
  SendMessage(self.mHwnd, LVM_SETBKCOLOR, 0, color)

method setForegroundColor*(self: wListCtrl, color: wColor) {.property} =
  ## Sets the foreground color of the control.
  procCall wWindow(self).setForegroundColor(color)
  self.setTextColor(color)

proc setAlternateRowColor*(self: wListCtrl, color: wColor)
    {.validate, property, inline.} =
  ## Sets alternating row background colors. Use a negative color vlaue to
  ## start from first row.
  self.mAlternateRowColor = color

proc getAlternateRowColor*(self: wListCtrl): wColor {.validate, property, inline.} =
  ## Gets alternating row background colors.
  result = self.mAlternateRowColor

proc disableAlternateRowColors*(self: wListCtrl) {.validate, property, inline.} =
  ## Disable alternating row background colors.
  self.mAlternateRowColor = -1

proc enableAlternateRowColors*(self: wListCtrl, flag = true) {.validate.} =
  ## Enable alternating row background colors. The appropriate color for the
  ## even rows is chosen automatically.
  if flag:
    if self.mAlternateRowColor == -1:
      let r = (self.mBackgroundColor.GetRValue().float * 0.9).byte
      let g = (self.mBackgroundColor.GetGValue().float * 0.9).byte
      let b = (self.mBackgroundColor.GetBValue().float * 0.9).byte
      self.mAlternateRowColor = RGB(r, g, b)

  else:
    self.disableAlternateRowColors()

proc getSelectedItemCount*(self: wListCtrl): int {.validate, property.} =
  ## Returns the number of selected items in the list control.
  result = int SendMessage(self.mHwnd, LVM_GETSELECTEDCOUNT, 0, 0)

proc getColumnsOrder*(self: wListCtrl): seq[int] {.validate, property.} =
  ## Returns the seq containing the orders of all columns.
  var buffer = newSeq[int32](self.mColCount)
  newSeq(result, self.mColCount)
  if SendMessage(self.mHwnd, LVM_GETCOLUMNORDERARRAY, self.mColCount, &buffer[0]) != 0:
    for i in 0..<self.mColCount:
      result[i] = buffer[i]

proc setColumnsOrder*(self: wListCtrl, orders: openarray[int]) {.validate, property.} =
  ## Changes the order in which the columns are shown.
  var buffer = newSeq[int32](orders.len)
  for i in 0..<orders.len:
    buffer[i] = orders[i].int32
  SendMessage(self.mHwnd, LVM_SETCOLUMNORDERARRAY, orders.len, &buffer[0])

proc ensureVisible*(self: wListCtrl, index: int) {.validate.} =
  ## Ensures this item is visible.
  SendMessage(self.mHwnd, LVM_ENSUREVISIBLE, index, false)

proc hitTest*(self: wListCtrl, x: int, y: int): tuple[index, col, flag: int]
    {.validate.} =
  ## Determines which item (if any) is at the specified point, giving details in flags.
  ## *flag* will be a combination of the following flags:
  ## ===========================  ==============================================
  ## Flag                         Description
  ## ===========================  ==============================================
  ## wListHittestAbove            Above the control's client area.
  ## wListHittestBelow            Below the control's client area.
  ## wListHittestToLeft           To the left of the control's client area.
  ## wListHittestToRight          To the right of the control's client area.
  ## wListHittestNoWhere          Inside the control's client area but not over an item.
  ## wListHittestOnItemLabel      Over an item's text.
  ## wListHittestOnItemIcon       Over an item's icon.
  ## wListHittestOnItemStateIcon  Over the checkbox of an item.
  var info: LVHITTESTINFO
  info.pt.x = x
  info.pt.y = y
  result.index = int SendMessage(self.mHwnd, LVM_SUBITEMHITTEST, 0, &info)
  result.col = info.iSubItem
  result.flag = info.flags

proc hitTest*(self: wListCtrl, pos: wPoint): tuple[index, col, flag: int]
    {.validate, inline.} =
  ## The same as hitTest().
  result = self.hitTest(pos.x, pos.y)

proc arrange*(self: wListCtrl, flag = wListAlignDefault) {.validate.} =
  ## Arranges the items in icon or small icon view.
  ## *flag* is one of: wListAlignDefault, wListAlignLeft, wListAlignTop,
  ## wListAlignSnapToGrid
  SendMessage(self.mHwnd, LVM_ARRANGE, flag, 0)

proc getNextItem*(self: wListCtrl, start: int, geometry: int, state: int): int
    {.validate, property.} =
  ## Searches for an item with the given geometry or state, starting from *start*.
  ## *geometry* can be one of wListNextAll, wListNextPrevious, wListNextAbove,
  ## wListNextBelow, wListNextLeft, wListNextRight. *state* can be a bitlist of
  ## wListStateDontCare, wListStateDropHighlighted, wListStateFocused,
  ## wListStateSelected, wListStateCut.
  # The specified item itself is excluded from the search.
  result = int SendMessage(self.mHwnd, LVM_GETNEXTITEM, start - 1, geometry or state)

proc refreshItem*(self: wListCtrl, item: int, itemTo = -1) {.validate.} =
  ## Redraws the given item or items between item and itemTo.
  SendMessage(self.mHwnd, LVM_REDRAWITEMS, item, if itemTo < 0: item else: itemTo)

proc scrollList*(self: wListCtrl, dx: int, dy: int) {.validate.} =
  ## Scrolls the list control.
  SendMessage(self.mHwnd, LVM_SCROLL, dx, dy)


type
  wListCtrl_Compare* = proc (item1: int, item2: int, data: int): int
    ## Comparing callback function prototype used in sortItems() and sortItemsByIndex()
  wListCtrl_SortData = object
    fn: wListCtrl_Compare
    data: int

proc wListCtrl_CompareFunc(lparam1, lparam2, lparamSort: LPARAM): int32 {.stdcall.} =
  let pSortData = cast[ptr wListCtrl_SortData](lparamSort)
  result = pSortData[].fn(int lparam1, int lparam2, pSortData[].data)

proc sortItems*(self: wListCtrl, callback: wListCtrl_Compare, data: int = 0)
    {.validate.} =
  ## Sorts the items in the list control. The value passed into callback function
  ## is the data associated with the item. You can use setItemData() to set it.
  ## The extra parameter *data* is the value passed into callback funtion
  ## as third parameter.
  var sortData = wListCtrl_SortData(fn: callback, data: data)
  SendMessage(self.mHwnd, LVM_SORTITEMS, &sortData, wListCtrl_CompareFunc)

proc sortItemsByIndex*(self: wListCtrl, callback: wListCtrl_Compare, data: int = 0)
    {.validate.} =
  ## Sorts the items in the list control. The value passed into callback function
  ## is the item index. You can use getItemText() to retrieve more information
  ## on an item if needed.
  var sortData = wListCtrl_SortData(fn: callback, data: data)
  SendMessage(self.mHwnd, LVM_SORTITEMSEX, &sortData, wListCtrl_CompareFunc)

proc setExtendedStyle*(self: wListCtrl, exStyle: DWORD, flag = true)
    {.validate, property.} =
  ## Sets extended styles in the list controls. See MSDN about
  ## "Extended List-View Styles" for more information.
  SendMessage(self.mHwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, exStyle, if flag: exStyle else: 0)

proc getExtendedStyle*(self: wListCtrl): DWORD {.validate, property.} =
  ## Gets the extended styles that are currently in use for the list control.
  result = DWORD SendMessage(self.mHwnd, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)

proc enableCheckBoxes*(self: wListCtrl, enable = true) {.validate, inline.} =
  ## Enable or disable checkboxes for list items.
  self.setExtendedStyle(LVS_EX_CHECKBOXES, enable)

proc hasCheckBoxes*(self: wListCtrl): bool {.validate.} =
  ## Returns true if checkboxes are enabled for list items.
  let style = self.getExtendedStyle()
  result = (style and LVS_EX_CHECKBOXES) != 0

proc checkItem*(self: wListCtrl, index: int, state = true) {.validate.} =
  ## Check or uncheck a item in a control using checkboxes.
  ListView_SetCheckState(self.mHwnd, index, state)

proc isItemChecked*(self: wListCtrl, index: int): bool {.validate.} =
  ## Return true if the checkbox for the given index is checked.
  result = bool ListView_GetCheckState(self.mHwnd, index)

proc getEditControl*(self: wListCtrl): wTextCtrl {.validate, property.} =
  ## Returns the edit control being currently used to edit a label.
  ## Returns nil if no label is being edited.
  let hwnd = HWND SendMessage(self.mHwnd, LVM_GETEDITCONTROL, 0, 0)
  if hwnd != 0:
    assert self.mTextCtrl.mHwnd == hwnd
    result = self.mTextCtrl

proc editLabel*(self: wListCtrl, index: int): wTextCtrl {.validate, discardable.} =
  ## Starts editing the label of the given item.
  # LVM_EDITLABEL requires that the list has focus.
  self.setFocus()
  let hwnd = HWND SendMessage(self.mHwnd, LVM_EDITLABEL, index, 0)
  if hwnd != 0:
    assert hwnd == self.mTextCtrl.mHwnd
    result = self.mTextCtrl

proc endEditLabel*(self: wListCtrl, cancel = false) {.validate.} =
  ## Finish editing the label.
  let hwnd = HWND SendMessage(self.mHwnd, LVM_GETEDITCONTROL, 0, 0)
  if hwnd != 0:
    assert hwnd == self.mTextCtrl.mHwnd
    SendMessage(hwnd, WM_KEYDOWN, if cancel: VK_ESCAPE else: VK_RETURN, 0)

method getBestSize*(self: wListCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  let ret = SendMessage(self.mHwnd, LVM_APPROXIMATEVIEWRECT, -1, MAKELPARAM(-1, -1))
  result.width = int LOWORD(ret)
  result.height = int HIWORD(ret)

proc ListEvent(self: wListCtrl, msg: UINT, lParam: LPARAM): wListEvent =
  let event = wListEvent Event(window=self, msg=msg, lParam=lParam)
  case msg
  of wEvent_ListBeginLabelEdit, wEvent_ListEndLabelEdit:
    let pndi = cast[LPNMLVDISPINFO](lParam)
    event.mIndex = pndi.item.iItem
    event.mCol = pndi.item.iSubItem
    if pndi.item.pszText != nil:
      event.mText = $pndi.item.pszText

  of wEvent_ListColRightClick:
    let hhdr = cast[LPNMHDR](lparam).hwndFrom
    var info: HDHITTESTINFO
    var val = GetMessagePos()
    info.pt.x = GET_X_LPARAM(val)
    info.pt.y = GET_Y_LPARAM(val)
    ScreenToClient(hhdr, info.pt)
    SendMessage(hhdr, HDM_HITTEST, 0, &info)
    event.mIndex = -1
    event.mCol = info.iItem

  of wEvent_ListColBeginMove, wEvent_ListColEndMove, wEvent_ListColBeginDrag,
      wEvent_ListColEndDrag, wEvent_ListColDragging:
    let pnh = cast[LPNMHEADER](lParam)
    event.mIndex = -1
    event.mCol = pnh.iItem

  of wEvent_ListItemRightClick, wEvent_ListItemActivated:
    let pnma = cast[LPNMITEMACTIVATE](lparam)
    event.mIndex = pnma.iItem
    event.mCol = pnma.iSubItem

  else:
    let pnmv = cast[LPNMLISTVIEW](lParam)
    event.mIndex = pnmv.iItem
    event.mCol = pnmv.iSubItem
  result = event

method processNotify(self: wListCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  let msg = case code
  of LVN_BEGINDRAG: wEvent_ListBeginDrag
  of LVN_BEGINRDRAG: wEvent_ListBeginRightDrag
  of LVN_COLUMNCLICK: wEvent_ListColClick
  of LVN_DELETEITEM: wEvent_ListDeleteItem
  of LVN_ITEMACTIVATE: wEvent_ListItemActivated
  of LVN_INSERTITEM: wEvent_ListInsertItem
  of HDN_BEGINDRAG: wEvent_ListColBeginMove
  of HDN_ENDDRAG: wEvent_ListColEndMove
  of HDN_ENDTRACK: wEvent_ListColEndDrag
  else: 0

  if msg != 0:
    return self.processEvent(self.ListEvent(msg, lParam))

  case code
  of HDN_BEGINTRACK:
    let event = self.ListEvent(wEvent_ListColBeginDrag, lParam)
    let processed = self.processEvent(event)
    if processed and not event.isAllowed:
      # MSDN: Returns FALSE to allow tracking of the divider, or TRUE to prevent tracking.
      ret = TRUE
    return processed

  of HDN_ITEMCHANGING:
    let pnh = cast[LPNMHEADER](lParam)
    if pnh.pitem != nil and (pnh.pitem.mask and HDI_WIDTH) != 0 and
        self.getColumnWidth(pnh.iItem) != pnh.pitem.cxy:

      let event = self.ListEvent(wEvent_ListColDragging, lParam)
      if event.leftDown():
        return self.processEvent(event)

  of NM_RCLICK:
    let isHeader = cast[LPNMHDR](lparam).hwndFrom != self.mHwnd
    let msg = if isHeader: wEvent_ListColRightClick else: wEvent_ListItemRightClick
    return self.processEvent(self.ListEvent(msg, lParam))

  of LVN_DELETEALLITEMS:
    self.processEvent(self.ListEvent(wEvent_ListDeleteAllItems, lParam))
    # MSDN: To suppress subsequent LVN_DELETEITEM notification codes, return TRUE.
    ret = TRUE
    return true # must return true so that TRUE will pass to who send WM_NOTIFY

  of LVN_BEGINLABELEDIT:
    let hwnd = HWND SendMessage(self.mHwnd, LVM_GETEDITCONTROL, 0, 0)
    if hwnd != 0:
      self.mTextCtrl = TextCtrl(hwnd)

    let event = self.ListEvent(wEvent_ListBeginLabelEdit, lParam)
    let processed = self.processEvent(event)
    if processed and not event.isAllowed:
      # MSDN: To prevent the user from editing the label, return TRUE.
      ret = TRUE
      # if here return TRUE, LVN_ENDLABELEDIT won't be fired.
      self.mTextCtrl = nil

    return processed

  of LVN_ENDLABELEDIT:
    self.mTextCtrl = nil

    let event = self.ListEvent(wEvent_ListEndLabelEdit, lParam)
    if self.processEvent(event) and not event.isAllowed:
      # MSDN: Return FALSE to reject the edited text and revert to the original label.
      # logic here is inverted !!
      ret = FALSE
    else:
      ret = TRUE

    return true # must return true

  of LVN_ITEMCHANGED:
    var processed = false
    let pnmv = cast[LPNMLISTVIEW](lparam)
    if (pnmv.uChanged and LVIF_STATE) != 0 and pnmv.iItem != -1:
      let
        oldSt = pnmv.uOldState
        newSt = pnmv.uNewState

      if (oldSt and LVIS_FOCUSED) == 0 and (newSt and LVIS_FOCUSED) != 0:
        processed = processed or
          self.processEvent(self.ListEvent(wEvent_ListItemFocused, lParam))

      if (oldSt and LVIS_SELECTED) != (newSt and LVIS_SELECTED):
        let msg =
          if (newSt and LVIS_SELECTED) != 0:
            wEvent_ListItemSelected
          else:
            wEvent_ListItemDeselected
        processed = processed or
          self.processEvent(self.ListEvent(msg, lParam))

      if (newSt and LVIS_STATEIMAGEMASK) != (oldSt and LVIS_STATEIMAGEMASK) and
          oldSt != INDEXTOSTATEIMAGEMASK(0):

        if newSt == INDEXTOSTATEIMAGEMASK(1):
          processed = processed or
            self.processEvent(self.ListEvent(wEvent_ListitemUnchecked, lParam))

        elif newSt == INDEXTOSTATEIMAGEMASK(2):
          processed = processed or
            self.processEvent(self.ListEvent(wEvent_ListitemChecked, lParam))

    return processed

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

proc wListCtrl_OnPaint(event: wEvent) =
  let self = wBase.wListCtrl(event.mWindow)
  let hwnd = self.mHwnd

  if self.mAlternateRowColor == -1 or self.getView() != wLcReport:
    event.skip

  else:
    var rectUpdate, rectDraw, rectItem: RECT
    let countPerPage = self.getCountPerPage()
    let topItem = self.getTopItem()

    var alternateColorRow = 0
    var alternateColor = self.mAlternateRowColor
    if self.mAlternateRowColor < 0:
      alternateColorRow = 1
      alternateColor = -self.mAlternateRowColor

    GetUpdateRect(hwnd, &rectUpdate, false)
    DefSubclassProc(hwnd, WM_PAINT, 0, 0)

    for i in topItem..topItem+countPerPage:
      rectItem.left = LVIR_BOUNDS
      if SendMessage(hwnd, LVM_GETITEMRECT, i, &rectItem) == 0:
        continue

      if IntersectRect(&rectDraw, &rectUpdate, &rectItem) != 0:
        let color =
          if i mod 2 == alternateColorRow:
            self.mBackgroundColor
          else:
            alternateColor
        SendMessage(hwnd, LVM_SETTEXTBKCOLOR, 0, color)
        SendMessage(hwnd, LVM_SETBKCOLOR, 0, color)

        InvalidateRect(hwnd, &rectDraw, true)
        DefSubclassProc(hwnd, WM_PAINT, 0, 0)

    # restore the background color
    SendMessage(hwnd, LVM_SETTEXTBKCOLOR, 0, self.mBackgroundColor)
    SendMessage(hwnd, LVM_SETBKCOLOR, 0, self.mBackgroundColor)

wClass(wListCtrl of wControl):

  method release*(self: wListCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wListCtrl, parent: wWindow, id: wCommandID = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wLcIcon) {.validate.} =
    ## Initializes a list control.
    wValidate(parent)
    self.wControl.init(className=WC_LISTVIEW, parent=parent, id=id, label="",
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or
      LVS_SHAREIMAGELISTS or LVS_SHOWSELALWAYS)

    SendMessage(self.mHwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_LABELTIP or
      LVS_EX_FULLROWSELECT or LVS_EX_SUBITEMIMAGES or LVS_EX_HEADERDRAGDROP)

    # set default background color
    self.setBackgroundColor(wColor SendMessage(self.mHwnd, LVM_GETBKCOLOR, 0, 0))
    self.disableAlternateRowColors()

    self.hardConnect(WM_PAINT, wListCtrl_OnPaint)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
        event.veto
