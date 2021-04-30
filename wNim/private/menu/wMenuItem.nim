#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A menu item represents an item in a menu.
#
## :Seealso:
##   `wMenu <wMenu.html>`_
##   `wMenuBar <wMenuBar.html>`_

include ../pragma
import strutils
import ../wBase

# For recursive module dependencies
proc MenuItem*(id: wCommandID = wIdAny, text = "", help = "",
    kind = wMenuItemNormal, bitmap: wBitmap = nil,
    submenu: wMenu = nil): wMenuItem {.inline.}

import wMenu
export wMenu

template withPosAtParentMenu(body: untyped) =
  mixin self
  for menuBase in wAppMenuBase():
    if menuBase of wMenu:
      let parent {.inject.} = wMenu(menuBase)
      let pos {.inject.} = parent.find(self)

      if pos != wNotFound:
        body
        break

proc getMenu*(self: wMenuItem): wMenu {.validate, property, inline.} =
  ## Returns the menu this item is in, or NULL if this item is not attached.
  withPosAtParentMenu:
    result = parent

proc getKind*(self: wMenuItem): wMenuItemKind {.validate, property, inline.} =
  ## Returns the item kind, one of wMenuItemNormal, wMenuItemCheck,
  ## wMenuItemRadio, wMenuItemSeparator, or wMenuItemSubMenu.
  result = self.mKind

proc getSubMenu*(self: wMenuItem): wMenu {.validate, property, inline.} =
  ## Returns the submenu for the menu item, or nil if there isn't one.
  result = self.mSubmenu

proc getText*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the text for the menu item.
  result = self.mText

proc getLabel*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the text for the menu item.
  result = self.mText

proc setText*(self: wMenuItem, text: string) {.validate, property.} =
  ## Sets the text for the menu item.
  self.mText = text
  withPosAtParentMenu:
    parent.setText(pos, text)

proc setLabel*(self: wMenuItem, text: string) {.validate, property.} =
  ## Sets the text for the menu item.
  self.setText(text)

proc getLabelText*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the text for the menu item, not include any accelerator characters.
  self.mText.replace("&", "")

proc getHelp*(self: wMenuItem): string {.validate, property, inline.} =
  ## Returns the help string.
  result = self.mHelp

proc setHelp*(self: wMenuItem, help: string) {.validate, property, inline.} =
  ## Sets the help string.
  self.mHelp = help

proc getBitmap*(self: wMenuItem): wBitmap {.validate, property, inline.} =
  ## Returns the bitmap.
  result = self.mBitmap

proc setBitmap*(self: wMenuItem, bitmap: wBitmap = nil) {.validate, property.} =
  ## Sets the bitmap for the menu item, nil for clear the bitmap.
  self.mBitmap = bitmap
  withPosAtParentMenu:
    parent.setBitmap(pos, bitmap)

proc getId*(self: wMenuItem): wCommandID {.validate, property, inline.} =
  ## Returns the menu item identifier.
  result = self.mId

proc setId*(self: wMenuItem, id: wCommandID) {.validate, property.} =
  ## Sets the id for the menu item.
  self.mId = id
  withPosAtParentMenu:
    parent.setId(pos, id)

proc getData*(self: wMenuItem): int {.validate, property, inline.} =
  ## Returns the data associated with the item.
  result = self.mData

proc setData*(self: wMenuItem, data: int) {.validate, property.} =
  ## Sets the item associated data.
  self.mData = data

proc isCheck*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of check item.
  result = self.mKind == wMenuItemCheck

proc isRadio*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of radio item.
  result = self.mKind == wMenuItemRadio

proc isSeparator*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of separator.
  result = self.mKind == wMenuItemSeparator

proc isSubMenu*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is a kind of submenu.
  result = self.mSubmenu != nil

proc enable*(self: wMenuItem, flag = true) {.validate.} =
  ## Enables or disables (greys out) a menu item.
  withPosAtParentMenu:
    parent.enable(pos, flag)

proc disable*(self: wMenuItem) {.validate, inline.} =
  ## Disables (greys out) a menu item.
  self.enable(false)

proc isEnabled*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is enabled.
  withPosAtParentMenu:
    result = parent.isEnabled(pos)

proc check*(self: wMenuItem, flag = true) {.validate.} =
  ## Checks or unchecks the menu item.
  withPosAtParentMenu:
    parent.check(pos, flag)

proc isChecked*(self: wMenuItem): bool {.validate.} =
  ## Determines whether a menu item is checked.
  withPosAtParentMenu:
    result = parent.isChecked(pos)

proc toggle*(self: wMenuItem) {.validate.} =
  ## Toggle the menu item.
  withPosAtParentMenu:
    parent.toggle(pos)

proc detach*(self: wMenuItem) {.validate.} =
  ## Detach a menu item from all menu.
  withPosAtParentMenu:
    parent.remove(pos)

wClass(wMenuItem):

  proc init*(self: wMenuItem, id: wCommandID = wIdAny, text = "", help = "",
      kind = wMenuItemNormal, bitmap: wBitmap = nil, submenu: wMenu = nil)
      {.validate.} =
    ## Initializer.
    if id.int notin 0..0xffff and id != wIdAny:
      raise newException(wError, "Menu ID out of range")

    if kind != wMenuItemSeparator:
      self.mId = if id == wIdAny: wCommandID wAppNextMenuId() else: id
    else:
      self.mId = wIdAny

    self.mText = text
    self.mHelp = help
    self.mKind = kind
    self.mBitmap = bitmap
    self.mSubmenu = submenu
    wAppInclMenuId(uint16 self.mId)
