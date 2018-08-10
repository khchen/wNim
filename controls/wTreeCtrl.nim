
# there is too much work to do to support multiple selection in windows treeview
# so this code just don't consider it and of couse don't support it

# for "single selection treeview", a focused item is selected, vice versa
#   setFocusedItem() = selectItem(): set focus, select, ensure visible, unselect others
#   getFocusedItem(): get the focused item, this item may not selected

#   setSelection(): set select state for an item, this may broken "single selection"
#   getSelections(): get the selected items

# for wTreeItem

proc newTreeItem(self: wTreeItem, handle: HTREEITEM): wTreeItem =
  result = wTreeItem(mTreeCtrl: mTreeCtrl, mHandle: handle)

proc isOk*(self: wTreeItem): bool =
  result = (mHandle != 0)

proc unset*(self: wTreeItem) =
  mHandle = 0

proc getHandle*(self: wTreeItem): HTREEITEM =
  result = mHandle

proc getTreeCtrl*(self: wTreeItem): wTreeCtrl =
  result = mTreeCtrl

proc getParent*(self: wTreeItem): wTreeItem =
  result = newTreeItem(SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_PARENT, mHandle).HTREEITEM)

proc getFirstChild*(self: wTreeItem): wTreeItem =
  result = newTreeItem(SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_CHILD, mHandle).HTREEITEM)

proc getPrevSibling*(self: wTreeItem): wTreeItem =
  result = newTreeItem(SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_PREVIOUS, mHandle).HTREEITEM)

proc getNextSibling*(self: wTreeItem): wTreeItem =
  result = newTreeItem(SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_NEXT, mHandle).HTREEITEM)

proc getLastChild*(self: wTreeItem): wTreeItem =
  var hItem = SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_CHILD, mHandle).HTREEITEM
  var hLast: HTREEITEM = 0

  while hItem != 0:
    hLast = hItem
    hItem = SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_NEXT, hItem).HTREEITEM

  result = newTreeItem(hLast)

proc getChildrenCount*(self: wTreeItem, recursively = true): int =
  var child = getFirstChild()
  while child.isOk():
    result.inc
    if recursively:
      result.inc(child.getChildrenCount(true))
    child = child.getNextSibling()

proc len*(self: wTreeItem): int =
  result = getChildrenCount(false)

iterator items*(self: wTreeItem): wTreeItem =
  var item = getFirstChild()
  while item.isOk():
    yield item
    item = item.getNextSibling()

iterator allItems*(self: wTreeItem): wTreeItem =
  var node = self
  block loop:
    while true:
      let child = node.getFirstChild()
      if child.isOk():
        node = child
      else:
        while true:
          if node.mHandle == mHandle:
            # this will happen if
            #   1. self(root) has no child
            #   2. getParent() reach self(root)
            break loop

          let sibling = node.getNextSibling()
          if sibling.isOk():
            node = sibling
            break

          node = node.getParent()

      yield node

proc addChildren(self: wTreeItem, children: var seq[wTreeItem], recursively = false) =
  for item in items():
    children.add(item)
    if recursively:
      item.addChildren(children, true)

proc getChildren*(self: wTreeItem): seq[wTreeItem] =
  newSeq(result, 0)
  addChildren(result, false)

proc getAllChildren*(self: wTreeItem): seq[wTreeItem] =
  newSeq(result, 0)
  addChildren(result, true)

proc items*(self: wTreeItem): seq[wTreeItem] =
  # alias for getChildren
  result = getChildren()

proc allItems*(self: wTreeItem): seq[wTreeItem] =
  # alias for getAllChildren
  result = getAllChildren()

proc set*(self: wTreeItem, text: string = nil, image = wTreeIgnore, selImage = wTreeIgnore, state = 0, flag = true) =
  var tvitem: TVITEM
  tvitem.mask = TVIF_HANDLE
  tvitem.hItem = mHandle

  if text != nil:
    tvitem.mask = tvitem.mask or TVIF_TEXT
    tvitem.pszText = &(T(text))

  if image != wTreeIgnore:
    tvitem.mask = tvitem.mask or TVIF_IMAGE
    tvitem.iImage = image.int32

  if image != wTreeIgnore:
    tvitem.mask = tvitem.mask or TVIF_SELECTEDIMAGE
    tvitem.iSelectedImage = selImage.int32

  if state != 0:
    tvitem.mask = tvitem.mask or TVIF_STATE
    tvitem.stateMask = state.int32
    tvitem.state = if flag: state.int32 else: 0

  SendMessage(mTreeCtrl.mHwnd, TVM_SETITEM, 0, addr tvitem)

