## wWindow is the base for all windows and represents any visible object on screen.
##
## :Superclass:
##    wView
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wBorderSimple                   Displays a thin border around the window.
##    wBorderSunken                   Displays a sunken border.
##    wBorderRaised                   Displays a raised border.
##    wBorderStatic                   Displays a border suitable for a static control.
##    wBorderDouble                   Displays a double border.
##    wTransparentWindow              The window is transparent.
##    wVScroll                        Use this style to enable a vertical scrollbar.
##    wHScroll                        Use this style to enable a horizontal scrollbar.
##    wClipChildren                   Use this style to eliminate flicker caused by the background being repainted, then children being painted over them.
##    wHideTaskbar                    Use this style to hide the taskbar item.
##    wPopup                          The windows is a pop-up window (WS_POPUP).
##    wPopupWindow                    The window is a pop-up window (WS_POPUPWINDOW).
##    ==============================  =============================================================

const
  wBorderSimple* = WS_BORDER
  wBorderSunken* = WS_EX_CLIENTEDGE shl 32
  wBorderRaised* = WS_EX_WINDOWEDGE shl 32
  wBorderStatic* = WS_EX_STATICEDGE shl 32
  wBorderDouble* = WS_EX_DLGMODALFRAME shl 32
  wTransparentWindow* = WS_EX_TRANSPARENT shl 32
  wVScroll* = WS_VSCROLL
  wHScroll* = WS_HSCROLL
  wClipChildren* = WS_CLIPCHILDREN
  wHideTaskbar* = 0x10000000 shl 32
  wPopup* = int64 cast[uint32](WS_POPUP) # WS_POPUP is 0x80000000L
  wPopupWindow* = int64 cast[uint32](WS_POPUPWINDOW)

method getWindowRect(self: wWindow, sizeOnly = false): wRect {.base.} =
  var rect: RECT
  GetWindowRect(mHwnd, rect)

  result.width = (rect.right - rect.left)
  result.height = (rect.bottom - rect.top)

  if not sizeOnly:
    if mParent != nil:
      ScreenToClient(mParent.mHwnd, cast[ptr POINT](addr rect))

    result.x = rect.left
    result.y = rect.top

method setWindowRect(self: wWindow, x, y, width, height, flag = 0) {.base, inline.} =
  # must use SWP_NOACTIVATE or window will steal focus after setsize
  SetWindowPos(mHwnd, 0, x, y, width, height, UINT(flag or SWP_NOZORDER or SWP_NOREPOSITION or SWP_NOACTIVATE))

proc setWindowSize(self: wWindow, width, height: int) {.inline.} =
  setWindowRect(0, 0, width, height, SWP_NOMOVE)

proc setWindowPos(self: wWindow, x, y: int) {.inline.} =
  setWindowRect(x, y, 0, 0, SWP_NOSIZE)

method getClientSize*(self: wWindow): wSize {.base, property.} =
  ## Returns the size of the window 'client area' in pixels.
  var r: RECT
  GetClientRect(mHwnd, r)
  result.width = r.right - r.left - mMarginX * 2
  result.height = r.bottom - r.top - mMarginY * 2

  if mToolBar != nil:
    let rect = mToolBar.getWindowRect()
    case toolBarDirection(mToolBar.mHwnd)
    of wTop, wBottom:
      result.height -= rect.height

    of wRight:
      result.width -= rect.width

    of wLeft:
      result.width -= rect.width + rect.x

    else: discard

  if mStatusBar != nil:
    let rect = mStatusBar.getWindowRect(sizeOnly=true)
    result.height -= rect.height

method getClientAreaOrigin*(self: wWindow): wPoint {.base.} =
  ## Get the origin of the client area of the window relative to the window
  ## top left corner (the client area may be shifted because of the borders,
  ## scrollbars, other decorations...)
  result.x = mMarginX
  result.y = mMarginY
  if mToolBar != nil:
    let rect = mToolBar.getWindowRect()
    case toolBarDirection(mToolBar.mHwnd)
    of wTop:
      result.y += rect.height + rect.y
    of wLeft:
      result.x += rect.width + rect.x
    else: discard

proc adjustForParentClientOriginAdd(self: wWindow, x, y: var int) =
  if mParent != nil:
    let point = mParent.getClientAreaOrigin()
    x += point.x
    y += point.y

proc adjustForParentClientOriginSub(self: wWindow, x, y: var int) =
  if mParent != nil:
    let point = mParent.getClientAreaOrigin()
    x -= point.x
    y -= point.y

proc getMarginX*(self: wWindow): int {.validate, property, inline.} =
  ## Get the margin setting of the windows' x-axis.
  ## Margin is the extra space around the client area..
  result = mMarginX

proc getMarginY*(self: wWindow): int {.validate, property, inline.} =
  ## Get the margin setting of the windows' y-axis.
  ## Margin is the extra space around the client area..
  result = mMarginY

proc getMargin*(self: wWindow): (int, int) {.validate, property, inline.} =
  ## Get the margin setting of the window as a tuple.
  ## Margin is the extra space around the client area..
  result = (mMarginX, mMarginY)

proc setMarginX*(self: wWindow, margin: int) {.validate, property, inline.}=
  ## Set the x-axis margin..
  mMarginX = margin

proc setMarginY*(self: wWindow, margin: int) {.validate, property, inline.}=
  ## Set the y-axis margin.
  mMarginY = margin

