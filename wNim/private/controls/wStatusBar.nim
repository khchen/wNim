#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A status bar is a narrow window that can be placed along the bottom of a frame
## to give small amounts of status information.
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Events:
##   `wStatusBarEvent <wStatusBarEvent.html>`_

include ../pragma
import ../wBase, wControl
export wControl

# statusbar's best size and default size are current size
method getBestSize*(self: wStatusBar): wSize {.property, inline.} =
  ## Returns the best size for the status bar.
  result = self.getSize()

method getDefaultSize*(self: wStatusBar): wSize {.property, inline.} =
  ## Returns the default size for the status bar.
  result = self.getSize()

proc resize(self: wStatusBar) =
  var
    width = self.getSize().width
    setWidths: array[256, int32]
    denominator = 0
    fixedSize = 0

  for i in 0..<self.mFiledNumbers:
    setWidths[i] = self.mWidths[i]
    if setWidths[i] >= 0:
      fixedSize += setWidths[i]
    else:
      denominator -= setWidths[i]

  var leftWidth = width - fixedSize
  for i in 0..<self.mFiledNumbers:
    if setWidths[i] < 0:
      setWidths[i] = (-setWidths[i].int * leftWidth div denominator)
    if i > 0: setWidths[i] += setWidths[i - 1]

  SendMessage(self.mHwnd, SB_SETPARTS, self.mFiledNumbers, addr setWidths)

proc setStatusWidths*(self: wStatusBar, widths: openarray[int]) {.validate, property, inline.} =
  ## Sets the widths of the fields in the status line.
  ## There are two types of fields: fixed widths and variable width fields.
  ## For the fixed width fields you should specify their (constant) width in pixels.
  ## For the variable width fields, specify a negative number which indicates
  ## how the field should expand: the space left for all variable width fields is
  ## divided between them according to the absolute value of this number.
  ## A variable width field with width of -2 gets twice as much of it as a field
  ## with width -1 and so on.
  ##
  ## For example, to create one fixed width field of width 100 in the right part
  ## of the status bar and two more fields which get 66% and 33% of the remaining
  ## space correspondingly, you should use an array containing -2, -1 and 100.

  self.mFiledNumbers = widths.len
  for i in 0..<widths.len:
    self.mWidths[i] = widths[i]

  self.resize()

proc setFieldsCount*(self: wStatusBar, number: range[0..256]) {.validate, property, inline.} =
  ## Sets the number of fields. All the fields has the same width.
  self.mFiledNumbers = number
  for i in 0..<number:
    self.mWidths[i] = -1

  self.resize()

proc getFieldsCount*(self: wStatusBar): int {.validate, property, inline.} =
  ## Returns the number of fields in the status bar.
  result = self.mFiledNumbers

proc getStatusWidth*(self: wStatusBar, index: int): int {.validate, property, inline.} =
  ## Returns the width of the specified field.
  result = self.mWidths[index]

proc setStatusText*(self: wStatusBar, text = "", index = 0) {.validate, property, inline.} =
  ## Sets the status text for the specified field.
  SendMessage(self.mHwnd, SB_SETTEXT, index, &T(text))

proc getStatusText*(self: wStatusBar, index: int): string {.validate, property.} =
  ## Returns the string associated with a status bar of the specified field.
  let length = int LOWORD(SendMessage(self.mHwnd, SB_GETTEXTLENGTH, index, 0))
  if length != 0:
    var buffer = T(length + 2)
    SendMessage(self.mHwnd, SB_GETTEXT, index, &buffer)
    buffer.setLen(length)
    result = $buffer

proc setStatusIcon*(self: wStatusBar, icon: wIcon = nil, index: int = 0) {.validate, property, inline.} =
  ## Sets the icon for the specified field.
  SendMessage(self.mHwnd, SB_SETICON, index, if icon.isNil: 0 else: icon.mHandle)

proc setMinHeight*(self: wStatusBar, height: int) {.validate, property, inline.} =
  ## Sets the minimal possible height for the status bar.
  SendMessage(self.mHwnd, SB_SETMINHEIGHT, height, 0)

proc setHelpIndex*(self: wStatusBar, index: int) {.validate, property, inline.} =
  ## Sets the index to show the help string for menu items.
  self.mHelpIndex = index

proc getHelpIndex*(self: wStatusBar): int {.validate, property, inline.} =
  ## Returns the index to show the help string for menu items.
  result = self.mHelpIndex

proc `[]=`*(self: wStatusBar, index: int, text: string) {.validate, inline.} =
  ## Sets the status text for the specified field.
  self.setStatusText(text, index)

proc `[]`*(self: wStatusBar, index: int): string {.validate, inline.} =
  ## Returns the string associated with a status bar of the specified field.
  result = self.getStatusText(index)

method show*(self: wStatusBar, flag = true) {.inline.} =
  ## Shows or hides the status bar.
  self.showAndNotifyParent(flag)

method processNotify(self: wStatusBar, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool {.shield.} =

  var eventKind: UINT
  case code
  of NM_CLICK: eventKind = wEvent_StatusBarLeftClick
  of NM_DBLCLK: eventKind = wEvent_StatusBarLeftDoubleClick
  of NM_RCLICK: eventKind = wEvent_StatusBarRightClick
  of NM_RDBLCLK: eventKind = wEvent_StatusBarRightDoubleClick
  else: return false
  return self.processMessage(eventKind, cast[WPARAM](id), lparam)

wClass(wStatusBar of wControl):

  method release*(self: wStatusBar) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mSizeConn)
    free(self[])

  proc init*(self: wStatusBar, parent: wWindow, id = wDefaultID,
      style: wStyle = 0) {.validate.} =
    ## Initializes a status bar.
    wValidate(parent)
    self.wControl.init(className=STATUSCLASSNAME, parent=parent, id=id, pos=(0, 0),
      size=(0, 0), style=style or WS_CHILD or WS_VISIBLE)

    self.mFiledNumbers = 1
    self.mWidths[0] = -1
    self.mFocusable = false

    parent.mStatusBar = self
    self.mSizeConn = parent.systemConnect(WM_SIZE) do (event: wEvent):
      # send WM_SIZE to statubar to resize itself
      SendMessage(self.mHwnd, WM_SIZE, 0, 0)
      # then recount the width of fields
      self.resize()
