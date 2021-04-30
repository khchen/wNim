#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This control allows the user to select a date.
#
## :Appearance:
##   .. image:: images/wDatePickerCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wDpDropDown                     Show drop-down part from which the user can select a date (Default).
##   wDpSpin                         Show spin-control-like arrows to change individual date components.
##   wDpAllowNone                    The control allows the user to not enter any valid date at all.
##   wDpShowCentury                  Forces display of the century in the default date format.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_DateChanged               The selected date changed.
##   ===============================  =============================================================

include ../pragma
import times # this line only for nim 0.19.0
import ../wBase, wControl
export wControl

const
  wDpDropDown*: wStyle = 0
  wDpSpin*: wStyle = DTS_UPDOWN
  wDpAllowNone*: wStyle = DTS_SHOWNONE
  wDpShowCentury*: wStyle = DTS_SHORTDATECENTURYFORMAT

method getBestSize*(self: wDatePickerCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the window.
  var size: SIZE
  SendMessage(self.mHwnd, DTM_GETIDEALSIZE, 0, addr size)
  result.width = size.cx + 2
  result.height = size.cy + 2

method getDefaultSize*(self: wDatePickerCtrl): wSize {.property.} =
  ## Returns the default size for the window.
  result = self.getBestSize()
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)

proc getValue*(self: wDatePickerCtrl): wTime {.validate, property.} =
  ## Returns the currently entered date.
  var st: SYSTEMTIME
  if GDT_VALID == SendMessage(self.mHwnd, DTM_GETSYSTEMTIME, 0, addr st):
    result = st.toTime()

proc setValue*(self: wDatePickerCtrl, time: wTime) {.validate, property.} =
  ## Changes the current value of the control.
  var st = time.toSystemTime()
  SendMessage(self.mHwnd, DTM_SETSYSTEMTIME, GDT_VALID, addr st)

proc getRange*(self: wDatePickerCtrl): (wTime, wTime) {.validate, property.} =
  ## If the control had been previously limited to a range of dates,
  ## returns the lower and upper bounds of this range.
  var st: array[2, SYSTEMTIME]
  let flag = SendMessage(self.mHwnd, DTM_GETRANGE , 0, addr st)
  result[0] = if (flag and GDTR_MIN) != 0: st[0].toTime() else: wDefaultTime
  result[1] = if (flag and GDTR_MAX) != 0: st[1].toTime() else: wDefaultTime

proc setRange*(self: wDatePickerCtrl, time1 = wDefaultTime, time2 = wDefaultTime) {.validate, property.} =
  ## Sets the valid range for the date selection.
  var st: array[2, SYSTEMTIME]
  var flag: DWORD
  if time1 != wDefaultTime:
    st[0] = time1.toSystemTime()
    flag = flag or GDTR_MIN

  if time2 != wDefaultTime:
    st[1] = time2.toSystemTime()
    flag = flag or GDTR_MAX

  SendMessage(self.mHwnd, DTM_SETRANGE, flag, addr st)

proc setRange*(self: wDatePickerCtrl, time: (wTime, wTime)) {.validate, property.} =
  ## Sets the valid range for the date selection.
  self.setRange(time[0], time[1])

method processNotify(self: wDatePickerCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  if code == DTN_DATETIMECHANGE:
    return self.processMessage(wEvent_DateChanged, id, lparam, ret)

  return procCall wControl(self).processNotify(code, id, lParam, ret)

wClass(wDatePickerCtrl of wControl):

  method release*(self: wDatePickerCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wDatePickerCtrl, parent: wWindow, id = wDefaultID,
      date = wDefaultTime, pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = wDpDropDown) {.validate.} =
    ## Initializes a date picker control.
    ## ==========  =================================================================================
    ## Parameters  Description
    ## ==========  =================================================================================
    ##    parent   Parent window.
    ##    id       The identifier for the control.
    ##    date     The initial value of the control, if an invalid date (such as the default value) is used, the control is set to today.
    ##    pos      Initial position.
    ##    size     Initial size. If left at default value, the control chooses its own best size.
    ##    style    The window style.
    wValidate(parent)
    self.wControl.init(className=DATETIMEPICK_CLASS, parent=parent, id=id, label="",
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    if date != wDefaultTime:
      self.setValue(date)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
        event.veto
