
proc setColumnWidth*(self: wListCtrl, col, width: int) =
  SendMessage(mHwnd, LVM_SETCOLUMNWIDTH, col, width)

proc insertColumn*(self: wListCtrl, col: int, text: string, format=LVCFMT_LEFT, width = LVSCW_AUTOSIZE, imageIndex = wListImageNone): int {.discardable.} =
  var lvcol: LVCOLUMN
  lvcol.mask = LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
  lvcol.fmt = LVCFMT_RIGHT
  lvcol.pszText = &(T(text))
  lvcol.cx = if width < 0: 80 else: width

  if imageIndex != wListIgnore:
    lvcol.mask = lvcol.mask or LVCF_IMAGE
    lvcol.iImage = imageIndex.int32

  result = SendMessage(mHwnd, LVM_INSERTCOLUMN, col, addr lvcol).int
  if result != -1:
    mColCount.inc

    if width == LVSCW_AUTOSIZE_USEHEADER:
      setColumnWidth(result, LVSCW_AUTOSIZE_USEHEADER)

proc appendColumn*(self: wListCtrl, text: string, format=LVCFMT_LEFT, width = LVSCW_AUTOSIZE, imageIndex = wListImageNone): int {.discardable.} =
  insertColumn(mColCount, text, format, width, imageIndex)

proc deleteColumn*(self: wListCtrl, col: int) =
  if SendMessage(mHwnd, LVM_DELETECOLUMN, col, 0) != 0:
    mColCount.dec

proc setColumn*(self: wListCtrl, col: int, text: string = nil, format = 0, width = wListIgnore, imageIndex = wListIgnore) =
  if width != wListIgnore:
    setColumnWidth(col, width)

  var lvcol: LVCOLUMN
  if text != nil:
    lvcol.mask = lvcol.mask or LVCF_TEXT
    lvcol.pszText = &(T(text))

  if format != 0:
    lvcol.mask = lvcol.mask or LVCF_FMT
    lvcol.fmt = format.int32

  if imageIndex != wListIgnore:
    lvcol.mask = lvcol.mask or LVCF_IMAGE
    lvcol.iImage = imageIndex.int32

  SendMessage(mHwnd, LVM_SETCOLUMN, col, addr lvcol)

proc setColumnText*(self: wListCtrl, col: int, text: string) =
  setColumn(col, text=text)

proc setColumnFormat*(self: wListCtrl, col: int, format: int) =
  setColumn(col, format=format)

proc setColumnImage*(self: wListCtrl, col: int, imageIndex: int) =
  setColumn(col, imageIndex=imageIndex)

proc getColumnCount*(self: wListCtrl): int =
  result = mColCount

proc getColumnWidth*(self: wListCtrl, col: int): int =
  result = SendMessage(mHwnd, LVM_GETCOLUMNWIDTH, col, 0).int

proc getColumnFormat*(self: wListCtrl, col: int): int =
  var lvcol: LVCOLUMN
  lvcol.mask = LVCF_FMT
  SendMessage(mHwnd, LVM_GETCOLUMN, col, addr lvcol)
  result = lvcol.fmt.int

proc getColumnImage*(self: wListCtrl, col: int): int =
  var lvcol: LVCOLUMN
  lvcol.mask = LVCF_IMAGE
  SendMessage(mHwnd, LVM_GETCOLUMN, col, addr lvcol)
  result = lvcol.iImage.int

proc getColumnText*(self: wListCtrl, col: int): string =
  var
    buffer = T(65536)
  #   pbuffer = allocWString(65536)
  #   buffer = cast[wstring](pbuffer)
  # defer: dealloc(pbuffer)

  var lvcol: LVCOLUMN
  lvcol.mask = LVCF_TEXT
  lvcol.cchTextMax = 65536
  lvcol.pszText = &buffer

  if SendMessage(mHwnd, LVM_GETCOLUMN, col, addr lvcol) != 0:
    # buffer.setLen(lstrlen(&buffer))
    buffer.nullTerminate
    result = $buffer

proc getItemCount*(self: wListCtrl): int =
  result = SendMessage(mHwnd, LVM_GETITEMCOUNT, 0, 0).int

proc getItem(self: wListCtrl, index: int, col: int = 0): LVITEM =
  result.mask = LVIF_PARAM or LVIF_STATE or LVIF_IMAGE
  result.iItem = index.int32
  result.iSubItem = col.int32
  result.stateMask = 0xFFFFFFFF'i32
  discard SendMessage(mHwnd, LVM_GETITEM, 0, addr result)

