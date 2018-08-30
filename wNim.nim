{.experimental, deadCodeElim: on, this: self.}

import tables, lists, math, strutils, dynlib, hashes, macros, times, sets, ospaths, kiwi
import winim/winstr, winim/utils
import winim/inc/[windef, winerror, winbase, winuser, wingdi]
import winim/inc/[commctrl, commdlg, objbase, richedit, shellapi, gdiplus]
export winstr, utils, windef, winerror, winbase, winuser, wingdi, kiwi
# import winim.lean, winim.inc/[commctrl, objbase, shellapi, richedit, gdiplus]
# export lean

include private/wMacro
include private/wTypes
include private/consts/wKeyCodes
include private/consts/wColors
include private/wHelper
include private/wAcceleratorTable
include private/wApp
include private/wUtils
include private/events/wEvent
include private/events/wMouseEvent
include private/events/wKeyEvent
include private/events/wSizeEvent
include private/events/wMoveEvent
include private/events/wContextMenuEvent
include private/events/wScrollWinEvent
include private/events/wTrayEvent
include private/events/wNavigationEvent
include private/events/wSetCursorEvent
include private/events/wStatusBarEvent
include private/events/wCommandEvent
include private/events/wScrollEvent
include private/events/wSpinEvent
include private/events/wHyperLinkEvent
include private/events/wListEvent
include private/events/wTreeEvent
include private/wImage
include private/gdiobjects/wGDIObject
include private/gdiobjects/wFont
include private/gdiobjects/wPen
include private/gdiobjects/wBrush
include private/gdiobjects/wBitmap
include private/gdiobjects/wIcon
include private/gdiobjects/wCursor
include private/gdiobjects/wPredefined
include private/wImageList
include private/wResizer
include private/wResizable
include private/wWindow
include private/wPanel
include private/dc/wDC
include private/dc/wMemoryDC
include private/dc/wClientDC
include private/dc/wWindowDC
include private/dc/wScreenDC
include private/dc/wPaintDC
include private/menu/wMenuBar
include private/menu/wMenu
include private/menu/wMenuItem
include private/menu/wMenuBase
include private/controls/wControl
include private/controls/wStatusBar
include private/controls/wToolBar
include private/controls/wButton
include private/controls/wCheckBox
include private/controls/wRadioButton
include private/controls/wStaticBox
include private/controls/wTextCtrl
include private/controls/wComboBox
include private/controls/wStaticText
include private/controls/wStaticBitmap
include private/controls/wStaticLine
include private/controls/wNoteBook
include private/controls/wSpinCtrl
include private/controls/wSpinButton
include private/controls/wSlider
include private/controls/wScrollBar
include private/controls/wGauge
include private/controls/wCalendarCtrl
include private/controls/wDatePickerCtrl
include private/controls/wTimePickerCtrl
include private/controls/wListBox
include private/controls/wListCtrl
include private/controls/wTreeCtrl
include private/controls/wHyperlinkCtrl
include private/controls/wSplitter
include private/wFrame
include private/dialogs/wMessageDialog
include private/dialogs/wDirDialog
include private/dialogs/wFileDialog
include private/dialogs/wColorDialog