proc setText*(self: wTreeItem, text: string) =
  set(text=text)

proc setBold*(self: wTreeItem, flag = true) =
  set(state=TVIS_BOLD, flag=flag)

proc setCut*(self: wTreeItem, flag = true) =
  set(state=TVIS_CUT, flag=flag)

proc setSelection*(self: wTreeItem, flag = true) =
  # just change the select state
  # this will broken single selection states, don't use this
  set(state=TVIS_SELECTED, flag=flag)

proc setDropHighlight*(self: wTreeItem, flag = true) =
  set(state=TVIS_DROPHILITED, flag=flag)

proc select*(self: wTreeItem) =
  # select, focus, and ensure visible of the item, also unselect others
  SendMessage(mTreeCtrl.mHwnd, TVM_SELECTITEM, TVGN_CARET, mHandle)

proc scrollTo*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_SELECTITEM, TVGN_FIRSTVISIBLE, mHandle)

proc unselect*(self: wTreeItem) =
  setSelection(false)

proc setImage*(self: wTreeItem, image = wTreeIgnore, selImage = wTreeIgnore) =
  var
    image = image
    selImage = selImage

  if image != wTreeIgnore and selImage == wTreeIgnore:
    # the same image is used for both
    selImage = image

  set(image=image, selImage=selImage)

proc setData*(self: wTreeItem, data: int) =
  var tvitem: TVITEM
  tvitem.mask = TVIF_PARAM or TVIF_HANDLE
  tvitem.hItem = mHandle
  tvitem.lParam = cast[LPARAM](data)
  SendMessage(mTreeCtrl.mHwnd, TVM_SETITEM, 0, addr tvitem)

proc setState*(self: wTreeItem, state: range[0..15]) =
  # state is bits 12 ~ 15, state image is 1-based, 0 for no state image
  var tvitem: TVITEM
  tvitem.mask = TVIF_STATE or TVIF_HANDLE
  tvitem.hItem = mHandle
  tvitem.state = INDEXTOSTATEIMAGEMASK(state.int32)
  tvitem.stateMask = TVIS_STATEIMAGEMASK
  SendMessage(mTreeCtrl.mHwnd, TVM_SETITEM, 0, addr tvitem)

proc setHasChildren*(self: wTreeItem, flag = true) =
  var tvitem: TVITEM
  tvitem.mask = TVIF_CHILDREN or TVIF_HANDLE
  tvitem.hItem = mHandle
  tvitem.cChildren = if flag: 1 else: 0
  SendMessage(mTreeCtrl.mHwnd, TVM_SETITEM, 0, addr tvitem)

proc expand*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_EXPAND, TVE_EXPAND, mHandle)

proc collapse*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_EXPAND, TVE_COLLAPSE, mHandle)

proc collapseAndReset*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_EXPAND, TVE_COLLAPSE or TVE_COLLAPSERESET, mHandle)

proc toggle*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_EXPAND, TVE_TOGGLE, mHandle)

proc setFocused*(self: wTreeItem) =
  select()

proc getText*(self: wTreeItem): string =
  # var
  #   pbuffer = allocWString(65536)
  #   buffer = cast[wstring](pbuffer)
  # defer: dealloc(pbuffer)
  var buffer = T(65536)

  var tvitem: TVITEM
  tvitem.mask = TVIF_TEXT or TVIF_HANDLE
  tvitem.hItem = mHandle
  tvitem.cchTextMax = 65536
  tvitem.pszText = &buffer
  if SendMessage(mTreeCtrl.mHwnd, TVM_GETITEM, 0, addr tvitem) != 0:
    # buffer.setLen(lstrlen(&buffer))
    buffer.nullTerminate
    result = $buffer

proc get(self: wTreeItem): TVITEM =
  result.mask = TVIF_HANDLE or TVIF_STATE or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE or TVIF_CHILDREN
  result.hItem = mHandle
  result.stateMask = 0xFFFFFFFF'i32
  discard SendMessage(mTreeCtrl.mHwnd, TVM_GETITEM, 0, addr result)

proc isBold*(self: wTreeItem): bool =
  let tvitem = get()
  result = (tvitem.state and TVIS_BOLD) != 0

