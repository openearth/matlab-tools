@echo off
REM Batch file to copy data from import backup to import using mask
REM
SET LOGFILE=ftp_wgetfiles.log

@echo off



echo "Starting ftp_wgetfiles.bat"  > %LOGFILE%
echo "This batch requires a working version of wget.exe"  >> %LOGFILE%



IF %1nul == nul GOTO usage

SET IMPORTDIR=%1
SET T0=%2

echo "destination folder    [%1]"  >> %LOGFILE%
echo "T0                    [%2]"  >> %LOGFILE%

taskkill /F /IM python.exe
python.exe Ftp_GSMAP.py %IMPORTDIR% %T0% >> %LOGFILE%

GOTO end
:usage
echo "python.exe Ftp_GSMAP.py %IMPORTDIR% %T0%" >> %LOGFILE%
:end


