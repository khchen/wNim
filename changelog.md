Version 0.7.1
-------------
* wUtil: add wGetWinVersion().
* Fix bug in pickicondialog.nim.

Version 0.7.0
-------------
* Add wRegion, wPrinterDC, wPrintData, wPageSetupDialog, and wPrintDialog.
* Add wDialog class. All common dialogs are now subclasses of wWindow.
* Add new events for dialogs: wEvent_DialogCreated, wEvent_DialogHelp, wEvent_DialogApply, etc.
* wWidnow: add setShape(), hasScrollbar(), scrollLines(), scrollPages(), disableFocus(), getDpi(), getDpiScaleRatio(), dpiScale(), dpiAutoScale().
* wWidnow: setDraggable() can be used by top-level window now.
* wWidnow: event handler can be disconnected from window by given proc now.
* wWindow: can use specified command to show a window.
* wWindow: exports processMessage() for convenient.
* wFrame: add isModal(), getStatusBar().
* wFrame: the default event handler for wEvent_Size can be changed now **(Breaking Change)**.
* wToolBar: add wTbNoAlign, wTbNoResize.
* wDC: add getRegion(), setRegion(), getCharHeight(), getCharWidth(), getFontMetrics(), stretchBlitQuality().
* wEvent: add wWparam and wLparam types. In case we need "cast" for creation event object.
* wUtil: add wGetSystemMetric(), wGetDefaultPrinter(), wSetDefaultPrinter(), wGetPrinters(), wSetSysemDpiAware(), wSetPerMonitorDpiAware().
* wPredefined: add wNilRegion.
* Add examples: shapewin.nim and printpreview.nim
* Fix bugs.

Version 0.6.0
-------------
* Add wWebView, wFontDialog, wTextEntryDialog, wPasswordEntryDialog, and wFindReplaceDialog.
* wFont: add getStrikeOut(), setStrikeOut().
* wFrame: add showWindowModal(), wDefaultDialogStyle.
* wCheckBox, wRadioButton: add click().
* Remove show() for dialogs. Use showModal() instead.
* Rename showModalResult() to display().
* Rewrite examples/frame.nim and examples/dialog.nim to demonstrate the dialogs.
* Add examples/webView.nim to demonstrate the wWebView class.
* Fix some small bugs.

Version 0.5.0
-------------
* Update for Nim Compiler 0.20.0.
* wWindow: add hasFocus(), improve popupMenu().
* wListBox: add setData(), getData(), getRect(), getFocused(), setFocused().
* wMenuItem: add detach(), getData(), setData().
* wImageList: add getBitmap(), getIcon().
* wSplitter: add wSpVertical, wSpHorizontal.
* wTreeCtrl: add wTrShowSelectAlways.
* wUtils: add wSetMousePosition().
* Docs: add wUtils.html page.
* Fix: TCC don't support size of UncheckArray.
* Fix: wMenu/wMenuItem let the GC crash.
* Fix: Menu event sent to wWindow instead of wFrame.
* Fix: Rename all HyperLink to Hyperlink.

Version 0.4.0
-------------
* Speed up compile time (use import file generate by winimx).
* Fix Windows XP compatibility.
* Add autolayout keyword: alias.
* Add wButton.setIcon(), wButton.getIcon().
* Remove experimental GUI DSL.
* Don't maintain compatibility with Nim Compiler 0.18 anymore.

Version 0.3.0
-------------
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

Version 0.2.0
-------------
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
