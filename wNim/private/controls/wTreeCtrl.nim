#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A tree control presents information as a hierarchy, with items that may be
## expanded to show further items. Items in a tree control are referenced by
## wTreeItem handles, which may be tested for validity by calling
## wTreeItem.isOk().
#
## :Appearance:
##   .. image:: images/wTreeCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wTrNoButtons                    For convenience to document that no buttons are to be drawn.
##   wTrHasButtons                   Use this style to show + and - buttons to the left of parent items.
##   wTrHasLines                     Use this style to show vertical level connectors.
##   wTrEditLabels                   Use this style if you wish the user to be able to edit labels in the tree control.
##   wTrFullRowHighLight             Use this style to have the background colour and the selection
##                                   highlight extend over the entire horizontal row of the tree control
##                                   window. Cannot use with wTrHasLines.
##   wTrLinesAtRoot                  Use this style to show lines between root nodes.
##   wTrCheckBox                     Enables check boxes for items.
##   wTrTwistButtons                 Selects alternative style of +/- buttons and shows rotating ("twisting") arrows instead.
##                                   Windows vista later.
##   wTrNoHScroll                    Disables horizontal scrolling.
##   wTrNoScroll                     Disables both horizontal and vertical scrolling.
##   wTrSingleExpand                 Causes the item being selected to expand and the item being unselected
##                                   to collapse upon selection in the tree view.
##   ==============================  =============================================================
#
## :Events:
##   `wTreeEvent <wTreeEvent.html>`_

include ../pragma
import tables
import ../wBase, wControl, wListCtrl, wTextCtrl
export wControl, wListCtrl, wTextCtrl

const
  # TreeCtrl styles and consts
  wTrNoButtons* = 0
  wTrHasButtons* = TVS_HASBUTTONS
  wTrHasLines* = TVS_HASLINES
  wTrEditLabels* = TVS_EDITLABELS
  wTrFullRowHighLight* = TVS_FULLROWSELECT
  wTrLinesAtRoot* = TVS_LINESATROOT
  wTrCheckBox* = TVS_CHECKBOXES
  wTrTwistButtons* = 0x10000000.int64 shl 32
  wTrNoHScroll* = TVS_NOHSCROLL
  wTrNoScroll* = TVS_NOSCROLL
  wTrSingleExpand* = TVS_SINGLEEXPAND
  wTrShowSelectAlways* = TVS_SHOWSELALWAYS
  # Tree item states
  wTreeItemStateBold* = TVIS_BOLD
  wTreeItemStateCut* = TVIS_CUT
  wTreeItemStateDropHighlighted* = TVIS_DROPHILITED
  wTreeItemStateSelected* = TVIS_SELECTED
  # Image
  wTreeImageCallback* = I_IMAGECALLBACK # -1
  wTreeImageNone* = I_IMAGENONE # -2
  wTreeIgnore* = -3
  wTreeItemIconNormal* = 0
  wTreeItemIconSelected* = 1
  # Hit test flags
  wTreeHittestAbove* = TVHT_ABOVE
  wTreeHittestBelow* = TVHT_BELOW
  wTreeHittestNoWhere* = TVHT_NOWHERE
  wTreeHittestOnItemButton* = TVHT_ONITEMBUTTON
  wTreeHittestOnItemIcon* = TVHT_ONITEMICON
  wTreeHittestOnItemIndent* = TVHT_ONITEMINDENT
  wTreeHittestOnItemLabel* = TVHT_ONITEMLABEL
  wTreeHittestOnItemRight* = TVHT_ONITEMRIGHT
  wTreeHittestOnItemStateIcon* = TVHT_ONITEMSTATEICON
  wTreeHittestOnItem* = TVHT_ONITEM
  wTreeHittestToLeft* = TVHT_TOLEFT
  wTreeHittestToRight* = TVHT_TORIGHT

# there is too much work to do to support multiple selection in windows treeview
# so this code just don't consider it and of couse don't support it

# for "single selection treeview", a focused item is selected, vice versa
#   setFocusedItem() = selectItem(): set focus, select, ensure visible, unselect others
#   getFocusedItem(): get the focused item, this item may not selected

#   setSelection(): set select state for an item, this may broken "single selection"
#   getSelections(): get the selected items

# wTreeItem procs

proc TreeItem*(treeCtrl: wTreeCtrl, handle: HTREEITEM): wTreeItem {.inline.} =
  ## Default constructor.
  result.mTreeCtrl = treeCtrl
  result.mHandle = handle

proc `==`*(a, b: wTreeItem): bool {.inline.} =
  ## Checks for equality between two wTreeItem.
  result = (a.mTreeCtrl == b.mTreeCtrl and a.mHandle == b.mHandle)

proc isOk*(self: wTreeItem): bool {.inline.} =
  ## Returns true if this instance is referencing a valid tree item.
  result = (self.mTreeCtrl != nil) and (self.mHandle != 0)

proc unset*(self: var wTreeItem) {.inline.} =
  ## Unset the tree item.
  self.mHandle = 0

proc getHandle*(self: wTreeItem): HTREEITEM {.property.} =
  ## Gets the real tree item handle.
  result = self.mHandle

proc getTreeCtrl*(self: wTreeItem): wTreeCtrl {.property.} =
  ## Gets the tree control this item associated to.
  result = self.mTreeCtrl

proc getParent*(self: wTreeItem): wTreeItem {.property.} =
  ## Gets the parent of this item.
  wValidate(self.mTreeCtrl)
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_PARENT)

proc getFirstChild*(self: wTreeItem): wTreeItem {.property.} =
  ## Gets the first child of the item.
  wValidate(self.mTreeCtrl)
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_CHILD)

proc getPrevSibling*(self: wTreeItem): wTreeItem {.property.} =
  ## Gets the previous slbling of the item.
  wValidate(self.mTreeCtrl)
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_PREVIOUS)

proc getNextSibling*(self: wTreeItem): wTreeItem {.property.} =
  ## Gets the next slbling of the item.
  wValidate(self.mTreeCtrl)
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_NEXT)

proc getLastChild*(self: wTreeItem): wTreeItem {.property.} =
  ## Gets the last child of the item.
  wValidate(self.mTreeCtrl)
  var hLast: HTREEITEM = 0
  var hItem = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_CHILD)
  while hItem != 0:
    hLast = hItem
    hItem = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, hItem, TVGN_NEXT)

  result = TreeItem(self.mTreeCtrl, hLast)

