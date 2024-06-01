# wNim

wNim is Nim's Windows GUI Framework, based on [winim](https://github.com/khchen/winim).
Layout DSL is powered by Yuriy Glukhov's Kiwi constraint solving library.

## Code Examples
Basic code structure:
```nim
import wNim

let app = App()
let frame = Frame(title="Hello World", size=(400, 300))

frame.center()
frame.show()
app.mainLoop()
```

[Event handler](https://khchen.github.io/wNim/wEvent.html):
```nim
button.wEvent_Button do ():
  frame.delete()

frame.wIdExit do ():
  frame.delete()

frame.wEvent_Size do ():
  layout()
```

[Layout DSL](https://khchen.github.io/wNim/wResizable.html):
```nim
panel.layout:
  staticText:
    top = panel.top + 10
    left = panel.left + 10
  button:
    right + 10 = panel.right
    bottom + 10 = panel.bottom
```

[Autolayout](https://khchen.github.io/wNim/autolayout.html):
```nim
panel.autolayout """
  V:|-[col1:[child1(child2)]-[child2]]-|
  V:|-[col2:[child3(child4,child5)]-[child4]-[child5]]-|
  H:|-[col1(col2)]-[col2]-|
"""
```

Getter and Setter:
```nim
let frame = Frame()

# wxWidgets/wxPython style
frame.setLabel("Hello World")
echo frame.getLabel()

# nim style
frame.label = "Hello World"
echo frame.label
```

## Screenshots
![demo.nim](https://github.com/khchen/wNim/blob/master/docs/images/screenshot.png)

## Install
With git on Windows:

    nimble install wNim

Without git:

    1. Download and unzip this module (by clicking the "Code" button).
    2. Start a console and change the current dir to the folder with the "wNim.nimble" file.
       (for example C:\wNim-master\wNim-master>)
    3. Run "nimble install"

## Import
The easiest way to use wNim is to import the whole package.

```nim
import wNim
```

However, the modules of wNim can also be imported one by one to speed up compilation time.

```nim
import wNim/[wApp, wFrame]
```

There are some simple rules:

    1. For every class in wNim, there is a corresponding module.
       For example: wFrame, wIcon, wMenu, etc.
    2. The wApp module must be imported into every wNim program.
    3. Symbols in wColors and wKeyCodes modules are imported automatically with the wApp module.
    4. All event classes in wNim share the same constructor: Event(), so all subclass modules
       of wEvent will be automatically imported with the wEvent module.
    5. wMacros, wUtils, and wTypes modules are three special modules in wNim.
       See their documentation for more information.

## Compile
To compile the examples, try the following command:

    nim c -d:release -d:strip --opt:size --app:gui demo.nim

For Windows XP compatibility, add:

    -d:useWinXP

To compile wNim with the [Tiny C Compiler](https://bellard.org/tcc/) or to add resource files, take a look at https://github.com/khchen/winim/tree/master/tcclib

## Q & A
### Q: Why did I start this project?
At first, I just wanted to write some code to test and prove my Winim library.
I wrote some event handlers, some GUI control classes, and more. Finally, it
became a whole GUI framework.

### Q: Why do the class and API names look so alike wxWidgets?
English is not my mother tongue. I often have no idea how to name an object or
a function. So, I borrowed wxWidgets' names to develop my own framework.

### Q: Why not add Linux or macOS support?
I start from winim. It is just a Windows API module.

### Q: How is wNim compare to nimx, libui, NiGui etc?
They are all good GUI libraries. I think wNim is easier to use and produces smaller .exe files.
However, it only supports Windows.

## Docs
* https://khchen.github.io/wNim/wNim.html
* https://github.com/khchen/wNim/wiki

## License
Read license.txt for more details.

Copyright (c) 2017-2021 Kai-Hung Chen, Ward. All rights reserved.
