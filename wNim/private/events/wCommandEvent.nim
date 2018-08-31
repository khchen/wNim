#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2018 Ward
#
#====================================================================

DefineIncrement(wEvent_CommandFirst):
  wEvent_Button
  wEvent_ButtonEnter
  wEvent_ButtonLeave
  wEvent_CheckBox
  wEvent_Choice
  wEvent_ListBox
  wEvent_ListBoxDoubleClick
  wEvent_CheckListBox
  wEvent_Menu
  wEvent_RadioBox
  wEvent_RadioButton
  wEvent_ComboBox
  wEvent_ToolRightClick
  wEvent_ToolDropDown
  wEvent_ToolEnter
  wEvent_ComboBoxDropDown
  wEvent_ComboBoxCloseUp
  wEvent_Text
  wEvent_TextCopy
  wEvent_TextCut
  wEvent_TextPaste
  wEvent_TextUpdate
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
  wEvent_TimeChanged* = wEvent_DateChanged

proc isCommandEvent(msg: UINT): bool {.inline.} =
  msg in wEvent_CommandFirst..wEvent_CommandLast