proc setMargin*(self: wWindow, margin: int) {.validate, property, inline.}=
  ## Set the x-axis and y-axis margin at the same time.
  mMarginX = margin
  mMarginY = margin

proc setMargin*(self: wWindow, margin: (int, int)) {.validate, property, inline.}=
  ## Set the x-axis and y-axis margin at the same time.
  mMarginX = margin[0]
  mMarginY = margin[1]

proc close*(self: wWindow) {.validate, inline.} =
  ## This function simply generates a wEvent_Close whose handler usually tries to close the window.
  SendMessage(mHwnd, WM_CLOSE, 0, 0)

method delete*(self: wWindow) {.base, inline.} =
  ## Destroys the window.
  DestroyWindow(mHwnd)

proc destroy*(self: wWindow) {.validate, inline.} =
  ## Destroys the window. The same as delete.
  delete()

proc move*(self: wWindow, x: int, y: int) {.validate.} =
  ## Moves the window to the given position.
  ## wDefault to indicate not to change.
  var
    xx = x
    yy = y

  adjustForParentClientOriginAdd(xx, yy)

  if x == wDefault or y == wDefault:
    let rect = getWindowRect()
    if x == wDefault: xx = rect.x
    if y == wDefault: yy = rect.y

  setWindowPos(xx, yy)

proc move*(self: wWindow, pos: wPoint) {.validate, inline.} =
  ## Moves the window to the given position.
  ## wDefault to indicate not to change.
  move(self, pos.x, pos.y)

proc setPosition*(self: wWindow, pos: wPoint) {.validate, property, inline.} =
  ## Moves the window to the specified position. The same as move.
  ## wDefault to indicate not to change.
  move(self, pos.x, pos.y)

proc setPosition*(self: wWindow, x: int, y: int) {.validate, property, inline.} =
  ## Moves the window to the specified position. The same as move.
  ## wDefault to indicate not to change.
  move(self, x, y)

proc setSize*(self: wWindow, width: int, height: int) {.validate, property.} =
  ## Sets the size of the window in pixels.
  ## wDefault to indicate not to change.
  var
    ww = width
    hh = height

  if width == wDefault or height == wDefault:
    let rect = getWindowRect()
    if width == wDefault: ww = rect.width
    if height == wDefault: hh = rect.height

  setWindowSize(ww, hh)

proc setSize*(self: wWindow, x: int, y: int, width: int, height: int) {.validate, property.} =
  ## Sets the size of the window in pixels.
  ## wDefault to indicate not to change.
  var
    xx = x
    yy = y
    ww = width
    hh = height

  adjustForParentClientOriginAdd(xx, yy)

  if x == wDefault or y == wDefault or width == wDefault or height == wDefault:
    let rect = getWindowRect()
    if x == wDefault: xx = rect.x
    if y == wDefault: yy = rect.y
    if width == wDefault: ww = rect.width
    if height == wDefault: hh = rect.height

  setWindowRect(xx, yy, ww, hh)

proc setSize*(self: wWindow, size: wSize) {.validate, property, inline.} =
  ## Sets the size of the window in pixels.
  ## wDefault to indicate not to change.
  setSize(self, size.width, size.height)

proc setSize*(self: wWindow, rect: wRect) {.validate, property, inline.} =
  ## Sets the size of the window in pixels.
  ## wDefault to indicate not to change.
  setSize(self, rect.x, rect.y, rect.width, rect.height)

proc getSize*(self: wWindow): wSize {.validate, property, inline.} =
  ## Returns the size of the entire window in pixels.
  let rect = getWindowRect(sizeOnly=true)
  result.width = rect.width
  result.height = rect.height

proc getRect*(self: wWindow): wRect {.validate, property.} =
  ## Returns the position and size of the window as a wRect object.
  result = getWindowRect()
  adjustForParentClientOriginSub(result.x, result.y)

proc getPosition*(self: wWindow): wPoint {.validate, property.} =
  ## Gets the position of the window in pixels.
  let rect = getWindowRect()
  result.x = rect.x
  result.y = rect.y
  adjustForParentClientOriginSub(result.x, result.y)

method getDefaultSize*(self: wWindow): wSize {.base, property, inline.} =
  ## Returns the system suggested size of a window (usually used for GUI controls).
  # window's default size is it's parent's clientSize, or 0, 0 by default
  if mParent != nil:
    result = mParent.getClientSize()

proc getClientMargin*(self: wWindow, direction: int): int {.validate, property.} =
  ## Returns the client margin of the specified direction.
  ## This function basically exists for wNim's layout DSL.
  result = case direction
  of wLeft:
    getClientAreaOrigin().x
  of wTop:
    getClientAreaOrigin().y
  of wRight:
    getSize().width - getClientSize().width - getClientAreaOrigin().x
  of wBottom:
    getSize().height - getClientSize().height - getClientAreaOrigin().y
  else: 0

proc getClientMargins*(self: wWindow): tuple[left, top, right, bottom: int] {.validate, property.} =
  ## Returns client margin of all the direction.
  let pos = getClientAreaOrigin()
  let size = getSize()
  let clientSize = getClientSize()

  result.left = pos.x
  result.top = pos.y
  result.right = size.width - clientSize.width - pos.x
  result.bottom = size.height - clientSize.height - pos.y

