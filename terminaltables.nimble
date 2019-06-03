# Package
version       = "0.1.1"
author        = "xmonader"
description   = "terminal tables"
license       = "BSD-3-Clause"
srcDir        = "src"


# Dependencies

requires "nim >= 0.19.4"
task genDocs, "Create code documentation for terminaltables":
    exec "nim doc --threads:on --project src/terminaltables.nim && rm -rf docs/api; mkdir -p docs && mv src/htmldocs docs/api "


task dmdm, "dmdm":
    echo paramCount()
    echo paramStr(2)
    exec "echo in dmdm"