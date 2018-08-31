#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

DefineIncrement(wEvent_ListFirst):
  wEvent_ListBeginDrag
  wEvent_ListBeginRightDrag
  wEvent_ListBeginLabelEdit
  wEvent_ListEndLabelEdit
  wEvent_ListDeleteItem
  wEvent_ListDeleteAllItems
  wEvent_ListItemFocused
  wEvent_ListItemSelected
  wEvent_ListItemDeselected
  wEvent_ListItemActivated
  wEvent_ListItemRightClick
  wEvent_ListItemChecked
  wEvent_ListItemUnchecked
  wEvent_ListInsertItem
  wEvent_ListColClick
  wEvent_ListColRightClick
  wEvent_ListColBeginDrag
  wEvent_ListColDragging
  wEvent_ListColEndDrag
  wEvent_ListColBeginMove
  wEvent_ListColEndMove
  wEvent_ListLast

proc isListEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_ListFirst..wEvent_ListLast

method getIndex*(self: wListEvent): int {.property, inline.} =
  ## The item index.
  result = mIndex

method getColumn*(self: wListEvent): int {.property, inline.} =
  ## The column position.
  result = mCol

method getText*(self: wListEvent): string {.property, inline.} =
  ## The (new) item label for wEvent_ListEndLabelEdit event.
  result = mText

