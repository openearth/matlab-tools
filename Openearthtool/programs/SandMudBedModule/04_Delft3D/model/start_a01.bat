@ echo off


set runid=a01
set argfile=config.ini
set logfile=simulate_a01.log
set version=Release
rem set version=Debug

echo ============ set srcdir
set srcdir=..\executables

rem ###################################################################

echo ============ set exedir
set exedir=%srcdir%\w32\flow\bin
echo =================================================================== 
echo === runid  = %runid%
echo === exedir = %exedir%
echo ===================================================================

rem pause

echo ============ remove output files
call run_delft3d_init.bat %runid%

echo ============ put arguments in file
echo [FileInformation]  >%argfile%
echo    FileCreatedBy    = batch file  >>%argfile%
echo    FileCreationDate = %date% %time% >>%argfile%
echo    FileVersion      = 00.01  >>%argfile%
echo [Component] >>%argfile%
echo    Name    = flow2d3d >>%argfile%
echo    MdfFile = %runid% >>%argfile%

set D3D_HOME=C:\
set PATH=%exedir%;%PATH%

echo === start deltares_hydro.exe ===
%exedir%\deltares_hydro.exe %argfile% 
rem > %logfile%

pause