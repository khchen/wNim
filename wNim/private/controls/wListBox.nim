#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A listbox is used to select one or more of a list of strings.
#
## :Appearance:
##   .. image:: images/wListBox.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wLbSingle                       Single-selection list.
##   wLbMultiple                     Multiple-selection list.
##   wLbExtended                     Extended-selection list: the user can extend the selection by using SHIFT or CTRL keys together with the cursor movement keys or the mouse.
##   wLbNeededScroll                 Only create a vertical scrollbar if needed.
##   wLbAlwaysScroll                 Always show a vertical scrollbar.
##   wLbSort                         The listbox contents are sorted in alphabetical order.
##   wLbNoSel                        Specifies that the list box contains items that can be viewed but not selected.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_ListBox                   When an item on the list is selected or the selection changes.
##   wEvent_ListBoxDoubleClick        When the listbox is double-clicked.
##   ===============================  =============================================================

include ../pragma
import ../wBase, wControl
export wControl

const
  # ListBox styles
  wLbSingle* = 0
  wLbMultiple* = LBS_MULTIPLESEL
  wLbExtended* = LBS_EXTENDEDSEL
  # The horizontal scroll of listbox bar is useless.
  # Even shows it by WS_HSCROLL + LBS_DISABLENOSCROLL, it is always disabled?
  # So we focus on vertical scroll bar here. (Testing under win10)
  # There are three condition for vertical scroll:
  #  1. no style: never shows a scroll bar. (wxLB_NO_SB)
  #  2. WS_VSCROLLL: shows a vertical scroll bar only when list is too long. (wxLB_NEEDED_SB)
  #  3. WS_VSCROLL + CBS_DISABLENOSCROLL: alwasy shows a vertical scroll bar. (wxLB_ALWAYS_SB)
  wLbNeededScroll* = WS_VSCROLL
  wLbAlwaysScroll* = WS_VSCROLL or LBS_DISABLENOSCROLL
  wLbSort* = LBS_SORT
  wLbNoSel* = LBS_NOSEL

proc getCount*(self: wListBox): int {.validate, property, inline.} =
  ## Returns the number of items in the control.
  result = int SendMessage(self.mHwnd, LB_GETCOUNT, 0, 0)

proc len*(self: wListBox): int {.validate, inline.} =
  ## Returns the number of items in the control.
  result = self.getCount()

proc getText*(self: wListBox, index: int): string {.validate, property.} =
  ## Returns the label of the item with the given index.
  # use getText instead of getString, otherwise property become "string" keyword.
  let maxLen = int SendMessage(self.mHwnd, LB_GETTEXTLEN, index, 0)
  if maxLen == LB_ERR: return ""

  var buffer = T(maxLen + 2)
  buffer.setLen(SendMessage(self.mHwnd, LB_GETTEXT, index, &buffer))
  result = $buffer

proc `[]`*(self: wListBox, index: int): string {.validate, inline.} =
  ## Returns the label of the item with the given index.
  ## Raise error if index out of bounds.
  result = self.getText(index)
  if result.len == 0:
    raise newException(IndexDefect, "index out of bounds")

iterator items*(self: wListBox): string {.validate, inline.} =
  ## Iterate each item in this list box.
  for i in 0..<self.len():
    yield self.getText(i)

iterator pairs*(self: wListBox): (int, string) {.validate, inline.} =
  ## Iterates over each item in this list box. Yields ``(index, [index])`` pairs.
  var i = 0
  for item in self:
    yield (i, item)
    inc i

proc insert*(self: wListBox, pos: int, text: string) {.validate, inline.} =
  ## Inserts the given string before the specified position.
  ## Notice that the inserted item won't be sorted even the list box has wLbSort
  ## style. If pos is -1, the string is added to the end of the list.
  SendMessage(self.mHwnd, LB_INSERTSTRING, pos, &T(text))

proc insert*(self: wListBox, pos: int, list: openarray[string])
    {.validate, inline.} =
  ## Inserts multiple strings in the same time.
  for i, text in list:
    self.insert(if pos < 0: pos else: i + pos, text)

proc append*(self: wListBox, text: string): int {.validate, inline, discardable.} =
  ## Appends the given string to the end. If the list box has the wLbSort style,
  ## the string is inserted into the list and the list is sorted.
  ## The return value is the index of the string in the list box.
  result = int SendMessage(self.mHwnd, LB_ADDSTRING, 0, &T(text))

proc append*(self: wListBox, list: openarray[string]) {.validate, inline.} =
  ## Appends multiple strings in the same time.
  for text in list:
    self.append(text)

proc delete*(self: wListBox, index: int) {.validate, inline.} =
  ## Delete a string in the list box.
  if index >= 0: SendMessage(self.mHwnd, LB_DELETESTRING, index, 0)

proc delete*(self: wListBox, text: string) {.validate, inline.} =
  ## Search and delete the specified string in the list box.
  self.delete(self.find(text))

proc clear*(self: wListBox) {.validate, inline.} =
  ## Remove all items from a list box.
  SendMessage(self.mHwnd, LB_RESETCONTENT, 0, 0)

