#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

## These events are generated by wTreeCtrl.
#
## :Superclass:
##   `wCommandEvent <wCommandEvent.html>`_
#
## :Seealso:
##   `wTreeCtrl <wTreeCtrl.html>`_
#
## :Events:
##   ==============================  =============================================================
##   wTreeEvent                      Description
##   ==============================  =============================================================
##   wEvent_TreeBeginDrag            Begin dragging with the left mouse button. This event is
##                                   vetoed by default. Call allow() To enable dragging.
##   wEvent_TreeBeginRdrag           Begin dragging with the right mouse button. This event is
##                                   vetoed by default. Call allow() To enable dragging.
##   wEvent_TreeEndDrag              End dragging with the left or right mouse button.
##   wEvent_TreeBeginLabelEdit       Begin editing a label. This event can be vetoed.
##   wEvent_TreeEndLabelEdit         Finish editing a label. This event can be vetoed.
##   wEvent_TreeDeleteItem           An item was deleted.
##   wEvent_TreeItemActivated        The item has been activated (ENTER or double click).
##   wEvent_TreeItemCollapsed        The item has been collapsed.
##   wEvent_TreeItemCollapsing       The item is being collapsed. This event can be vetoed.
##   wEvent_TreeItemExpanded         The item has been expanded.
##   wEvent_TreeItemExpanding        The item is being expanded. This event can be vetoed.
##   wEvent_TreeItemRightClick       The user has clicked the item with the right mouse button.
##   wEvent_TreeSelChanged           Selection has changed.
##   wEvent_TreeSelChanging          Selection is changing. This event can be vetoed.
##   wEvent_TreeItemMenu             The context menu for the selected item has been requested,
##                                   either by a right click or by using the menu key.
##   ==============================  =============================================================

include ../pragma
import ../wBase

wEventRegister(wTreeEvent):
  wEvent_TreeFirst
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

method getItem*(self: wTreeEvent): wTreeItem {.property, inline, raises: [].} =
  ## Returns the item.
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = self.mHandle

method getOldItem*(self: wTreeEvent): wTreeItem {.property, inline, raises: [].} =
  ## Returns the old item (valid for wEvent_TreeSelChanging, wEvent_TreeSelChanged,
  ## and wEvent_TreeEndDrag events).
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = self.mOldHandle

method getText*(self: wTreeEvent): string {.property, inline.} =
  ## The (new) item label for wEvent_TreeEndLabelEdit event.
  result = self.mText

method getInsertMark*(self: wTreeEvent): int {.property, inline.} =
  ## Retrun insert mark position (valid for wEvent_TreeEndDrag event).
  result = self.mInsertMark

method getPoint*(self: wTreeEvent): wPoint {.property, inline.} =
  ## Returns the position of the mouse pointer if the event is a drag or menu-context event.
  result = self.mPoint
