#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2018 Ward
#
#====================================================================

## wMenuBase is the super class of wMenuBar and wMenu.
## It means the functions here work with both menubar and menu.
#
## :Subclasses:
##   `wMenuBar <wMenuBar.html>`_
##   `wMenu <wMenu.html>`_

proc find*(self: wMenuBase, id: wCommandID): tuple[menu: wMenu, pos: int]
    {.validate.} =
  ## Return the tuple (menu, pos) indicate a item with the given id,
  ## (nil, wNotFound(-1)) if not found.
  if self of wMenuBar:
    let menuBar = wMenuBar(self)
    for topMenu in menuBar.mMenuList:
      result = find(topMenu, id)
      if result.menu != nil: # found !!
        return

  elif self of wMenu:
    let menu = wMenu(self)
    for i, item in menu.mItemList: # level fist, deep later
      if item.mId == id: # found !!
        return (menu, i)

    for item in menu.mItemList:
      if item.mSubmenu != nil:
        result = find(item.mSubmenu, id)
        if result.menu != nil: # found !!
          return

proc findItem*(self: wMenuBase, id: wCommandID): wMenuItem {.validate.} =
  ## Search the first wMenuItem object with the given id, nil if not found.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.mItemList[pos]

proc remove*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Removes the menu item from the menu.
  ## If the item is a submenu, it will not be deleted.
  ## Use destroy() if you want to delete a submenu.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.remove(pos)

proc delete*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Deletes the menu item from the menu. Same as remove().
  let (menu, pos) = find(id)
  if menu != nil:
    menu.delete(pos)

proc destroy*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Destroy the menu item from the menu.
  ## If the item is a submenu, it will be deleted.
  ## Use remove() if you want to keep the submenu.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.destroy(pos)

proc getKind*(self: wMenuBase, id: wCommandID): wMenuItemKind
    {.validate, property.} =
  ## Returns the item kind,
  ## one of wMenuItemNormal, wMenuItemCheck,  wMenuItemRadio, wMenuItemSeparator, or wMenuItemSubMenu.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getKind(pos)

proc getSubMenu*(self: wMenuBase, id: wCommandID): wMenu {.validate, property.} =
  ## Returns the submenu for the menu item, or nil if there isn't one.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getSubMenu(pos)

proc getText*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the text for the menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getText(pos)

proc getLabel*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the text for the menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getLabel(pos)

proc setText*(self: wMenuBase, id: wCommandID, text: string) {.validate, property.} =
  ## Sets the text for the menu item at the position.
  wValidate(text)
  let (menu, pos) = find(id)
  if menu != nil:
    menu.setText(pos, text)

proc setLabel*(self: wMenuBase, id: wCommandID, text: string) {.validate, property.} =
  ## Sets the text for the menu item.
  wValidate(text)
  let (menu, pos) = find(id)
  if menu != nil:
    menu.setLabel(pos, text)

proc getLabelText*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the text for the menu item,
  ## not include any accelerator characters.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getLabelText(pos)

proc getHelp*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the help string for the menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getHelp(pos)

proc setHelp*(self: wMenuBase, id: wCommandID, help: string) {.validate, property.} =
  ## Sets the help string of item.
  wValidate(help)
  let (menu, pos) = find(id)
  if menu != nil:
    menu.setHelp(pos, help)

proc getBitmap*(self: wMenuBase, id: wCommandID): wBitmap {.validate, property.} =
  ## Returns the bitmap of item.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.getBitmap(pos)

proc setBitmap*(self: wMenuBase, id: wCommandID, bitmap: wBitmap = nil)
    {.validate, property.} =
  ## Sets the bitmap for the menu item, nil for clear the bitmap.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.setBitmap(pos, bitmap)

proc setId*(self: wMenuBase, id: wCommandID, newid: wCommandID)
    {.validate, property.} =
  ## Sets the id for the menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.setId(pos, newid)

proc replace*(self: wMenuBase, id: wCommandID, text: string = nil,
    help: string = nil, bitmap: wBitmap = nil, submenu: wMenu = nil,
    kind = wMenuItemNormal): wMenuItem {.validate, discardable.} =
  ## Replaces the menu item with another one.
  ## Return the new menu item object.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.replace(pos, id, text, help, bitmap, submenu, kind)

proc replace*(self: wMenuBase, id: wCommandID, item: wMenuItem): wMenuItem
    {.validate, discardable.} =
  ## Replaces the menu item with another one.
  ## Return the new menu item object.
  wValidate(item)
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.replace(pos, item)

proc isCheck*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of check item.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.isCheck(pos)

proc isRadio*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of radio item.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.isRadio(pos)

proc isSeparator*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of separator.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.isSeparator(pos)

proc isSubMenu*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of submenu.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.isSubMenu(pos)

proc enable*(self: wMenuBase, id: wCommandID, flag = true) {.validate.} =
  ## Enables or disables (greys out) a menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.enable(pos, flag)

proc disable*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Disables (greys out) a menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.disable(pos)

proc isEnabled*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is enabled.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.isEnabled(pos)

proc check*(self: wMenuBase, id: wCommandID, flag = true) {.validate.} =
  ## Checks or unchecks the menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.check(pos, flag)

proc isChecked*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is checked.
  let (menu, pos) = find(id)
  if menu != nil:
    result = menu.isChecked(pos)

proc toggle*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Toggle the menu item.
  let (menu, pos) = find(id)
  if menu != nil:
    menu.toggle(pos)