proc clientToWindow(self: wWindow, size: wSize): wSize {.validate.} =
  let
    clientSize = getClientSize()
    windowSize = getSize()

  result = size

  if size.width != wDefault:
    result.width += windowSize.width - clientSize.width

  if size.height != wDefault:
    result.height += windowSize.height - clientSize.height

method getBestSize*(self: wWindow): wSize {.base, property.} =
  ## Returns the best acceptable minimal size for the window (usually used for GUI controls).
  if mChildren.len == 0:
    result = getSize()
  else:
    var width, height: int = 0
    for child in mChildren:
      let rect = child.getRect()
      width = max(width, rect.x + rect.width)
      height = max(height, rect.y + rect.height)
    result = clientToWindow((width, height))

proc fit*(self: wWindow) {.validate, inline.} =
  ## Sizes the window to fit its best size.
  setSize(getBestSize())

proc setClientSize*(self: wWindow, size: wSize) {.validate, property.} =
  ## This sets the size of the window client area in pixels.
  for i in 1..4:
    let clientSize = getClientSize()
    if (clientSize.width == size.width or size.width == wDefault) and
        (clientSize.height == size.height or size.height == wDefault):
      break
    setSize(clientToWindow(size))

proc setClientSize*(self: wWindow, width: int, height: int) {.validate, property.} =
  ## This sets the size of the window client area in pixels.
  setClientSize((width, height))

proc contain*(self: wWindow, windows: varargs[wWindow, wWindow]) {.validate.} =
  ## Sizes the window to contain all the specified windows.
  ## Basically used by staticbox control.
  var width, height: int
  var x, y = int.high

  for i in 0..<windows.len:
    let win = windows[i]
    wValidate(win)
    let pos = win.getPosition()
    x = min(x, pos.x)
    y = min(y, pos.y)

  for i in 0..<windows.len:
    let win = windows[i]
    let rect = win.getRect()

    width = max(width, rect.x + rect.width - x)
    height = max(height, rect.y + rect.height - y)

  let margins = getClientMargins()
  x -= margins.left
  y -= margins.top
  width += margins.left + margins.right
  height += margins.top + margins.bottom
  setSize(x, y, width, height)

proc setMinSize*(self: wWindow, size: wSize) {.validate, property.} =
  ## Sets the minimum size of the window.
  mMinSize = size
  var
    currentSize = getSize()
    adjustSize = wDefaultSize

  if currentSize.width < size.width: adjustSize.width = size.width
  if currentSize.height < size.height: adjustSize.height = size.height
  if adjustSize != wDefaultSize: setSize(adjustSize)

proc setMinSize*(self: wWindow, x: int, y: int) {.validate, property, inline.} =
  ## Sets the minimum size of the window.
  setMinSize((x, y))

proc getMinSize*(self: wWindow): wSize {.validate, property, inline.} =
  ## Returns the minimum size of the window.
  result = mMinSize

proc setMaxSize*(self: wWindow, size: wSize) {.validate, property.} =
  ## Sets the maximum size of the window.
  mMaxSize = size
  var
    currentSize = getSize()
    adjustSize = wDefaultSize

  if currentSize.width > size.width: adjustSize.width = size.width
  if currentSize.height > size.height: adjustSize.height = size.height
  if adjustSize != wDefaultSize: setSize(adjustSize)

proc setMaxSize*(self: wWindow, x: int, y: int) {.validate, property, inline.} =
  ## Sets the maximum size of the window.
  setMaxSize((x, y))

proc getMaxSize*(self: wWindow): wSize {.validate, property, inline.} =
  ## Returns the maximum size of the window.
  result = mMaxSize

proc setMinClientSize*(self: wWindow, size: wSize) {.validate, property, inline.} =
  ## Sets the minimum client size of the window.
  setMinSize(clientToWindow(size))

proc setMinClientSize*(self: wWindow, x: int, y: int) {.validate, property, inline.} =
  ## Sets the minimum client size of the window.
  setMinSize(clientToWindow((x, y)))

proc setMaxClientSize*(self: wWindow, size: wSize) {.validate, property, inline.} =
  ## Sets the maximum client size of the window
  setMaxSize(clientToWindow(size))

proc setMaxClientSize*(self: wWindow, x: int, y: int) {.validate, property, inline.} =
  ## Sets the maximum client size of the window
  setMaxSize(clientToWindow((x, y)))

proc screenToClient*(self: wWindow, pos: wPoint): wPoint {.validate.} =
  ## Converts from screen to client window coordinates.
  var p: POINT
  p.x = pos.x
  p.y = pos.y
  ScreenToClient(mHwnd, p)
  let point = getClientAreaOrigin()
  result.x = (if pos.x != wDefault: int(p.x - point.x) else: wDefault)
  result.y = (if pos.y != wDefault: int(p.y - point.y) else: wDefault)

proc clientToScreen*(self: wWindow, pos: wPoint): wPoint {.validate.} =
  ## Converts to screen coordinates from coordinates relative to this window.
  var p: POINT
  let point = getClientAreaOrigin()
  p.x = int32(pos.x + point.x)
  p.y = int32(pos.y + point.y)
  ClientToScreen(mHwnd, p)
  result.x = (if pos.x != wDefault: p.x.int else: wDefault)
  result.y = (if pos.y != wDefault: p.y.int else: wDefault)

