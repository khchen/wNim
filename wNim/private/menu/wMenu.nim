#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A menu is a popup (or pull down) list of items.
#
## :Superclass:
##   `wMenuBase <wMenuBase.html>`_
#
## :Seealso:
##   `wMenuBar <wMenuBar.html>`_
##   `wMenuItem <wMenuItem.html>`_

include ../pragma
import strutils
import ../wBase

# For recursive module dependencies.
proc find*(self: wMenu, item: wMenuItem): int
proc setText*(self: wMenu, pos: int, text: string) {.property.}
proc setBitmap*(self: wMenu, pos: int, bitmap: wBitmap = nil) {.property.}
proc setId*(self: wMenu, pos: int, id: wCommandID) {.property.}
proc enable*(self: wMenu, pos: int, flag = true)
proc isEnabled*(self: wMenu, pos: int): bool
proc check*(self: wMenu, pos: int, flag = true)
proc isChecked*(self: wMenu, pos: int): bool
proc toggle*(self: wMenu, pos: int)
proc remove*(self: wMenu, pos: int)
proc remove*(self: wMenu, submenu: wMenu)
proc replace*(self: wMenu, pos: int, id: wCommandID = wIdAny, text = "",
    help = "", bitmap: wBitmap = nil, submenu: wMenu = nil,
    kind = wMenuItemNormal): wMenuItem {.discardable.}

import wMenuBase, wMenuBar, wMenuItem
export wMenuBase, wMenuBar, wMenuItem

# forward declarations
proc Menu*(hMenu: HMENU): wMenu {.inline.}

proc detach*(self: wMenu, menuBar: wMenuBar) {.validate.} =
  ## Detach a menu from a menubar.
  wValidate(menuBar)
  menuBar.remove(self)

proc detach*(self: wMenu, parentMenu: wMenu) {.validate.} =
  ## Detach a menu from a parent menu.
  wValidate(parentMenu)
  parentMenu.remove(self)

proc detach*(self: wMenu) {.validate.} =
  ## Detach a menu from all menubar and menu(as submenu).
  for menuBase in wAppMenuBase():
    if menuBase of wBase.wMenuBar:
      self.detach(wBase.wMenuBar(menuBase))

    elif menuBase of wBase.wMenu:
      self.detach(wBase.wMenu(menuBase))

proc insert*(self: wMenu, pos: int = -1, id: wCommandID = wIdAny, text = "",
    help = "", bitmap: wBitmap = nil, submenu: wMenu = nil,
    kind = wMenuItemNormal): wMenuItem {.validate, discardable.} =
  ## Inserts the given item before the position.
  ## Kind is one of wMenuItemNormal, wMenuItemCheck, wMenuItemRadio
  ## or wMenuItemSeparator.

  var
    pos = pos
    kind = kind
    count = self.mItemList.len
    submenu = submenu

  # check separator before MenuItem ctor, so that separator's id can be -1
  if text.len == 0:
    kind = wMenuItemSeparator
    submenu = nil # separator don't allow submenu

  var item = MenuItem(id=id, text=text, help=help, kind=kind, bitmap=bitmap,
      submenu=submenu)

  if pos < 0: pos = count
  elif pos > count: pos = count

  var menuItemInfo = MENUITEMINFO(
    cbSize: sizeof(MENUITEMINFO),
    fMask: MIIM_DATA or MIIM_FTYPE or MIIM_ID,
    dwItemData: cast[ULONG_PTR](item),
    wID: UINT item.mId) # for wIdAny, item.mId != id

  if kind == wMenuItemSeparator:
    menuItemInfo.fType = MFT_SEPARATOR

  else:
    item.mKind = if kind in {wMenuItemCheck, wMenuItemRadio}: kind else: wMenuItemNormal
    menuItemInfo.fType = MFT_STRING
    menuItemInfo.fMask = menuItemInfo.fMask or MIIM_STRING
    menuItemInfo.dwTypeData = T(text)

  if bitmap != nil:
    menuItemInfo.fMask = menuItemInfo.fMask or MIIM_BITMAP

    when defined(useWinXP):
      menuItemInfo.hbmpItem = HBMMENU_CALLBACK
      # don't use callback if windows version is vista or latter
      if wAppWinVersion() >= 6.0: menuItemInfo.hbmpItem = bitmap.mHandle

    else:
      menuItemInfo.hbmpItem = bitmap.mHandle

  if submenu != nil:
    item.mKind = wMenuItemSubMenu
    menuItemInfo.fMask = menuItemInfo.fMask or MIIM_SUBMENU
    menuItemInfo.hSubMenu = submenu.mHmenu

  if InsertMenuItem(self.mHmenu, pos, true, menuItemInfo) != 0:
    self.mItemList.insert(item, pos)
    result = item

