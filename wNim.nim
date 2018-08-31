#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

##  wNim is Nim's Windows gui framework.
##
##  Reference
##  =========
##
##  Basic Elements
##  --------------
##  - `wTypes <wTypes.html>`_
##  - `wApp <wApp.html>`_
##  - `wImage <wImage.html>`_
##  - `wImageList <wImageList.html>`_
##  - `wResizer <wResizer.html>`_
##  - `wResizable <wResizable.html>`_
##  - `wAcceleratorTable <wAcceleratorTable.html>`_
##
##  Windows
##  -------
##  - `wWindow <wWindow.html>`_
##  - `wPanel <wPanel.html>`_
##  - `wFrame <wFrame.html>`_
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
##  - `wComboBox <wComboBox.html>`_
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
##  - `wListBox <wListBox.html>`_
##  - `wListCtrl <wListCtrl.html>`_
##  - `wTreeCtrl <wTreeCtrl.html>`_
##  - `wHyperlinkCtrl <wHyperlinkCtrl.html>`_
##  - `wSplitter <wSplitter.html>`_
##
##  Device Contexts
##  ---------------
##  - `wDC <wDC.html>`_
##  - `wMemoryDC <wMemoryDC.html>`_
##  - `wClientDC <wClientDC.html>`_
##  - `wWindowDC <wWindowDC.html>`_
##  - `wScreenDC <wScreenDC.html>`_
##  - `wPaintDC <wPaintDC.html>`_
##
##  GDI Objects
##  -----------
##  - `wGDIObject <wGDIObject.html>`_
##  - `wFont <wFont.html>`_
##  - `wPen <wPen.html>`_
##  - `wBrush <wBrush.html>`_
##  - `wBitmap <wBitmap.html>`_
##  - `wIcon <wIcon.html>`_
##  - `wCursor <wCursor.html>`_
##  - `wPredefined <wPredefined.html>`_
##
##  Dialogs
##  -------
##  - `wMessageDialog <wMessageDialog.html>`_
##  - `wDirDialog <wDirDialog.html>`_
##  - `wFileDialog <wFileDialog.html>`_
##  - `wColorDialog <wColorDialog.html>`_
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
##  - `wNavigationEvent <wNavigationEvent.html>`_
##  - `wSetCursorEvent <wSetCursorEvent.html>`_
##  - `wStatusBarEvent <wStatusBarEvent.html>`_
##  - `wCommandEvent <wCommandEvent.html>`_
##  - `wScrollEvent <wScrollEvent.html>`_
##  - `wSpinEvent <wSpinEvent.html>`_
##  - `wHyperLinkEvent <wHyperLinkEvent.html>`_
##  - `wListEvent <wListEvent.html>`_
##  - `wTreeEvent <wTreeEvent.html>`_
##
##  Constants
##  ---------
##  - `wKeyCodes <wKeyCodes.html>`_
##  - `wColors <wColors.html>`_


{.experimental, deadCodeElim: on, this: self.}

# import winim.lean, winim.inc/[commctrl, objbase, shellapi, richedit, gdiplus]
# export lean
when not defined(wnimdoc):
  import tables, lists, math, strutils, dynlib, hashes, macros, times, sets, ospaths
  import kiwi
  import winim/winstr, winim/utils
  import winim/inc/[windef, winerror, winbase, winuser, wingdi]
  import winim/inc/[commctrl, commdlg, objbase, richedit, shellapi, gdiplus]
  export winstr, utils, windef, winerror, winbase, winuser, wingdi, kiwi

  include wNim/private/wMacro
  include wNim/private/wTypes
  include wNim/private/consts/wKeyCodes
  include wNim/private/consts/wColors
  include wNim/private/wHelper
  include wNim/private/wAcceleratorTable
  include wNim/private/wApp
  include wNim/private/wUtils
  include wNim/private/events/wEvent
  include wNim/private/events/wMouseEvent
  include wNim/private/events/wKeyEvent
  include wNim/private/events/wSizeEvent
  include wNim/private/events/wMoveEvent
  include wNim/private/events/wContextMenuEvent
  include wNim/private/events/wScrollWinEvent
  include wNim/private/events/wTrayEvent
  include wNim/private/events/wNavigationEvent
  include wNim/private/events/wSetCursorEvent
  include wNim/private/events/wStatusBarEvent
  include wNim/private/events/wCommandEvent
  include wNim/private/events/wScrollEvent
  include wNim/private/events/wSpinEvent
  include wNim/private/events/wHyperLinkEvent
  include wNim/private/events/wListEvent
  include wNim/private/events/wTreeEvent
  include wNim/private/wImage
  include wNim/private/gdiobjects/wGDIObject
  include wNim/private/gdiobjects/wFont
  include wNim/private/gdiobjects/wPen
  include wNim/private/gdiobjects/wBrush
  include wNim/private/gdiobjects/wBitmap
  include wNim/private/gdiobjects/wIcon
  include wNim/private/gdiobjects/wCursor
  include wNim/private/gdiobjects/wPredefined
  include wNim/private/wImageList
  include wNim/private/wResizer
  include wNim/private/wResizable
  include wNim/private/wWindow
  include wNim/private/wPanel
  include wNim/private/dc/wDC
  include wNim/private/dc/wMemoryDC
  include wNim/private/dc/wClientDC
  include wNim/private/dc/wWindowDC
  include wNim/private/dc/wScreenDC
  include wNim/private/dc/wPaintDC
  include wNim/private/menu/wMenuBar
  include wNim/private/menu/wMenu
  include wNim/private/menu/wMenuItem
  include wNim/private/menu/wMenuBase
  include wNim/private/controls/wControl
  include wNim/private/controls/wStatusBar
  include wNim/private/controls/wToolBar
  include wNim/private/controls/wButton
  include wNim/private/controls/wCheckBox
  include wNim/private/controls/wRadioButton
  include wNim/private/controls/wStaticBox
  include wNim/private/controls/wTextCtrl
  include wNim/private/controls/wComboBox
  include wNim/private/controls/wStaticText
  include wNim/private/controls/wStaticBitmap
  include wNim/private/controls/wStaticLine
  include wNim/private/controls/wNoteBook
  include wNim/private/controls/wSpinCtrl
  include wNim/private/controls/wSpinButton
  include wNim/private/controls/wSlider
  include wNim/private/controls/wScrollBar
  include wNim/private/controls/wGauge
  include wNim/private/controls/wCalendarCtrl
  include wNim/private/controls/wDatePickerCtrl
  include wNim/private/controls/wTimePickerCtrl
  include wNim/private/controls/wListBox
  include wNim/private/controls/wListCtrl
  include wNim/private/controls/wTreeCtrl
  include wNim/private/controls/wHyperlinkCtrl
  include wNim/private/controls/wSplitter
  include wNim/private/wFrame
  include wNim/private/dialogs/wMessageDialog
  include wNim/private/dialogs/wDirDialog
  include wNim/private/dialogs/wFileDialog
  include wNim/private/dialogs/wColorDialog
