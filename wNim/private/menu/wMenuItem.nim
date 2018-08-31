#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

## A menu item represents an item in a menu.

template withPosAtParentMenu(body: untyped) =
  mixin self
  if self.mParentMenu != nil:
    let pos {.inject.} = self.mParentMenu.find(self)
    if pos != wNotFound:
      body

proc getMenu*(self: wMenuItem): wMenu {.validate, property, inline.} =
  ## Returns the menu this item is in, or NULL if this item is not attached.
  result = mParentMenu

proc getKind*(self: wMenuItem): wMenuItemKind {.validate, property, inline.} =
  ## Returns the item kind, one of wMenuItemNormal, wMenuItemCheck,
  ## wMenuItemRadio, wMenuItemSeparator, or wMenuItemSubMenu.
  result = mKind

proc getSubMenu*(self: wMenuItem): wMenu {.validate, property, inline.} =
  ## Returns the submenu for the menu item, or nil if there isn't one.
  result = mSubmenu

proc getText*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the text for the menu item.
  result = mText

proc getLabel*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the text for the menu item.
  result = mText

proc setText*(self: wMenuItem, text: string) {.validate, property.} =
  ## Sets the text for the menu item.
  wValidate(text)
  withPosAtParentMenu:
    mParentMenu.setText(pos, text)

proc setLabel*(self: wMenuItem, text: string) {.validate, property.} =
  ## Sets the text for the menu item.
  wValidate(text)
  setText(text)

proc getLabelText*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the text for the menu item, not include any accelerator characters.
  mText.replace("&", "")

proc getHelp*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the help string.
  result = mHelp

proc setHelp*(self: wMenuItem, help: string) {.validate, property, inline.} =
  ## Sets the help string.
  mHelp = help

proc getBitmap*(self: wMenuItem): wBitmap {.validate, property, inline.} =
  ## Returns the bitmap.
  result = mBitmap

proc setBitmap*(self: wMenuItem, bitmap: wBitmap = nil) {.validate, property.} =
  ## Sets the bitmap for the menu item, nil for clear the bitmap.
  withPosAtParentMenu:
    mParentMenu.setBitmap(pos, bitmap)

proc getId*(self: wMenuItem): wCommandID {.validate, property, inline.} =
  ## Returns the menu item identifier.
  result = mId

proc setId*(self: wMenuItem, id: wCommandID) {.validate, property.} =
  ## Sets the id for the menu item.
  withPosAtParentMenu:
    mParentMenu.setId(pos, id)

proc isCheck*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of check item.
  result = mKind == wMenuItemCheck

proc isRadio*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of radio item.
  result = mKind == wMenuItemRadio

proc isSeparator*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of separator.
  result = mKind == wMenuItemSeparator

proc isSubMenu*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of submenu.
  result = mSubmenu != nil

proc enable*(self: wMenuItem, flag = true) {.validate.} =
  ## Enables or disables (greys out) a menu item.
  withPosAtParentMenu:
    mParentMenu.enable(pos, flag)

proc disable*(self: wMenuItem) {.validate, inline.} =
  ## Disables (greys out) a menu item.
  enable(false)

proc isEnabled*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is enabled.
  withPosAtParentMenu:
    result = mParentMenu.isEnabled(pos)

proc check*(self: wMenuItem, flag = true) {.validate.} =
  ## Checks or unchecks the menu item.
  withPosAtParentMenu:
    mParentMenu.check(pos, flag)

proc isChecked*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is checked.
  withPosAtParentMenu:
    result = mParentMenu.isChecked(pos)

proc toggle*(self: wMenuItem) {.validate.} =
  ## Toggle the menu item.
  withPosAtParentMenu:
    mParentMenu.toggle(pos)

proc MenuItem*(id: wCommandID = 0, text: string = nil, help: string = nil,
    kind = wMenuItemNormal, bitmap: wBitmap = nil, submenu: wMenu = nil): wMenuItem
    {.inline.} =
  ## Constructor.
  result = wMenuItem(mId: id, mText: text, mHelp: help, mKind: kind,
    mBitmap: bitmap, mSubmenu: submenu)
