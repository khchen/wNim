#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2020 Ward
#
#====================================================================

## Basic types definition for wNim.

{.experimental, deadCodeElim: on.}

# Export some modules that every module in wNim depends on.
import winim/[winstr, utils], winim/inc/windef, kiwi/kiwi
export winstr, utils, windef, kiwi

import winimx except BITMAP
export winimx except BITMAP

import wTypes, wMacros, wHelper
export wTypes, wMacros, wHelper

import consts/[wColors, wKeyCodes]
export wColors, wKeyCodes

# Needs a new line so that wApp can use wEventId() in wMacros.
import wApp
export wApp