proc getItemData*(self: wListCtrl, index: int): int =
  let item = getItem(index)
  result = cast[int](item.lParam)

proc getItemState*(self: wListCtrl, index: int): int =
  let item = getItem(index)
  result = item.state.int

proc getItemImage*(self: wListCtrl, index, col: int): int =
  let item = getItem(index, col)
  result = item.iImage.int

proc getItemText*(self: wListCtrl, index, col: int): string =
  var buffer = T(65536)
  # var
  #   pbuffer = allocWString(65536)
  #   buffer = cast[wstring](pbuffer)
  # defer: dealloc(pbuffer)

  var item: LVITEM
  item.mask = LVIF_TEXT
  item.iItem = index.int32
  item.iSubItem = col.int32
  item.cchTextMax = 65536
  item.pszText = &buffer

  if SendMessage(mHwnd, LVM_GETITEM, 0, addr item) != 0:
    # buffer.setLen(lstrlen(&buffer))
    buffer.nullTerminate
    result = $buffer

proc insertItem*(self: wListCtrl, index: int, text: string, imageIndex = wListImageNone): int {.discardable.} =
  var item: LVITEM
  item.mask = LVIF_TEXT
  item.iItem = index.int32
  item.pszText = &(T(text))

  if imageIndex != wListIgnore:
    item.mask = item.mask or LVIF_IMAGE
    item.iImage = imageIndex.int32

  result = SendMessage(mHwnd, LVM_INSERTITEM, 0, addr item).int

proc appendItem*(self: wListCtrl, text: string, imageIndex = wListImageNone): int {.discardable.} =
  result = insertItem(getItemCount(), text, imageIndex)

proc insertItem*(self: wListCtrl, index: int, imageIndex: int): int {.discardable.} =
  var item: LVITEM
  item.iItem = index.int32

  if imageIndex != wListIgnore:
    item.mask = LVIF_IMAGE
    item.iImage = imageIndex.int32

  result = SendMessage(mHwnd, LVM_INSERTITEM, 0, addr item).int

proc appendItem*(self: wListCtrl, imageIndex: int): int {.discardable.} =
  result = insertItem(getItemCount(), imageIndex)

proc setItem*(self: wListCtrl, index, col: int = 0, text: string = nil, imageIndex = wListIgnore, state = 0, flag = true) =
  var item: LVITEM
  item.iItem = index.int32
  item.iSubItem = col.int32

  if text != nil:
    item.mask = item.mask or LVIF_TEXT
    item.pszText = &(T(text))

  if imageIndex != wListIgnore:
    item.mask = item.mask or LVIF_IMAGE
    item.iImage = imageIndex.int32

  if state != 0:
    item.mask = item.mask or LVIF_STATE
    item.stateMask = state.int32
    item.state = if flag: state.int32 else: 0

  SendMessage(mHwnd, LVM_SETITEM, 0, addr item)

proc setItemText*(self: wListCtrl, index, col: int, text: string) =
  setItem(index, col, text=text)

proc setItemState*(self: wListCtrl, index, state: int, flag = true) =
  setItem(index, 0, state=state, flag=flag)

proc setItemColumnImage*(self: wListCtrl, index, col, imageIndex: int) =
  setItem(index, col, imageIndex=imageIndex)

proc setItemImage*(self: wListCtrl, index, col, imageIndex: int) =
  setItem(index, col, imageIndex=imageIndex)

proc setItemData*(self: wListCtrl, index: int, data: int) =
  var item: LVITEM
  item.mask = LVIF_PARAM
  item.iItem = index.int32
  item.lParam = cast[LPARAM](data)
  SendMessage(mHwnd, LVM_SETITEM, 0, addr item)

proc insertItem*(self: wListCtrl, index: int, texts: openarray[string], imageIndex = wListImageNone): int {.discardable.} =
  assert texts.len >= 1
  result = insertItem(index, texts[0], imageIndex)
  for i in 1..<texts.len:
    setItem(result, i, texts[i])

proc appendItem*(self: wListCtrl, texts: openarray[string], imageIndex = wListImageNone): int {.discardable.} =
  insertItem(getItemCount(), texts, imageIndex)

proc deleteItem*(self: wListCtrl, index: int) =
  SendMessage(mHwnd, LVM_DELETEITEM, index, 0)