proc findText*(self: wListBox, text: string): int {.validate, inline.} =
  ## Finds an item whose label matches the given text.
  result = self.find(text)

proc getSelection*(self: wListBox): int {.validate, property, inline.} =
  ## Returns the index of the selected item or wNotFound(-1) if no item is
  ## selected. Don't use in multiple-selection list box.
  result = int SendMessage(self.mHwnd, LB_GETCURSEL, 0, 0)

proc getFocused*(self: wListBox): int {.validate, property, inline.} =
  ## Returns the index of current focused item.
  result = int SendMessage(self.mHwnd, LB_GETCARETINDEX, 0, 0)

proc setFocused*(self: wListBox, index: int) {.validate, property, inline.} =
  ## Sets focused item.
  SendMessage(self.mHwnd, LB_SETCARETINDEX, index, FALSE)

iterator getSelections*(self: wListBox): int {.validate.} =
  ## Iterates over each index of the selected items.
  if (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and LBS_MULTIPLESEL) != 0:
    let L = self.len()
    let buffer = cast[ptr UncheckedArray[int32]](alloc(sizeof(int32) * L))
    defer: dealloc(buffer)

    let selCount = SendMessage(self.mHwnd, LB_GETSELITEMS, L, buffer)
    for i in 0..<selCount:
      yield int buffer[i]
  else:
    yield self.getSelection()

iterator selections*(self: wListBox): int {.validate, inline.} =
  ## Iterates over each index of the selected items.
  for i in self.getSelections():
    yield i

proc getSelections*(self: wListBox): seq[int] {.validate, property.} =
  ## Get the currently selected items.
  result = newSeqOfCap[int](self.len())
  for i in self.getSelections():
    result.add i

proc select*(self: wListBox, index: int = -1) {.validate.} =
  ## Selects an item in the list box.
  ## For multiple-selection list box, -1 means select all.
  if (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and LBS_MULTIPLESEL) != 0:
    SendMessage(self.mHwnd, LB_SETSEL, true, index)
  else:
    SendMessage(self.mHwnd, LB_SETCURSEL, index, 0)

proc selectAll*(self: wListBox) {.validate, inline.} =
  ## Selects all items.
  self.select(-1)

proc deselect*(self: wListBox, index: int = -1) {.validate.} =
  ## Deselects an item in the list box.
  ## For multiple-selection list box, -1 means deselect all.
  if (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and LBS_MULTIPLESEL) != 0:
    SendMessage(self.mHwnd, LB_SETSEL, false, index)
  else:
    SendMessage(self.mHwnd, LB_SETCURSEL, -1, 0)

proc deselectAll*(self: wListBox) {.validate, inline.} =
  ## Deselects all items.
  self.deselect(-1)

proc select*(self: wListBox, text: string) =
  ## Searches and selects an item in the list box.
  let i = self.find(text)
  if i >= 0: self.select(i)

proc deselect*(self: wListBox, text: string) =
  ## Searches and deselects an item in the list box.
  let i = self.find(text)
  if i >= 0: self.deselect(i)

proc setSelection*(self: wListBox, index: int) {.validate, property, inline.} =
  ## Sets the selection to the given index. The same as select().
  self.select(index)

proc setSelections*(self: wListBox, text: string) {.validate, property, inline.} =
  ## Searches and sets the selection to the given text. The same as select().
  self.select(text)

proc setSelections*(self: wListBox, list: openarray[int])
    {.validate, property, inline.} =
  ## Sets the selections.
  for i in list:
    if i >= 0: self.select(i)

proc setSelections*(self: wListBox, list: openarray[string])
    {.validate, property, inline.} =
  ## Searches and sets the selections.
  for i in list: self.select(i)

proc isSelected*(self: wListBox, n: int): bool {.validate, inline.} =
  ## Determines whether an item is selected.
  result = if SendMessage(self.mHwnd, LB_GETSEL, n, 0) == 0: false else: true

proc setText*(self: wListBox, index: int, text: string) {.validate, property.} =
  ## Sets the label for the given item.
  if index >= 0:
    let reselect = self.isSelected(index)
    self.delete(index)
    self.insert(index, text)
    if reselect:
      self.select(index)

proc setFirstItem*(self: wListBox, index: int) {.validate, property, inline.} =
  ## Set the specified item to be the first visible item.
  SendMessage(self.mHwnd, LB_SETTOPINDEX, index, 0)

proc getTopItem*(self: wListBox): int {.validate, property, inline.} =
  ## Return the index of the topmost visible item.
  result = int SendMessage(self.mHwnd, LB_GETTOPINDEX, 0, 0)

proc hitTest*(self: wListBox, x, y: int): int {.validate, inline.} =
  ## Returns the item located at point, or wNotFound(-1) if there is no item
  ## located at point.

  # The return value contains the index of the nearest item in the LOWORD.
  # The HIWORD is zero if the specified point is in the client area of the list box,
  # or one if it is outside the client area.
  let ret = SendMessage(self.mHwnd, LB_ITEMFROMPOINT, 0, MAKELPARAM(x, y))
  result = if HIWORD(ret) != 0: -1 else: int LOWORD(ret)

