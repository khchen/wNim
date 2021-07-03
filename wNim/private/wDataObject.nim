#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A wDataObject represents data that can be copied to or from the clipboard,
## or dragged and dropped. For now, only text, files list, and bitmap are
## supported.
#
## :Seealso:
##   `wWindow <wWindow.html>`_
##   `wDragDropEvent <wDragDropEvent.html>`_
#
## :Effects:
##   ==============================  =============================================================
##   Drag-Drop Effects               Description
##   ==============================  =============================================================
##   wDragNone                       Drop target cannot accept the data.
##   wDragCopy                       Drop results in a copy.
##   wDragMove                       Drag source should remove the data.
##   wDragLink                       Drag source should create a link to the original data.
##   ==============================  =============================================================

include pragma
import wBase, gdiobjects/wBitmap, memlib/rtlib

const
  wDragNone* = DROPEFFECT_NONE # 0
  wDragCopy* = DROPEFFECT_COPY # 1
  wDragMove* = DROPEFFECT_MOVE # 2
  wDragLink* = DROPEFFECT_LINK # 4
  wDragError* = 8
  wDragCancel* = 16

type
  wDataObjectError* = object of wError
    ## An error raised when wDataObject creation or operation failure.

# The obj returned from SHCreateFileDataObject() only suport BMP in Windows 10
# So here we implement our own IDataObject to support it.
type
  BmpDataObject {.pure.} = object
    lpVtbl: ptr IDataObjectVtbl
    vtbl: IDataObjectVtbl
    refCount: LONG
    bmp: HBITMAP

# Windows XP don't support SHCreateDataObject.
# And SHCreateFileDataObject support CF_HDROP format.
proc SHCreateFileDataObject(pidlFolder: PCIDLIST_ABSOLUTE, cidl: UINT,
  apidl: PCUITEMID_CHILD_ARRAY, pDataInner: ptr IDataObject,
  ppDataObj: ptr ptr IDataObject): HRESULT
  {.checkedRtlib: "shell32", stdcall, importc: 740.}

converter BmpDataObjectToIUnknown(x: ptr BmpDataObject): ptr IUnknown {.shield.} = cast[ptr IUnknown](x)
converter BmpDataObjectToIDataObject(x: ptr BmpDataObject): ptr IDataObject {.shield.} = cast[ptr IDataObject](x)

proc newBmpDataObject(bmp: HBITMAP): ptr BmpDataObject =
  result = cast[ptr BmpDataObject](alloc0(sizeof(BmpDataObject)))
  if result == nil: return

  result.lpVtbl = &result.vtbl
  result.bmp = CopyImage(bmp, IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE)
  result.refCount = 1

  result.vtbl.AddRef = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    let obj = cast[ptr BmpDataObject](self)
    discard InterlockedIncrement(&obj.refCount)
    return obj.refCount

  result.vtbl.Release = proc(self: ptr IUnknown): ULONG {.stdcall.} =
    let obj = cast[ptr BmpDataObject](self)
    discard InterlockedDecrement(&obj.refCount)
    if obj.refCount == 0:
      DeleteObject(obj.bmp)
      dealloc(obj)
      return 0

    return obj.refCount

  result.vtbl.QueryInterface = proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.} =
    if ppvObject.isNil:
      return E_POINTER
    elif IsEqualIID(riid, &IID_IUnknown) or IsEqualIID(riid, &IID_IDataObject):
      ppvObject[] = self
      self.AddRef()
      return S_OK
    else:
      ppvObject[] = nil
      return E_NOINTERFACE

  result.vtbl.GetData = proc(self: ptr IDataObject, pformatetcIn: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.stdcall.} =
    if pformatetcIn.cfFormat == CF_BITMAP and (pformatetcIn.tymed and TYMED_GDI) != 0:
      let obj = cast[ptr BmpDataObject](self)
      pmedium.tymed = TYMED_GDI
      pmedium.u.hBitmap = CopyImage(obj.bmp, IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE)
      pmedium.pUnkForRelease = nil
      return S_OK

    return E_FAIL

  result.vtbl.GetDataHere = proc(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM): HRESULT {.stdcall.} =
    return E_NOTIMPL

  result.vtbl.QueryGetData = proc(self: ptr IDataObject, pformatetc: ptr FORMATETC): HRESULT {.stdcall.} =
    if pformatetc.cfFormat == CF_BITMAP:
      return S_OK

    return E_NOTIMPL

  result.vtbl.GetCanonicalFormatEtc = proc(self: ptr IDataObject, pformatectIn: ptr FORMATETC, pformatetcOut: ptr FORMATETC): HRESULT {.stdcall.} =
    return E_NOTIMPL

  result.vtbl.SetData = proc(self: ptr IDataObject, pformatetc: ptr FORMATETC, pmedium: ptr STGMEDIUM, fRelease: WINBOOL): HRESULT {.stdcall.} =
    return E_NOTIMPL

  result.vtbl.EnumFormatEtc = proc(self: ptr IDataObject, dwDirection: DWORD, ppenumFormatEtc: ptr ptr IEnumFORMATETC): HRESULT {.stdcall.} =
    if dwDirection == DATADIR_GET:
      var formatetc = [
        FORMATETC(cfFormat: CF_BITMAP, dwAspect: DVASPECT_CONTENT, lindex: -1, tymed: TYMED_GDI),
      ]
      return SHCreateStdEnumFmtEtc(UINT formatetc.len, &formatetc[0], ppenumFormatEtc)
    else:
      return E_NOTIMPL

  result.vtbl.DAdvise = proc(self: ptr IDataObject, pformatetc: ptr FORMATETC, advf: DWORD, pAdvSink: ptr IAdviseSink, pdwConnection: ptr DWORD): HRESULT {.stdcall.} =
    return E_NOTIMPL

  result.vtbl.DUnadvise = proc(self: ptr IDataObject, dwConnection: DWORD): HRESULT {.stdcall.} =
    return E_NOTIMPL

  result.vtbl.EnumDAdvise = proc(self: ptr IDataObject, ppenumAdvise: ptr ptr IEnumSTATDATA): HRESULT {.stdcall.} =
    return E_NOTIMPL

