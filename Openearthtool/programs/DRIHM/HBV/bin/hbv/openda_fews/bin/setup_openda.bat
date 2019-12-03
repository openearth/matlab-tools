@echo off

rem Setup bin. dir for openda.
rem Script has to be run from the dir. containing the script.

set OPENDADIR=%~dp0
set PATH=%~dp0;%PATH%
@echo OPENDA_BINDIR set to %OPENDADIR%

rem system type: something like win64_gnu or win32_ifort
set ODASYSTEM=win32_ifort
echo "System set to %ODASYSTEM%"

set ODALIBDIR="%OPENDADIR%\%ODASYSTEM%"
