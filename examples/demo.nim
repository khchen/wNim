#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim

var app = App()
var frame = Frame(title="wNim Demo", style=wDefaultFrameStyle or wModalFrame)

frame.size = (800, 600)
frame.minSize = (500, 500)
frame.icon = Icon("", 0) # load icon from exe file.

var statusBar = StatusBar(frame)
var panel = Panel(frame)
panel.margin = 10

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

const logo = staticRead(r"images\logo.png")
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
  panel.layout:
    staticbox1:
      top = panel.top
      bottom = panel.bottom
      left = panel.left
      innerWidth = calendarctrl.bestSize.width

    button:
      top = staticbox1.innerTop + 5
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 25

    checkbox:
      top = button.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 25

    textctrl:
      top = checkbox.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 25

    statictext:
      top = textctrl.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 25

    staticline:
      top = statictext.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 2

    datepickerctrl:
      top = staticline.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 25

    timepickerctrl:
      top = datepickerctrl.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5
      height = 25

    calendarctrl:
      top = timepickerctrl.bottom + 10
      left = staticbox1.innerLeft + 5
      right = staticbox1.innerRight - 5

    staticbox2:
      top = panel.top
      left = staticbox1.right + 10
      right = panel.right
      innerBottom = gauge.bottom + 5

    spinctrl:
      top = staticbox2.innerTop + 5
      left = staticbox2.innerLeft + 5
      right = staticbox2.innerRight - 5
      height = 25

    slider:
      top = spinctrl.bottom + 10
      left = staticbox2.innerLeft + 5
      right = staticbox2.innerRight - 5
      height = 25

    gauge:
      top = slider.bottom + 10
      left = staticbox2.innerLeft + 5
      right = staticbox2.innerRight - 5
      height = 25

    staticbox3:
      top = staticbox2.bottom + 10
      left = staticbox1.right + 10
      right = panel.right
      innerBottom = radiobutton3.bottom + 5

    combobox:
      top = staticbox3.innerTop + 5
      left = staticbox3.innerLeft + 5
      right = staticbox3.innerRight - 5
      height = 25

    editable:
      top = combobox.bottom + 10
      left = staticbox3.innerLeft + 5
      right = staticbox3.innerRight - 5
      height = 25

    radiobutton1:
      top = editable.bottom + 10
      left = staticbox3.innerLeft + 5
      right = staticbox3.innerRight - 5
      height = 22

    radiobutton2:
      top = radiobutton1.bottom
      left = staticbox3.innerLeft + 5
      right = staticbox3.innerRight - 5
      height = 22

    radiobutton3:
      top = radiobutton2.bottom
      left = staticbox3.innerLeft + 5
      right = staticbox3.innerRight - 5
      height = 22

    notebook:
      top = staticbox3.bottom + 10
      bottom = panel.bottom
      left = staticbox3.left
      right = panel.right

  notebook.layout:
    staticbitmap:
      left = notebook.left
      right = notebook.right
      top = notebook.top
      bottom = notebook.bottom

    listbox:
      left = notebook.left
      right = notebook.right
      top = notebook.top
      bottom = notebook.bottom

panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()
