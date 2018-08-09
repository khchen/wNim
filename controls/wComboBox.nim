proc len*(self: wComboBox): int =
  result = SendMessage(mHwnd, CB_GETCOUNT, 0, 0).int

proc getCount*(self: wComboBox): int =
  result = len()

proc getString*(self: wComboBox, n: int): string =
  let maxLen = SendMessage(mHwnd, CB_GETLBTEXTLEN, n, 0).int + 1
  if maxLen <= 0:
    raise newException(IndexError, "index out of bounds")

  var
    ptext = allocWString(maxLen)
    text = cast[wstring](ptext)
  defer: dealloc(ptext)

  text.setLen(SendMessage(mHwnd, CB_GETLBTEXT, n, &text))
  result = $text

iterator items*(self: wComboBox): string =
  let count = len()
  var i = 0
  while i < count:
    yield getString(i)
    i.inc

proc insert*(self: wComboBox, n: int, text: string) =
  # Unlike the CB_ADDSTRING message, the CB_INSERTSTRING message does not cause a list with the CBS_SORT style to be sorted.
  SendMessage(mHwnd, CB_INSERTSTRING, n, &(L(text)))

proc insert*(self: wComboBox, n: int, list: openarray[string]) =
  for i, text in list:
    insert(if n < 0: n else: i + n, text)

proc append*(self: wComboBox, text: string) =
  SendMessage(mHwnd, CB_ADDSTRING, 0, &(L(text)))

proc append*(self: wComboBox, list: openarray[string]) =
  for text in list:
    append(text)

proc delete*(self: wComboBox, n: int) =
  if n >= 0:
    SendMessage(mHwnd, CB_DELETESTRING, n, 0)

proc delete*(self: wComboBox, text: string) =
  delete(find(text))

proc clear*(self: wComboBox) =
  SendMessage(mHwnd, CB_RESETCONTENT, 0, 0)

proc findString*(self: wComboBox, text: string): int =
  result = find(text)

proc getCurrentSelection*(self: wComboBox): int =
  result = SendMessage(mHwnd, CB_GETCURSEL, 0, 0).int

proc getSelection*(self: wComboBox): (int, int) =
  discard SendMessage(mHwnd, CB_GETEDITSEL, addr result[0], addr result[1])

proc getInsertionPoint*(self: wComboBox): int =
  discard SendMessage(mHwnd, CB_GETEDITSEL, addr result, 0)

proc getStringSelection*(self: wComboBox): string =
  let
    text = L(getLabel())
    sel = getSelection()
  result = $(text[sel[0]..<sel[1]])

proc setSelection*(self: wComboBox, start, last: int) =
  SendMessage(mHwnd, CB_SETEDITSEL, 0, MAKELONG(start, last))

proc select*(self: wComboBox, n: int) =
  SendMessage(mHwnd, CB_SETCURSEL, n, 0)

proc setSelection*(self: wComboBox, n: int) =
  select(n)

proc setString*(self: wComboBox, n: int, text: string) =
  if n >= 0:
    let reselect = (getCurrentSelection() == n)
    delete(n)
    insert(n, text)
    if reselect:
      select(n)

proc changeValue*(self: wComboBox, text: string) =
  # does not generate the wEvent_Text
  let kind = GetWindowLongPtr(mHwnd, GWL_STYLE).DWORD and 0b11
  if kind == wCbReadOnly:
    let n = find(text)
    select(n) # if n == -1, selection is removed
  else:
    setLabel(text)

proc setValue*(self: wComboBox, text: string) =
  # this method will generate a wEvent_Text event
  changeValue(text)

  let id = getId()
  var processed = false
  discard self.mMessageHandler(self, wEvent_Text, cast[WPARAM](id), 0, processed)

proc getValue*(self: wComboBox): string =
  result = getLabel()

proc isListEmpty*(self: wComboBox): bool =
  result = (len() == 0)

proc isTextEmpty*(self: wComboBox): bool =
  result = (getLabel().len == 0)

proc popup*(self: wComboBox) =
  SendMessage(mHwnd, CB_SHOWDROPDOWN, TRUE, 0)

proc dismiss*(self: wComboBox) =
  SendMessage(mHwnd, CB_SHOWDROPDOWN, FALSE, 0)