proc insert*(self: wMenu, pos: int = -1, item: wMenuItem): wMenuItem
    {.validate, discardable.} =
  ## Inserts the given item before the position.
  ## The given wMenuItem object will be copied internally.
  wValidate(item)
  if item != nil:
    result = self.insert(pos=pos, id=item.mId, text=item.mText, help=item.mHelp,
      kind=item.mKind, bitmap=item.mBitmap, submenu=item.mSubmenu)

proc insertSubMenu*(self: wMenu, pos: int = -1, submenu: wMenu, text: string,
    help = "", bitmap: wBitmap = nil, id: wCommandID = wIdAny): wMenuItem
    {.validate, inline, discardable.} =
  ## Inserts the given submenu before the position.
  wValidate(submenu)
  result = self.insert(pos=pos, submenu=submenu, text=text, help=help, bitmap=bitmap)

proc insertSeparator*(self: wMenu, pos: int = -1): wMenuItem
    {.validate, inline, discardable.} =
  ## Inserts a separator at the given position.
  result = self.insert(pos=pos)

proc insertCheckItem*(self: wMenu, pos: int = -1, id: wCommandID = wIdAny,
    text: string, help = "", bitmap: wBitmap = nil): wMenuItem
    {.validate, inline, discardable.} =
  ## Inserts a checkable item at the given position.
  result = self.insert(pos=pos, id=id, text=text, help=help, bitmap=bitmap,
    kind=wMenuItemCheck)

proc insertRadioItem*(self: wMenu, pos: int = -1, id: wCommandID = wIdAny,
    text: string, help = "", bitmap: wBitmap = nil): wMenuItem
    {.validate, inline, discardable.} =
  ## Inserts a radio item at the given position.
  result = self.insert(pos=pos, id=id, text=text, help=help, bitmap=bitmap,
    kind=wMenuItemRadio)

proc append*(self: wMenu, id: wCommandID = wIdAny, text: string, help = "",
  bitmap: wBitmap = nil, submenu: wMenu = nil, kind = wMenuItemNormal): wMenuItem
  {.validate, inline, discardable.} =
  ## Adds a menu item.
  result = self.insert(id=id, text=text, help=help, bitmap=bitmap, submenu=submenu,
    kind=kind)

proc append*(self: wMenu, item: wMenuItem): wMenuItem
    {.validate, inline, discardable.} =
  ## Adds a menu item.
  wValidate(item)
  result = self.insert(item=item)

proc appendSubMenu*(self: wMenu, submenu: wMenu, text: string,
    help = "", bitmap: wBitmap = nil, id: wCommandID = wIdAny): wMenuItem
    {.validate, inline, discardable.} =
  ## Adds a submenu.
  result = self.insert(submenu=submenu, text=text, help=help, bitmap=bitmap)

proc appendSeparator*(self: wMenu): wMenuItem
    {.validate, inline, discardable.} =
  ## Adds a separator.
  result = self.insert()

proc appendCheckItem*(self: wMenu, id: wCommandID = wIdAny, text: string,
    help = "", bitmap: wBitmap = nil): wMenuItem
    {.validate, inline, discardable.} =
  ## Adds a checkable item.
  result = self.insert(id=id, text=text, help=help, bitmap=bitmap, kind=wMenuItemCheck)

proc appendRadioItem*(self: wMenu, id: wCommandID = wIdAny, text: string,
    help = "", bitmap: wBitmap = nil): wMenuItem
    {.validate, inline, discardable.} =
  ## Adds a radio item.
  result = self.insert(id=id, text=text, help=help, bitmap=bitmap, kind=wMenuItemRadio)

