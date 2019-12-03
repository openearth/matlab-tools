@echo off
rem Usage: run_openda_in_fews.bat %1 %2 %3 %4 %5 %6 %7
rem    or: run_openda_in_fews.bat -jre "path of java runtime environment (jre) folder" %3 %4 %5 %6 %7

rem The setlocal statement must be on top!
setlocal enabledelayedexpansion

rem Either
rem    take care that %OPENDA_BINDIR% is set as env. var
rem    (e.g. by running setup_openda.bat on the bin dir)
rem or
rem    Set openda_bindir right here below.
call %~dp0\setup_openda.bat

rem    For running examples that use native code,
rem    add %OPENDA_BINDIR% to the path
rem    Note that it should appear as the first directory
set PATH=%OPENDA_BINDIR%;%PATH%

rem ==== check command line arguments ====
rem ==== OpenDaInFews always needs at least 4 arguments ===
if "%4" == "" goto Error3

if not "%1"=="-jre" goto no_jre_spec
set arg1=
set arg2=
set OPENDA_JRE="%~2%"
rem ==== OpenDaInFews always needs at least 4 arguments + 2 for JRE ===
if "%6" == "" goto Error3
if exist %OPENDA_JRE%\bin\java.exe goto JAVA_OK
goto Error5

:no_jre_spec
set arg1=%1
set arg2=%2
rem ==== check if jre available as distributed with openda ====
set OPENDA_JRE=%OPENDA_BINDIR%..\jre
if exist "%OPENDA_JRE%\bin\java.exe" goto JAVA_OK

rem no openda jre is available, check if there is a default one
if "%JAVA_HOME%" == "" goto Error0
set OPENDA_JRE="%JAVA_HOME%"

:JAVA_OK
rem ==== check availability and arguments ===
if not exist %OPENDA_BINDIR%\openda_core.jar goto Error1
if not exist %OPENDA_BINDIR%\fews_openda.jar goto Error2

rem ==== run ===
set addJar=
for /r %OPENDA_BINDIR% %%G in (*.jar) do set addJar=!addJar!;"%%G"
"%OPENDA_JRE%\bin\java" -Xms128m -Xmx1024m -classpath %addJar% nl.deltares.openda.fews.OpenDaInFews %arg1% %arg2% %3 %4 %5 %6 %7
if errorlevel 1 goto Error4
endlocal
goto End

rem ==== show errors ===
:Error0
echo No JAVA runtime found - please check this
goto End

:Error1
echo The file %OPENDA_BINDIR%\openda_core.jar does not exist
goto End

:Error2
echo The file %OPENDA_BINDIR%\fews_openda.jar does not exist
goto End

:Error3
echo.
echo Usage:
echo.
echo OpenDA application run:  run_openda_in_fews -f ^<FEWS pi run file path relative to working dir^> -a ^<OpenDA application config file (.oda file) path relative to working dir^>
echo.
echo OpenDA application run with specific jre:  run_openda_in_fews -jre ^<path of java runtime environment (jre) folder^> -f ^<FEWS pi run file path relative to working dir^> -a ^<OpenDA application config file (.oda file) path relative to working dir^>
echo.
echo Single model run:  run_openda_in_fews -f ^<FEWS pi run file path relative to working dir^> -m ^<modelFactory or stochModelFactory full className^> ^<modelFactory or stochModelFactory config file path relative to pi run file dir^>
echo.
echo Single model run with specific jre:  run_openda_in_fews -jre ^<path of java runtime environment (jre) folder^> -f ^<FEWS pi run file path relative to working dir^> -m ^<modelFactory or stochModelFactory full className^> ^<modelFactory or stochModelFactory config file path relative to pi run file dir^>
echo.
echo.
echo Examples of usage: run_openda_in_fews -f run_info.xml -a enkf_run.oda
echo                    run_openda_in_fews -jre ..\..\jre -f run_info.xml -a enkf_run.oda
echo.
goto End

:Error4
echo Error running OpenDaInFews - please check the error messages
goto End

:Error5
echo.
echo Error: incorrect java runtime environment (jre) folder specified after option -jre
goto Error3

rem ==== done ===
:End