proc isCut*(self: wTreeItem): bool =
  let tvitem = get()
  result = (tvitem.state and TVIS_CUT) != 0

proc isDropHighlight*(self: wTreeItem): bool =
  let tvitem = get()
  result = (tvitem.state and TVIS_DROPHILITED) != 0

proc isSelected*(self: wTreeItem): bool =
  let tvitem = get()
  result = (tvitem.state and TVIS_SELECTED) != 0

proc isExpanded*(self: wTreeItem): bool =
  let tvitem = get()
  result = (tvitem.state and TVIS_EXPANDED) != 0

proc isFocused*(self: wTreeItem): bool =
  result = SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_CARET, 0).HTREEITEM == mHandle

proc getImage*(self: wTreeItem, witch = wTreeItemIconNormal): int =
  let tvitem = get()
  if witch == wTreeItemIconSelected:
    result = tvitem.iSelectedImage.int
  else:
    result = tvitem.iImage.int

proc getSelImage*(self: wTreeItem): int =
  result = getImage(wTreeItemIconSelected)

proc getData*(self: wTreeItem): int =
  let tvitem = get()
  result = cast[int](tvitem.lParam)

proc getState*(self: wTreeItem): int =
  template STATEIMAGEMASKTOINDEX(i: int32): int32 = (i and TVIS_STATEIMAGEMASK) shr 12
  let tvitem = get()
  result = STATEIMAGEMASKTOINDEX(tvitem.state).int

proc hasChildren*(self: wTreeItem): bool =
  let tvitem = get()
  result = tvitem.cChildren != 0

proc expandAllChildren*(self: wTreeItem) =
  expand()

  var child = getFirstChild()
  while child.isOk():
    child.expandAllChildren()
    child = child.getNextSibling()

proc collapseAllChildren*(self: wTreeItem) =
  collapse()

  var child = getFirstChild()
  while child.isOk():
    child.collapseAllChildren()
    child = child.getNextSibling()

proc getRawRect(self: wTreeItem, r: var RECT, textOnly = false): bool =
  cast[ptr HTREEITEM](addr r)[] = mHandle
  result = SendMessage(mTreeCtrl.mHwnd, TVM_GETITEMRECT, textOnly, addr r) != 0

proc getBoundingRect*(self: wTreeItem, rect: var wRect, textOnly = false): bool =
  var r: RECT
  if getRawRect(r, textOnly):
    rect = toWRect(r)
    result = true
  else:
    result = false

proc getBoundingRect*(self: wTreeItem, textOnly = false): wRect =
  if not getBoundingRect(result, textOnly):
    result = wDefaultRect

proc isVisible*(self: wTreeItem): bool =
  var r: RECT
  if not getRawRect(r, true):
    return false

  result = r.bottom > 0 and r.top < mTreeCtrl.getClientSize().height

proc getNextVisible*(self: wTreeItem): wTreeItem =
  result = newTreeItem(SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_NEXTVISIBLE, mHandle).HTREEITEM)

  # TVGN_NEXTVISIBLE return all non-collapsed item
  if result.isOk() and not result.isVisible():
    result.unset()

proc getPrevVisible*(self: wTreeItem): wTreeItem =
  result = newTreeItem(SendMessage(mTreeCtrl.mHwnd, TVM_GETNEXTITEM, TVGN_PREVIOUSVISIBLE, mHandle).HTREEITEM)

  # TVGN_PREVIOUSVISIBLE return all non-collapsed item
  if result.isOk() and not result.isVisible():
    result.unset()

proc ensureVisible*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_ENSUREVISIBLE, 0, mHandle)

proc delete*(self: wTreeItem) =
  SendMessage(mTreeCtrl.mHwnd, TVM_DELETEITEM, 0, mHandle)

proc deleteChildren*(self: wTreeItem) =
  for item in getChildren():
    delete item

proc toggleSelection*(self: wTreeItem) =
  setSelection(not isSelected())

proc selectChildren*(self: wTreeItem) =
  for item in items():
    item.setSelection(true)

proc sortChildren*(self: wTreeItem) =
  # sort children by item text (lstrcmpi)
  SendMessage(mTreeCtrl.mHwnd, TVM_SORTCHILDREN, 0, mHandle)

