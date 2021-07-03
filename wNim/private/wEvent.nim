#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## *wEvent* and it's subclass hold information about an event passed to
## an event handler. An object of wWindow can be bound to an event handler
## by ``connect`` proc. For example:
##
## .. code-block:: Nim
##   var button = Button(panel, label="Button")
##   button.connect(wEvent_Button) do (event: wEvent):
##     discard
##
## If an event is generated from a control or menu, it may also associated with
## a wCommandID:
##
## .. code-block:: Nim
##   var frame = Frame()
##   frame.connect(wEvent_Menu, wIdExit) do (event: wEvent):
##     discard
##
## For frame, button, and toolbar, you can also simply connect to a wCommandID:
##
## .. code-block:: Nim
##   var frame = Frame()
##   frame.connect(wIdExit) do (event: wEvent):
##     discard
##
## If the event object is not used in the handler, it can be omitted. Moreover,
## dot is a symbol alias for ``connect``, so following is the simplest code:
##
## .. code-block:: Nim
##   var frame = Frame()
##   frame.wIdExit do ():
##     discard
##
## An event is usually generated from system. However, the user may define their
## own event type, create the event object, and pass to a window by
## wWindow.processEvent().
##
## **Notice: Event() is the only constructor for all event objects in wNim**.
## `import wNim/wEvent` **will import all of its subclasses automatically.**
#
## :Subclasses:
##   `wMouseEvent <wMouseEvent.html>`_
##   `wKeyEvent <wKeyEvent.html>`_
##   `wSizeEvent <wSizeEvent.html>`_
##   `wMoveEvent <wMoveEvent.html>`_
##   `wContextMenuEvent <wContextMenuEvent.html>`_
##   `wScrollWinEvent <wScrollWinEvent.html>`_
##   `wTrayEvent <wTrayEvent.html>`_
##   `wDragDropEvent <wDragDropEvent.html>`_
##   `wNavigationEvent <wNavigationEvent.html>`_
##   `wSetCursorEvent <wSetCursorEvent.html>`_
##   `wStatusBarEvent <wStatusBarEvent.html>`_
##   `wCommandEvent <wCommandEvent.html>`_
##   `wScrollEvent <wScrollEvent.html>`_
##   `wSpinEvent <wSpinEvent.html>`_
##   `wHyperlinkEvent <wHyperlinkEvent.html>`_
##   `wListEvent <wListEvent.html>`_
##   `wTreeEvent <wTreeEvent.html>`_
##   `wIpEvent <wIpEvent.html>`_
##   `wWebViewEvent <wWebViewEvent.html>`_
##   `wDialogEvent <wDialogEvent.html>`_
##   `wTextLinkEvent <wTextLinkEvent.html>`_
#
## :Events:
##   ================================  =============================================================
##   wEvent                            Description
##   ================================  =============================================================
##   wEvent_SetFocus                   A window has gained the keyboard focus.
##   wEvent_KillFocus                  A window is about to loses the keyboard focus.
##   wEvent_Show                       A window is about to be hidden or shown.
##   wEvent_Activate                   A window being activated or deactivated.
##   wEvent_Timer                      A timer expires.
##   wEvent_Paint                      A window's client area must be painted.
##   wEvent_NcPaint                    A window's frame must be painted.
##   wEvent_HotKey                     The user presses the registered hotkey.
##   wEvent_Close                      The user has tried to close a window. This event can be vetoed.
##   wEvent_MenuHighlight              The user selects a menu item (not clicks).
##   wEvent_Destroy                    A window is being destroyed.
##   wEvent_DpiChanged                 The effective dots per inch (dpi) for a window has changed.
##   wEvent_App                        Used to define private event type, usually of the form wEvent_App+x.
##   ================================  =============================================================

include pragma
import wBase

const
  wEvent_PropagateMax* = int INT_PTR.high
  wEvent_PropagateNone* = 0

wEventRegister(wEvent):
  wEvent_SetFocus= WM_SETFOCUS
  wEvent_KillFocus = WM_KILLFOCUS
  wEvent_Show = WM_SHOWWINDOW
  wEvent_Activate = WM_ACTIVATE
  wEvent_Timer = WM_TIMER
  wEvent_MenuHighlight = WM_MENUSELECT
  wEvent_Paint = WM_PAINT
  wEvent_NcPaint = WM_NCPAINT
  wEvent_HotKey = WM_HOTKEY
  wEvent_DpiChanged = 0x02E0 # WM_DPICHANGED
  wEvent_Close
  wEvent_Destroy

