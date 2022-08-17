Version 0.13.2
--------------
* wResizable: allow dot expr in layout DSL (#104).
* autolayout: allow accent quoted (``) nim symbol in autolayout (dot expr must be quoted).
* autolayout: allow priority and arithmetic in spacing setting.
* autolayout: allow nested alias.
* wApp: add `run` as alias of `mainLoop` to start an app.
* wCheckComboBox: Fix drawing bug on Windows 11.
* examples/tictactoe.nim: fix typo (#96).

Version 0.13.1
--------------
* autolayout: allow underline in variable names (#91, thanks to rockcavera).

Version 0.13.0
--------------
* Add wMenuBarCtrl class: a menubar that can be placed everywhere. For example, in the rebar control.
* wTextCtrl: Add a lot of RTF relate functions: writeRtfText(), appendRtfText(), writeLink(),
  appendLink(), writeImage(), appendImage(), setStyle(), setFormat(), setDefaultFormat(),
  enableAutoUrlDetect(), zoom(), etc.
  Remove formatSelection(), use setFormat() instead **(Breaking Change)**.
* Add wTextLinkEvent class to deal with hyperlink event in wTextCtrl.
* wApp: App() can accept an extra parameter to set the default DPI awareness.
* wWindow: Add showCaret(), getToolBars() and style wClipSiblings.
* wImage: Image object can be created based on binary bytes along with size and format information.
* wToolBar: Add undock().
* wMenuBar: Remove getCount() and getHandle(). wMenuBase already has these procs.
* Examples: Add textctrl.nim; modify rebar.nim and menu.nim to demonstrate new features.
* Fix typo and bugs. wSetSysemDpiAware => wSetSystemDpiAware **(Breaking Change)**.
* Don't maintain compatibility with Nim Compiler 1.0 (requires nim >= 1.2.0).

Version 0.12.0
--------------
* autolayout: Using excellent npeg module to parse visual format language now, this brings
  more features (alias, quote, etc.) and less bugs. The most important change is that
  all rules have default priority to avoid annoying *UnsatisfiableConstraintException*.
* wRebar: Add a lot of methods. wRebar class is fully functioning and not experimental
  anymore. **(Breaking Change)**
* wResizer: Add some consts that can be used in layout DLS and autolayout VFL as priority keywords.
* wEvent: getKeyStatus() returns set of key-codes instead of array **(Breaking Change)**.
* Modify examples/autolayoutEditor.nim and dialog.nim to demonstrate new features of autolayout.
* Modify examples/rebar.nim to demonstrate new feature of wRebar.
* Fix bugs.

Version 0.11.5
--------------
* wWindow: Add lift(), lower(), and cover() for Z-order adjustment.
* Add prebuilt resource file for vcc.

Version 0.11.4
--------------
* Update for Nim Compiler 1.4.0.
* wWindow: Fix incorrect error message in event loop.
* wResizable: Add workaround for compiler bug with --gc:arc.

Version 0.11.3
--------------
* wImageList: Fix incorrect index in getBitmap() and getIcon() (#64, thanks to BugFix).
* wTreeEvent: Fix getItem() and getOldItem(). Remove the mistake comment.

Version 0.11.2
--------------
* Slightly modify the event system. wNim now uses the new wEventRegister() macro to define all the event.
  A newly-defined event don't need to use `const wEvent_MyNewEvent = wEvent_App + 1` anymore.
  The constructor of wEvent `Event()` can return the corresponding object of the subclass that registered
  by wEventRegister. All of this means that the GUI controls and their event can be designd as plugin
  module more easily **(Breaking Change)**.
* wMacro: Add wEventRegister() macro.
* wEvent: Add wEventBase as superclass to wEvent so that shouldPropagate(self: wEvent) can be overridden.
* wApp: Remove setMessagePropagation(), isMessagePropagation(). Override shouldPropagate() method instead.
* wTextCtrl: Add enableAutoComplete(), disableAutoComplete() to use the Windows built-in autocomplete feature.
* wDC: Add drawRegion().
* autolayout: Fix bugs. Now the syntax and behavior of *view stacks* are the same as autolayout.js.
  The old curly brackets syntax is also available for backward compatibility.
* wResizable: A wResizable object supports all the layout DSL template like a wWindow object now.
* Modify examples/wHyperlink.nim to demonstrate wEventRegister().
* Modify examples/webView.nim to demonstrate wTextCtrl.enableAutoComplete().
* Fix bugs.

Version 0.11.1
--------------
* Update for Nim Compiler 1.3.5 (devel).
* wApp: Add setMessageLoopWait(), getMessageLoopWait().
* wTextCtrl: Add loadRtf(), saveRtf(), loadRtfFile(), saveRtfFile().
* wWindow: Add sendMessage().
* Add example: calendar.nim.
* Fix bugs.

Version 0.11.0
--------------
* Don't maintain compatibility with Nim Compiler 0.20.
* Use destructor instead of finalizer internally. Now wNim works with --gc:arc.
* wApp: Don't need to call App() to create a wApp object at thread begining anymore.
* wApp: Add addMessageLoopHook()/removeMessageLoopHook() to add the hook proc to the message loop.
* wDC: getBackground() returns wColor instead of wBrush **(Breaking Change)**.
* WDC: clear() has an additional parameter to specify the custom brush as the background.
* wPrintDialog: Add display() and remove useless initDefault parameter in initializer.
* wMenu: Fix bug about using wIdAny in wMenu/wMenuItem.
* wMenu: Add removeAll() to remove all the menu items.
* wMenuBar: Add removeAll() to remove all the menus.
* wDialog: After a dialog closed, the event handler connected to the dialog will be cleared **(Breaking Change)**.
* wMacros: In wClass macro, final() proc is optional. And all final() for superclasses (if exists) will be invoked automatically **(Breaking Change)**.
* wWebView: Remove codes to avoid stealing focus.
* Fix other bugs.

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
* wPrintDialog: Rename wEvent_PrintChanged to wEvent_PrinterChanged **(Breaking Change)**.
* Add wToolTip class (a standalone tooltip anywhere on the screen).
* wControl: Add setBuddy(). This function can achieve a text control with a "Browse" button.
* wToolBar: setBackgroundColor() works for toolbar now (transparent by default).
* wStatusBar: Add setHelpIndex(), getHelpIndex().
* wDirDialog: Remove wDdXpCompatible (WinXP compatible code only exists with -d:useWinXp).
* Modify examples/customdialog.nim and pickicondialog.nim to demonstrate setBuddy().
* Fix bugs.

Version 0.9.0
-------------
* wNim modules can be imported one by one to speed up compilation (Requires nim version >= 0.20.0).
* wNim don't export symbols in winim/[winstr, utils] anymore **(Breaking Change)**.
* wBitmap: Constructor rename to Bitmap() now (old name is Bmp()) **(Breaking Change)**.
* wApp: Add broadcastTopLevelMessage() and broadcastMessage().
* wWindow: Add activate(), isMouseInWindow(), setRedraw(), and queueMessage().
* wWindow: Add getToolBar().
* wFrame: Remove setMenuBar(). Use MenuBar(frame) constructor or MenuBar.attach(frame) instead.
* wFrame: Remove createStatusBar(). Use StatusBar(frame) constructor instead.
* wFrame: Remove getStatusBar(). Use wWindow.getStatusBar() instead.
* wToolBar, wStatusBar, wRebar: Showing or hiding generates wEvent_Size for parent window.
* wMenu: Add Menu(hMenu: HMENU) constructor for wrap system menu handle.
* wComboBox: Add isPopup().
* wCheckComboBox: Add changeStyle(), isPopup(), and wCcNormalColor style.
* wHyperlinkCtrl: Remove the *url* parameter from constructor. Use setUrl() instead.
* wUtils: Remove wGetMessagePosition(). Use wGetMousePosition() instead.
* wMacros: Add wClass macro.
* Remove wPredefined.nim. Predefined objects are moved into corresponding modules.
* Rename and rewrite examples/lowlevel.nim to winsdk.nim.
* Add example: colors.nim.
* Fix bugs.

Version 0.8.0
-------------
* Add wCheckComboBox and wHotkeyCtrl.
* wEvent: Add getHotkeyId() and getHotkey().
* wWindow: Add getData(), setData(), wModNoRepeat const for registerHotKey().
* wWindow: setBackgroundColor() supports transparent.
* wDC: Add drawLabel().
* wPaintDC: Add getPaintRect().
* wListBox: Add selectAll(), deselectAll().
* wUtil: Add wGetWinVersion().
* wNoteBook: Theme background is used by default.
* wComboBox: Press enter key to popup/dismiss drop-down.
* Fix bugs.

Version 0.7.0
-------------
* Add wRegion, wPrinterDC, wPrintData, wPageSetupDialog, and wPrintDialog.
* Add wDialog class. All common dialogs are now subclasses of wWindow.
* Add new events for dialogs: wEvent_DialogCreated, wEvent_DialogHelp, wEvent_DialogApply, etc.
* wWidnow: Add setShape(), hasScrollbar(), scrollLines(), scrollPages(), disableFocus(), getDpi(), getDpiScaleRatio(), dpiScale(), dpiAutoScale().
* wWidnow: setDraggable() can be used by top-level window now.
* wWidnow: Event handler can be disconnected from window by given proc now.
* wWindow: Can use specified command to show a window.
* wWindow: Exports processMessage() for convenient.
* wFrame: Add isModal(), getStatusBar().
* wFrame: The default event handler for wEvent_Size can be changed now **(Breaking Change)**.
* wToolBar: Add wTbNoAlign, wTbNoResize.
* wDC: Add getRegion(), setRegion(), getCharHeight(), getCharWidth(), getFontMetrics(), stretchBlitQuality().
* wEvent: Add wWparam and wLparam types. In case we need "cast" for creation event object.
* wUtil: Add wGetSystemMetric(), wGetDefaultPrinter(), wSetDefaultPrinter(), wGetPrinters(), wSetSystemDpiAware(), wSetPerMonitorDpiAware().
* wPredefined: Add wNilRegion.
* Add examples: shapewin.nim and printpreview.nim.
* Fix bugs.

Version 0.6.0
-------------
* Add wWebView, wFontDialog, wTextEntryDialog, wPasswordEntryDialog, and wFindReplaceDialog.
* wFont: Add getStrikeOut(), setStrikeOut().
* wFrame: Add showWindowModal(), wDefaultDialogStyle.
* wCheckBox, wRadioButton: Add click().
* Remove show() for dialogs. Use showModal() instead.
* Rename showModalResult() to display().
* Rewrite examples/frame.nim and examples/dialog.nim to demonstrate the dialogs.
* Add examples/webView.nim to demonstrate the wWebView class.
* Fix some small bugs.

Version 0.5.0
-------------
* Update for Nim Compiler 0.20.0.
* wWindow: Add hasFocus(), improve popupMenu().
* wListBox: Add setData(), getData(), getRect(), getFocused(), setFocused().
* wMenuItem: Add detach(), getData(), setData().
* wImageList: Add getBitmap(), getIcon().
* wSplitter: Add wSpVertical, wSpHorizontal.
* wTreeCtrl: Add wTrShowSelectAlways.
* wUtils: Add wSetMousePosition().
* Docs: Add wUtils.html page.
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