proc getChildrenCount*(self: wTreeItem, recursively = true): int {.property.} =
  ## Gets the number of items in the branch. If *recursively* is true, returns the
  ## total number of descendants, otherwise only one level of children is counted.
  wValidate(self.mTreeCtrl)
  var child = self.getFirstChild()
  while child.isOk():
    result.inc
    if recursively:
      result.inc(child.getChildrenCount(true))
    child = child.getNextSibling()

proc len*(self: wTreeItem): int =
  ## Gets the number of children in this item.
  wValidate(self.mTreeCtrl)
  result = self.getChildrenCount(false)

iterator items*(self: wTreeItem): wTreeItem =
  ## Iterate each child in this item.
  wValidate(self.mTreeCtrl)
  var item = self.getFirstChild()
  while item.isOk():
    yield item
    item = item.getNextSibling()

iterator allItems*(self: wTreeItem): wTreeItem =
  ## Iterate each child in this item, including all descendants.
  wValidate(self.mTreeCtrl)
  var node = self
  block loop:
    while true:
      let child = node.getFirstChild()
      if child.isOk():
        node = child
      else:
        while true:
          if node.mHandle == self.mHandle:
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
  for item in self.items():
    children.add(item)
    if recursively:
      item.addChildren(children, true)

proc getChildren*(self: wTreeItem): seq[wTreeItem] {.property.} =
  ## Returns all children as a seq.
  wValidate(self.mTreeCtrl)
  result = @[]
  self.addChildren(result, false)

proc getAllChildren*(self: wTreeItem): seq[wTreeItem] {.property.} =
  ## Returns all children including descendants as a seq.
  wValidate(self.mTreeCtrl)
  result = @[]
  self.addChildren(result, true)

proc set*(self: wTreeItem, text = "", image = wTreeIgnore,
    selImage = wTreeIgnore, state = 0, flag = true) =
  ## Sets the item attributes.
  wValidate(self.mTreeCtrl)
  var tvitem = TVITEM(mask: TVIF_HANDLE, hItem: self.mHandle)

  if text.len != 0:
    tvitem.mask = tvitem.mask or TVIF_TEXT
    tvitem.pszText = &T(text)

  if image != wTreeIgnore:
    tvitem.mask = tvitem.mask or TVIF_IMAGE
    tvitem.iImage = image

  if image != wTreeIgnore:
    tvitem.mask = tvitem.mask or TVIF_SELECTEDIMAGE
    tvitem.iSelectedImage = selImage

  if state != 0:
    tvitem.mask = tvitem.mask or TVIF_STATE
    tvitem.stateMask = state
    tvitem.state = if flag: state else: 0

  TreeView_SetItem(self.mTreeCtrl.mHwnd, &tvitem)

proc setText*(self: wTreeItem, text: string) {.property, inline.} =
  ## Sets the item text.
  wValidate(self.mTreeCtrl)
  self.set(text=text)

proc setBold*(self: wTreeItem, flag = true) {.property, inline.} =
  ## Makes the item appear in bold or not.
  wValidate(self.mTreeCtrl)
  self.set(state=TVIS_BOLD, flag=flag)

proc setCut*(self: wTreeItem, flag = true) {.property, inline.} =
  ## Makes the item appear in cut-and-paste operation or not.
  wValidate(self.mTreeCtrl)
  self.set(state=TVIS_CUT, flag=flag)

proc setSelection*(self: wTreeItem, flag = true) {.property, inline.} =
  ## Makes the item appear in selected or not.
  ## Notice: this will broken single selection states, don't use this if possible.
  wValidate(self.mTreeCtrl)
  self.set(state=TVIS_SELECTED, flag=flag)

proc setDropHighlight*(self: wTreeItem, flag = true) {.property, inline.} =
  ## Makes the item appear in Drag'n'Drop actions or not.
  wValidate(self.mTreeCtrl)
  self.set(state=TVIS_DROPHILITED, flag=flag)

proc select*(self: wTreeItem) =
  ## Select, focus, and ensure visible of the item, also unselect others.
  wValidate(self.mTreeCtrl)
  TreeView_SelectItem(self.mTreeCtrl.mHwnd, self.mHandle)

proc scrollTo*(self: wTreeItem) =
  ## Scrolls the specified item into view.
  wValidate(self.mTreeCtrl)
  TreeView_Select(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_FIRSTVISIBLE)

proc unselect*(self: wTreeItem) {.inline.} =
  ## Unselects this item.
  ## Notice: this will broken single selection states, don't use this if possible.
  wValidate(self.mTreeCtrl)
  self.setSelection(false)

proc setImage*(self: wTreeItem, image = wTreeIgnore, selImage = wTreeIgnore)
    {.property.} =
  ## Sets the specified item's image.
  wValidate(self.mTreeCtrl)
  var selImage = selImage

  if image != wTreeIgnore and selImage == wTreeIgnore:
    # the same image is used for both
    selImage = image

  self.set(image=image, selImage=selImage)

proc setData*(self: wTreeItem, data: int) {.property.} =
  ## Sets the item associated data.
  wValidate(self.mTreeCtrl)
  if self.mTreeCtrl.mInSortChildren:
    self.mTreeCtrl.mDataTable[self.mHandle] = data
  else:
    var tvitem = TVITEM(mask: TVIF_PARAM or TVIF_HANDLE, hItem: self.mHandle, lParam: data)
    TreeView_SetItem(self.mTreeCtrl.mHwnd, &tvitem)

proc setState*(self: wTreeItem, state: range[0..15]) {.property.} =
  ## Sets the item state image. If *state* > 0, the 1-based state image will
  ## be displayed. *state* = 0 to disable the state image. PS. State image stored
  ## in the imagelist specified by setImageList(which=wImageListState).

  # state is bits 12 ~ 15, state image is 1-based, 0 for no state image
  wValidate(self.mTreeCtrl)
  var tvitem = TVITEM(
    mask: TVIF_STATE or TVIF_HANDLE,
    hItem: self.mHandle,
    state: INDEXTOSTATEIMAGEMASK(state),
    stateMask: TVIS_STATEIMAGEMASK)
  TreeView_SetItem(self.mTreeCtrl.mHwnd, &tvitem)

