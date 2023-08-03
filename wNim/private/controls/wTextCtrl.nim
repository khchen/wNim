#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A text control allows text to be displayed and edited.
##
## If the user pressed Enter key inside the control, a wEvent_TextEnter event
## will be generated. If this event is not processed, the default behavior of
## text control will be doen. However, for read-only control, wEvent_TextEnter
## will never be generated.
#
## :Appearance:
##   .. image:: images/wTextCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wTeMultiLine                    The text control allows multiple lines.
##   wTePassword                     The text will be echoed as asterisks.
##   wTeReadOnly                     The text will not be user-editable.
##   wTeNoHideSel                    Show the selection event when it doesn't have focus.
##   wTeLeft                         The text in the control will be left-justified (default).
##   wTeCentre                       The text in the control will be centered.
##   wTeCenter                       The text in the control will be centered.
##   wTeRight                        The text in the control will be right-justified.
##   wTeDontWrap                     Don't wrap at all, show horizontal scrollbar instead.
##   wTeRich                         Use rich text control, this allows to have more than 64KB
##                                   of text in the control.
##   wTeProcessTab                   With this style, press TAB key to insert a TAB character instead
##                                   of switches focus to the next control. Only works with wTeMultiLine.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_Text                      When the text changes.
##   wEvent_TextUpdate                When the control is about to redraw itself.
##   wEvent_TextMaxlen                When the user tries to enter more text into the control than the limit.
##   wEvent_TextEnter                 When pressing Enter key.
##   ===============================  =============================================================
##
##   `wTextLinkEvent <wTextLinkEvent.html>`_

include ../pragma
import strutils, streams
import ../wBase, ../wImage, wControl
export wControl

const
  EM_SETEXTENDEDSTYLE = ECM_FIRST + 10
  ES_EX_ZOOMABLE = 0x0010
  ES_EX_CONVERT_EOL_ON_PASTE = 0x0004

  # TextCtrl styles
  wTeMultiLine* = ES_MULTILINE
  wTeReadOnly* = ES_READONLY
  wTePassword* = ES_PASSWORD
  wTeNoHideSel* = ES_NOHIDESEL
  wTeLeft* = ES_LEFT
  wTeCentre* = ES_CENTER
  wTeCenter* = ES_CENTER
  wTeRight* = ES_RIGHT
  wTeDontWrap* = WS_HSCROLL or ES_AUTOHSCROLL
  wTeRich* = 0x10000000.int64 shl 32
  wTeProcessTab* = 0x4000 # not used in ES_XXXX

  # flags for autocomplete
  wAcFile* = 1
  wAcDir* = 2
  wAcMru* = 4
  wAcUrl* = 8

  # for setStyle
  wTextAlignLeft* = PFA_LEFT
  wTextAlignRight* = PFA_RIGHT
  wTextAlignCenter* = PFA_CENTER
  wTextAlignJustify* = PFA_JUSTIFY
  wNumberingBullet* = PFN_BULLET
  wNumberingArabic* = PFN_ARABIC
  wNumberingLowerLetter* = PFN_LCLETTER
  wNumberingUpperLetter* = PFN_UCLETTER
  wNumberingLowerRoman* = PFN_LCROMAN
  wNumberingUpperRoman* = PFN_UCROMAN

type
  wTabStyle* = enum
    ## Indicate the style of tab leader.
    wTabStyleSpace, wTabStyleDot, wTabStyleDash, wTabStyleUnderline, wTabStyleThickLine, wTabStyleDoubleLine

  wTabAlign* = enum
    ## Indicate the tab alignment.
    wTabAlignLeft, wTabAlignCenter, wTabAlignRight, wTabAlignDecimal, wTabAlignVertical

  wTextTabs* {.pure.} = object
    ## wTextTabs is an object used to set tabs of paragraph.
    mTabs: seq[LONG]

  wAutoCompleteProvider* = proc (self: wTextCtrl): seq[string]
    ## Callback function to provide the custom source for autocomplete

proc isMultiLine*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if this is a multi line edit control and false otherwise.
  result = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and ES_MULTILINE) != 0

proc isEditable*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if the controls contents may be edited by user.
  result = (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and ES_READONLY) == 0

proc isSingleLine*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if this is a single line edit control and false otherwise.
  result = not self.isMultiLine()

proc setModified*(self: wTextCtrl, modified: bool) {.validate, property, inline.} =
  ## Marks the control as being modified by the user or not.
  SendMessage(self.mHwnd, EM_SETMODIFY, modified, 0)

proc discardEdits*(self: wTextCtrl) {.validate, inline.} =
  ## Resets the internal modified flag as if the current changes had been saved.
  self.setModified(false)

proc markDirty*(self: wTextCtrl) {.validate, inline.} =
  ## Mark text as modified (dirty).
  self.setModified(true)

proc isModified*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if the text has been modified by user.
  SendMessage(self.mHwnd, EM_GETMODIFY, 0, 0) != 0

proc setEditable*(self: wTextCtrl, flag: bool) {.validate, property, inline.} =
  ## Makes the text item editable or read-only.
  SendMessage(self.mHwnd, EM_SETREADONLY, not flag, 0)

proc setMargin*(self: wTextCtrl, left: int, right: int)
    {.validate, property, inline.} =
  ## Set the left and right margins.
  SendMessage(self.mHwnd, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN,
    MAKELONG(left, right))

proc setMargin*(self: wTextCtrl, margin: (int, int))
    {.validate, property, inline.} =
  ## Set the left and right margins.
  self.setMargin(margin[0], margin[1])

