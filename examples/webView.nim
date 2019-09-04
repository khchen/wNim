#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  strutils, os, random,
  resource/resource2,
  winim/com

when defined(aio):
  import wNim
else:
  import wNim/[wApp, wImage, wIcon, wBitmap, wFrame, wStatusBar, wToolBar,
    wRebar, wWebView, wTextCtrl, wMessageDialog]

# block:
#   var hkey: HKEY
#   if RegCreateKeyEx(HKEY_CURRENT_USER, r"Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION",
#     0, nil, REG_OPTION_VOLATILE, KEY_WRITE, nil, &hkey, nil) == ERROR_SUCCESS:

#     defer: RegCloseKey(hkey)

#     var val = DWORD 11000
#     RegSetValueEx(hkey, getAppFilename().extractFilename(), 0, REG_DWORD, cast[ptr BYTE](&val), 4)

type
  MenuID = enum
    idGoBack = wIdUser, idGoForward

proc aboutDialog(owner: wWindow) =
  let dialog = Frame(owner=owner, title="wNim wWebView", size=(350, 450), style=wDefaultDialogStyle)
  let webView = WebView(dialog, style=wWvNoSel or wWvNoScroll or wWvNoContextMenu or wWvSilent)
  webView.navigate("res://webView.exe/about.html")

  webView.wEvent_WebViewNavigating do (event: wEvent):
    event.veto
    if event.url == "wnim:close":
      dialog.close()

  dialog.wEvent_Close do ():
    dialog.endModal()

  dialog.center()
  dialog.showModal()
  dialog.delete()

let app = App()
let frame = Frame(title="wWebView", size=(640, 460))
let statusbar = StatusBar(frame)
let rebar = Rebar(frame)
let webView = WebView(frame, style=wWvSilent)

let toolbar = ToolBar(rebar)
let imgGoBack = Image(Icon("shell32.dll,137")).scale(24, 24)
let imgGoForward = Image(Icon("shell32.dll,137")).scale(24, 24)
imgGoBack.rotateFlip(wImageRotateNoneFlipX)

toolbar.addTool(idGoBack, "", Bmp(imgGoBack), longHelp="Navigate back")
toolbar.addTool(idGoForward, "", Bmp(imgGoForward), longHelp="Navigate foreward")
toolBar.disableTool(idGoBack)
toolBar.disableTool(idGoForward)
rebar.addControl(toolBar)

var textctrl = TextCtrl(rebar, value="about:blank", style=wBorderSunken)
rebar.addControl(textctrl, label="Address")
rebar.minimize(0)

# select all when the textctrl just got focus
textctrl.wEvent_LeftDown do (event: wEvent):
  if not textctrl.hasFocus():
    textctrl.setFocus()
  else:
    event.skip

textctrl.wEvent_SetFocus do (event: wEvent):
  textctrl.selectAll()
  event.skip

textctrl.wEvent_TextEnter do ():
  webView.navigate(textctrl.value)

# using shortcut to ensure refreshing page even the webView not has focus
frame.shortcut(wAccelNormal, wKey_F5) do ():
  webView.refresh()

# update UI
webView.wEvent_WebViewStatusChanged do (event: wEvent):
  statusBar.setStatusText(event.text)

webView.wEvent_WebViewTitleChanged do (event: wEvent):
  frame.title =
    if event.text.len == 0: "wWebView"
    else: "wWebView - " & event.text

webView.wEvent_WebViewHistoryChanged do ():
  toolBar.enableTool(idGoBack, webView.canGoBack)
  toolBar.enableTool(idGoForward, webView.canGoForward)

webView.wEvent_WebViewLoaded do ():
  textctrl.value = webView.currentUrl
  textctrl.selectAll()

# avoid new window
webView.wEvent_WebViewNewWindow do (event: wEvent):
  event.veto
  if event.url.len != 0:
    webView.navigate(event.url)

# actions
frame.wEvent_Tool do (event: wEvent):
  case event.id
  of idGoBack: webView.goBack()
  of idGoForward: webView.goForward()
  else: event.skip

webView.wEvent_WebViewNavigating do (event: wEvent):
  case event.url
  of "wnim:clickme":
    # get a winim COM object with IWebBrowser2 interface
    let obj = webView.comObject

    # call script function, using winim/obj call() proc
    let ret = obj.document.script.call("clickme", rand(10), rand(10), rand(10))

    # display the result
    MessageDialog(frame, "JS code return " & $ret, caption="wWebView").display()

    # DOM manipulation
    obj.document.getelementById("clickme").innerHTML = "click me again"

    event.veto

  of "wnim:about":
    frame.aboutDialog()
    event.veto

  else: discard

randomize()
webView.navigate("res://webView.exe/demo.html")
textctrl.setFocus()
frame.center()
frame.show()
app.mainLoop()
