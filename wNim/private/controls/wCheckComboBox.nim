#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A checkcombobox is like a read-only combobox but in which the items
## in the dropdown are preceded by a checkbox.
#
## :Appearance:
##   .. image:: images/wCheckComboBox.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wCcSort                         Sorts the entries in the list alphabetically.
##   wCcNeededScroll                 Only create a vertical scrollbar if needed.
##   wCcAlwaysScroll                 Always show a vertical scrollbar.
##   wCcEndEllipsis                  If the text value is too long, it is truncated and ellipses are added.
##   wCcNormalColor                  Use normal color to draw the control instead of read-only color.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_CheckComboBox             When the value of the checkcombobox changed by user.
##   wEvent_CheckComboBoxCloseUp      When the listbox of the checkcombobox disappears.
##   wEvent_CheckComboBoxDropDown     When the listbox part of the checkcombobox is shown.
##   wEvent_CommandSetFocus           When the control receives the keyboard focus.
##   wEvent_CommandKillFocus          When the control loses the keyboard focus.
##   ===============================  =============================================================

include ../pragma
import strutils
import ../wBase, ../gdiobjects/wCursor, ../dc/[wPaintDC, wClientDC], wControl, wComboBox
# import ../wEvent # compiler bug?
export wControl

const
  wCcSort* = CBS_SORT
  wCcNeededScroll* = WS_VSCROLL
  wCcAlwaysScroll* = WS_VSCROLL or CBS_DISABLENOSCROLL
  # CBS_DROPDOWNLIST = 3, so 1 and 2 are free to use
  wCcEndEllipsis* = 1
  wCcNormalColor* = 2
  SELECT = 0x01
  DISABLE = 0x02

type
  wCheckComboBoxSelection = object
    ctrl: wCheckComboBox

# When reuse the code of wComboBox, make sure it only relay on mHwnd

proc getCount*(self: wCheckComboBox): int {.validate, property, inline.} =
  ## Returns the number of items in the control.
  result = cast[wComboBox](self).getCount()

proc len*(self: wCheckComboBox): int {.validate, inline.} =
  ## Returns the number of items in the control.
  result = cast[wComboBox](self).len()

proc getText*(self: wCheckComboBox, index: int): string {.validate, property, inline.} =
  ## Returns the text of the item with the given index.
  result = cast[wComboBox](self).getText(index)

proc `[]`*(self: wCheckComboBox, index: int): string {.validate, inline.} =
  ## Returns the text of the item with the given index.
  ## Raise error if index out of bounds.
  result = cast[wComboBox](self).`[]`(index)

iterator items*(self: wCheckComboBox): string {.validate, inline.} =
  ## Iterate each item in this control.
  for i in 0..<self.len:
    yield self.getText(i)

iterator pairs*(self: wCheckComboBox): (int, string) {.validate, inline.} =
  ## Iterates over each item in this control. Yields ``(index, [index])`` pairs.
  var i = 0
  for item in self:
    yield (i, item)
    inc i

proc insert*(self: wCheckComboBox, pos: int, text: string) {.validate, inline.} =
  ## Inserts the given string before the specified position.
  ## Notice that the inserted item won't be sorted even the listbox has wCbSort
  ## style. If pos is -1, the string is added to the end of the list.
  cast[wComboBox](self).insert(pos, text)

proc insert*(self: wCheckComboBox, pos: int, list: openarray[string]) {.validate, inline.} =
  ## Inserts multiple strings in the same time.
  cast[wComboBox](self).insert(pos, list)

proc append*(self: wCheckComboBox, text: string) {.validate, inline.} =
  ## Appends the given string to the end. If the checkcombobox has the wCbSort style,
  ## the string is inserted into the list and the list is sorted.
  cast[wComboBox](self).append(text)

proc append*(self: wCheckComboBox, list: openarray[string]) {.validate, inline.} =
  ## Appends multiple strings in the same time.
  cast[wComboBox](self).append(list)

proc delete*(self: wCheckComboBox, index: int) {.validate, inline.} =
  ## Delete a string in the checkcombobox.
  cast[wComboBox](self).delete(index)

