#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

import resource/resource
import wNim/[wApp, wFrame, wTextCtrl, wFont, wImage, wIcon]
import winim/winstr, winim/inc/shellapi
import std/with

const logo = staticRead(r"images/nim.png")

let app = App(wSystemDpiAware)
let frame = Frame(title="wNim wTextCtrl", size=(640, 460))
frame.icon = Icon("", 0) # load icon from exe file.

let textctrl = TextCtrl(frame, style=wTeRich or wTeMultiLine)
textctrl.backgroundColor = 0x2a201e

let largeFont = Font(20, weight=900, faceName="Tahoma")
let smallFont = Font(12, weight=900, faceName="Tahoma")

with textctrl:
  writeText("\n")
  setStyle(lineSpacing=1.5, indent=288)
  writeImage(Image(logo), 0.6)
  writeText("\n")

  setFormat(largeFont, fgColor=0x53e9ff)
  setStyle(lineSpacing=1.5)
  writeText("Efficient, expressive, elegant\n")

  setFormat(smallFont, fgColor=wWhite)
  setStyle(lineSpacing=1)
  writeText("Nim is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula.\n\n")

  setFormat(smallFont, fgColor=wBlack, bgColor=0x53e9ff)
  setStyle(align=wTextAlignCenter, lineSpacing=1.5, spaceBefore=100)
  writeText("  ")
  writeLink("https://nim-lang.org/", "Install Nim")
  setFormat(smallFont, fgColor=wBlack, bgColor=0x53e9ff)
  writeText("  ")
  setFormat(fgColor=0x2a201e, bgColor=0x2a201e)
  writeText("    ")
  setFormat(smallFont, fgColor=wBlack, bgColor=0xb3b3b3)
  writeText("  ")
  writeLink("https://play.nim-lang.org/", "Try it online")
  setFormat(smallFont, fgColor=wBlack, bgColor=0xb3b3b3)
  writeText("  \n")
  resetStyle()

textctrl.wEvent_TextLink do (event: wEvent):
  if event.mouseEvent == wEvent_LeftUp:
    let url = textctrl.range(event.start..<event.end)
    ShellExecute(0, "open", url, nil, nil, 5)

frame.center()
frame.show()
app.mainLoop()