proc setMargin*(self: wTextCtrl, margin: int) {.validate, property, inline.} =
  ## Set the left and right margins to the same value.
  self.setMargin(margin, margin)

proc getMargin*(self: wTextCtrl): tuple[left: int, right: int]
    {.validate, property, inline.} =
  ## Returns the margins.
  let ret = SendMessage(self.mHwnd, EM_GETMARGINS, 0, 0)
  result.left = int LOWORD(ret)
  result.right = int HIWORD(ret)

proc xyToPosition*(self: wTextCtrl, x: int, y: int): int {.validate, inline.} =
  ## Converts the given zero based column and line number to a position.
  result = int SendMessage(self.mHwnd, EM_LINEINDEX, y, 0) + x

proc xyToPosition*(self: wTextCtrl, pos: wPoint): int {.validate, inline.} =
  ## Converts the given zero based column and line number to a position.
  result = self.xyToPosition(pos.x, pos.y)

proc getLineCount*(self: wTextCtrl): int {.validate, property, inline.} =
  ## Gets the number of lines in the control.
  result = int SendMessage(self.mHwnd, EM_GETLINECOUNT, 0, 0)

proc getNumberOfLines*(self: wTextCtrl): int {.validate, property, inline.} =
  ## Returns the number of lines in the text control buffer. The same as
  ## getLineCount().
  result = self.getLineCount()

proc getLengthOfLineContainingPos(self: wTextCtrl, pos: int): int
    {.validate, property, inline.} =
  result = int SendMessage(self.mHwnd, EM_LINELENGTH, pos, 0)

proc getLineLength*(self: wTextCtrl, line: int): int
    {.validate, property, inline.} =
  ## Gets the length of the specified line, not including any trailing newline
  ## character
  result = self.getLengthOfLineContainingPos(self.xyToPosition(0, line))

proc getLastPosition*(self: wTextCtrl): int {.validate, property.} =
  ## Returns the zero based index of the last position in the text control,
  ## which is equal to the number of characters in the control.
  if self.isMultiLine():
    let lastLineStart = self.xyToPosition(0, self.getNumberOfLines() - 1)
    let lastLineLength = self.getLengthOfLineContainingPos(lastLineStart)
    result = lastLineStart + lastLineLength

  else:
    result = int SendMessage(self.mHwnd, EM_LINELENGTH, 0, 0)

proc isEmpty*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if the control is currently empty.
  result = self.getLastPosition() == 0

proc positionToXY*(self: wTextCtrl, pos: int): wPoint {.validate.} =
  ## Converts given position to a zero-based column, line number pair.
  var line: int
  if self.mRich:
    line = int SendMessage(self.mHwnd, EM_EXLINEFROMCHAR, 0, pos)
  else:
    line = int SendMessage(self.mHwnd, EM_LINEFROMCHAR, pos, 0)

  # even if pos is too large, line is still last line
  let posLineStart = self.xyToPosition(0, line)
  result.x = pos - posLineStart
  result.y = line

  if result.x > self.getLineLength(line):
    raise newException(IndexDefect, "index out of bounds")

proc showPosition*(self: wTextCtrl, pos: int) {.validate.} =
  ## Makes the line containing the given position visible.
  let
    currentLine = SendMessage(self.mHwnd, EM_GETFIRSTVISIBLELINE, 0, 0)
    toLine = SendMessage(self.mHwnd, EM_LINEFROMCHAR, pos, 0)
    lineCount = toLine - currentLine

  if lineCount != 0:
    SendMessage(self.mHwnd, EM_LINESCROLL, 0, lineCount)

proc getSelection*(self: wTextCtrl): Slice[int] {.validate, property, inline.} =
  ## Gets the current selection range. If result.b < result.a, there was no
  ## selection.
  SendMessage(self.mHwnd, EM_GETSEL, &result.a, &result.b)
  dec result.b # system return a==b if no selection, so -1.

proc getInsertionPoint*(self: wTextCtrl): int {.validate, property, inline.} =
  ## Returns the insertion point, or cursor, position.
  result = self.getSelection().a

proc setSelection*(self: wTextCtrl, start: int, last: int)
    {.validate, property, inline.} =
  ## Selects the text starting at the first position up to
  ## (but not including) the character at the last position.
  SendMessage(self.mHwnd, EM_SETSEL, start, last)

proc setSelection*(self: wTextCtrl, range: Slice[int])
    {.validate, property, inline.} =
  ## Selects the text in range (including).
  self.setSelection(range.a, range.b + 1)

proc selectAll*(self: wTextCtrl) {.validate, inline.} =
  ## Selects all text.
  self.setSelection(0, -1)

proc setInsertionPoint*(self: wTextCtrl, pos: int) {.validate, property, inline.} =
  ## Sets the insertion point at the given position.
  self.setSelection(pos, pos)

proc setInsertionPointEnd*(self: wTextCtrl) {.validate, property, inline.} =
  ## Sets the insertion point at the end of the text control.
  self.setInsertionPoint(self.getLastPosition())

proc selectNone*(self: wTextCtrl)  {.validate, inline.} =
  ## Deselects selected text in the control.
  self.setInsertionPoint(self.getInsertionPoint())

proc getRange*(self: wTextCtrl, range: Slice[int]): string {.validate, property.} =
  ## Returns the text in range.
  if self.mRich:
    var
      buffer = T(range.b - range.a + 2)
      textrange = TEXTRANGE(lpstrText: &buffer,
        chrg: CHARRANGE(cpMin: range.a, cpMax: range.b + 1))

    buffer.setLen(SendMessage(self.mHwnd, EM_GETTEXTRANGE, 0, &textrange))
    result = $buffer

  else:
    let text = +$(self.getTitle()) # convert to wstring so that we can count in chars
    result = $(text[range])