proc delete*(self: wCheckComboBox, text: string)  {.validate, inline.} =
  ## Search and delete the specified string in the checkcombobox.
  cast[wComboBox](self).delete(text)

proc findText*(self: wCheckComboBox, text: string): int {.validate, inline.} =
  ## Finds an item whose label matches the given text.
  result = cast[wComboBox](self).findText(text)

proc setBit(self: wCheckComboBox, index: int, bit: int, flag: bool) {.validate.} =
  var data = SendMessage(self.mHwnd, CB_GETITEMDATA, index, 0)
  if flag:
    data = data or bit
  else:
    data = data and (not bit)
  SendMessage(self.mHwnd, CB_SETITEMDATA, index, data)

proc getBit(self: wCheckComboBox, index: int, bit: int): bool {.validate.} =
  var data = SendMessage(self.mHwnd, CB_GETITEMDATA, index, 0)
  result = (data and bit) == bit

proc selectImpl(self: wCheckComboBox, index: int, flag: bool) {.validate.} =
  var data = SendMessage(self.mHwnd, CB_GETITEMDATA, index, 0)
  if (data and DISABLE) == DISABLE: return

  if flag:
    data = data or SELECT
  else:
    data = data and (not SELECT)
  SendMessage(self.mHwnd, CB_SETITEMDATA, index, data)

proc isSelected*(self: wCheckComboBox, index: int): bool {.validate, inline.} =
  ## Determines whether an item is selected.
  result = self.getBit(index, SELECT)

proc isDisabled*(self: wCheckComboBox, index: int): bool {.validate, inline.} =
  ## Determines whether an item is disabled.
  result = self.getBit(index, DISABLE)

proc update(self: wCheckComboBox) {.validate.} =
  let oldValue = self.mValue
  let count = self.len
  var s = newSeqOfCap[string](count)
  for i in 0..<count:
    if self.isSelected(i):
      s.add self.getText(i)

  self.mValue = s.join(self.mSeparator)
  if oldValue != self.mValue:
    self.refresh(false)
    self.mList.refresh(false)

proc select*(self: wCheckComboBox, index: int = -1) {.validate.} =
  ## Selects an item, -1 means all items.
  if index >= 0:
    self.selectImpl(index, true)
  else:
    for i in 0..<self.len: self.selectImpl(i, true)
  self.update()

proc select*(self: wCheckComboBox, text: string) {.validate.} =
  ## Selects an item by given text.
  let index = self.findText(text)
  if index >= 0:
    self.select(index)

proc selectAll*(self: wCheckComboBox) {.validate, inline.} =
  ## Selects all items.
  self.select(-1)

proc deselect*(self: wCheckComboBox, index: int = -1) {.validate.} =
  ## Deselects an item, -1 means all items.
  if index >= 0:
    self.selectImpl(index, false)
  else:
    for i in 0..<self.len: self.selectImpl(i, false)
  self.update()

proc deselect*(self: wCheckComboBox, text: string) {.validate.} =
  ## Deselects an item by given text.
  let index = self.findText(text)
  if index >= 0:
    self.deselect(index)

proc deselectAll*(self: wCheckComboBox) {.validate, inline.} =
  ## Deselects all items.
  self.deselect(-1)

proc toggle*(self: wCheckComboBox, index: int) {.validate.} =
  ## Toggle an item.
  if index >= 0:
    if self.isSelected(index):
      self.deselect(index)
    else:
      self.select(index)

proc toggle*(self: wCheckComboBox, text: string) {.validate.} =
  ## Toggle an item by given text.
  let index = self.findText(text)
  if index >= 0:
    self.toggle(index)

proc disable*(self: wCheckComboBox, index: int) {.validate.} =
  ## Disables an item, -1 means all items.
  if index >= 0:
    self.setBit(index, DISABLE, true)
  else:
    for i in 0..<self.len: self.setBit(i, DISABLE, true)
  self.mList.refresh(false)

proc disable*(self: wCheckComboBox, text: string) {.validate.} =
  ## Disables an item by given text.
  let index = self.findText(text)
  if index >= 0:
    self.disable(index)