proc sortChildren*(self: wTreeItem, callback: proc (itemData1, itemData2, data: int): int, data: int = 0) =
  # sore children by item custom data
  var dataSort: wInternalDataSort
  dataSort.data = data
  dataSort.fn = callback

  var tvsortcb: TVSORTCB
  tvsortcb.hParent = mHandle
  tvsortcb.lpfnCompare = dataCompareFunc
  tvsortcb.lParam = cast[LPARAM](addr dataSort)

  SendMessage(mTreeCtrl.mHwnd, TVM_SORTCHILDRENCB, 0, addr tvsortcb)

type
  wInternalItemSort = object
    fn: proc (item1, item2: wTreeItem, data: int): int
    data: int
    store: seq[tuple[item: wTreeItem, data: int]]

proc itemCompareFunc(itemData1, itemData2, data: int): int =
  let pItemSort = cast[ptr wInternalItemSort](data)
  result = pItemSort[].fn(
    pItemSort[].store[itemData1].item,
    pItemSort[].store[itemData2].item,
    pItemSort[].data)

proc sortChildren*(self: wTreeItem, callback: proc (item1, item2: wTreeItem, data: int): int, data: int = 0) =
  # sore children by item object
  # notice: getData() result in sort compare function is invalid

  var itemSort: wInternalItemSort
  itemSort.data = data
  itemSort.fn = callback
  newSeq(itemSort.store, 0)

  # store old data, and set item data to index of store
  for item in items():
    let old = item.getData()
    item.setData(itemSort.store.len)
    itemSort.store.add((item, old))

  sortChildren(callback=itemCompareFunc, data=cast[int](addr itemSort))

  # restore the old data
  for tup in itemSort.store:
    tup.item.setData(tup.data)

# for wTreeCtrl, warp of wTreeItem method

proc getFirstChild*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getFirstChild()

proc getPrevSibling*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getPrevSibling()

proc getNextSibling*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getNextSibling()

proc getPrevVisible*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getPrevVisible()

proc getNextVisible*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getNextVisible()

proc getLastChild*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getLastChild()

proc getItemParent*(self: wTreeCtrl, item: wTreeItem): wTreeItem =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getParent()

proc getItemText*(self: wTreeCtrl, item: wTreeItem): string =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getText()

proc getItemData*(self: wTreeCtrl, item: wTreeItem): int =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getData()

proc getItemImage*(self: wTreeCtrl, item: wTreeItem, witch = wTreeItemIconNormal): int =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getImage(witch)

proc getItemSelImage*(self: wTreeCtrl, item: wTreeItem): int =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getSelImage()

proc getItemState*(self: wTreeCtrl, item: wTreeItem): int =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getState()

proc getChildrenCount*(self: wTreeCtrl, item: wTreeItem, recursively = true): int =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getChildrenCount(recursively)

proc getBoundingRect*(self: wTreeCtrl, item: wTreeItem, textOnly = false): wRect =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getBoundingRect(textOnly)

proc getBoundingRect*(self: wTreeCtrl, item: wTreeItem, rect: var wRect, textOnly = false): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getBoundingRect(rect, textOnly)

proc isBold*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isBold()

proc isCut*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isCut()

proc isDropHighlight*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isDropHighlight()

proc isSelected*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isSelected()

proc isExpanded*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isExpanded()

proc isFocused*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isFocused()

proc isVisible*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.isVisible()

proc itemHasChildren*(self: wTreeCtrl, item: wTreeItem): bool =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.hasChildren()

proc setItemText*(self: wTreeCtrl, item: wTreeItem, text: string) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setText(text)

proc setItemBold*(self: wTreeCtrl, item: wTreeItem, flag = true) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setBold(flag)

proc setItemCut*(self: wTreeCtrl, item: wTreeItem, flag = true) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setCut(flag)

proc setItemSelection*(self: wTreeCtrl, item: wTreeItem, flag = true) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setSelection(flag)

proc setItemDropHighlight*(self: wTreeCtrl, item: wTreeItem, flag = true) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setDropHighlight(flag)

proc setItemImage*(self: wTreeCtrl, item: wTreeItem, image = wTreeIgnore, selImage = wTreeIgnore) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setImage(image, selImage)

proc setItemData*(self: wTreeCtrl, item: wTreeItem, data: int) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setData(data)

proc setItemState*(self: wTreeCtrl, item: wTreeItem, state: range[0..15]) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setState(state)

proc setFocusedItem*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setFocused()

proc selectItem*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.select()

proc unselectItem*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.unselect()

proc scrollTo*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.scrollTo()

