Version 0.4
-------------
* Speed up compile time (use import file generate by winimx).
* Fix Windows XP compatibility.
* Add autolayout keyword: alias.
* Add wButton.setIcon(), wButton.getIcon().
* Remove experimental GUI DSL.
* Don't maintain compatibility with Nim Compiler 0.18 anymore.

Version 0.3
-----------
* Add autolayout module to parse Visual Format Language.
* Modify wResizable to use autolayout module.
* Improve wResizer, significant speed up wNim layout DSL performance.
* Add example: autolayoutEditor.nim, and other examples to use autolayout.
* Add example: pickicondialog.nim.
* Add wTextCtrl.setFont() to set default font for rich editor.
* Add wListCtrl.setItemSpacing().
* Add wFrame.getReturnCode() and wFrame.setReturnCode().
* Update for Nim Compiler 0.19.9
* Fix a lot of small bugs.

Version 0.2
-----------
* Add wIconImage class.
* wImage, wBitmap, wIcon, and wCursor can convert between each other now.
* Remove deprecated "this" pragma.
* Add example: rebar.nim

Version 0.1.4
-------------
* Int expressions are totally supported by layout DSL now. (Fix #4)
* Add wWindow.getToolTip(). (Fix #6)

Version 0.1.3
-------------
* Add wIpCtrl class, the IP v4 address control.
* Add wRebar class, the windows Rebar control (experimental).
* Add wTeProcessTab style and wEvent_TextEnter event to wTextCtrl.
* Add wEvent_TextEnter event to wSpinCtrl.
* Add wToolBar.getToolSize().
* Add wImageList.getHandle().
* Update for Nim Compiler 0.19.
* All example can compile by Tiny C Compiler.

Version 0.1.2
-------------
* Catch unhandled exception in event handler to prevent crash.
* Add wDataObject for drag-drop and clipboard support.
* Add wWindow.setToolTip(), wWindow.unsetToolTip().
* Add example: dragdrop.nim
