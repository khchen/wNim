#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim,
  strformat

type
  # A menu ID in wNim is type of wCommandID (distinct int) or any enum type.
  MenuID = enum
    idOpen = wIdUser, idExit
    idIcon1, idIcon2, idIcon3, idIcon4, idIcon5, idIcon6
    idCheck1, idCheck2, idRadio1, idRadio2, idRadio3
    idEnable, idDisable, idAbout

const resources: array[idIcon1..idIcon6, string] = [
  staticRead(r"images\1.png"),
  staticRead(r"images\2.png"),
  staticRead(r"images\3.png"),
  staticRead(r"images\4.png"),
  staticRead(r"images\5.png"),
  staticRead(r"images\6.png") ]

var app = App()
var frame = Frame(title="wNim Menu Demo")
frame.icon = Icon("", 0) # load icon from exe file.

var statusBar = StatusBar(frame)
var menuBar = MenuBar(frame)

var menuFile = Menu(menuBar, "&File")
menuFile.append(idOpen, "&Open", "Open a file.")
menuFile.appendSeparator()
menuFile.append(idExit, "E&xit", "Exit the program.")

var menuIcon = Menu(menuBar, "&Icon")
for id in idIcon1..idIcon6:
  var bmp = Bmp(Image(resources[id]).scale(36, 36))
  menuIcon.append(id, $id, $id & " Help", bmp)

var menuTest = Menu(menuBar, "&Test")
menuTest.appendCheckItem(idCheck1, "Check 1", "Check 1 Help").check()
menuTest.appendCheckItem(idCheck2, "Check 2", "Check 2 Help")
menuTest.appendSeparator()
menuTest.appendRadioItem(idRadio1, "Radio 1", "Radio 1 help").check()
menuTest.appendRadioItem(idRadio2, "Radio 2", "Radio 2 help")
menuTest.appendRadioItem(idRadio3, "Radio 3", "Radio 3 help")
menuTest.appendSeparator()
menuTest.append(idEnable, "Enable", "Enable the icon menu and about")
menuTest.append(idDisable, "Disable", "Disable the icon menu and about")
menuTest.appendSeparator()
menuTest.appendSubMenu(menuIcon, "&Icon", "Icon menu here.").disable()

var menuAbout = Menu(menuBar, "&About")
var itemAbout = menuAbout.append(idAbout, "About", "About")

# frame.connect(idExit) is syntax sugar for frame.connect(wEvent_Menu, idExit)
# frame.idExit is syntax sugar for frame.connect(idExit)

frame.idExit do ():
  frame.delete

frame.idEnable do ():
  menuIcon.enable
  itemAbout.enable

frame.idDisable do ():
  menuIcon.disable
  itemAbout.disable

frame.wEvent_Menu do (event: wEvent):
  var item = menuBar.findItem(event.id)
  var help = menuBar.getHelp(event.id)
  var msg: string

  if item != nil and item.isCheck:
    msg = fmt"{item.text} is checked: {item.isChecked}"
  else:
    msg = fmt"{MenuID(event.id)} is selected, help is ""{help}""."

  statusBar.setStatusText(msg)
  event.skip # make sure idExit event pass to next handler

frame.connect(wEvent_ContextMenu) do (event: wEvent):
  frame.popupMenu(menuTest, event.getMousePos())
  # Or just frame.popupMenu(menuTest) in order to use the current
  # mouse pointer position.

frame.show()
app.mainLoop()