proc getWindowStyle*(self: wWindow): wStyle {.validate, property.} =
  ## Gets the wNim's window style.
  ## It simply combine of windows' style and exstyle.
  result = towStyle(DWORD GetWindowLongPtr(mHwnd, GWL_STYLE), DWORD GetWindowLongPtr(mHwnd, GWL_EXSTYLE))

proc setWindowStyle*(self: wWindow, style: wStyle) {.validate, property.} =
  ## Sets the style of the window.
  let
    msStyle = LONG_PTR(style and 0xFFFFFFFF)
    exStyle = LONG_PTR(style shr 32)

  SetWindowLongPtr(mHwnd, GWL_STYLE, msStyle)
  SetWindowLongPtr(mHwnd, GWL_EXSTYLE, exStyle)

proc refresh*(self: wWindow, eraseBackground = true) {.validate.} =
  ## Redraws the contents of the window.
  InvalidateRect(mHwnd, nil, eraseBackground)

proc refresh*(self: wWindow, eraseBackground = true, rect: wRect) {.validate.} =
  ## Redraws the contents of the given rectangle: only the area inside it will be repainted.
  var r = rect.toRECT()
  InvalidateRect(mHwnd, r, eraseBackground)

method show*(self: wWindow, flag = true) {.base, inline.} =
  ## Shows or hides the window.
  ShowWindow(mHwnd, if flag: SW_SHOWNORMAL else: SW_HIDE)

proc hide*(self: wWindow) {.validate, inline.} =
  ## Hides the window.
  show(false)

proc isShownOnScreen*(self: wWindow): bool {.validate, inline.} =
  ## Returns true if the window is physically visible on the screen.
  ## i.e. it is shown and all its parents up to the toplevel window are shown as well.
  result = bool IsWindowVisible(mHwnd)

proc isShown*(self: wWindow): bool {.validate.} =
  ## Returns true if the window is shown, false if it has been hidden.
  if (GetWindowLongPtr(mHwnd, GWL_STYLE).DWORD and WS_VISIBLE) == 0:
    result = false
  else:
    result = true

proc enable*(self: wWindow, flag = true) {.validate, inline.} =
  ## Enable or disable the window for user input.
  EnableWindow(mHwnd, if flag: 1 else: 0)

proc disable*(self: wWindow) {.validate, inline.} =
  ## Disables the window.
  enable(false)

proc isEnabled*(self: wWindow): bool {.validate, inline.} =
  ## Returns true if the window is enabled.
  result = bool IsWindowEnabled(mHwnd)

proc setFocus*(self: wWindow) {.validate.} =
  ## This sets the window to receive keyboard input.
  # draw focus rect
  if mParent != nil:
    SendMessage(mParent.mHwnd, WM_UPDATEUISTATE, MAKEWPARAM(UIS_CLEAR, UISF_HIDEFOCUS), 0)

  if GetFocus() == mHwnd:
    discard SendMessage(mHwnd, WM_SETFOCUS, mHwnd, 0) # a compiler bug here
  else:
    SetFocus(mHwnd)

proc isFocusable*(self: wWindow): bool {.validate, inline.} =
  ## Can this window itself have focus?
  result = mFocusable

proc captureMouse*(self: wWindow) {.validate, inline.} =
  ## Directs all mouse input to this window.
  SetCapture(mHwnd)

proc releaseMouse*(self: wWindow) {.validate, inline.} =
  ## Releases mouse input captured with CaptureMouse().
  ReleaseCapture()

proc hasCapture*(self: wWindow): bool {.validate, inline.} =
  ## Returns true if this window has the current mouse capture.
  result = (mHwnd == GetCapture())

proc getHandle*(self: wWindow): HANDLE {.validate, property, inline.} =
  ## Returns the system HWND of this window.
  result = mHwnd

proc getParent*(self: wWindow): wWindow {.validate, property, inline.} =
  ## Returns the parent of the window.
  result = mParent

proc getForegroundColor*(self: wWindow): wColor {.validate, property, inline.} =
  ## Returns the foreground color of the window.
  result = mForegroundColor

proc getBackgroundColor*(self: wWindow): wColor {.validate, property, inline.} =
  ## Returns the background color of the window.
  result = mBackgroundColor

proc getFont*(self: wWindow): wFont {.validate, property, inline.} =
  ## Returns the font for this window.
  result = mFont

proc getStatusBar*(self: wWindow): wStatusBar {.validate, property, inline.} =
  ## Returns the status bar currently associated with the window.
  result = mStatusBar

proc getId*(self: wWindow): wCommandID {.validate, property, inline.} =
  ## Returns the identifier of the window.
  result = wCommandID GetWindowLongPtr(mHwnd, GWLP_ID)

proc getTitle*(self: wWindow): string {.validate, property.} =
  ## Returns the title of the window.
  var
    maxLen = GetWindowTextLength(mHwnd) + 1
    title = T(maxLen + 2)

  title.setLen(GetWindowText(mHwnd, &title, maxLen))
  result = $title

proc getLabel*(self: wWindow): string {.validate, property, inline.} =
  ## Returns the label of the window. The same as getTitle.
  result = getTitle()

proc getChildren*(self: wWindow): seq[wWindow] {.validate, property, inline.} =
  ## Returns a seq of the window's children.
  result = mChildren

proc getTopParent*(self: wWindow): wWindow {.validate, property.} =
  ## Returns the first top level parent of the given window.
  result = self
  while result.mParent != nil:
    result = result.mParent