proc setHasChildren*(self: wTreeItem, flag = true) {.property.} =
  ## Force appearance of the button next to the item.
  wValidate(self.mTreeCtrl)
  var tvitem = TVITEM(mask: TVIF_CHILDREN or TVIF_HANDLE, hItem: self.mHandle,
    cChildren: if flag: 1 else: 0)
  TreeView_SetItem(self.mTreeCtrl.mHwnd, &tvitem)

proc expand*(self: wTreeItem) =
  ## Expands the item.
  wValidate(self.mTreeCtrl)
  TreeView_Expand(self.mTreeCtrl.mHwnd, self.mHandle, TVE_EXPAND)

proc collapse*(self: wTreeItem) =
  ## Collapses the item.
  wValidate(self.mTreeCtrl)
  TreeView_Expand(self.mTreeCtrl.mHwnd, self.mHandle, TVE_COLLAPSE)

proc collapseAndReset*(self: wTreeItem) =
  ## Collapses the given item and removes all children.
  wValidate(self.mTreeCtrl)
  TreeView_Expand(self.mTreeCtrl.mHwnd, self.mHandle, TVE_COLLAPSE or TVE_COLLAPSERESET)

proc toggle*(self: wTreeItem) =
  ## Toggles the item between collapsed and expanded states.
  wValidate(self.mTreeCtrl)
  TreeView_Expand(self.mTreeCtrl.mHwnd, self.mHandle, TVE_TOGGLE)

proc getText*(self: wTreeItem): string {.property.} =
  ## Returns the item text.
  wValidate(self.mTreeCtrl)
  var buffer = T(65536)
  var tvitem = TVITEM(
    mask: TVIF_TEXT or TVIF_HANDLE,
    hItem: self.mHandle,
    cchTextMax: 65536,
    pszText: &buffer)

  if TreeView_GetItem(self.mTreeCtrl.mHwnd, &tvitem) != 0:
    buffer.nullTerminate
    result = $buffer

proc get(self: wTreeItem, mask = 0): TVITEM =
  result.mask = TVIF_HANDLE or mask
  result.hItem = self.mHandle
  result.stateMask = -1
  discard TreeView_GetItem(self.mTreeCtrl.mHwnd, &result)

proc isBold*(self: wTreeItem): bool =
  ## Returns true if the item is in bold state.
  wValidate(self.mTreeCtrl)
  var tvitem = self.get(TVIF_STATE)
  result = (tvitem.state and TVIS_BOLD) != 0

proc isCut*(self: wTreeItem): bool =
  ## Returns true if the item is in cut-and-paste operation state.
  wValidate(self.mTreeCtrl)
  var tvitem = self.get(TVIF_STATE)
  result = (tvitem.state and TVIS_CUT) != 0

proc isDropHighlight*(self: wTreeItem): bool =
  ## Returns true if the item is in drop hightlight state.
  wValidate(self.mTreeCtrl)
  var tvitem = self.get(TVIF_STATE)
  result = (tvitem.state and TVIS_DROPHILITED) != 0

proc isSelected*(self: wTreeItem): bool =
  ## Returns true if the item is in selected state.
  wValidate(self.mTreeCtrl)
  var tvitem = self.get(TVIF_STATE)
  result = (tvitem.state and TVIS_SELECTED) != 0

proc isExpanded*(self: wTreeItem): bool =
  ## Returns true if the item is expanded.
  wValidate(self.mTreeCtrl)
  var tvitem = self.get(TVIF_STATE)
  result = (tvitem.state and TVIS_EXPANDED) != 0

proc isFocused*(self: wTreeItem): bool =
  ## Returns true if the item is focused.
  wValidate(self.mTreeCtrl)
  result = self.mHandle == TreeView_GetSelection(self.mTreeCtrl.mHwnd)

proc getImage*(self: wTreeItem): int {.property.} =
  ## Gets the item image.
  wValidate(self.mTreeCtrl)
  let tvitem = self.get(TVIF_IMAGE)
  result = tvitem.iImage

proc getSelImage*(self: wTreeItem): int {.property.} =
  ## Gets the selected item image.
  wValidate(self.mTreeCtrl)
  let tvitem = self.get(TVIF_SELECTEDIMAGE)
  result = tvitem.iImage

proc getData*(self: wTreeItem): int {.property.} =
  ## Returns the data associated with the item.
  wValidate(self.mTreeCtrl)
  if self.mTreeCtrl.mInSortChildren:
    result = self.mTreeCtrl.mDataTable.getOrDefault(self.mHandle)
  else:
    let tvitem = self.get(TVIF_PARAM)
    result = int tvitem.lParam

proc getState*(self: wTreeItem): int {.property.} =
  ## Gets the item state image.
  wValidate(self.mTreeCtrl)
  template STATEIMAGEMASKTOINDEX(i: int): int = (i and TVIS_STATEIMAGEMASK) shr 12
  let tvitem = self.get(TVIF_STATE)
  result = STATEIMAGEMASKTOINDEX(tvitem.state)

proc hasChildren*(self: wTreeItem): bool =
  ## Returns true if the item is in having children state. Notice this only gets
  ## the state that can be set by setHasChildren().
  wValidate(self.mTreeCtrl)
  let tvitem = self.get(TVIF_CHILDREN)
  result = tvitem.cChildren != 0

proc expandAllChildren*(self: wTreeItem) =
  ## Expands the item and all its children recursively.
  wValidate(self.mTreeCtrl)
  self.expand()
  var child = self.getFirstChild()
  while child.isOk():
    child.expandAllChildren()
    child = child.getNextSibling()

proc collapseAllChildren*(self: wTreeItem) =
  ## Collapses this item and all of its children, recursively.
  wValidate(self.mTreeCtrl)
  self.collapse()
  var child = self.getFirstChild()
  while child.isOk():
    child.collapseAllChildren()
    child = child.getNextSibling()