proc find*(self: wMenu, item: wMenuItem): int {.validate.} =
  ## Find the index of the item or wNotFound(-1) if not found.
  # every item in self.mItemList should be unique, don't need iterator here.
  wValidate(item)
  for i, it in self.mItemList:
    if it == item:
      return i
  result = wNotFound

iterator find*(self: wMenu, submenu: wMenu): int {.validate.} =
  ## Iterates over each index of submenu in menu.
  wValidate(submenu)
  for i, item in self.mItemList:
    if item.mSubmenu == submenu:
      yield i

proc find*(self: wMenu, submenu: wMenu): int {.validate.} =
  ## Find the first index of submenu or wNotFound(-1) if not found.
  wValidate(submenu)
  for i in self.find(submenu):
    return i
  result = wNotFound

iterator find*(self: wMenu, text: string): int {.validate.} =
  ## Iterates over each index with the given text.
  for i, item in self.mItemList:
    if item.mText == text:
      yield i

proc find*(self: wMenu, text: string): int {.validate.} =
  ## Find the first index with the given text or wNotFound(-1) if not found.
  for i in self.find(text):
    return i
  result = wNotFound

iterator findItem*(self: wMenu, text: string): wMenuItem {.validate.} =
  ## Iterates over each wMenuItem object with the given text.
  for i in self.find(text):
    yield self.mItemList[i]

proc findItem*(self: wMenu, text: string): wMenuItem {.validate.} =
  ## Find the first wMenuItem object with the given text or nil if not found.
  for item in self.findItem(text):
    return item

iterator findText*(self: wMenu, text: string): int {.validate.} =
  ## Iterates over each index with the given text (not include any accelerator
  ## characters),
  for i, item in self.mItemList:
    if item.mText.len != 0 and item.mText.replace("&", "") == text:
      yield i

proc findText*(self: wMenu, text: string): int {.validate.} =
  ## Find the first index with the given text (not include any accelerator
  ## characters), wNotFound(-1) if not found.
  for i in self.findText(text):
    return i
  result = wNotFound

iterator findItemText*(self: wMenu, text: string): wMenuItem {.validate.} =
  ## Iterates over each wMenuItem object with the given text (not include any
  ## accelerator characters).
  for i in self.findText(text):
    yield self.mItemList[i]

proc findItemText*(self: wMenu, text: string): wMenuItem {.validate.} =
  ## Find the first wMenuItem object with the given text (not include any
  ## accelerator characters), nil if not found.
  for item in self.findItemText(text):
    return item

proc remove*(self: wMenu, pos: int) {.validate.} =
  ## Removes the menu item from the menu.
  ## If the item is a submenu, it will not be deleted.
  ## Use destroy() if you want to delete a submenu.
  if pos >= 0 and pos < self.mItemList.len:
    if RemoveMenu(self.mHmenu, pos, MF_BYPOSITION) != 0:
      self.mItemList.delete(pos)

proc remove*(self: wMenu, submenu: wMenu) {.validate.} =
  ## Find and remove all the submenu object from the menu.
  wValidate(submenu)
  while true:
    let pos = self.find(submenu)
    if pos == wNotFound: break
    self.remove(pos)

proc removeAll*(self: wMenu) {.validate.} =
  ## Removes all the menu items from the menu.
  for i in 0..<GetMenuItemCount(self.mHmenu):
    RemoveMenu(self.mHmenu, 0, MF_BYPOSITION)
  self.mItemList.setLen(0)

proc delete*(self: wMenu, pos: int) {.validate.} =
  ## Deletes the menu item from the menu. Same as remove().
  self.remove(pos)

proc getKind*(self: wMenu, pos: int): wMenuItemKind {.validate, property.} =
  ## Returns the item kind at the position, one of wMenuItemNormal,
  ## wMenuItemCheck,  wMenuItemRadio, wMenuItemSeparator, or wMenuItemSubMenu.
  if pos >= 0 and pos < self.mItemList.len:
    result = self.mItemList[pos].mKind