proc getEventObject*(self: wEvent): wWindow {.validate, property, inline.} =
  ## Returns the object (usually a window) associated with the event
  result = self.mWindow

proc getWindow*(self: wEvent): wWindow {.validate, property, inline.} =
  ## Returns the window associated with the event. The same as getEventObject().
  result = self.mWindow

proc getEventType*(self: wEvent): UINT {.validate, property, inline.} =
  ## Returns the type of the given event, such as wEvent_Button, aka message code.
  result = self.mMsg

proc getEventMessage*(self: wEvent): UINT {.validate, property, inline.} =
  ## Returns the message code of the given event. The same as getEventType().
  result = self.mMsg

proc getId*(self: wEvent): wCommandID {.validate, property, inline.} =
  ## Returns the ID associated with this event, aka command ID or menu ID.
  result = self.mID

proc getIntId*(self: wEvent): int {.validate, property, inline.} =
  ## Returns the ID associated with this event, aka command ID or menu ID.
  result = int self.mID

proc getTimerId*(self: wEvent): int {.validate, property, inline.} =
  ## Return the timer ID. Only for wEvent_Timer event.
  result = int self.mWparam

proc getHotkeyId*(self: wEvent): int {.validate, property, inline.} =
  ## Return the hotkey ID. Only for wEvent_HotKey event.
  result = int self.mWparam

proc getHotkey*(self: wEvent): tuple[modifiers: int, keyCode: int] {.validate, property, inline.} =
  ## Returns the hotkey. Valid for wEvent_HotKey, wEvent_HotkeyChanged, and wEvent_HotkeyChanging.
  result.modifiers = int LOWORD(self.mLparam)
  result.keyCode = int HIWORD(self.mLparam)

proc getlParam*(self: wEvent): LPARAM {.validate, property, inline.} =
  ## Returns the low-level LPARAM data of the associated windows message.
  result = self.mLparam

proc getwParam*(self: wEvent): WPARAM {.validate, property, inline.} =
  ## Returns the low-level WPARAM data of the associated windows message.
  result = self.mWparam

proc getResult*(self: wEvent): LRESULT {.validate, property, inline.} =
  ## Returns data that will be sent to system after event handler exit.
  result = self.mResult

proc setResult*(self: wEvent, ret: LRESULT) {.validate, property, inline.} =
  ## Set the data that will be sent to system after event handler exit.
  self.mResult = ret

proc getUserData*(self: wEvent): int {.validate, property, inline.} =
  ## Return the userdata associated with an event.
  result = self.mUserData

proc setUserData*(self: wEvent, userData: int) {.validate, property, inline.} =
  ## Set the userdata associated with an event.
  self.mUserData = userData

proc skip*(self: wEvent, skip = true) {.validate, inline.} =
  ## This proc can be used inside an event handler to control whether further
  ## event handlers bound to this event will be called after the current one
  ## returns. It sometimes means skip the default behavior for an event.
  self.mSkip = skip

proc `skip=`*(self: wEvent, skip: bool) {.validate, inline.} =
  ## Nim style setter for skip
  self.skip(skip)

proc veto*(self: wEvent) {.validate, inline.} =
  ## Prevents the change announced by this event from happening.
  # Most windows's message return non-zero value to "veto". So for convenience,
  # here just set mResult to TRUE. If somewhere the logic is inverted, deal with
  # the value clearly in the event handler.
  self.mResult = TRUE

proc deny*(self: wEvent) {.validate, inline.} =
  ## The same as veto().
  self.veto()

proc allow*(self: wEvent) {.validate, inline.} =
  ## This is the opposite of veto(): it explicitly allows the event to be
  ## processed.
  self.mResult = FALSE

