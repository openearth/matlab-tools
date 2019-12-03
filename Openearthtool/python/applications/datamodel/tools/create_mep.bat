@ECHO OFF
ECHO Creates mep-duinen database.
ECHO Run from postgres bin folder or add postgres bin folder to path.
ECHO .
SET PATH=C:\Program Files\PostgreSQL\9.3\bin\;%PATH%
ECHO Press any key to start...
pause > null

ECHO ON
CreateDB.exe -h localhost -U postgres --encoding=UTF8 mep-duinen
@ECHO OFF
ECHO Press any key to add extensions...
pause > null

ECHO ON
PSQL.exe -h localhost -U postgres -d mep-duinen -c "CREATE EXTENSION postgis"
PSQL.exe -h localhost -U postgres -d mep-duinen -c "CREATE EXTENSION postgis_topology"
@ECHO OFF
ECHO Press any key to create tables...
pause > null

ECHO ON
PSQL.exe -h localhost -U postgres -d mep-duinen -f public_domaintables_filled.sql
@ECHO OFF
ECHO Press any key to create schema
pause > null

ECHO ON
PSQL.exe -h localhost -U postgres -d mep-duinen -f observation_schema_duinen.sql
@ECHO OFF
ECHO Press any key to finish...
pause > null
