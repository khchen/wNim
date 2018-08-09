
proc isMultiLine*(self: wTextCtrl): bool =
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and ES_MULTILINE) != 0

proc isEditable*(self: wTextCtrl): bool =
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and ES_READONLY) == 0

proc isSingleLine*(self: wTextCtrl): bool =
  result = not isMultiLine()

proc discardEdits*(self: wTextCtrl) =
  SendMessage(mHwnd, EM_SETMODIFY, 0, 0)

proc markDirty*(self: wTextCtrl) =
  SendMessage(mHwnd, EM_SETMODIFY, 1, 0)

proc setModified*(self: wTextCtrl, modified: bool) =
  SendMessage(mHwnd, EM_SETMODIFY, modified, 0)

proc isModified*(self: wTextCtrl): bool =
  SendMessage(mHwnd, EM_GETMODIFY, 0, 0) != 0

proc setEditable*(self: wTextCtrl, flag: bool) =
  SendMessage(mHwnd, EM_SETREADONLY, not flag, 0)

proc setMargins*(self: wTextCtrl, left: int, right: int = wDefault) =
  var right = right
  if right == wDefault: right = left
  SendMessage(mHwnd, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, MAKELONG(left, right))

proc getMargins*(self: wTextCtrl): tuple[left, right: int] =
  let ret = SendMessage(mHwnd, EM_GETMARGINS, 0, 0)
  result.left = LOWORD(ret).int
  result.right = HIWORD(ret).int

proc xyToPosition*(self: wTextCtrl, x, y: int): int =
  result = SendMessage(mHwnd, EM_LINEINDEX, y, 0).int + x

proc xyToPosition*(self: wTextCtrl, pos: wPoint): int =
  result = xyToPosition(pos.x, pos.y)

proc getNumberOfLines*(self: wTextCtrl): int =
  SendMessage(mHwnd, EM_GETLINECOUNT, 0, 0).int

proc getLengthOfLineContainingPos(self: wTextCtrl, pos: int): int =
  result = SendMessage(mHwnd, EM_LINELENGTH, pos, 0).int

proc getLineLength*(self: wTextCtrl, line: int): int =
  result = getLengthOfLineContainingPos(xyToPosition(0, line))

proc getLastPosition*(self: wTextCtrl): int =
  if isMultiLine():
    let lastLineStart = xyToPosition(0, getNumberOfLines() - 1)
    let lastLineLength = getLengthOfLineContainingPos(lastLineStart)
    result = lastLineStart + lastLineLength

  else:
    result = SendMessage(mHwnd, EM_LINELENGTH, 0, 0).int

proc isEmpty*(self: wTextCtrl): bool =
  result = getLastPosition() == 0

proc positionToXY*(self: wTextCtrl, pos: int): wPoint =
  var line: int

  if mRich:
    line = SendMessage(mHwnd, EM_EXLINEFROMCHAR, 0, pos).int
  else:
    line = SendMessage(mHwnd, EM_LINEFROMCHAR, pos, 0).int

  # even if pos is too large, line is still last line
  let posLineStart = xyToPosition(0, line)

  result.x = pos - posLineStart
  result.y = line

  if result.x > getLineLength(line):
    raise newException(IndexError, "index out of bounds")

proc showPosition*(self: wTextCtrl, pos: int) =
  let
    currentLine = SendMessage(mHwnd, EM_GETFIRSTVISIBLELINE, 0, 0)
    toLine = SendMessage(mHwnd, EM_LINEFROMCHAR, pos, 0)
    lineCount = toLine - currentLine

  if lineCount != 0:
    SendMessage(mHwnd, EM_LINESCROLL, 0, lineCount)

# We implementation selection and range by nim Slice object
# In nim, slice a..b are included a and b

proc getSelection*(self: wTextCtrl): Slice[int] =
  # if result.b < result.a means no selection
  discard SendMessage(mHwnd, EM_GETSEL, addr result.a, addr result.b)
  result.b -= 1

proc getInsertionPoint*(self: wTextCtrl): int =
  result = getSelection().a

proc setSelection*(self: wTextCtrl, range = Slice[int](a: -1, b: -1)) =
  var range = range
  if range.a == -1 and range.b == -1:
    # a = b = -1 -> select all -> wparam = 0, lparam = -1
    range.a = 0
  else:
    range.b += 1

  SendMessage(mHwnd, EM_SETSEL, range.a, range.b)

proc setInsertionPoint*(self: wTextCtrl, pos: int = -1) =
  var pos = pos
  if pos == -1:
    pos = getLastPosition()

  SendMessage(mHwnd, EM_SETSEL, pos, pos)

proc setInsertionPointEnd*(self: wTextCtrl) =
  setInsertionPoint()

proc selectAll*(self: wTextCtrl) =
  setSelection()