proc deleteAllItems*(self: wListCtrl) =
  SendMessage(mHwnd, LVM_DELETEALLITEMS, 0, 0)

proc deleteAllColumns*(self: wListCtrl) =
  while mColCount > 0:
    deleteColumn(0)

proc clearAll*(self: wListCtrl) =
  deleteAllItems()
  deleteAllColumns()

iterator items*(self: wListCtrl): string =
  let count = getItemCount()
  var i = 0
  while i < count:
    yield getItemText(i, 0)
    i.inc

proc len*(self: wListCtrl): int =
  result = getItemCount()

proc findItem*(self: wListCtrl, start: int, text: string, partial = false): int =
  var
    findInfo: LVFINDINFO
    start = start

  findInfo.flags = if partial: LVFI_PARTIAL else: LVFI_STRING
  findInfo.psz = T(text)

  # LVM_FINDITEM excludes the first item
  if start != -1: start.dec
  result = SendMessage(mHwnd, LVM_FINDITEM, start, addr findInfo).int

proc findItem*(self: wListCtrl, start: int, data: int): int =
  var
    findInfo: LVFINDINFO
    start = start

  findInfo.flags = LVFI_PARAM
  findInfo.lParam = cast[LPARAM](data)

  # LVM_FINDITEM excludes the first item
  if start != -1: start.dec
  result = SendMessage(mHwnd, LVM_FINDITEM, start, addr findInfo).int

proc getItemPosition*(self: wListCtrl, index: int): wPoint =
  var pt: POINT
  SendMessage(mHwnd, LVM_GETITEMPOSITION, index, addr pt)
  result.x = pt.x.int
  result.y = pt.y.int

proc setItemPosition*(self: wListCtrl, index: int, pos: wPoint) =
  var pt: POINT
  pt.x = pos.x.int32
  pt.y = pos.y.int32
  SendMessage(mHwnd, LVM_SETITEMPOSITION32, index, addr pt)

proc getItemSpacing*(self: wListCtrl): wSize =
  let isSmall = (GetWindowLongPtr(mHwnd, GWL_STYLE) and LVS_SMALLICON) != 0
  let spacing = SendMessage(mHwnd, LVM_GETITEMSPACING, isSmall, 0)
  result.width = LOWORD(spacing).int
  result.height = HIWORD(spacing).int

proc getTopItem*(self: wListCtrl): int =
  result = SendMessage(mHwnd, LVM_GETTOPINDEX, 0, 0).int

proc getCountPerPage*(self: wListCtrl): int =
  result = SendMessage(mHwnd, LVM_GETCOUNTPERPAGE, 0, 0).int

proc getItemRect*(self: wListCtrl, index: int, code = LVIR_BOUNDS): wRect =
  var rect = RECT(left: code.int32)
  SendMessage(mHwnd, LVM_GETITEMRECT, index, addr rect)
  result = toWRect(rect)

proc inReportView*(self: wListCtrl): bool =
  result = (GetWindowLongPtr(mHwnd, GWL_STYLE) and LVS_REPORT) != 0

proc getSubItemRect*(self: wListCtrl, index, col: int, code = LVIR_BOUNDS): wRect =
  # only meaningful when the wListCtrl is in the report mode
  assert inReportView()

  var rect = RECT(top: col.int32, left: code.int32)
  SendMessage(mHwnd, LVM_GETSUBITEMRECT, index, addr rect)
  result = toWRect(rect)

  if col == 0:
    # fix width if col = 0, it will return full row width
    result.width = getColumnWidth(0)

proc getViewRect*(self: wListCtrl): wRect =
  if (GetWindowLongPtr(mHwnd, GWL_STYLE) and LVS_REPORT) != 0:
    let count = getItemCount()
    if count > 0:
      result = getItemRect(min(getTopItem() + getCountPerPage(), count - 1))
      result.height += result.y
      result.y = 0
  else:
    var rect: RECT
    SendMessage(mHwnd, LVM_GETVIEWRECT, 0, addr rect)
    result = toWRect(rect)

proc setImageList(self: wListCtrl, imageList: wImageList, which = LVSIL_SMALL, owns: bool) =
  case which
  of LVSIL_NORMAL:
    mImageListNormal = imageList
    mOwnsImageListNormal = owns
  of LVSIL_SMALL:
    mImageListSmall = imageList
    mOwnsImageListSmall = owns
  of LVSIL_STATE:
    mImageListState = imageList
    mOwnsImageListState = owns
  else: return
  SendMessage(mHwnd, LVM_SETIMAGELIST, which, imageList.mHandle)