proc hitTest*(self: wListBox, pos: wPoint): int {.validate, inline.} =
  ## Returns the item located at point, or wNotFound(-1) if there is no item
  ## located at point.
  result = self.hitTest(pos.x, pos.y)

proc getCountPerPage*(self: wListBox): int {.validate, property.} =
  ## Return the number of items that can fit vertically in the visible area of
  ## the listbox.
  let size = self.getSize()
  let itemHeight = int SendMessage(self.mHwnd, LB_GETITEMHEIGHT, 0, 0)
  result = size.height div itemHeight

proc ensureVisible*(self: wListBox, index: int) {.validate, property.} =
  ## Ensure that the item with the given index is currently shown.
  if index >= 0:
    var rect: RECT
    if LB_ERR == SendMessage(self.mHwnd, LB_GETITEMRECT, index, &rect): return

    if rect.top < 0:
      self.setFirstItem(index)

    if rect.bottom.int > self.getSize().height:
      self.setFirstItem(index - self.getCountPerPage() + 1)

proc isSorted*(self: wListBox): bool {.validate, inline.} =
  ## Return true if the listbox has wLbSort style.
  result = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and LBS_SORT) != 0

proc setData*(self: wListBox, index: int, data: int) {.validate, property,
    inline.} =
  ## Associates application-defined data with this item.
  SendMessage(self.mHwnd, LB_SETITEMDATA, index, data)

proc getData*(self: wListBox, index: int): int {.validate, property.} =
  ## Gets the application-defined data associated with this item.
  result = int SendMessage(self.mHwnd, LB_GETITEMDATA, index, 0)

proc getRect*(self: wListBox, index: int): wRect {.validate, property.} =
  ## Returns the rectangle representing the item's size and position,
  ## in physical coordinates.
  var rect: RECT
  if LB_ERR != SendMessage(self.mHwnd, LB_GETITEMRECT, index, &rect):
    result = toWRect(rect)

proc countSize(self: wListBox, minItem: int, rate: float): wSize =
  const maxItem = 10
  let
    lineHeight = getLineControlDefaultHeight(self.mFont.mHandle)
    style = GetWindowLongPtr(self.mHwnd, GWL_STYLE)
    count = self.len()

  proc countWidth(rate: float): int =
    result = lineHeight # minimum width
    for text in self.items():
      let size = getTextFontSize(text, self.mFont.mHandle, self.mHwnd)
      result = max(result, int(size.width.float * rate) + 8)

  let itemHeight = int SendMessage(self.mHwnd, LB_GETITEMHEIGHT, 0, 0)
  result.width = countWidth(rate)
  # not too tall, not too small
  result.height = min(max(count, minItem), maxItem) * itemHeight + 2

  if (style and WS_VSCROLL) != 0 and ((style and LBS_DISABLENOSCROLL) != 0 or count > maxItem):
    result.width += GetSystemMetrics(SM_CXVSCROLL)

method getDefaultSize*(self: wListBox): wSize {.property, inline.} =
  ## Returns the default size for the control.
  # width of longest item + 30% x an integral number of items (3 items minimum)
  result = self.countSize(3, 1.3)

method getBestSize*(self: wListBox): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = self.countSize(1, 1.0)

method trigger(self: wListBox) =
  for i in 0..<self.mInitCount:
    self.append(self.mInitData[i])

wClass(wListBox of wControl):

  method release*(self: wListBox) =
    ## Release all the resources during destroying. Used internally.
    # self.mParent may be nil for wrapped wListBox.
    if not self.mParent.isNil:
      self.mParent.systemDisconnect(self.mCommandConn)

    free(self[])

  proc init*(self: wListBox, parent: wWindow, id = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, choices: openarray[string] = [],
      style: wStyle = wLbSingle) {.validate.} =
    ## Initializes a list box.
    wValidate(parent)
    self.mInitData = cast[ptr UncheckedArray[string]](choices)
    self.mInitCount = choices.len

    self.wControl.init(className=WC_LISTBOX, parent=parent, id=id, label="",
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or
      LBS_NOTIFY or LBS_NOINTEGRALHEIGHT)

    # A list box by default have white background, not parent's background
    self.setBackgroundColor(wWhite)

    # Even with wLbNoSel style, wListBox still can get focus!
    # if (style and wLbNoSel) != 0:
    #   self.mFocusable = false

    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      if event.mLparam == self.mHwnd:
        case HIWORD(event.mWparam):
        of LBN_SELCHANGE:
          self.processMessage(wEvent_ListBox, event.mWparam, event.mLparam)
        of LBN_DBLCLK:
          self.processMessage(wEvent_ListBoxDoubleClick, event.mWparam, event.mLparam)
        of LBN_SETFOCUS:
          self.processMessage(wEvent_CommandSetFocus, event.mWparam, event.mLparam)
        else: discard

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
        event.veto

  proc init*(self: wListBox, hWnd: HWND) {.validate.} =
    ## Initializes a list box by subclassing a system handle. Used internally.
    self.wWindow.init(hwnd)
