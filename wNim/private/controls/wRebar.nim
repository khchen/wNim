#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## A rebar control can contain one or more bands, and each band can have a
## gripper bar, a bitmap, a text label, and one child control.
## As you dynamically reposition a rebar control band, the rebar control manages
## the size and position of the child window assigned to that band.
## **Notice: This is just a experimental module, not yet fully functional.**
#
## :Superclass:
##   `wControl <wControl.html>`_

{.experimental, deadCodeElim: on.}
when defined(gcDestructors): {.push sinkInference: off.}

import ../wBase, wControl, wToolBar
export wControl, wToolBar

const
  wRbBandBorder* = RBS_BANDBORDERS
  wRbDoubleClickToggle* = RBS_DBLCLKTOGGLE

proc setImageList*(self: wRebar, imageList: wImageList) {.validate, property.} =
  ## Sets the image list associated with the rebar.
  if imageList != nil:
    var rebarInfo = REBARINFO(cbSize: sizeof(REBARINFO), fMask: RBIM_IMAGELIST,
      himl: imageList.mHandle)
    SendMessage(self.mHwnd, RB_SETBARINFO, 0, &rebarInfo)

  self.mImageList = imageList

proc getImageList*(self: wRebar): wImageList {.validate, property, inline.} =
  ## Returns the specified image list.
  result = self.mImageList

proc getCount*(self: wRebar): int {.validate, property, inline.} =
  ## Returns the number of controls in the rebar.
  result = int SendMessage(self.mHwnd, RB_GETBANDCOUNT, 0, 0)

proc addControl*(self: wRebar, control: wControl, image = -1, label = "",
    isBreak = false) {.validate.} =
  ## Adds a control to the rebar.
  wValidate(control)

  var rbBand: REBARBANDINFO
  # only REBARBANDINFO_V5_SIZE works from XP to Win10
  rbBand.cbSize = cast[int](addr rbBand.cxHeader) - cast[int](addr rbBand)
  rbBand.fMask = RBBIM_STYLE or RBBIM_CHILD or RBBIM_CHILDSIZE or
    RBBIM_SIZE or RBBIM_IMAGE
  rbBand.fStyle = RBBS_CHILDEDGE or RBBS_GRIPPERALWAYS
  if isBreak: rbBand.fStyle = rbBand.fStyle or RBBS_BREAK
  rbBand.hwndChild = control.mHwnd
  rbBand.iImage = image

  if control of wBase.wToolBar:
    var toolbar = wBase.wToolBar(control)
    var toolSize = toolbar.getToolSize()
    rbBand.cxMinChild = toolbar.getToolsCount() * toolSize.width
    rbBand.cyMinChild = toolSize.height

    toolbar.addWindowStyle(wTbDefaultStyle or CCS_NODIVIDER or
      CCS_NOPARENTALIGN or CCS_NORESIZE)

  else:
    var size = control.getMinSize()
    if size == wDefaultSize:
      size = control.getBestSize()
    rbBand.cxMinChild = size.width
    rbBand.cyMinChild = size.height

  rbBand.cx = rbBand.cxMinChild
  rbBand.cyChild = rbBand.cyMinChild

  if label.len != 0:
    rbBand.fMask = rbBand.fMask or RBBIM_TEXT
    rbBand.lpText = T(label)

  SendMessage(self.mHwnd, RB_INSERTBAND, -1, &rbBand)

proc minimize*(self: wRebar, band: int) {.validate, inline.} =
  ## Resizes a band to its smallest size.
  SendMessage(self.mHwnd, RB_MINIMIZEBAND, band, 0)

proc len*(self: wRebar): int {.validate, inline.} =
  ## Returns the number of controls in the rebar.
  result = self.getCount()

method show*(self: wRebar, flag = true) {.inline, uknlock.} =
  ## Shows or hides the status bar.
  self.showAndNotifyParent(flag)

method processNotify(self: wRebar, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool {.uknlock.} =

  case code
  of RBN_BEGINDRAG:
    self.mDragging = true

  of RBN_ENDDRAG:
    self.mDragging = false

  # of RBN_LAYOUTCHANGED:
  #   # Notice the parent the client size is changed. Here must be wEvent_Size
  #   # instead of WM_SIZE, otherwise, it will enter infinite loop.
  #   let rect = mParent.getWindowRect(sizeOnly=true)
  #   mParent.processMessage(wEvent_Size, SIZE_RESTORED,
  #     MAKELPARAM(rect.width, rect.height))

  of RBN_AUTOSIZE:
    # Notice the parent the client size is changed. Here must be wEvent_Size
    # instead of WM_SIZE, otherwise, it will enter infinite loop.
    let rect = self.mParent.getWindowRect(sizeOnly=true)
    self.mParent.processMessage(wEvent_Size, SIZE_RESTORED,
      MAKELPARAM(rect.width, rect.height))

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)


wClass(wRebar of wControl):

  method release*(self: wRebar) {.uknlock.} =
    ## Release all the resources during destroying. Used internally.
    self.mParent.systemDisconnect(self.mSizeConn)
    free(self[])

  proc init*(self: wRebar, parent: wWindow, id = wDefaultID,
      imageList: wImageList = nil, style: wStyle = 0) {.validate.} =
    ## Initializes a rebar.
    wValidate(parent)
    self.mControls = @[]

    self.wControl.init(className=REBARCLASSNAME, parent=parent, id=id,
      style=style or WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or
      RBS_VARHEIGHT or CCS_NODIVIDER or RBS_AUTOSIZE)

    parent.mRebar = self

    self.mSizeConn = parent.systemConnect(WM_SIZE) do (event: wEvent):
      self.setSize(parent.getSize().width, wDefault)