proc getNextSibling*(self: wWindow): wWindow {.validate, property.} =
  ## Returns the next window after this one among the parent's children.
  if mParent != nil:
    for i, win in mParent.mChildren:
      if win == self:
        if i + 1 < mParent.mChildren.len:
          result = mParent.mChildren[i + 1]
        break

proc getPrevSibling*(self: wWindow): wWindow {.validate, property.} =
  ## Returns the previous window before this one among the parent's children.
  if mParent != nil:
    for i, win in mParent.mChildren:
      if win == self:
        if i > 0:
          result = mParent.mChildren[i - 1]
        break

proc isDescendant*(self: wWindow, win: wWindow): bool {.validate.} =
  ## Check if the specified window is a descendant of this one.
  wValidate(win)
  var win = win
  while win != nil:
    if win == self: return true
    win = win.mParent

proc isTopLevel*(self: wWindow): bool {.validate.} =
  ## Returns true if the given window is a top-level one.
  result = mParent == nil

proc setParent*(self: wWindow, parent: wWindow): bool {.validate, property, discardable.} =
  ## Set the window's parent, i.e. the window will be removed from its current parent window
  ## and then re-inserted into another.
  wValidate(parent)
  if mParent != nil and SetParent(mHwnd, parent.mHwnd) != 0:
    let index = mParent.mChildren.find(self)
    if index != -1:
      mParent.mChildren.delete(index)

    mParent = parent
    parent.mChildren.add(self)
    return true

proc reparent*(self: wWindow, parent: wWindow): bool {.validate, inline, discardable.} =
  ## Reparents the window. The same as setParent.
  wValidate(parent)
  setParent(parent)

method setForegroundColor*(self: wWindow, color: wColor) {.base, property, inline.} =
  ## Sets the foreground color of the window.
  mForegroundColor = color

method setBackgroundColor*(self: wWindow, color: wColor) {.base, property.} =
  ## Sets the background color of the window.
  mBackgroundColor = color
  mBackgroundBrush = Brush(color)
  SetClassLongPtr(mHwnd, GCL_HBRBACKGROUND, cast[LONG_PTR](mBackgroundBrush.mHandle))
  refresh(self)

proc setId*(self: wWindow, id: wCommandID)  {.validate, property, inline.} =
  ## Sets the identifier of the window.
  SetWindowLongPtr(mHwnd, GWLP_ID, int id)

proc setTitle*(self: wWindow, title: string) {.validate, property, inline.} =
  ## Sets the window's title.
  wValidate(title)
  SetWindowText(mHwnd, title)

proc setLabel*(self: wWindow, label: string) {.validate, property, inline.} =
  ## Sets the window's label. The same as setTitle.
  wValidate(label)
  SetWindowText(mHwnd, label)

proc setFont*(self: wWindow, font: wFont) {.validate, property.} =
  ## Sets the font for this window.
  wValidate(font)
  mFont = font
  SendMessage(mHwnd, WM_SETFONT, font.mHandle, 1)

proc setTransparent*(self: wWindow, alpha: range[0..255]) {.validate, property.} =
  # Set the window to be translucent. A value of 0 sets the window to be fully transparent.
  SetWindowLongPtr(mHwnd, GWL_EXSTYLE, WS_EX_LAYERED or GetWindowLongPtr(mHwnd, GWL_EXSTYLE))
  SetLayeredWindowAttributes(mHwnd, 0, alpha, LWA_ALPHA)

proc getTransparent*(self: wWindow): int {.validate, property.} =
  ## Get the alpha value of a transparent window. Return -1 if failed.
  var alpha: byte
  if GetLayeredWindowAttributes(mHwnd, nil, &alpha, nil) == 0: return -1
  result = int alpha

# todo:
# SetScrollbar
# SetScrollPos

proc getScrollInfo(self: wWindow, orientation: int): SCROLLINFO {.validate, property.} =
  assert orientation in {wHorizontal, wVertical}

  result = SCROLLINFO(cbSize: sizeof(SCROLLINFO))
  result.fMask = SIF_ALL
  GetScrollInfo(mHwnd, if orientation == wHorizontal: SB_HORZ else: SB_VERT, addr result)

proc getScrollRange*(self: wWindow, orientation: int): int {.validate, property.} =
  ## Returns the built-in scrollbar range.
  let info = getScrollInfo(orientation)
  result = int info.nMax

proc getScrollThumb*(self: wWindow, orientation: int): int {.validate, property.} =
  ## Returns the built-in scrollbar thumb size.
  let info = getScrollInfo(orientation)
  result = int info.nPage

proc getScrollPos*(self: wWindow, orientation: int): int {.validate, property.} =
  ## Returns the built-in scrollbar position.
  let info = getScrollInfo(orientation)
  echo info.repr
  result = int info.nPos

proc center*(self: wWindow, direction = wBoth) {.validate.} =
  ## Centers the window..
  var rect = getWindowRect()

  if mParent == nil:
    var r: RECT
    GetClientRect(GetDesktopWindow(), r)

    if (direction and wHorizontal) != 0:
      rect.x = (int(r.right - r.left) - rect.width) div 2

    if (direction and wVertical) != 0:
      rect.y = (int(r.bottom - r.top) - rect.height) div 2

  else:
    let
      size = mParent.getClientSize()
      point = mParent.getClientAreaOrigin()

    if (direction and wHorizontal) != 0:
      rect.x = (size.width - rect.width) div 2 + point.x

    if (direction and wVertical) != 0:
      rect.y = (size.height - rect.height) div 2 + point.y

  setWindowPos(rect.x, rect.y)