proc setImageList*(self: wListCtrl, imageList: wImageList, which = LVSIL_SMALL) =
  setImageList(imageList, which, owns=false)

proc assignImageList*(self: wListCtrl, imageList: wImageList, which = LVSIL_SMALL) =
  setImageList(imageList, which, owns=true)

proc getImageList*(self: wListCtrl, which = LVSIL_SMALL): wImageList =
  result = case which
  of LVSIL_NORMAL: mImageListNormal
  of LVSIL_SMALL: mImageListSmall
  of LVSIL_STATE: mImageListState
  else: nil

proc setTextColor*(self: wListCtrl, color: wColor) =
  SendMessage(mHwnd, LVM_SETTEXTCOLOR, 0, color)

proc getTextColor*(self: wListCtrl): wColor =
  result = SendMessage(mHwnd, LVM_GETTEXTCOLOR, 0, 0).wColor

method setBackgroundColor*(self: wListCtrl, color: wColor) =
  procCall wWindow(self).setBackgroundColor(color)
  SendMessage(mHwnd, LVM_SETTEXTBKCOLOR, 0, color)
  SendMessage(mHwnd, LVM_SETBKCOLOR, 0, color)

method setForegroundColor*(self: wListCtrl, color: wColor) =
  procCall wWindow(self).setForegroundColor(color)
  setTextColor(color)

proc setAlternateRowColor*(self: wListCtrl, color: wColor) =
  mAlternateRowColor = color

proc getAlternateRowColor*(self: wListCtrl): wColor =
  result = mAlternateRowColor

proc disableAlternateRowColors*(self: wListCtrl) =
  mAlternateRowColor = 0xFFFFFFFF'i32.wColor

proc enableAlternateRowColors*(self: wListCtrl, flag = true) =
  if flag:
    if mAlternateRowColor == 0xFFFFFFFF'i32.wColor:
      let
        r = (mBackgroundColor.GetRValue().float * 0.9).byte
        g = (mBackgroundColor.GetGValue().float * 0.9).byte
        b = (mBackgroundColor.GetBValue().float * 0.9).byte

      mAlternateRowColor = RGB(r, g, b)

  else:
    disableAlternateRowColors()

proc getSelectedItemCount*(self: wListCtrl): int =
  result = SendMessage(mHwnd, LVM_GETSELECTEDCOUNT, 0, 0).int

proc getColumnsOrder*(self: wListCtrl): seq[int] =
  var buffer = newSeq[int32](mColCount)
  newSeq(result, mColCount)
  if SendMessage(mHwnd, LVM_GETCOLUMNORDERARRAY, mColCount, addr buffer[0]) != 0:
    for i in 0..<mColCount:
      result[i] = buffer[i]

proc setColumnsOrder*(self: wListCtrl, orders: openarray[int]) =
  var buffer = newSeq[int32](orders.len)
  for i in 0..<orders.len:
    buffer[i] = orders[i].int32
  SendMessage(mHwnd, LVM_SETCOLUMNORDERARRAY, orders.len, addr buffer[0])

proc ensureVisible*(self: wListCtrl, index: int) =
  SendMessage(mHwnd, LVM_ENSUREVISIBLE, index, false)

proc hitTest*(self: wListCtrl, x, y: int): tuple[index, col, flag: int] =
  var hitTestInfo: LV_HITTESTINFO
  hitTestInfo.pt.x = x.int32
  hitTestInfo.pt.y = y.int32
  result.index = SendMessage(mHwnd, LVM_SUBITEMHITTEST, 0, addr hitTestInfo).int
  result.col = hitTestInfo.iSubItem.int
  result.flag = hitTestInfo.flags.int

proc hitTest*(self: wListCtrl, pos: wPoint): tuple[index, col, flag: int] =
  result = hitTest(pos.x, pos.y)

type
  wInternalDataSort = object
    fn: proc (item1, item2, data: int): int
    data: int

proc dataCompareFunc(lparam1, lparam2, lparamSort: LPARAM): int32 {.stdcall.} =
  let pDataSort = cast[ptr wInternalDataSort](lparamSort)
  result = pDataSort[].fn(cast[int](lparam1), cast[int](lparam2), pDataSort[].data).int32