proc getValue*(self: wTextCtrl): string {.validate, property.} =
  ## Gets the contents of the control.
  if self.mRich:
    when winimAnsi:
      var gtl = GETTEXTLENGTHEX(flags: GTL_DEFAULT, codepage: CP_ACP)
    else:
      var gtl = GETTEXTLENGTHEX(flags: GTL_DEFAULT, codepage: 1200)

    let length = int SendMessage(self.mHwnd, EM_GETTEXTLENGTHEX, &gtl, 0)
    result = self.getRange(0..<length)
  else:
    result = self.getTitle()

proc copy*(self: wTextCtrl) {.validate, inline.} =
  ## Copies the selected text to the clipboard.
  SendMessage(self.mHwnd, WM_COPY, 0, 0)

proc cut*(self: wTextCtrl) {.validate, inline.} =
  ## Copies the selected text to the clipboard and removes it from the control.
  SendMessage(self.mHwnd, WM_CUT, 0, 0)

proc paste*(self: wTextCtrl) {.validate, inline.} =
  ## Pastes text from the clipboard to the text item.
  SendMessage(self.mHwnd, WM_COPY, 0, 0)

proc undo*(self: wTextCtrl) {.validate, inline.} =
  ## If there is an undo facility and the last operation can be undone, undoes
  ## the last operation.
  SendMessage(self.mHwnd, EM_UNDO, 0, 0)

proc redo*(self: wTextCtrl) {.validate, inline.} =
  ## If there is a redo facility and the last operation can be redone, redoes
  ## the last operation.
  SendMessage(self.mHwnd, if self.mRich: EM_REDO else: EM_UNDO, 0, 0)

proc canRedo*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if there is a redo facility available and the last operation
  ## can be redone.
  result = SendMessage(self.mHwnd, EM_CANUNDO, 0, 0) != 0

proc canUndo*(self: wTextCtrl): bool {.validate, inline.} =
  ## Returns true if there is an undo facility available and the last operation
  ## can be undone.
  result = SendMessage(self.mHwnd,
    if self.mRich: EM_CANREDO else: EM_CANUNDO, 0, 0) != 0

proc setMaxLength*(self: wTextCtrl, length: int) {.validate, property.} =
  ## This function sets the maximum number of characters the user can enter into
  ## the control.
  if self.mRich:
    SendMessage(self.mHwnd, EM_EXLIMITTEXT, 0, length)
  else:
    SendMessage(self.mHwnd, EM_LIMITTEXT, length, 0)

proc setValue*(self: wTextCtrl, value: string) {.validate, property.} =
  ## Sets the new text control value.
  ## Note that, unlike most other functions changing the controls values,
  ## this function generates a wEvent_Text event. To avoid this you can use
  ## changeValue() instead.
  self.setLabel(value)
  self.discardEdits()

  # MSDN: EN_CHANGE notification code is not sent when the
  # ES_MULTILINE style is used and the text is sent through WM_SETTEXT.
  if not self.mRich and self.isMultiLine():
    SendMessage(self.mParent.mHwnd, WM_COMMAND,
      MAKELONG(GetWindowLongPtr(self.mHwnd, GWLP_ID), EN_CHANGE), self.mHwnd)

proc changeValue*(self: wTextCtrl, value: string) {.validate.} =
  ## Sets the new text control value.
  ## This functions does not generate the wEvent_Text event.
  self.mDisableTextEvent = true
  self.setValue(value)
  self.mDisableTextEvent = false

proc clear*(self: wTextCtrl) {.validate, inline.} =
  ## Clears the text in the control.
  self.setValue("")

proc getLineText*(self: wTextCtrl, line: int): string {.validate, property.} =
  ## Returns the contents of a given line in the text control, not including any
  ## trailing newline character.
  let length = self.getLineLength(line)
  var buffer = T(length + 2)
  let size = cast[ptr WORD](&buffer)
  size[] = WORD length
  buffer.setLen(SendMessage(self.mHwnd, EM_GETLINE, line, &buffer))
  result = $buffer

proc writeText*(self: wTextCtrl, text: string) {.validate, inline.} =
  ## Writes the text into the text control at the current insertion position.
  SendMessage(self.mHwnd, EM_REPLACESEL, 1, &T(text))

proc appendText*(self: wTextCtrl, text: string) {.validate.} =
  ## Appends the text to the end of the text control.
  self.setInsertionPointEnd()
  self.writeText(text)

  if self.mRich and self.isMultiLine():
    SendMessage(self.mHwnd, WM_VSCROLL, SB_BOTTOM, 0)

proc writeRtfText*(self: wTextCtrl, text: string) {.validate, inline.} =
  ## Writes the RTF text into the text control at the current insertion position.
  ## Only works for rich text control.
  if self.mRich:
    var settextex = SETTEXTEX(flags: ST_SELECTION, codepage: 65001)
    SendMessage(self.mHwnd, EM_SETTEXTEX, &settextex, &text)

proc appendRtfText*(self: wTextCtrl, text: string) {.validate.} =
  ## Appends the RTF text to the end of the text control.
  ## Only works for rich text control.
  if self.mRich:
    self.setInsertionPointEnd()
    self.writeRtfText(text)

    if self.isMultiLine():
      SendMessage(self.mHwnd, WM_VSCROLL, SB_BOTTOM, 0)

