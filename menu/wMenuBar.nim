## A menubar is a series of menus accessible from the top of a frame.

proc refresh*(self: wMenuBar) {.validate.} =
  ## Redraw the menubar.
  for frame in mParentFrameSet:
    if frame.mMenuBar == self:
      DrawMenuBar(frame.mHwnd)

proc attach*(self: wMenuBar, frame: wFrame) {.validate.} =
  ## Attach a menubar to frame window.
  wValidate(frame)
  frame.mMenuBar = self
  if SetMenu(frame.mHwnd, mHmenu) != 0:
    DrawMenuBar(frame.mHwnd)
    mParentFrameSet.incl frame

proc detach*(self: wMenuBar, frame: wFrame) {.validate.} =
  ## Detach a menubar from the frame.
  wValidate(frame)
  if frame.mMenuBar == self:
    frame.mMenuBar = nil
    SetMenu(frame.mHwnd, 0)
    DrawMenuBar(frame.mHwnd)
  if frame in mParentFrameSet:
    mParentFrameSet.excl frame

proc detach*(self: wMenuBar) {.validate.} =
  ## Detach a menubar from all frames.
  for frame in mParentFrameSet:
    detach(frame)

proc isAttached*(self: wMenuBar): bool {.validate.} =
  ## Return true if a menubar is attached to some frame window.
  result = mParentFrameSet.len > 0

proc isAttached*(self: wMenuBar, frame: wFrame): bool {.validate.} =
  ## Return true if a menubar is attached to the frame window.
  wValidate(frame)
  result = frame in mParentFrameSet

proc insert*(self: wMenuBar, pos: int, menu: wMenu, text: string, bitmap: wBitmap = nil) {.validate.} =
  ## Inserts the menu at the given position into the menubar.
  wValidate(menu, text)
  var
    text = text
    pos = pos
    count = mMenuList.len

  if text.len == 0: text = ""
  if pos < 0: pos = count
  elif pos > count: pos = count

  var menuItemInfo = MENUITEMINFO(
    cbSize: sizeof(MENUITEMINFO),
    fMask: MIIM_DATA or MIIM_FTYPE or MIIM_SUBMENU or MIIM_STRING,
    dwItemData: cast[ULONG_PTR](menu),
    fType: MFT_STRING,
    hSubMenu: menu.mHmenu,
    dwTypeData: T(text))

  if bitmap != nil:
    menu.mBitmap = bitmap
    menuItemInfo.fMask = menuItemInfo.fMask or MIIM_BITMAP
    menuItemInfo.hbmpItem = (if wGetWinVersion() > 6.0: bitmap.mHandle else: HBMMENU_CALLBACK)

  if InsertMenuItem(mHmenu, pos, true, menuItemInfo) != 0:
    mMenuList.insert(menu, pos)
    menu.mParentMenuCountTable.inc(self, 1)
    refresh()

proc append*(self: wMenuBar, menu: wMenu, text: string, bitmap: wBitmap = nil) {.validate, inline.} =
  ## Adds the menu to the end of the menubar.
  wValidate(menu, text)
  insert(pos = -1, menu=menu, text=text, bitmap=bitmap)

proc enable*(self: wMenuBar, pos: int, flag = true) {.validate.} =
  ## Enables or disables a whole menu.
  if pos >= 0 and pos < mMenuList.len:
    wEnableMenu(mHmenu, pos, flag)

proc disable*(self: wMenuBar, pos: int) {.validate, inline.} =
  ## Disables a whole menu.
  enable(pos, false)

proc isEnabled*(self: wMenuBar, pos: int): bool {.validate.} =
  ## Returns true if the menu with the given index is enabled.
  if pos >= 0 and pos < mMenuList.len:
    result = wIsMenuEnabled(mHmenu, pos)

