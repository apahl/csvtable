# csvtable
Tools for handling CSV files (comma or tab-separated) with an API similar to Python's CSVDictReader and -Writer.
The values in the rows are assigned to tables as values where the keys are the corresponding headers.

## Example usage

```Nim
import csvtable
var csvTbl: CSVTblReader
var csvOut: CSVTblWriter
let headers = csvTbl.open("test.csv")
echo headers
csvOut.open("tmp.csv", headers)
for d in csvTbl:
    echo d
    csvOut.writeRow(d)
csvOut.close
```

## Installation
`nimble install csvtable`

## Documentation
Run `nimble gendoc`. Documentation can then be found in `doc/csvtable.html`.