## A static text control displays one or more lines of read-only text.
##
## :Superclass:
##    wControl
##
## :Styles:
##    ==============================  =============================================================
##    Styles                          Description
##    ==============================  =============================================================
##    wAlignLeft                      Align the text to the left.
##    wAlignRight                     Align the text to the right.
##    wAlignCentre                    Center the text (horizontally).
##    wAlignMiddle                    Center the text (vertically).
##    wAlignLeftNoWordWrap            Align the text to the left, but words are not wrapped
##    ==============================  =============================================================
##
## :Events:
##    ==============================  =============================================================
##    wCommandEvent                   Description
##    ==============================  =============================================================
##    wEvent_CommandLeftClick         Clicked the left mouse button within the control.
##    wEvent_CommandLeftDoubleClick   Double-clicked the left mouse button within the control.
##    ==============================  =============================================================

const
  wAlignLeft* = SS_LEFT
  wAlignRight* = SS_RIGHT
  wAlignCentre* = SS_CENTER
  wAlignMiddle* = SS_CENTERIMAGE
  wAlignLeftNoWordWrap* = SS_LEFTNOWORDWRAP

method getBestSize*(self: wStaticText): wSize {.property.} =
  ## Returns the best acceptable minimal size for the control.
  result = getTextFontSize(getLabel(), mFont.mHandle)
  result.width += 2
  result.height += 2

method getDefaultSize*(self: wStaticText): wSize {.property.} =
  ## Returns the default size for the control.
  result = getBestSize()
  result.height = getLineControlDefaultHeight(mFont.mHandle)

proc init(self: wStaticText, parent: wWindow, id: wCommandID = -1, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = 0) =

  self.wControl.init(className=WC_STATIC, parent=parent, id=id, label=label, pos=pos, size=size,
    style=style or WS_CHILD or WS_VISIBLE or SS_NOTIFY)

  mFocusable = false

  systemConnect(WM_SIZE) do (event: wEvent):
    # when size change, StaticText should refresh itself, but windows system don't do it
    self.refresh()

  parent.systemConnect(WM_COMMAND) do (event: wEvent):
    # translate to wEvent_Command event
    if event.mLparam == mHwnd:
      let cmdEvent = case HIWORD(event.mWparam)
        of STN_CLICKED: wEvent_CommandLeftClick
        of STN_DBLCLK: wEvent_CommandLeftDoubleClick
        else: 0

      if cmdEvent != 0:
        var processed: bool
        discard self.mMessageHandler(self, cmdEvent, event.mWparam, event.mLparam, processed)

proc StaticText*(parent: wWindow, id: wCommandID = wDefaultID, label: string = "",
    pos = wDefaultPoint, size = wDefaultSize, style: wStyle = wAlignLeft): wStaticText {.discardable.} =
  ## Constructor, creating and showing a text control.
  wValidate(parent, label)
  new(result)
  result.init(parent=parent, label=label, pos=pos, size=size, style=style)
