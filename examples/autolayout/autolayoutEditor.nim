#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                (c) Copyright 2017-2019 Ward
#
#====================================================================

import
  ../resource/resource,
  wNim,
  strutils, macros

type
  MenuID = enum
    idVertical = wIdUser, idHorizontal, idExit, idExample

  Example = object
    name: string
    vfl: string
    show: proc ()

var app = App()
var frame = Frame(title="AutoLayout Editor", size=(900, 600))
frame.icon = Icon("", 0) # load icon from exe file.

macro generateExamples(x: untyped): untyped =

  var code = """
    var examples = newSeq[Example]()
  """.unindent

  var templ = """
  examples.add Example(name: $1, vfl: $2, show: proc () =
    var win = Frame(frame, title=$1, size=(400, 400))
    var panel = Panel(win)
    const style = wAlignCentre or wAlignMiddle or wBorderSimple
$3
    win.wEvent_Size do (event: wEvent):
      panel.autorelayout $2

    win.center()
    win.show()
  )
  """

  for i in x:
    var
      name = i[0].strVal
      vfl = i[1][0].strVal.unindent
      parser = initVflParser()
      children = ""

    parser.parse(vfl)
    for item in parser.names:
      children.add "var $1 = StaticText(panel, label=\"$2\", style=style)\n" % [item, item]

    code.add templ.unindent(2) % [name.escape, vfl.escape, children.indent(2)]

  parseStmt(code)

generateExamples:
  "Proportional size":
    """
      H:|-[view(50%)]
      V:|-[view(50%)]
    """

  "Operators":
    """
      H:|-[view1(==view2*4-100)]-[view2]-|
      V:|-[view1(==view2*4-100)]-[view2]-|
    """

  "Attributes":
    """
      H:|-[view1]-|
      V:|-[view1(view1.width/2)]
    """

  "Equal Size Spacers":
    """
      H:|~[view1,view2(100)]~|
      V:|~[view1(100)]~[view2(100)]~|
    """

  "View Stacks":
    """
      V:|-{column:[view1(50)]-[view2]-[view3(50)]}-|
      H:|-[column]-|
    """

  "View Ranges":
    """
      H:[view1(view1.height)]
      HV:[view2..5(view1)]
      H:|-[view1]-[view2]-[view3]-[view4]-[view5]-|
      V:|~[view1..5]~|
    """

  "Multiple Views":
    """
      H:|-[view1(view2,view4)]-[view2,view3]-[view4]-|
      V:|-[view1,view4]-|
      V:|-[view2(view3)]-[view3]-|
    """

  "Multiple orientations":
    """
      HV:|-[view]-|
    """

  "Disconnections":
    """
      H:|-{column:[left1]-[left2]->[right1]-[right2]}-|
      H:[column(50)]
      V:|-[column]-|
    """

  "Overlapping Views":
    """
      H:|-[view1,view2,view3]-|
      V:|-[view1(100)]-(-10)-[view2(view1)]-(view2/-2)-[view3]-|
    """

  "Explicit Constraint Syntax":
    """
      HV:[view(100)]
      C:view.centerX = panel.centerX
      C:view.centerY = panel.centerY
    """

  "Spacing and Variable Setting":
    """
      spacing: 50
      variable: v
      H:|~[view1..2(100)]-[view3..4(100)]~|
      V:|~[view1,view3(100)]-[view2,view4(100)]~|
    """

  "Outer Setting":
    """
      HV:|-[view1]-|
      outer: view1
      HV:|-(100)-[view2]-(100)-|
    """

  "Priority":
    """
      HV:|-(10@WEAK)-[view(100@STRONG)]-(10@WEAK)|
    """

  "Comments, Space, and Newline":
    """
      // Single line comments
      # Single line comments
      |-[view1]-| # H: can be omit, but not encourage
      V: | -
            [ view1 ]
          - | # space and newline are ignored
    """

  "Autolayout.js Example 1":
    """
      |-[child1(child3)]-[child3]-|
      |-[child2(child4)]-[child4]-|
      [child5(child4)]-|
      V:|-[child1(child2)]-[child2]-|
      V:|-[child3(child4,child5)]-[child4]-[child5]-|
    """

  "Autolayout.js Example 2":
    """
      V:|-{col1:[child1(child2)]-[child2]}-|
      V:|-{col2:[child3(child4,child5)]-[child4]-[child5]}-|
      H:|-[col1(col2)]-[col2]-|
    """

  "Layout Example 1":
    """
      spacing: 8
      H:|-[text1..2]-[text3..5(text1)]-|
      V:|-[text1]-[text2(text1)]-|
      V:|-[text3(text4,text5)]-[text4]-[text5]-|
    """

  "Layout Example 2":
    """
      spacing: 8
      H:|~[text4..5(text1+text2+text3+16)]~|
      H:|~[text2(text1)]-[text1(<=200@STRONG)]-[text3(text1)]~|
      V:|~[text4(text1*0.66)]-[text1..3(<=100@STRONG)]-[text5(text1*0.66)]~|
      C: WEAK: text1.width = panel.width / 4
      C: WEAK: text1.height = panel.height / 3
    """

  "Layout Example 3":
    """
      spacing: 8
      H:|-[text1(60)]-[text2]-|
      H:|-[text1]-[text3(60)]-[text4]-|
      H:|-[text1]-[text3]-(>=8)-[text5(text5.height@WEAK)]-|
      V:|-[text1]-|
      V:|-[text2(60@WEAK)]-[text3]-|
      V:|-[text2]-[text4(60@WEAK)]-[text5]-|
      V:[text4]-(>=8)-|
    """

  "Demo":
    """
      spacing: 10
      H:|-[staticbox1]-[staticbox2..3,notebook]-|
      V:|-[staticbox1]-|
      V:|-[staticbox2]-[staticbox3]-[notebook]-|
      C: staticbox1.innerWidth = calendarctrl.bestSize.width

      outer: staticbox1
      V:|-5-{stack1:[button]-[checkbox]-[textctrl]-[statictext]}-[staticline]-
        {stack2:[datepickerctrl]-[timepickerctrl]}-[calendarctrl]
      H:|-5-[stack1..2,staticline,calendarctrl]-5-|

      outer: staticbox2
      V:|-5-{stack3:[spinctrl]-[slider]-[gauge]}-5-|
      H:|-5-[stack3]-5-|

      outer: staticbox3
      V:|-5-{stack4:[combobox]-[editable]-
        [radiobutton1][radiobutton2][radiobutton3]}-5-|
      H:|-5-[stack4]-5-|

      V:[stack1..4(25)]
    """

