## A listbox is used to select one or more of a list of strings.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wLbSingle                       Single-selection list.
##    wLbMultiple                     Multiple-selection list.
##    wLbExtended                     Extended-selection list: the user can extend the selection by using SHIFT or CTRL keys together with the cursor movement keys or the mouse.
##    wLbNeededScroll                 Only create a vertical scrollbar if needed.
##    wLbAlwaysScroll                 Always show a vertical scrollbar.
##    wLbSort                         The listbox contents are sorted in alphabetical order.
##    wLbNoSel                        Specifies that the list box contains items that can be viewed but not selected.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wCommandEvent                   Description
##    ==============================  =============================================================
##    wEvent_ListBox                  When an item on the list is selected or the selection changes.
##    wEvent_ListBoxDoubleClick       When the listbox is double-clicked.
##    ==============================  =============================================================

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

proc len*(self: wListBox): int {.validate, inline.} =
  ## Returns the number of items in the control.
  result = int SendMessage(mHwnd, LB_GETCOUNT, 0, 0)

proc getCount*(self: wListBox): int {.validate, property, inline.} =
  ## Returns the number of items in the control.
  result = len()

proc getText*(self: wListBox, index: int): string {.validate, property.} =
  ## Returns the label of the item with the given index.
  # use getText instead of getString, otherwise property become "string" keyword.
  let maxLen = int SendMessage(mHwnd, LB_GETTEXTLEN, index, 0)
  if maxLen == LB_ERR: return nil

  var buffer = T(maxLen + 2)
  buffer.setLen(SendMessage(mHwnd, LB_GETTEXT, index, &buffer))
  result = $buffer

proc `[]`*(self: wListBox, index: int): string {.validate, inline.} =
  ## Returns the label of the item with the given index.
  ## Raise error if index out of bounds.
  result = getText(index)
  if result == nil:
    raise newException(IndexError, "index out of bounds")

iterator items*(self: wListBox): string {.validate, inline.} =
  ## Iterate each item in this list box.
  for i in 0..<len():
    yield getText(i)

iterator pairs*(self: wListBox): tuple[key: int, val: string] {.validate, inline.} =
  ## Iterates over each item of listbox. Yields ``(index, [index])`` pairs.
  var i = 0
  for item in self:
    yield (i, item)
    inc i

proc insert*(self: wListBox, pos: int, text: string) {.validate, inline.} =
  ## Inserts the given string before the specified position.
  ## Notice that the inserted item won't be sorted even the list box has wLbSort style.
  ## If pos is -1, the string is added to the end of the list.
  SendMessage(mHwnd, LB_INSERTSTRING, pos, &T(text))

proc insert*(self: wListBox, pos: int, list: openarray[string]) {.validate, inline.} =
  ## Inserts multiple strings in the same time.
  for i, text in list:
    insert(if pos < 0: pos else: i + pos, text)

proc append*(self: wListBox, text: string): int {.validate, discardable, inline.} =
  ## Appends the given string to the end. If the list box has the wLbSort style,
  ## the string is inserted into the list and the list is sorted.
  ## The return value is the index of the string in the list box.
  result = int SendMessage(mHwnd, LB_ADDSTRING, 0, &T(text))

proc append*(self: wListBox, list: openarray[string]) {.validate, inline.} =
  ## Appends multiple strings in the same time.
  for text in list:
    append(text)

proc delete*(self: wListBox, index: int) {.validate, inline.} =
  ## Delete a string in the list box.
  if index >= 0: SendMessage(mHwnd, LB_DELETESTRING, index, 0)

proc delete*(self: wListBox, text: string) {.validate, inline.} =
  ## Search and delete the specified string in the list box.
  delete(find(text))

proc clear*(self: wListBox) {.validate, inline.} =
  ## Remove all items from a list box.
  SendMessage(mHwnd, LB_RESETCONTENT, 0, 0)

proc findText*(self: wListBox, text: string): int {.validate, inline.} =
  ## Finds an item whose label matches the given text.
  result = find(text)