proc getBoundingRect*(self: wTreeItem, textOnly = false): wRect {.property.} =
  ## Retrieves the rectangle bounding the item.
  ## If textOnly is true, only the rectangle around the item's label will be
  ## returned, otherwise the item's image is also taken into account.
  ## The return value is wDefaultRect if not successfully, for example,
  ## if the item is currently invisible.
  ## Notice that the rectangle coordinates are logical, not physical ones.
  ## So, for example, the x coordinate may be negative if the tree has a
  ## horizontal scrollbar and its position is not 0.
  wValidate(self.mTreeCtrl)
  var rect: RECT
  if TreeView_GetItemRect(self.mTreeCtrl.mHwnd, self.mHandle, &rect, textOnly):
    result = toWRect(rect)
  else:
    result = wDefaultRect

proc isVisible*(self: wTreeItem): bool =
  ## Returns true if the item is visible on the screen.
  wValidate(self.mTreeCtrl)
  var rect: RECT
  if TreeView_GetItemRect(self.mTreeCtrl.mHwnd, self.mHandle, &rect, true):
    result = rect.bottom > 0 and rect.top < self.mTreeCtrl.getClientSize().height

proc getNextVisible*(self: wTreeItem): wTreeItem {.property.} =
  ## Returns the next visible item or an invalid item if this item is the last
  ## visible one. Notice: The item itself must be visible.
  wValidate(self.mTreeCtrl)
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_NEXTVISIBLE)
  # TVGN_NEXTVISIBLE return all non-collapsed item
  if not result.isVisible():
    result.mHandle = 0

proc getPrevVisible*(self: wTreeItem): wTreeItem {.property.} =
  ## Returns the previous visible item or an invalid item if this item is the
  ## first visible one. Notice: The item itself must be visible.
  wValidate(self.mTreeCtrl)
  result.mTreeCtrl = self.mTreeCtrl
  result.mHandle = TreeView_GetNextItem(self.mTreeCtrl.mHwnd, self.mHandle, TVGN_PREVIOUSVISIBLE)
  # TVGN_PREVIOUSVISIBLE return all non-collapsed item
  if not result.isVisible():
    result.mHandle = 0

proc ensureVisible*(self: wTreeItem) =
  ## Scrolls and/or expands items to ensure that the item is visible.
  wValidate(self.mTreeCtrl)
  TreeView_EnsureVisible(self.mTreeCtrl.mHwnd, self.mHandle)

proc delete*(self: wTreeItem) =
  ## Deletes the specified item.
  wValidate(self.mTreeCtrl)
  TreeView_DeleteItem(self.mTreeCtrl.mHwnd, self.mHandle)

proc deleteChildren*(self: wTreeItem) =
  ## Deletes all children of the given item (but not the item itself).
  wValidate(self.mTreeCtrl)
  for item in self.getChildren():
    item.delete()

proc toggleSelection*(self: wTreeItem) =
  ## Toggles the item between selected and unselected states.
  wValidate(self.mTreeCtrl)
  self.setSelection(not self.isSelected())

proc selectChildren*(self: wTreeItem) =
  ## Select all the immediate children of the given parent.
  wValidate(self.mTreeCtrl)
  for item in self.items():
    item.setSelection(true)

proc editLabel*(self: wTreeItem): wTextCtrl {.discardable.} =
  ## Starts editing the label of the item.
  wValidate(self.mTreeCtrl)
  # TreeView_EditLabel requires that the control has focus.
  self.mTreeCtrl.setFocus()
  let hwnd = TreeView_EditLabel(self.mTreeCtrl.mHwnd, self.mHandle)
  if hwnd != 0:
    assert hwnd == self.mTreeCtrl.mTextCtrl.mHwnd
    result = self.mTreeCtrl.mTextCtrl

proc sortChildren*(self: wTreeItem, recursively = false) =
  ## Sorts the children of the item by text (alphabetically).
  # TreeView_SortChildren don't really sort recursively, even MSDN says it will do.
  wValidate(self.mTreeCtrl)
  TreeView_SortChildren(self.mTreeCtrl.mHwnd, self.mHandle, 0)
  if recursively:
    var child = self.getFirstChild()
    while child.isOk():
      child.sortChildren(true)
      child = child.getNextSibling()

type
  wTreeCtrl_Compare* = proc (data1: int, data2: int, data: int): int
    ## Comparing callback function prototype used in sortChildren()
  wTreeCtrl_SortData = object
    fn: wTreeCtrl_Compare
    data: int

proc wTree_CompareFunc(lparam1, lparam2, lparamSort: LPARAM): int32 {.stdcall.} =
  let pSortData = cast[ptr wTreeCtrl_SortData](lparamSort)
  result = pSortData[].fn(int lparam1, int lparam2, pSortData[].data)

proc sortChildren*(self: wTreeItem, callback: wTreeCtrl_Compare,
    data: int = 0, recursively = false) =
  ## Sorts the children of the item. The value passed into callback function
  ## is the data associated with the item
  wValidate(self.mTreeCtrl)
  var sortData = wTreeCtrl_SortData(fn: callback, data: data)
  var tvsortcb = TVSORTCB(hParent: self.mHandle, lpfnCompare: wTree_CompareFunc,
    lParam: cast[LPARAM](&sortData))

  TreeView_SortChildrenCB(self.mTreeCtrl.mHwnd, &tvsortcb, 0)

  if recursively:
    var child = self.getFirstChild()
    while child.isOk():
      child.sortChildren(callback, data, true)
      child = child.getNextSibling()

type
  wTreeCtrl_ItemCompare* = proc (item1: wTreeItem, item2: wTreeItem, data: int): int
    ## Comparing callback function prototype used in sortChildren()
  wTreeCtrl_ItemSortData = object
    fn: wTreeCtrl_ItemCompare
    data: int
    treeCtrl: wTreeCtrl

proc wTree_ItemCompareFunc(lparam1, lparam2, lparamSort: LPARAM): int32 {.stdcall.} =
  let pSortData = cast[ptr wTreeCtrl_ItemSortData](lparamSort)
  var item1 = TreeItem(pSortData[].treeCtrl, HTREEITEM lparam1)
  var item2 = TreeItem(pSortData[].treeCtrl, HTREEITEM lparam2)
  result = pSortData[].fn(item1, item2, pSortData[].data)

