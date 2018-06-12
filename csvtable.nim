##[Tools for handling CSV files (comma or tab-separated) with an API similar to Python's CSVDictReader and -Writer.
The values in the rows are assigned to tables as values where the keys are the corresponding headers.

Please note: version 0.3.0 changes the API, have a look at the example and the doc. For the old API. use releases <0.3.0.

*Example usage:*

.. code-block::
    import csvtable, strutils
    var
      csvIn = newCSVTblReader("test.csv")
    echo csvIn.headers
    let
      headersOut = @["position", "total"]  # all headers must be known at the creation of the file
    var csvOut = newCSVTblWriter("tmp.csv", headersOut)
    for dIn in csvIn:
      var dOut = newTable[string, string]()
      dOut["position"] = dIn["position"]
      dOut["total"] = $(dIn["day1"].parseInt + dIn["day2"].parseInt)
      csvOut.writeRow(dOut)
    csvOut.close]##

import tables
import strutils
export tables

type
  CSVTblHandler = object of RootObj
    f: File
    filen*: string
    isOpen*: bool
    sep*: char
    headers*: seq[string]

  CSVTblReader* = object of CSVTblHandler
  CSVTblWriter* = object of CSVTblHandler

proc newCSVTblReader*(filen: string, sep=','): CSVTblReader =
  ##[Opens the csv file, reads csv headers,
  returns the instance and keeps the file open for iteration.]##
  var headers: seq[string] = @[]
  result.f = open(filen, fmRead)
  result.isOpen = true
  let firstline = result.f.readLine
  let splt = firstline.split(sep)
  result.filen = filen
  result.sep=sep
  for header in splt:
    headers.add(header)
  result.headers = headers

proc newCSVTblWriter*(filen: string, headers: seq[string], sep=','): CSVTblWriter =
  ##[Opens the csv file, writes the csv headers and keeps the file open.
  Remember to manually close the file when done.]##
  result.f = open(filen, fmWrite)
  result.isOpen = true
  result.headers = headers
  result.filen = filen
  result.sep=sep
  let line = headers.join($sep) & "\n"
  result.f.write(line)

proc writeRow*(csvTbl: CSVTblWriter, row: TableRef[string, string]) =
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

iterator items*(csvTbl: var CSVTblReader): TableRef[string, string] =
  ##[Reads the csv file line by line and returns a table for each line
  where the keys are the headers and the values are the values from the line.
  Closes the file when done.]##
  if csvTbl.isOpen:
    for line in csvTbl.f.lines:
      var result = newTable[string, string]()
      let s = line.split(csvTbl.sep)
      for idx, val in s:
        if val.len != 0:
          result[csvTbl.headers[idx]] = val
      yield result
    csvTbl.f.close
    csvTbl.isOpen = false
  else:
    raise newException(IOError, "file is not open. Read headers first.")

iterator pairs*(csvTbl: var CSVTblReader): (int, TableRef[string, string]) =
  ##[Reads the csv file line by line and returns the index and a table for each line
  where the keys are the headers and the values are the values from the line.
  Closes the file when done.]##
  if csvTbl.isOpen:
    var idx = -1
    for line in csvTbl.f.lines:
      var result = newTable[string, string]()
      let s = line.split(csvTbl.sep)
      for i, val in s:
        if val.len != 0:
          result[csvTbl.headers[i]] = val
      idx += 1
      yield (idx, result)
    csvTbl.f.close
    csvTbl.isOpen = false
  else:
    raise newException(IOError, "file is not open. Read headers first.")

proc next*(csvTbl: var CSVTblReader): TableRef[string, string] =
  ##[Returns a new line from the csv file on each call. At the end of the file an empty table is returned (len == 0) and the csv file is closed.]##
  result = newTable[string, string]()
  if csvTbl.isOpen:
    try:
      let
        ln = csvTbl.f.readLine()
        s = ln.split(csvTbl.sep)
      for i, val in s:
        if val.len != 0:
          result[csvTbl.headers[i]] = val

    except IOError:
      csvTbl.close
  else:
    raise newException(IOError, "file is not open. Read headers first.")


when isMainModule:
  import strutils
  var
    csvIn = newCSVTblReader("test.csv")
  echo csvIn.headers
  let
    headersOut = @["position", "total"]  # all headers must be known at the creation of the file
  var csvOut = newCSVTblWriter("tmp.csv", headersOut)
  for dIn in csvIn:
    var dOut = newTable[string, string]()
    dOut["position"] = dIn["position"]
    dOut["total"] = $(dIn["day1"].parseInt + dIn["day2"].parseInt)
    csvOut.writeRow(dOut)
  csvOut.close