proc popupMenu*(self: wWindow, menu: wMenu, pos: wPoint = wDefaultPoint) {.validate.} =
  ## Pops up the given menu at the specified coordinates.
  wValidate(menu)
  var pos = clientToScreen(pos)
  if pos.x == wDefault or pos.y == wDefault:
    pos = wGetMousePosition()

  TrackPopupMenu(menu.mHmenu, TPM_RECURSE or TPM_RIGHTBUTTON, pos.x, pos.y, 0, mHwnd, nil)

proc popupMenu*(self: wWindow, menu: wMenu, x, y: int) {.validate, inline.} =
  ## Pops up the given menu at the specified coordinates.
  popupMenu(menu, (x, y))

proc processEvent*(self: wWindow, event: wEvent): bool {.validate, discardable.} =
  ## Call the window's message handler to process the specified event.
  wValidate(event)
  event.mResult = self.mMessageHandler(self, event.mMsg, event.mWparam, event.mLparam, result)

proc queueEvent*(self: wWindow, event: wEvent) {.validate.} =
  ## Queue event for a later processing.
  wValidate(event)
  PostMessage(mHwnd, event.mMsg, event.mWparam, event.mLparam)

iterator children*(self: wWindow): wWindow {.validate.} =
  ## Iterate the window's children.
  for child in mChildren:
    yield child

iterator siblings*(self: wWindow): wWindow {.validate.} =
  ## Iterate the window's siblings.
  if mParent != nil:
    for child in mParent.mChildren:
      if child != self:
        yield child

# assign to WNDCLASSEX.lpfnWndProc for invoke wWindow's message handler
proc wWndProc(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM): LRESULT {.stdcall.} =
  var self = wAppWindowFindByHwnd(hwnd)
  if self != nil:
    if self.mMessageHandler != nil:
      var processed: bool
      result = self.mMessageHandler(self, msg, wparam, lparam, processed)

      if processed:
        return result

      elif self.mSubclassedOldProc != nil:
        return CallWindowProc(self.mSubclassedOldProc, hwnd, msg, wParam, lParam)

  return DefWindowProc(hwnd, msg, wParam, lParam)

# a default window message handler to every wWindow, handle wEvent here
proc wWindowMessageHandler(self: wWindow, msg: UINT, wparam: WPARAM, lparam: LPARAM, processed: var bool): LRESULT =
  if not processed and wAppHasMessage(msg):
    var propagationLevel = msg.defaultPropagationLevel()
    var event = Event(window=self, msg=msg, wParam=wParam, lParam=lParam, propagationLevel=propagationLevel)
    var id = event.mId
    event.mKeyStatus = getKeyStatus()

    template callHandler(connection: untyped): untyped =
      if connection.id == 0 or connection.id == id:
        if not connection.handler.isNil:
          connection.handler(event)
          processed = not event.mSkip

        elif not connection.neatHandler.isNil:
          connection.neatHandler()
          processed = true

    mSystemConnectionTable.withValue(msg, list):
      for connection in list: # FIFO
        connection.callHandler()
        # system event always skip to next
        # so we don't break even the event is processed

    var this = self
    while true:
      this.mConnectionTable.withValue(msg, list):
        for i in countdown(list.high, 0): # FILO
          let connection = list[i]
          connection.callHandler()
          # pass event to next handler only if not processed
          if processed: break

      this = this.mParent
      if this == nil or processed or event.shouldPropagate() == false:
        break
      else:
        event.mPropagationLevel.dec

    if not event.isNil:
      result = event.mResult

  if not processed:
    case msg
    of WM_GETMINMAXINFO:
      if mMinSize != wDefaultSize or mMaxSize != wDefaultSize:
        var pInfo: PMINMAXINFO = cast[PMINMAXINFO](lparam)
        if mMinSize.width != wDefault: pInfo.ptMinTrackSize.x = mMinSize.width
        if mMinSize.height != wDefault: pInfo.ptMinTrackSize.y = mMinSize.height
        if mMaxSize.width != wDefault: pInfo.ptMaxTrackSize.x = mMaxSize.width
        if mMaxSize.height != wDefault: pInfo.ptMaxTrackSize.y = mMaxSize.height
        processed = true

    of WM_NOTIFY:
      var
        pNMHDR = cast[LPNMHDR](lparam)
        win = wAppWindowFindByHwnd(pNMHDR.hwndFrom)

      if win == nil: win = self # by default, handle it ourselves
      if win != nil and win.mNotifyHandler != nil:
        result = win.mNotifyHandler(win, cast[INT](pNMHDR.code), pNMHDR.idFrom, lparam, processed)

    of WM_CTLCOLORBTN, WM_CTLCOLOREDIT, WM_CTLCOLORSTATIC, WM_CTLCOLORLISTBOX:
      # here lparam.HANDLE maybe a subwindow of our wWindow
      # so need to find our wWindow to get the color setting

      let hdc = wparam.HDC
      var hwnd = lparam.HANDLE
      while hwnd != 0:
        let win = wAppWindowFindByHwnd(hwnd)
        if win != nil:
          SetBkColor(hdc, win.mBackgroundColor)
          SetTextColor(hdc, win.mForegroundColor)
          processed = true
          return win.mBackgroundBrush.mHandle.LRESULT

        hwnd = GetParent(hwnd)

    of WM_DESTROY:
      # always post a WM_QUIT message to mainloop
      # GetMessage won't end because it check wAppHasTopLevelWindow()
      # PostQuitMessage(0)

      # use our own wEvent_AppQuit here, because PostQuitMessage indicates system the thread
      # wishes to terminate. It disables the further creation of windows (MessageBox).
      PostMessage(0, wEvent_AppQuit, 0, 0)
      processed = true

    of WM_NCDESTROY:
      if mDummyParent != 0:
        DestroyWindow(mDummyParent)
        mDummyParent = 0

      wAppWindowDelete(self)
      if mParent != nil:
        let index = mParent.mChildren.find(self)
        if index != -1:
          mParent.mChildren.delete(index)
      processed = true

    else: discard

