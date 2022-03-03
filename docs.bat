@echo off
title Generate docs for mongo-godot-driver

@REM needs godot to be available in PATH

set GDSCRIPT_DOCS_MAKER_PATH=%CD%\docs\gdscript-docs-maker
set DOCS_BUILD_PATH=%CD%\docs\site\content

set CUR_DIR=%CD%
pushd .
cd project
set PROJECT_PATH=%CD%
erase /Q reference.json
robocopy %GDSCRIPT_DOCS_MAKER_PATH%\godot-scripts . Collector.gd /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT
robocopy %GDSCRIPT_DOCS_MAKER_PATH%\godot-scripts . ReferenceCollectorCLI.gd /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT


@REM replace `var directories := ["res://"]` with `var directories := ["res://addons/mongo-godot-driver/wrapper"]`
python replace_doc_dir.py

cmd.exe /c godot --quiet -q -d -e -s --no-window --path %PROJECT_PATH% ReferenceCollectorCLI.gd > nul
erase /Q Collector.gd
erase /Q ReferenceCollectorCLI.gd
rmdir __pycache__ /s /q > nul
set GD_PROJECT_PATH=%CD%
cd %GDSCRIPT_DOCS_MAKER_PATH%\src\
rmdir %DOCS_BUILD_PATH% /s /q > nul
python -m gdscript_docs_maker %GD_PROJECT_PATH%\reference.json -p %DOCS_BUILD_PATH% -f hugo -d DD-MM-YYYY -a delano -v --make-index
rename %DOCS_BUILD_PATH%\index.md _index.md
cd %CUR_DIR%