rem run swanmud simulation

set RUNID=%1
set executable=..\..\swanmud\Release\swanmud.exe

@echo off
@echo SWAN batchfile executed for Delft3D
@echo Performing wave computation for: %RUNID%.swn
@echo %executable%

date /T       >> %RUNID%.log
time /T       >> %RUNID%.log
echo started  >> %RUNID%.log
echo %RUNID%  >> %RUNID%.log

if exist PRINT              del  PRINT
if exist INPUT              del  INPUT
if exist swaninit           del  swaninit
if exist Errfile            del  Errfile
if exist errpts             del  errpts
if exist %RUNID%.erf        del  %RUNID%.erf
if exist %RUNID%.erp        del  %RUNID%.erp
if not exist %RUNID%.swn    goto error1
if not exist "%executable%" goto error2
copy %RUNID%.swn INPUT

"%executable%"  > %RUNID%.out

if exist errfile  copy errfile     %RUNID%.erf
if exist errpts   copy errpts      %RUNID%.erp
if exist MUDFILE  copy MUDFile     %RUNID%.MUDF

echo finished >> %RUNID%.log
date /T       >> %RUNID%.log
time /T       >> %RUNID%.log

if exist swaninit del  swaninit
goto finish
:error1
@echo
@echo     **************************************************************
@echo                SWAN input file %RUNID%.swn does not exist
@echo     **************************************************************
pause
goto finish
:error2
@echo
@echo     **************************************************************
@echo                SWAN executable does not exist
@echo                (%executable%)
@echo     **************************************************************
pause
goto finish
:finish
@echo on
rem exit