proc generateLinkRtf(link: string, alias = ""): string =
  let
    alias = if alias.len == 0: link else: alias
    link = link.replace("\"", "")

  result = r"""{\rtf{\field{\*\fldinst HYPERLINK "$#"}{\fldrslt $#}}}""" %
    [link, alias]

proc generateImageRtf(image: wImage, scale: float, dpi: int): string =
  when not defined(Nimdoc):
    let
      (width, height) = image.size
      png = image.saveData(wImageTypePng)
      wgoal = width * 1440 div dpi
      hgoal = height * 1440 div dpi
      scale = int scale * 100

    result = r"{\rtf{\pict\pngblip\picscalex$#\picscaley$#\picwgoal$#\pichgoal$# $#}}" %
      [$scale, $scale, $wgoal, $hgoal, png.tohex]

proc writeLink*(self: wTextCtrl, link: string, alias = "") {.validate.} =
  ## Writes a link into the text control at the current insertion position.
  ## Only works for rich text control.
  ## A wEvent_TextLink event will be generated when mouse events occur over link.
  if self.mRich:
    self.writeRtfText(generateLinkRtf(link, alias))

proc appendLink*(self: wTextCtrl, link: string, alias = "") {.validate.} =
  ## Appends a link to the end of the text control.
  ## Only works for rich text control.
  ## A wEvent_TextLink event will be generated when mouse events occur over link.
  if self.mRich:
    self.appendRtfText(generateLinkRtf(link, alias))

proc writeImage*(self: wTextCtrl, image: wImage, scale = 1.0) =
  ## Writes an image into the text control at the current insertion position.
  ## Only works for rich text control.
  wValidate(image)
  if self.mRich:
    self.writeRtfText(generateImageRtf(image, scale, self.getDpi()))

proc appendImage*(self: wTextCtrl, image: wImage, scale = 1.0) {.validate.} =
  ## Appends an image to the end of the text control.
  ## Only works for rich text control.
  wValidate(image)
  if self.mRich:
    self.appendRtfText(generateImageRtf(image, scale, self.getDpi()))

proc getTextSelection*(self: wTextCtrl): string {.validate, property.} =
  ## Gets the text currently selected in the control or empty string if there is
  ## no selection.
  let sel = self.getSelection()
  result = (if sel.b >= sel.a: self.getRange(sel) else: "")

proc replace*(self: wTextCtrl, range: Slice[int], value: string)
    {.validate, inline.} =
  ## Replaces the text in range.
  self.setSelection(range)
  self.writeText(value)

proc remove*(self: wTextCtrl, range: Slice[int]) {.validate, inline.} =
  ## Removes the text in range.
  self.replace(range, "")

proc loadFile*(self: wTextCtrl, filename: string) {.validate, inline.} =
  ## Loads and displays the named file, if it exists.
  self.setValue(readFile(filename))

proc saveFile*(self: wTextCtrl, filename: string) {.validate, inline.} =
  ## Saves the contents of the control in a text file.
  writeFile(filename, self.getValue())

proc len*(self: wTextCtrl): int {.validate, inline.} =
  ## Returns the number of characters in the control.
  result = self.getLastPosition()

proc add*(self: wTextCtrl, text: string) {.validate, inline.} =
  ## Appends the text to the end of the text control. The same as appendText()
  self.appendText(text)

proc tabStyle(style: wTabStyle, align: wTabAlign): DWORD =
  result = case style
    of wTabStyleSpace: 0
    of wTabStyleDot: 0x10000000
    of wTabStyleDash: 0x20000000
    of wTabStyleUnderline: 0x30000000
    of wTabStyleThickLine: 0x40000000
    of wTabStyleDoubleLine: 0x50000000

  result = result or (case align
    of wTabAlignLeft: 0
    of wTabAlignCenter: 0x01000000
    of wTabAlignRight: 0x02000000
    of wTabAlignDecimal: 0x03000000
    of wTabAlignVertical: 0x04000000)

proc TextTabs*(offset: int, style: wTabStyle = wTabStyleSpace,
    align: wTabAlign = wTabAlignLeft): wTextTabs =
  ## Constructor for wTextTabs object used by *setStyle*.
  ## Space unit is twip (1/1440 inche).
  result.mTabs.setLen(MAX_TAB_STOPS)
  var n = offset
  for i in 0..<MAX_TAB_STOPS:
    result.mTabs[i] = (n.DWORD and 0xffffff) or tabStyle(style, align)
    n += offset

proc set*(self: var wTextTabs, index: range[0..(MAX_TAB_STOPS-1)], style: wTabStyle = wTabStyleSpace,
    align: wTabAlign = wTabAlignLeft) =
  ## Sets the style and alignment of specified tab stop.
  self.mTabs[index] = (self.mTabs[index] and 0xffffff) or tabStyle(style, align)

proc resetStyle*(self: wTextCtrl) {.validate, inline.} =
  ## Reset the style to default.
  if self.mRich:
    var format = PARAFORMAT2(cbSize: sizeof(PARAFORMAT2))
    format.wAlignment = PFA_LEFT
    format.dwMask = PFM_ALIGNMENT or PFM_STARTINDENT or PFM_OFFSET or
      PFM_RIGHTINDENT or PFM_SPACEBEFORE or PFM_SPACEAFTER or PFM_NUMBERING or
      PFM_LINESPACING or PFM_TABSTOPS

    SendMessage(self.mHwnd, EM_SETPARAFORMAT, 0, &format)

