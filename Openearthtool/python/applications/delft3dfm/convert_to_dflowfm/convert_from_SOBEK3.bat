@ echo off

    rem Usage:
    rem 1. Be sure that parameter "pythonscript" below points to the location of the Python conversion script on your PC
    rem 2. Be sure that parameter "inputfile"    below points to the correct SOBEK3 md1d file                 on your PC
    rem 3. Execute this batch file
    rem    result: directory "dflowfm" next to this batch file

set pythonscript=c:\code\other\convert_to_dflowfm\Run.py
set inputfile=d:\testbank\cases\e106_dflow1d\f15_backwater-curves\c01_M1_iadvec1d_1\dflow1d\Flow1d.md1d

set ThisBatchFileLocation=%~dp0
set outputdir=%ThisBatchFileLocation%

    rem Execute the script
python.exe %pythonscript% -i %inputfile%  -o %outputdir%

    rem To avoid the command box to disappear immediately
pause

