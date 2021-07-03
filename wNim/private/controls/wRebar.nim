#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A rebar control can contain one or more bands, and each band can have a
## gripper bar, a bitmap, a text label, and one child control.
## As you dynamically reposition a rebar control band, the rebar control manages
## the size and position of the child window assigned to that band.
#
## :Superclass:
##   `wControl <wControl.html>`_

include ../pragma
import ../wBase, wControl, wToolBar, ../nimpack
export wControl, wToolBar

const
  wRbBandBorder* = RBS_BANDBORDERS
  wRbDoubleClickToggle* = RBS_DBLCLKTOGGLE
  wRbFixedSize* = RBBS_FIXEDSIZE
  wRbBreak* = RBBS_BREAK
  wRbTopAlign* = RBBS_TOPALIGN
  wRbHittestCaption* = RBHT_CAPTION
  wRbHittestChevron* = RBHT_CHEVRON
  wRbHittestClient* = RBHT_CLIENT
  wRbHittestGrabber* = RBHT_GRABBER
  wRbHittestNowhere* = RBHT_NOWHERE
  wRbHittestSplitter* = RBHT_SPLITTER

proc initRebarBandInfo(fMask: UINT): REBARBANDINFO =
  # only REBARBANDINFO_V5_SIZE works from XP to Win10
  result.cbSize = cast[int](addr result.cxHeader) - cast[int](addr result)
  result.fMask = fMask

proc findUnusedId(self: wRebar): wCommandID =
  var id = 1
  while SendMessage(self.mHwnd, RB_IDTOINDEX, id, 0) >= 0:
    id.inc
  result = wCommandID id

proc setImageList*(self: wRebar, imageList: wImageList) {.validate, property.} =
  ## Sets the image list associated with the rebar.
  if imageList != nil:
    var rebarInfo = REBARINFO(cbSize: sizeof(REBARINFO), fMask: RBIM_IMAGELIST,
      himl: imageList.mHandle)
    SendMessage(self.mHwnd, RB_SETBARINFO, 0, &rebarInfo)

  self.mImageList = imageList

proc getImageList*(self: wRebar): wImageList {.validate, property, inline.} =
  ## Returns the image list associated with the rebar.
  result = self.mImageList

proc getCount*(self: wRebar): int {.validate, property, inline.} =
  ## Returns the number of bands in the rebar.
  result = int SendMessage(self.mHwnd, RB_GETBANDCOUNT, 0, 0)

proc getRowCount*(self: wRebar): int {.validate, property, inline.} =
  ## Returns the number of rows in the rebar.
  result = int SendMessage(self.mHwnd, RB_GETROWCOUNT, 0, 0)

proc getHeight*(self: wRebar): int {.validate, property, inline.} =
  ## Returns the height of the rebar.
  result = int SendMessage(self.mHwnd, RB_GETBARHEIGHT, 0, 0)

proc insertBand*(self: wRebar, pos: int, control: wWindow = nil, image = -1,
    label = "", style: wStyle = 0): wCommandID {.validate, discardable.} =
  ## Inserts a band to the rebar and returns the ID of the band (wIdZero if failed).
  ## If *control* is nil, an empty band will be inserted.
  ## Add *wRbBreak* style to indicate the band is on a new line.
  var rbBand = initRebarBandInfo(RBBIM_STYLE or RBBIM_IMAGE or RBBIM_ID)
  rbBand.fStyle = RBBS_CHILDEDGE or RBBS_GRIPPERALWAYS or cast[DWORD](style)
  rbBand.iImage = image
  rbBand.wID = DWORD self.findUnusedId()

  if not control.isNil:
    rbBand.fMask = rbBand.fMask or RBBIM_SIZE or RBBIM_CHILD or RBBIM_CHILDSIZE
    rbBand.hwndChild = control.mHwnd

    if control of wBase.wToolBar:
      wBase.wToolBar(control).undock()

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

  if SendMessage(self.mHwnd, RB_INSERTBAND, pos, &rbBand) != 0:
    result = wCommandID rbBand.wID

proc addBand*(self: wRebar, control: wWindow = nil, image = -1,
    label = "", style: wStyle = 0): wCommandID {.validate, inline, discardable.} =
  ## Adds a band to the rebar and returns the ID of the band (wIdZero if failed).
  ## If *control* is nil, an empty band will be added.
  ## Add *wRbBreak* style to indicate the band is on a new line.
  result = self.insertBand(-1, control, image, label, style)

