#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2020 Ward
#
#====================================================================

##  wNim is Nim's Windows GUI framework.
##
##  Reference
##  =========
##
##  Basic Elements
##  --------------
##  - `wTypes <wTypes.html>`_
##  - `wMacros <wMacros.html>`_
##  - `wApp <wApp.html>`_
##  - `wImage <wImage.html>`_
##  - `wImageList <wImageList.html>`_
##  - `wIconImage <wIconImage.html>`_
##  - `wResizer <wResizer.html>`_
##  - `wResizable <wResizable.html>`_
##  - `wAcceleratorTable <wAcceleratorTable.html>`_
##  - `wDataObject <wDataObject.html>`_
##  - `wPrintData <wPrintData.html>`_
##  - `wUtils <wUtils.html>`_
##
##  Windows
##  -------
##  - `wWindow <wWindow.html>`_
##  - `wPanel <wPanel.html>`_
##  - `wFrame <wFrame.html>`_
##  - `wToolTip <wToolTip.html>`_
##
##  Menus
##  -----
##  - `wMenuBar <wMenuBar.html>`_
##  - `wMenu <wMenu.html>`_
##  - `wMenuItem <wMenuItem.html>`_
##  - `wMenuBase <wMenuBase.html>`_
##
##  GUI Controls
##  ------------
##  - `wControl <wControl.html>`_
##  - `wStatusBar <wStatusBar.html>`_
##  - `wToolBar <wToolBar.html>`_
##  - `wButton <wButton.html>`_
##  - `wCheckBox <wCheckBox.html>`_
##  - `wRadioButton <wRadioButton.html>`_
##  - `wStaticBox <wStaticBox.html>`_
##  - `wTextCtrl <wTextCtrl.html>`_
##  - `wListBox <wListBox.html>`_
##  - `wComboBox <wComboBox.html>`_
##  - `wCheckComboBox <wCheckComboBox.html>`_
##  - `wStaticText <wStaticText.html>`_
##  - `wStaticBitmap <wStaticBitmap.html>`_
##  - `wStaticLine <wStaticLine.html>`_
##  - `wNoteBook <wNoteBook.html>`_
##  - `wSpinCtrl <wSpinCtrl.html>`_
##  - `wSpinButton <wSpinButton.html>`_
##  - `wSlider <wSlider.html>`_
##  - `wScrollBar <wScrollBar.html>`_
##  - `wGauge <wGauge.html>`_
##  - `wCalendarCtrl <wCalendarCtrl.html>`_
##  - `wDatePickerCtrl <wDatePickerCtrl.html>`_
##  - `wTimePickerCtrl <wTimePickerCtrl.html>`_
##  - `wListCtrl <wListCtrl.html>`_
##  - `wTreeCtrl <wTreeCtrl.html>`_
##  - `wHyperlinkCtrl <wHyperlinkCtrl.html>`_
##  - `wSplitter <wSplitter.html>`_
##  - `wIpCtrl <wIpCtrl.html>`_
##  - `wWebView <wWebView.html>`_
##  - `wHotkeyCtrl <wHotkeyCtrl.html>`_
##  - `wRebar <wRebar.html>`_  (experimental)
##
##  Device Contexts
##  ---------------
##  - `wDC <wDC.html>`_
##  - `wMemoryDC <wMemoryDC.html>`_
##  - `wClientDC <wClientDC.html>`_
##  - `wWindowDC <wWindowDC.html>`_
##  - `wScreenDC <wScreenDC.html>`_
##  - `wPaintDC <wPaintDC.html>`_
##  - `wPrinterDC <wPrinterDC.html>`_
##
##  GDI Objects
##  -----------
##  - `wGdiObject <wGdiObject.html>`_
##  - `wFont <wFont.html>`_
##  - `wPen <wPen.html>`_
##  - `wBrush <wBrush.html>`_
##  - `wBitmap <wBitmap.html>`_
##  - `wIcon <wIcon.html>`_
##  - `wCursor <wCursor.html>`_
##  - `wRegion <wRegion.html>`_
##
##  Dialogs
##  -------
##  - `wDialog <wDialog.html>`_
##  - `wMessageDialog <wMessageDialog.html>`_
##  - `wDirDialog <wDirDialog.html>`_
##  - `wFileDialog <wFileDialog.html>`_
##  - `wColorDialog <wColorDialog.html>`_
##  - `wFontDialog <wFontDialog.html>`_
##  - `wTextEntryDialog <wTextEntryDialog.html>`_
##  - `wPasswordEntryDialog <wPasswordEntryDialog.html>`_
##  - `wFindReplaceDialog <wFindReplaceDialog.html>`_
##  - `wPageSetupDialog <wPageSetupDialog.html>`_
##  - `wPrintDialog <wPrintDialog.html>`_
##
##  Events
##  ------
##  - `wEvent <wEvent.html>`_
##  - `wMouseEvent <wMouseEvent.html>`_
##  - `wKeyEvent <wKeyEvent.html>`_
##  - `wSizeEvent <wSizeEvent.html>`_
##  - `wMoveEvent <wMoveEvent.html>`_
##  - `wContextMenuEvent <wContextMenuEvent.html>`_
##  - `wScrollWinEvent <wScrollWinEvent.html>`_
##  - `wTrayEvent <wTrayEvent.html>`_
##  - `wDragDropEvent <wDragDropEvent.html>`_
##  - `wNavigationEvent <wNavigationEvent.html>`_
##  - `wSetCursorEvent <wSetCursorEvent.html>`_
##  - `wStatusBarEvent <wStatusBarEvent.html>`_
##  - `wCommandEvent <wCommandEvent.html>`_
##  - `wScrollEvent <wScrollEvent.html>`_
##  - `wSpinEvent <wSpinEvent.html>`_
##  - `wHyperlinkEvent <wHyperlinkEvent.html>`_
##  - `wListEvent <wListEvent.html>`_
##  - `wTreeEvent <wTreeEvent.html>`_
##  - `wIpEvent <wIpEvent.html>`_
##  - `wWebViewEvent <wWebViewEvent.html>`_
##  - `wDialogEvent <wDialogEvent.html>`_
##
##  Constants
##  ---------
##  - `wKeyCodes <wKeyCodes.html>`_
##  - `wColors <wColors.html>`_
##
##  Autolayout
##  ----------
##  - `autolayout <autolayout.html>`_

