#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

## A checkbox is a labelled box which by default is either on (checkmark is visible) or off (no checkmark).
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wChk2State                      Create a 2-state checkbox. This is the default.
##    wChk3State                      Create a 3-state checkbox.
##    wChkAlignRight                  Makes the text appear on the left of the checkbox.
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wCommandEvent                   Description
##    ==============================  =============================================================
##    wEvent_Checkbox                 The checkbox is clicked.
##    ==============================  =============================================================

const
  # CheckBox styles and state
  wChk2State* = 0
  wChk3State* = BS_AUTO3STATE
  wChkAlignRight* = BS_LEFTTEXT or BS_RIGHT

  wChkUnchecked* = BST_UNCHECKED
  wChkChecked* = BST_CHECKED
  wChkUndetermined* = BST_INDETERMINATE

method getBestSize*(self: wCheckBox): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  # BCM_GETIDEALSIZE not works correct on BS_AUTO3STATE
  result = getTextFontSizeWithCheckMark(getLabel(), mFont.mHandle)
  result.height += 2

method getDefaultSize*(self: wCheckBox): wSize {.property.} =
  ## Returns the default size for the control.
  result = getBestSize()
  result.height = getLineControlDefaultHeight(mFont.mHandle)

proc getValue*(self: wCheckBox): bool {.validate, property, inline.} =
  ## Gets the state of a 2-state checkbox
  result = SendMessage(mHwnd, BM_GETCHECK, 0, 0) == BST_CHECKED

proc isChecked*(self: wCheckBox): bool {.validate, inline.} =
  ## This is just a maybe more readable synonym for getValue.
  result = getValue()

proc is3State*(self: wCheckBox): bool {.validate.} =
  ## Returns whether or not the checkbox is a 3-state checkbox.
  result = case getWindowStyle() and 0xF
    of BS_3STATE, BS_AUTO3STATE: true
    else: false

proc get3StateValue*(self: wCheckBox): int {.validate, property, inline.} =
  ## Gets the state of a 3-state checkbox.
  ## Returned value can be one of wChkUnchecked, wChkChecked, or wChkUndetermined.
  result = int SendMessage(mHwnd, BM_GETCHECK, 0, 0)

proc set3StateValue*(self: wCheckBox, state: int) {.validate, property, inline.} =
  ## Sets the checkbox to the given state.
  ## State can be one of wChkUnchecked, wChkChecked, or wChkUndetermined.
  SendMessage(mHwnd, BM_SETCHECK, state, 0)

proc setValue*(self: wCheckBox, state: bool) {.validate, property, inline.} =
  ## Sets the checkbox to the given state.
  SendMessage(mHwnd, BM_SETCHECK, if state: BST_CHECKED else: BST_UNCHECKED, 0)

proc final*(self: wCheckBox) =
  ## Default finalizer for wCheckBox.
  discard

proc init*(self: wCheckBox, parent: wWindow, id = wDefaultID,
    label: string = "", pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wChk2State) {.validate.} =

  wValidate(parent)
  let checkType = if (style and wChk3State) != 0: BS_AUTO3STATE else: BS_AUTOCHECKBOX

  # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
  let style = (style and (not 0xF)) or checkType

  self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label, pos=pos,
    size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    if event.mLparam == mHwnd and HIWORD(event.mWparam) == BN_CLICKED:
      self.processMessage(wEvent_CheckBox, event.mWparam, event.mLparam)

proc CheckBox*(parent: wWindow, id = wDefaultID,
    label: string = "", pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = wChk2State): wCheckBox {.inline, discardable.} =
  ## Constructor, creating and showing a checkbox
  wValidate(parent)
  new(result, final)
  result.init(parent, id, label, pos, size, style)
