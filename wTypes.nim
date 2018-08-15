## Basic types definition for wNim.

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

const
  wDefault* = int32.low.int
    ## Used in wNim as default value.
  wDefaultFloat* = NaN
    ## Used in wNim as default float value.
  wDefaultColor: wColor = 0xFFFFFFFF'i32
    ## Used in wNim as default color.
  wDefaultPoint*: wPoint = (wDefault, wDefault)
    ## Used in wNim as default point.
  wDefaultPosition*: wPoint = (wDefault, wDefault)
    ## Used in wNim as default position.
  wDefaultSize*: wSize = (wDefault, wDefault)
    ## Used in wNim as default size.
  wDefaultRect*: wRect = (wDefault, wDefault, wDefault, wDefault)
    ## Used in wNim as default rect.
  wDefaultTime*: wTime = wTime int64.low
    ## Used in wNim as default time.
  wDefaultID*: wCommandID = wCommandID(-1)
    ## Used in wNim as default command ID.

converter converterIntEnumTowCommandID*(x: int|enum): wCommandID = wCommandID x
  ## We usually use the enum for where need a command ID. see the examples.

type
  wPredefinedID* = enum
    ## Predefined names to use as menus or controls ID.
    wID_LOWEST = 4999, wID_OPEN, wID_CLOSE, wID_NEW, wID_SAVE, wID_SAVEAS, wID_REVERT, wID_EXIT, wID_UNDO,
      wID_REDO, wID_HELP, wID_PRINT, wID_PRINT_SETUP, wID_PREVIEW, wID_ABOUT, wID_HELP_CONTENTS, wID_HELP_COMMANDS
      wID_HELP_PROCEDURES, wID_HELP_CONTEXT, wID_CLOSE_ALL, wID_DELETE, wID_PROPERTIES, wID_REPLACE

    wID_CUT = 5030, wID_COPY, wID_PASTE, wID_CLEAR, wID_FIND, wID_DUPLICATE, wID_SELECTALL
    wID_FILE1 = 5050, wID_FILE2, wID_FILE3, wID_FILE4, wID_FILE5, wID_FILE6, wID_FILE7, wID_FILE8, wID_FILE9
    wID_OK = 5100, wID_CANCEL, wID_APPLY, wID_YES, wID_NO, wID_STATIC, wID_FORWARD, wID_BACKWARD, wID_DEFAULT
      wID_MORE, wID_SETUP, wID_RESET, wID_CONTEXT_HELP, wID_YESTOALL, wID_NOTOALL, wID_ABORT, wID_RETRY, wID_IGNORE

    wID_SYSTEM_MENU = 5200, wID_CLOSE_FRAME, wID_MOVE_FRAME, wID_RESIZE_FRAME, wID_MAXIMIZE_FRAME, wID_ICONIZE_FRAME, wID_RESTORE_FRAME
    wID_FILEDLGG = 5900
    wID_HIGHEST = 5999
    wID_USER

  wUSE_KEY = enum
    wUSE_NIL
    wUSE_TAB
    wUSE_SHIFT_TAB
    wUSE_CTRL_TAB
    wUSE_ENTER
    wUSE_LEFT
    wUSE_RIGHT
    wUSE_UP
    wUSE_DOWN

