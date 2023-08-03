#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A IP control allows the user to enter an IP (v4) address in an easily
## understood format. Because of the limitation of Windows native control,
## IP control cannot change size after creation.
##
## Notice: a IP control may recieve events propagated from its child text
## control. (wEvent_Text, wEvent_TextUpdate, wEvent_TextMaxlen etc.)
## In these case, event.window should be the child text control, not IP control
## itself.
#
## :Appearance:
##   .. image:: images/wIpCtrl.png
#
## :Superclass:
##   `wControl <wControl.html>`_
#
## :Events:
##   `wIpEvent <wIpEvent.html>`_
##   `wCommandEvent <wCommandEvent.html>`_
##   ==============================   =============================================================
##   wIpEvent                         Description
##   ==============================   =============================================================
##   wEvent_IpChanged                 When the user changes a field or moves from one field to another.
##
##   wCommandEvent                    Description
##   ==============================   =============================================================
##   wEvent_Text                      When the text changes.
##   wEvent_TextUpdate                When the control is about to redraw itself.
##   wEvent_TextMaxlen                When the user tries to enter more text into the control than the limit.
##   wEvent_TextEnter                 When pressing Enter key.
##   ===============================  =============================================================

include ../pragma
import net
import ../wBase, wControl, wTextCtrl, ../gdiobjects/wFont
export wControl, wTextCtrl

method setWindowRect(self: wIpCtrl, x = 0, y = 0, width = 0, height = 0, flag = 0) {.inline, shield.} =
  # WC_IPADDRESS cannot change size after create, it's Windows's limitation.
  SetWindowPos(self.mHwnd, 0, x, y, 0, 0,
    UINT(flag or SWP_NOZORDER or SWP_NOREPOSITION or SWP_NOACTIVATE or SWP_NOSIZE))

proc setFocus*(self: wIpCtrl, index: range[0..3]) {.validate, property.} =
  ## Sets the focus to specified field.
  SendMessage(self.mHwnd, IPM_SETFOCUS, index, 0)

proc setValue*(self: wIpCtrl, value: int) {.validate, property.} =
  ## Sets the address values for all four fields in the IP address control.
  SendMessage(self.mHwnd, IPM_SETADDRESS, 0, value)

proc getValue*(self: wIpCtrl): int {.validate, property.} =
  ## Gets the address values for all four fields in the IP address control.
  discard SendMessage(self.mHwnd, IPM_GETADDRESS, 0, &result)

proc setIpAddress*(self: wIpCtrl, ipAddress: IpAddress) {.validate, property.} =
  ## Sets the address object for all four fields in the IP address control.
  if ipAddress.family == IpAddressFamily.IPv4:
    self.setValue(cast[int](MAKEIPADDRESS(ipAddress.address_v4[0],
      ipAddress.address_v4[1], ipAddress.address_v4[2], ipAddress.address_v4[3])))

proc getIpAddress*(self: wIpCtrl): IpAddress {.validate, property.} =
  ## Gets the address object for all four fields in the IP address control.
  let value = self.getValue()
  result = IpAddress(
    family: IpAddressFamily.IPv4,
    address_v4: [value.FIRST_IPADDRESS, value.SECOND_IPADDRESS,
      value.THIRD_IPADDRESS, value.FOURTH_IPADDRESS])

proc setText*(self: wIpCtrl, text: string) {.validate, property.} =
  ## Sets the address text for all four fields in the IP address control.
  self.setIpAddress(parseIpAddress(text))

proc getText*(self: wIpCtrl): string {.validate, property.} =
  ## Gets the address text for all four fields in the IP address control.
  let value = self.getValue()
  result = $value.FIRST_IPADDRESS
  result.add '.'
  result.add $value.SECOND_IPADDRESS
  result.add '.'
  result.add $value.THIRD_IPADDRESS
  result.add '.'
  result.add $value.FOURTH_IPADDRESS

proc clear*(self: wIpCtrl) {.validate.} =
  ## Clears the contents of the IP address control.
  SendMessage(self.mHwnd, IPM_CLEARADDRESS, 0, 0)

proc getEditControl*(self: wIpCtrl, index: range[0..3]): wTextCtrl
    {.validate, property, inline.} =
  ## Returns the text control part of the specified field.
  result = self.mEdits[index]

proc getTextCtrl*(self: wIpCtrl, index: range[0..3]): wTextCtrl
    {.validate, property, inline.} =
  ## Returns the text control part of the specified field.
  ## The same as getEditControl().
  result = self.getEditControl(index)

method processNotify(self: wIpCtrl, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool {.shield.} =

  if code == IPN_FIELDCHANGED:
    let lpnmipa = cast[LPNMIPADDRESS](lparam)
    let event = wIpEvent Event(window=self, msg=wEvent_IpChanged)
    event.mIndex = lpnmipa.iField
    event.mValue = lpnmipa.iValue
    if self.processEvent(event):
      lpnmipa.iValue = event.mValue
    return true

  return procCall wControl(self).processNotify(code, id, lParam, ret)

wClass(wIpCtrl of wControl):

  method release*(self: wIpCtrl) =
    ## Release all the resources during destroying. Used internally.
    free(self[])

  proc init*(self: wIpCtrl, parent: wWindow, id = wDefaultID, value: int = 0,
      pos = wDefaultPoint, size = wDefaultSize, font: wFont = nil,
      style: wStyle = 0) {.validate.} =
    ## Initializes a ip control.
    wValidate(parent)

    # need to count the init size for WC_IPADDRESS control.
    var size = size
    var font = if font != nil: font else: Font(parent.mFont)

    if size.width == wDefault:
      size.width = getTextFontSize(" 222 . 222 . 222 . 222 ", font.mHandle,
        self.mHwnd).width

    if size.height == wDefault:
      size.height = getLineControlDefaultHeight(font.mHandle)

    self.wControl.init(className=WC_IPADDRESS, parent=parent, id=id,
      pos=pos, size=size, style=style or WS_CHILD or WS_VISIBLE or WS_TABSTOP)

    self.setFont(font)
    if value != 0:
      self.setValue(value)

    # subclass all the child edit control and relay the navigation events to self
    proc EnumChildProc(hwnd: HWND, lParam: LPARAM): BOOL {.stdcall.} =
      let self = cast[wIpCtrl](lParam)
      for i in 0..3:
        if self.mEdits[i] == nil:
          self.mEdits[i] = TextCtrl(hwnd)
          break
      return TRUE

    EnumChildWindows(self.mHwnd, EnumChildProc, cast[LPARAM](self))

    for edit in self.mEdits:
      if edit != nil:
        edit.hardConnect(WM_CHAR) do (event: wEvent):
          if event.getKeyCode() == VK_RETURN:
            # try to send wEvent_TextEnter first.
            # If someone handle this, block the default behavior.
            if self.processMessage(wEvent_TextEnter, 0, 0):
              return

          if not self.processMessage(WM_CHAR, event.mWparam, event.mLparam, event.mResult):
            event.skip

        edit.hardConnect(WM_KEYDOWN) do (event: wEvent):
          if not self.processMessage(WM_KEYDOWN, event.mWparam, event.mLparam, event.mResult):
            event.skip

        edit.hardConnect(WM_SYSCHAR) do (event: wEvent):
          if not self.processMessage(WM_SYSCHAR, event.mWparam, event.mLparam, event.mResult):
            event.skip

    self.hardConnect(wEvent_Navigation) do (event: wEvent):
      if event.getKeyCode() in {wKey_Left, wKey_Right}:
        event.veto