proc disableAll*(self: wCheckComboBox) {.validate, inline.} =
  ## Disables all items.
  self.disable(-1)

proc enable*(self: wCheckComboBox, index: int) {.validate.} =
  ## Enables an item, -1 means all items.
  if index >= 0:
    self.setBit(index, DISABLE, false)
  else:
    for i in 0..<self.len: self.setBit(i, DISABLE, false)
  self.mList.refresh(false)

proc enable*(self: wCheckComboBox, text: string) {.validate.} =
  ## Enables an item by given text.
  let index = self.findText(text)
  if index >= 0:
    self.enable(index)

proc enableAll*(self: wCheckComboBox) {.validate, inline.} =
  ## Enables all items.
  self.enable(-1)

proc setText*(self: wCheckComboBox, index: int, text: string) {.validate, property.} =
  ## Changes the text of the specified item.
  if index >= 0:
    let reselect = self.isSelected(index)
    self.delete(index)
    self.insert(index, text)
    if reselect:
      self.select(index)

proc setSeparator*(self: wCheckComboBox, sep: string) {.validate, property, inline.} =
  ## Sets the separator between itmes, default value is ", ".
  self.mSeparator = sep
  self.update()

proc getSeparator*(self: wCheckComboBox): string {.validate, property, inline.} =
  ## Gets the separator between itmes, default value is ", ".
  result = self.mSeparator

proc setValue*(self: wCheckComboBox, text: string) {.validate, property.} =
  ## Sets the text for the checkcombobox text field. This function will split
  ## the input text and then try to select the subitmes, leading or trailing
  ## spaces are ignored.
  self.deselectAll()
  for item in text.split(self.mSeparator.strip):
    self.select(item.strip)

proc getValue*(self: wCheckComboBox): string {.validate, property, inline.} =
  ## Gets the text for the checkcombobox text field.
  result = self.mValue

proc clear*(self: wCheckComboBox) {.validate, inline.} =
  ## Remove all items from a checkcombobox.
  cast[wComboBox](self).clear()
  self.update()

proc isPopup*(self: wCheckComboBox): bool {.validate, property, inline.} =
  ## Returns whether or not the listbox is popup.
  result = cast[wComboBox](self).isPopup()

proc popup*(self: wCheckComboBox) {.validate, inline.} =
  ## Shows the listbox portion of the checkcombobox.
  cast[wComboBox](self).popup()

  # Fix the mouse cursor problem (wrong cursor shape when mouse enters from outside).
  # The self.mList window will capture the mouse after popup().
  var conn: wEventConnection
  conn = self.mList.systemConnect(wEvent_MouseMove) do (event: wEvent):
    self.mList.setCursor(wArrorCursor)
    self.mList.setOverrideCursor(wArrorCursor)
    self.mList.systemDisconnect(conn)

proc dismiss*(self: wCheckComboBox) {.validate, inline.} =
  ## Hides the listbox portion of the checkcombobox.
  cast[wComboBox](self).dismiss()

proc getEmpty*(self: wCheckComboBox): string {.validate, property, inline.} =
  ## Gets the displayed text if the value is empty .
  result = self.mEmpty

proc setEmpty*(self: wCheckComboBox, text: string) {.validate, property, inline.} =
  ## Sets the displayed text if the value is empty.
  self.mEmpty = text

proc changeStyle*(self: wCheckComboBox, style: wStyle) {.validate, inline.} =
  ## Change the style of the contorl. Only wCcEndEllipsis or wCcNormalColor can
  ## be changed.
  if (style and wCcEndEllipsis) != 0:
    self.mDrawTextFlag = DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS
  else:
    self.mDrawTextFlag = DT_SINGLELINE or DT_VCENTER

  if (style and wCcNormalColor) != 0:
    self.mComboPart = CP_BORDER
  else:
    self.mComboPart = CP_READONLY

proc getCurrentSelection(self: wCheckComboBox): int {.validate, property, inline.} =
  # Returns the index of the selected item or wNotFound(-1) if no item is selected.
  # Only useful to detect current hot position in listbox, it seems not need to
  # public.
  result = cast[wComboBox](self).getSelection()

