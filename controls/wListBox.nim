
proc len*(self: wListBox): int =
  result = SendMessage(mHwnd, LB_GETCOUNT, 0, 0).int

proc getCount*(self: wListBox): int =
  result = len()

proc getString*(self: wListBox, n: int): string =
  let maxLen = SendMessage(mHwnd, LB_GETTEXTLEN, n, 0).int + 1
  if maxLen <= 0:
    raise newException(IndexError, "index out of bounds")

  var
    ptext = allocWString(maxLen)
    text = cast[wstring](ptext)
  defer: dealloc(ptext)

  text.setLen(SendMessage(mHwnd, LB_GETTEXT, n, &text))
  result = $text

iterator items*(self: wListBox): string =
  let count = len()
  var i = 0
  while i < count:
    yield getString(i)
    i.inc

proc insert*(self: wListBox, n: int, text: string) =
  # Unlike the LB_ADDSTRING message, the LB_INSERTSTRING message does not cause a list with the LBS_SORT style to be sorted.
  SendMessage(mHwnd, LB_INSERTSTRING, n, &(T(text)))

proc insert*(self: wListBox, n: int, list: openarray[string]) =
  for i, text in list:
    insert(if n < 0: n else: i + n, text)

proc append*(self: wListBox, text: string) =
  SendMessage(mHwnd, LB_ADDSTRING, 0, &(T(text)))

proc append*(self: wListBox, list: openarray[string]) =
  for text in list:
    append(text)

proc delete*(self: wListBox, n: int) =
  if n >= 0:
    SendMessage(mHwnd, LB_DELETESTRING, n, 0)

proc delete*(self: wListBox, text: string) =
  delete(find(text))

proc clear*(self: wListBox) =
  SendMessage(mHwnd, LB_RESETCONTENT, 0, 0)

proc findString*(self: wListBox, text: string): int =
  result = find(text)

proc getSelection*(self: wListBox): int =
  # don't use in multiple-selection list box
  result = SendMessage(mHwnd, LB_GETCURSEL, 0, 0).int

proc getSelections*(self: wListBox): seq[int] =
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and LBS_MULTIPLESEL) != 0:
    let count = len()
    if count > 0:
      var buffer = newSeq[int32](count)
      let selCount = SendMessage(mHwnd, LB_GETSELITEMS, count, addr buffer[0]).int
      newSeq(result, selCount)
      for i in 0..<selCount:
        result[i] = buffer[i]

    else:
      result = @[]

  else:
    newSeq(result, 1)
    result[0] = getSelection()

proc select*(self: wListBox, n: int) =
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and LBS_MULTIPLESEL) != 0:
    # select(wNotFound) means deselect all
    SendMessage(mHwnd, LB_SETSEL, if n == wNotFound: false else: true, n)
  else:
    SendMessage(mHwnd, LB_SETCURSEL, n, 0)

proc deselect*(self: wListBox, n: int) =
  # for multiple-selection list box only
  let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
  if (style and LBS_MULTIPLESEL) != 0:
    # deselect(wNotFound) means select all
    SendMessage(mHwnd, LB_SETSEL, if n == wNotFound: true else: false, n)

proc setSelection*(self: wListBox, n: int) =
  select(n)

proc isSelected*(self: wListBox, n: int): bool =
  result = if SendMessage(mHwnd, LB_GETSEL, n, 0) == 0: false else: true

proc setStringSelection*(self: wListBox, text: string, flag = true) =
  let n = find(text)
  if n != -1:
    if flag:
      select(n)
    else:
      deselect(n)

proc setString*(self: wListBox, n: int, text: string) =
  if n >= 0:
    let reselect = isSelected(n)
    delete(n)
    insert(n, text)
    if reselect:
      select(n)

proc setFirstItem*(self: wListBox, n: int) =
  SendMessage(mHwnd, LB_SETTOPINDEX, n, 0)

proc getTopItem*(self: wListBox): int =
  result = SendMessage(mHwnd, LB_GETTOPINDEX, 0, 0).int

proc hitTest*(self: wListBox, x, y: int): int =
  let ret = SendMessage(mHwnd, LB_ITEMFROMPOINT, 0, MAKELPARAM(x, y))
  result = if HIWORD(ret) != 0: -1 else: LOWORD(ret).int

proc hitTest*(self: wListBox, pos: wPoint): int =
  result = hitTest(pos.x, pos.y)

proc getCountPerPage*(self: wListBox): int =
  let size = getSize()
  let itemHeight = SendMessage(mHwnd, LB_GETITEMHEIGHT, 0, 0).int
  result = size.height div itemHeight

proc ensureVisible*(self: wListBox, n: int) =
  if n >= 0:
    var rect: RECT
    if LB_ERR == SendMessage(mHwnd, LB_GETITEMRECT, n, addr rect): return

    if rect.top < 0:
      setFirstItem(n)

    if rect.bottom.int > getSize().height:
      setFirstItem(n - getCountPerPage() + 1)

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

  let itemHeight = SendMessage(mHwnd, LB_GETITEMHEIGHT, 0, 0).int
  result.width = countWidth(rate)
  result.height = min(max(count, minItem), maxItem) * itemHeight + 2 # not too tall, not too small

  if (style and WS_VSCROLL) != 0 and ((style and LBS_DISABLENOSCROLL) != 0 or count > maxItem):
    result.width += GetSystemMetrics(SM_CXVSCROLL).int

method getDefaultSize*(self: wListBox): wSize =
  # width of longest item + 30% x an integral number of items (3 items minimum)
  result = countSize(3, 1.3)

method getBestSize*(self: wListBox): wSize =
  result = countSize(1, 1.0)

proc wListBoxInit*(self: wListBox, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize,
    choices: openarray[string] = [], style: int64 = 0) =

  assert parent != nil

  var choices = @choices # so that callback can catch choices
  proc callback(self: wWindow) =
    for text in choices:
      SendMessage(mHwnd, LB_ADDSTRING, 0, &(T(text)))

  self.wControl.init(className=WC_LISTBOX, parent=parent, id=id, label="", pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or LBS_NOTIFY or LBS_NOINTEGRALHEIGHT, callback=callback)

  mKeyUsed = {wUSE_RIGHT, wUSE_LEFT, wUSE_UP, wUSE_DOWN}

proc ListBox*(parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize,
    choices: openarray[string] = [], style: int64 = 0): wListBox =

  new(result)
  result.wListBoxInit(parent=parent, id=id, pos=pos, size=size, choices=choices, style=style)

# nim style getter/setter

proc count*(self: wListBox): int = getCount()
proc selection*(self: wListBox): int = getSelection()
proc selections*(self: wListBox): seq[int] = getSelections()
proc topItem*(self: wListBox): int = getTopItem()
proc countPerPage*(self: wListBox): int = getCountPerPage()
proc `selection=`*(self: wListBox, n: int) = setSelection(n)
proc `sirstItem=`*(self: wListBox, n: int) = setFirstItem(n)
