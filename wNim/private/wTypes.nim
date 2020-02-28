#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## Basic types definition for wNim. Symbols in this module will automatically
## export by wApp, so the user don't need to import this module in most situation.
## However, sometimes the nim compiler cannot distinguish wNim types from module
## names (generic instantiation, etc). In that case, you can import wTypes and
## specify the type name. For example: wTypes.wIcon.

{.experimental, deadCodeElim: on.}

import times, tables, sets, lists, hashes
import winim/[winstr, utils], winim/inc/windef, winimx, kiwi/kiwi

type
  wSize* = tuple
    ## A data structure contains integer width and height.
    width: int
    height: int

  wPoint* = tuple
    ## A data structure contains integer x and y.
    x: int
    y: int

  wRect* = tuple
    ## A data structure contains x, y, width, and height.
    x: int
    y: int
    width: int
    height: int

  wDirection* = tuple
    ## A data structure contains left, up, right, down.
    left: int
    up: int
    right: int
    down: int

  wError* = object of Exception
    ## Base of exception use in wNim.

  wCommandID* = distinct int
    ## A integer number used in menus or GUI controls as the ID.

  wStyle* = int64
    ## The wNim window style type. It simply combine of windows' style and exstyle.

  wColor* = int32
    ## Representing a combination of Red, Green, and Blue (RGB) intensity values.
    ## Same as windows' COLORREF.

  wTime* = Time
    ## Represents a point in time.

  wWparam* = WPARAM
  wLparam* = LPARAM

const
  wDefault* = int32.low.int
    ## Used in wNim as default value.
  wDefaultFloat* = NaN
    ## Used in wNim as default float value.
  wDefaultColor*: wColor = 0xFFFFFFFF'i32
    ## Used in wNim as default color.
  wDefaultPoint*: wPoint = (wDefault, wDefault)
    ## Used in wNim as default point.
  wDefaultPosition*: wPoint = (wDefault, wDefault)
    ## Used in wNim as default position.
  wDefaultSize*: wSize = (wDefault, wDefault)
    ## Used in wNim as default size.
  wDefaultRect*: wRect = (wDefault, wDefault, wDefault, wDefault)
    ## Used in wNim as default rect.
  wDefaultID*: wCommandID = wCommandID(-1)
    ## Used in wNim as default command ID.
  wDefaultTime*: wTime = initTime(int64.low, 0)
    ## Used in wNim as default time.
  wNotFound* = -1
    ## Used in wNim as default value.

const
  # Direction
  wLeft* = 0x0010
  wRight* = 0x0020
  wUp* = 0x0040
  wDown* = 0x0080
  wTop* = wUp
  wBottom* = wDown
  wNorth* = wUp
  wSouth* = wDown
  wWest* = wLeft
  wEast* = wRight
  wHorizontal* = wLeft or wRight
  wVertical* = wUp or wDown
  wBoth* = wHorizontal or wVertical
  wCenter* = wLeft or wRight
  wMiddle* = wUp or wDown

converter converterIntEnumTowCommandID*(x: int|enum): wCommandID = wCommandID x
  ## We usually use the enum for where need a command ID. see the examples.

# converter IntToCint*(x: int): cint = cint x
# Nim's *int* should convert to Win32's cint automatically.

type
  wId* = enum
    ## Predefined names to use as menus or controls ID.
    wIdAny = -1,
    wIdZero = 0,
    wIdLowest = 4999, wIdOpen, wIdClose, wIdNew, wIdSave, wIdSaveAS, wIdRevert,
      wIdExit, wIdUndo, wIdRedo, wIdHelp, wIdPrint, wIdPrintSetup, wIdPreview,
      wIdAbout, wIdHelpContents, wIdHelpCommands, wIdHelpProcedures, wIdCloseAll,
      wIdDelete, wIdProperties, wIdReplace

    wIdCut = 5030, wIdCopy, wIdPaste, wIdClear, wIdFind, wIdDuplicate,
      wIdSelectAll

    wIdFile1 = 5050, wIdFile2, wIdFile3, wIdFile4, wIdFile5, wIdFile6, wIdFile7,
      wIdFile8, wIdFile9

    wIdOk = 5100, wIdCancel, wIdApply, wIdYes, wIdNo, wIdStatic, wIdForward,
      wIdBackward, wIdDefault, wIdMore, wIdSetup, wIdReset, wIdContextHelp,
      wIdYesToAll, wIdNoToAll, wIdAbort, wIdRetry, wIdIgnore, wIdContinue,
      wIdTryAgain

    wIdSystemMenu = 5200, wIdCloseFrame, wIdMoveFrame, wIdResizeFrame,
      wIdMaximizeFrame, wIdIconizeFrame, wIdRestoreFrame

    wIdHighest = 5999, wIdUser

