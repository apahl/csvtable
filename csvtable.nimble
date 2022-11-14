# Package

version       = "0.3.2"
author        = "Axel Pahl"
description   = "Nim tools for handling CSV files with an API similar to Python\'s CSVDictReader and -Writer"
license       = "MIT"

# Dependencies

requires "nim >= 0.18.1"

const
  module = "csvtable"

task gendoc, "build the documentation":
  echo "\nBuilding documentation in doc/"
  mkDir "doc"
  let taskCmd = "nim -o:doc/" & module & ".html doc " & module & ".nim"
  exec taskCmd

task test, "run the tests":
  echo "\nRunning tests..."
  let taskCmd = "nim -r --verbosity:0 --hints:off c " & module & ".nim"
  exec taskCmd
  rmFile toExe(module)