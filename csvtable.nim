##[Tools for handling CSV files with an API similar to Python's CSVDictReder and -Writer.
The values in the rows are assigned to tables as values where the keys are the corresponding headers.

*Example usage:*

.. code-block::
    import tables
    var csvTbl: CSVTblReader
    var csvOut: CSVTblWriter
    let headers = csvTbl.open("test.csv")
    echo headers
    csvOut.open("tmp.csv", headers)
    for d in csvTbl:
      echo d
      csvOut.writeRow(d)
    csvOut.close
]##

import tables
from strutils import join, split
export tables

type
  CSVTblHandler = object of RootObj
    f: File
    filen: string
    isOpen: bool
    sep*: char
    headers*: seq[string]

  CSVTblReader* = object of CSVTblHandler
  CSVTblWriter* = object of CSVTblHandler

proc open*(csvTbl: var CSVTblReader, filen: string, sep='\t'): seq[string] =
  ##[Opens the csv file, reads and returns the csv headers and keeps the file open for iteration.]##
  csvTbl.f = open(filen, fmRead)
  csvTbl.isOpen = true
  let firstline = csvTbl.f.readLine
  let splt = firstline.split(sep)
  csvTbl.filen = filen
  csvTbl.sep=sep
  result = @[]
  for header in splt:
    result.add(header)
  csvTbl.headers = result

iterator items*(csvTbl: var CSVTblReader): Table[string, string] =
  ##[Reads the csv file line by line and returns a table for each line
  where the keys are the headers and the values are the values from the line.
  Closes the file when done.]##
  if csvTbl.isOpen:
    for line in csvTbl.f.lines:
      var result = initTable[string, string]()
      let s = line.split(csvTbl.sep)
      for idx, val in s:
        if val.len != 0:
          result[csvTbl.headers[idx]] = val
      yield result
    csvTbl.f.close
    csvTbl.isOpen = false
  else:
    raise newException(IOError, "file is not open. Read headers first.")

iterator pairs*(csvTbl: var CSVTblReader): (int, Table[string, string]) =
  ##[Reads the csv file line by line and returns the index and a table for each line
  where the keys are the headers and the values are the values from the line.
  Closes the file when done.]##
  if csvTbl.isOpen:
    var idx = -1
    for line in csvTbl.f.lines:
      var result = initTable[string, string]()
      let s = line.split(csvTbl.sep)
      for idx, val in s:
        if val.len != 0:
          result[csvTbl.headers[idx]] = val
      idx += 1
      yield (idx, result)
    csvTbl.f.close
    csvTbl.isOpen = false
  else:
    raise newException(IOError, "file is not open. Read headers first.")

proc open*(csvTbl: var CSVTblWriter, filen: string, headers: seq[string], sep='\t') =
  ##[Opens the csv file, writes the csv headers and keeps the file open.]##
  csvTbl.f = open(filen, fmWrite)
  csvTbl.isOpen = true
  csvTbl.headers = headers
  csvTbl.filen = filen
  csvTbl.sep=sep
  let line = headers.join($sep) & "\n"
  csvTbl.f.write(line)

proc writeRow*(csvTbl: CSVTblWriter, row: Table[string, string]) =
  ##[Writes a row of values in the columns specified by the table.
  Keeps the file open, it needs to be explicitly closed.]##
  var line: seq[string] = @[]
  for header in csvTbl.headers:
    if header in row:
      line.add(row[header])
    else:
      line.add("")
  let line_str = line.join($csvTbl.sep) & "\n"
  csvTbl.f.write(line_str)

proc close*[T: CSVTblReader | CSVTblWriter](csvTbl: var T) =
  ##Closes the file.
  csvTbl.f.close
  csvTbl.isOpen = false


when isMainModule:
  var csvTbl: CSVTblReader
  var csvOut: CSVTblWriter
  let headers = csvTbl.open("test.csv")
  echo headers
  csvOut.open("tmp.csv", headers)
  for i, d in csvTbl:
    echo i, ": ", d
    csvOut.writeRow(d)
  csvOut.close