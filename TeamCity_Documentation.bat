echo off
rem Build script to test OpenEarthTools matlab scripts
rem with TeamCity Distributed Build Management and Continuous Integration Server
rem <http://www.jetbrains.com/teamcity/>

rem TO DO: put entire mapping command in environment variable %openearth_map%

rem Map drive with matlab
rem -----------------------------------
net use y: /delete
net use y: \\wlhost\library %openearth_password% /USER:%openearth_user% 

:oet_perform
rem Call matlab
rem http://www.mathworks.com/support/solutions/data/1-16B8X.html
rem -----------------------------------
rem Create a temp file
echo Matlab is running > matlabruns.busy
rem now run matlab
Y:\app\MATLAB2010a\bin\matlab.exe -nosplash -nodesktop -minimize -r "TeamCity_makedocumentation(%BUILD_VCS_NUMBER_svn__https___repos_deltares_nl_repos_OpenEarthTools_trunk_matlab%);" -logfile mlogfile.log -sd "%teamcity.build.workingDir%"

rem hold reporting until matlab status file has been deleted

:loopmatlabbusy
if exist teamcitymessage.matlab goto echo_teamcity_message
:continueloobmatlabbusy
If exist matlabruns.busy goto loopmatlabbusy

echo 'teamcity OK'

rem Remove drive with matlab
rem -----------------------------------
net use y: /delete
goto end

:echo_teamcity_message
type teamcitymessage.matlab
del teamcitymessage.matlab
goto continueloobmatlabbusy

:end