proc selectNone*(self: wTextCtrl) =
  setInsertionPoint(getInsertionPoint())

proc copy*(self: wTextCtrl) =
  SendMessage(mHwnd, WM_COPY, 0, 0)

proc cut*(self: wTextCtrl) =
  SendMessage(mHwnd, WM_CUT, 0, 0)

proc paste*(self: wTextCtrl) =
  SendMessage(mHwnd, WM_COPY, 0, 0)

proc undo*(self: wTextCtrl) =
  SendMessage(mHwnd, EM_UNDO, 0, 0)

proc redo*(self: wTextCtrl) =
  SendMessage(mHwnd, if mRich: EM_REDO else: EM_UNDO, 0, 0)

proc canRedo*(self: wTextCtrl): bool =
  result = SendMessage(mHwnd, EM_CANUNDO, 0, 0) != 0

proc canUndo*(self: wTextCtrl): bool =
  result = SendMessage(mHwnd, if mRich: EM_CANREDO else: EM_CANUNDO, 0, 0) != 0

proc setMaxLength*(self: wTextCtrl, length: int) =
  if mRich:
    SendMessage(mHwnd, EM_EXLIMITTEXT, 0, length)
  else:
    SendMessage(mHwnd, EM_LIMITTEXT, length, 0)

proc setValue*(self: wTextCtrl, value: string) =
  setLabel(value)
  discardEdits()

  # MSDN:  EN_CHANGE notification code is not sent when the ES_MULTILINE style is used and the text is sent through WM_SETTEXT.
  if not mRich and isMultiLine():
    SendMessage(mParent.mHwnd, WM_COMMAND, MAKELONG(GetWindowLongPtr(mHwnd, GWLP_ID), EN_CHANGE), mHwnd)

proc changeValue*(self: wTextCtrl, value: string) =
  # not to generate the wEvent_Text event
  mDisableTextEvent = true
  setValue(value)
  mDisableTextEvent = false

proc clear*(self: wTextCtrl) =
    setValue("")

proc getRange*(self: wTextCtrl, range = Slice[int](a: -1, b: -1)): string =
  # -1..-1 is special for all text
  var range = range

  if mRich:
    if range.a == -1 and range.b == -1:
      var gtl = GETTEXTLENGTHEX(flags: GTL_DEFAULT, codepage: 1200)
      range.a = 0
      range.b = SendMessage(mHwnd, EM_GETTEXTLENGTHEX, addr gtl, 0).int

    var
      tr: TEXTRANGE
      buffer = T(range.b - range.a + 2)
    #   pbuffer = allocWString(range.b - range.a + 2)
    #   buffer = cast[wstring](pbuffer)
    # defer: dealloc(pbuffer)

    tr.lpstrText = &buffer
    tr.chrg.cpMin = range.a.int32
    tr.chrg.cpMax = range.b.int32 + 1
    SendMessage(mHwnd, EM_GETTEXTRANGE, 0, addr tr)
    result = $buffer

  else:
    result = getTitle()
    if range.a != -1 or range.b != -1:
      result = result[range]

proc getLineText*(self: wTextCtrl, line: int): string =
  let
    length = getLineLength(line)
    pbuffer = allocWString(length + 2)
    buffer = cast[wstring](pbuffer)
    size = cast[ptr WORD](&buffer)
  defer: dealloc(pbuffer)
  size[] = length.WORD

  SendMessage(mHwnd, EM_GETLINE, line, &buffer)
  result = $buffer

proc getValue*(self: wTextCtrl): string =
  result = getRange()

proc writeText*(self: wTextCtrl, text: string) =
  SendMessage(mHwnd, EM_REPLACESEL, 1, &(T(text)))

proc appendText*(self: wTextCtrl, text: string) =
  setInsertionPoint()
  writeText(text)

  if mRich and isMultiLine():
    SendMessage(mHwnd, WM_VSCROLL, SB_BOTTOM, 0)

proc getStringSelection*(self: wTextCtrl): string =
  let sel = getSelection()
  result = (if sel.b >= sel.a: getRange(sel) else: "")

proc replace*(self: wTextCtrl, range: Slice[int], value: string) =
  setSelection(range)
  writeText(value)

proc remove*(self: wTextCtrl, range: Slice[int]) =
  replace(range, "")

proc loadFile*(self: wTextCtrl, filename: string) =
  setValue(readFile(filename))

proc saveFile*(self: wTextCtrl, filename: string) =
  writeFile(filename, getValue())

