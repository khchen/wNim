
const
  wNotFound* = -1

  # ToolBar or Menuitem kind
  wItemNormal* = TBSTYLE_BUTTON
  wItemSeparator* = TBSTYLE_SEP
  wItemCheck* = TBSTYLE_CHECK
  wItemRadio* = TBSTYLE_CHECKGROUP
  wItemDropDown* = BTNS_WHOLEDROPDOWN
  wItemSubMenu* = wItemDropDown

  # Direction
  wLeft* = 0x0010
  wRight* = 0x0020
  wUp* = 0x0040
  wDown* = 0x0080
  wTop* = wUp
  wBottom* = wDown
  wNorth* = wUp
  wSouth* = wDown
  wWest* = wLeft
  wEast* = wRight
  wHorizontal* = wLeft
  wVertical* = wUp
  wBoth* = wHorizontal or wVertical
  wCenter* = wLeft or wRight
  wMiddle* = wUp or wDown

