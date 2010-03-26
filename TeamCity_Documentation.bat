echo off
rem Build script to test OpenEarthTools matlab scripts
rem with TeamCity Distributed Build Management and Continuous Integration Server
rem <http://www.jetbrains.com/teamcity/>

rem TO DO: put entire mapping command in environment variable %openearth_map%

rem Map drive with matlab
rem -----------------------------------
if exist %openearth_password% goto oet_map
goto oet_perform
:oet_map
net use y: /delete
net use y: \\wlhost\library %openearth_password% /USER:%openearth_user% 

:oet_perform
rem Call matlab
rem http://www.mathworks.com/support/solutions/data/1-16B8X.html
rem -----------------------------------
rem Create a temp file
echo Matlab is running > matlabruns.busy
rem now run matlab
rem TODO: create and copy documentation (zip as artifact as well)
rem matlab -nosplash -nodesktop -minimize -r "run('oetsettings');teamcityrunoettests;delete('matlabruns.busy');exit;" -logfile mlogfile.log
rem hold reporting until matlab status file has been deleted

:loopmatlabbusy
if exist teamcitymessage.matlab goto echo_teamcity_message
:continueloobmatlabbusy
If exist matlabruns.busy goto loopmatlabbusy

echo 'teamcity OK'

rem Remove drive with matlab
rem -----------------------------------
if exist %openearth_password% goto oet_unmap
:oet_unmap
net use y: /delete
goto end

:echo_teamcity_message
type teamcitymessage.matlab
del teamcitymessage.matlab
goto continueloobmatlabbusy

:end