proc findBand*(self: wRebar, id: wCommandID): int {.validate, inline.} =
  ## Find a band by id. Returns zero-based index, or -1 otherwise.
  result = int SendMessage(self.mHwnd, RB_IDTOINDEX, DWORD id, 0)

proc getBandId*(self: wRebar, index: int): wCommandID {.validate, property, inline.} =
  ## Returns the id for a given band.
  var rbBand = initRebarBandInfo(RBBIM_ID)
  SendMessage(self.mHwnd, RB_GETBANDINFO, index, &rbBand)
  result = wCommandID rbBand.wID

proc setBandId*(self: wRebar, index: int, id: wCommandID) {.validate, property, inline.} =
  ## Sets the id for a band.
  var rbBand = initRebarBandInfo(RBBIM_ID)
  rbBand.wID = DWORD id
  SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)

proc deleteBand*(self: wRebar, index: int) {.validate, inline.} =
  ## Deletes a band from a rebar by index.
  SendMessage(self.mHwnd, RB_DELETEBAND, index, 0)

proc deleteBand*(self: wRebar, id: wCommandID) {.validate, inline.} =
  ## Deletes a band from a rebar by id.
  self.deleteBand(self.findBand(id))

proc showBand*(self: wRebar, index: int, flag = true) {.validate, inline.} =
  ## Shows or hides a given band in a rebar by index.
  SendMessage(self.mHwnd, RB_SHOWBAND, index, int flag)

proc showBand*(self: wRebar, id: wCommandID, flag = true) {.validate, inline.} =
  ## Shows or hides a given band in a rebar by id.
  self.showBand(self.findBand(id), flag)

proc minimizeBand*(self: wRebar, index: int) {.validate, inline.} =
  ## Resizes a band to its smallest size by index.
  SendMessage(self.mHwnd, RB_MINIMIZEBAND, index, 0)

proc minimizeBand*(self: wRebar, id: wCommandID) {.validate, inline.} =
  ## Resizes a band to its smallest size by id.
  self.minimizeBand(self.findBand(id))

proc maximizeBand*(self: wRebar, index: int) {.validate, inline.} =
  ## Resizes a band to either its ideal or largest size by index.
  SendMessage(self.mHwnd, RB_MAXIMIZEBAND, index, 0)

proc maximizeBand*(self: wRebar, id: wCommandID) {.validate, inline.} =
  ## Resizes a band to either its ideal or largest size by id.
  self.maximizeBand(self.findBand(id))

proc getBandRect*(self: wRebar, index: int): wRect {.validate, property, inline.} =
  ## Returns the bounding rectangle for a given band by index.
  var rect: RECT
  SendMessage(self.mHwnd, RB_GETRECT, index, &rect)
  result = toWRect(rect)

proc getBandRect*(self: wRebar, id: wCommandID): wRect {.validate, property, inline.} =
  ## Returns the bounding rectangle for a given band by id.
  result = self.getBandRect(self.findBand(id))

proc getBandWidth*(self: wRebar, index: int): int {.validate, property, inline.} =
  ## Returns the width for a given band by index.
  var rbBand = initRebarBandInfo(RBBIM_CHILDSIZE or RBBIM_SIZE)
  SendMessage(self.mHwnd, RB_GETBANDINFO, index, &rbBand)
  result = rbBand.cx

proc getBandWidth*(self: wRebar, id: wCommandID): int {.validate, property, inline.} =
  ## Returns the width for a given band by id.
  result = self.getBandWidth(self.findBand(id))

proc setBandWidth*(self: wRebar, index: int, width: int, exactly=false) {.validate, property.} =
  ## Sets the width for a band by index.
  if exactly:
    var rbBand = initRebarBandInfo(RBBIM_SIZE)
    rbBand.cx = UINT width
    SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)
  else:
    SendMessage(self.mHwnd, RB_SETBANDWIDTH, index, width)

proc setBandWidth*(self: wRebar, id: wCommandID, width: int, exactly=false) {.validate, property, inline.} =
  ## Sets the width for a band by id.
  self.setBandWidth(self.findBand(id), width, exactly)

proc setBandMinWidth*(self: wRebar, index: int, width: int) {.validate, property, inline.} =
  ## Sets the minimum width for a band by index.
  var rbBand = initRebarBandInfo(RBBIM_CHILDSIZE)
  SendMessage(self.mHwnd, RB_GETBANDINFO, index, &rbBand)
  rbBand.cxMinChild = width
  SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)