method getBestSize*(self: wTextCtrl): wSize =
  if mRich:
    result = mBestSize
    # richedit's GWL_STYLE won't return WS_VSCROLL or WS_HSCROLL
    # add 2 to make sure scrollbar won't appear even WS_VSCROLL or WS_HSCROLL is set
    result.width += 2
    result.height += 2

  else:
    var maxWidth = 0
    var size: wSize
    for line in getTitle().splitLines:
      size = getTextFontSize(line, mFont.mHandle)
      maxWidth = max(size.width, maxWidth)

    let margin = getMargins()
    result.width = maxWidth + 11 + margin.left + margin.right
    result.height = size.height * getNumberOfLines() + 2

    let style = GetWindowLongPtr(mHwnd, GWL_STYLE)
    if (style and WS_VSCROLL) != 0:
      result.width += GetSystemMetrics(SM_CXVSCROLL).int

    if (style and WS_HSCROLL) != 0:
      result.height += GetSystemMetrics(SM_CYHSCROLL).int

method getDefaultSize*(self: wTextCtrl): wSize =
  result.width = 120
  result.height = getLineControlDefaultHeight(mFont.mHandle)
  if isMultiLine():
    result.height *= 3

proc wTextCtrlNotifyHandler(self: wTextCtrl, code: INT, id: UINT_PTR, lparam: LPARAM, processed: var bool): LRESULT =
  case code
  of EN_REQUESTRESIZE:
    let requestSize  = cast[ptr REQRESIZE](lparam)
    mBestSize.width = int(requestSize.rc.right - requestSize.rc.left)
    mBestSize.height = int(requestSize.rc.bottom  - requestSize.rc.top)

  else:
    return self.wControlNotifyHandler(code, id, lparam, processed)

var richDllLoaded {.threadvar.}: bool

proc wTextCtrlInit*(self: wTextCtrl, parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  mRich = ((style and wTeRich) != 0)
  mDisableTextEvent = false
  if mRich and not richDllLoaded:
    if LoadLibrary("msftedit.dll") != 0:
      richDllLoaded = true
    else:
      mRich = false
  let
    style = style and (not wTeRich)
    className = if mRich: MSFTEDIT_CLASS else: WC_EDIT

  self.wControl.init(className=className, parent=parent, id=id, label=label, pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  if (style and wTeReadOnly) != 0:
    mKeyUsed = {}

  elif (style and wTeMultiLine) != 0:
    mKeyUsed = {wUSE_TAB, wUSE_ENTER, wUSE_RIGHT, wUSE_LEFT, wUSE_UP, wUSE_DOWN}

  else:
    mKeyUsed = {wUSE_RIGHT, wUSE_LEFT}

  if mRich:
    wTextCtrl.setNotifyHandler(wTextCtrlNotifyHandler)

    SendMessage(mHwnd, EM_SETBKGNDCOLOR, 0, parent.mBackgroundColor)
    SendMessage(mHwnd, EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_REQUESTRESIZE)

    var format = PARAFORMAT2(cbSize: sizeof(PARAFORMAT2).UINT)
    format.dwMask = PFM_LINESPACING
    format.dyLineSpacing = 0
    format.bLineSpacingRule = 5
    echo SendMessage(mHwnd, EM_SETPARAFORMAT, 0, addr format)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd:
      var processed: bool
      let msg = case HIWORD(event.mWparam.int32)
      of EN_CHANGE:
        if mDisableTextEvent: 0.UINT else: wEvent_Text
      of EN_MAXTEXT: wEvent_TextMaxlen
      else: 0
      if msg != 0: event.mResult = self.mMessageHandler(self, msg, event.mWparam, event.mLparam, processed)

proc TextCtrl*(parent: wWindow, id: wCommandID = -1, label: string = "", pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wTextCtrl {.discardable.} =
  new(result)
  result.wTextCtrlInit(parent=parent, id=id, label=label, pos=pos, size=size, style=style)

# nim style getter/setter
proc editable*(self: wTextCtrl): bool = isEditable()
proc margins*(self: wTextCtrl): tuple[left, right: int] = getMargins()
proc numberOfLines*(self: wTextCtrl): int = getNumberOfLines()
proc lastPosition*(self: wTextCtrl): int = getLastPosition()
proc selection*(self: wTextCtrl): Slice[int] = getSelection()
proc insertionPoint*(self: wTextCtrl): int = getInsertionPoint()
proc value*(self: wTextCtrl): string = getValue()
proc `modified=`*(self: wTextCtrl, modified: bool) = setModified(modified)
proc `editable=`*(self: wTextCtrl, flag: bool) = setEditable(flag)
proc `margins=`*(self: wTextCtrl, margin: int) = setMargins(margin)
proc `selection=`*(self: wTextCtrl, range: Slice[int]) = setSelection(range)
proc `insertionPoint=`*(self: wTextCtrl, pos: int) = setInsertionPoint(pos)
proc `maxLength=`*(self: wTextCtrl, length: int) = setMaxLength(length)
proc `value=`*(self: wTextCtrl, value: string) = setValue(value)
