
const
  wNotFound* = -1



  # ToolBar or Menuitem kind
  wItemNormal* = TBSTYLE_BUTTON
  wItemSeparator* = TBSTYLE_SEP
  wItemCheck* = TBSTYLE_CHECK
  wItemRadio* = TBSTYLE_CHECKGROUP
  wItemDropDown* = BTNS_WHOLEDROPDOWN
  wItemSubMenu* = wItemDropDown





  # TextCtrl styles
  wTeMultiLine* = ES_MULTILINE
  wTeReadOnly* = ES_READONLY
  wTePassword* = ES_PASSWORD
  wTeNoHideSel* = ES_NOHIDESEL
  wTeLeft* = ES_LEFT
  wTeCentre* = ES_CENTER
  wTeRight* = ES_RIGHT
  # wTE_DONTWRAP* = wHScroll
  wTeRich* = 0x10000000 shl 32

  # SpinCtrl styles
  wSpArrowKeys* = UDS_ARROWKEYS
  wSpWrap* = UDS_ALIGNRIGHT # ** a hack value, see wSpinCtrl.nil
  wSpReadOnly* = wTeReadOnly



  # Imagelist styles and consts
  wImageListNormal* = LVSIL_NORMAL
  wImageListSmall* = LVSIL_SMALL
  wImageListState* = LVSIL_STATE

  # ListCtrl styles and consts
  wLcIcon* = LVS_ICON
  wLcSmallIcon* = LVS_SMALLICON
  wLcList* = LVS_LIST
  wLcReport* = LVS_REPORT
  wLcAlignLeft* = LVS_ALIGNLEFT
  wLcAlignTop* = LVS_ALIGNTOP
  wLcAutoArrange* = LVS_AUTOARRANGE
  wLcNoSortHeader* = LVS_NOSORTHEADER
  wLcNoHeader* = LVS_NOCOLUMNHEADER
  wLcEditLabels* = LVS_EDITLABELS
  wLcSingleSel* = LVS_SINGLESEL
  wLcSortAscending* = LVS_SORTASCENDING
  wLcSortDescending* = LVS_SORTDESCENDING
  wList_image_callback* = I_IMAGECALLBACK # -1
  wListImageNone* = I_IMAGENONE # -2
  wListAutosize* = LVSCW_AUTOSIZE # -1
  wListAutosizeUseHeader* = LVSCW_AUTOSIZE_USEHEADER # -2
  wListIgnore* = -3
  wListFormatLeft* = LVCFMT_LEFT
  wListFormatRight* = LVCFMT_RIGHT
  wListFormatCenter* = LVCFMT_CENTER
  wListStateFocused* = LVIS_FOCUSED
  wListStateSelected* = LVIS_SELECTED
  wListStateDropHighlighted* = LVIS_DROPHILITED
  wListStateCut* = LVIS_CUT
  wListRectBounds* = LVIR_BOUNDS
  wListRectIcon* = LVIR_ICON
  wListRectLabel* = LVIR_LABEL
  wListHittestAbove* = LVHT_ABOVE
  wListHittestBelow* = LVHT_BELOW
  wListHittestToleft* = LVHT_TOLEFT
  wListHittestToright* = LVHT_TORIGHT
  wListHittestNowhere* = LVHT_NOWHERE
  wListHittestOnItemLabel* = LVHT_ONITEMLABEL
  wListHittestOnItemIcon* = LVHT_ONITEMICON
  wListHittestOnItemStateicon* = LVHT_ONITEMSTATEICON

  # TreeCtrl styles and consts
  wTrNoButtons* = 0
  wTrHasButtons* = TVS_HASBUTTONS
  wTrHasLines* = TVS_HASLINES
  wTrEditLabels* = TVS_EDITLABELS
  wTrFullRowHighlight* = TVS_FULLROWSELECT
  wTrLinesAtRoot* = TVS_LINESATROOT
  wTrCheckBox* = TVS_CHECKBOXES
  wTrTwistButtons* = 0x10000000 shl 32
  wTrNoHScroll* = TVS_NOHSCROLL
  wTrNoScroll* = TVS_NOSCROLL
  wTrSingleExpand* = TVS_SINGLEEXPAND

  wTreeImageCallback* = I_IMAGECALLBACK # -1
  wTreeImageNone* = I_IMAGENONE # -2
  wTreeIgnore* = -3
  wTreeItemIconNormal* = 0
  wTreeItemIconSelected* = 1




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

  # MessageDialog styles
  wOk* = 1
  wYesNo* = 2
  wCancel* = 4
  wYesDefault* = 0x200
  wNoDefault* = 0x400
  wIconHand* = MB_ICONHAND # 0x10
  wIconErr* = MB_ICONERROR # 0x10
  wIconQuestion* = MB_ICONQUESTION # 0x20
  wIconExclamation* = MB_ICONEXCLAMATION # 0x30
  wIconInformation* = MB_ICONINFORMATION # 0x40