{.experimental, deadCodeElim: on.}

when not defined(Nimdoc):
  import
    wNim/private/[wTypes, wMacros, wApp, wAcceleratorTable, wDataObject, wPrintData,
      wIconImage, wImage, wImageList, wEvent, wResizable, wResizer, wWindow,
      wPanel, wFrame, wToolTip, wUtils, autolayout],

    wNim/private/gdiobjects/[wBitmap, wBrush, wCursor, wFont, wGdiObject, wIcon, wPen, wRegion],

    wNim/private/dc/[wDC, wClientDC, wMemoryDC, wPaintDC, wPrinterDC, wScreenDC, wWindowDC],

    wNim/private/menu/[wMenu, wMenuBar, wMenuBase, wMenuItem],

    wNim/private/controls/[wControl, wButton, wCalendarCtrl, wCheckBox, wCheckComboBox,
      wComboBox, wDatePickerCtrl, wGauge, wHotkeyCtrl, wHyperlinkCtrl, wIpCtrl,
      wListBox, wListCtrl, wNoteBook, wRadioButton, wRebar, wScrollBar, wSlider,
      wSpinButton, wSpinCtrl, wSplitter, wStaticBitmap, wStaticBox, wStaticLine,
      wStaticText, wStatusBar, wTextCtrl, wTimePickerCtrl, wToolBar, wTreeCtrl,
      wWebView],

    wNim/private/dialogs/[wColorDialog, wDialog, wDirDialog, wFileDialog, wFindReplaceDialog,
      wFontDialog, wMessageDialog, wPageSetupDialog, wPasswordEntryDialog,
      wPrintDialog, wTextEntryDialog],

    wNim/private/consts/[wColors, wKeyCodes]

  export
    wTypes, wMacros, wApp, wAcceleratorTable, wDataObject, wPrintData,
    wIconImage, wImage, wImageList, wEvent, wResizable, wResizer, wWindow,
    wPanel, wFrame, wToolTip, wUtils, autolayout,

    wBitmap, wBrush, wCursor, wFont, wGdiObject, wIcon, wPen, wRegion,

    wDC, wClientDC, wMemoryDC, wPaintDC, wPrinterDC, wScreenDC, wWindowDC,

    wMenu, wMenuBar, wMenuBase, wMenuItem,

    wControl, wButton, wCalendarCtrl, wCheckBox, wCheckComboBox,
    wComboBox, wDatePickerCtrl, wGauge, wHotkeyCtrl, wHyperlinkCtrl, wIpCtrl,
    wListBox, wListCtrl, wNoteBook, wRadioButton, wRebar, wScrollBar, wSlider,
    wSpinButton, wSpinCtrl, wSplitter, wStaticBitmap, wStaticBox, wStaticLine,
    wStaticText, wStatusBar, wTextCtrl, wTimePickerCtrl, wToolBar, wTreeCtrl,
    wWebView,

    wColorDialog, wDialog, wDirDialog, wFileDialog, wFindReplaceDialog,
    wFontDialog, wMessageDialog, wPageSetupDialog, wPasswordEntryDialog,
    wPrintDialog, wTextEntryDialog,

    wColors, wKeyCodes
