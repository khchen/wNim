# Package

version       = "0.4"
author        = "Ward"
description   = "wNim - Nim\'s Windows GUI framework"
license       = "MIT"
skipDirs      = @["examples", "docs"]

# Dependencies

requires "nim >= 0.19.0", "winim >= 3.0", "kiwi >= 0.1.0"

# Examples

task example, "Build all the examples":
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/demo"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/dialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/dragdrop"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/draggable"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/frame"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/helloworld"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/layout1"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/layout2"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/layout3"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/lowlevel"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/menu"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/nonsubclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/pickicondialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/rebar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/reversi"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/scribble"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/subclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/tictactoe"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/toolbar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/wHyperLink"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/autolayout/autolayoutEditor"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/autolayout/demo"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/autolayout/layout1"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/autolayout/layout2"
  exec "nim c -d:release --opt:size --passL:-s --app:gui examples/autolayout/layout3"

# Examples for Windows XP

task xpexample, "Build all the examples for Windows XP":
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/demo"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/dialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/dragdrop"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/draggable"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/frame"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/helloworld"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/layout1"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/layout2"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/layout3"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/lowlevel"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/menu"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/nonsubclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/pickicondialog"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/rebar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/reversi"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/scribble"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/subclassing"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/tictactoe"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/toolbar"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/wHyperLink"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/autolayout/autolayoutEditor"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/autolayout/demo"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/autolayout/layout1"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/autolayout/layout2"
  exec "nim c -d:release --opt:size --passL:-s --app:gui --cpu:i386 -d:useWinXP examples/autolayout/layout3"

# Clean

task clean, "Delete all the executable files":
  exec "cmd /c IF EXIST examples\\*.exe del examples\\*.exe"
  exec "cmd /c IF EXIST examples\\autolayout\\*.exe del examples\\autolayout\\*.exe"
