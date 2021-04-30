#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2021 Ward
#
#====================================================================

# This example demonstrates how wNim works with Windows SDK.

import
  resource/resource,
  winim/lean

import wNim/[wApp, wIcon, wFrame, wMenu, wStatusBar, wPaintDC, wBrush,
  wMessageDialog, wUtils]

wSetSysemDpiAware()
let
  app = App()
  frame = Frame(title="wNim with Windows SDK", size=(640, 480))
  statusBar = StatusBar(frame)

  # Loads a system icon
  hIcon = LoadImage(0, IDI_INFORMATION, IMAGE_ICON, 48, 48, LR_SHARED)

  # Gets the system handle (HWND) of the wFrame.
  hWnd = frame.handle

  # Gets the system menu handle (HMENU) by Windows API.
  hMenu = GetSystemMenu(hWnd, false)

# Wraps HICON to wIcon object.
frame.icon = Icon(hIcon)

# Wraps the system menu handle to wMenu object for modifying.
let menu = Menu(hMenu)
menu.insertSeparator(0)
menu.insert(0, wIdSystemMenu, "About")

# Let's pop up system menu anywhere.
frame.wEvent_ContextMenu do ():
  frame.popupMenu(menu)

frame.wEvent_Paint do ():
  var dc = PaintDC(frame)
  defer: delete dc

  # Wraps the system brush handle to wBrush object for drawing.
  let hBrush = CreateHatchBrush(HS_CROSS, wBlack)
  dc.background = wGrey
  dc.clear(Brush(hBrush, copy=false))

  # Gets the system DC handle from the wPaintDC object.
  let hDc = dc.handle

  # Draws an icon by Windows API.
  DrawIcon(hDc, 10, 10, hIcon)

# When the menu pops up as context menu, we receive wEvent_Menu event.
# Sends WM_SYSCOMMAND message back to the frame window so that the command works.
frame.wEvent_Menu do (event: wEvent):
  SendMessage(hWnd, WM_SYSCOMMAND, wWparam event.id, 0)

# Connects system message as an event.
frame.connect(WM_SYSCOMMAND) do (event: wEvent):
  let msg = case int event.wParam:
  of int wIdSystemMenu: "wNim Framework with Windows SDK"
  of SC_CLOSE: "SC_CLOSE"
  of SC_MAXIMIZE: "SC_MAXIMIZE"
  of SC_MINIMIZE: "SC_MINIMIZE"
  of SC_MOVE: "SC_MOVE"
  of SC_RESTORE: "SC_RESTORE"
  of SC_SIZE: "SC_SIZE"
  else: ""

  if msg.len != 0:
    statusBar.setStatusText(msg)
    MessageDialog(frame, msg, "WM_SYSCOMMAND").display()

  # Skips this event so that the default procedure can process this message.
  event.skip

frame.center()
frame.show()
app.mainLoop()
