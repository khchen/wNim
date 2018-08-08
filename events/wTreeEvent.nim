DefineIncrement(wEvent_TreeFirst):
  wEvent_TreeBeginDrag
  wEvent_TreeBeginRdrag
  wEvent_TreeEndDrag
  wEvent_TreeBeginLabelEdit
  wEvent_TreeEndLabelEdit
  wEvent_TreeDeleteItem
  wEvent_TreeGetInfo
  wEvent_TreeSetInfo
  wEvent_TreeItemActivated
  wEvent_TreeItemCollapsed
  wEvent_TreeItemCollapsing
  wEvent_TreeItemExpanded
  wEvent_TreeItemExpanding
  wEvent_TreeItemRightClick
  wEvent_TreeItemMiddleClick
  wEvent_TreeSelChanged
  wEvent_TreeSelChanging
  wEvent_TreeKeyDown
  wEvent_TreeItemGetTooltip
  wEvent_TreeItemMenu
  wEvent_TreeStateImageClick
  wEvent_TreeLast

proc isTreeEvent(msg: UINT): bool {.inline.} =
  msg.isBetween(wEvent_TreeFirst, wEvent_TreeLast)