proc setItemHasChildren*(self: wTreeCtrl, item: wTreeItem, flag = true) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.setHasChildren(flag)

proc collapse*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.collapse()

proc collapseAllChildren*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.collapseAllChildren()

proc collapseAndReset*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.collapseAndReset()

proc expand*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.expand()

proc expandAllChildren*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.expandAllChildren()

proc ensureVisible*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.ensureVisible()

proc delete*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.delete()

proc deleteChildren*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.deleteChildren()

proc toggle*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.toggle()

proc toggleItemSelection*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.toggleSelection()

proc selectChildren*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.selectChildren()

proc sortChildren*(self: wTreeCtrl, item: wTreeItem) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.sortChildren()

proc sortChildren*(self: wTreeCtrl, item: wTreeItem, callback: proc (itemData1, itemData2, data: int): int, data: int = 0) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.sortChildren(callback=callback, data=data)

proc sortChildren*(self: wTreeCtrl, item: wTreeItem, callback: proc (item1, item2: wTreeItem, data: int): int, data: int = 0) =
  assert item.mTreeCtrl.mHwnd == mHwnd
  item.sortChildren(callback=callback, data=data)

proc getChildren*(self: wTreeCtrl, item: wTreeItem): seq[wTreeItem] =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getChildren()

proc getAllChildren*(self: wTreeCtrl, item: wTreeItem): seq[wTreeItem] =
  assert item.mTreeCtrl.mHwnd == mHwnd
  result = item.getAllChildren()

# for wTreeCtrl

proc newTreeItem(self: wTreeCtrl, handle: HTREEITEM): wTreeItem =
  result = wTreeItem(mTreeCtrl: self, mHandle: handle)

proc getFirstRoot*(self: wTreeCtrl): wTreeItem =
  result = newTreeItem(SendMessage(mHwnd, TVM_GETNEXTITEM, TVGN_ROOT, 0).HTREEITEM)

proc getRootItem*(self: wTreeCtrl): wTreeItem =
  result = getFirstRoot()

proc getFirstVisibleItem*(self: wTreeCtrl): wTreeItem =
  result = newTreeItem(SendMessage(mHwnd, TVM_GETNEXTITEM, TVGN_FIRSTVISIBLE, 0).HTREEITEM)

proc getFocusedItem*(self: wTreeCtrl): wTreeItem =
  result = newTreeItem(SendMessage(mHwnd, TVM_GETNEXTITEM, TVGN_CARET, 0).HTREEITEM)

proc getSelections*(self: wTreeCtrl): seq[wTreeItem] =
  newSeq(result, 0)
  var root = getFirstRoot()
  while root.isOk():
    if root.isSelected():
      result.add(root)

    for item in root.allItems():
      if item.isSelected():
        result.add(item)
    root = root.getNextSibling()

proc unselectAll*(self: wTreeCtrl) =
  for item in getSelections():
    item.unselect()

proc expandAll*(self: wTreeCtrl) =
  var root = getFirstRoot()
  while root.isOk():
    root.expandAllChildren()
    root = root.getNextSibling()

proc collapseAll*(self: wTreeCtrl) =
  var root = getFirstRoot()
  while root.isOk():
    root.collapseAllChildren()
    root = root.getNextSibling()

proc deleteAllItems*(self: wTreeCtrl) =
  SendMessage(mHwnd, TVM_DELETEITEM, 0, 0)

proc clearFocusedItem*(self: wTreeCtrl) =
  SendMessage(mHwnd, TVM_SELECTITEM, TVGN_CARET, 0)

proc getCount*(self: wTreeCtrl): int =
  result = SendMessage(mHwnd, TVM_GETCOUNT, 0, 0).int

proc len*(self: wTreeCtrl): int =
  result = getCount()

proc isEmpty*(self: wTreeCtrl): bool =
  result = getCount() == 0

# cookie version of getFirstChild, getFirstChild
proc getFirstChild*(self: wTreeCtrl, item: wTreeItem, cookie: var int): wTreeItem =
  result = self.getFirstChild(item)
  cookie = result.mHandle

proc getNextChild*(self: wTreeCtrl, cookie: var int): wTreeItem =
  result = newTreeItem(SendMessage(mHwnd, TVM_GETNEXTITEM, TVGN_NEXT, cookie).HTREEITEM)
  cookie = result.mHandle