proc setStyle*(self: wTextCtrl, align = 0, indent = -1, subIndent = -1,
    rightIndent = -1, spaceBefore = -1, spaceAfter = -1, numbering = -1,
    lineSpacing = NaN, tabs = default(wTextTabs)) {.validate, property.} =
  ## Sets style of paragraph in the current selection or paragraph inserted at the insertion point.
  ## Space unit is twip (1/1440 inche).
  ## *lineSpacing* >= 0 means lines, < 0 means abs(twip).
  ## ===========================  ==============================================
  ## align                        Description
  ## ===========================  ==============================================
  ## wTextAlignLeft               Paragraphs are aligned with the left margin.
  ## wTextAlignRight              Paragraphs are aligned with the right margin.
  ## wTextAlignCenter             Paragraphs are centered.
  ## wTextAlignJustify            Paragraphs are justified by expanding the blanks alone.
  ##
  ## ===========================  ==============================================
  ## numbering                    Description
  ## ===========================  ==============================================
  ## wNumberingBullet             Insert a bullet at the beginning of each selected paragraph.
  ## wNumberingArabic             Use Arabic numbers (0, 1, 2, and so on).
  ## wNumberingLowerLetter        Use lowercase letters (a, b, c, and so on).
  ## wNumberingUpperLetter        Use lowercase Roman letters (i, ii, iii, and so on).
  ## wNumberingLowerRoman         Use uppercase letters (A, B, C, and so on).
  ## wNumberingUpperRoman         Use uppercase Roman letters (I, II, III, and so on).
  if not self.mRich: return
  var format = PARAFORMAT2(cbSize: sizeof(PARAFORMAT2))

  if align in PFA_LEFT..PFA_JUSTIFY:
    format.dwMask = format.dwMask or PFM_ALIGNMENT
    format.wAlignment = WORD align

  if indent >= 0:
    format.dwMask = format.dwMask or PFM_STARTINDENT
    format.dxStartIndent = indent

  if subIndent >= 0:
    format.dwMask = format.dwMask or PFM_OFFSET
    format.dxOffset  = subIndent

  if rightIndent >= 0:
    format.dwMask = format.dwMask or PFM_RIGHTINDENT
    format.dxRightIndent  = rightIndent

  if spaceBefore >= 0:
    format.dwMask = format.dwMask or PFM_SPACEBEFORE
    format.dySpaceBefore  = spaceBefore

  if spaceAfter >= 0:
    format.dwMask = format.dwMask or PFM_SPACEAFTER
    format.dySpaceAfter  = rightIndent

  if numbering in 0..PFN_UCROMAN:
    format.dwMask = format.dwMask or PFM_NUMBERING
    format.wNumbering = WORD numbering

  if lineSpacing == lineSpacing: # not NaN
    format.dwMask = format.dwMask or PFM_LINESPACING
    if lineSpacing >= 0:
      format.bLineSpacingRule = 5
      format.dyLineSpacing = int(lineSpacing * 20)
    else:
      format.bLineSpacingRule = 3
      format.dyLineSpacing = int abs(lineSpacing)

  if tabs.mTabs.len != 0:
    format.dwMask = format.dwMask or PFM_TABSTOPS
    format.cTabCount = SHORT min(tabs.mTabs.len, MAX_TAB_STOPS)
    copyMem(addr format.rgxTabs[0], unsafeaddr tabs.mTabs[0], sizeof(LONG) * format.cTabCount)

  SendMessage(self.mHwnd, EM_SETPARAFORMAT, 0, &format)

proc charformat(self: wTextCtrl, flag: int, font: wFont = nil, fgColor: wColor = -1, bgColor: wColor = -1) =
  var charformat = CHARFORMAT2(cbSize: sizeof(CHARFORMAT2))
  if font != nil:
    charformat.dwMask = charformat.dwMask or (CFM_SIZE or CFM_WEIGHT or CFM_FACE or CFM_CHARSET or CFM_EFFECTS)
    charformat.yHeight = LONG(font.mPointSize * 20)
    charformat.wWeight = WORD font.mWeight
    charformat.szFaceName << T(font.mFaceName)
    charformat.bCharSet = BYTE font.mEncoding
    charformat.bPitchAndFamily = BYTE font.mFamily
    if font.mItalic: charformat.dwEffects = charformat.dwEffects or CFM_ITALIC
    if font.mUnderline: charformat.dwEffects = charformat.dwEffects or CFE_UNDERLINE

  if fgColor > 0:
    charformat.dwMask = charformat.dwMask or CFM_COLOR
    charformat.crTextColor = fgColor

  if bgColor > 0:
    charformat.dwMask = charformat.dwMask or CFM_BACKCOLOR
    charformat.crBackColor = bgColor

  SendMessage(self.mHwnd, EM_SETCHARFORMAT, flag, &charformat)

proc setFormat*(self: wTextCtrl, font: wFont = nil, fgColor: wColor = -1,
    bgColor: wColor = -1) {.validate, property.} =
  ## Sets the selection and new character format for this text control if wTeRich style is specified.
  ## Using nil for font or -1 for color indicate not to change.
  if self.mRich:
    self.charformat(SCF_SELECTION, font, fgColor, bgColor)

proc setDefaultFormat*(self: wTextCtrl, font: wFont = nil, fgColor: wColor = -1,
    bgColor: wColor = -1) {.validate, property.} =
  ## Sets the default format for this text control if wTeRich style is specified.
  ## Using nil for font or -1 for color indicate not to change.
  if self.mRich:
    self.charformat(SCF_DEFAULT, font, fgColor, bgColor)

method setFont*(self: wTextCtrl, font: wFont) {.validate, property.} =
  ## Sets the font for this text control.
  wValidate(font)
  procCall wWindow(self).setFont(font)
  if self.mRich:
    self.charformat(SCF_DEFAULT, font)