proc getSelection*(self: wListBox): int {.validate, property, inline.} =
  ## Returns the index of the selected item or wNotFound(-1) if no item is selected.
  ## Don't use in multiple-selection list box.
  result = int SendMessage(mHwnd, LB_GETCURSEL, 0, 0)

iterator getSelections*(self: wListBox): int {.validate.} =
  ## Iterates over each index of the selected items.
  if (GetWindowLongPtr(mHwnd, GWL_STYLE) and LBS_MULTIPLESEL) != 0:
    let L = len()
    let buffer = cast[ptr UncheckedArray[int32]](alloc(sizeof(int32) * L))
    defer: dealloc(buffer)

    let selCount = SendMessage(mHwnd, LB_GETSELITEMS, L, buffer)
    for i in 0..<selCount:
      yield int buffer[i]
  else:
    yield getSelection()

iterator selections*(self: wListBox): int {.validate, inline.} =
  ## Iterates over each index of the selected items.
  for i in getSelections():
    yield i

proc getSelections*(self: wListBox): seq[int] {.validate, property.} =
  ## Get the currently selected items.
  result = newSeqOfCap[int](len())
  for i in getSelections():
    result.add i

proc select*(self: wListBox, index: int = -1) {.validate.} =
  ## Selects an item in the list box.
  ## For multiple-selection list box, -1 means select all.
  if (GetWindowLongPtr(mHwnd, GWL_STYLE) and LBS_MULTIPLESEL) != 0:
    SendMessage(mHwnd, LB_SETSEL, true, index)
  else:
    SendMessage(mHwnd, LB_SETCURSEL, index, 0)

proc deselect*(self: wListBox, index: int = -1) {.validate.} =
  ## Deselects an item in the list box.
  ## For multiple-selection list box, -1 means deselect all.
  if (GetWindowLongPtr(mHwnd, GWL_STYLE) and LBS_MULTIPLESEL) != 0:
    SendMessage(mHwnd, LB_SETSEL, false, index)
  else:
    SendMessage(mHwnd, LB_SETCURSEL, -1, 0)

proc select*(self: wListBox, text: string) =
  ## Searches and selects an item in the list box.
  let i = find(text)
  if i >= 0: select(i)

proc deselect*(self: wListBox, text: string) =
  ## Searches and deselects an item in the list box.
  let i = find(text)
  if i >= 0: deselect(i)

proc setSelection*(self: wListBox, index: int) {.validate, property, inline.} =
  ## Sets the selection to the given index. The same as select().
  select(index)

proc setSelections*(self: wListBox, text: string) {.validate, property, inline.} =
  ## Searches and sets the selection to the given text. The same as select().
  select(text)

proc setSelections*(self: wListBox, list: openarray[int]) {.validate, property, inline.} =
  ## Sets the selections.
  for i in list:
    if i >= 0: select(i)

proc setSelections*(self: wListBox, list: openarray[string]) {.validate, property, inline.} =
  ## Searches and sets the selections.
  for i in list: select(i)

proc isSelected*(self: wListBox, n: int): bool {.validate, inline.} =
  ## Determines whether an item is selected.
  result = if SendMessage(mHwnd, LB_GETSEL, n, 0) == 0: false else: true

proc setText*(self: wListBox, index: int, text: string) {.validate, property.} =
  ## Sets the label for the given item.
  if index >= 0:
    let reselect = isSelected(index)
    delete(index)
    insert(index, text)
    if reselect:
      select(index)

proc setFirstItem*(self: wListBox, index: int) {.validate, property, inline.} =
  ## Set the specified item to be the first visible item.
  SendMessage(mHwnd, LB_SETTOPINDEX, index, 0)

proc getTopItem*(self: wListBox): int {.validate, property, inline.} =
  ## Return the index of the topmost visible item.
  result = int SendMessage(mHwnd, LB_GETTOPINDEX, 0, 0)

proc hitTest*(self: wListBox, x, y: int): int {.validate, inline.} =
  ## Returns the item located at point, or wNOT_FOUND(-1) if there is no item located at point.

  # The return value contains the index of the nearest item in the LOWORD.
  # The HIWORD is zero if the specified point is in the client area of the list box,
  # or one if it is outside the client area.
  let ret = SendMessage(mHwnd, LB_ITEMFROMPOINT, 0, MAKELPARAM(x, y))
  result = if HIWORD(ret) != 0: -1 else: int LOWORD(ret)

