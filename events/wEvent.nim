const
  wEvent_PropagateMax* = int INT_PTR.high
  wEvent_PropagateNone* = 0

  wEvent_SetFocus* = WM_SETFOCUS
  wEvent_Show* = WM_SHOWWINDOW
  wEvent_KillFocus* = WM_KILLFOCUS
  wEvent_Horizontal* = WM_HSCROLL
  wEvent_Vertical* = WM_VSCROLL
  wEvent_Activate* = WM_ACTIVATE
  wEvent_Destroy* = WM_DESTROY
  wEvent_CloseWindow* = WM_CLOSE
  wEvent_Close* = WM_CLOSE
  wEvent_Timer* = WM_TIMER
  wEvent_InitDialog* = WM_INITDIALOG
  wEvent_MenuHighlight* = WM_MENUSELECT
  wEvent_Paint* = WM_PAINT
  wEvent_NcPaint* = WM_NCPAINT

  # wEvent_AppQuit = WM_APP + 1
  # wEvent_Navigation* = WM_APP + 2
  # wEvent_MouseEnter* = WM_APP + 51

  wEvent_ScrollWinFirst = WM_APP + 100
  wEvent_CommandFirst = WM_APP + 150
  wEvent_StatusBarFirst = WM_APP + 200
  wEvent_ScrollFirst = WM_APP + 250
  wEvent_ListFirst = WM_APP + 300
  wEvent_TreeFirst = WM_APP + 350
  wEvent_CommandLast = WM_APP + 400
  wEvent_UserFirst* = wEvent_CommandLast + 1

proc isMouseEvent(msg: UINT): bool {.inline.}
proc isKeyEvent(msg: UINT): bool {.inline.}
proc isSizeEvent(msg: UINT): bool {.inline.}
proc isMoveEvent(msg: UINT): bool {.inline.}
proc isContextMenuEvent(msg: UINT): bool {.inline.}
proc isScrollWinEvent(msg: UINT): bool {.inline.}
proc isCommandEvent(msg: UINT): bool {.inline.}
proc isScrollEvent(msg: UINT): bool {.inline.}
proc isListEvent(msg: UINT): bool {.inline.}
proc isTreeEvent(msg: UINT): bool {.inline.}
proc isStatusBarEvent(msg: UINT): bool {.inline.}

proc defaultPropagationLevel(msg: UINT): int =
  if msg.isCommandEvent() or wAppIsMessagePropagation(msg):
    result = wEvent_PropagateMax
  else:
    result = 0

proc Event*(window: wWindow = nil, msg: UINT = 0, wParam: WPARAM = 0, lParam: LPARAM = 0,
    origin: HWND = 0, userData: int = 0): wEvent =
  ## Constructor.

  template CreateEvent(Constructor: untyped): untyped =
    Constructor(mWindow: window, mMsg: msg, mWparam: wParam, mLparam: lParam,
      mOrigin: origin, mUserData: userData)

  if msg.isMouseEvent():
    result = CreateEvent(wMouseEvent)

  elif msg.isKeyEvent():
    result = CreateEvent(wKeyEvent)

  elif msg.isSizeEvent():
    result = CreateEvent(wSizeEvent)

  elif msg.isMoveEvent():
    result = CreateEvent(wMoveEvent)

  elif msg.isContextMenuEvent():
    result = CreateEvent(wContextMenuEvent)

  elif msg.isScrollWinEvent():
    result = CreateEvent(wScrollWinEvent)

  elif msg.isScrollEvent():
    result = CreateEvent(wScrollEvent)

  elif msg.isListEvent():
    result = CreateEvent(wListEvent)

  elif msg.isTreeEvent():
    result = CreateEvent(wTreeEvent)

  elif msg.isStatusBarEvent():
    result = CreateEvent(wStatusBarEvent)

  elif msg.isCommandEvent(): # must last check
    result = CreateEvent(wCommandEvent)

  else:
    result = CreateEvent(wOtherEvent)

  if result of wCommandEvent:
    result.mId = wCommandID LOWORD(wParam)

  result.mPropagationLevel = msg.defaultPropagationLevel()

  # save the status for the last message occured
  GetKeyboardState(cast[PBYTE](&result.mKeyStatus[0]))
  var val = GetMessagePos()
  result.mMousePos.x = GET_X_LPARAM(val)
  result.mMousePos.y = GET_Y_LPARAM(val)
  result.mClientPos = wDefaultPoint