proc sortChildren*(self: wTreeItem, callback: wTreeCtrl_ItemCompare,
    data: int = 0, recursively = false) =
  ## Sorts the children of the item. The value passed into callback function
  ## is the wTreeItem object.
  wValidate(self.mTreeCtrl)
  var sortData = wTreeCtrl_ItemSortData(fn: callback, data: data, treeCtrl: self.mTreeCtrl)
  var tvsortcb = TVSORTCB(hParent: self.mHandle, lpfnCompare: wTree_ItemCompareFunc,
    lParam: cast[LPARAM](&sortData))

  self.mTreeCtrl.mDataTable = initTable[HTREEITEM, int]()
  for item in self.items():
    self.mTreeCtrl.mDataTable[item.mHandle] = item.getData()
    item.setData(item.mHandle)

  self.mTreeCtrl.mInSortChildren = true
  TreeView_SortChildrenCB(self.mTreeCtrl.mHwnd, &tvsortcb, 0)
  self.mTreeCtrl.mInSortChildren = false

  for item in self.items():
    item.setData(self.mTreeCtrl.mDataTable[item.mHandle])
  self.mTreeCtrl.mDataTable.clear()

  if recursively:
    var child = self.getFirstChild()
    while child.isOk():
      child.sortChildren(data=data, recursively=true, callback=callback)
      child = child.getNextSibling()

proc setFocused*(self: wTreeItem) =
  ## Sets the currently focused item. Use select() instead of this if possible.
  wValidate(self.mTreeCtrl)
  var focus = TreeItem(self.mTreeCtrl, TreeView_GetSelection(self.mTreeCtrl.mHwnd))
  if focus.mHandle == self.mHandle:
    return

  if self.isOk():
    var wasSelected = self.isSelected()
    var reselectFocus = false
    if focus.isOk() and focus.isSelected():
      TreeView_SelectItem(self.mTreeCtrl.mHwnd, 0)
      reselectFocus = true

    self.select()
    self.setSelection(wasSelected)

    if reselectFocus:
      focus.setSelection(true)

  else:
    var wasSelected = focus.isSelected()
    TreeView_SelectItem(self.mTreeCtrl.mHwnd, 0)
    focus.setSelection(wasSelected)

# wTreeCtrl procs

proc getFirstRoot*(self: wTreeCtrl): wTreeItem {.validate, property.} =
  ## Returns the first root item for the tree control.
  result.mTreeCtrl = self
  result.mHandle = TreeView_GetRoot(self.mHwnd)

proc getRootItem*(self: wTreeCtrl): wTreeItem {.validate, property, inline.} =
  ## Returns the first root item for the tree control. The same as getFirstRoot().
  result = self.getFirstRoot()

proc getFirstVisibleItem*(self: wTreeCtrl): wTreeItem {.validate, property.} =
  ## Returns the first visible item.
  result.mTreeCtrl = self
  result.mHandle = TreeView_GetFirstVisible(self.mHwnd)

proc getFocusedItem*(self: wTreeCtrl): wTreeItem {.validate, property.} =
  ## Returns the item last clicked or otherwise selected.
  result.mTreeCtrl = self
  result.mHandle = TreeView_GetSelection(self.mHwnd)

proc getSelections*(self: wTreeCtrl): seq[wTreeItem] {.validate, property.} =
  ## Returns currently selected items.
  result = @[]
  var root = self.getFirstRoot()
  while root.isOk():
    if root.isSelected():
      result.add(root)

    for item in root.allItems():
      if item.isSelected():
        result.add(item)
    root = root.getNextSibling()

proc hitTest*(self: wTreeCtrl, x: int, y: int): tuple[item: wTreeItem, flag: int]
    {.validate.} =
  ## Calculates which (if any) item is under the given point, returning the
  ## tree item at this point plus extra information flags.
  ## *flags* is a bitlist of the following:
  ## ===========================  ==============================================
  ## Flag                         Description
  ## ===========================  ==============================================
  ## wTreeHittestAbove            Above the client area.
  ## wTreeHittestBelow            Below the client area.
  ## wTreeHittestNoWhere          In the client area but below the last item.
  ## wTreeHittestOnItemButton     On the button associated with an item.
  ## wTreeHittestOnItemIcon       On the bitmap associated with an item.
  ## wTreeHittestOnItemIndent     In the indentation associated with an item.
  ## wTreeHittestOnItemLabel      On the label (string) associated with an item.
  ## wTreeHittestOnItemRight      In the area to the right of an item.
  ## wTreeHittestOnItemStateIcon  On the state icon for a tree view item that is in a user-defined state.
  ## wTreeHittestOnItem           OnItemIcon or OnItemLabel or OnItemStateIcon.
  ## wTreeHittestToLeft           To the right of the client area.
  ## wTreeHittestToRight          To the left of the client area.
  var info: TVHITTESTINFO
  info.pt.x = x
  info.pt.y = y
  result.item.mTreeCtrl = self
  result.item.mHandle = TreeView_HitTest(self.mHwnd, &info)
  result.flag = info.flags

proc hitTest*(self: wTreeCtrl, pos: wPoint): tuple[item: wTreeItem, flag: int]
    {.validate, inline.} =
  ## The same as hitTest().
  result = self.hitTest(pos.x, pos.y)

proc unselectAll*(self: wTreeCtrl) {.validate.} =
  ## Removes the selection from all items.
  for item in self.getSelections():
    item.unselect()

proc expandAll*(self: wTreeCtrl) {.validate.} =
  ## Expands all items in the tree.
  var root = self.getFirstRoot()
  while root.isOk():
    root.expandAllChildren()
    root = root.getNextSibling()

proc collapseAll*(self: wTreeCtrl) {.validate.} =
  ## Collapses all items in the tree.
  var root = self.getFirstRoot()
  while root.isOk():
    root.collapseAllChildren()
    root = root.getNextSibling()

proc deleteAllItems*(self: wTreeCtrl) {.validate.} =
  ## Deletes all items in the control.
  TreeView_DeleteItem(self.mHwnd, 0)

proc clearFocusedItem*(self: wTreeCtrl) {.validate.} =
  ## Clears the currently focused item.
  TreeView_SelectItem(self.mHwnd, 0)

proc getCount*(self: wTreeCtrl): int {.validate, property.} =
  ## Returns the number of items in the control.
  result = TreeView_GetCount(self.mHwnd)

proc len*(self: wTreeCtrl): int {.validate, property, inline.} =
  ## Returns the number of items in the control. The same as getCount().
  result = self.getCount()