proc getSubMenu*(self: wMenu, pos: int): wMenu {.validate, property.} =
  ## Returns the submenu for the menu item at the position, or nil if there isn't one.
  if pos >= 0 and pos < self.mItemList.len:
    result = self.mItemList[pos].mSubmenu

proc getText*(self: wMenu, pos: int): string {.validate, property.} =
  ## Returns the text for the menu item at the position.
  if pos >= 0 and pos < self.mItemList.len:
    result = self.mItemList[pos].mText

proc getLabel*(self: wMenu, pos: int): string {.validate, property, inline.} =
  ## Returns the text for the menu item at the position.
  self.getText(pos)

proc setText*(self: wMenu, pos: int, text: string) {.validate, property.} =
  ## Sets the text for the menu item at the position.
  if pos >= 0 and pos < self.mItemList.len and text.len != 0:
    let item = self.mItemList[pos]
    if item.mKind != wMenuItemSeparator:
      var menuItemInfo = MENUITEMINFO(
        cbSize: sizeof(MENUITEMINFO),
        fMask: MIIM_STRING,
        dwTypeData: T(text))
      if SetMenuItemInfo(self.mHmenu, pos, true, menuItemInfo) != 0:
        item.mText = text

proc setLabel*(self: wMenu, pos: int, text: string) {.validate, property, inline.} =
  ## Sets the text for the menu item at the position.
  self.setText(pos, text)

proc getLabelText*(self: wMenu, pos: int): string {.validate, property, inline.} =
  ## Returns the text for the menu item at the position,
  ## not include any accelerator characters.
  self.getText(pos).replace("&", "")

proc getHelp*(self: wMenu, pos: int): string {.validate, property.} =
  ## Returns the help string for the menu item at the position.
  if pos >= 0 and pos < self.mItemList.len:
    result = self.mItemList[pos].mHelp

proc setHelp*(self: wMenu, pos: int, help: string) {.validate, property.} =
  ## Sets the help string of item at the position.
  if pos >= 0 and pos < self.mItemList.len:
    self.mItemList[pos].mHelp = help

proc getBitmap*(self: wMenu, pos: int): wBitmap {.validate, property.} =
  ## Returns the bitmap of item at the position.
  if pos >= 0 and pos < self.mItemList.len:
    result = self.mItemList[pos].mBitmap

proc setBitmap*(self: wMenu, pos: int, bitmap: wBitmap = nil) {.validate, property.} =
  ## Sets the bitmap for the menu item at the position. nil for clear the bitmap.
  if pos >= 0 and pos < self.mItemList.len:
    let item = self.mItemList[pos]
    if item.mKind != wMenuItemSeparator:
      var hbmp = 0
      if bitmap != nil:
        hbmp = (if wAppWinVersion() >= 6.0: bitmap.mHandle else: HBMMENU_CALLBACK)

      var menuItemInfo = MENUITEMINFO(
        cbSize: sizeof(MENUITEMINFO),
        fMask: MIIM_BITMAP,
        hbmpItem: hbmp)
      if SetMenuItemInfo(self.mHmenu, pos, true, menuItemInfo) != 0:
        item.mBitmap = bitmap

proc setId*(self: wMenu, pos: int, id: wCommandID) {.validate, property.} =
  ## Sets the id for the menu item at the position.
  if pos >= 0 and pos < self.mItemList.len:
    let item = self.mItemList[pos]
    if item.mKind != wMenuItemSeparator:
      var menuItemInfo = MENUITEMINFO(
        cbSize: sizeof(MENUITEMINFO),
        fMask: MIIM_ID,
        wID: UINT id)
      if SetMenuItemInfo(self.mHmenu, pos, true, menuItemInfo) != 0:
        item.mId = id

proc replace*(self: wMenu, pos: int, id: wCommandID = wIdAny, text = "",
    help = "", bitmap: wBitmap = nil, submenu: wMenu = nil,
    kind = wMenuItemNormal): wMenuItem {.validate, discardable.} =
  ## Replaces the menu item at the given position with another one.
  ## Return the new menu item object.
  if pos >= 0 and pos < self.mItemList.len:
    self.remove(pos)
    result = self.insert(pos=pos, id=id, text=text, help=help, bitmap=bitmap,
      submenu=submenu, kind=kind)