proc EventConnection(id: wCommandID = 0, handler: wEventHandler = nil, neatHandler: wEventNeatHandler = nil,
    userData = 0, undeletable = false): wEventConnection {.inline.} =

  result = (id: id, handler: handler, neatHandler: neatHandler, userData: userData, undeletable: undeletable)

# used internally: a default behavior cannot be changed by user
proc systemConnect(self: wWindow, msg: UINT, handler: wEventHandler) =
  var connection = EventConnection(handler=handler, undeletable=true)
  self.mSystemConnectionTable.mgetOrPut(msg, @[]).add(connection)
  wAppIncMessage(msg)

# used internally: a default behavior can be changed by user but cannot be deleted
proc hardConnect(self: wWindow, msg: UINT, handler: wEventHandler) =
  var connection = EventConnection(handler=handler, undeletable=true)
  self.mConnectionTable.mgetOrPut(msg, @[]).add(connection)
  wAppIncMessage(msg)

proc connect*(self: wWindow, msg: UINT, handler: wEventHandler, userData: int = 0, undeletable = false) {.validate.} =
  ## Connects the given event type with the event handler defined as "proc (event: wEvent)".
  var connection = EventConnection(handler=handler, userData=userData, undeletable=undeletable)
  self.mConnectionTable.mgetOrPut(msg, @[]).add(connection)
  wAppIncMessage(msg)

proc connect*(self: wWindow, msg: UINT, handler: wEventNeatHandler, userData: int = 0, undeletable = false) {.validate.} =
  ## Connects the given event type with the event handler defined as "proc ()".
  var connection = EventConnection(neatHandler=handler, userData=userData, undeletable=undeletable)
  self.mConnectionTable.mgetOrPut(msg, @[]).add(connection)
  wAppIncMessage(msg)

proc connect*(self: wWindow, msg: UINT, id: wCommandID, handler: wEventHandler, userData: int = 0, undeletable = false) {.validate.} =
  ## Connects the given event type and specified ID with the event handler defined as "proc (event: wEvent)".
  var connection = EventConnection(id=id, handler=handler, userData=userData, undeletable=undeletable)
  self.mConnectionTable.mgetOrPut(msg, @[]).add(connection)
  wAppIncMessage(msg)

proc connect*(self: wWindow, msg: UINT, id: wCommandID, handler: wEventNeatHandler, userData: int = 0, undeletable = false) {.validate.} =
  ## Connects the given event type and specified ID with the event handler defined as "proc ()".
  var connection = EventConnection(id=id, neatHandler=handler, userData=userData, undeletable=undeletable)
  self.mConnectionTable.mgetOrPut(msg, @[]).add(connection)
  wAppIncMessage(msg)

proc connect*(self: wWindow, id: wCommandID, handler: wEventHandler, userData: int = 0, undeletable = false) {.validate.} =
  ## Connects the specified ID with the event handler defined as "proc (event: wEvent)".
  assert id.ord != 0
  connect(self, self.getCommandEvent(), id, handler, userData, undeletable)

proc connect*(self: wWindow, id: wCommandID, handler: wEventNeatHandler, userData: int = 0, undeletable = false) {.validate.} =
  ## Connects the specified ID with the event handler defined as "proc ()".
  assert id.ord != 0
  connect(self, self.getCommandEvent(), id, handler, userData, undeletable)

proc disconnect*(self: wWindow, msg: UINT, limit = -1) {.validate.} =
  ## Disconnects the given event type from the event handler.
  var count = 0
  mConnectionTable.withValue(msg, list):
    for i in countdown(list.high, 0):
      if not list[i].undeletable:
        list.delete(i)
        wAppDecMessage(msg)
        count.inc
        if limit >= 0 and count >= limit: break

proc disconnect*(self: wWindow, msg: UINT, id: wCommandID, limit = -1) {.validate.} =
  ## Disconnects the given event type and specified ID from the event handler.
  var count = 0
  mConnectionTable.withValue(msg, list):
    for i in countdown(list.high, 0):
      if list[i].id == id and not list[i].undeletable:
        list.delete(i)
        wAppDecMessage(msg)
        count.inc
        if limit >= 0 and count >= limit: break

proc disconnect*(self: wWindow, id: wCommandID, limit = -1) {.validate.} =
  ## Disconnects the specified ID from the event handler.
  disconnect(self, self.getCommandEvent(), id, limit)

proc `.`*(self: wWindow, msg: UINT, handler: wEventHandler) {.inline.} =
  ## Symbol alias for connect.
  self.connect(msg, handler)