proc isEmpty*(self: wTreeCtrl): bool {.validate, inline.} =
  ## Returns true if the control is empty.
  result = self.getCount() == 0

proc insertItem(self: wTreeCtrl, parent, after: HTREEITEM, text: string,
    image = wTreeImageNone, selImage = wTreeIgnore, data = 0): wTreeItem =

  var insert = TVINSERTSTRUCT(hParent: parent, hInsertAfter: after)
  insert.item.mask = TVIF_TEXT or TVIF_PARAM
  insert.item.pszText = &T(text)
  insert.item.lParam = data

  var selImage = selImage
  if image != wTreeIgnore and selImage == wTreeIgnore:
    # the same image is used for both
    selImage = image

  if image != wTreeIgnore:
    insert.item.mask = insert.item.mask or TVIF_IMAGE
    insert.item.iImage = image

  if selImage != wTreeIgnore:
    insert.item.mask = insert.item.mask or TVIF_SELECTEDIMAGE
    insert.item.iSelectedImage = selImage

  result = TreeItem(self, HTREEITEM SendMessage(self.mHwnd, TVM_INSERTITEM, 0, &insert))

proc addRoot*(self: wTreeCtrl, text: string, image = wTreeImageNone,
    selImage = wTreeIgnore, data: int = 0): wTreeItem {.validate, discardable.} =
  ## Adds the root node to the tree, returning the new item.
  result = self.insertItem(TVI_ROOT, TVI_ROOT, text, image, selImage, data)

proc appendItem*(self: wTreeCtrl, parent: wTreeItem, text: string,
    image = wTreeImageNone, selImage = wTreeIgnore, data: int = 0): wTreeItem
    {.validate, discardable.} =
  ## Appends an item to the end of the branch identified by parent, return a new item.
  assert parent.mTreeCtrl == self
  result = self.insertItem(parent.mHandle, TVI_LAST, text, image, selImage, data)

proc prependItem*(self: wTreeCtrl, parent: wTreeItem, text: string,
    image = wTreeImageNone, selImage = wTreeIgnore, data: int = 0): wTreeItem
    {.validate, discardable.} =
  ## Appends an item as the first child of parent, return a new item.
  assert parent.mTreeCtrl == self
  result = self.insertItem(parent.mHandle, TVI_FIRST, text, image, selImage, data)

proc insertItem*(self: wTreeCtrl, parent: wTreeItem, prev: wTreeItem, text: string,
    image = wTreeImageNone, selImage = wTreeIgnore, data: int = 0): wTreeItem
    {.validate, discardable.} =
  ## Inserts an item after a given one (*previous*).
  assert parent.mTreeCtrl == self and prev.mTreeCtrl == self
  result = self.insertItem(parent.mHandle, prev.mHandle, text, image, selImage, data)

proc insertItem*(self: wTreeCtrl, parent: wTreeItem, pos: int, text: string,
    image = wTreeImageNone, selImage = wTreeIgnore, data: int = 0): wTreeItem
    {.validate, discardable.} =
  ## Inserts an item before one identified by its position (*pos*).
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

  result = self.insertItem(hParent, after, text, image, selImage, data)

proc setImageList*(self: wTreeCtrl, imageList: wImageList,
    which = wImageListNormal) {.validate, property.} =
  ## Sets the image list associated with the control.
  ## *which* is one of wImageListNormal, wImageListState.
  wValidate(imageList)
  # TVSIL_NORMAL = LVSIL_NORMAL, TVSIL_STATE = LVSIL_STATE
  # it's save to use the same define in wListCtrl
  case which
  of TVSIL_NORMAL: self.mImageListNormal = imageList
  of TVSIL_STATE: self.mImageListState = imageList
  else: return
  SendMessage(self.mHwnd, TVM_SETIMAGELIST, which, imageList.mHandle)

proc getImageList*(self: wTreeCtrl, which = wImageListNormal): wImageList
    {.validate, property.} =
  ## Returns the specified image list.
  ## *which* is one of wImageListNormal, wImageListState.
  result = case which
  of TVSIL_NORMAL: self.mImageListNormal
  of TVSIL_STATE: self.mImageListState
  else: nil

proc getIndent*(self: wTreeCtrl): int {.validate, property.} =
  ## Returns the current tree control indentation.
  result = TreeView_GetIndent(self.mHwnd)

proc setIndent*(self: wTreeCtrl, indent: int) {.validate, property.} =
  ## Sets the indentation for the tree control.
  TreeView_SetIndent(self.mHwnd, indent)

proc enableInsertMark*(self: wTreeCtrl, flag = true) {.validate, inline.} =
  ## Enables or disables insert mark durgn Drag'n'Drop action.
  self.mEnableInsertMark = flag

method setBackgroundColor*(self: wTreeCtrl, color: wColor) {.property} =
  ## Sets the background color of the control.
  procCall wWindow(self).setBackgroundColor(color)
  TreeView_SetBkColor(self.mHwnd, color)

method setForegroundColor*(self: wTreeCtrl, color: wColor) {.property} =
  ## Sets the foreground color of the control.
  procCall wWindow(self).setForegroundColor(color)
  TreeView_SetTextColor(self.mHwnd, color)

iterator items*(self: wTreeCtrl): wTreeItem {.validate.} =
  ## Iterate each child in this control.
  var item = self.getFirstRoot()
  while item.isOk():
    yield item
    item = item.getNextSibling()

iterator allItems*(self: wTreeCtrl): wTreeItem {.validate.} =
  ## Iterate each child in this control, including all descendants.
  var item = self.getFirstRoot()
  while item.isOk():
    yield item
    for subitem in item.allItems():
      yield subitem

    item = item.getNextSibling()

method getBestSize*(self: wTreeCtrl): wSize {.property.} =
  result = wDefaultSize

  var info = SCROLLBARINFO(cbSize: sizeof(SCROLLBARINFO))
  GetScrollBarInfo(self.mHwnd, OBJID_VSCROLL, &info)
  var scrollX = info.rcScrollBar.right - info.rcScrollBar.left
  GetScrollBarInfo(self.mHwnd, OBJID_HSCROLL, &info)
  var scrollY = info.rcScrollBar.bottom - info.rcScrollBar.top

  for item in self.allItems():
    var rect = item.getBoundingRect(textOnly=true)
    if rect != wDefaultRect:
      result.width = max(result.width, rect.x + rect.width + scrollX + 5)
      result.height = max(result.height, rect.y + rect.height + scrollY + 5)