proc replace*(self: wMenu, pos: int, item: wMenuItem): wMenuItem
    {.validate, discardable.} =
  ## Replaces the menu item at the given position with another one.
  ## Return the new menu item object.
  wValidate(item)
  if pos >= 0 and pos < self.mItemList.len:
    self.remove(pos)
    result = self.insert(pos, item)

proc isCheck*(self: wMenu, pos: int): bool {.validate.} =
  ## Determines whether a menu item is a kind of check item.
  if pos >= 0 and pos < self.mItemList.len:
    result = (self.mItemList[pos].mKind == wMenuItemCheck)

proc isRadio*(self: wMenu, pos: int): bool {.validate.} =
  ## Determines whether a menu item is a kind of radio item.
  if pos >= 0 and pos < self.mItemList.len:
    result = (self.mItemList[pos].mKind == wMenuItemRadio)

proc isSeparator*(self: wMenu, pos: int): bool {.validate.} =
  ## Determines whether a menu item is a kind of separator.
  if pos >= 0 and pos < self.mItemList.len:
    result = (self.mItemList[pos].mKind == wMenuItemSeparator)

proc isSubMenu*(self: wMenu, pos: int): bool {.validate.} =
  ## Determines whether a menu item is a kind of submenu.
  if pos >= 0 and pos < self.mItemList.len:
    result = (self.mItemList[pos].mSubmenu != nil)

proc enable*(self: wMenu, pos: int, flag = true) {.validate.} =
  ## Enables or disables (greys out) a menu item.
  if pos >= 0 and pos < self.mItemList.len:
    wEnableMenu(self.mHmenu, pos, flag)

    # it need to refresh if the menu in menubar
    for menuBase in wAppMenuBase():
      if menuBase of wBase.wMenuBar:
        let menuBar = wBase.wMenuBar(menuBase)
        let pos = menuBar.find(self)
        if pos != wNotFound:
          menuBar.refresh()

proc disable*(self: wMenu, pos: int) {.validate, inline.} =
  ## Disables (greys out) a menu item.
  self.enable(pos, false)

proc isEnabled*(self: wMenu, pos: int): bool {.validate.} =
  ## Determines whether a menu item is enabled.
  if pos >= 0 and pos < self.mItemList.len:
    result = wIsMenuEnabled(self.mHmenu, pos)

proc enable*(self: wMenu, flag = true) {.validate.} =
  ## Enables or disables (greys out) this menu.
  for menuBase in wAppMenuBase():
    if menuBase of wBase.wMenuBar:
      let menuBar = wBase.wMenuBar(menuBase)
      let pos = menuBar.find(self)
      if pos != wNotFound: menuBar.enable(pos, flag)

    elif menuBase of wBase.wMenu:
      let menu = wBase.wMenu(menuBase)
      let pos = menu.find(self)
      if pos != wNotFound: menu.enable(pos, flag)

proc disable*(self: wMenu) {.validate, inline.} =
  ## Disables (greys out) this menu.
  self.enable(false)

proc check*(self: wMenu, pos: int, flag = true) {.validate.} =
  ## Checks or unchecks the menu item.
  wMenuCheck(self, pos, flag)

proc isChecked*(self: wMenu, pos: int): bool {.validate.} =
  ## Determines whether a menu item is checked.
  if pos >= 0 and pos < self.mItemList.len:
    var menuItemInfo = wGetMenuItemInfo(self.mHmenu, pos)
    result = (menuItemInfo.fState and MFS_CHECKED) != 0

proc toggle*(self: wMenu, pos: int) {.validate.} =
  ## Toggle the menu item.
  wMenuToggle(self, pos)

