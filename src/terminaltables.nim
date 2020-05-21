import strformat, strutils
from unicode import runeLen

type Cell* = ref object
  leftpad*: int
  rightpad: int
  pad*: int
  text*: string

proc newCell*(text: string, leftpad = 1, rightpad = 1, pad = 0): Cell =
  result = Cell(pad: pad, text: text)
  if pad != 0:
    result.leftpad = pad
    result.rightpad = pad
  else:
    result.leftpad = leftpad
    result.rightpad = rightpad

proc newCellFromAnother(another: Cell): Cell =
  result = newCell(another.text, another.leftpad, another.rightpad)

proc len*(this: Cell): int =
  result = this.leftpad + this.text.runeLen + this.rightpad

proc `$`*(this:Cell): string =
  result = " ".repeat(this.leftpad) & this.text & " ".repeat(this.rightpad)

type Style* = object
  rowSeparator*: string
  colSeparator*: string
  cellEdgeLeft*: string
  cellEdgeRight*: string
  dashLineLeft*: string
  dashLineRight*: string
  dashLineColSeparatorTopRow*: string
  dashLineColSeparatorLastRow*: string
  dashLineColSeparator*: string
  topLeft*: string
  topRight*: string
  topRowSeparator*: string
  bottomRowSeparator*: string
  bottomLeft*: string
  bottomRight*: string

const
  asciiStyle* = Style(
    rowSeparator: "-", colSeparator: "|",
    cellEdgeLeft: "+", cellEdgeRight: "+",
    topLeft: "+", topRight: "+",
    bottomLeft: "-", bottomRight: "-",
    topRowSeparator: "-", bottomRowSeparator: "-",
    dashLineLeft: "+", dashLineRight: "+",
    dashLineColSeparatorLastRow: "+", dashLineColSeparatorTopRow: "+",
    dashLineColSeparator: "+"
  )

  unicodeStyle* = Style(
    rowSeparator: "─", colSeparator: "│",
    cellEdgeLeft: "├", cellEdgeRight: "┤",
    topLeft: "┌", topRight: "┐",
    bottomLeft: "└", bottomRight: "┘",
    topRowSeparator: "┬", bottomRowSeparator: "┴",
    dashLineLeft: "├", dashLineRight: "┤",
    dashLineColSeparatorLastRow: "┴", dashLineColSeparatorTopRow: "┬",
    dashLineColSeparator: "┼"
  )

  noStyle* = Style()

type TerminalTable* = ref object
  rows: seq[seq[string]]
  headers: seq[Cell]
  style*: Style
  widths: seq[int]
  suggestedWidths: seq[int]
  tableWidth*: int
  separateRows*: bool

proc newTerminalTable*(style = asciiStyle): TerminalTable =
  TerminalTable(
    style: style,
    tableWidth: 0,
    separateRows: true
  )

proc newAsciiTable*(style = asciiStyle): TerminalTable =
  result = newTerminalTable()

proc newUnicodeTable*(style = unicodeStyle): TerminalTable =
  result = newTerminalTable(style)

proc columnsCount*(this: TerminalTable): int =
  result = this.headers.len

proc setHeaders*(this: TerminalTable, headers: seq[string]) =
  for s in headers:
    var cell = newCell(s)
    this.headers.add(cell)

proc setHeaders*(this: TerminalTable, headers: seq[Cell]) =
  this.headers = headers

proc setRows*(this: TerminalTable, rows: seq[seq[string]]) =
  this.rows = rows

proc addRows*(this: TerminalTable, rows: seq[seq[string]]) =
  this.rows.add(rows)

proc addRow*(this: TerminalTable, row: seq[string]) =
  this.rows.add(row)

proc suggestWidths*(this: TerminalTable, widths: seq[int]) =
  this.suggestedWidths = widths

proc reset*(this: TerminalTable) =
  this[] = newTerminalTable()[]

proc calculateWidths(this: TerminalTable) =
  var colsWidths = newSeq[int]()
  if this.suggestedWidths.len == 0:
    for h in this.headers:
      colsWidths.add(h.len)
  else:
    colsWidths = this.suggestedWidths
  
  for row in this.rows:
    for colpos, c in row:
      var acell = newCellFromAnother(this.headers[colpos])
      acell.text = c
      if len(acell) > colsWidths[colpos]:
        colsWidths[colpos] = len(acell)

  let sizeForCol = (this.tablewidth/len(this.headers)).toInt()
  var lenHeaders = 0
  for w in colsWidths:
    lenHeaders += w

  if this.tablewidth > lenHeaders:
    if this.suggestedWidths.len == 0:
      for colpos, c in colsWidths:
        colsWidths[colpos] += sizeForCol - c
  
  if this.suggestedWidths.len != 0:
    var sumSuggestedWidths = 0
    for s in this.suggestedWidths:
      sumSuggestedWidths += s
    
    if lenHeaders > sumSuggestedWidths:
      raise newException(ValueError, fmt"sum of {this.suggestedWidths} = {sumSuggestedWidths} and it's less than required length {lenHeaders}")
  
  this.widths = colsWidths

