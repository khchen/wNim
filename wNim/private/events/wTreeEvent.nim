#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

DefineIncrement(wEvent_TreeFirst):
  wEvent_TreeBeginDrag
  wEvent_TreeBeginRdrag
  wEvent_TreeEndDrag
  wEvent_TreeBeginLabelEdit
  wEvent_TreeEndLabelEdit
  wEvent_TreeDeleteItem
  wEvent_TreeItemActivated
  wEvent_TreeItemCollapsed
  wEvent_TreeItemCollapsing
  wEvent_TreeItemExpanded
  wEvent_TreeItemExpanding
  wEvent_TreeItemRightClick
  wEvent_TreeSelChanged
  wEvent_TreeSelChanging
  wEvent_TreeItemMenu
  wEvent_TreeLast

proc isTreeEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_TreeFirst..wEvent_TreeLast

method getItem*(self: wTreeEvent): wTreeItem {.property, inline.} =
  ## Returns the item.
  result.mTreeCtrl = mTreeCtrl
  result.mHandle = mHandle

method getOldItem*(self: wTreeEvent): wTreeItem {.property, inline.} =
  ## Returns the old item (valid for wEvent_TreeSelChanging and wEvent_TreeSelChanged events).
  result.mTreeCtrl = mTreeCtrl
  result.mHandle = mOldHandle

method getText*(self: wTreeEvent): string {.property, inline.} =
  ## The (new) item label for wEvent_TreeEndLabelEdit event.
  result = mText

method getInsertMark*(self: wTreeEvent): int {.property, inline.} =
  ## Retrun insert mark position (valid for wEvent_TreeEndDrag event).
  result = mInsertMark

method getPoint*(self: wTreeEvent): wPoint {.property, inline.} =
  ## Returns the position of the mouse pointer if the event is a drag or menu-context event.
  result = mPoint