proc zoom*(self: wTextCtrl, ratio = 1.0) {.validate, inline.} =
  ## Sets the zoom ratio for this text control.
  ## Ratio should be between 1/64 and 64.
  ## If ratio is zero or NaN, disable zoom if possible.
  if ratio == 0 or ratio != ratio:
    SendMessage(self.mHwnd, EM_SETEXTENDEDSTYLE, ES_EX_ZOOMABLE, 0)
    SendMessage(self.mHwnd, EM_SETZOOM, 0, 0)
  else:
    let ratio = ratio.clamp(1 / 64, 64)
    SendMessage(self.mHwnd, EM_SETEXTENDEDSTYLE, ES_EX_ZOOMABLE, ES_EX_ZOOMABLE)
    if ratio >= 1:
      SendMessage(self.mHwnd, EM_SETZOOM, int16.high, int16(int16.high.float / ratio))
    else:
      SendMessage(self.mHwnd, EM_SETZOOM, int16(int16.high.float * ratio), int16.high)

proc StreamInCallback(dwCookie: DWORD_PTR, pbBuff: LPBYTE, cb: LONG, pcb: ptr LONG): DWORD {.stdcall.} =
  let pstrm = cast[ptr Stream](dwCookie)
  if pstrm[].atEnd:
    pcb[] = 0
  else:
    pcb[] = pstrm[].readData(pbBuff, cb)
  return 0

proc StreamOutCallback(dwCookie: DWORD_PTR, pbBuff: LPBYTE, cb: LONG, pcb: ptr LONG): DWORD {.stdcall.} =
  let pstrm = cast[ptr Stream](dwCookie)
  pstrm[].writeData(pbBuff, cb)
  pcb[] = cb
  return 0

proc loadRtf*(self: wTextCtrl, rtf: string) {.validate.} =
  ## Loads and displays Rich Text Format (RTF) string. Only works for rich text control.
  if self.mRich:
    var
      strm = newStringStream(rtf)
      es = EDITSTREAM(pfnCallback: StreamInCallback, dwCookie: cast[DWORD_PTR](addr strm))

    SendMessage(self.mHwnd, EM_STREAMIN, SF_RTF, cast[LPARAM](&es))

proc saveRtf*(self: wTextCtrl, selectionOnly = false): string {.validate.} =
  ## Saves the all or selected text in Rich Text Format (RTF) string. Only works for rich text control.
  if self.mRich:
    var
      strm = newStringStream()
      es = EDITSTREAM(pfnCallback: StreamOutCallback, dwCookie: cast[DWORD_PTR](addr strm))
      flag = SF_RTF or (if selectionOnly: SFF_SELECTION else: 0)

    SendMessage(self.mHwnd, EM_STREAMOUT, flag, cast[LPARAM](&es))

    strm.setPosition(0)
    result = strm.readAll()

proc loadRtfFile*(self: wTextCtrl, filename: string) {.validate.} =
  ## Loads and displays Rich Text Format (RTF) file. Only works for rich text control.
  self.loadRtf(readFile(filename))

proc saveRtfFile*(self: wTextCtrl, filename: string, selectionOnly = false) {.validate.} =
  ## Saves the all or selected text in Rich Text Format (RTF) file. Only works for rich text control.
  writeFile(filename, self.saveRtf())

iterator lines*(self: wTextCtrl): string {.validate.} =
  ## Iterates over each line in the control.
  let count = self.getLineCount()
  for i in 0..<count:
    yield self.getLineText(i)

method getBestSize*(self: wTextCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  if self.mRich:
    result = self.mBestSize
    # richedit's GWL_STYLE won't return WS_VSCROLL or WS_HSCROLL
    # add 2 to make sure scrollbar won't appear even WS_VSCROLL or WS_HSCROLL is set
    result.width += 2
    result.height += 2

  else:
    var maxWidth = 0
    var size: wSize
    for line in self.getTitle().splitLines:
      size = getTextFontSize(line, self.mFont.mHandle, self.mHwnd)
      maxWidth = max(size.width, maxWidth)

    let margin = self.getMargin()
    result.width = maxWidth + 11 + margin.left + margin.right
    result.height = size.height * self.getNumberOfLines() + 2

    let style = GetWindowLongPtr(self.mHwnd, GWL_STYLE)
    if (style and WS_VSCROLL) != 0:
      result.width += GetSystemMetrics(SM_CXVSCROLL)

    if (style and WS_HSCROLL) != 0:
      result.height += GetSystemMetrics(SM_CYHSCROLL)

method getDefaultSize*(self: wTextCtrl): wSize {.property.} =
  ## Returns the default size for the control.
  result.width = 120
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)
  if self.isMultiLine():
    result.height *= 3

method setBackgroundColor*(self: wTextCtrl, color: wColor) {.property.} =
  ## Sets the background color of the control.
  if self.mRich: SendMessage(self.mHwnd, EM_SETBKGNDCOLOR, 0, color)
  procCall wWindow(self).setBackgroundColor(color)

proc onAutoCompleteKeyDown(event: wEvent) =
  # Autocompletion will eat the enter key event (WM_CHAR/VK_RETURN),
  # detect it in WM_KEYDOWN instead.
  let flag = event.ctrlDown or event.shiftDown or event.altDown or event.winDown
  if event.getKeyCode() == VK_RETURN and not flag:
    event.mWindow.processMessage(wEvent_TextEnter, 0, 0)
  event.skip()

proc disableAutoComplete*(self: wTextCtrl) =
  ## Disable the autocompletion.
  if not self.mPac.isNil:
    self.disconnect(WM_KEYDOWN, onAutoCompleteKeyDown)
    self.mPac.Enable(false)
    self.mPac.Release()
    self.mPac = nil

