#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2021 Ward
#
#====================================================================

import resource/resource
import times
import wNim/[wApp, wFrame, wCalendarCtrl, wScrollBar, wFont, wIcon]
import winim/[lean, inc/uxtheme] # for SetWindowTheme()

proc update(calendar: wCalendarCtrl, today: DateTime) =
  var firstDay = initDateTime(1, mJan, today.year, 0, 0, 0, 0)
  var lastDay = initDateTime(31, mDec, today.year, 0, 0, 0, 0)

  calendar.dateRange = (firstDay.toTime, lastDay.toTime)
  calendar.date = today.toTime

var app = App(wSystemDpiAware)
var frame = Frame(title="wNim Calendar")
frame.icon = Icon("", 0) # load icon from exe file.

# Use wScrollBar control instead of wHScroll so that we can change the width.
var scroll = ScrollBar(frame, style=wSbHorizontal)
scroll.setScrollbar(100, 1, 200)

var calendar = CalendarCtrl(frame, style=wCalNoToday)
calendar.disable()
calendar.doubleBuffered = true
calendar.handle.SetWindowTheme("", "") # disable the theme to change the font
calendar.font = Font(10, weight=wFontWeightBold)
calendar.update(now())

frame.wEvent_Size do ():
  frame.autolayout """
    H: |[calendar,scroll]|
    V: |[calendar][scroll(30)]|
  """

frame.wEvent_ScrollBar do (event: wEvent):
  var day = now() + years(event.getScrollPos() - 100)
  calendar.update(day)

frame.wEvent_LeftDoubleClick do ():
  scroll.setScrollbar(100, 1, 200)
  calendar.update(now())

# The default size to display the whole year
frame.clientSize = (calendar.bestSize.width * 4, calendar.bestSize.height * 3 + 30)

frame.center()
frame.show()
app.mainLoop()