proc isAllowed*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the change is allowed (veto() hasn't been called) or false
  ## otherwise (if it was).
  result = self.mResult != TRUE

proc stopPropagation*(self: wEvent): int {.validate, inline, discardable.} =
  ## Stop the event from propagating to its parent window.
  result = self.mPropagationLevel
  self.mPropagationLevel = 0

proc resumePropagation*(self: wEvent, propagationLevel = wEvent_PropagateMax)
    {.validate, inline.} =
  ## Sets the propagation level to the given value.
  self.mPropagationLevel = propagationLevel

proc getPropagationLevel*(self: wEvent): int {.validate, property, inline.} =
  ## Get how many levels the event can propagate.
  result = self.mPropagationLevel

proc setPropagationLevel*(self: wEvent, propagationLevel: int)
    {.validate, property, inline.}  =
  ## Set how many levels the event can propagate.
  self.mPropagationLevel = propagationLevel

proc lCtrlDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left ctrl key is pressed.
  result = self.mKeyStatus[wKey_LCtrl] < 0

proc lShiftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left shift key is pressed.
  result = self.mKeyStatus[wKey_LShift] < 0

proc lAltDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left alt key is pressed.
  result = self.mKeyStatus[wKey_LAlt] < 0

proc lWinDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left win key is pressed.
  result = self.mKeyStatus[wKey_LWin] < 0

proc rCtrlDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right ctrl key is pressed.
  result = self.mKeyStatus[wKey_RCtrl] < 0

proc rShiftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right shift key is pressed.
  result = self.mKeyStatus[wKey_RShift] < 0

proc rAltDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right alt key is pressed.
  result = self.mKeyStatus[wKey_RAlt] < 0

proc rWinDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right win key is pressed.
  result = self.mKeyStatus[wKey_RWin] < 0

proc ctrlDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any ctrl key is pressed.
  result = self.lCtrlDown() or self.rCtrlDown()

proc shiftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any shift key is pressed.
  result = self.lShiftDown() or self.rShiftDown()

proc altDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any alt key is pressed.
  result = self.lAltDown() or self.rAltDown()

proc winDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any win key is pressed.
  result = self.lWinDown() or self.rWinDown()

proc leftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left mouse button is currently down.
  result = self.mKeyStatus[wKeyLButton] < 0

proc rightDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right mouse button is currently down.
  result = self.mKeyStatus[wKeyRButton] < 0

proc middleDown*(self: wEvent): bool {.validate, inline.} =
  ##  Returns true if the middle mouse button is currently down.
  result = self.mKeyStatus[wKeyMButton] < 0

proc getKeyStatus*(self: wEvent): set[byte] {.validate, property, inline.} =
  ## Return a set of key-codes with all the pressed keys.
  ## The key-codes are defined in wKeyCodes.nim.
  ## For example:
  ##
  ## .. code-block:: Nim
  ##   echo wKey_Ctrl in event.keyStatus
  for key, val in self.mKeyStatus:
    if val < 0:
      result.incl byte key

proc getMouseScreenPos*(self: wEvent): wPoint {.validate, property, inline.} =
  ## Get coordinate of the cursor.
  ## The coordinate is relative to the screen.
  result = self.mMousePos

method getIndex*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getPosition*(self: wEvent): wPoint {.base, property.} = discard
  ## Method needs to be overridden.
method getKeyCode*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getSize*(self: wEvent): wSize {.base, property.} = discard
  ## Method needs to be overridden.
method setPosition*(self: wEvent, x: int, y: int) {.base, property.} = discard
  ## Method needs to be overridden.
method setPosition*(self: wEvent, pos: wPoint) {.base, property.} = discard
  ## Method needs to be overridden.
method getOrientation*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getScrollPos*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getKind*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getWheelRotation*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getSpinPos*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method setSpinPos*(self: wEvent, pos: int) {.base, property.} = discard
  ## Method needs to be overridden.
method getSpinDelta*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method setSpinDelta*(self: wEvent, delta: int) {.base, property.} = discard
  ## Method needs to be overridden.
method getUrl*(self: wEvent): string {.base, property.} = discard
  ## Method needs to be overridden.
method getLinkId*(self: wEvent): string {.base, property.} = discard
  ## Method needs to be overridden.
method getVisited*(self: wEvent): bool {.base, property.} = discard
  ## Method needs to be overridden.
method getCursor*(self: wEvent): wCursor {.base, property.} = discard
  ## Method needs to be overridden.
method setCursor*(self: wEvent, cursor: wCursor) {.base, property.} = discard
  ## Method needs to be overridden.
method getColumn*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getText*(self: wEvent): string {.base, property.} = discard
  ## Method needs to be overridden.
method getItem*(self: wEvent): wTreeItem {.base, property, raises: [].} = discard
  ## Method needs to be overridden.
method getOldItem*(self: wEvent): wTreeItem {.base, property, raises: [].} = discard
  ## Method needs to be overridden.
method getInsertMark*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getPoint*(self: wEvent): wPoint {.base, property.} = discard
  ## Method needs to be overridden.
method getDataObject*(self: wEvent): wDataObject {.base, property.} = discard
  ## Method needs to be overridden.
method getEffect*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method setEffect*(self: wEvent, effect: int) {.base, property.} = discard
  ## Method needs to be overridden.
method getValue*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method setValue*(self: wEvent, value: int) {.base, property.} = discard
  ## Method needs to be overridden.
method getMenuItem*(self: wEvent): wMenuItem {.base, property.} = discard
  ## Method needs to be overridden.
method getErrorCode*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getStart*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getEnd*(self: wEvent): int {.base, property.} = discard
  ## Method needs to be overridden.
method getMouseEvent*(self: wEvent): UINT {.base, property.} = discard
  ## Method needs to be overridden.

method shouldPropagate*(self: wEventBase): bool {.base.} =
  ## Test if this event should be propagated or not.
  ## This method can be override, for example:
  ##
  ## .. code-block:: Nim
  ##   method shouldPropagate(self: wEvent): bool =
  ##     if self.eventType == wEvent_Char:
  ##       result = true
  ##     else:
  ##       result = procCall shouldPropagate(wEventBase self)
  result = if self of wCommandEvent: true else: false

# Importing wEvent will also import (and export) all the subclasses automatically.

import events/[wMouseEvent, wKeyEvent, wSizeEvent, wMoveEvent, wContextMenuEvent,
  wScrollWinEvent, wTrayEvent, wDragDropEvent, wDialogEvent, wNavigationEvent,
  wSetCursorEvent, wCommandEvent]

export wMouseEvent, wKeyEvent, wSizeEvent, wMoveEvent, wContextMenuEvent,
  wScrollWinEvent, wTrayEvent, wDragDropEvent, wDialogEvent, wNavigationEvent,
  wSetCursorEvent, wCommandEvent

# Still proveding wEvent_App for backward compatible
wEventRegister(wEvent):
  wEvent_App

proc init*(self: wEvent, window: wWindow = nil, msg: UINT = 0, wParam: wWparam = 0,
    lParam: wLparam = 0, origin: HWND = 0, userData: int = 0) =
  ## Initializes an event.
  self.mWindow = window
  self.mOrigin = origin
  self.mMsg = msg
  self.mWparam = wParam
  self.mLparam = lParam
  self.mUserData = userData

  if self of wBase.wCommandEvent:
    self.mId = wCommandID LOWORD(wParam)

  if self.shouldPropagate():
    self.mPropagationLevel = wEvent_PropagateMax
  else:
    self.mPropagationLevel = wEvent_PropagateNone

  # save the status for the last message occured
  GetKeyboardState(cast[PBYTE](&self.mKeyStatus[0]))
  self.mMousePos = wGetMessagePosition()
  self.mClientPos = wDefaultPoint

template Event*(window: wWindow = nil, msg: UINT = 0, wParam: wWparam = 0,
    lParam: wLparam = 0, origin: HWND = 0, userData: int = 0): wEvent =
  ## Constructor.
  var self: wEvent = wEventCtor(msg)
  self.init(window, msg, wParam, lParam, origin, userData)
  self

import wWindow

proc getMousePos*(self: wEvent): wPoint {.validate, property.} =
  ## Get coordinate of the cursor.
  ## The coordinate is relative to the origin of the client area.
  if self.mClientPos == wDefaultPoint:
    self.mClientPos = self.mWindow.screenToClient(self.mMousePos)

  result = self.mClientPos

proc getX*(self: wEvent): int {.validate, property, inline.} =
  ## Get x-coordinate of the cursor.
  ## The coordinate is relative to the origin of the client area.
  result = self.getMousePos().x

proc getY*(self: wEvent): int {.validate, property, inline.} =
  ## Get y-coordinate of the cursor.
  ## The coordinate is relative to the origin of the client area.
  result = self.getMousePos().y