proc TreeEvent(self: wTreeCtrl, msg: UINT, lParam: LPARAM): wTreeEvent =
  let event = wTreeEvent Event(window=self, msg=msg, lParam=lParam)
  event.mTreeCtrl = self

  case msg
  of wEvent_TreeItemActivated, wEvent_TreeItemRightClick,
      wEvent_TreeEndDrag, wEvent_TreeItemMenu:
    event.mHandle = HTREEITEM lParam

  of wEvent_TreeBeginLabelEdit, wEvent_TreeEndLabelEdit:
    let pndi = cast[LPNMTVDISPINFO](lParam)
    event.mHandle = pndi.item.hItem
    if pndi.item.pszText != nil:
      event.mText = $pndi.item.pszText

  of wEvent_TreeSelChanging, wEvent_TreeSelChanged:
    let pnmtv = cast[LPNMTREEVIEW](lParam)
    event.mHandle = pnmtv.itemNew.hItem
    event.mOldHandle = pnmtv.itemOld.hItem

  of wEvent_TreeDeleteItem:
    let pnmtv = cast[LPNMTREEVIEW](lParam)
    event.mHandle = pnmtv.itemOld.hItem
    event.mOldHandle = pnmtv.itemOld.hItem

  else:
    let pnmtv = cast[LPNMTREEVIEW](lParam)
    event.mHandle = pnmtv.itemNew.hItem

  result = event

proc isReallyOnItem(self: wTreeCtrl, flags: int): bool =
  var mask = TVHT_ONITEM
  if (GetWindowLongPtr(self.mHwnd, GWL_STYLE) and TVS_FULLROWSELECT) != 0:
    mask = mask or TVHT_ONITEMINDENT or TVHT_ONITEMRIGHT

  result = (flags and mask) != 0

proc beginDrag(self: wTreeCtrl, hItem: HTREEITEM, pos: wPoint) =
  self.mDragging = true
  self.mCurrentDraggingItem = hItem
  # select the item before Drag'n'Drop is nature behavior?
  TreeView_SelectItem(self.mHwnd, hItem)

  # TreeView_CreateDragImage don't inlcude text for ascii string, but include
  # text for non-ascii string, a strange bug for Windows?
  # So here add a "Ideographic Space" to force inlcude the text.
  var item = TreeItem(self, hItem)
  let text = item.getText()
  item.setText(text & "\xE3\x80\x80")
  var iml = TreeView_CreateDragImage(self.mHwnd, hItem)
  item.setText(text)

  ImageList_BeginDrag(iml, 0, 0, 0)
  ImageList_DragEnter(self.mHwnd, pos.x, pos.y)
  self.captureMouse()

proc dragging(self: wTreeCtrl, pos: wPoint) =
  ImageList_DragMove(pos.x, pos.y)
  ImageList_DragShowNolock(false)
  var item = self.hitTest(pos).item
  if item.isOk():
    self.mCurrentInsertItem = item.mHandle
    var insert = false
    if self.mEnableInsertMark:
      let rect = item.getBoundingRect()
      if rect != wDefaultRect:
        if pos.y < rect.y + rect.height div 4:
          TreeView_SetInsertMark(self.mHwnd, item.mHandle, false)
          TreeView_SelectDropTarget(self.mHwnd, 0)
          insert = true
          self.mCurrentInsertMark = -1
        elif pos.y > rect.y + rect.height * 3 div 4:
          TreeView_SetInsertMark(self.mHwnd, item.mHandle, true)
          TreeView_SelectDropTarget(self.mHwnd, 0)
          insert = true
          self.mCurrentInsertMark = 1

    if not insert:
      TreeView_SetInsertMark(self.mHwnd, 0, 0)
      TreeView_SelectDropTarget(self.mHwnd, item.mHandle)
      self.mCurrentInsertMark = 0

  ImageList_DragShowNoLock(true)

proc cancelDrag*(self: wTreeCtrl) {.validate.} =
  ## Cancel Drag'n'Drop action.
  if self.mDragging:
    ImageList_EndDrag()
    TreeView_SetInsertMark(self.mHwnd, 0, 0)
    TreeView_SelectDropTarget(self.mHwnd, 0)
    self.mDragging = false
    self.mCurrentDraggingItem = 0
    self.releaseMouse()

proc endDrag*(self: wTreeCtrl) {.validate.} =
  ## Ends Drag'n'Drop action.
  # let this public so that user can end Drag'n'Drop programmatically.
  if self.mDragging:
    let draggingItem = self.mCurrentDraggingItem
    self.cancelDrag()
    let event = self.TreeEvent(wEvent_TreeEndDrag, self.mCurrentInsertItem)
    event.mInsertMark = self.mCurrentInsertMark
    event.mOldHandle = draggingItem
    self.processEvent(event)

