set CURDIR=%CD%

set GODIR=%CURDIR:~2%
set GODIR=%GODIR:\=/%
set GODIR=/p%GODIR%

set DRIVE=%CURDIR:~0,1%

set SCRIPTDIR=%~dp0%
set OUTPUTFILE="n:\My Documents\unix-h6\run_ext.sh"

ECHO . .bash_profile  > %OUTPUTFILE%
ECHO cd "%GODIR%"    >> %OUTPUTFILE%
ECHO clear           >> %OUTPUTFILE%
ECHO . /etc/bashrc   >> %OUTPUTFILE%
ECHO /bin/bash       >> %OUTPUTFILE%



start "" "C:\Program Files (x86)\Putty\putty.exe" -ssh USERNAME@h6.directory.intra -pw PASSWORD  -m %OUTPUTFILE% -t

