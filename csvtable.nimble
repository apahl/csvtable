# Package

version       = "0.2.0"
author        = "Axel Pahl"
description   = "Nim tools for handling CSV files with an API similar to Python\'s CSVDictReader and -Writer"
license       = "MIT"

# Dependencies

requires "nim >= 0.15.3"

const
  module = "csvtable"

task doc, "build the documentation":
  echo "\nBuilding documentation in doc/"
  let taskCmd = "nim -o:doc/" & module & ".html doc " & module & ".nim"
  exec taskCmd

task test, "run the tests":
  echo "\nRunning tests..."
  let taskCmd = "nim -r --verbosity:0 --hints:off c " & module & ".nim"
  exec taskCmd
  rmFile toExe(module)