proc enableAutoComplete*(self: wTextCtrl, flags = wAcFile or wAcMru or wAcUrl): bool {.discardable.} =
  ## Enable the autocompletion and use system predefined sources. *flags* is a bitwise combination
  ## of wAcFile, wAcDir, wAcMru, wAcUrl.
  ## ==========  =================================================================================
  ## Flags       Description
  ## ==========  =================================================================================
  ## wAcFile     Include the file system and directories.
  ## wAcDir      Include the file directories only.
  ## wAcMru      Include the URLs in the user's **Recently Used** list.
  ## wAcUrl      Include the URLs in the user's **History** list.
  self.disableAutoComplete()

  block okay:
    if CoCreateInstance(&CLSID_AutoComplete, nil, CLSCTX_INPROC_SERVER, &IID_IAutoComplete, &self.mPac).FAILED: break okay

    var pac2: ptr IAutoComplete2
    if self.mPac.QueryInterface(&IID_IAutoComplete2, &pac2).SUCCEEDED:
      pac2.SetOptions(ACO_AUTOSUGGEST)
      pac2.Release()

    var pom: ptr IObjMgr
    if CoCreateInstance(&CLSID_ACLMulti, nil, CLSCTX_INPROC_SERVER, &IID_IObjMgr, &pom).FAILED: break okay
    defer: pom.Release()

    var punkSourceIsf: ptr IUnknown
    if CoCreateInstance(&CLSID_ACListISF, nil, CLSCTX_INPROC_SERVER, &IID_IUnknown, &punkSourceIsf).FAILED: break okay
    defer: punkSourceIsf.Release()

    var punkSourceMru: ptr IUnknown
    if CoCreateInstance(&CLSID_ACLMRU, nil, CLSCTX_INPROC_SERVER, &IID_IUnknown, &punkSourceMru).FAILED: break okay
    defer: punkSourceMru.Release()

    var punkSourceUrl: ptr IUnknown
    if CoCreateInstance(&CLSID_ACLHistory, nil, CLSCTX_INPROC_SERVER, &IID_IUnknown, &punkSourceUrl).FAILED: break okay
    defer: punkSourceUrl.Release()

    var pal2: ptr IACList2
    if punkSourceIsf.QueryInterface(&IID_IACList2, &pal2).SUCCEEDED:
      pal2.SetOptions(if (flags and wAcDir) != 0: ACLO_FILESYSDIRS else: ACLO_FILESYSONLY)
      pal2.Release()

    if (flags and (wAcDir or wAcFile)) != 0:
      pom.Append(punkSourceIsf)

    if (flags and wAcMru) != 0:
      pom.Append(punkSourceMru)

    if (flags and wAcUrl) != 0:
      pom.Append(punkSourceUrl)

    if self.mPac.Init(self.mHwnd, pom, nil, nil).FAILED: break okay
    self.connect(WM_KEYDOWN, onAutoCompleteKeyDown)
    return true

  return false

proc enableAutoComplete*(self: wTextCtrl, provider: wAutoCompleteProvider): bool {.discardable.} =
  ## Enable the autocompletion and use custom source.
  self.disableAutoComplete()

  if self.mEnumString.lpVtbl.isNil:
    self.mEnumString.lpVtbl = &self.mEnumString.vtbl
    self.mEnumString.window = self
    self.mEnumString.vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} = 1
    self.mEnumString.vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} = 1
    self.mEnumString.vtbl.Clone = proc(self: ptr IEnumString, ppenum: ptr ptr IEnumString): HRESULT {.stdcall.} = E_NOTIMPL
    self.mEnumString.vtbl.Skip = proc(self: ptr IEnumString, celt: ULONG): HRESULT {.stdcall.} = E_NOTIMPL

    self.mEnumString.vtbl.Next = proc(self: ptr IEnumString, celt: ULONG, rgelt: ptr LPOLESTR, pceltFetched: ptr ULONG): HRESULT {.stdcall.} =
      let pes = cast[ptr wEnumString](self)
      var fetched: ULONG = 0
      defer:
        if not pceltFetched.isNil:
          pceltFetched[] = fetched

      if pes.index < pes.list.len:
        let ws = +$(pes.list[pes.index])
        rgelt[] = cast[LPOLESTR](CoTaskMemAlloc(SIZE_T (ws.len + 2) * 2))
        if not rgelt[].isNil:
          rgelt[] <<< ws
          fetched.inc
          pes.index.inc

      return if fetched == 0: S_FALSE else: S_OK

    self.mEnumString.vtbl.Reset = proc(self: ptr IEnumString): HRESULT {.stdcall.} =
      let pes = cast[ptr wEnumString](self)
      pes.list = pes.provider(pes.window)
      pes.index = 0
      return S_OK

    self.mEnumString.vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
      if ppvObject.isNil:
        return E_POINTER

      elif IsEqualIID(riid, &IID_IEnumString):
        ppvObject[] = self
        self.AddRef()
        return S_OK

      else:
        ppvObject[] = nil
        return E_NOINTERFACE

  self.mEnumString.provider = provider

  block okay:
    if CoCreateInstance(&CLSID_AutoComplete, nil, CLSCTX_INPROC_SERVER, &IID_IAutoComplete, &self.mPac).FAILED: break okay

    var pac2: ptr IAutoComplete2
    if self.mPac.QueryInterface(&IID_IAutoComplete2, &pac2).SUCCEEDED:
      pac2.SetOptions(ACO_AUTOSUGGEST)
      pac2.Release()

    if self.mPac.Init(self.mHwnd, cast[ptr IUnknown](&self.mEnumString), nil, nil).FAILED: break okay
    self.connect(WM_KEYDOWN, onAutoCompleteKeyDown)
    return true

  return false