proc setCurrentSelection(self: wCheckComboBox, index: int) {.validate, property, inline.} =
  # Only useful to set current hot position in listbox, it seems not need to
  # public.
  cast[wComboBox](self).select(index)

proc getListControl*(self: wCheckComboBox): wListBox {.validate, property, inline.} =
  ## Returns the list control part of this checkcombobox.
  result = self.mList

proc selections*(self: wCheckComboBox): wCheckComboBoxSelection {.validate, inline.} =
  ## Returns a help object to iterate over, so that both *items* and *pairs* work.
  ## For example:
  ##
  ## .. code-block:: Nim
  ##   for i in checkCombobox.selections: echo i
  ##   for i, text in checkCombobox.selections: echo i, ": ", text
  result.ctrl = self

iterator items*(self: wCheckComboBoxSelection): int =
  ## Iterates over each index of the selected items.
  for i in 0..<self.ctrl.len:
    if self.ctrl.isSelected(i):
      yield i

iterator pairs*(self: wCheckComboBoxSelection): (int, string) =
  ## Iterates over each item of the selected items. Yields ``(index, [index])`` pairs.
  for i in 0..<self.ctrl.len:
    if self.ctrl.isSelected(i):
      yield (i, self.ctrl[i])

method getDefaultSize*(self: wCheckComboBox): wSize {.property.} =
  ## Returns the default size for the control.
  var line = ""
  for text in self.items():
    line.add text
    line.add self.mSeparator

  var size = getTextFontSize(line, self.mFont.mHandle, self.mHwnd)
  var cbi = COMBOBOXINFO(cbSize: sizeof(COMBOBOXINFO))
  GetComboBoxInfo(self.mHwnd, cbi)

  result.height = self.getWindowRect(sizeOnly=true).height
  result.width = max(size.width + 8, result.height) + (cbi.rcButton.right - cbi.rcButton.left) + 2

method getBestSize*(self: wCheckComboBox): wSize {.property, inline.} =
  ## Returns the best acceptable minimal size for the control.
  result = cast[wComboBox](self).countSize(1, 1.0)

when defined(useWinXP):
  proc paintXp(self: wCheckComboBox, hdc: HDC, stateId: cint, isFocused: bool,
      clientRect: var RECT, cbi: var COMBOBOXINFO) =

    DrawThemeBackground(self.mTheme, hdc, self.mComboPart, CBRO_NORMAL, clientRect, nil)
    DrawThemeBackground(self.mTheme, hdc, CP_DROPDOWNBUTTON, stateId, cbi.rcButton, nil)

    var bkColor, txColor: wColor
    if isFocused:
      bkColor = SetBkColor(hdc, GetSysColor(COLOR_HIGHLIGHT))
      txColor = SetTextColor(hdc, GetSysColor(COLOR_HIGHLIGHTTEXT))
    else:
      bkColor = SetBkColor(hdc, GetSysColor(COLOR_BTNFACE))
      txColor = SetTextColor(hdc, self.mForegroundColor)

    defer:
      SetBkColor(hdc, bkColor)
      SetTextColor(hdc, txColor)

    var rect = cbi.rcItem
    InflateRect(rect, 1, 1)
    ExtTextOut(hdc, 0, 0, ETO_OPAQUE, rect, nil, 0, nil)

    let text = if self.mValue.len == 0: self.mEmpty else: self.mValue
    rect = cbi.rcItem
    InflateRect(rect, -2, -2)
    DrawText(hdc, text, -1, rect, self.mDrawTextFlag)

    if isFocused:
      DrawFocusRect(hdc, cbi.rcItem)

