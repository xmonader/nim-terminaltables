# nim-terminaltables
terminal tables for nim

## API 

API docs available [here](https://xmonader.github.io/nim-terminaltables/api/terminaltables.html)
terminaltables has a very small API
- `newUnicodeTable` uses `unicodeStyle`
- `newAsciiTable` uses `asciiStyle`

Table style is configurable using `Style` object. Here's an example of how `asciiStyle` and `unicodeStyle` are defined

```nim

let asciiStyle =   Style(rowSeparator:"-", colSeparator:"|", cellEdgeLeft:"+", cellEdgeRight:"+", topLeft:"+", topRight:"+", bottomLeft:"-", bottomRight:"-", topRowSeparator:"-", bottomRowSeparator:"-", dashLineLeft:"+", dashLineRight:"+", dashLineColSeparatorLastRow:"+", dashLineColSeparatorTopRow:"+", dashLineColSeparator:"+")
let unicodeStyle = Style(rowSeparator:"─", colSeparator:"│", cellEdgeLeft:"├", cellEdgeRight:"┤", topLeft:"┌", topRight:"┐", bottomLeft:"└", bottomRight:"┘", topRowSeparator:"┬", bottomRowSeparator:"┴", dashLineLeft:"├", dashLineRight:"┤", dashLineColSeparatorLastRow:"┴", dashLineColSeparatorTopRow:"┬", dashLineColSeparator:"┼")

```
- newUnicodeTable to create Table with unicode table style
- newAsciiTable to create Table with ascii table style
- separateRows controls if you want to add dashline between rows.
- addRow used to add a row to the table
- setHeaders used to set headers of the table and it accepts strings or `cell objects` with padding information.
- a
```nim


  let t2 = newUnicodeTable()
  t2.separateRows = false
  t2.setHeaders(@["ID", "Name", "Fav animal", "Date"])
  # t2.setHeaders(@[newCell("ID", pad=5), newCell("Name", rightpad=10), newCell("Fav animal", pad=2), newCell("Date", 5)])
  t2.addRow(@["1", "xmonader", "Cat, Dog", "2018-10-22"])
  t2.addRow(@["2", "ahmed", "Shark", "2015-12-6"])
  t2.addRow(@["3", "dr who", "Humans", "1018-5-2"])
  printTable(t2)
```


## Examples

```nim

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

  let t2 = newUnicodeTable()
  t2.separateRows = false
  t2.setHeaders(@[newCell("ID", pad=5), newCell("Name", rightpad=10), newCell("Fav animal", pad=2), newCell("Date", 5)])
  t2.addRow(@["1", "xmonader", "Cat, Dog", "2018-10-22"])
  t2.addRow(@["2", "ahmed", "Shark", "2015-12-6"])
  t2.addRow(@["3", "dr who", "Humans", "1018-5-2"])
  printTable(t2)
```

```
+------------------------+------------------------+------------------------+------------------------+------------------------+
| ID                     | Name                   | Fav animal             | Date                   | OK                     |
+------------------------+------------------------+------------------------+------------------------+------------------------+
| 1                      | xmonader               | Cat, Dog               | 2018-10-2              | yes                    |
+------------------------+------------------------+------------------------+------------------------+------------------------+
| 2                      | ahmed                  | Shark                  | 2018-10-2              | yes                    |
+------------------------+------------------------+------------------------+------------------------+------------------------+
| 3                      | dr who                 | Humans                 | 1018-5-2               | no                     |
-------------------------+------------------------+------------------------+------------------------+-------------------------

+----+----------+------------+-----------+-----+
| ID | Name     | Fav animal | Date      | OK  |
+----+----------+------------+-----------+-----+
| 1  | xmonader | Cat, Dog   | 2018-10-2 | yes |
+----+----------+------------+-----------+-----+
| 2  | ahmed    | Shark      | 2018-10-2 | yes |
+----+----------+------------+-----------+-----+
| 3  | dr who   | Humans     | 1018-5-2  | no  |
-----+----------+------------+-----------+------

+----+----------+------------+-----------+-----+
| ID | Name     | Fav animal | Date      | OK  |
+----+----------+------------+-----------+-----+
| 1  | xmonader | Cat, Dog   | 2018-10-2 | yes |
| 2  | ahmed    | Shark      | 2018-10-2 | yes |
| 3  | dr who   | Humans     | 1018-5-2  | no  |
-----+----------+------------+-----------+------

┌────────────┬───────────────────┬──────────────┬────────────────┐
│     ID     │ Name              │  Fav animal  │     Date       │
├────────────┼───────────────────┼──────────────┼────────────────┤
│     1      │ xmonader          │  Cat, Dog    │     2018-10-22 │
│     2      │ ahmed             │  Shark       │     2015-12-6  │
│     3      │ dr who            │  Humans      │     1018-5-2   │
└────────────┴───────────────────┴──────────────┴────────────────┘
```

## using custom styles
Using custom styles is pretty easy 

```nim


  var t2 = newUnicodeTable()
  t2.separateRows = false
  t2.setHeaders(@[newCell("ID", pad=5), newCell("Name", rightpad=10), newCell("Fav animal", pad=2), newCell("Date", 5)])
  t2.addRow(@["1", "xmonader", "Cat, Dog", "2018-10-22"])
  t2.addRow(@["2", "ahmed", "Shark", "2015-12-6"])
  t2.addRow(@["3", "dr who", "Humans", "1018-5-2"])
  t2.separateRows = true
  let testStyle =  Style(rowSeparator:"┈", colSeparator:"┇", cellEdgeLeft:"├", cellEdgeRight:"┤", topLeft:"┏", topRight:"┓", bottomLeft:"└", bottomRight:"┘", topRowSeparator:"┬", bottomRowSeparator:"┴", dashLineLeft:"├", dashLineRight:"┤", dashLineColSeparatorLastRow:"┴", dashLineColSeparatorTopRow:"┬", dashLineColSeparator:"┼")

  t2.style = testStyle
  printTable(t2)
  ```
```
┏┈┈┈┈┈┈┈┈┈┈┈┈┬┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┬┈┈┈┈┈┈┈┈┈┈┈┈┈┈┬┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┓
┇     ID     ┇ Name              ┇  Fav animal  ┇     Date       ┇
├┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┤
┇     1      ┇ xmonader          ┇  Cat, Dog    ┇     2018-10-22 ┇
├┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┤
┇     2      ┇ ahmed             ┇  Shark       ┇     2015-12-6  ┇
├┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┼┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┤
┇     3      ┇ dr who            ┇  Humans      ┇     1018-5-2   ┇
└┈┈┈┈┈┈┈┈┈┈┈┈┴┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┴┈┈┈┈┈┈┈┈┈┈┈┈┈┈┴┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┘


```