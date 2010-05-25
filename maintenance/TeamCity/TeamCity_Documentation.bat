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

set tempfile = temp_file_containing_linecount.TXT
tasklist /fi "imagename eq MATLAB.exe" /nh 2> null | find /C "MATLAB.exe" > tempfile  
FOR /f "tokens=* delims=" %%c IN (tempfile ) DO (
if not %%c == 0 goto loopmatlabbusy
)
del tempfile

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