proc setBandMinWidth*(self: wRebar, id: wCommandID, width: int) {.validate, property, inline.} =
  ## Sets the minimum width for a band by id.
  self.setBandMinWidth(self.findBand(id), width)

proc getBandHeight*(self: wRebar, index: int): int {.validate, property, inline.} =
  ## Returns the height for a given band by index.
  result = int SendMessage(self.mHwnd, RB_GETROWHEIGHT, index, 0)

proc getBandHeight*(self: wRebar, id: wCommandID): int {.validate, property, inline.} =
  ## Returns the height for a given band by id.
  result = self.getBandHeight(self.findBand(id))

proc setBandMinHeight*(self: wRebar, index: int, height: int) {.validate, property, inline.} =
  ## Sets the minimum height for a band by index.
  var rbBand = initRebarBandInfo(RBBIM_CHILDSIZE)
  rbBand.cyMinChild = height
  rbBand.cyChild = height
  SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)

proc setBandMinHeight*(self: wRebar, id: wCommandID, height: int) {.validate, property, inline.} =
  ## Sets the minimum height for a band by id.
  self.setBandMinHeight(self.findBand(id), height)

proc getBandLabel*(self: wRebar, index: int): string {.validate, property.} =
  ## Returns the label for a band by index.
  var rbBand = initRebarBandInfo(RBBIM_TEXT)
  var buffer = T(65536)
  rbBand.lpText = &buffer
  rbBand.cch = 65536
  SendMessage(self.mHwnd, RB_GETBANDINFO, index, &rbBand)
  buffer.nullTerminate
  result = $buffer

proc getBandLabel*(self: wRebar, id: wCommandID): string {.validate, property, inline.} =
  ## Returns the label for a band by id.
  result = self.getBandLabel(self.findBand(id))

proc setBandLabel*(self: wRebar, index: int, label: string) {.validate, property.} =
  ## Sets the label for a band by index.
  var rbBand = initRebarBandInfo(RBBIM_TEXT)
  rbBand.lpText = T(label)
  SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)

proc setBandLabel*(self: wRebar, id: wCommandID, label: string) {.validate, property, inline.} =
  ## Sets the label for a band by id.
  self.setBandLabel(self.findBand(id), label)

proc getBandImage*(self: wRebar, index: int): int {.validate, property, inline.} =
  ## Returns the index of image list for a band by index. -1 means no image.
  var rbBand = initRebarBandInfo(RBBIM_IMAGE)
  SendMessage(self.mHwnd, RB_GETBANDINFO, index, &rbBand)
  result = rbBand.iImage

proc getBandImage*(self: wRebar, id: wCommandID): int {.validate, property, inline.} =
  ## Returns the index of image list for a band by id. -1 means no image.
  result = self.getBandImage(self.findBand(id))

proc setBandImage*(self: wRebar, index: int, image: int) {.validate, property, inline.} =
  ## Sets the index of image list for a band by index. -1 means no image.
  var rbBand = initRebarBandInfo(RBBIM_IMAGE)
  rbBand.iImage = image
  SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)

proc setBandImage*(self: wRebar, id: wCommandID, image: int) {.validate, property, inline.} =
  ## Sets the index of image list for a band by id. -1 means no image.
  self.setBandImage(self.findBand(id), image)

proc getBandStyle*(self: wRebar, index: int): wStyle {.validate, property, inline.} =
  ## Returns the style for a band by index.
  var rbBand = initRebarBandInfo(RBBIM_STYLE)
  SendMessage(self.mHwnd, RB_GETBANDINFO, index, &rbBand)
  result = cast[wStyle](rbBand.fStyle)

proc getBandStyle*(self: wRebar, id: wCommandID): wStyle {.validate, property, inline.} =
  ## Returns the style for a band by id.
  result = self.getBandStyle(self.findBand(id))

proc setBandStyle*(self: wRebar, index: int, style: wStyle) {.validate, property, inline.} =
  ## Sets the style for a band by index.
  var rbBand = initRebarBandInfo(RBBIM_STYLE)
  rbBand.fStyle = cast[UINT](style)
  SendMessage(self.mHwnd, RB_SETBANDINFO, index, &rbBand)

proc setBandStyle*(self: wRebar, id: wCommandID, style: wStyle) {.validate, property, inline.} =
  ## Sets the style for a band by id.
  self.setBandStyle(self.findBand(id), style)