when not defined(wnimdoc):
  # Mutually recursive types are only possible within a single type section.
  # So we collect all type definition in this module.
  type
    wEventHandler = proc (event: wEvent)
    wEventNeatHandler = proc ()

    wApp* = ref object of RootObj
      mInstance: HANDLE
      mTopLevelWindowList: seq[wWindow]
      mWindowTable: Table[HWND, wWindow]
      mGDIStockSeq: seq[wGdiObject]
      mPropagationSet: HashSet[UINT]
      mMessageCountTable: CountTable[UINT]
      mExitCode: uint

    wEvent* = ref object of RootObj
      mWindow: wWindow
      mOrigin: HWND
      mMsg: UINT
      mId: wCommandID
      mWparam: WPARAM
      mLparam: LPARAM
      mUserData: int
      mSkip: bool
      mPropagationLevel: int
      mResult: LRESULT
      mKeyStatus: array[256, int8] # use int8 so that we can test if it < 0
      mMousePos: wPoint
      mClientPos: wPoint

    wMouseEvent* = ref object of wEvent
    wKeyEvent* = ref object of wEvent
    wSizeEvent* = ref object of wEvent
    wMoveEvent* = ref object of wEvent
    wScrollWinEvent* = ref object of wEvent
    wOtherEvent* = ref object of wEvent
    wContextMenuEvent* = ref object of wEvent
    wCommandEvent* = ref object of wEvent
    wNavigationEvent* = ref object of wEvent
    wStatusBarEvent* = ref object of wCommandEvent
    wListEvent* = ref object of wCommandEvent
    wTreeEvent* = ref object of wCommandEvent
    wScrollEvent* = ref object of wCommandEvent
    wSpinEvent* = ref object of wCommandEvent
    wHyperLinkEvent* = ref object of wCommandEvent

    wScrollData = object
      kind: int
      orientation: int

    wView* = ref object of RootObj
      mLeft: Variable
      mRight: Variable
      mTop: Variable
      mBottom: Variable

    wViewSolver* = ref object of RootObj
      mSolver: Solver
      mViews: HashSet[wView]

    wEventConnection = tuple
      id: wCommandID
      handler: wEventHandler
      neatHandler: wEventNeatHandler
      userData: int
      undeletable: bool

    wWindow* = ref object of wView
      mHwnd: HWND
      mParent: wWindow
      mChildren: seq[wWindow]
      mMarginX: int
      mMarginY: int
      mStatusBar: wStatusBar
      mToolBar: wToolBar
      mFont: wFont
      mBackgroundColor: wColor
      mForegroundColor: wColor
      mBackgroundBrush: wBrush
      mSubclassedOldProc: WNDPROC
      mConnectionTable: Table[UINT, seq[wEventConnection]]
      mSystemConnectionTable: Table[UINT, seq[wEventConnection]]
      mSaveFocus: wWindow
      mFocusable: bool
      mMaxSize: wSize
      mMinSize: wSize
      mDummyParent: HWND
      mMouseInWindow: bool
      # acceleratorTable =

    wFrame* = ref object of wWindow
      mMenuBar: wMenuBar
      mIcon: wIcon
      mDisableList: seq[wWindow]

    wPanel* = ref object of wWindow

    wControl* = ref object of wWindow

    wStatusBar* = ref object of wControl
      mFiledNumbers: int
      mWidths: array[256, int32]

    wToolBarTool* = ref object of RootObj
      mBitmap: wBitmap
      mShortHelp: string
      mLongHelp: string
      mMenu: wMenu

    wToolBar* = ref object of wControl
      mTools: seq[wToolBarTool]

    wButton* = ref object of wControl
      mImgData: BUTTON_IMAGELIST
      mDefault: bool
      mMenu: wMenu

    wStaticText* = ref object of wControl

    wStaticBitmap* = ref object of wControl
      mBitmap: wBitmap

    wStaticLine* = ref object of wControl

    wCheckBox* = ref object of wControl

    wRadioButton* = ref object of wControl

    wStaticBox* = ref object of wControl

    wComboBox* = ref object of wControl
      mEdit: wTextCtrl
      mList: wWindow
      mOldEditProc: WNDPROC
      mInitData: ptr UncheckedArray[string]
      mInitCount: int

    wTextCtrl* = ref object of wControl
      mRich: bool
      mDisableTextEvent: bool
      mBestSize: wSize

    wNoteBook* = ref object of wControl
      mSelection: int
      mPages: seq[wWindow]

    wSpinCtrl* = ref object of wControl
      mUpdownHwnd: HWND
      mUpdownWidth: int

    wSpinButton* = ref object of wControl

    wSlider* = ref object of wControl
      mReversed: bool
      mMax: int
      mMin: int
      mDragging: bool

    wScrollBar* = ref object of wControl
      mPageSize: int
      mRange: int

    wGauge* = ref object of wControl
      mTaskBar: ptr ITaskbarList3

    wCalendarCtrl* = ref object of wControl

    wDatePickerCtrl* = ref object of wControl

    wTimePickerCtrl* = ref object of wDatePickerCtrl

    wListBox* = ref object of wControl
      mInitData: ptr UncheckedArray[string]
      mInitCount: int

    wListCtrl* = ref object of wControl
      mColCount: int
      mImageListNormal: wImageList
      mImageListSmall: wImageList
      mImageListState: wImageList
      mOwnsImageListNormal: bool
      mOwnsImageListSmall: bool
      mOwnsImageListState: bool
      mAlternateRowColor: wColor
      mTextCtrl: wTextCtrl

    wTreeItem* = ref object of RootObj
      mHandle: HTREEITEM
      mTreeCtrl: wTreeCtrl

    wTreeItemId* = wTreeItem

    wTreeCtrl* = ref object of wControl
      mImageListNormal: wImageList
      mImageListState: wImageList
      mOwnsImageListNormal: bool
      mOwnsImageListState: bool

    wHyperLinkCtrl* = ref object of wControl

    # wToolTip* = ref wToolTipObj
    # wToolTipObj = object of wControlObj

    wMenuBase* = ref object of RootObj
      mHmenu: HMENU

    wMenu* = ref object of wMenuBase
      mBitmap: wBitmap
      mItemList: seq[wMenuItem]
      mParentMenuCountTable: CountTable[wMenuBase]

    wMenuBar* = ref object of wMenuBase
      mMenuList: seq[wMenu]
      mParentFrameSet: HashSet[wFrame]

    wMenuItem* = ref object of RootObj
      mId: wCommandID
      mKind: int
      mText: string
      mHelp: string
      mBitmap: wBitmap
      mSubmenu: wMenu
      mParentMenu: wMenu

    wImage* = ref object of RootObj
      mGdipBmp: ptr GpBitmap

    wImageList* = ref object of RootObj
      mHandle: HIMAGELIST

    wGdiObject* = ref object of RootObj
      mHandle: HANDLE

    wFont* = ref object of wGdiObject
      mPointSize: float
      mFamily: int
      mWeight: int
      mItalic: bool
      mUnderline: bool
      mFaceName: string
      mEncoding: int

    wPen* = ref object of wGdiObject
      mColor: wColor
      mStyle: DWORD
      mWidth: int

    wBrush* = ref object of wGdiObject
      mColor: wColor
      mStyle: DWORD

    wBitmap* = ref object of wGdiObject
      mWidth: int
      mHeight: int
      mDepth: int

    wIcon* = ref object of wGdiObject
      mWidth: int
      mHeight: int

    wCursor* = ref object of wGdiObject

    # device context type is "object" not "ref object"
    wDC* = object of RootObj
      mHdc: HDC
      mTextBackgroundColor: wColor
      mTextForegroundColor: wColor
      mFont: wFont
      mPen: wPen
      mBrush: wBrush
      mBackground: wBrush
      mBitmap: wBitmap
      mScale: tuple[x, y: float]
      mCanvas: wWindow
      mhOldFont: HANDLE
      mhOldPen: HANDLE
      mhOldBrush: HANDLE
      mhOldBitmap: HANDLE

    wMemoryDC* = object of wDC

    wWindowDC* = object of wDC

    wScreenDC* = object of wDC

    wClientDC* = object of wDC

    wPaintDC* = object of wDC
      mPs: PAINTSTRUCT

    wMessageDialog* = object of RootObj
      mParent: wWindow
      mMessage: string
      mCaption: string
      mStyle: int64

    wFileDialog* = object of RootObj
    wDirDialog* = object of RootObj
    wColorDialog* = object of RootObj

  proc `==`*(x: wCommandID, y: wCommandID): bool {.borrow.}
  proc `$`*(x: wCommandID): string {.borrow.}
  proc hash*(o: ref object): Hash {.inline.} = hash(cast[int](o))

