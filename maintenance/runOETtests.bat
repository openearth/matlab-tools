@echo off
rem Build script to test OpenEarthTools matlab scripts
rem with TeamCity Distributed Build Management and Continuous Integration Server
rem <http://www.jetbrains.com/teamcity/>

rem TO DO: put entire mapping command in environment variable %openearth_map%

rem Settings
rem -----------------------------------
set     matlab_path=
set openearth_mpath=D:\checkouts\OpenEarthTools\matlab\

rem Map drive with matlab
rem -----------------------------------
if exist %openearth_password% goto oet_map
goto oet_perform
:oet_map
net use y: /delete
net use y: \\wlhost\library %openearth_password% /USER:%openearth_user% 

rem Call matlab
rem http://www.mathworks.com/support/solutions/data/1-16B8X.html
rem -----------------------------------
:oet_perform
matlab -nosplash -nodesktop -minimize -r "run('oetsettings');surf(peaks);print('tst.png','-dpng');exit;" -logfile mlogfile
echo 'teamcity OK'

rem Remove drive with matlab
rem -----------------------------------
if exist %openearth_password% goto oet_unmap
goto end
:oet_unmap
net use y: /delete
:end