proc moveBand*(self: wRebar, index: int, newPos: int) {.validate.} =
  ## Moves a band to another position by index.
  let isHidden = (self.getBandStyle(index) and RBBS_HIDDEN) != 0
  SendMessage(self.mHwnd, RB_MOVEBAND, index, newPos)
  SendMessage(self.mHwnd, RB_SHOWBAND, index, if isHidden: 0 else: 1)

proc moveBand*(self: wRebar, id: wCommandID, newPos: int) {.validate, inline.} =
  ## Moves a band to another position by id.
  self.moveBand(self.findBand(id), newPos)

proc hitTest*(self: wRebar, x: int, y: int): tuple[band: wCommandID, flag: int] {.validate.} =
  ## Determines which band (if any, wIdZero otherwise) is at the specified point,
  ## giving details in flags. *flag* will be a one of the following flags:
  ## ===========================  ==============================================
  ## Flag                         Description
  ## ===========================  ==============================================
  ## wRbHittestCaption            In the rebar band's caption.
  ## wRbHittestChevron            In the rebar band's chevron
  ## wRbHittestClient             In the rebar band's client area.
  ## wRbHittestGrabber            In the rebar band's gripper.
  ## wRbHittestNowhere            Not in a rebar band.
  ## wRbHittestSplitter           In the rebar band's splitter.
  var info: RBHITTESTINFO
  info.pt.x = x
  info.pt.y = y
  SendMessage(self.mHwnd, RB_HITTEST, 0, &info)
  if info.iBand != -1:
    result.band = self.getBandId(info.iBand)
    result.flag = info.flags

proc hitTest*(self: wRebar, pos: wPoint): tuple[band: wCommandID, flag: int] {.validate, inline.} =
  ## The same as hitTest().
  result = self.hitTest(pos.x, pos.y)

proc disableMinMax*(self: wRebar, disable = true) {.validate, inline.} =
  ## Disables or enables maximizing or minimizing a band.
  self.mDisableMinMax = disable

proc disableDrag*(self: wRebar, disable = true) {.validate, inline.} =
  ## Disables or enables dragging a band.
  self.mDisableDrag = disable

proc getLayout*(self: wRebar): string {.validate, property.} =
  ## Returns the current layout of bands in the rebar (binary format).
  ## The bands must have different id to work.
  var data: seq[tuple[id: int32, width: int32, style: int32]]
  for i in 0..<self.getCount():
    data.add (int32 self.getBandId(i), int32 self.getBandWidth(i), int32 self.getBandStyle(i))
  result = pack(data)

proc setLayout*(self: wRebar, layout: string) {.validate, property.} =
  ## Sets a layout of bands in the rebar.
  ## The bands must have different id to work.
  var data: seq[tuple[id: int32, width: int32, style: int32]]
  data = unpack(layout, data.type)
  if data.len == self.getCount():
    for i, (id, width, style) in data:
      let index = self.findBand(wCommandID id)
      if index >= 0:
        self.setBandStyle(index, wStyle style)
        self.setBandWidth(index, int width, exactly=true)
        self.moveBand(index, i)

proc len*(self: wRebar): int {.validate, inline.} =
  ## Returns the number of bands in the rebar.
  result = self.getCount()

method show*(self: wRebar, flag = true) {.inline.} =
  ## Shows or hides the rebar bar.
  self.showAndNotifyParent(flag)

method processNotify(self: wRebar, code: INT, id: UINT_PTR, lParam: LPARAM,
    ret: var LRESULT): bool =

  case code
  of RBN_BEGINDRAG:
    self.mDragging = true
    if self.mDisableDrag:
      ret = TRUE
      return true

  of RBN_ENDDRAG:
    self.mDragging = false

  of RBN_MINMAX:
    if self.mDisableMinMax:
      ret = TRUE
      return true

  of RBN_AUTOSIZE:
    # Notice the parent the client size is changed. Here must be wEvent_Size
    # instead of WM_SIZE, otherwise, it will enter infinite loop.
    let rect = self.mParent.getWindowRect(sizeOnly=true)
    self.mParent.processMessage(wEvent_Size, SIZE_RESTORED,
      MAKELPARAM(rect.width, rect.height))

  else:
    return procCall wControl(self).processNotify(code, id, lParam, ret)

wClass(wRebar of wControl):

  method release*(self: wRebar) =
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