proc paint(self: wCheckComboBox, hdc: HDC, stateId: cint, isFocused: bool,
    clientRect: var RECT, cbi: var COMBOBOXINFO) =

  # button state only allow CBRO_DISABLED and CBRO_NORMAL
  let buttonStateId = if stateId == CBRO_DISABLED: CBRO_DISABLED else: CBRO_NORMAL

  DrawThemeParentBackground(self.mHwnd, hdc, clientRect)
  DrawThemeBackground(self.mTheme, hdc, self.mComboPart, stateId, clientRect, nil)
  DrawThemeBackground(self.mTheme, hdc, CP_DROPDOWNBUTTONRIGHT, buttonStateId, cbi.rcButton, nil)

  let text = if self.mValue.len == 0: self.mEmpty else: self.mValue
  var rect = cbi.rcItem
  InflateRect(rect, -2, -2)
  DrawThemeText(self.mTheme, hdc, self.mComboPart, stateId, text, -1, self.mDrawTextFlag, 0, rect)

  if isFocused:
    DrawFocusRect(hdc, cbi.rcItem)

proc paintItem(self: wCheckComboBox, hdc: HDC, text: string, rect: var RECT,
    isHot, isChecked, isDisabled: bool,) =

  var rcText = rect
  var rcCheck = rect
  var size: SIZE
  GetThemePartSize(self.mCheckTheme, hdc, BP_CHECKBOX, CBS_UNCHECKEDNORMAL, nil, TS_DRAW, size)

  var gap = ((rcCheck.bottom - rcCheck.top) - size.cy) div 2
  gap = gap.clamp(2, 10)
  InflateRect(rcCheck, -gap, -gap)

  rcCheck.right = rcCheck.left + size.cx
  rcText.left = rcCheck.right + gap.clamp(5, 10)

  let stateId =
    if isDisabled:
      if isChecked: CBS_CHECKEDDISABLED
      else: CBS_UNCHECKEDDISABLED
    elif isHot:
      if isChecked: CBS_CHECKEDHOT
      else: CBS_UNCHECKEDHOT
    else:
      if isChecked: CBS_CHECKEDNORMAL
      else: CBS_UNCHECKEDNORMAL

  var bkColor, txColor: wColor = -1
  if isHot:
    bkColor = SetBkColor(hdc, GetThemeSysColor(self.mTheme, COLOR_HIGHLIGHT))
    txColor = SetTextColor(hdc, GetThemeSysColor(self.mTheme, COLOR_HIGHLIGHTTEXT))
  elif isDisabled:
    txColor = SetTextColor(hdc, GetThemeSysColor(self.mTheme, COLOR_GRAYTEXT))

  defer:
    if bkColor != -1: SetBkColor(hdc, bkColor)
    if txColor != -1: SetTextColor(hdc, txColor)

  ExtTextOut(hdc, 0, 0, ETO_OPAQUE, rect, nil, 0, nil)
  DrawThemeParentBackground(self.mHwnd, hdc, rcCheck)
  DrawThemeBackground(self.mCheckTheme, hdc, BP_CHECKBOX, stateId, rcCheck, nil)
  DrawText(hdc, text, -1, rcText, DT_SINGLELINE or DT_VCENTER)

  if isHot:
    DrawFocusRect(hdc, rect)

proc onPaint(event: wEvent) =
  let self = wBase.wCheckComboBox event.mWindow
  # There is a system bug here: When STATE_SYSTEM_PRESSED occur, the update area
  # is smaller then it should be. So we always repaint all the clinet area by
  # add this line before creating PaintDC.
  InvalidateRect(self.mHwnd, nil, FALSE)

  var clientRect: RECT
  GetClientRect(self.mHwnd, clientRect)

  var dc = PaintDC(self)
  defer: dc.delete()

  var cbi = COMBOBOXINFO(cbSize: sizeof(COMBOBOXINFO))
  GetComboBoxInfo(self.mHwnd, cbi)

  let hdc = dc.mHdc
  let isFocused = not self.mIsPopup and (self.mHwnd == GetFocus())
  let stateId =
    if not self.isEnabled(): CBRO_DISABLED
    elif cbi.stateButton == STATE_SYSTEM_PRESSED or self.mIsPopup: CBRO_PRESSED
    elif self.mMouseInWindow: CBRO_HOT
    else: CBRO_NORMAL

  when defined(useWinXP):
    if wAppWinVersion() < 6.0: # for xp only
      self.paintXp(hdc, stateId, isFocused, clientRect, cbi)
    else:
      self.paint(hdc, stateId, isFocused, clientRect, cbi)
  else:
    self.paint(hdc, stateId, isFocused, clientRect, cbi)

