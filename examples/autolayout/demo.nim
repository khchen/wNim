#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  ../resource/resource,
  wNim

var app = App()
var frame = Frame(title="wNim Demo", style=wDefaultFrameStyle or wModalFrame)

frame.size = (800, 600)
frame.minSize = (500, 500)
frame.icon = Icon("", 0) # load icon from exe file.

var statusBar = StatusBar(frame)
var panel = Panel(frame)
var staticbox1 = StaticBox(panel, label="Basic Controls")
var staticbox2 = StaticBox(panel, label="Numbers Controls")
var staticbox3 = StaticBox(panel, label="Lists Controls")

var button = Button(panel, label="Button")
var checkbox = CheckBox(panel, label="CheckBox")
var textctrl = TextCtrl(panel, value="TextCtrl", style=wBorderSunken)
var statictext = StaticText(panel, label="StaticText")
var staticline = StaticLine(panel)

var datepickerctrl = DatePickerCtrl(panel)
var timepickerctrl = TimePickerCtrl(panel)
var calendarctrl = CalendarCtrl(panel, style=wCalNoToday)

var spinctrl = SpinCtrl(panel, value=50, style=wSpArrowKeys)
var slider = Slider(panel, value=50)
var gauge = Gauge(panel, value=50)

var combobox = ComboBox(panel, value="Combobox Item1",
  choices=["Combobox Item1", "Combobox Item2", "Combobox Item3"],
  style=wCbReadOnly)

var editable = ComboBox(panel, value="Editable Item1",
  choices=["Editable Item1", "Editable Item2", "Editable Item3"],
  style=wCbDropDown)

var radiobutton1 = RadioButton(panel, label="Radio Button 1")
var radiobutton2 = RadioButton(panel, label="Radio Button 2")
var radiobutton3 = RadioButton(panel, label="Radio Button 3")

var notebook = NoteBook(panel)
notebook.addPage("Page1")
notebook.addPage("Page2")
notebook.addPage("Page3")

const logo = staticRead(r"..\images\logo.png")
notebook.page(0).backgroundColor = panel.backgroundColor
notebook.page(1).backgroundColor = wGrey

var staticbitmap = StaticBitmap(notebook.page(0), bitmap=Bmp(logo), style=wSbFit)

notebook.page(1).wEvent_Paint do (event: wEvent):
  var size = event.window.clientSize
  var factorX = size.width / 460
  var factorY = size.height / 120

  var dc = PaintDC(event.window)
  dc.scale = (factorX, factorY)
  dc.drawEllipse(15, 35, 90, 50)
  dc.drawRoundedRectangle(130, 35, 90, 50, 10)
  dc.drawArc(240, 45, 340, 45, 290, 30)
  dc.drawPolygon([(355, 65), (405, 95), (405, 65), (445, 35), (365, 25)])

var listbox = ListBox(notebook.page(2), style=wLbNoSel or wBorderSimple or wLbNeededScroll)

listbox.wEvent_ContextMenu do ():
  var menu = Menu()
  menu.append(wIdClear, "&Clear")
  listbox.popupMenu(menu)

frame.wIdClear do ():
  listbox.clear()

proc add(self: wListBox, text: string) =
  self.ensureVisible(self.append(text))

button.wEvent_Button do (): listbox.add "button.wEvent_Button"
checkbox.wEvent_CheckBox do (): listbox.add "checkbox.wEvent_CheckBox"
textctrl.wEvent_Text do (): listbox.add "textctrl.wEvent_Text"
statictext.wEvent_MouseEnter do (): listbox.add "statictext.wEvent_MouseEnter"
statictext.wEvent_MouseLeave do (): listbox.add "statictext.wEvent_MouseLeave"
datepickerctrl.wEvent_DateChanged  do (): listbox.add "datepickerctrl.wEvent_DateChanged"
timepickerctrl.wEvent_TimeChanged  do (): listbox.add "timepickerctrl.wEvent_TimeChanged"
calendarctrl.wEvent_CalendarSelChanged do (): listbox.add "calendarctrl.wEvent_CalendarSelChanged"
spinctrl.wEvent_Spin do (): listbox.add "spinctrl.wEvent_Spin"
slider.wEvent_Slider do (): listbox.add "slider.wEvent_Slider"
combobox.wEvent_ComboBox do (): listbox.add "combobox.wEvent_ComboBox"
editable.wEvent_ComboBox do (): listbox.add "editable.wEvent_ComboBox"
editable.editControl.wEvent_Text do (): listbox.add "editable.editControl.wEvent_Text"
radiobutton1.wEvent_RadioButton do (): listbox.add "radiobutton1.wEvent_RadioButton"
radiobutton2.wEvent_RadioButton do (): listbox.add "radiobutton2.wEvent_RadioButton"
radiobutton3.wEvent_RadioButton do (): listbox.add "radiobutton3.wEvent_RadioButton"
notebook.wEvent_NoteBookPageChanged do (): listbox.add "notebook.wEvent_NoteBookPageChanged"
staticbitmap.wEvent_CommandLeftClick do (): listbox.add "staticbitmap.wEvent_CommandLeftClick"

proc layout() =
  panel.autolayout """
    spacing: 10
    H:|-[staticbox1]-[staticbox2..3,notebook]-|
    V:|-[staticbox1]-|
    V:|-[staticbox2]-[staticbox3]-[notebook]-|
    C: staticbox1.innerWidth = calendarctrl.bestSize.width

    outer: staticbox1
    V:|-5-{stack1:[button]-[checkbox]-[textctrl]-[statictext]}-[staticline]-
      {stack2:[datepickerctrl]-[timepickerctrl]}-[calendarctrl]
    H:|-5-[stack1..2,staticline,calendarctrl]-5-|

    outer: staticbox2
    V:|-5-{stack3:[spinctrl]-[slider]-[gauge]}-5-|
    H:|-5-[stack3]-5-|

    outer: staticbox3
    V:|-5-{stack4:[combobox]-[editable]-
      [radiobutton1][radiobutton2][radiobutton3]}-5-|
    H:|-5-[stack4]-5-|

    V:[stack1..4(25)]
  """

  notebook.autolayout """
    HV:|[staticbitmap,listbox]|
  """

panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()
