const
  wFdOpen* = 0
  wFdSave* = 0x1 shl 32
  wFdOverwritePrompt* = OFN_OVERWRITEPROMPT
  wFdNoFollow* = OFN_NODEREFERENCELINKS
  wFdFileMustExist* = OFN_FILEMUSTEXIST
  wFdMultiple* = OFN_ALLOWMULTISELECT
  wFdChangeDir* = 0x2 shl 32

  wFdMaxPath = 65534
  wFdMaxFile = 1024

proc final*(self: wFileDialog) =
  discard

proc init*(self: wFileDialog, parent: wWindow = nil, message: string = nil,
    defaultDir: string = nil, defaultFile: string = nil, wildcard = "*.*",
    style: wStyle = wFdOpen, pos = wDefaultPoint, size = wDefaultSize) {.validate.} =

  mParent = parent
  mMessage = message
  mDefaultDir = defaultDir
  mDefaultFile = defaultFile
  mWildcard = wildcard
  mStyle = style
  mPos = pos
  mSize = size

proc FileDialog*(parent: wWindow = nil, message: string = nil,
    defaultDir: string = nil, defaultFile: string = nil, wildcard = "*.*",
    style: wStyle = wFdOpen, pos = wDefaultPoint, size = wDefaultSize): wFileDialog
    {.inline.} =

  new(result, final)
  result.init(parent, message, defaultDir, defaultFile, wildcard, style, pos, size)

proc showModal*(self: wFileDialog): wId {.discardable.} =
  var
    buffer = T(wFdMaxPath)
    titleBuffer = T(wFdMaxFile)
    ofn = OPENFILENAME(
      lStructSize: sizeof(OPENFILENAME),
      lpstrFile: &buffer,
      nMaxFile: wFdMaxPath,
      lpstrFileTitle: &titleBuffer,
      nMaxFileTitle: wFdMaxFile)

  if mParent != nil:
    ofn.hwndOwner = mParent.mHwnd

  if mDefaultDir != nil:
    ofn.lpstrInitialDir = &T(mDefaultDir)

  if mMessage != nil:
    ofn.lpstrTitle = &T(mMessage)

  if mWildcard != nil:
    discard
    # lpstrFilter
    # nFilterIndex

  ofn.Flags = OFN_EXPLORER or cast[DWORD](mStyle and 0xffffffff)

  if (mStyle and wFdSave) != 0:
    GetSaveFileName(&ofn)
  else:
    GetOpenFileName(&ofn)

  result = wID_OK
# proc echoResult(str: string) =
#   var str = str
#   str.setLen(str.find("\0\0"))
#   for i in str.split("\0"):
#     echo i

# var
#   buffer = T(65536)
#   o = OPENFILENAME(
#     lStructSize: sizeof OPENFILENAME,
#     lpstrTitle: "open file",
#     lpstrFile: &buffer,
#     nMaxFile: 65536,
#     Flags: OFN_EXPLORER or OFN_ALLOWMULTISELECT)

# if GetOpenFileName(o):
#   echoResult($buffer)
