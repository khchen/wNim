Version 0.10.2
--------------
* Merged pull requests of Duncan Clarke.
* Fix broken document about controls.
* Fix #41, #44.

Version 0.10.1
--------------
* Don't maintain compatibility with Nim Compiler 0.19.
* Fix bugs.

Version 0.10.0
--------------
* wPrintDialog: rename wEvent_PrintChanged to wEvent_PrinterChanged **(Breaking Change)**.
* Add wToolTip class (a standalone tooltip anywhere on the screen).
* wControl: add setBuddy(). This function can achieve a text control with a "Browse" button.
* wToolBar: setBackgroundColor() works for toolbar now (transparent by default).
* wStatusBar: add setHelpIndex(), getHelpIndex().
* wDirDialog: remove wDdXpCompatible (WinXP compatible code only exists with -d:useWinXp).
* Modify examples/customdialog.nim and pickicondialog.nim to demonstrate setBuddy().
* Fix bugs.

Version 0.9.0
-------------
* wNim modules can be imported one by one to speed up compilation (Requires nim version >= 0.20.0).
* wNim don't export symbols in winim/[winstr, utils] anymore **(Breaking Change)**.
* wBitmap: constructor rename to Bitmap() now (old name is Bmp()) **(Breaking Change)**.
* wApp: add broadcastTopLevelMessage() and broadcastMessage().
* wWindow: add activate(), isMouseInWindow(), setRedraw(), and queueMessage().
* wWindow: add getToolBar().
* wFrame: remove setMenuBar(). Use MenuBar(frame) constructor or MenuBar.attach(frame) instead.
* wFrame: remove createStatusBar(). Use StatusBar(frame) constructor instead.
* wFrame: remove getStatusBar(). Use wWindow.getStatusBar() instead.
* wToolBar, wStatusBar, wRebar: showing or hiding generates wEvent_Size for parent window.
* wMenu: add Menu(hMenu: HMENU) constructor for wrap system menu handle.
* wComboBox: add isPopup().
* wCheckComboBox: add changeStyle(), isPopup(), and wCcNormalColor style.
* wHyperlinkCtrl: remove the *url* parameter from constructor. Use setUrl() instead.
* wUtils: remove wGetMessagePosition(). Use wGetMousePosition() instead.
* wMacros: add wClass macro.
* Remove wPredefined.nim. Predefined objects are moved into corresponding modules.
* Rename and rewrite examples/lowlevel.nim to winsdk.nim.
* Add examples: colors.nim.
* Fix bugs.

Version 0.8.0
-------------
* Add wCheckComboBox and wHotkeyCtrl.
* wEvent: add getHotkeyId() and getHotkey().
* wWindow: add getData(), setData(), wModNoRepeat const for registerHotKey().
* wWindow: setBackgroundColor() supports transparent.
* wDC: add drawLabel().
* wPaintDC: add getPaintRect().
* wListBox: add selectAll(), deselectAll().
* wUtil: add wGetWinVersion().
* wNoteBook: theme background is used by default.
* wComboBox: press enter key to popup/dismiss drop-down.
* Fix bugs.

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
* Add examples: shapewin.nim and printpreview.nim.
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
