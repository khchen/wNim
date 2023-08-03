#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## Basic types definition for wNim. Symbols in this module will automatically
## export by wApp, so the user should not import this module directly.
## Sometimes the nim compiler cannot distinguish wNim types from module
## names. In that case, you need to specify the type name from wApp.
## For example: *wApp.wIcon*.

include pragma
import std/[exitprocs, times, tables, sets, lists, hashes, sequtils]
import winim/[winstr, utils], winim/inc/[windef, winbase], winimx, kiwi/kiwi

when defined(wNimDebug):
  import strformat

when not declared(IndexDefect):
  type
    IndexDefect* = object of IndexError

when compiles(block:
    type O = object
    proc `=destroy`(self: O) = discard
  ):
  const newDestructors = true
else:
  const newDestructors = false

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

  wError* = object of CatchableError
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

# Mutually recursive types are only possible within a single type section.
# So we collect all type definition in this module.
type
  wEventProc* = proc (event: wEvent)
    ## Event handler with event object as parameter.

  wEventNeatProc* = proc ()
    ## Event handler without parameter.

  wHookProc* = proc (self: wWindow, msg: UINT, wParam: WPARAM, lParam: LPARAM): bool
    ## Used internally.

  wMessageLoopHookProc* = proc (msg: var wMsg, modalHwnd: HWND): int
    ## Hook procedure to the message loop. *modalHwnd* is not 0 if it is a modal
    ## window message loop instead of main loop. Returns > 0 to continue(skip) the loop,
    ## and returns < 0 to break(exit) the loop.

  wMsg* = MSG
    ## Binary compatibility with Win32 MSG structure.

  wApp* = ref object of RootObj
    mInstance*: HANDLE
    mClassAtomTable*: Table[string, ATOM]
    mTopLevelWindowTable*: Table[HWND, wWindow]
    mWindowTable*: Table[HWND, wWindow]
    mMenuBaseTable*: Table[HMENU, pointer]
    mGDIStockSeq*: seq[wGdiObject]
    mMenuIdSet*: set[uint16]
    mMessageCountTable*: Table[UINT, int]
    mMessageLoopHookProcs*: seq[wMessageLoopHookProc]
    mWaitMessage*: bool
    mExitCode*: uint
    mAccelExists*: bool
    mDpi*: int
    mWinVersion*: float
    mUsingTheme*: bool

  wEventBase* = ref object of RootObj

  wEvent* = ref object of wEventBase
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

  wTextLinkEvent* = ref object of wCommandEvent
    mStart*: int
    mEnd*: int
    mMouseEvent*: UINT

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
    mClassName*: string
    mRegistered*: bool
    mSystemConnectionTable*: Table[UINT, DoublyLinkedList[wEventConnection]]
    mConnectionTable*: Table[UINT, DoublyLinkedList[wEventConnection]]
    mMargin*: wDirection
    mStatusBar*: wStatusBar
    mToolBars*: seq[wToolBar]
    mRebar*: wRebar
    mFont*: wFont
    mBackgroundColor*: wColor
    mForegroundColor*: wColor
    mBackgroundBrush*: wBrush
    mCursor*: wCursor
    mOverrideCursor*: wCursor
    mAcceleratorTable*: wAcceleratorTable
    mPopupMenu*: wMenu
    mSaveFocusHwnd*: HWND
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
    mDisableMinMax*: bool
    mDisableDrag*: bool

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

  wEnumString* = object
    lpVtbl*: ptr IEnumStringVtbl
    vtbl*: IEnumStringVtbl
    window*: wTextCtrl
    provider*: proc (self: wTextCtrl): seq[string]
    list*: seq[string]
    index*: int

  wTextCtrl* = ref object of wControl
    mRich*: bool
    mDisableTextEvent*: bool
    mBestSize*: wSize
    mCommandConn*: wEventConnection
    mPac*: ptr IAutoComplete
    mEnumString*: wEnumString

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

  wMenuBarCtrl* = ref object of wControl
    mMenuBar*: wMenuBar
    mOldWndProc*: WNDPROC
    mOldFocus*: HWND
    mHotItem*: int
    mPressedItem*: int
    mFromKeyboard*: bool
    mContinueHotTrack*: bool
    mRtl*: bool
    mHook*: HHOOK
    mLastPos*: POINT
    mLastItem*: int
    mBlockerStart*: DWORD
    mHelpStatusBar*: wStatusBar
    mHelpDisplayed*: bool

  wMenuBase* = ref object of RootObj
    mHmenu*: HMENU

  wMenu* = ref object of wMenuBase
    mBitmap*: wBitmap
    mItemList*: seq[wMenuItem]
    mDeletable*: bool

  wMenuBar* = ref object of wMenuBase
    mMenuList*: seq[wMenu]

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

  wDC* = object of RootObj
    mHdc*: HDC
    mTextBackgroundColor*: wColor
    mFont*: wFont
    mPen*: wPen
    mBrush*: wBrush
    mRegion*: wRegion
    mScale*: tuple[x, y: float]
    mhOldFont*: HANDLE
    mhOldPen*: HANDLE
    mhOldBrush*: HANDLE
    mhOldBitmap*: HANDLE

  wMemoryDC* = object of wDC
    mBitmap*: wBitmap

  wScreenDC* = object of wDC

  wWindowDC* = object of wDC
    mCanvas*: wWindow

  wClientDC* = object of wDC
    mCanvas*: wWindow

  wPaintDC* = object of wDC
    mPs*: PAINTSTRUCT
    mCanvas*: wWindow

  wPrinterDC* = object of wDC

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
    mPrintData*: wPrintData

  wPrintDialogCallback* = object
    lpVtbl*: ptr IPrintDialogCallbackVtbl
    vtbl*: IPrintDialogCallbackVtbl
    withSite*: IObjectWithSite
    services*: ptr IPrintDialogServices

  wPrintDialog* = ref object of wDialog
    mPd*: TPRINTDLGEX
    mRanges*: array[64, PRINTPAGERANGE]
    mPrintData*: wPrintData
    mCallBack*: wPrintDialogCallback