proc `.`*(self: wWindow, msg: UINT, handler: wEventNeatHandler) {.inline.} =
  ## Symbol alias for connect.
  self.connect(msg, handler)

proc `.`*(self: wWindow, id: wCommandID, handler: wEventHandler) {.inline.} =
  ## Symbol alias for connect.
  self.connect(id, handler)

proc `.`*(self: wWindow, id: wCommandID, handler: wEventNeatHandler) {.inline.} =
  ## Symbol alias for connect.
  self.connect(id, handler)

proc subclass(self: wWindow, hwnd: HWND): HWND =
  result = mHwnd
  mHwnd = hwnd
  wAppWindowChange(self)
  mSubclassedOldProc = cast[WNDPROC](SetWindowLongPtr(hwnd, GWL_WNDPROC, cast[LONG_PTR](wWndProc)))
  assert mSubclassedOldProc != wWndProc

proc unusedClassName(base: string): string =
  var
    count = 1
    wc: WNDCLASSEX

  while true:
    result = base & $count
    count.inc
    if GetClassInfoEx(wAppGetInstance(), result, wc) == 0: break

proc init(self: wWindow, parent: wWindow = nil, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0, owner: wWindow = nil, className = "wWindow", title = "",
    bgColor: wColor = wDefaultColor, fgColor: wColor = wDefaultColor,
    id: wCommandID = 0, regist = true, callback: proc(self: wWindow) = nil) =

  self.wView.init()
  mConnectionTable = initTable[UINT, seq[wEventConnection]]()
  mSystemConnectionTable = initTable[UINT, seq[wEventConnection]]()
  mChildren = @[]
  mMaxSize = wDefaultSize
  mMinSize = wDefaultSize
  mMessageHandler = wWindowMessageHandler
  mParent = parent

  var
    bgColor = bgColor
    fgColor = fgColor

  if parent.isNil:
    if bgColor == wDefaultColor: bgColor = wWhite
    if fgColor == wDefaultColor: fgColor = wBlack
  else:
    if bgColor == wDefaultColor: bgColor = parent.mBackgroundColor
    if fgColor == wDefaultColor: fgColor = parent.mForegroundColor

  mBackgroundBrush = Brush(bgColor)
  mBackgroundColor = bgColor
  mForegroundColor = fgColor

  var className = className
  if regist:
    className = unusedClassName(className)
    var wc: WNDCLASSEX
    wc.cbSize = sizeof(wc)
    wc.style = CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
    wc.lpfnWndProc = wWndProc
    wc.hInstance = wAppGetInstance()
    wc.hCursor = LoadCursor(0, IDC_ARROW)
    wc.hbrBackground = mBackgroundBrush.mHandle
    wc.lpszClassName = className

    if RegisterClassEx(wc) == 0:
      raise newException(wError, className & " class register failure")

  let
    isHideTaskbar = (style and wHideTaskbar) != 0
    style = style and not (wHideTaskbar)

  var
    msStyle = cast[DWORD](style and 0xFFFFFFFF)
    # here need cast because int64 style maybe > int32.high
    exStyle = DWORD(style shr 32 and 0x0FFFFFFF)
    # we use 0x10000000 to 0x80000000 as wNim's style, so must clear it

    x = pos.x
    y = pos.y
    parentHwnd: HWND
    size = size

  if parent.isNil:
    if owner != nil:
      parentHwnd = owner.mHwnd

    elif isHideTaskbar:
      # create a dummy parent window wiht WS_EX_TOOLWINDOW will hide the taskbar button
      parentHwnd = CreateWindowEx(WS_EX_TOOLWINDOW, className, nil, 0, 0, 0, 0, 0, parentHwnd, 0, wAppGetInstance(), nil)
      mDummyParent = parentHwnd

    msStyle = msStyle and (not WS_VISIBLE.DWORD) or WS_CLIPCHILDREN

  else:
    parentHwnd = parent.mHwnd
    msStyle = msStyle or WS_CHILD or WS_VISIBLE

    if pos.x == wDefault: x = 0
    if pos.y == wDefault: y = 0
    adjustForParentClientOriginAdd(x, y)

  mHwnd = CreateWindowEx(exStyle, className, title, msStyle, x, y, 0, 0, parentHwnd, int id, wAppGetInstance(), nil)
  if mHwnd == 0:
    raise newException(wError, className & " window creation failure")

  if callback != nil: callback(self)

  wAppWindowAdd(self)
  if parent.isNil:
    wAppTopLevelWindowAdd(self)
  else:
    mFont = parent.mFont
    parent.mChildren.add(self)

  if mFont == nil: mFont = wDefaultFont
  SendMessage(mHwnd, WM_SETFONT, mFont.mHandle, 1)

  # set size after window create and font setting ok
  # because getDefaultSize usually use font to calculate size
  if size.width == wDefault or size.height == wDefault:
    let defaultSize = getDefaultSize()
    if size.width == wDefault: size.width = defaultSize.width
    if size.height == wDefault: size.height = defaultSize.height

  setSize(size)
  UpdateWindow(mHwnd)

proc Window*(parent: wWindow = nil, id: wCommandID = 0, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0, className = "wWindow"): wWindow =
  ## Constructs a window.
  new(result)
  result.init(parent=parent, pos=pos, size=size, style=style, className=className, id=id)
