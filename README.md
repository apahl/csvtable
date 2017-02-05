# csvtable
Tools for handling CSV files (comma or tab-separated) with an API similar to Python's CSVDictReader and -Writer.
The values in the rows are assigned to tables as values where the keys are the corresponding headers.

## Example usage

```Nim
  import csvtable, strutils
  var
    csvIn: CSVTblReader
    csvOut: CSVTblWriter
  let
    headersIn = csvIn.open("test.csv")
    headersOut = @["position", "total"]  # all headers must be known at the creation of the file
  echo headersIn
  csvOut.open("tmp.csv", headersOut)
  for dIn in csvIn:
    var dOut = newTable[string, string]()
    dOut["position"] = dIn["position"]
    dOut["total"] = $(dIn["day1"].parseInt + dIn["day2"].parseInt)
    csvOut.writeRow(dOut)
  csvOut.close
```

## Installation
`nimble install csvtable`

## Documentation
Run `nimble gendoc`. Documentation can then be found in `doc/csvtable.html`.