proc clone*(self: wEvent): wEvent {.validate.} =
  ## Returns a copy of the event.
  deepCopy(result, self)

proc getEventObject*(self: wEvent): wWindow {.validate, property, inline.} =
  ## Returns the object (usually a window) associated with the event
  result = mWindow

proc getWindow*(self: wEvent): wWindow {.validate, property, inline.} =
  ## Returns the window associated with the event. This proc is equal to getEventObject.
  result = mWindow

proc getEventType*(self: wEvent): UINT {.validate, property, inline.} =
  ## Returns the type of the given event, such as wxEVT_BUTTON, aka message code.
  result = mMsg

proc getEventMessage*(self: wEvent): UINT {.validate, property, inline.} =
  ## Returns the message code of the given event. The same as getEventType().
  result = mMsg

proc getId*(self: wEvent): wCommandID {.validate, property, inline.} =
  ## Returns the ID associated with this event, aka command ID or menu ID.
  result = mID

proc getIntId*(self: wEvent): int {.validate, property, inline.} =
  ## Returns the ID associated with this event, aka command ID or menu ID.
  result = int mID

proc getTimerId*(self: wEvent): int {.validate, property, inline.} =
  ## Return the timer ID. Only for wEvent_Timer event.
  result = int mWparam

proc getlParam*(self: wEvent): LPARAM {.validate, property, inline.} =
  ## Returns the low-level LPARAM data of the associated windows message.
  result = mLparam

proc getwParam*(self: wEvent): WPARAM {.validate, property, inline.} =
  ## Returns the low-level WPARAM data of the associated windows message.
  result = mWparam

proc getResult*(self: wEvent): LRESULT {.validate, property, inline.} =
  ## Returns data that will be sent to system after event handler exit.
  result = mResult

proc setResult*(self: wEvent, ret: LRESULT) {.validate, property, inline.} =
  ## Set the data that will be sent to system after event handler exit.
  mResult = ret

proc getUserData*(self: wEvent): int {.validate, property, inline.} =
  ## Return the userdata associated with a event.
  result = mUserData

proc setUserData*(self: wEvent, userData: int) {.validate, property, inline.} =
  ## Set the userdata associated with a event.
  mUserData = userData

proc skip*(self: wEvent, skip = true) {.validate, inline.} =
  ## This proc can be used inside an event handler to control whether
  ## further event handlers bound to this event will be called after the current one returns.
  mSkip = skip

proc `skip=`*(self: wEvent, skip: bool) {.validate, inline.} =
  ## Nim style setter for skip
  skip(skip)

proc veto*(self: wEvent) {.validate, inline.} =
  ## Prevents the change announced by this event from happening.
  #todo: most windows's message return non-zero value to veto.
  #however, is it need more judgment?
  mResult = TRUE

proc deny*(self: wEvent) {.validate, inline.} =
  ## The same as veto().
  veto()

proc allow*(self: wEvent) {.validate, inline.} =
  ## This is the opposite of veto(): it explicitly allows the event to be processed.
  mResult = FALSE

