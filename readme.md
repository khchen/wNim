# wNim

wNim is Nim's Windows GUI Framework, based on [winim](https://github.com/khchen/winim).
Layout DSL is powered by Yuriy Glukhov's Kiwi constraint solving library.

## Code Examples
Basic code structure:
```nimrod
import wNim

let app = App()
let frame = Frame(title="Hello World", size=(400, 300))

frame.center()
frame.show()
app.mainLoop()
```

[Event handler](https://khchen.github.io/wNim/wEvent.html):
```nimrod
button.wEvent_Button do ():
  frame.delete()

frame.wIdExit do ():
  frame.delete()

frame.wEvent_Size do ():
  layout()
```

[Layout DSL](https://khchen.github.io/wNim/wResizable.html):
```nimrod
panel.layout:
  staticText:
    top = panel.top + 10
    left = panel.left + 10
  button:
    right + 10 = panel.right
    bottom + 10 = panel.bottom
```

[Autolayout](https://khchen.github.io/wNim/autolayout.html):
```nimrod
panel.autolayout """
  V:|-{col1:[child1(child2)]-[child2]}-|
  V:|-{col2:[child3(child4,child5)]-[child4]-[child5]}-|
  H:|-[col1(col2)]-[col2]-|
"""
```

Getter and Setter:
```nimrod
let frame = Frame()

# wxWidgets/wxPython style
frame.setLabel("Hello World")
echo frame.getLabel()

# nim style
frame.label = "Hello World"
echo frame.label
```

## Screenshots
![demo.nim](https://github.com/khchen/wNim/blob/master/examples/images/screenshot.png)

## Install
With git on windows:

    nimble install wNim

Without git:

    1. Download and unzip this moudle (by click "Clone or download" button).
    2. Start a console, change current dir to the folder which include "wNim.nimble" file.
       (for example: C:\wNim-master\wNim-master>)
    3. Run "nimble install"

## Compile
To compile the examples, try following command:

    nim c -d:release --opt:size --passL:-s --app:gui demo.nim

For Windows XP compatibility, add:

    -d:useWinXP

To compile by [Tiny C Compiler](https://bellard.org/tcc/), or want to add some resource files, take a look at https://github.com/khchen/winim/tree/master/tcclib

## Q & A
### Q: Why I start this project?
In the first, I just wanted to write some code to test and prove my winim library.
I wrote some event handler, some GUI control class, more and more...Finally, it
become a whole GUI framework now.

### Q: Why the class and api name look so like wxWidgets?
English is not my mother tongue, I often have no idea how to name an object or
a function. So I borrow wxWidgets' names to develop my own framework.

### Q: Why not add linux or macOS support?
I start from winim. It is just a Windows API module.

### Q: How is wNim compare to nimx, libui, NiGui etc?
They are all good GUI librarys. I think wNim is easier to use and produce smaller exe file.
However, it only support Windows system.

## Docs
* https://khchen.github.io/wNim/wNim.html

## License
Read license.txt for more details.

Copyright (c) 2017-2019 Kai-Hung Chen, Ward. All rights reserved.
