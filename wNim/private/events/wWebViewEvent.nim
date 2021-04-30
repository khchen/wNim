#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2021 Ward
#
#====================================================================

## A navigation event holds information about events associated with
## wWebView objects.
#
## :Superclass:
##   `wCommandEvent <wCommandEvent.html>`_
#
## :Seealso:
##   `wWebView <wWebView.html>`_
#
## :Events:
##   ==============================  =============================================================
##   wWebViewEvent                   Description
##   ==============================  =============================================================
##   wEvent_WebViewNavigating        Generated before trying to get a resource. This event can be vetoed.
##   wEvent_WebViewContextMenu       Generated before trying to show context menu. This event can be vetoed.
##   wEvent_WebViewNewWindow         Generated when a new window is created. This event can be vetoed.
##   wEvent_WebViewLoaded            Generated when the document is fully loaded and displayed.
##   wEvent_WebViewError             Generated when a navigation error occurs. This event can be vetoed
##                                   (cancel navigation to an error page).
##   wEvent_WebViewTitleChanged      Generated when the page title changes.
##   wEvent_WebViewStatusChanged     Generated when the status text changes.
##   wEvent_WebViewHistoryChanged    Generated when the history of visited pages changes.
##   ==============================  =============================================================

include ../pragma
import ../wBase

wEventRegister(wWebViewEvent):
  wEvent_WebViewFirst
  wEvent_WebViewNavigating
  wEvent_WebViewContextMenu
  wEvent_WebViewNewWindow
  wEvent_WebViewLoaded
  wEvent_WebViewError
  wEvent_WebViewTitleChanged
  wEvent_WebViewStatusChanged
  wEvent_WebViewHistoryChanged
  wEvent_WebViewLast

method getUrl*(self: wWebViewEvent): string {.property, inline.} =
  ## Returns the url (valid for wEvent_WebViewNavigating, wEvent_WebViewNewWindow,
  ## and wEvent_WebViewError).
  result = self.mUrl

method getText*(self: wWebViewEvent): string {.property, inline.} =
  ## Returns the text (valid for wEvent_WebViewStatusChanged and
  ## wEvent_WebViewTitleChanged).
  result = self.mText

method getErrorCode*(self: wWebViewEvent): int {.property, inline.} =
  ## Returns the error code (valid for wEvent_WebViewError).
  result = int self.mLparam