proc isAllowed*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the change is allowed (veto() hasn't been called) or false otherwise (if it was).
  result = mResult != TRUE

proc stopPropagation*(self: wEvent): int {.validate, inline, discardable.} =
  ## Stop the event from propagating to its parent window.
  result = mPropagationLevel
  mPropagationLevel = 0

proc resumePropagation*(self: wEvent, propagationLevel = wEvent_PropagateMax) {.validate, inline.} =
  ## Sets the propagation level to the given value.
  mPropagationLevel = propagationLevel

method shouldPropagate*(self: wEvent): bool {.base.} = mPropagationLevel > 0
  ## Test if this event should be propagated or not, i.e. if the propagation level is currently greater than 0.
  ## This method can be override, for example:
  ## .. code-block:: Nim
  ##   method shouldPropagate*(event: wKeyEvent): bool =
  ##     if event.eventType == wEvent_Char:
  ##       result = true
  ##     else:
  ##       result = procCall wEvent(event).shouldPropagate()

proc getPropagationLevel*(self: wEvent): int {.validate, property, inline.} =
  ## Get how many levels the event can propagate.
  result = mPropagationLevel

proc setPropagationLevel*(self: wEvent, propagationLevel: int) {.validate, property, inline.}  =
  ## Set how many levels the event can propagate.
  mPropagationLevel = propagationLevel

proc screenToClient*(self: wWindow, pos: wPoint): wPoint

proc getMouseScreenPos*(self: wEvent): wPoint {.validate, property, inline.} =
  ## Get coordinate of the cursor.
  ## The coordinate is relative to the screen.
  result = mMousePos

proc getMousePos*(self: wEvent): wPoint {.validate, property.} =
  ## Get coordinate of the cursor.
  ## The coordinate is relative to the origin of the client area.
  if mClientPos == wDefaultPoint:
    mClientPos = mWindow.screenToClient(mMousePos)

  result = mClientPos

proc getX*(self: wEvent): int {.validate, property, inline.} =
  ## Get x-coordinate of the cursor.
  ## The coordinate is relative to the origin of the client area.
  result = getMousePos().x

proc getY*(self: wEvent): int {.validate, property, inline.} =
  ## Get y-coordinate of the cursor.
  ## The coordinate is relative to the origin of the client area.
  result = getMousePos().y

proc lCtrlDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left ctrl key is pressed.
  result = mKeyStatus[wKeyLCtrl] < 0

proc lShiftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left shift key is pressed.
  result = mKeyStatus[wKeyLShift] < 0

proc lAltDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left alt key is pressed.
  result = mKeyStatus[wKeyLAlt] < 0

proc lWinDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left win key is pressed.
  result = mKeyStatus[wKeyLWin] < 0

proc rCtrlDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right ctrl key is pressed.
  result = mKeyStatus[wKeyRCtrl] < 0

proc rShiftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right shift key is pressed.
  result = mKeyStatus[wKeyRShift] < 0

proc rAltDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right alt key is pressed.
  result = mKeyStatus[wKeyRAlt] < 0

proc rWinDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right win key is pressed.
  result = mKeyStatus[wKeyRWin] < 0

proc ctrlDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any ctrl key is pressed.
  result = lCtrlDown() or rCtrlDown()

proc shiftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any shift key is pressed.
  result = lShiftDown() or rShiftDown()

proc altDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any alt key is pressed.
  result = lAltDown() or rAltDown()

proc winDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if any win key is pressed.
  result = lWinDown() or rWinDown()

proc leftDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the left mouse button is currently down.
  result = mKeyStatus[wKeyLButton] < 0

proc rightDown*(self: wEvent): bool {.validate, inline.} =
  ## Returns true if the right mouse button is currently down.
  result = mKeyStatus[wKeyRButton] < 0

proc middleDown*(self: wEvent): bool {.validate, inline.} =
  ##  Returns true if the middle mouse button is currently down.
  result = mKeyStatus[wKeyMButton] < 0

proc getKeyStatus*(self: wEvent): array[256, bool] {.validate, property, inline.} =
  ## Return an bool array with all the pressed keys.
  ## Using const defined in wKeyCodes.nim as the index.
  ## For exampel, echo event.keyStauts[wKeyCtrl]
  for key, val in mKeyStatus:
    result[key] = val < 0

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