proc enableAutoUrlDetect*(self: wTextCtrl, enable = true): bool {.discardable.} =
  ## Enables or disables automatic detection of hyperlinks by a rich edit control.
  ## A wEvent_TextLink event will be generated when mouse events occur over url.
  if self.mRich:
    result = SendMessage(self.mHwnd, EM_AUTOURLDETECT, if enable: AURL_ENABLEEA else: 0, 0) == 0

method processNotify(self: wTextCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code
  of EN_REQUESTRESIZE:
    let requestSize  = cast[ptr REQRESIZE](lparam)
    self.mBestSize.width = int(requestSize.rc.right - requestSize.rc.left)
    self.mBestSize.height = int(requestSize.rc.bottom - requestSize.rc.top)
    return true

  of EN_LINK:
    let pEnlink = cast[ptr TENLINK](lParam)
    var event = wTextLinkEvent Event(self, wEvent_TextLink, cast[WPARAM](id), lParam)
    event.mStart = pEnlink.chrg.cpMin
    event.mEnd = pEnlink.chrg.cpMax
    event.mMouseEvent = pEnlink.msg
    return self.processEvent(event)

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

proc wTextCtrl_ParentOnCommand(self: wTextCtrl, event: wEvent) =
  if event.mLparam == self.mHwnd:
    case HIWORD(event.mWparam)
    of EN_CHANGE:
      if not self.mDisableTextEvent:
        self.processMessage(wEvent_Text, 0, 0)
    of EN_UPDATE:
      self.processMessage(wEvent_TextUpdate, 0, 0)
    of EN_MAXTEXT:
      self.processMessage(wEvent_TextMaxlen, 0, 0)
    else: discard

wClass(wTextCtrl of wControl):

  method release*(self: wTextCtrl) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mCommandConn)
    self.disableAutoComplete()
    free(self[])

  proc init*(self: wTextCtrl, parent: wWindow, id = wDefaultID,
      value: string = "", pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = wTeLeft) {.validate.} =
    ## Initializes a text control.
    wValidate(parent)
    var isProcessTab = ((style and wTeProcessTab) != 0)
    self.mRich = ((style and wTeRich) != 0)
    self.mDisableTextEvent = false

    if self.mRich and not loadRichDll():
      self.mRich = false

    var
      style = style and (not (wTeRich or wTeProcessTab))
      className = if self.mRich: MSFTEDIT_CLASS else: WC_EDIT

    if (style and wTeMultiLine) == 0:
      # single line text control should always have this style?
      style = style or ES_AUTOHSCROLL

    self.wControl.init(className=className, parent=parent, id=id, label=value,
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    SendMessage(self.mHwnd, EM_SETEXTENDEDSTYLE, ES_EX_CONVERT_EOL_ON_PASTE,
      ES_EX_CONVERT_EOL_ON_PASTE)

    if self.mRich:
      SendMessage(self.mHwnd, EM_SETEVENTMASK, 0, ENM_CHANGE or
        ENM_REQUESTRESIZE or ENM_UPDATE or ENM_LINK)

      # rich edit's scroll bar needs these to work well
      self.systemConnect(WM_VSCROLL, wWindow_DoScroll)
      self.systemConnect(WM_HSCROLL, wWindow_DoScroll)

    # a text control by default have white background, not parent's background
    self.setBackgroundColor(wWhite)

    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      wTextCtrl_ParentOnCommand(self, event)

    # for readonly control, don't generate wEvent_TextEnter event.
    if (style and wTeReadOnly) == 0:
      self.hardConnect(WM_CHAR) do (event: wEvent):
        var processed = false
        defer: event.skip(if processed: false else: true)

        if event.getKeyCode() == VK_RETURN:
          processed = self.processMessage(wEvent_TextEnter, 0, 0)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      var vetoKeys = {wKey_Left, wKey_Right}

      if (style and wTeMultiLine) != 0:
        vetoKeys.incl {wKey_Up, wKey_Down}

        if (style and wTeReadOnly) == 0:
          vetoKeys.incl wKey_Enter

          if isProcessTab:
            vetoKeys.incl wKey_Tab

      if event.getKeyCode() in vetoKeys:
        event.veto

  proc init*(self: wTextCtrl, hWnd: HWND) {.validate.} =
    ## Initializes a text control by subclassing a system handle. Used internally.
    # only wrap a wWindow's child for now
    let parent = wAppWindowFindByHwnd(GetParent(hWnd))
    if parent == nil:
      raise newException(wError, "cannot wrap this textctrl.")

    self.wWindow.init(hwnd)
    self.mRich = false
    self.mDisableTextEvent = false
    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      wTextCtrl_ParentOnCommand(self, event)

    # add this so that the subcalssed control can get regain focus correctly
    self.systemConnect(WM_KILLFOCUS) do (event: wEvent):
      self.getTopParent().mSaveFocusHwnd = self.mHwnd

    # add this so that the parent's sibling button can have "default button" style
    self.systemConnect(WM_SETFOCUS) do (event: wEvent):
      # Call wControl_DoSetFocus() on parent window.
      # Don't use SendMessage(parent.mHwnd, WM_SETFOCUS...), because it let the
      # default WndProc do some extra action.
      var event = Event(parent, WM_SETFOCUS, event.mWparam, event.mLparam)
      wControl_DoSetFocus(event)
