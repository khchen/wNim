#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A radio button item is a button which usually denotes one of several mutually
## exclusive options.
#
## :Appearance:
##   .. image:: images/wRadioButton.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Styles:
##   ==============================  =============================================================
##   Styles                          Description
##   ==============================  =============================================================
##   wRbGroup                        Marks the beginning of a new group of radio buttons.
##   ==============================  =============================================================
#
## :Events:
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_RadioButton               The radio button is clicked.
##   ===============================  =============================================================

include ../pragma
import ../wBase, wControl
export wControl

const
  # RadioButton styles
  wRbGroup* = WS_GROUP

method getBestSize*(self: wRadioButton): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getTextFontSizeWithCheckMark(self.getLabel(), self.mFont.mHandle, self.mHwnd)
  result.height += 2

method getDefaultSize*(self: wRadioButton): wSize {.property.} =
  ## Returns the default size for the control.
  result = self.getBestSize()
  result.height = getLineControlDefaultHeight(self.mFont.mHandle)

proc getValue*(self: wRadioButton): bool {.validate, property, inline.} =
  ## Returns true if the radio button is checked, false otherwise.
  result = SendMessage(self.mHwnd, BM_GETCHECK, 0, 0) == BST_CHECKED

proc setValue*(self: wRadioButton, state: bool) {.validate, property, inline.} =
  ## Sets the radio button to checked or unchecked status.
  SendMessage(self.mHwnd, BM_SETCHECK, if state: BST_CHECKED else: BST_UNCHECKED, 0)

proc click*(self: wRadioButton) {.validate, inline.} =
  ## Simulates the user clicking a radiobutton.
  SendMessage(self.mHwnd, BM_CLICK, 0, 0)

wClass(wRadioButton of wControl):

  method release*(self: wRadioButton) =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mCommandConn)
    free(self[])

  proc init*(self: wRadioButton, parent: wWindow, id = wDefaultID,
      label: string = "", pos = wDefaultPoint, size = wDefaultSize,
      style: wStyle = 0) {.validate.} =
    ## Initializes radio button
    wValidate(parent)
    # clear last 4 bits, they indicates the button type (checkbox, radiobutton, etc)
    let style = (style and (not 0xF)) or BS_AUTORADIOBUTTON

    self.wControl.init(className=WC_BUTTON, parent=parent, id=id, label=label,
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    self.mCommandConn = parent.systemConnect(WM_COMMAND) do (event: wEvent):
      if event.mLparam == self.mHwnd and HIWORD(event.mWparam) == BN_CLICKED:
        self.processMessage(wEvent_RadioButton, event.mWparam, event.mLparam)