converter converterIntEnumTowCommandID*(x: int|enum): wCommandID = wCommandID x
  ## We usually use the enum for where need a command ID. see the examples.

when not isMainModule: # hide from doc

  import wMacros

  proc `==`*(x: wCommandID, y: wCommandID): bool {.borrow.}
  proc `$`*(x: wCommandID): string {.borrow.}
  proc hash*(o: ref object): Hash {.inline.} = hash(cast[int](o))

  converter GpImageToGpBitmap(x: ptr GpBitmap): ptr GpImage = cast[ptr GpImage](x)

  proc free[T](self: var T) {.shield.} =
    for field in self.fields:
      when field is ref | pointer | wHookProc | wEventProc | wEventNeatProc:
        field = nil
      elif field is seq:
        field.setLen(0)
      elif field is Table:
        field.clear()
      elif field is object:
        field.free()

  when newDestructors:
    proc `=destroy`(self: type(wMenuItem()[])) {.shield.}
    proc `=destroy`(self: type(wMenu()[])) {.shield.}
  else:
    proc `=destroy`(self: var type(wMenuItem()[])) {.shield.}
    proc `=destroy`(self: var type(wMenu()[])) {.shield.}

  # Basic classes

  when newDestructors:
    proc `=destroy`(self: type(wImage()[])) {.shield.} =
      if self.mGdipBmp != nil:
        GdipDisposeImage(self.mGdipBmp)

  else:
    proc `=destroy`(self: var type(wImage()[])) {.shield.} =
      if self.mGdipBmp != nil:
        GdipDisposeImage(self.mGdipBmp)
        self.mGdipBmp = nil

  when newDestructors:
    proc `=destroy`(self: type(wDataObject()[])) {.shield, raises: [Exception].} =
      if OleIsCurrentClipboard(self.mObj):
        OleFlushClipboard()
      if self.mReleasable and self.mObj != nil:
        self.mObj.Release()

  else:
    proc `=destroy`(self: var type(wDataObject()[])) {.shield, raises: [Exception].} =
      if OleIsCurrentClipboard(self.mObj):
        OleFlushClipboard()
      if self.mReleasable and self.mObj != nil:
        self.mObj.Release()
      self.mObj = nil

  when newDestructors:
    proc `=destroy`(self: type(wImageList()[])) {.shield.} =
      if self.mHandle != 0:
        ImageList_Destroy(self.mHandle)

  else:
    proc `=destroy`(self: var type(wImageList()[])) {.shield.} =
      if self.mHandle != 0:
        ImageList_Destroy(self.mHandle)
        self.mHandle = 0

  when newDestructors:
    proc `=destroy`(self: type(wAcceleratorTable()[])) {.shield.} =
      if self.mHandle != 0:
        DestroyAcceleratorTable(self.mHandle)

  else:
    proc `=destroy`(self: var type(wAcceleratorTable()[])) {.shield.} =
      self.mAccels.setLen(0)
      if self.mHandle != 0:
        DestroyAcceleratorTable(self.mHandle)
      self.mHandle = 0

  # wGDIObjects

  when newDestructors:
    proc `=destroy`(self: type(wGdiObject()[])) {.shield.} =
      if self.mHandle != 0 and self.mDeletable:
        DeleteObject(self.mHandle)

  else:
    proc `=destroy`(self: var type(wGdiObject()[])) {.shield.} =
      if self.mHandle != 0 and self.mDeletable:
        DeleteObject(self.mHandle)
      self.mHandle = 0

  when newDestructors:
    proc `=destroy`(self: type(wIcon()[])) {.shield.} =
      if self.mHandle != 0 and self.mDeletable:
        DestroyIcon(self.mHandle)

  else:
    proc `=destroy`(self: var type(wIcon()[])) {.shield.} =
      if self.mHandle != 0 and self.mDeletable:
        DestroyIcon(self.mHandle)
      self.mHandle = 0

  when newDestructors:
    proc `=destroy`(self: type(wCursor()[])) {.shield.} =
      if self.mHandle != 0 and self.mDeletable:
        if self.mIconResource:
          DestroyIcon(self.mHandle)
        else:
          DestroyCursor(self.mHandle)

  else:
    proc `=destroy`(self: var type(wCursor()[])) {.shield.} =
      if self.mHandle != 0 and self.mDeletable:
        if self.mIconResource:
          DestroyIcon(self.mHandle)
        else:
          DestroyCursor(self.mHandle)
      self.mHandle = 0

  # wBaseApp

  var wBaseApp* {.threadvar.}: wApp

  proc wNimAtExit() {.noconv.} =
    if wBaseApp != nil:
      for hwnd in toSeq(wBaseApp.mWindowTable.keys):
        DestroyWindow(hwnd)

      free(wBaseApp[])

  addExitProc(wNimAtExit)

  # wMenu

  when newDestructors:
    proc `=destroy`(self: type(wMenuItem()[])) {.shield.} =
      if wBaseApp != nil:
        wBaseApp.mMenuIdSet.excl(uint16 self.mId)

  else:
    proc `=destroy`(self: var type(wMenuItem()[])) {.shield.} =
      if wBaseApp != nil:
        wBaseApp.mMenuIdSet.excl(uint16 self.mId)
      free(self)

  when newDestructors:
    proc `=destroy`(self: type(wMenu()[])) {.shield.} =
      when defined(wNimDebug): echo fmt"Destroying wMenu({self.mHmenu}[{self.mItemList.len}])"
      if self.mHmenu != 0:
        if self.mDeletable:
          for i in 0..<GetMenuItemCount(self.mHmenu):
            RemoveMenu(self.mHmenu, 0, MF_BYPOSITION)
          DestroyMenu(self.mHmenu)
        wBaseApp.mMenuBaseTable.del(self.mHmenu)

  else:
    proc `=destroy`(self: var type(wMenu()[])) {.shield.} =
      when defined(wNimDebug): echo fmt"Destroying wMenu({self.mHmenu}[{self.mItemList.len}])"
      if self.mHmenu != 0:
        if self.mDeletable:
          for i in 0..<GetMenuItemCount(self.mHmenu):
            RemoveMenu(self.mHmenu, 0, MF_BYPOSITION)
          DestroyMenu(self.mHmenu)
        wBaseApp.mMenuBaseTable.del(self.mHmenu)
        self.mHmenu = 0
        free(self)

  when newDestructors:
    proc `=destroy`(self: type(wMenuBar()[])) {.shield.} =
      when defined(wNimDebug): echo fmt"Destroying wMenuBar({self.mHmenu}[{self.mMenuList.len}])"
      if self.mHmenu != 0:
        for i in 0..<GetMenuItemCount(self.mHmenu):
          RemoveMenu(self.mHmenu, 0, MF_BYPOSITION)
        DestroyMenu(self.mHmenu)
        wBaseApp.mMenuBaseTable.del(self.mHmenu)

  else:
    proc `=destroy`(self: var type(wMenuBar()[])) {.shield.} =
      when defined(wNimDebug): echo fmt"Destroying wMenuBar({self.mHmenu}[{self.mMenuList.len}])"
      if self.mHmenu != 0:
        for i in 0..<GetMenuItemCount(self.mHmenu):
          RemoveMenu(self.mHmenu, 0, MF_BYPOSITION)
        DestroyMenu(self.mHmenu)
        wBaseApp.mMenuBaseTable.del(self.mHmenu)
        self.mHmenu = 0
        free(self)

  # wDialog

  when newDestructors:
    proc `=destroy`(self: type(wPageSetupDialog()[])) {.shield.} =
      if self.mPsd.hDevMode != 0:
        GlobalFree(self.mPsd.hDevMode)

      if self.mPsd.hDevNames != 0:
        GlobalFree(self.mPsd.hDevNames)

  else:
    proc `=destroy`(self: var type(wPageSetupDialog()[])) {.shield.} =
      if self.mPsd.hDevMode != 0:
        GlobalFree(self.mPsd.hDevMode)
        self.mPsd.hDevMode = 0

      if self.mPsd.hDevNames != 0:
        GlobalFree(self.mPsd.hDevNames)
        self.mPsd.hDevNames = 0

      free(self)

  when newDestructors:
    proc `=destroy`(self: type(wPrintDialog()[])) {.shield.} =
      if self.mPd.hDevMode != 0:
        GlobalFree(self.mPd.hDevMode)

      if self.mPd.hDevNames != 0:
        GlobalFree(self.mPd.hDevNames)

  else:
    proc `=destroy`(self: var type(wPrintDialog()[])) {.shield.} =
      if self.mPd.hDevMode != 0:
        GlobalFree(self.mPd.hDevMode)
        self.mPd.hDevMode = 0

      if self.mPd.hDevNames != 0:
        GlobalFree(self.mPd.hDevNames)
        self.mPd.hDevNames = 0

      free(self)

  # wDC

  when newDestructors:
    proc `=destroy`(self: wDC) {.shield.} =
      if self.mhOldFont != 0:
        SelectObject(self.mHdc, self.mhOldFont)

      if self.mhOldPen != 0:
        SelectObject(self.mHdc, self.mhOldPen)

      if self.mhOldBrush != 0:
        SelectObject(self.mHdc, self.mhOldBrush)

      if self.mhOldBitmap != 0:
        SelectObject(self.mHdc, self.mhOldBitmap)

  else:
    proc `=destroy`(self: var wDC) {.shield.} =
      if self.mhOldFont != 0:
        SelectObject(self.mHdc, self.mhOldFont)
        self.mhOldFont = 0

      if self.mhOldPen != 0:
        SelectObject(self.mHdc, self.mhOldPen)
        self.mhOldPen = 0

      if self.mhOldBrush != 0:
        SelectObject(self.mHdc, self.mhOldBrush)
        self.mhOldBrush = 0

      if self.mhOldBitmap != 0:
        SelectObject(self.mHdc, self.mhOldBitmap)
        self.mhOldBitmap = 0

      free(self)

  when newDestructors:
    proc `=destroy`(self: wMemoryDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        DeleteDC(self.mHdc)
  else:
    proc `=destroy`(self: var wMemoryDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        DeleteDC(self.mHdc)
        self.mBitmap = nil
        self.mHdc = 0

  when newDestructors:
    proc `=destroy`(self: wScreenDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        ReleaseDC(0, self.mHdc)
  else:
    proc `=destroy`(self: var wScreenDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        ReleaseDC(0, self.mHdc)
        self.mHdc = 0

  when newDestructors:
    proc `=destroy`(self: wWindowDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        if not self.mCanvas.isNil:
          ReleaseDC(self.mCanvas.mHwnd, self.mHdc)

  else:
    proc `=destroy`(self: var wWindowDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        if not self.mCanvas.isNil:
          ReleaseDC(self.mCanvas.mHwnd, self.mHdc)
          self.mCanvas = nil
        self.mHdc = 0

  when newDestructors:
    proc `=destroy`(self: wClientDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        if not self.mCanvas.isNil:
          ReleaseDC(self.mCanvas.mHwnd, self.mHdc)

  else:
    proc `=destroy`(self: var wClientDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        if not self.mCanvas.isNil:
          ReleaseDC(self.mCanvas.mHwnd, self.mHdc)
          self.mCanvas = nil
        self.mHdc = 0

  when newDestructors:
    proc `=destroy`(self: wPaintDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        if not self.mCanvas.isNil:
          EndPaint(self.mCanvas.mHwnd, addr self.mPs)

  else:
    proc `=destroy`(self: var wPaintDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        if not self.mCanvas.isNil:
          EndPaint(self.mCanvas.mHwnd, self.mPs)
          self.mCanvas = nil
        self.mHdc = 0

  when newDestructors:
    proc `=destroy`(self: wPrinterDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        DeleteDC(self.mHdc)

  else:
    proc `=destroy`(self: var wPrinterDC) {.shield.} =
      if self.mHdc != 0:
        `=destroy`(wDC(self))
        DeleteDC(self.mHdc)
        self.mHdc = 0

  when defined(wNimDebug) and defined(gcDestructors):

    when newDestructors:
      proc `=destroy`(self: type(wButton()[])) {.shield.} =
        echo fmt"Destroying wButton({self.mHwnd})"
        for i in self.fields: i.reset()

      proc `=destroy`(self: type(wPanel()[])) {.shield.} =
        echo fmt"Destroying wPanel({self.mHwnd})"
        for i in self.fields: i.reset()

      proc `=destroy`(self: type(wFrame()[])) {.shield.} =
        echo fmt"Destroying wFrame({self.mHwnd})"
        for i in self.fields: i.reset()

    else:
      proc `=destroy`(self: var type(wButton()[])) {.shield.} =
        echo fmt"Destroying wButton({self.mHwnd})"
        for i in self.fields: i.reset()

      proc `=destroy`(self: var type(wPanel()[])) {.shield.} =
        echo fmt"Destroying wPanel({self.mHwnd})"
        for i in self.fields: i.reset()

      proc `=destroy`(self: var type(wFrame()[])) {.shield.} =
        echo fmt"Destroying wFrame({self.mHwnd})"
        for i in self.fields: i.reset()