proc onDrawItem(event: wEvent) =
  let self = wBase.wCheckComboBox event.mWindow

  var drawItem = cast[ptr DRAWITEMSTRUCT](event.mLparam)
  if drawItem.CtlType != ODT_COMBOBOX or drawItem.hwndItem != self.mHwnd:
    return

  let hdc = drawItem.hDC
  if (drawItem.itemAction and (ODA_DRAWENTIRE or ODA_SELECT)) != 0:
    if (drawItem.itemState and ODS_COMBOBOXEDIT) != 0:
      # System will clear the rcItem here. we can redraw it later by
      # invalidate the rect, however, it cause a short term flicker.
      # So we paint the combobox again to avoid flicker.
      var cbi = COMBOBOXINFO(cbSize: sizeof(COMBOBOXINFO))
      GetComboBoxInfo(self.mHwnd, cbi)

      var clientRect: RECT
      GetClientRect(self.mHwnd, clientRect)

      when defined(useWinXP):
        if wAppWinVersion() < 6.0: # for xp only
          self.paintXp(hdc, CBRO_NORMAL, false, clientRect, cbi)
        else:
          self.paint(hdc, CBRO_NORMAL, false, clientRect, cbi)
      else:
        self.paint(hdc, CBRO_NORMAL, false, clientRect, cbi)

      InvalidateRect(self.mHwnd, drawItem.rcItem, FALSE)

    else:
      let text = self.getText(drawItem.itemID)
      let isHot = (drawItem.itemState and ODS_SELECTED) != 0
      let isChecked = self.isSelected(drawItem.itemID)
      let isDisabled = self.isDisabled(drawItem.itemID)

      self.paintItem(hdc, text, drawItem.rcItem, isHot, isChecked, isDisabled)

proc onKeyDown(event: wEvent) =
  let self = wBase.wCheckComboBox event.mWindow

  case event.getkeyCode()
  of VK_RETURN:
    if self.isPopup:
      self.dismiss()
    else:
      if self.getCurrentSelection() < 0:
        self.setCurrentSelection(0)
      self.popup()
    return

  of VK_SPACE:
    if self.isPopup:
      let pos = self.getCurrentSelection()
      if pos >= 0:
        let oldValue = self.mValue
        self.toggle(pos)
        if oldValue != self.mValue: self.processMessage(wEvent_CheckComboBox, 0, 0)
    else:
      if self.getCurrentSelection() < 0:
        self.setCurrentSelection(0)
      self.popup()
    return

  of VK_INSERT, VK_DELETE:
    if self.isPopup:
      let pos = self.getCurrentSelection()
      if pos >= 0:
        let oldValue = self.mValue
        if event.getKeyCode() == VK_INSERT:
          self.select(pos)
        else:
          self.deselect(pos)
        if oldValue != self.mValue: self.processMessage(wEvent_CheckComboBox, 0, 0)
      return

  of VK_UP, VK_PRIOR, VK_LEFT:
    if not self.isPopup:
      self.setCurrentSelection(self.len - 1)
      self.popup()
      return

  of VK_DOWN, VK_NEXT, VK_RIGHT:
    if not self.isPopup:
      self.setCurrentSelection(0)
      self.popup()
      return

  else: discard
  event.skip

method setFont*(self: wCheckComboBox, font: wFont) {.validate, property.} =
  ## Sets the font for this text control.
  wValidate(font)
  procCall wWindow(self).setFont(font)
  var dc = self.ClientDC()
  defer: dc.delete()
  let metrics = dc.getFontMetrics()
  let height = metrics.height + metrics.externalLeading + 1

  # MSDN: zero to set the height of list items
  SendMessage(self.mHwnd, CB_SETITEMHEIGHT, 0, height)

  # -1 to set the combobox height (undocumented)
  SendMessage(self.mHwnd, CB_SETITEMHEIGHT, -1, height)