proc error(self: wDataObject) {.inline.} =
  raise newException(wDataObjectError, "wDataObject creation failed")

proc isText*(self: wDataObject): bool {.validate.} =
  ## Checks the data is text or not.
  var format = FORMATETC(
    cfFormat: CF_UNICODETEXT,
    dwAspect: DVASPECT_CONTENT,
    lindex: -1,
    tymed: TYMED_HGLOBAL)

  if self.mObj.QueryGetData(&format) == S_OK:
    return true

  format.cfFormat = CF_TEXT
  if self.mObj.QueryGetData(&format) == S_OK:
    return true

proc getText*(self: wDataObject): string {.validate, property.}  =
  ## Gets the data in text format.
  var ret: string
  defer: result = ret

  var format = FORMATETC(
    cfFormat: CF_UNICODETEXT,
    dwAspect: DVASPECT_CONTENT,
    lindex: -1,
    tymed: TYMED_HGLOBAL)

  var isUnicode = true
  var medium: STGMEDIUM
  if self.mObj.GetData(&format, &medium) != S_OK:
    format.cfFormat = CF_TEXT
    isUnicode = false
    if self.mObj.GetData(&format, &medium) != S_OK:
      return

  if medium.tymed == TYMED_HGLOBAL:
    if isUnicode:
      let pData = cast[ptr WCHAR](GlobalLock(medium.u.hGlobal))
      ret = $pData
    else:
      let pData = cast[ptr char](GlobalLock(medium.u.hGlobal))
      ret = $pData
    GlobalUnlock(medium.u.hGlobal)

  ReleaseStgMedium(&medium)

proc isFiles*(self: wDataObject): bool {.validate.} =
  ## Checks the data is files list or not.
  var format = FORMATETC(
    cfFormat: CF_HDROP,
    dwAspect: DVASPECT_CONTENT,
    lindex: -1,
    tymed: TYMED_HGLOBAL)

  if self.mObj.QueryGetData(&format) == S_OK:
    # only return true if there are some files.
    var medium: STGMEDIUM
    if self.mObj.GetData(&format, &medium) == S_OK:
      if medium.tymed == TYMED_HGLOBAL:
        let count = DragQueryFile(medium.u.hGlobal, -1, nil, 0)
        if count >= 1:
          return true

iterator getFiles*(self: wDataObject): string {.validate.} =
  ## Iterate each file in this file list.
  var format = FORMATETC(
    cfFormat: CF_HDROP,
    dwAspect: DVASPECT_CONTENT,
    lindex: -1,
    tymed: TYMED_HGLOBAL)

  var medium: STGMEDIUM
  if self.mObj.GetData(&format, &medium) == S_OK:
    if medium.tymed == TYMED_HGLOBAL:
      var buffer = T(65536)
      let count = DragQueryFile(medium.u.hGlobal, -1, nil, 0)
      for i in 0..<count:
        let length = DragQueryFile(medium.u.hGlobal, UINT i, &buffer, 65536)
        yield $buffer.substr(0, length - 1)

    ReleaseStgMedium(&medium)

proc getFiles*(self: wDataObject): seq[string] {.validate, property.} =
  ## Gets the files list as seq.
  result = @[]
  for file in self.getFiles():
    result.add file

proc isBitmap*(self: wDataObject): bool {.validate.} =
  ## Checks the data is bitmap or not.
  var format = FORMATETC(
    cfFormat: CF_BITMAP,
    dwAspect: DVASPECT_CONTENT,
    lindex: -1,
    tymed: TYMED_GDI)

  if self.mObj.QueryGetData(&format) == S_OK:
    return true

