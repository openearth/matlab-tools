@ECHO OFF
ECHO Add taxon_animalia table to mep-duinen
ECHO .
ECHO Press any key to start...
pause > nul
SET PATH=C:\Program Files\PostgreSQL\9.3\bin\;%PATH%

ECHO ON
PSQL.exe -h localhost -U postgres -d mep-duinen -f domaintable_filled_animalia.sql
@ECHO OFF
ECHO Press any key to exit
pause > nul