proc sortItems*(self: wListCtrl, callback: proc (itemData1, itemData2, data: int): int, data: int = 0) =
  var dataSort: wInternalDataSort
  dataSort.data = data
  dataSort.fn = callback
  SendMessage(mHwnd, LVM_SORTITEMS, addr dataSort, dataCompareFunc)

proc sortItemsByIndex*(self: wListCtrl, callback: proc (itemIndex1, itemIndex2, data: int): int, data: int = 0) =
  var dataSort: wInternalDataSort
  dataSort.data = data
  dataSort.fn = callback
  SendMessage(mHwnd, LVM_SORTITEMSEX, addr dataSort, dataCompareFunc)

proc setExtendedStyle*(self: wListCtrl, exStyle: DWORD, flag = true) =
  SendMessage(mHwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, exStyle, if flag: exStyle else: 0)

proc getExtendedStyle*(self: wListCtrl): DWORD =
  SendMessage(mHwnd, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0).DWORD

proc subclassEdit(self: wListCtrl, hwnd: HWND): wTextCtrl =
  if hwnd != 0:
    # todo: a dirty hack here, fix it
    let textctrl = TextCtrl(parent=self, pos=(0, 0), size=(0, 0))
    textctrl.mKeyUsed = {wUSE_TAB, wUSE_SHIFT_TAB, wUSE_ENTER, wUSE_RIGHT, wUSE_LEFT, wUSE_UP, wUSE_DOWN}
    let oldEditHwnd = textctrl.subclass(hwnd)
    DestroyWindow(oldEditHwnd)

    textctrl.systemConnect(WM_NCDESTROY) do(event: wEvent):
      self.mTextCtrl = nil

    return textctrl

proc getEditControl*(self: wListCtrl): wTextCtrl =
  let hwnd = SendMessage(mHwnd, LVM_GETEDITCONTROL, 0, 0).HWND
  if hwnd != 0:
    assert mTextCtrl.mHwnd == hwnd
    result = mTextCtrl

proc editLabel*(self: wListCtrl, index: int): wTextCtrl =
  let hwnd = SendMessage(mHwnd, LVM_EDITLABEL, index, 0).HWND
  if hwnd != 0:
    assert mTextCtrl.mHwnd == hwnd
    result = mTextCtrl

proc endEditLabel*(self: wListCtrl, cancel = false) =
  let hwnd = SendMessage(mHwnd, LVM_GETEDITCONTROL, 0, 0).HWND
  if hwnd != 0:
    SendMessage(hwnd, WM_KEYDOWN, if cancel: VK_ESCAPE else: VK_RETURN, 0)

method getBestSize*(self: wListCtrl): wSize =
  result = getDefaultSize() # default size as minimal size

  let
    ret = SendMessage(mHwnd, LVM_APPROXIMATEVIEWRECT, -1, -1)
    width = LOWORD(ret).int
    height = HIWORD(ret).int

  if width > result.width: result.width = width
  if height > result.height: result.height = height

# proc wListCtrlNotifyHandler(self: wListCtrl, code: INT, id: UINT_PTR, lparam: LPARAM, processed: var bool): LRESULT =
#   let isHeaderNotify = (cast[LPNMHDR](lparam).hwndFrom != mHwnd)
#   var isEditNotify = false
#   var eventType: UINT = 0

#   case code
#   of HDN_BEGINDRAG: eventType = wEvent_ListColBeginMove
#   of HDN_ENDDRAG: eventType = wEvent_ListColEndMove
#   of HDN_BEGINTRACK: eventType = wEvent_ListColBeginDrag
#   of HDN_ENDTRACK: eventType = wEvent_ListColEndDrag
#   of HDN_ITEMCHANGING: eventType = wEvent_ListColDragging
#   of LVN_COLUMNCLICK: eventType = wEvent_ListColClick

#   of LVN_BEGINDRAG: eventType = wEvent_ListBeginDrag
#   of LVN_BEGINRDRAG: eventType = wEvent_ListBeginRightDrag
#   of LVN_DELETEITEM: eventType = wEvent_ListDeleteItem
#   of LVN_DELETEALLITEMS: eventType = wEvent_ListDeleteAllItems
#   of LVN_INSERTITEM: eventType = wEvent_ListInsertItem
#   of LVN_KEYDOWN: eventType = wEvent_ListKeyDown
#   of LVN_ITEMACTIVATE: eventType = wEvent_ListItemActivated

