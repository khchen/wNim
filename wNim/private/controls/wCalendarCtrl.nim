#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## The calendar control allows the user to pick a date.
#
## :Appearance:
##   .. image:: images/wCalendarCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wCalSundayFirst                 Show Sunday as the first day in the week.
##   wCalMondayFirst                 Show Monday as the first day in the week.
##   wCalNoToday                     Does not display the "today" date at the bottom of the control.
##   wCalNoMonthChange               Disable the month (and, implicitly, the year) changing.
##   wCalShowWeekNumbers             Show week numbers on the left side of the calendar.
##   wCalMultiSelect                 Enables the user to select a range of dates within the control.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_CalendarSelChanged        The selected date changed.
##   wEvent_CalendarViewChanged       The control view changed.
##   ===============================  =============================================================

include ../pragma
import times
import ../wBase, wControl
export wControl

const
  wCalSundayFirst* = 0
  wCalMondayFirst* = 0x10000000.int64 shl 32
  wCalNoToday* = MCS_NOTODAY
  wCalNoMonthChange* = 0x20000000.int64 shl 32
  wCalShowWeekNumbers* = MCS_WEEKNUMBERS
  wCalMultiSelect* = MCS_MULTISELECT

method getBestSize*(self: wCalendarCtrl): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  var rect: RECT
  SendMessage(self.mHwnd, MCM_GETMINREQRECT, 0, addr rect)
  result.width = max(rect.right.int,
    SendMessage(self.mHwnd, MCM_GETMAXTODAYWIDTH, 0, 0).int) + 2
  result.height = rect.bottom + 2

method getDefaultSize*(self: wCalendarCtrl): wSize {.property, inline.} =
  ## Returns the default size for the control.
  result = self.getBestSize()

proc getDate*(self: wCalendarCtrl): wTime {.validate, property.} =
  ## Gets the currently selected date.
  var st: SYSTEMTIME
  if SendMessage(self.mHwnd, MCM_GETCURSEL, 0, addr st) != 0:
    result = st.toTime()

proc getDates*(self: wCalendarCtrl): (wTime, wTime) {.validate, property.} =
  ## Gets the currently selected date range.
  var st: array[2, SYSTEMTIME]
  if SendMessage(self.mHwnd, MCM_GETSELRANGE, 0, addr st) != 0:
    result[0] = st[0].toTime()
    result[1] = st[1].toTime()

proc setDate*(self: wCalendarCtrl, time: wTime) {.validate, property.} =
  ## Sets the current date.
  var st = time.toSystemTime()
  SendMessage(self.mHwnd, MCM_SETCURSEL, 0, addr st)

proc setDates*(self: wCalendarCtrl, time1: wTime, time2: wTime)
    {.validate, property.} =
  ## Sets the selected date range.
  var st: array[2, SYSTEMTIME]
  st[0] = time1.toSystemTime()
  st[1] = time2.toSystemTime()
  SendMessage(self.mHwnd, MCM_SETSELRANGE, 0, addr st)

proc setDates*(self: wCalendarCtrl, time: (wTime, wTime)) {.validate, property.} =
  ## Sets the selected date range.
  self.setDates(time[0], time[1])

proc getToday*(self: wCalendarCtrl): wTime {.validate, property.} =
  ## Retrieves the date information for the date specified as "today"
  var st: SYSTEMTIME
  if SendMessage(self.mHwnd, MCM_GETTODAY, 0, addr st) != 0:
    result = st.toTime()

proc setToday*(self: wCalendarCtrl, time: wTime) {.validate, property.} =
  ## Sets the "today" value.
  var st = time.toSystemTime()
  SendMessage(self.mHwnd, MCM_SETTODAY, 0, addr st)
  self.refresh(false)

proc getDateRange*(self: wCalendarCtrl): (wTime, wTime) {.validate, property.} =
  ## If the control had been previously limited to a range of dates,
  ## returns the lower and upper bounds of this range.
  var st: array[2, SYSTEMTIME]
  let flag = SendMessage(self.mHwnd, MCM_GETRANGE, 0, addr st)
  result[0] = if (flag and GDTR_MIN) != 0: st[0].toTime() else: wDefaultTime
  result[1] = if (flag and GDTR_MAX) != 0: st[1].toTime() else: wDefaultTime

proc setDateRange*(self: wCalendarCtrl, time1 = wDefaultTime,
    time2 = wDefaultTime) {.validate, property.} =
  ## Sets the valid range for the date selection.
  var st: array[2, SYSTEMTIME]
  var flag: DWORD
  if time1 != wDefaultTime:
    st[0] = time1.toSystemTime()
    flag = flag or GDTR_MIN

  if time2 != wDefaultTime:
    st[1] = time2.toSystemTime()
    flag = flag or GDTR_MAX

  SendMessage(self.mHwnd, MCM_SETRANGE, flag, addr st)

proc setDateRange*(self: wCalendarCtrl, time: (wTime, wTime)) {.validate, property.} =
  ## Sets the valid range for the date selection.
  self.setDateRange(time[0], time[1])

proc enableMonthChange*(self: wCalendarCtrl, flag = true) {.validate.} =
  ## Enable or Disable the month changing.
  if flag:
    self.setDateRange()
  else:
    var first = now() - days(now().monthday - 1)
    var last = first + days(getDaysInMonth(first.month, first.year) - 1)
    self.setDateRange(first.toTime(), last.toTime())

proc setMaxSelectCount*(self: wCalendarCtrl, max: int) {.validate, property.} =
  ## Sets the maximum number of days that can be selected.
  SendMessage(self.mHwnd, MCM_SETMAXSELCOUNT, max, 0)

proc getMaxSelectCount*(self: wCalendarCtrl): int {.validate, property.} =
  ## Retrieves the maximum date range that can be selected
  result = int SendMessage(self.mHwnd, MCM_GETMAXSELCOUNT, 0, 0)

method processNotify(self: wCalendarCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code
  of MCN_SELCHANGE:
    return self.processMessage(wEvent_CalendarSelChanged, id, lparam, ret)

  of MCN_VIEWCHANGE:
    return self.processMessage(wEvent_CalendarViewChanged, id, lparam, ret)

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

wClass(wCalendarCtrl of wControl):

  method release*(self: wCalendarCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wCalendarCtrl, parent: wWindow, id = wDefaultID,
      date = wDefaultTime, pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = 0) {.validate.} =
    ## Initializes a calendar control.
    ## ==========  =================================================================================
    ## Parameters  Description
    ## ==========  =================================================================================
    ## parent      Parent window.
    ## id          The identifier for the control.
    ## date        The initial value of the control, if an invalid date (such as the default value) is used, the control is set to today.
    ## pos         Initial position.
    ## size        Initial size. If left at default value, the control chooses its own best size.
    ## style       The window style.
    wValidate(parent)
    self.wControl.init(className=MONTHCAL_CLASS, parent=parent, id=id, label="",
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    if (style and wCalMondayFirst) != 0:
      SendMessage(self.mHwnd, MCM_SETFIRSTDAYOFWEEK, 0, 0)

    if (style and wCalNoMonthChange) != 0:
      self.enableMonthChange(false)

    if date != wDefaultTime:
      self.setDate(date)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
        event.veto