method processNotify(self: wTreeCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code:
  of TVN_SELCHANGED:
    let event = self.TreeEvent(wEvent_TreeSelChanged, lParam)
    return self.processEvent(event)

  of TVN_DELETEITEM:
    let event = self.TreeEvent(wEvent_TreeDeleteItem, lParam)
    return self.processEvent(event)

  of TVN_BEGINDRAG, TVN_BEGINRDRAG:
    let msg = if code == TVN_BEGINDRAG: wEvent_TreeBeginDrag else: wEvent_TreeBeginRdrag
    let event = self.TreeEvent(msg, lParam)
    event.veto # vetoed by default.
    let processed = self.processEvent(event)
    if processed and event.isAllowed:
      let pnmtv = cast[LPNMTREEVIEW](lParam)
      self.beginDrag(pnmtv.itemNew.hItem, (int pnmtv.ptDrag.x, int pnmtv.ptDrag.y))
    return processed

  of TVN_SELCHANGING:
    let event = self.TreeEvent(wEvent_TreeSelChanging, lParam)
    let processed = self.processEvent(event)
    if processed and not event.isAllowed:
      # MSDN: Returns TRUE to prevent the selection from changing.
      ret = TRUE
    return processed

  of TVN_ITEMEXPANDING:
    let msg =
      if cast[LPNMTREEVIEW](lParam).action == TVE_COLLAPSE:
        wEvent_TreeItemCollapsing
      else:
        wEvent_TreeItemExpanding

    let event = self.TreeEvent(msg, lParam)
    let processed = self.processEvent(event)
    if processed and not event.isAllowed:
      # MSDN: Returns TRUE to prevent the list from expanding or collapsing.
      ret = TRUE
    return processed

  of TVN_ITEMEXPANDED:
    let msg =
      if cast[LPNMTREEVIEW](lParam).action == TVE_COLLAPSE:
        wEvent_TreeItemCollapsed
      else:
        wEvent_TreeItemExpanded

    let event = self.TreeEvent(msg, lParam)
    return self.processEvent(event)

  of TVN_BEGINLABELEDIT:
    let hwnd = TreeView_GetEditControl(self.mHwnd)
    if hWnd != 0:
      self.mTextCtrl = TextCtrl(hwnd)

    let event = self.TreeEvent(wEvent_TreeBeginLabelEdit, lParam)
    let processed = self.processEvent(event)
    if processed and not event.isAllowed:
      # MSDN: Returns TRUE to cancel label editing.
      ret = TRUE
      # if here return TRUE, TVN_ENDLABELEDIT won't be fired.
      self.mTextCtrl = nil

    return processed

  of TVN_ENDLABELEDIT:
    self.mTextCtrl = nil

    let event = self.TreeEvent(wEvent_TreeEndLabelEdit, lParam)
    if self.processEvent(event) and not event.isAllowed:
      # MSDN: Return FALSE to reject the edited text and revert to the original label.
      # logic here is inverted !!
      ret = FALSE
    else:
      ret = TRUE

    return true # must return true

  of NM_DBLCLK, NM_RCLICK:
    var processed = false
    let (item, flag) = self.hitTest(self.screenToClient(wGetMessagePosition()))
    if item.isOk() and self.isReallyOnItem(flag):
      let msg =
        if code == NM_DBLCLK:
          wEvent_TreeItemActivated
        else:
          wEvent_TreeItemRightClick
      let event = self.TreeEvent(msg, item.mHandle)
      processed = self.processEvent(event)

    if code == NM_RCLICK and not processed:
      self.processMessage(wEvent_ContextMenu, WPARAM self.mHwnd, LPARAM GetMessagePos())

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

proc wTreeCtrl_OnChar(event: wEvent) =
  # Tree control don't have an activate notification code.
  # we need to generate it by ourself.
  var self = wBase.wTreeCtrl event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if event.getKeyCode() == wKey_Enter and
      (not event.shiftDown) and (not event.altDown) and (not event.winDown):

    let event = self.TreeEvent(wEvent_TreeItemActivated, TreeView_GetSelection(self.mHwnd))
    self.processEvent(event)

    # system's default handler for enter is just a annoyingly beep. avoid it.
    processed = true

proc wTreeCtrl_OnContextMenu(event: wEvent) =
  var self = wBase.wTreeCtrl event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  var pos = event.getPosition()
  var item: wTreeItem

  if pos == wDefaultPoint:
    item = self.getFocusedItem()
    var rect = item.getBoundingRect(textOnly=true)
    pos = (rect.x, rect.y + rect.height div 2)

  else:
    pos = self.screenToClient(pos)
    let tup = self.hitTest(pos)
    item = tup.item
    if item.isOk():
      if self.isReallyOnItem(tup.flag):
        item.select()
      else:
        item.unset()

  let event = self.TreeEvent(wEvent_TreeItemMenu, item.mHandle)
  event.mPoint = pos
  processed =  self.processEvent(event)

proc wTreeCtrl_OnMouseMove(event: wEvent) =
  var self = wBase.wTreeCtrl event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if self.mDragging:
    self.dragging(event.getMousePos())
    processed = true

proc wTreeCtrl_LeftUp(event: wEvent) =
  var self = wBase.wTreeCtrl event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if self.mDragging:
    self.endDrag()
    processed = true

proc wTreeCtrl_RightUp(event: wEvent) =
  var self = wBase.wTreeCtrl event.mWindow
  var processed = false
  defer: event.skip(if processed: false else: true)

  if self.mDragging:
    self.endDrag()
    processed = true
  else:
    # send wEvent_ContextMenu here, usually the happen when click on space area
    processed = self.processMessage(wEvent_ContextMenu, WPARAM self.mHwnd, LPARAM GetMessagePos())

proc wTreeCtrl_RightDown(event: wEvent) =
  # here we block the right down event if it's not click on item
  # becasue the default behavior will change focus even click on right space area
  var self = wBase.wTreeCtrl event.mWindow
  let (item, flag) = self.hitTest(event.getMousePos())
  if item.isOk() and self.isReallyOnItem(flag):
    item.select()
    event.skip

wClass(wTreeCtrl of wControl):

  method release*(self: wTreeCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wTreeCtrl, parent: wWindow, id: wCommandID = wDefaultID,
      pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wTrNoButtons) {.validate.} =
    ## Initializes a tree control.
    wValidate(parent)
    # for TVS_HASBUTTONS, TVS_LINESATROOT must also be specified.
    var style = style
    if (style and wTrTwistButtons) != 0 or (style and TVS_HASBUTTONS) != 0:
      style = style or TVS_LINESATROOT or TVS_HASBUTTONS

    self.wControl.init(className=WC_TREEVIEW, parent=parent, id=id, label="",
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    # a tree control by default have white background, not parent's background
    self.setBackgroundColor(wWhite)

    if (style and wTrTwistButtons) != 0:
      SetWindowTheme(self.mHwnd, "Explorer", nil)

    self.hardConnect(wEvent_Char, wTreeCtrl_OnChar)
    self.hardConnect(wEvent_ContextMenu, wTreeCtrl_OnContextMenu)
    self.hardConnect(wEvent_MouseMove, wTreeCtrl_OnMouseMove)
    self.hardConnect(wEvent_LeftUp, wTreeCtrl_LeftUp)
    self.hardConnect(wEvent_RightUp, wTreeCtrl_RightUp)
    self.hardConnect(wEvent_RightDown, wTreeCtrl_RightDown)

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Up, wKey_Down, wKey_Left, wKey_Right}:
        event.veto
