echo off
rem Build script to test OpenEarthTools matlab scripts
rem with TeamCity Distributed Build Management and Continuous Integration Server
rem <http://www.jetbrains.com/teamcity/>

rem Map drive with matlab
rem -----------------------------------
net use y: /delete
net use y: \\wlhost\library %openearth_password% /USER:%openearth_user% 
rem net use y: \\wlhost\library 

rem Call matlab
rem http://www.mathworks.com/support/solutions/data/1-16B8X.html
rem -----------------------------------

Y:\app\MATLAB2010a\bin\matlab.exe -nosplash -nodesktop -minimize -r "TeamCity_makedocumentation(%BUILD_VCS_NUMBER%);" -logfile mlogfile.log -sd "%teamcity.build.workingDir%"

:loopmatlabbusy

if exist teamcitymessage.matlab goto echo_teamcity_message

rem check whether matlab.exe is still running
tasklist /FI "IMAGENAME eq MATLAB.exe" 2>NUL | find /I /N "MATLAB.exe">NUL
if "%ERRORLEVEL%"=="0" goto loopmatlabbusy

echo 'teamcity OK'

rem Remove drive with matlab
rem -----------------------------------
net use y: /delete

goto end

:echo_teamcity_message
type teamcitymessage.matlab
del teamcitymessage.matlab
goto loopmatlabbusy

:end