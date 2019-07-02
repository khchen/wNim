#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## This class represents the font chooser dialog.
#
## :Seealso:
##   `wMessageDialog <wMessageDialog.html>`_
##   `wFileDialog <wFileDialog.html>`_
##   `wDirDialog <wDirDialog.html>`_
##   `wColorDialog <wColorDialog.html>`_

proc getChosenFont*(self: wFontDialog): wFont {.validate, property, inline.} =
  ## Gets the font chosen by the user if the user pressed OK.
  result = self.mChosenFont

proc setChosenFont*(self: wFontDialog, font: wFont) {.validate, property, inline.} =
  ## Sets the font that will be returned to the user (for internal use only).
  self.mChosenFont = font

proc getInitialFont*(self: wFontDialog): wFont {.validate, property, inline.} =
  ## Gets the font that will be initially used by the font dialog.
  result = self.mInitialFont

proc setInitialFont*(self: wFontDialog, font: wFont) {.validate, property, inline.} =
  ## Sets the font that will be initially used by the font dialog.
  self.mInitialFont = font

proc getColor*(self: wFontDialog): wColor {.validate, property, inline.} =
  ## Gets the color associated with the font dialog.
  result = self.mColor

proc setColor*(self: wFontDialog, color: wColor) {.validate, property, inline.} =
  ## Sets the color that will be used for the font foreground color.
  self.mColor = color

proc getEnableEffects*(self: wFontDialog): bool {.validate, property, inline.} =
  ## Determines whether "effects" are enabled.
  result = self.mEnableEffects

proc setEnableEffects*(self: wFontDialog, enable: bool) {.validate, property, inline.} =
  ## Sets the color that will be used for the font foreground color.
  self.mEnableEffects = enable

proc enableEffects*(self: wFontDialog, enable: bool) {.validate, inline.} =
  ## Sets the color that will be used for the font foreground color.
  self.mEnableEffects = enable

proc getAllowSymbols*(self: wFontDialog): bool {.validate, property, inline.} =
  ## Returns a flag determining whether symbol fonts can be selected.
  result = self.mAllowSymbols

proc setAllowSymbols*(self: wFontDialog, allowSymbols: bool) {.validate, property, inline.} =
  ## Determines whether symbol fonts can be selected.
  self.mAllowSymbols = allowSymbols

proc getShowHelp*(self: wFontDialog): bool {.validate, property, inline.} =
  ## Returns true if the Help button will be shown.
  result = self.mShowHelp

proc setShowHelp*(self: wFontDialog, showHelp: bool) {.validate, property, inline.} =
  ## Determines whether the Help button will be displayed in the font dialog.
  self.mShowHelp = showHelp

proc getRange*(self: wFontDialog): Slice[int] {.validate, property, inline.} =
  ## Returns the valid range for the font point size.
  result = self.mRange

proc setRange*(self: wFontDialog, min: int, max: int) {.validate, property, inline.} =
  ## Sets the valid range for the font point size.
  self.mRange = min..max

proc setRange*(self: wFontDialog, range: Slice[int]) {.validate, property, inline.} =
  ## Sets the valid range for the font point size.
  self.mRange = range

proc final*(self: wFontDialog) {.validate.} =
  ## Default finalizer for wFontDialog.
  discard

proc init*(self: wFontDialog, parent: wWindow = nil, font: wFont = nil,
    color = wBlack, enableEffects = true, allowSymbols = true, showHelp = false,
    range = 0..0) {.validate.} =
  ## Initializer.
  self.mParent = parent
  self.mInitialFont = font
  self.mColor = color
  self.mEnableEffects = enableEffects
  self.mAllowSymbols = allowSymbols
  self.mShowHelp = showHelp
  self.mRange = range

proc FontDialog*(parent: wWindow = nil, font: wFont = nil, color = wBlack,
    enableEffects = true, allowSymbols = true, showHelp = false,
    range = 0..0): wFontDialog {.inline.} =
  ## Constructor.
  new(result, final)
  result.init(parent, font, color, enableEffects, allowSymbols, showHelp, range)

proc showModal*(self: wFontDialog): wId {.discardable.} =
  ## Shows the dialog, returning wIdOk if the user pressed OK, and wIdCancel
  ## otherwise.
  var
    lf: LOGFONT
    cf = TCHOOSEFONT(lStructSize: sizeof(TCHOOSEFONT), lpLogFont: &lf)

  if self.mInitialFont != nil:
    cf.Flags = cf.Flags or CF_INITTOLOGFONTSTRUCT
    GetObject(self.mInitialFont.mHandle, sizeof(LOGFONT), cast[pointer](&lf))

  if self.mEnableEffects:
    cf.Flags = cf.Flags or CF_EFFECTS
    cf.rgbColors = self.mColor

  if not self.mAllowSymbols:
    cf.Flags = cf.Flags or CF_SCRIPTSONLY

  if self.mShowHelp:
    cf.Flags = cf.Flags or CF_SHOWHELP

  if self.mRange != 0..0:
    cf.Flags = cf.Flags or CF_LIMITSIZE
    cf.nSizeMin = self.mRange.a
    cf.nSizeMax = self.mRange.b

  if self.mParent != nil:
    cf.hwndOwner = self.mParent.mHwnd

  if ChooseFont(cf):
    self.mChosenFont = Font(lf)
    self.mColor = cf.rgbColors
    result = wIdOk
  else:
    result = wIdCancel

proc show*(self: wFontDialog): wId {.inline, discardable.} =
  ## The same as showModal().
  result = self.showModal()

proc showModalResult*(self: wFontDialog): wFont {.inline, discardable.} =
  ## Shows the dialog, returning the user-selected font or nil.
  if self.showModal() == wIdOk:
    result = self.mChosenFont

proc showResult*(self: wFontDialog): wFont {.inline, discardable.} =
  ## The same as showModalResult().
  if self.show() == wIdOk:
    result = self.mChosenFont