method trigger(self: wCheckComboBox) =
  for i in 0..<self.mInitCount:
    self.append(self.mInitData[i])

wClass(wCheckComboBox of wControl):

  method release*(self: wCheckComboBox) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mDrawItemConn)
    self.mParent.systemDisconnect(self.mCommandConn)
    CloseThemeData(self.mTheme)
    CloseThemeData(self.mCheckTheme)
    free(self[])

  proc init*(self: wCheckComboBox, parent: wWindow, id = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, choices: openarray[string] = [],
      style: wStyle = 0) {.validate.} =
    ## Initializes a checkcombobox.
    wValidate(parent)
    self.mInitData = cast[ptr UncheckedArray[string]](choices)
    self.mInitCount = choices.len
    self.mSeparator = ", "
    self.mEmpty = ""
    self.changeStyle(style)

    let style = (style and (not CBS_OWNERDRAWVARIABLE)) or
      CBS_DROPDOWNLIST or CBS_HASSTRINGS or CBS_OWNERDRAWFIXED

    # Since setFont() method (called in wWindow.init()) will always set
    # the height we want, so we don't need to handle WM_MEASUREITEM.

    self.wControl.init(className=WC_COMBOBOX, parent=parent, id=id,
      pos=pos, size=size, style=style or WS_CHILD or WS_TABSTOP or WS_VISIBLE)

    self.mTheme = OpenThemeData(self.mHwnd, WC_COMBOBOX)
    self.mCheckTheme = OpenThemeData(self.mHwnd, WC_BUTTON)

    # Only support with visual style for now.
    if not wUsingTheme() or self.mTheme == 0 or self.mCheckTheme == 0:
      self.delete()
      raise newException(wError, "wCheckComboBox creation failed")

    self.hardConnect(WM_PAINT, onPaint)
    self.systemConnect(WM_DRAWITEM, onDrawItem)

    self.mDrawItemConn = parent.systemConnect(WM_DRAWITEM) do (event: wEvent):
      self.processMessage(WM_DRAWITEM, event.mWparam, event.mLparam)

    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      if event.mLparam == self.mHwnd:
        let cmdEvent = case HIWORD(event.mWparam)
          of CBN_CLOSEUP:
            self.mIsPopup = false
            self.refresh(false)
            wEvent_CheckComboBoxCloseUp
          of CBN_DROPDOWN:
            self.mIsPopup = true
            wEvent_CheckComboBoxDropDown
          of CBN_SETFOCUS: wEvent_CommandSetFocus
          of CBN_KILLFOCUS: wEvent_CommandKillFocus
          else: 0

        if cmdEvent != 0:
          self.processMessage(cmdEvent, event.mWparam, event.mLparam)

    var cbi = COMBOBOXINFO(cbSize: sizeof(COMBOBOXINFO))
    GetComboBoxInfo(self.mHwnd, cbi)
    self.mList = ListBox(cbi.hwndList)

    proc onListLeftDown(event: wEvent) =
      let pos = self.mList.hitTest(event.getMousePos())
      if pos >= 0:
        let oldValue = self.mValue
        self.toggle(pos)
        if oldValue != self.mValue: self.processMessage(wEvent_CheckComboBox, 0, 0)
      else:
        event.skip

    proc onListRightDown(event: wEvent) =
      let pos = self.mList.hitTest(event.getMousePos())
      if pos >= 0:
        let oldValue = self.mValue
        self.selectAll()
        if oldValue == self.mValue:
          self.deselectAll()
        if oldValue != self.mValue: self.processMessage(wEvent_CheckComboBox, 0, 0)
      else:
        self.dismiss()

    self.mList.hardConnect(wEvent_LeftDown, onListLeftDown)
    self.mList.hardConnect(wEvent_LeftDoubleClick, onListLeftDown)
    self.mList.hardConnect(wEvent_RightDown, onListRightDown)
    self.mList.hardConnect(wEvent_RightDoubleClick, onListRightDown)
    self.hardConnect(WM_KEYDOWN, onKeyDown)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
        event.veto
