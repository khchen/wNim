## A panel is a window on which controls are placed. It is usually placed within a frame.
## Its main feature over its parent class wWindow is code for handling child windows and TAB traversal.
##
## :Superclass:
##    wWindow

proc init(self: wPanel, parent: wWindow = nil, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0, className: string = "wPanel") =

  # add wDoubleBuffered to avoid flickering during resizing
  # Does it any problem to add it by default?
  self.wWindow.init(parent=parent, pos=pos, size=size, style=style or wDoubleBuffered, className=className,
    bgColor=GetSysColor(COLOR_BTNFACE))

proc Panel*(parent: wWindow, pos = wDefaultPoint, size = wDefaultSize,
    style: wStyle = 0): wPanel {.discardable.} =
  ## Constructor.
  wValidate(parent)
  new(result)
  result.init(parent=parent, pos=pos, size=size, style=style)