proc countSize(self: wComboBox, minItem: int, rate: float): wSize =
  const maxItem = 10
  let
    lineHeight = getLineControlDefaultHeight(mFont.mHandle)
    kind = GetWindowLongPtr(mHwnd, GWL_STYLE).DWORD and 0b11
    count = len()

  var cbi = COMBOBOXINFO(cbSize: sizeof(COMBOBOXINFO).DWORD)
  GetComboBoxInfo(mHwnd, cbi)

  proc countWidth(rate: float): int =
    result = lineHeight # minimum width
    for text in self.items():
      let size = getTextFontSize(text, mFont.mHandle)
      result = max(result, int(size.width.float * rate) + 8)

  if kind == wCbSimple:
    let itemHeight = SendMessage(mHwnd, CB_GETITEMHEIGHT, 0, 0).int
    result.width = countWidth(rate)
    result.height = lineHeight + min(max(count, minItem), maxItem) * itemHeight + 4 # not too tall, not too small

    let style = GetWindowLongPtr(cbi.hwndList, GWL_STYLE)
    if (style and WS_VSCROLL) != 0 and ((style and LBS_DISABLENOSCROLL) != 0 or count > maxItem):
      result.width += GetSystemMetrics(SM_CXVSCROLL).int

  else:
    result.width = countWidth(rate) + int(cbi.rcButton.right - cbi.rcButton.left) + 2
    result.height = getWindowRect(sizeOnly=true).height

method getDefaultSize*(self: wComboBox): wSize =
  # width of longest item + 30% x an integral number of items (3 items minimum)
  result = countSize(3, 1.3)

method getBestSize*(self: wComboBox): wSize =
  result = countSize(1, 1.0)

proc comboBoxEditProc(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM): LRESULT {.stdcall.} =
  var processed = false
  var wComboHwnd = hwnd
  while wComboHwnd != 0:
    let win = wAppWindowFindByHwnd(wComboHwnd)
    if win != nil and win of wComboBox:
      let self = cast[wComboBox](win)

      if msg == WM_CHAR and (wparam == VK_TAB or wparam == VK_RETURN):
        result = self.mMessageHandler(self, msg, wparam, lparam, processed)

      if not processed:
        result = CallWindowProc(self.mOldEditProc, hwnd, msg, wParam, lParam)

      return result

    wComboHwnd = GetParent(wComboHwnd)

proc wComboBoxInit(self: wComboBox, parent: wWindow, id: wCommandID = -1, value: string = "",
    pos = wDefaultPoint, size = wDefaultSize, choices: openarray[string], style: int64 = 0) =

  assert parent != nil

  var choices = @choices # so that callback can catch choices
  proc callback(self: wWindow) =
    for text in choices:
      SendMessage(mHwnd, CB_ADDSTRING, 0, &(L(text)))

  self.wControl.init(className=WC_COMBOBOX, parent=parent, id=id, pos=pos, size=size,
    style=style or WS_TABSTOP or WS_VISIBLE or WS_CHILD, callback=callback)

  mKeyUsed = {wUSE_RIGHT, wUSE_LEFT, wUSE_UP, wUSE_DOWN, wUSE_ENTER}

  var cbi = COMBOBOXINFO(cbSize: sizeof(COMBOBOXINFO).DWORD)
  GetComboBoxInfo(mHwnd, cbi)

  # we only subclass the child edit control of combobox to handle tab and enter
  # for wCbReadOnly, mHwnd == cbi.hwndItem, there is no child edit control
  if mHwnd != cbi.hwndItem:
    mOldEditProc = cast[WNDPROC](SetWindowLongPtr(cbi.hwndItem, GWL_WNDPROC, cast[LONG_PTR](comboBoxEditProc)))

  changeValue(value)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd:
      let cmdEvent = case HIWORD(event.mWparam.int32)
        of CBN_SELENDOK:
          # the system set the edit control value AFTER this event
          # however, we need let getValue() return a correct value
          let n = self.getCurrentSelection()
          if n >= 0:
            self.setLabel(self.getString(n))
          wEvent_ComboBox
        of CBN_EDITCHANGE: wEvent_Text
        of CBN_CLOSEUP: wEvent_ComboBoxCloseUp
        of CBN_DROPDOWN: wEvent_ComboBoxDropDown
        of CBN_SETFOCUS: wEvent_CommandSetFocus
        of CBN_KILLFOCUS: wEvent_CommandKillFocus
        of CBN_DBLCLK: wEvent_CommandLeftDoubleClick
        else: 0

      if cmdEvent != 0:
        var processed: bool
        event.mResult = self.mMessageHandler(self, cmdEvent, event.mWparam, event.mLparam, processed)

proc ComboBox*(parent: wWindow, id: wCommandID = -1, value: string = "",
    pos = wDefaultPoint, size = wDefaultSize, choices: openarray[string], style: int64 = 0): wComboBox {.discardable.} =

  new(result)
  result.wComboBoxInit(parent=parent, id=id, value=value, pos=pos, size=size, choices=choices, style=style)

# nim style getter/setter

proc count*(self: wComboBox): int = len()
proc currentSelection*(self: wComboBox): int = getCurrentSelection()
proc selection*(self: wComboBox): (int, int) = getSelection()
proc insertionPoint*(self: wComboBox): int = getInsertionPoint()
proc stringSelection*(self: wComboBox): string = getStringSelection()
proc value*(self: wComboBox): string = getValue()
proc `selection=`*(self: wComboBox, pos: int) = setSelection(pos)
proc `value=`*(self: wComboBox, text: string) = setValue(text)