proc hitTest*(self: wListBox, pos: wPoint): int {.validate, inline.} =
  ## Returns the item located at point, or wNOT_FOUND(-1) if there is no item located at point.
  result = hitTest(pos.x, pos.y)

proc getCountPerPage*(self: wListBox): int {.validate, property.} =
  ## Return the number of items that can fit vertically in the visible area of the listbox.
  let size = getSize()
  let itemHeight = int SendMessage(mHwnd, LB_GETITEMHEIGHT, 0, 0)
  result = size.height div itemHeight

proc ensureVisible*(self: wListBox, index: int) {.validate, property.} =
  ## Ensure that the item with the given index is currently shown.
  if index >= 0:
    var rect: RECT
    if LB_ERR == SendMessage(mHwnd, LB_GETITEMRECT, index, &rect): return

    if rect.top < 0:
      setFirstItem(index)

    if rect.bottom.int > getSize().height:
      setFirstItem(index - getCountPerPage() + 1)

proc isSorted*(self: wListBox): bool {.validate, inline.} =
  ## Return true if the listbox has wLbSort style.
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and LBS_SORT) != 0

proc countSize(self: wListBox, minItem: int, rate: float): wSize =
  const maxItem = 10
  let
    lineHeight = getLineControlDefaultHeight(mFont.mHandle)
    style = GetWindowLongPtr(mHwnd, GWL_STYLE)
    count = len()

  proc countWidth(rate: float): int =
    result = lineHeight # minimum width
    for text in self.items():
      let size = getTextFontSize(text, mFont.mHandle)
      result = max(result, int(size.width.float * rate) + 8)

  let itemHeight = int SendMessage(mHwnd, LB_GETITEMHEIGHT, 0, 0)
  result.width = countWidth(rate)
  result.height = min(max(count, minItem), maxItem) * itemHeight + 2 # not too tall, not too small

  if (style and WS_VSCROLL) != 0 and ((style and LBS_DISABLENOSCROLL) != 0 or count > maxItem):
    result.width += GetSystemMetrics(SM_CXVSCROLL)

method getDefaultSize*(self: wListBox): wSize =
  ## Returns the default size for the control.
  # width of longest item + 30% x an integral number of items (3 items minimum)
  result = countSize(3, 1.3)

method getBestSize*(self: wListBox): wSize =
  ## Returns the best acceptable minimal size for the control.
  result = countSize(1, 1.0)

method trigger(self: wListBox) =
  for i in 0..<mInitCount:
    let text = mInitData[i]
    SendMessage(mHwnd, LB_ADDSTRING, 0, &T(text))

proc init(self: wListBox, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint,
    size = wDefaultSize, choices: openarray[string] = [], style: wStyle = 0) =

  mInitData = cast[ptr UncheckedArray[string]](choices)
  mInitCount = choices.len

  self.wControl.init(className=WC_LISTBOX, parent=parent, id=id, label="", pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or LBS_NOTIFY or LBS_NOINTEGRALHEIGHT)

  # a list box by default have white background, not parent's background
  setBackgroundColor(wWhite)

  if (style and wLbNoSel) != 0:
    mFocusable = false

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd:
      case HIWORD(event.mWparam):
      of LBN_SELCHANGE:
        self.processMessage(wEvent_ListBox, event.mWparam, event.mLparam)
      of LBN_DBLCLK:
        self.processMessage(wEvent_ListBoxDoubleClick, event.mWparam, event.mLparam)
      else: discard

  hardConnect(wEvent_Navigation) do (event: wEvent):
    if event.keyCode in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
      event.veto

proc ListBox*(parent: wWindow, id: wCommandID = wDefaultID, pos = wDefaultPoint, size = wDefaultSize,
    choices: openarray[string] = [], style: wStyle = wLbSingle): wListBox {.discardable.} =
  ## Constructor, creating and showing a list box.
  wValidate(parent)
  new(result)
  result.init(parent=parent, id=id, pos=pos, size=size, choices=choices, style=style)
