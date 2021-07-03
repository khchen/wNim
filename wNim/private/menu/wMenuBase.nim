#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## wMenuBase is the super class of wMenuBar and wMenu.
## It means the functions here work with both menubar and menu.
#
## :Subclasses:
##   `wMenuBar <wMenuBar.html>`_
##   `wMenu <wMenu.html>`_

include ../pragma
import ../wBase, wMenu

proc getHandle*(self: wMenuBase): HMENU {.validate, property, inline.} =
  ## Get system handle of this menu.
  result = self.mHmenu

proc getCount*(self: wMenuBase): int {.validate, property, inline.} =
  ## Returns number of items in a menu or number of menus in a menubar.
  result = GetMenuItemCount(self.mHmenu)

proc find*(self: wMenuBase, id: wCommandID): tuple[menu: wMenu, pos: int]
    {.validate.} =
  ## Return the tuple (menu, pos) indicate a item with the given id,
  ## (nil, wNotFound(-1)) if not found.
  if self of wBase.wMenuBar:
    let menuBar = wBase.wMenuBar(self)
    for topMenu in menuBar.mMenuList:
      result = find(topMenu, id)
      if result.menu != nil: # found !!
        return

  elif self of wBase.wMenu:
    let menu = wBase.wMenu(self)
    for i, item in menu.mItemList: # level fist, deep later
      if item.mId == id: # found !!
        return (menu, i)

    for item in menu.mItemList:
      if item.mSubmenu != nil:
        result = find(item.mSubmenu, id)
        if result.menu != nil: # found !!
          return

template withMenuPos(id: wCommandID, body: untyped) =
  mixin self
  let tup = self.find(id)
  let menu {.inject.} = tup.menu
  let pos {.inject.} = tup.pos
  if menu != nil:
    body

proc findItem*(self: wMenuBase, id: wCommandID): wMenuItem {.validate.} =
  ## Search the first wMenuItem object with the given id, nil if not found.
  withMenuPos(id):
    result = menu.mItemList[pos]

proc remove*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Removes the menu item from the menu.
  ## If the item is a submenu, it will not be deleted.
  ## Use destroy() if you want to delete a submenu.
  withMenuPos(id):
    menu.remove(pos)

proc delete*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Deletes the menu item from the menu. Same as remove().
  withMenuPos(id):
    menu.delete(pos)

proc destroy*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Destroy the menu item from the menu.
  ## If the item is a submenu, it will be deleted.
  ## Use remove() if you want to keep the submenu.
  withMenuPos(id):
    menu.destroy(pos)

proc getKind*(self: wMenuBase, id: wCommandID): wMenuItemKind
    {.validate, property.} =
  ## Returns the item kind,
  ## one of wMenuItemNormal, wMenuItemCheck,  wMenuItemRadio, wMenuItemSeparator, or wMenuItemSubMenu.
  withMenuPos(id):
    result = menu.getKind(pos)

proc getSubMenu*(self: wMenuBase, id: wCommandID): wMenu {.validate, property.} =
  ## Returns the submenu for the menu item, or nil if there isn't one.
  withMenuPos(id):
    result = menu.getSubMenu(pos)

proc getText*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the text for the menu item.
  withMenuPos(id):
    result = menu.getText(pos)

proc getLabel*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the text for the menu item.
  withMenuPos(id):
    result = menu.getLabel(pos)

proc setText*(self: wMenuBase, id: wCommandID, text: string) {.validate, property.} =
  ## Sets the text for the menu item at the position.
  withMenuPos(id):
    menu.setText(pos, text)

proc setLabel*(self: wMenuBase, id: wCommandID, text: string) {.validate, property.} =
  ## Sets the text for the menu item.
  withMenuPos(id):
    menu.setLabel(pos, text)

proc getLabelText*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the text for the menu item,
  ## not include any accelerator characters.
  withMenuPos(id):
    result = menu.getLabelText(pos)

proc getHelp*(self: wMenuBase, id: wCommandID): string {.validate, property.} =
  ## Returns the help string for the menu item.
  withMenuPos(id):
    result = menu.getHelp(pos)

proc setHelp*(self: wMenuBase, id: wCommandID, help: string) {.validate, property.} =
  ## Sets the help string of item.
  withMenuPos(id):
    menu.setHelp(pos, help)

proc getBitmap*(self: wMenuBase, id: wCommandID): wBitmap {.validate, property.} =
  ## Returns the bitmap of item.
  withMenuPos(id):
    result = menu.getBitmap(pos)

proc setBitmap*(self: wMenuBase, id: wCommandID, bitmap: wBitmap = nil)
    {.validate, property.} =
  ## Sets the bitmap for the menu item, nil for clear the bitmap.
  withMenuPos(id):
    menu.setBitmap(pos, bitmap)

proc setId*(self: wMenuBase, id: wCommandID, newid: wCommandID)
    {.validate, property.} =
  ## Sets the id for the menu item.
  withMenuPos(id):
    menu.setId(pos, newid)

proc replace*(self: wMenuBase, id: wCommandID, text = "", help = "",
    bitmap: wBitmap = nil, submenu: wMenu = nil,
    kind = wMenuItemNormal): wMenuItem {.validate, discardable.} =
  ## Replaces the menu item with another one.
  ## Return the new menu item object.
  withMenuPos(id):
    result = menu.replace(pos, id, text, help, bitmap, submenu, kind)

proc replace*(self: wMenuBase, id: wCommandID, item: wMenuItem): wMenuItem
    {.validate, discardable.} =
  ## Replaces the menu item with another one.
  ## Return the new menu item object.
  wValidate(item)
  withMenuPos(id):
    result = menu.replace(pos, item)

proc isCheck*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of check item.
  withMenuPos(id):
    result = menu.isCheck(pos)

proc isRadio*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of radio item.
  withMenuPos(id):
    result = menu.isRadio(pos)

proc isSeparator*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of separator.
  withMenuPos(id):
    result = menu.isSeparator(pos)

proc isSubMenu*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is a kind of submenu.
  withMenuPos(id):
    result = menu.isSubMenu(pos)

proc enable*(self: wMenuBase, id: wCommandID, flag = true) {.validate.} =
  ## Enables or disables (greys out) a menu item.
  withMenuPos(id):
    menu.enable(pos, flag)

proc disable*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Disables (greys out) a menu item.
  withMenuPos(id):
    menu.disable(pos)

proc isEnabled*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is enabled.
  withMenuPos(id):
    result = menu.isEnabled(pos)

proc check*(self: wMenuBase, id: wCommandID, flag = true) {.validate.} =
  ## Checks or unchecks the menu item.
  withMenuPos(id):
    menu.check(pos, flag)

proc isChecked*(self: wMenuBase, id: wCommandID): bool {.validate.} =
  ## Determines whether a menu item is checked.
  withMenuPos(id):
    result = menu.isChecked(pos)

proc toggle*(self: wMenuBase, id: wCommandID) {.validate.} =
  ## Toggle the menu item.
  withMenuPos(id):
    menu.toggle(pos)

proc MenuBase*(hMenu: HMENU): wMenuBase {.inline.} =
  ## Return the wMenuBase object of specific hMenu handle or nil if not exists.
  ## Notice: This is not a constructor and for low level use only.
  result = wAppGetMenuBase(hMenu)