iterator find*(self: wMenuBar, menu: wMenu): int {.validate.} =
  ## Iterates over each index of menu in menubar.
  wValidate(menu)
  for i, m in mMenuList:
    if m == menu:
      yield i

proc find*(self: wMenuBar, menu: wMenu): int {.validate.} =
  ## Find the first index of menu or wNotFound(-1) if not found.
  wValidate(menu)
  for i in find(menu):
    return i
  result = wNotFound

iterator find*(self: wMenuBar, text: string): int {.validate.} =
  ## Iterates over each index with the given title.
  # don's use mTitle here, because a menu may be attach a frame twice, or different frame?
  wValidate(text)
  var buffer = T(65536)
  for i in 0..<GetMenuItemCount(mHmenu):
    let length = wGetMenuItemString(mHmenu, i, buffer)
    if length != 0 and $buffer[0..<length] == text:
      yield i

proc find*(self: wMenuBar, text: string): int {.validate.} =
  ## Find the first index with the given title or wNotFound(-1) if not found.
  wValidate(text)
  for i in find(text):
    return i
  result = wNotFound

iterator findMenu*(self: wMenuBar, text: string): wMenu {.validate.} =
  ## Iterates over each wMenu object with the given title.
  wValidate(text)
  for i in find(text):
    yield mMenuList[i]

proc findMenu*(self: wMenuBar, text: string): wMenu {.validate.} =
  ## Find the first wMenu object with the given title or nil if not found.
  wValidate(text)
  for menu in findMenu(text):
    return menu

iterator findText*(self: wMenuBar, text: string): int {.validate.} =
  ## Iterates over each index with the given title (not include any accelerator characters).
  wValidate(text)
  var buffer = T(65536)
  for i in 0..<GetMenuItemCount(mHmenu):
    let length = wGetMenuItemString(mHmenu, i, buffer)
    if length != 0 and replace($buffer[0..<length], "&", "") == text:
      yield i

proc findText*(self: wMenuBar, text: string): int {.validate.} =
  ## Find the first index with the given title (not include any accelerator characters),
  ## wNotFound(-1) if not found.
  wValidate(text)
  for i in findText(text):
    return i
  result = wNotFound

iterator findMenuText*(self: wMenuBar, text: string): wMenu {.validate.} =
  ## Iterates over each wMenu object with the given title (not include any accelerator characters).
  wValidate(text)
  for i in findText(text):
    yield mMenuList[i]

proc findMenuText*(self: wMenuBar, text: string): wMenu {.validate.} =
  ## Find the first wMenu object with the given title (not include any accelerator characters),
  ## nil if not found.
  wValidate(text)
  for menu in findMenuText(text):
    return menu

proc getMenu*(self: wMenuBar, pos: int): wMenu {.validate, property.} =
  ## Returns the menu at pos, nil if index out of bounds.
  if pos >= 0 and pos < mMenuList.len:
    result = mMenuList[pos]

proc getLabel*(self: wMenuBar, pos: int): string {.validate, property.} =
  ## Returns the label of a top-level menu.
  if pos >= 0 and pos < mMenuList.len:
    var buffer = T(65536)
    let length = wGetMenuItemString(mHmenu, pos, buffer)
    if length != 0:
      result = $buffer[0..<length]

proc getLabelText*(self: wMenuBar, pos: int): string {.validate, property.} =
  ## Returns the label of a top-level menu, not include any accelerator characters.
  wValidate(self)
  result = getLabel(pos)
  if result.len != 0:
    result = result.replace("&", "")

proc setLabel*(self: wMenuBar, pos: int, text: string) {.validate, property.} =
  ## Sets the label of a top-level menu.
  wValidate(text)
  if pos >= 0 and pos < mMenuList.len and text != nil:
    var menuItemInfo = MENUITEMINFO(
      cbSize: sizeof(MENUITEMINFO),
      fMask: MIIM_STRING,
      dwTypeData: T(text))
    SetMenuItemInfo(mHmenu, pos, true, menuItemInfo)

