# Package

version       = "0.11.3"
author        = "Ward"
description   = "wNim - Nim\'s Windows GUI framework"
license       = "MIT"
skipDirs      = @["examples", "docs"]

# Dependencies

requires "nim >= 1.0.0", "winim >= 3.3.4"

# Examples

task example, "Build all the examples":
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/autolayoutEditor"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/colors"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/customdialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/demo"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/dialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/dragdrop"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/draggable"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/frame"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/helloworld"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/layout1"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/layout2"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/layout3"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/menu"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/nonsubclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/pickicondialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/printpreview"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/rebar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/reversi"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/scribble"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/shapewin"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/subclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/tictactoe"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/toolbar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/webView"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/wHyperlink"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/winsdk"

# Examples for Windows XP

task xpexample, "Build all the examples for Windows XP":
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/autolayoutEditor"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/colors"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/customdialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/demo"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/dialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/dragdrop"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/draggable"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/frame"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/helloworld"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/layout1"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/layout2"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/layout3"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/menu"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/nonsubclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/pickicondialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/printpreview"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/rebar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/reversi"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/scribble"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/shapewin"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/subclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/tictactoe"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/toolbar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/webView"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/wHyperlink"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/winsdk"

# Clean

task clean, "Delete all the executable files":
  exec "cmd /c IF EXIST examples\\*.exe del examples\\*.exe"
