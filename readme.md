# wNim

wNim is Nim's Windows GUI Framework, based on winim.
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

Event handler:
```nimrod
button.wEvent_Button do ():
  frame.delete()

frame.wIdExit do ():
  frame.delete()

frame.wEvent_Size do ():
  layout()
```

Layout DSL:
```nimrod
panel.layout:
  staticText:
    top = panel.top + 10
    left = panel.left + 10
  button:
    right + 10 = panel.right
    bottom + 10 = panel.bottom
```

## Screenshots
![demo.nim](https://github.com/khchen/wNim/blob/master/examples/images/screenshot.png)

## Q & A
### Q: Why start this project?
In the first, I just wanto to write some code to test and prove my winim library
is usable. I wrote some event handler, some GUI control class, and then, it
become a whole GUI framework.

### Q: Why the class and api name looks so like wxWidgets?
English is not my mother tongue, I often have no idea how to name a object or
a function. So I borrow wxWidgets' names to develop my own framework.

### Q: Why not add linux or macos support?
I start from winim. It is just the Windows API module.

### Q: How is wNim compare to nimx, libui, NiGui etc?
I think wNim is easier to use and produce smaller exe. However, it only support
Windows system.

## Docs
* https://khchen.github.io/wNim/wNim.html

## License
Read license.txt for more details.

Copyright (c) 2016-2018 Kai-Hung Chen, Ward. All rights reserved.