proc getBitmap*(self: wDataObject): wBitmap {.validate, property.} =
  ## Gets the data in bitmap format.
  var format = FORMATETC(
    cfFormat: CF_BITMAP,
    dwAspect: DVASPECT_CONTENT,
    lindex: -1,
    tymed: TYMED_GDI)

  var medium: STGMEDIUM
  if self.mObj.GetData(&format, &medium) == S_OK:
    if medium.tymed == TYMED_GDI:
      result = Bitmap(medium.u.hBitmap, copy=true)

    ReleaseStgMedium(&medium)

proc doDragDrop*(self: wDataObject, flags: int = wDragCopy or wDragMove or
    wDragLink): int {.validate, discardable.} =
  ## Starts the drag-and-drop operation which will terminate when the user
  ## releases the mouse. The result will be one of drag-drop effect,
  ## wDragCancel, or wDragError.

  # SHDoDragDrop better than DoDragDrop on:
  # 1. It provides a generic drag image.
  # 2. The Shell creates a drop source object for you.
  #    (According to MSDN, vista later, howevere, Windows XP also works)
  var effect: DWORD
  result = case SHDoDragDrop(0, self.mObj, nil, flags, &effect)
  of DRAGDROP_S_DROP:
    effect
  of DRAGDROP_S_CANCEL:
    wDragCancel
  else:
    wDragError

proc delete*(self: wDataObject) {.validate.} =
  ## Nim's garbage collector will delete this object by default.
  ## However, sometimes you maybe want do that by yourself.
  ## Moreover, if the data object is still on the clipboard, delete
  ## it will force to flush it.
  `=destroy`(self[])

wClass(wDataObject):

  proc init*(self: wDataObject, dataObj: ptr IDataObject) {.validate, inline.} =
    ## Initializes a dataObject from IDataObject COM interface. Used internally.
    self.mObj = dataObj
    self.mReleasable = false

  proc init*(self: wDataObject, text: string) {.validate.} =
    ## Initializes a dataObject from text.
    try:
      if SHCreateFileDataObject(nil, 0, nil, nil, &self.mObj) != S_OK:
        self.error()
    except LibraryError:
      self.error()

    # if SHCreateDataObject(nil, 0, nil, nil, &IID_IDataObject, &self.mObj) != S_OK:
    #   error()

    self.mReleasable = true

    var format = FORMATETC(
      dwAspect: DVASPECT_CONTENT,
      lindex: -1,
      tymed: TYMED_HGLOBAL)

    var medium = STGMEDIUM(tymed: TYMED_HGLOBAL)

    let
      wstr = +$text
      pWstr = GlobalAlloc(GPTR, SIZE_T wstr.len * 2 + 2)
      mstr = -$text
      pMstr = GlobalAlloc(GPTR, SIZE_T mstr.len + 1)

    if pWstr == 0 or pMstr == 0: self.error()
    cast[ptr WCHAR](pWstr) <<< wstr
    cast[ptr char](pMstr) <<< mstr

    format.cfFormat = CF_UNICODETEXT
    medium.u.hGlobal = pWstr
    if self.mObj.SetData(&format, &medium, TRUE) != S_OK: self.error()

    format.cfFormat = CF_TEXT
    medium.u.hGlobal = pMstr
    if self.mObj.SetData(&format, &medium, TRUE) != S_OK: self.error()

  proc init*(self: wDataObject, files: openarray[string]) {.validate.} =
    ## Initializes a dataObject from files. The path must exist.
    if files.len == 0: self.error()

    var pidlDesk: PIDLIST_ABSOLUTE
    if SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, &pidlDesk) != S_OK: self.error()
    defer: CoTaskMemFree(pidlDesk)

    var apidl = newSeqOfCap[PIDLIST_ABSOLUTE](files.len)
    var buffer = T(65536)
    for file in files:
      if GetFullPathName(file, 65536, &buffer, nil) == 0: self.error()
      var il = ILCreateFromPath(buffer)
      if il == nil: self.error()
      apidl.add(il)

    try:
      if SHCreateFileDataObject(pidlDesk, files.len, &apidl[0], nil, &self.mObj) != S_OK:
        self.error()
    except LibraryError:
      self.error()

    self.mReleasable = true

    for il in apidl:
      ILFree(il)

  proc init*(self: wDataObject, bmp: wBitmap) {.validate.} =
    ## Initializes a dataObject from bitmap.
    wValidate(bmp)

    self.mObj = newBmpDataObject(bmp.mHandle)
    if self.mObj == nil: self.error()
    self.mReleasable = true

  proc init*(self: wDataObject, dataObj: wDataObject) {.validate.} =
    ## Initializes a dataObject from a wDataObject, aka. copy.
    wValidate(dataObj)
    if dataObj.isText():
      self.init(dataObj.getText())
    elif dataObj.isFiles():
      self.init(dataObj.getFiles())
    elif dataObj.isBitmap():
      self.init(dataObj.getBitmap())
    else:
      self.error()