proc getTitle*(self: wMenu): string {.validate, property.} =
  ## Returns the title of the menu, a title means it's label in menuBar or menu.
  ## (find fist match if a menu attach to more than one menuBar or menu).
  for menuBase in wAppMenuBase():
    if menuBase of wBase.wMenuBar:
      let menuBar = wBase.wMenuBar(menuBase)
      let pos = menuBar.find(self)
      if pos != wNotFound: return menuBar.getLabel(pos)

    elif menuBase of wBase.wMenu:
      let menu = wBase.wMenu(menuBase)
      let pos = menu.find(self)
      if pos != wNotFound: return menu.getText(pos)

iterator items*(self: wMenu): wMenuItem {.validate.} =
  ## Iterator menus in a menubar
  for item in self.mItemList:
    yield item

proc `[]`*(self: wMenu, pos: int): wMenuItem {.validate, inline.} =
  ## Returns the menu item at pos. Raise error if index out of bounds.
  result = self.mItemList[pos]

proc len*(self: wMenu): int {.validate, inline.} =
  ## Returns the number of wMenuItem objects in the menu.
  ## This shoud be equal to getCount() in most case.
  result = self.mItemList.len

proc delete*(self: wMenu) {.validate.} =
  ## Delete the menu.
  if self.mHmenu != 0:
    self.detach()
    `=destroy`(self[])

proc destroy*(self: wMenu, pos: int) {.validate.} =
  ## Destroy the menu item from the menu.
  ## If the item is a submenu, it will be deleted.
  ## Use remove() if you want to keep the submenu.
  if pos >= 0 and pos < self.mItemList.len:
    if self.mItemList[pos].mSubmenu != nil:
      self.mItemList[pos].mSubmenu.delete()
    self.mItemList.delete(pos)

wClass(wMenu of wMenuBase):

  proc init*(self: wMenu) {.validate.} =
    ## Initializes an empty menu.
    self.mHmenu = CreatePopupMenu()
    var menuInfo = MENUINFO(
      cbSize: sizeof(MENUINFO),
      fMask: MIM_MENUDATA or MIM_STYLE,
      dwStyle: MNS_CHECKORBMP or MNS_NOTIFYBYPOS,
      dwMenuData: cast[ULONG_PTR](self))
    SetMenuInfo(self.mHmenu, menuInfo)
    self.mItemList = @[]
    self.mDeletable = true
    self.wAppMenuBaseAdd()

  proc init*(self: wMenu, menuBar: wMenuBar, text: string,
      bitmap: wBitmap = nil) {.validate.} =
    ## Initializes an empty menu and append to menubar.
    wValidate(menuBar)
    self.init()
    menuBar.append(self, text, bitmap)

  proc init*(self: wMenu, hMenu: HMENU) {.validate.} =
    ## Initializes a menu by a given system menu handle. The style (dwStyle) and
    ## application-defined value (dwMenuData) of this menu will be overwritten.
    if IsMenu(hMenu) == 0:
      raise newException(wError, "wMenu creation failed")

    self.mHmenu = hMenu
    var menuInfo = MENUINFO(
      cbSize: sizeof(MENUINFO),
      fMask: MIM_MENUDATA or MIM_STYLE,
      dwStyle: MNS_CHECKORBMP or MNS_NOTIFYBYPOS,
      dwMenuData: cast[ULONG_PTR](self))
    SetMenuInfo(self.mHmenu, menuInfo)
    self.mItemList = @[]
    self.mDeletable = false
    self.wAppMenuBaseAdd()

    let count = GetMenuItemCount(hMenu)
    for i in 0..<count:
      var text = T(65536)
      text.setLen(wGetMenuItemString(hMenu, i, text))

      var itemInfo = wGetMenuItemInfo(hMenu, i, MIIM_FTYPE or MIIM_ID or MIIM_SUBMENU)
      let
        submenu = if itemInfo.hSubMenu != 0: Menu(itemInfo.hSubMenu) else: nil
        id = wCommandID itemInfo.wID
        kind =
          if not submenu.isNil: wMenuItemSubMenu
          elif (itemInfo.fType and MFT_SEPARATOR) != 0: wMenuItemSeparator
          else: wMenuItemNormal # wMenuItemCheck or wMenuItemRadio ?

      var item = MenuItem(id=id, text=($text), kind=kind, submenu=submenu)
      self.mItemList.add item