proc remove*(self: wMenuBar, pos: int): wMenu {.validate, discardable.} =
  ## Removes the menu from the menubar and returns the menu object.
  if pos >= 0 and pos < mMenuList.len:
    if RemoveMenu(mHmenu, pos, MF_BYPOSITION) != 0:
      result = mMenuList[pos]
      result.mParentMenuCountTable.inc(self, -1)
      mMenuList.delete(pos)
    refresh()

proc remove*(self: wMenuBar, menu: wMenu) {.validate.} =
  ## Find and remove all the menu object from the menubar.
  wValidate(menu)
  while true:
    let pos = find(menu)
    if pos == wNotFound: break
    remove(pos)

proc replace*(self: wMenuBar, pos: int, menu: wMenu, text: string, bitmap: wBitmap = nil): wMenu {.validate, discardable.} =
  ## Replaces the menu at the given position with another one.
  ## Return the old menu object.
  wValidate(menu)
  if pos >= 0 and pos < mMenuList.len:
    result = remove(pos)
    insert(pos, menu=menu, text=text, bitmap=bitmap)

proc delete*(self: wMenuBar) {.validate.} =
  ## Delete the menubar.
  detach()
  if mHmenu != 0:
    # use GetMenuItemCount(mHmenu) instead of mMenuList.len to ensure we remove all menu.
    for i in 0..<GetMenuItemCount(mHmenu):
      RemoveMenu(mHmenu, 0, MF_BYPOSITION)
    DestroyMenu(mHmenu)

    for i in 0..<mMenuList.len:
      mMenuList[i].mParentMenuCountTable.inc(self, -1)

    mMenuList = @[]
    mHmenu = 0

proc getHandle*(self: wMenuBar): HMENU {.validate, property, inline.} =
  ## Get system handle of this menubar.
  result = mHmenu

proc getCount*(self: wMenuBar): int {.validate, property, inline.} =
  ## Returns the number of menus in this menubar.
  result = GetMenuItemCount(mHmenu)

iterator items*(self: wMenuBar): wMenu {.validate.} =
  ## Items iterator for menus in a menubar.
  for menu in mMenuList:
    yield menu

iterator pairs*(self: wMenuBar): (int, wMenu) {.validate.} =
  ## Pair iterator for indexes/menus in a menubar.
  for i, menu in mMenuList:
    yield (i, menu)

proc `[]`*(self: wMenuBar, pos: int): wMenu {.validate, inline.} =
  ## Returns the menu at pos, raise error if index out of bounds.
  result = mMenuList[pos]

proc len*(self: wMenuBar): int {.validate, inline.} =
  ## Returns the number of wMenu objects in this menubar.
  ## This shoud be equal to getCount in most case.
  result = mMenuList.len

proc init(self: wMenuBar) =
  mHmenu = CreateMenu()
  var menuInfo = MENUINFO(
    cbSize: sizeof(MENUINFO),
    fMask: MIM_STYLE,
    dwStyle: MNS_CHECKORBMP or MNS_NOTIFYBYPOS)
  SetMenuInfo(mHmenu, menuInfo)
  mMenuList = @[]
  mParentFrameSet = initSet[wFrame]()

proc final(self: wMenuBar) =
  delete()

proc MenuBar*(): wMenuBar =
  ## Construct an empty menubar.
  new(result, final)
  result.init()

proc MenuBar*(menus: openarray[(wMenu, string)]): wMenuBar =
  ## Construct a menubar from arrays of menus and titles.
  result = MenuBar()
  for menu in menus:
    result.append(menu[0], menu[1])

proc MenuBar*(frame: wFrame, menus: openarray[(wMenu, string)] = []): wMenuBar =
  ## Construct a menubar from arrays of menus and titles, and attach it to frame window.
  wValidate(frame)
  result = MenuBar(menus)
  result.attach(frame)
