#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim,
  winim/lean

let
  app = App()
  frame = Frame(title="Hello World", size=(300, 200))
  statusBar = StatusBar(frame)

frame.icon = Icon("", 0) # load icon from exe file.

frame.WM_SYSCOMMAND do (event: wEvent):
  let msg = case int event.wParam:
  of SC_CLOSE: "SC_CLOSE"
  of SC_CONTEXTHELP: "SC_CONTEXTHELP"
  of SC_DEFAULT: "SC_DEFAULT"
  of SC_HOTKEY: "SC_HOTKEY"
  of SC_HSCROLL: "SC_HSCROLL"
  of SCF_ISSECURE: "SCF_ISSECURE"
  of SC_KEYMENU: "SC_KEYMENU"
  of SC_MAXIMIZE: "SC_MAXIMIZE"
  of SC_MINIMIZE: "SC_MINIMIZE"
  of SC_MONITORPOWER: "SC_MONITORPOWER"
  of SC_MOUSEMENU: "SC_MOUSEMENU"
  of SC_MOVE: "SC_MOVE"
  of SC_NEXTWINDOW: "SC_NEXTWINDOW"
  of SC_PREVWINDOW: "SC_PREVWINDOW"
  of SC_RESTORE: "SC_RESTORE"
  of SC_SCREENSAVE: "SC_SCREENSAVE"
  of SC_SIZE: "SC_SIZE"
  of SC_TASKLIST: "SC_TASKLIST"
  of SC_VSCROLL: "SC_VSCROLL"
  else: ""

  if msg.len != 0:
    statusBar.setStatusText(msg)

  event.skip

frame.center()
frame.show()
app.mainLoop()