#   of LVN_BEGINLABELEDIT:
#     isEditNotify = true
#     eventType = wEvent_ListBeginLabelEdit
#     mTextCtrl = subclassEdit(SendMessage(mHwnd, LVM_GETEDITCONTROL, 0, 0).HWND)

#   of LVN_ENDLABELEDIT:
#     isEditNotify = true
#     eventType = wEvent_ListEndLabelEdit

#   of NM_RCLICK:
#     eventType = if isHeaderNotify: wEvent_ListColRightClick else: wEvent_ListItemRightClick

#   of LVN_ITEMCHANGED:
#     let pnmv = cast[LPNMLISTVIEW](lparam)
#     if (pnmv.uChanged and LVIF_STATE) != 0 and pnmv.iItem != -1:
#       const
#         LVIS_CHECKED = 0x2000
#         LVIS_UNCHECKED = 0x1000
#       let
#         oldSt = pnmv.uOldState
#         newSt = pnmv.uNewState

#       # focus changed ?
#       if (oldSt and LVIS_FOCUSED) == 0 and (newSt and LVIS_FOCUSED) != 0:
#         eventType = wEvent_ListItemFocused

#       if (oldSt and LVIS_SELECTED) != (newSt and LVIS_SELECTED):
#         if eventType == wEvent_ListItemFocused:
#           # focus and selection have both changed, invoke focus event first
#           discard self.mMessageHandler(self, wEvent_ListItemFocused, cast[WPARAM](id), lparam, processed)
#           processed = false

#         eventType = if (newSt and LVIS_SELECTED) != 0: wEvent_ListItemSelected else: wEvent_ListItemDeselected

#       if (newSt and LVIS_STATEIMAGEMASK) != (oldSt and LVIS_STATEIMAGEMASK):
#         if oldSt != INDEXTOSTATEIMAGEMASK(0):
#           if newSt == INDEXTOSTATEIMAGEMASK(1):
#             eventType = wEvent_ListitemUnchecked
#           elif newSt == INDEXTOSTATEIMAGEMASK(2):
#             eventType = wEvent_ListitemChecked

#   else: discard

#   if eventType != 0:
#     var
#       lparam = lparam
#       pnmh = cast[LPNMHDR](lparam)
#       nmv: NMLISTVIEW

#     if isHeaderNotify:
#       # try to create a fake NMLISTVIEW object
#       var info: HDHITTESTINFO
#       GetCursorPos(info.pt)
#       ScreenToClient(pnmh.hwndFrom, info.pt)
#       SendMessage(pnmh.hwndFrom, HDM_HITTEST, 0, addr info)

#       nmv.hdr = pnmh[]
#       nmv.iItem = -1
#       nmv.iSubItem = info.iItem
#       nmv.ptAction = info.pt
#       lparam = cast[LPARAM](addr nmv)

#     elif isEditNotify:
#       let nmdisp = cast[LPNMLVDISPINFO](lparam)
#       nmv.hdr = pnmh[]
#       nmv.iItem = nmdisp.item.iItem
#       nmv.iSubItem = nmdisp.item.iSubItem
#       lparam = cast[LPARAM](addr nmv)

#     result = self.mMessageHandler(self, eventType, cast[WPARAM](id), lparam, processed)
#     if eventType == wEvent_ListEndLabelEdit:
#       #logic here is inverted
#       result = if result == 0: 1 else: 0
#   else:
#     result = self.wControlNotifyHandler(code, id, lparam, processed)

