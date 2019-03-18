#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim

type
  MenuID = enum
    idTool1 = wIdUser, idTool2, idTool3, idTool4

const resource1 = staticRead(r"images\1.png")
const resource2 = staticRead(r"images\2.png")
const resource3 = staticRead(r"images\3.png")
const resource4 = staticRead(r"images\4.png")
const resource5 = staticRead(r"images\cancel.ico")

var imageList = ImageList(24, 24)
imageList.add(Image(resource1).scale(24, 24))
imageList.add(Image(resource2).scale(24, 24))
imageList.add(Image(resource3).scale(24, 24))
imageList.add(Image(resource4).scale(24, 24))
imageList.add(Image(resource5).scale(24, 24))

let img1 = Image(resource1).scale(16, 16)
let img2 = Image(resource2).scale(16, 16)
let img3 = Image(resource3).scale(16, 16)
let img4 = Image(resource4).scale(16, 16)

let app = App()
let frame = Frame(title="Rebar Example")
frame.icon = Icon("", 0) # load icon from exe file.

let statusbar = StatusBar(frame)
let panel = Panel(frame)
let rebar = Rebar(frame)
rebar.setImageList(imageList)

let toolbar = ToolBar(rebar)
toolbar.addTool(idTool1, "Tool 1", Bmp(img1), "Tool1", "This is tool 1.")
toolbar.addTool(idTool2, "Tool 2", Bmp(img2), "Tool2", "This is tool 2.")
toolbar.addTool(idTool3, "Tool 3", Bmp(img3), "Tool3", "This is tool 3.")
toolbar.addTool(idTool4, "Tool 4", Bmp(img4), "Tool4", "This is tool 4.")

let button = Button(rebar, label="Exit")

let combobox = ComboBox(rebar, value="Combobox Item1",
  choices=["Combobox Item1", "Combobox Item2", "Combobox Item3"],
  style=wCB_READONLY)

rebar.addControl(toolBar)
rebar.addControl(button, 4)
rebar.addControl(combobox, 2, "Combo", isBreak=true)

frame.wEvent_Tool do (event: wEvent):
  statusbar.setStatusText($MenuID(event.id) & " clicked.")

combobox.wEvent_ComboBox do (event: wEvent):
  statusbar.setStatusText(combobox.getValue())

button.wEvent_Button do ():
  frame.close()

frame.center()
frame.show()
app.mainLoop()