proc insertItem(self: wTreeCtrl, parent, after: HTREEITEM, text: string, image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =
  var insert: TVINSERTSTRUCT
  insert.hParent = parent
  insert.hInsertAfter = after
  insert.item.mask = TVIF_TEXT or TVIF_PARAM
  insert.item.pszText = &(T(text))
  insert.item.lParam = data.LPARAM

  var
    image = image
    selImage = selImage

  if image != wTreeIgnore and selImage == wTreeIgnore:
    # the same image is used for both
    selImage = image

  if image != wTreeIgnore:
    insert.item.mask = insert.item.mask or TVIF_IMAGE
    insert.item.iImage = image.int32

  if selImage != wTreeIgnore:
    insert.item.mask = insert.item.mask or TVIF_SELECTEDIMAGE
    insert.item.iSelectedImage = selImage.int32

  result = newTreeItem(SendMessage(mHwnd, TVM_INSERTITEM, 0, addr insert).HTREEITEM)

proc addRoot*(self: wTreeCtrl, text: string, image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =
  result = insertItem(TVI_ROOT, TVI_ROOT, text, image, selImage, data)

proc appendItem*(self: wTreeCtrl, parent: wTreeItem, text: string, image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =
  assert parent.mTreeCtrl == self
  result = insertItem(parent.mHandle, TVI_LAST, text, image, selImage, data)

proc prependItem*(self: wTreeCtrl, parent: wTreeItem, text: string, image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =
  assert parent.mTreeCtrl == self
  result = insertItem(parent.mHandle, TVI_FIRST, text, image, selImage, data)

proc insertItem*(self: wTreeCtrl, parent, prev: wTreeItem, text: string, image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =
  assert parent.mTreeCtrl == self and prev.mTreeCtrl == self
  result = insertItem(parent.mHandle, prev.mHandle, text, image, selImage, data)

proc insertItem*(self: wTreeCtrl, parent: wTreeItem, pos: int, text: string, image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =
  assert parent.mTreeCtrl == self
  let hParent = parent.mHandle
  var after: HTREEITEM

  if pos < 0: # append to the end if pos < 0
    after = TVI_LAST

  elif pos == 0:
    after = TVI_FIRST

  else:
    var pos = pos
    var cur = parent.getFirstChild()
    while true:
      after = cur.mHandle
      pos.dec
      if pos == 0: break

      cur = cur.getNextSibling()
      if not cur.isOk():
        after = TVI_LAST
        break

  result = insertItem(hParent, after, text, image, selImage, data)

proc setImageList(self: wTreeCtrl, imageList: wImageList, which: int, owns: bool) =
  case which
  of TVSIL_NORMAL:
    mImageListNormal = imageList
    mOwnsImageListNormal = owns
  of TVSIL_STATE:
    mImageListState = imageList
    mOwnsImageListState = owns
  else: return
  SendMessage(mHwnd, TVM_SETIMAGELIST, which, imageList.mHandle)

proc setImageList*(self: wTreeCtrl, imageList: wImageList) =
  setImageList(imageList, TVSIL_NORMAL, owns=false)

proc setStateImageList*(self: wTreeCtrl, imageList: wImageList) =
  setImageList(imageList, TVSIL_STATE, owns=false)

proc assignImageList*(self: wTreeCtrl, imageList: wImageList) =
  setImageList(imageList, TVSIL_NORMAL, owns=true)

proc assignStateImageList*(self: wTreeCtrl, imageList: wImageList) =
  setImageList(imageList, TVSIL_STATE, owns=true)

proc getStateImageList*(self: wTreeCtrl): wImageList =
  result = mImageListNormal

proc getImageList*(self: wTreeCtrl): wImageList =
  result = mImageListState

proc getIndent*(self: wTreeCtrl): int =
  result = SendMessage(mHwnd, TVM_GETINDENT, 0, 0).int

proc setIndent*(self: wTreeCtrl, indent: int) =
  SendMessage(mHwnd, TVM_SETINDENT, indent, 0)

method setBackgroundColor*(self: wTreeCtrl, color: wColor) =
  procCall wWindow(self).setBackgroundColor(color)
  SendMessage(mHwnd, TVM_SETBKCOLOR, 0, color)

method setForegroundColor*(self: wTreeCtrl, color: wColor) =
  procCall wWindow(self).setForegroundColor(color)
  SendMessage(mHwnd, TVM_SETTEXTCOLOR, 0, color)

iterator items*(self: wTreeCtrl): wTreeItem =
  var item = getFirstRoot()
  while item.isOk():
    yield item
    item = item.getNextSibling()

iterator allItems*(self: wTreeCtrl): wTreeItem =
  var item = getFirstRoot()
  while item.isOk():
    yield item
    for subitem in item.allItems():
      yield subitem

    item = item.getNextSibling()

method getBestSize*(self: wTreeCtrl): wSize =
  result = getDefaultSize() # default size as minimal size

  var rect: wRect
  var scrollY = 0
  # todo: how to get scrollX ?

  if getFirstRoot().getBoundingRect(rect, textOnly=false):
    scrollY = -rect.y

  for item in allItems():
    if item.getBoundingRect(rect, textOnly=true):
      result.width = max(result.width, rect.x + rect.width + 5)
      result.height = max(result.height, rect.y + rect.height + scrollY + 5)

proc wTreeCtrlNotifyHandler(self: wTreeCtrl, code: INT, id: UINT_PTR, lparam: LPARAM, processed: var bool): LRESULT =
  var eventType: UINT = 0

  case code
  of TVN_ITEMEXPANDED:
    let pnmtv = cast[LPNMTREEVIEW](lparam)
    if pnmtv.action == TVE_EXPAND:
      eventType = wEvent_TreeItemExpanded
    elif pnmtv.action == TVE_COLLAPSE:
      eventType = wEvent_TreeItemCollapsed

  of TVN_ITEMEXPANDING:
    let pnmtv = cast[LPNMTREEVIEW](lparam)
    if pnmtv.action == TVE_EXPAND:
      eventType = wEvent_TreeItemExpanding
    elif pnmtv.action == TVE_COLLAPSE:
      eventType = wEvent_TreeItemCollapsing

  of TVN_ITEMCHANGED:
    let pnmtc = cast[ptr NMTVITEMCHANGE](lparam)
    if (pnmtc.uStateNew and TVIS_SELECTED) != (pnmtc.uStateOld and TVIS_SELECTED):
      eventType = wEvent_TreeSelChanged

  else: discard

  if eventType != 0:
    result = self.mMessageHandler(self, eventType, cast[WPARAM](id), lparam, processed)
  else:
    result = self.wControlNotifyHandler(code, id, lparam, processed)


proc wTreeCtrlInit(self: wTreeCtrl, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  # for TVS_HASBUTTONS, TVS_LINESATROOT must also be specified.
  var style = style
  if (style and wTrTwistButtons) != 0 or (style and TVS_HASBUTTONS) != 0:
    style = style or TVS_LINESATROOT or TVS_HASBUTTONS

  self.wControl.init(className=WC_TREEVIEW, parent=parent, id=id, label="", pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

  wTreeCtrl.setNotifyHandler(wTreeCtrlNotifyHandler)
  mKeyUsed = {wUSE_RIGHT, wUSE_LEFT, wUSE_UP, wUSE_DOWN, wUSE_ENTER}

  if (style and wTrTwistButtons) != 0:
    type SetWindowTheme = proc (hwnd: HWND, pszSubAppName: LPCWSTR, pszSubIdList: LPCWSTR): HRESULT {.stdcall.}
    let themeLib = loadLib("uxtheme.dll")
    let setWindowTheme = cast[SetWindowTheme](themeLib.checkedSymAddr("SetWindowTheme"))
    discard setWindowTheme(mHwnd, "Explorer", nil)

  systemConnect(WM_NCDESTROY) do (event: wEvent):
    if mOwnsImageListNormal: delete mImageListNormal
    if mOwnsImageListState:  delete mImageListState
    mImageListNormal = nil
    mImageListState = nil

proc TreeCtrl*(parent: wWindow, id: wCommandID = wDefaultID, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wTreeCtrl {.discardable.} =
  new(result)
  result.wTreeCtrlInit(parent=parent, id=id, pos=pos, size=size, style=style)

# for wTreeEvent

proc getItem*(self: wTreeEvent): wTreeItem =
  case mMsg
  of wEvent_TreeItemExpanded, wEvent_TreeItemCollapsed,
      wEvent_TreeItemExpanding, wEvent_TreeItemCollapsing:

    let pnmtv = cast[LPNMTREEVIEW](mLparam)
    result = wTreeItem(mTreeCtrl: cast[wTreeCtrl](mWindow), mHandle: pnmtv.itemNew.hItem)

  # of

  else:
    raise newException(wError, "unsupported event method")
