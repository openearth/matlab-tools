echo off
rem Build script to test OpenEarthTools matlab scripts
rem with TeamCity Distributed Build Management and Continuous Integration Server
rem <http://www.jetbrains.com/teamcity/>

rem Start matlab
rem -----------------------------------

%map_matlab%

%matlab_path%matlab.exe -nosplash -nodesktop -minimize -r "%matlab_command%" -logfile mlogfile.log -sd "%teamcity.build.workingDir%"

:loopmatlabbusy

if exist teamcitymessage.matlab goto echo_teamcity_message

rem check whether matlab.exe is still running
tasklist /FI "IMAGENAME eq MATLAB.exe" 2>NUL | find /I /N "MATLAB.exe">NUL
if "%ERRORLEVEL%"=="0" goto loopmatlabbusy

echo 'teamcity OK'

%umap_matlab%

goto end

:echo_teamcity_message
type teamcitymessage.matlab
del teamcitymessage.matlab
goto loopmatlabbusy

:end