var splitter = Splitter(frame, style=wSpHorizontal or wDoubleBuffered, size=(8, 8))
var statusBar = StatusBar(frame)
var menuBar = MenuBar(frame)

var textCtrl1 = TextCtrl(splitter.panel1,
  style=wTeRich or wTeMultiLine or wTeDontWrap or wVScroll)
textCtrl1.font = Font(12, faceName="Consolas", encoding=wFontEncodingCp1252)

var textCtrl2 = TextCtrl(splitter.panel2,
  style=wTeRich or wTeMultiLine or wTeReadOnly or wTeDontWrap or wVScroll)
textCtrl2.font = Font(12, faceName="Consolas", encoding=wFontEncodingCp1252)

proc switchSplitter(mode: int) =
  splitter.splitMode = mode
  statusBar.refresh()
  let size = frame.clientSize
  splitter.move(size.width div 2, size.height div 2)

var menu = Menu(menuBar, "&Layout")
menu.appendRadioItem(idHorizontal, "&Horizontal").check()
menu.appendRadioItem(idVertical, "&Vertical")
menu.appendSeparator()
menu.append(idExit, "E&xit")

var menuExample = Menu(menuBar, "&Example")
for i, e in examples:
  menuExample.append(wCommandID(idExample.ord + i), e.name)

frame.wEvent_Menu do (event: wEvent):
  case event.id
  of idExit:
    frame.close()

  of idVertical:
    if not splitter.isVertical:
      switchSplitter(wSpVertical)

  of idHorizontal:
    if splitter.isVertical:
      switchSplitter(wSpHorizontal)

  else:
    var index = event.id.ord - idExample.ord
    if index >= 0 and index < examples.len:
      # Don't use setValue to allow undo
      textCtrl1.selectAll()
      textCtrl1.writeText(examples[index].vfl)
      examples[index].show()

splitter.panel1.wEvent_Size do ():
  splitter.panel1.autolayout "HV:|[textCtrl1]|"

splitter.panel2.wEvent_Size do ():
  splitter.panel2.autolayout "HV:|[textCtrl2]|"

textCtrl1.wEvent_Text do ():
  textCtrl2.value = autolayout(textCtrl1.value)

switchSplitter(wSpHorizontal)
frame.center()
frame.show()

app.mainLoop()