when not isMainModule:
  # Mutually recursive types are only possible within a single type section.
  # So we collect all type definition in this module.
  type
    wEventProc* = proc (event: wEvent)
    wEventNeatProc* = proc ()
    wHookProc* = proc (self: wWindow, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool

    # 0.4.1
    # wNim use wMenu.mParentMenuCountTable and wMenuItem.mParentMenu to find the
    # parent of menu/menuitem before. However, it seems let the data struct too
    # complicated, so that the GC will crash somehow. I think there is still some
    # bugs in the GC, both refc and markAndSweep. But it is hard to trace and
    # analysis. From now on, wNim use wApp.mMenuBaseTable as a kind of weakrefs
    # to find the parent of menu/menuitem. It is indeed more time consuming,
    # however, what program has ten thousand menus or even more? The most
    # important is, it don't crash the GC.
    wApp* = ref object of RootObj
      mInstance*: HANDLE
      mTopLevelWindowTable*: Table[HWND, wWindow]
      mWindowTable*: Table[HWND, wWindow]
      mMenuBaseTable*: Table[HMENU, pointer]
      mGDIStockSeq*: seq[wGdiObject]
      mPropagationSet*: HashSet[UINT]
      mMenuIdSet*: set[uint16]
      mMessageCountTable*: Table[UINT, int]
      mExitCode*: uint
      mAccelExists*: bool
      mDpi*: int
      mWinVersion*: float
      mUsingTheme*: bool

    wEvent* = ref object of RootObj
      mWindow*: wWindow
      mOrigin*: HWND
      mMsg*: UINT
      mId*: wCommandID
      mWparam*: WPARAM
      mLparam*: LPARAM
      mUserData*: int
      mSkip*: bool
      mPropagationLevel*: int
      mResult*: LRESULT
      mKeyStatus*: array[256, int8] # use int8 so that we can test if it < 0
      mMousePos*: wPoint
      mClientPos*: wPoint

    wMouseEvent* = ref object of wEvent

    wKeyEvent* = ref object of wEvent

    wSizeEvent* = ref object of wEvent

    wMoveEvent* = ref object of wEvent

    wScrollWinEvent* = ref object of wEvent
      mScrollPos*: int

    wOtherEvent* = ref object of wEvent

    wContextMenuEvent* = ref object of wEvent

    wCommandEvent* = ref object of wEvent

    wNavigationEvent* = ref object of wEvent

    wSetCursorEvent* = ref object of wEvent

    wTrayEvent* = ref object of wEvent

    wDragDropEvent* = ref object of wEvent
      mDataObject*: wDataObject
      mEffect*: int

    wDialogEvent* = ref object of wEvent

    wStatusBarEvent* = ref object of wCommandEvent

    wListEvent* = ref object of wCommandEvent
      mIndex*: int
      mCol*: int
      mText*: string

    wTreeEvent* = ref object of wCommandEvent
      mTreeCtrl*: wTreeCtrl
      mHandle*: HTREEITEM
      mOldHandle*: HTREEITEM
      mText*: string
      mInsertMark*: int
      mPoint*: wPoint

    wScrollEvent* = ref object of wCommandEvent
      mScrollPos*: int

    wSpinEvent* = ref object of wCommandEvent

    wHyperlinkEvent* = ref object of wCommandEvent
      mVisited*: bool

    wIpEvent* = ref object of wCommandEvent
      mIndex*: int
      mValue*: int

    wWebViewEvent* = ref object of wCommandEvent
      mDispatch*: ptr IDispatch
      mUrl*: string
      mText*: string

    wScrollData* = object
      kind*: int
      orientation*: int

    wResizable* = ref object of RootObj
      mLeft*: Variable
      mTop*: Variable
      mWidth*: Variable
      mHeight*: Variable

    wResizer* = ref object of RootObj
      mParent*: wResizable
      mSolver*: Solver
      mObjects*: HashSet[wResizable]

    wDataObject* = ref object
      mObj*: ptr IDataObject
      mReleasable*: bool

    wPrintData* = ref object
      mDevice*: string
      mDevModeBuffer*: string

    wEventConnection* = object
      msg*: UINT
      id*: wCommandID
      handler*: wEventProc
      neatHandler*: wEventNeatProc
      userData*: int
      undeletable*: bool

    wAcceleratorTable* = ref object of RootObj
      mHandle*: HACCEL
      mAccels*: seq[ACCEL]
      mModified*: bool

    wSizingInfo = ref object
      border*: wDirection
      dragging*: bool
      ready*: tuple[up, down, left, right: bool]
      offset*: wDirection
      connection*: tuple[move, up, down: wEventConnection]

    wDraggableInfo = ref object
      enable*: bool
      inClient*: bool
      dragging*: bool
      startMousePos*: wPoint
      startPos*: wPoint
      connection*: tuple[move, down, up: wEventConnection]

    wDropTarget* = object
      lpVtbl*: ptr IDropTargetVtbl
      vtbl*: IDropTargetVtbl
      self*: wWindow
      effect*: DWORD

    wWindow* = ref object of wResizable
      mHwnd*: HWND
      mParent*: wWindow
      mChildren*: seq[wWindow]
      mData*: int
      mSystemConnectionTable*: Table[UINT, DoublyLinkedList[wEventConnection]]
      mConnectionTable*: Table[UINT, DoublyLinkedList[wEventConnection]]
      mMargin*: wDirection
      mStatusBar*: wStatusBar
      mToolBar*: wToolBar
      mRebar*: wRebar
      mFont*: wFont
      mBackgroundColor*: wColor
      mForegroundColor*: wColor
      mBackgroundBrush*: wBrush
      mCursor*: wCursor
      mOverrideCursor*: wCursor
      mAcceleratorTable*: wAcceleratorTable
      mSaveFocus*: wWindow
      mFocusable*: bool
      mMouseInWindow*: bool
      mMaxSize*: wSize
      mMinSize*: wSize
      mDummyParent*: HWND
      mTipHwnd*: HWND
      mSizingInfo*: wSizingInfo
      mDraggableInfo*: wDraggableInfo
      mDropTarget*: ref wDropTarget
      mHookProc*: wHookProc

    wFrame* = ref object of wWindow
      mMenuBar*: wMenuBar
      mIcon*: wIcon
      mDisableList*: seq[HWND]
      mTrayIcon*: wIcon
      mTrayToolTip*: string
      mTrayIconAdded*: bool
      mTrayConn*: wEventConnection
      mCreateConn*: wEventConnection
      mRetCode*: int
      mIsModal*: bool

    wPanel* = ref object of wWindow

    wToolTip* = ref object of wWindow
      mText*: string
      mToolInfo*: TOOLINFO

    wControl* = ref object of wWindow

    wStatusBar* = ref object of wControl
      mFiledNumbers*: int
      mWidths*: array[256, int32]
      mHelpIndex*: int
      mSizeConn*: wEventConnection

    wToolBarTool* = ref object of RootObj
      mBitmap*: wBitmap
      mShortHelp*: string
      mLongHelp*: string
      mMenu*: wMenu

    wToolBar* = ref object of wControl
      mTools*: seq[wToolBarTool]
      mSizeConn*: wEventConnection
      mCommandConn*: wEventConnection

    wRebar* = ref object of wControl
      mControls*: seq[wControl]
      mImageList*: wImageList
      mSizeConn*: wEventConnection
      mDragging*: bool

    wButton* = ref object of wControl
      mImgData*: BUTTON_IMAGELIST
      mDefault*: bool
      mMenu*: wMenu
      mCommandConn*: wEventConnection

    wStaticText* = ref object of wControl
      mCommandConn*: wEventConnection

    wStaticBitmap* = ref object of wControl
      mBitmap*: wBitmap
      mCommandConn*: wEventConnection

    wStaticLine* = ref object of wControl

    wIpCtrl* = ref object of wControl
      mEdits*: array[4, wTextCtrl]

    wCheckBox* = ref object of wControl
      mCommandConn*: wEventConnection

    wRadioButton* = ref object of wControl
      mCommandConn*: wEventConnection

    wStaticBox* = ref object of wControl

    wComboBox* = ref object of wControl
      mEdit*: wTextCtrl
      mList*: wListBox
      mOldEditProc*: WNDPROC
      mInitData*: ptr UncheckedArray[string]
      mInitCount*: int
      mCommandConn*: wEventConnection

    wCheckComboBox* = ref object of wControl
      mTheme*: HTHEME
      mCheckTheme*: HTHEME
      mDrawTextFlag*: DWORD
      mComboPart*: DWORD
      mSeparator*: string
      mValue*: string
      mEmpty*: string
      mList*: wListBox
      mIsPopup*: bool
      mInitData*: ptr UncheckedArray[string]
      mInitCount*: int
      mDrawItemConn*: wEventConnection
      mCommandConn*: wEventConnection

    wTextCtrl* = ref object of wControl
      mRich*: bool
      mDisableTextEvent*: bool
      mBestSize*: wSize
      mCommandConn*: wEventConnection

    wNoteBook* = ref object of wControl
      mTheme*: HTHEME
      mImageList*: wImageList
      mSelection*: int
      mPages*: seq[wPanel]

    wSpinCtrl* = ref object of wControl
      mUpdownHwnd*: HWND
      mUpdownWidth*: int
      mCommandConn*: wEventConnection
      mNotifyConn*: wEventConnection

    wSpinButton* = ref object of wControl
      mNotifyConn*: wEventConnection

    wSlider* = ref object of wControl
      mReversed*: bool
      mMax*: int
      mMin*: int
      mDragging*: bool
      mHScrollConn*: wEventConnection
      mVScrollConn*: wEventConnection

    wScrollBar* = ref object of wControl
      mPageSize*: int
      mRange*: int
      mHScrollConn*: wEventConnection
      mVScrollConn*: wEventConnection

    wGauge* = ref object of wControl
      mTaskBar*: ptr ITaskbarList3
      mTaskBarCreatedConn*: wEventConnection

    wCalendarCtrl* = ref object of wControl

    wDatePickerCtrl* = ref object of wControl

    wTimePickerCtrl* = ref object of wDatePickerCtrl

    wListBox* = ref object of wControl
      mInitData*: ptr UncheckedArray[string]
      mInitCount*: int
      mCommandConn*: wEventConnection

    wListCtrl* = ref object of wControl
      mColCount*: int
      mImageListNormal*: wImageList
      mImageListSmall*: wImageList
      mImageListState*: wImageList
      mAlternateRowColor*: wColor
      mTextCtrl*: wTextCtrl
      mDragging*: bool

    wTreeCtrl* = ref object of wControl
      mImageListNormal*: wImageList
      mImageListState*: wImageList
      mOwnsImageListNormal*: bool
      mOwnsImageListState*: bool
      mInSortChildren*: bool
      mDataTable*: Table[HTREEITEM, int]
      mTextCtrl*: wTextCtrl
      mEnableInsertMark*: bool
      mDragging*: bool
      mCurrentDraggingItem*: HTREEITEM
      mCurrentInsertMark*: int
      mCurrentInsertItem*: HTREEITEM

    wTreeItem* = object
      mHandle*: HTREEITEM
      mTreeCtrl*: wTreeCtrl

    wHyperlinkCtrl* = ref object of wControl

    wSplitter* = ref object of wControl
      mIsVertical*: bool
      mIsDrawButton*: bool
      mSize*: int
      mDragging*: bool
      mResizing*: bool
      mPanel1*: wPanel
      mPanel2*: wPanel
      mMin1*: int
      mMin2*: int
      mPosOffset*: wPoint
      mInPanelMargin*: bool
      mSystemConnections*: seq[tuple[win: wWindow, conn: wEventConnection]]
      mConnections*: seq[tuple[win: wWindow, conn: wEventConnection]]
      mSizeConn*: wEventConnection
      mAttach1*: bool
      mAttach2*: bool

    wWebView* = ref object of wControl

    wHotkeyCtrl* = ref object of wControl
      mProcessTab*: bool
      mClearKeyCode*: int
      mHook*: HHOOK
      mCtrl*: bool
      mAlt*: bool
      mShift*: bool
      mWin*: bool
      mValue*: string
      mKeyCode*: int
      mModifiers*: int

    wMenuBase* = ref object of RootObj
      mHmenu*: HMENU

    wMenu* = ref object of wMenuBase
      mBitmap*: wBitmap
      mItemList*: seq[wMenuItem]
      mDeletable*: bool

    wMenuBar* = ref object of wMenuBase
      mMenuList*: seq[wMenu]
      mParentFrameSet*: HashSet[wFrame]

    wMenuItemKind* = enum
      wMenuItemNormal
      wMenuItemSeparator
      wMenuItemCheck
      wMenuItemRadio
      wMenuItemSubMenu

    wMenuItem* = ref object of RootObj
      mId*: wCommandID
      mKind*: wMenuItemKind
      mText*: string
      mHelp*: string
      mBitmap*: wBitmap
      mSubmenu*: wMenu
      mData*: int
      # mParentMenu*: wMenu

    wImage* = ref object of RootObj
      mGdipBmp*: ptr GpBitmap

    wImageList* = ref object of RootObj
      mHandle*: HIMAGELIST

    wIconImage* = ref object of RootObj
      mIcon*: string
      mHotspot*: wPoint

    wGdiObject* = ref object of RootObj
      mHandle*: HANDLE
      mDeletable*: bool

    wFont* = ref object of wGdiObject
      mPointSize*: float
      mFamily*: int
      mWeight*: int
      mItalic*: bool
      mUnderline*: bool
      mStrikeout*: bool
      mFaceName*: string
      mEncoding*: int

    wPen* = ref object of wGdiObject
      mColor*: wColor
      mStyle*: DWORD
      mWidth*: int

    wBrush* = ref object of wGdiObject
      mColor*: wColor
      mStyle*: DWORD

    wBitmap* = ref object of wGdiObject
      mWidth*: int
      mHeight*: int
      mDepth*: int

    wIcon* = ref object of wGdiObject
      mWidth*: int
      mHeight*: int

    wCursor* = ref object of wGdiObject
      mWidth*: int
      mHeight*: int
      mHotspot*: wPoint
      mIconResource*: bool

    wRegion* = ref object of wGdiObject

    # device context type is "object" not "ref object"
    # `=destroy` need the definition in the same module

    # wDC* = object of RootObj
    #   mHdc*: HDC
    #   mTextBackgroundColor*: wColor
    #   mTextForegroundColor*: wColor
    #   mFont*: wFont
    #   mPen*: wPen
    #   mBrush*: wBrush
    #   mBackground*: wBrush
    #   mRegion*: wRegion
    #   mScale*: tuple[x, y: float]
    #   mhOldFont*: HANDLE
    #   mhOldPen*: HANDLE
    #   mhOldBrush*: HANDLE
    #   mhOldBitmap*: HANDLE

    # wMemoryDC* = object of wDC

    # wWindowDC* = object of wDC

    # wScreenDC* = object of wDC

    # wClientDC* = object of wDC

    # wPaintDC* = object of wDC
    #   mPs*: PAINTSTRUCT

    # wPrinterDC* = object of wDC

    wDialog* = ref object of wWindow
      mOwner*: wWindow

    wMessageDialog* = ref object of wDialog
      mHook*: HHOOK
      mMessage*: string
      mCaption*: string
      mStyle*: wStyle
      mLabelText*: Table[INT, string]

    wDirDialog* = ref object of wDialog
      mMessage*: string
      mPath*: string
      mStyle*: wStyle

    wFileDialog* = ref object of wDialog
      mMessage*: string
      mDefaultDir*: string
      mDefaultFile*: string
      mWildcard*: string
      mStyle*: wStyle
      mFilterIndex*: int
      mPath*: string
      mPaths*: seq[string]

    wColorDialog* = ref object of wDialog
      mCc*: TCHOOSECOLOR
      mStyle*: wStyle
      mCustomColor*: array[16, wColor]

    wFontDialog* = ref object of wDialog
      mCf*: TCHOOSEFONT
      mLf*: LOGFONT
      mChosenFont*: wFont

    wTextEntryDialog* = ref object of wDialog
      mFrame*: wFrame
      mMessage*: string
      mCaption*: string
      mValue*: string
      mStyle*: wStyle
      mMaxLength*: int
      mPos*: wPoint
      mOkLabel*: string
      mCancelLabe*: string
      mReturnId*: wId

    wPasswordEntryDialog* = ref object of wTextEntryDialog

    wFindReplaceDialog* = ref object of wDialog
      mFr*: FINDREPLACE
      mFindString*: TString
      mReplaceString*: TString
      mIsReplace*: bool
      mMsgConn*: wEventConnection

    wPageSetupDialog* = ref object of wDialog
      mPsd*: TPAGESETUPDLG

    wPrintDialog* = ref object of wDialog
      mPd*: TPRINTDLGEX
      mRanges*: array[64, PRINTPAGERANGE]
      mPrintData*: wPrintData

  proc `==`*(x: wCommandID, y: wCommandID): bool {.borrow.}
  proc `$`*(x: wCommandID): string {.borrow.}
  proc hash*(o: ref object): Hash {.inline.} = hash(cast[int](o))

else:
  type
    # wEventProc* = proc (event: wEvent)
    # wEventNeatProc* = proc ()
    # wHookProc* = proc (self: wWindow, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool
    wApp* = ref object of RootObj

    wEvent* = ref object of RootObj
    wCommandEvent* = ref object of wEvent
    wContextMenuEvent* = ref object of wEvent
    wDialogEvent* = ref object of wEvent
    wDragDropEvent* = ref object of wEvent
    wHyperlinkEvent* = ref object of wCommandEvent
    wIpEvent* = ref object of wCommandEvent
    wKeyEvent* = ref object of wEvent
    wListEvent* = ref object of wCommandEvent
    wMouseEvent* = ref object of wEvent
    wMoveEvent* = ref object of wEvent
    wNavigationEvent* = ref object of wEvent
    wOtherEvent* = ref object of wEvent
    wScrollEvent* = ref object of wCommandEvent
    wScrollWinEvent* = ref object of wEvent
    wSetCursorEvent* = ref object of wEvent
    wSizeEvent* = ref object of wEvent
    wSpinEvent* = ref object of wCommandEvent
    wStatusBarEvent* = ref object of wCommandEvent
    wTrayEvent* = ref object of wEvent
    wTreeEvent* = ref object of wCommandEvent
    wWebViewEvent* = ref object of wCommandEvent

    wDataObject* = ref object
    wPrintData* = ref object
    wAcceleratorTable* = ref object of RootObj
    wImage* = ref object of RootObj
    wImageList* = ref object of RootObj
    wIconImage* = ref object of RootObj
    # wEventConnection* = object

    wResizable* = ref object of RootObj
    wResizer* = ref object of RootObj
    wWindow* = ref object of wResizable
    wFrame* = ref object of wWindow
    wPanel* = ref object of wWindow

    wControl* = ref object of wWindow
    wButton* = ref object of wControl
    wCalendarCtrl* = ref object of wControl
    wCheckBox* = ref object of wControl
    wCheckComboBox* = ref object of wControl
    wComboBox* = ref object of wControl
    wDatePickerCtrl* = ref object of wControl
    wGauge* = ref object of wControl
    wHotkeyCtrl* = ref object of wControl
    wHyperlinkCtrl* = ref object of wControl
    wIpCtrl* = ref object of wControl
    wListBox* = ref object of wControl
    wListCtrl* = ref object of wControl
    wNoteBook* = ref object of wControl
    wRadioButton* = ref object of wControl
    wRebar* = ref object of wControl
    wScrollBar* = ref object of wControl
    wSlider* = ref object of wControl
    wSpinButton* = ref object of wControl
    wSpinCtrl* = ref object of wControl
    wSplitter* = ref object of wControl
    wStaticBitmap* = ref object of wControl
    wStaticBox* = ref object of wControl
    wStaticLine* = ref object of wControl
    wStaticText* = ref object of wControl
    wStatusBar* = ref object of wControl
    wTextCtrl* = ref object of wControl
    wTimePickerCtrl* = ref object of wDatePickerCtrl
    wToolBar* = ref object of wControl
    wTreeCtrl* = ref object of wControl
    wTreeItem* = object
    wWebView* = ref object of wControl

    wMenuItemKind* = enum
      wMenuItemNormal
      wMenuItemSeparator
      wMenuItemCheck
      wMenuItemRadio
      wMenuItemSubMenu

    wMenuBase* = ref object of RootObj
    wMenu* = ref object of wMenuBase
    wMenuBar* = ref object of wMenuBase
    wMenuItem* = ref object of RootObj

    wGdiObject* = ref object of RootObj
    wBitmap* = ref object of wGdiObject
    wBrush* = ref object of wGdiObject
    wCursor* = ref object of wGdiObject
    wFont* = ref object of wGdiObject
    wIcon* = ref object of wGdiObject
    wPen* = ref object of wGdiObject
    wRegion* = ref object of wGdiObject

    wDialog* = ref object of wWindow
    wColorDialog* = ref object of wDialog
    wDirDialog* = ref object of wDialog
    wFileDialog* = ref object of wDialog
    wFindReplaceDialog* = ref object of wDialog
    wFontDialog* = ref object of wDialog
    wMessageDialog* = ref object of wDialog
    wPageSetupDialog* = ref object of wDialog
    wPrintDialog* = ref object of wDialog
    wTextEntryDialog* = ref object of wDialog
    wPasswordEntryDialog* = ref object of wTextEntryDialog