proc init(self: wListCtrl, parent: wWindow, id: wCommandID = -1, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0) =
  assert parent != nil

  self.wControl.init(className=WC_LISTVIEW, parent=parent, id=id, label="", pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP or LVS_SHAREIMAGELISTS or LVS_SHOWSELALWAYS)

  SendMessage(mHwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_LABELTIP or LVS_EX_FULLROWSELECT or LVS_EX_SUBITEMIMAGES or LVS_EX_HEADERDRAGDROP)

  mKeyUsed = {wUSE_RIGHT, wUSE_LEFT, wUSE_UP, wUSE_DOWN, wUSE_ENTER}

  # set default background color
  setBackgroundColor(SendMessage(mHwnd, LVM_GETBKCOLOR, 0, 0).wColor)
  disableAlternateRowColors()

  systemConnect(WM_NCDESTROY) do (event: wEvent):
    if mOwnsImageListNormal: delete mImageListNormal
    if mOwnsImageListSmall: delete mImageListSmall
    if mOwnsImageListState:  delete mImageListState
    mImageListNormal = nil
    mImageListSmall = nil
    mImageListState = nil

  hardConnect(WM_PAINT) do (event: wEvent):
    if not self.inReportView() or mAlternateRowColor == 0xFFFFFFFF'i32.wColor:
      event.mSkip = true

    else:
      var rectUpdate, rectDraw, rectItem: RECT
      let
        countPerPage = self.getCountPerPage()
        topItem = self.getTopItem()

      GetUpdateRect(mHwnd, addr rectUpdate, false)
      CallWindowProc(mSubclassedOldProc, mHwnd, WM_PAINT, 0, 0)

      for i in topItem..topItem+countPerPage:
        rectItem.left = LVIR_BOUNDS
        if SendMessage(mHwnd, LVM_GETITEMRECT, i, addr rectItem) == 0:
          continue

        if IntersectRect(addr rectDraw, addr rectUpdate, addr rectItem) != 0:
          let color = if i mod 2 == 0: mBackgroundColor else: mAlternateRowColor
          SendMessage(mHwnd, LVM_SETTEXTBKCOLOR, 0, color)
          SendMessage(mHwnd, LVM_SETBKCOLOR, 0, color)

          InvalidateRect(mHwnd, addr rectDraw, true)
          CallWindowProc(mSubclassedOldProc, mHwnd, WM_PAINT, 0, 0)

      # restore the background color
      SendMessage(mHwnd, LVM_SETTEXTBKCOLOR, 0, mBackgroundColor)
      SendMessage(mHwnd, LVM_SETBKCOLOR, 0, mBackgroundColor)

proc ListCtrl*(parent: wWindow, id: wCommandID = wDefaultID, pos = wDefaultPoint, size = wDefaultSize, style: int64 = 0): wListCtrl {.discardable.} =
  new(result)
  result.init(parent=parent, id=id, pos=pos, size=size, style=style)

# for wListEvent

# proc getColumn*(self: wListEvent): int =
#   let pnmv = cast[LPNMLISTVIEW](mLparam)
#   # The iItem member is -1, and the iSubItem member identifies the column
#   result = pnmv.iSubItem.int

# proc getIndex*(self: wListEvent): int =
#   let pnmv = cast[LPNMLISTVIEW](mLparam)
#   result = pnmv.iItem.int

# proc getPoint*(self: wListEvent): wPoint =
#   let pnmv = cast[LPNMLISTVIEW](mLparam)
#   result.x = pnmv.ptAction.x.int
#   result.y = pnmv.ptAction.y.int

# proc getState*(self: wListEvent): int =
#   let pnmv = cast[LPNMLISTVIEW](mLparam)
#   result = pnmv.uNewState.int

# proc getOldState*(self: wListEvent): int =
#   let pnmv = cast[LPNMLISTVIEW](mLparam)
#   result = pnmv.uOldState.int

# proc getKeyCode*(self: wListEvent): int =
#   let pnmv = cast[LPNMLVKEYDOWN](mLparam)
#   result = pnmv.wVKey.int

# nim style getter/setter

proc columnCount*(self: wListCtrl): int = getColumnCount()
proc itemCount*(self: wListCtrl): int = getItemCount()
proc itemSpacing*(self: wListCtrl): wSize = getItemSpacing()
proc topItem*(self: wListCtrl): int = getTopItem()
proc countPerPage*(self: wListCtrl): int = getCountPerPage()
proc viewRect*(self: wListCtrl): wRect = getViewRect()
proc textColor*(self: wListCtrl): wColor = getTextColor()
proc alternateRowColor*(self: wListCtrl): wColor = getAlternateRowColor()
proc selectedItemCount*(self: wListCtrl): int = getSelectedItemCount()
proc columnsOrder*(self: wListCtrl): seq[int] = getColumnsOrder()
proc editControl*(self: wListCtrl): wTextCtrl = getEditControl()
proc `textColor=`*(self: wListCtrl, color: wColor) = setTextColor(color)
proc `backgroundColor=`*(self: wListCtrl, color: wColor) = setBackgroundColor(color)
proc `alternateRowColor=`*(self: wListCtrl, color: wColor) = setAlternateRowColor(color)
proc `columnsOrder=`*(self: wListCtrl, orders: openarray[int]) = setColumnsOrder(orders)