proc oneLine(this: TerminalTable): string =
  result &= this.style.cellEdgeLeft
  for w in this.widths[0..^2]:
    result &= this.style.rowSeparator.repeat(w) & this.style.dashLineColSeparator
  result &= this.style.rowSeparator.repeat(this.widths[^1]) & this.style.dashLineRight & "\n"


proc oneLineTop(this: TerminalTable): string =
  result &= this.style.topLeft
  for w in this.widths[0..^2]:
    result &= this.style.rowSeparator.repeat(w) & this.style.dashLineColSeparatorTopRow

  result &= this.style.rowSeparator.repeat(this.widths[^1]) & this.style.topRight & "\n"

proc oneLineBottom(this: TerminalTable): string =
  result &= this.style.bottomLeft
  for w in this.widths[0..^2]:
    result &= this.style.rowSeparator.repeat(w) & this.style.dashLineColSeparatorLastRow

  result &= this.style.rowSeparator.repeat(this.widths[^1]) & this.style.bottomRight & "\n"

proc render*(this: TerminalTable): string =
  this.calculateWidths()
  # top border
  result &= this.oneLineTop()
  
  # headers
  for colidx, h in this.headers:
    result &= this.style.colSeparator & $h & " ".repeat(this.widths[colidx]-len(h) )
  
  result &= this.style.colSeparator
  result &= "\n"
  # finish headers

  # line after headers
  result &= this.oneline()

  # start rows
  for ridx,r in this.rows:
    # start row
    for colidx, c in r:
      let cell = newCell(c,
        leftpad = this.headers[colidx].leftpad,
        rightpad = this.headers[colidx].rightpad
      )
      result &= this.style.colSeparator & $cell & " ".repeat(this.widths[colidx]-len(cell))
    result &= this.style.colSeparator
    result &= "\n"
    if this.separateRows and ridx < this.rows.len-1:
        result &= this.oneLine()

  result &= this.oneLineBottom()

proc printTable*(this: TerminalTable) =
  ## print table.
  echo(this.render())

when not defined(js):
  import os, osproc
  proc termColumns(): int =
    if os.existsEnv("COLUMNS") and getEnv("COLUMNS")[0].isDigit():
        return parseInt(getEnv("COLUMNS"))
    else:
      if findExe("tput") != "":
        let (cols, rc) = execCmdEx("tput cols")
        if rc == 0:
          return cols.strip().parseInt()
      if findExe("stty") != "":
        let (output, rc) = execCmdEx("stty size")
        if rc == 0:
          let parts = output.splitWhitespace()
          if len(parts) == 2:
            return parts[1].strip().parseInt()
    return 0


when isMainModule:

  var t = newTerminalTable()
  var width = 150
  when not defined(js):
    width = termColumns()
    echo "termColumns: " & $termColumns()

  # width of the table is the terminal COLUMNS - the amount of separators (columns + 1)  multiplied by length of the separator
  t.tableWidth = width - (t.columnsCount() * len($t.style.colSeparator)) - 10
  t.setHeaders(@["ID", "Name", "Fav animal", "Date", "OK"])
  t.addRow(@["1", "xmonader", "Cat, Dog", "2018-10-2", "yes"])
  t.addRow(@["2", "ahmed", "Shark", "2018-10-2", "yes"])
  t.addRow(@["3", "dr who", "Humans", "1018-5-2", "no"])
  printTable(t)
  
  t.tableWidth = 0
  printTable(t)

  t.tableWidth = 0
  t.separateRows = false
  printTable(t)
  
  t.reset()

  var t2 = newUnicodeTable()
  t2.separateRows = false
  t2.setHeaders(@[newCell("ID", pad=5), newCell("Name", rightpad=10), newCell("Fav animal", pad=2), newCell("Date", 5)])
  t2.addRow(@["1", "xmonader", "Cat, Dog", "2018-10-22"])
  t2.addRow(@["2", "ahmed", "Shark", "2015-12-6"])
  t2.addRow(@["3", "dr who", "Humans", "1018-5-2"])
  printTable(t2)
  t2.separateRows = false
  let testStyle = Style(
    rowSeparator:"┈", colSeparator:"┇",
    cellEdgeLeft:"├", cellEdgeRight:"┤",
    topLeft:"┏", topRight:"┓",
    bottomLeft:"└", bottomRight:"┘",
    topRowSeparator:"┬", bottomRowSeparator:"┴",
    dashLineLeft:"├", dashLineRight:"┤",
    dashLineColSeparatorLastRow:"┴", dashLineColSeparatorTopRow:"┬",
    dashLineColSeparator:"┼"
  )

  t2.style = testStyle
  printTable(t2)

  t2.style = noStyle
  printTable(t2)

  t2.setHeaders(@[newCell("ID", pad=0), newCell("Name", pad=0), newCell("Fav animal", pad=0), newCell("Date", 0)])

  printTable(t2)
