#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  resource/resource,
  wNim,
  strutils, os,
  winim/inc/[windef, winuser, shellapi]

import strformat except `&`

proc pickIconDialog(owner: wWindow, initFile = "shell32.dll"): string =
  const iconFiles = ["accessibilitycpl.dll", "explorer.exe", "gameux.dll",
    "imageres.dll", "mmcndmgr.dll", "mmres.dll", "moricons.dll", "mstscax.dll",
    "netshell.dll", "networkmap.dll", "pifmgr.dll", "sensorscpl.dll",
    "setupapi.dll", "shell32.dll", "wmp.dll", "wmploc.dll", "wpdshext.dll"]

  var
    dialog = Frame(owner=owner, title="Pick Icon Dialog", size=(440, 440),
      style=wCaption or wSystemMenu or wModalFrame or wResizeBorder)

    menu = Menu()
    panel = Panel(dialog)
    staticText = StaticText(panel, style=wBorderStatic or wAlignLeftNoWordWrap)
    select = Button(panel, label="Select File")
    listCtrl = ListCtrl(panel, style=wLcIcon or wLcAutoArrange or
      wLcSingleSel or wBorderSunken)
    combo = ComboBox(panel, value="48 x 48",
      choices=["16 x 16", "24 x 24", "36 x 36", "48 x 48", "64 x 64"],
      style=wCbReadOnly)
    ok = Button(panel, label="Ok")
    cancel = Button(panel, label="Cancel")

    imageList: wImageList
    currentFile = initFile
    ret: string

  proc pickAndClose(index: int) =
    if index != -1:
      ret = if listCtrl.getItemText(index).len == 0:
          currentFile
        else:
          fmt"{currentFile},{index}"

      dialog.close()

  proc showFilename() =
    var
      dc = WindowDC(staticText)
      buffer = newWString(currentFile)
      text: string

    defer:
      delete dc

    if PathCompactPath(dc.handle, buffer, UINT staticText.size.width - 4):
      text = $buffer.nullTerminated()
    else:
      text = currentFile

    staticText.label = text
    staticText.setToolTip(if text != currentFile: currentFile else: "")

  proc showIcons() =
    let
      fields = combo.value.split('x')
      size: wSize = (parseInt(fields[0].strip()), parseInt(fields[1].strip()))

    SendMessage(listCtrl.handle, WM_SETREDRAW, FALSE, 0)
    defer: SendMessage(listCtrl.handle, WM_SETREDRAW, TRUE, 0)

    if imageList != nil: imageList.delete()
    listCtrl.clearAll()

    imageList = ImageList(size, mask=true)
    listCtrl.setImageList(imageList, wImageListNormal)
    listCtrl.setItemSpacing(size.width + 25, size.height + 25)

    var index = 0
    while true:
      # load all icons from dll/exe
      try:
        var icon = Icon(currentFile, index, size)
        defer: icon.delete()

        imageList.add(icon)
        listCtrl.appendItem($index, image=index)
        index.inc

      except: break

    if index == 0:
      # it's not a dll/exe with icons, treat it as icon file.
      try:
        var icon = Icon(currentFile, size)
        defer: icon.delete()

        imageList.add(icon)
        listCtrl.appendItem("", image=0)

      except: discard

  menu.append(1, "Browse...")
  menu.appendSeparator()

  for i, file in iconFiles:
    # MSDN: If this value is –1 and phiconLarge and phiconSmall are both NULL,
    # the function returns the total number of icons
    let n = ExtractIconEx(file, -1, nil, nil, 0)
    if n != 0:
      menu.append(i + 2, fmt"{file} ({n})")

  dialog.icon = Icon("shell32.dll,22")
  select.setDropdownMenu(menu)
  ok.setDefault()
  showIcons()

  dialog.wEvent_Size do (event: wEvent):
    panel.autolayout """
      spacing: 12
      H:|-[staticText]-[select(select.defaultWidth)]-|
      H:|-[listCtrl]-|
      H:|-[combo(combo.bestWidth)]->[ok(cancel)]-[cancel(cancel.bestWidth+48)]-|
      V:|-[staticText(staticText.defaultHeight)]-[listCtrl]-[combo(combo.bestHeight)]-|
      V:|-[select(staticText.height)]-[listCtrl]-[ok,cancel(combo.height)]-|
    """

    let n = ok.size.width + cancel.size.width + combo.size.width + 12 * 4
    dialog.minClientSize = (n, n)
    showFilename()

  dialog.wEvent_Menu do (event: wEvent):
    var i = int event.id
    if i == 1:
      var files = FileDialog(dialog, "Select Icon Files",
        defaultDir=getCurrentDir(), wildcard="Icon Files|*.ico;*.cur;*.dll;*.exe",
        style=wFdOpen or wFdFileMustExist).showResult()

      if files.len == 1:
        currentFile = files[0]
        showFilename()
        showIcons()

    else:
      i -= 2
      if i >= 0 and i < iconFiles.len:
        currentFile = iconFiles[i]
        showFilename()
        showIcons()

  dialog.wEvent_ComboBox do ():
    showIcons()

  select.wEvent_Button do ():
    select.showDropdownMenu()

  cancel.wEvent_Button do ():
    dialog.close()

  ok.wEvent_Button do ():
    let index = listCtrl.getNextItem(0, wListNextAll, wListStateSelected)
    pickAndClose(index)

  listCtrl.wEvent_CommandLeftDoubleClick do (event: wEvent):
    let index = listCtrl.hitTest(event.x, event.y)[0]
    pickAndClose(index)

  dialog.shortcut(wAccelNormal, wKey_Esc) do ():
    dialog.close()

  dialog.wEvent_Close do ():
    dialog.endModal()

  dialog.center()
  dialog.showModal()
  dialog.delete()
  return ret

when isMainModule:
  type
    MenuID = enum
      idOpen = wIdUser
      idExit

  var backgroundIcons = newSeq[wIcon]()

  let app = App()
  let frame = Frame(title="wNim PickIconDialog", size=(650, 380))
  frame.icon = Icon("", 0) # load icon from exe file.

  let statusbar = StatusBar(frame)
  let menubar = MenuBar(frame)
  let menu = Menu(menubar, "&File")
  menu.append(idOpen, "&Pick", "Pick an icon.")
  menu.appendSeparator()
  menu.append(idExit, "E&xit", "Exit the program.")

  frame.wEvent_Paint do ():
    var dc = PaintDC(frame)
    defer: delete dc

    var x = 0
    for icon in backgroundIcons:
      if icon != nil:
        dc.drawIcon(icon, x=x)
        x += icon.size.width + 5

  frame.idOpen do ():
    var iconPath {.global.} = "shell32.dll"
    let path = pickIconDialog(frame, iconPath)
    if path.len != 0:
      iconPath = path.rsplit(',', maxsplit=1)[0]
      backgroundIcons = @[]
      for n in [16, 24, 36, 48, 64, 128, 256]:
        try:
          backgroundIcons.add Icon(path, (n, n))
        except: discard
      frame.refresh()

  frame.idExit do ():
    frame.close()

  frame.wEvent_ContextMenu do (event: wEvent):
    frame.popupMenu(menu, event.getMousePos())

  frame.center()
  frame.show()
  app.mainLoop()
