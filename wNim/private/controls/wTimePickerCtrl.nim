#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## This control allows the user to enter time.
#
## :Appearance:
##   .. image:: images/wTimePickerCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_TimeChanged               The selected time changed.
##   ===============================  =============================================================

include ../pragma
import ../wBase, wControl, wDatePickerCtrl
export wControl

proc getTime*(self: wTimePickerCtrl): tuple[hour, min, sec: int]
    {.validate, property.} =
  ## Returns the currently entered time as hours, minutes and seconds
  var st: SYSTEMTIME
  if GDT_VALID == SendMessage(self.mHwnd, DTM_GETSYSTEMTIME, 0, addr st):
    result.hour = st.wHour.int
    result.min = st.wMinute.int
    result.sec = st.wSecond.int

proc setTime*(self: wTimePickerCtrl, hour: int, min: int, sec: int)
    {.validate, property.} =
  ## Changes the current time of the control.
  var st: SYSTEMTIME
  GetLocalTime(addr st)
  st.wHour = hour.WORD
  st.wMinute = min.WORD
  st.wSecond = sec.WORD
  SendMessage(self.mHwnd, DTM_SETSYSTEMTIME, GDT_VALID, addr st)

proc setTime*(self: wTimePickerCtrl, time: tuple[hour, min, sec: int])
    {.validate, property.} =
  ## Changes the current time of the control.
  self.setTime(time.hour, time.min, time.sec)

wClass(wTimePickerCtrl of wDatePickerCtrl):

  method release*(self: wTimePickerCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wTimePickerCtrl, parent: wWindow, id = wDefaultID,
      time = wDefaultTime, pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = 0) {.validate.} =
    ## Initializes a time picker control.
    ## ==========  =================================================================================
    ## Parameters  Description
    ## ==========  =================================================================================
    ## parent      Parent window.
    ## id          The identifier for the control.
    ## time        The initial value of the control, if an invalid date (such as the default value) is used, the control is set to current time.
    ## pos         Initial position.
    ## size        Initial size. If left at default value, the control chooses its own best size.
    ## style       The window style, should be left at 0 as there are no special styles for this control.
    wValidate(parent)
    self.wDatePickerCtrl.init(parent=parent, id=id, date=time, pos=pos,
      size=size, style=style or DTS_TIMEFORMAT)
