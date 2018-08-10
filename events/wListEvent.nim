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
  wEvent_ListItemMiddleClick
  wEvent_ListItemRightClick
  wEvent_ListKeyDown
  wEvent_ListInsertItem
  wEvent_ListColClick
  wEvent_ListColRightClick
  wEvent_ListColBeginDrag
  wEvent_ListColDragging
  wEvent_ListColEndDrag
  wEvent_ListColBeginMove
  wEvent_ListColEndMove
  wEvent_ListitemChecked
  wEvent_ListitemUnchecked
  wEvent_ListLast

proc isListEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_ListFirst..wEvent_ListLast
