DefineIncrement(wEvent_First):
  wEvent_Button
  wEvent_ButtonEnter
  wEvent_ButtonLeave
  wEvent_CheckBox
  wEvent_Choice
  wEvent_ListBox
  wEvent_ListBoxDoubleClick
  wEvent_CheckListBox
  wEvent_HyperLink
  wEvent_Menu
  wEvent_RadioBox
  wEvent_RadioButton
  wEvent_ComboBox
  wEvent_ToolRightClick
  wEvent_ToolDropDown
  wEvent_ToolEnter
  wEvent_ComboBoxDropDown
  wEvent_ComboBoxCloseUp
  wEvent_SpinCtrl
  wEvent_Text
  wEvent_TextCopy
  wEvent_TextCut
  wEvent_TextPaste
  wEvent_TextUpdated
  wEvent_TextEnter
  wEvent_TextMaxlen
  wEvent_CommandLeftClick
  wEvent_CommandLeftDoubleClick
  wEvent_CommandRightClick
  wEvent_CommandRightDoubleClick
  wEvent_CommandSetFocus
  wEvent_CommandKillFocus
  wEvent_CommandEnter
  wEvent_CommandTab
  wEvent_NoteBookPageChanged
  wEvent_NoteBookPageChanging
  wEvent_CalendarSelChanged
  wEvent_CalendarViewChanged
  wEvent_DateChanged

const
  wEventTool* = wEvent_Menu
  wEventTimeChanged* = wEvent_DateChanged

proc isCommandEvent(msg: UINT): bool {.inline.} =
  msg.isBetween(wEvent_First, wEvent_Last)

proc getCommandEvent(window: wWindow): UINT =
  if window of wFrame:
    result = wEvent_Menu
  elif window of wButton:
    result = wEvent_Button
  elif window of wCheckBox:
    result = wEvent_CheckBox
  elif window of wRadioButton:
    result = wEvent_RadioButton
  elif window of wToolBar:
    result = wEventTool
  else:
    assert true

