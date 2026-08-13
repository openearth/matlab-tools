rem 
rem This batch file is a wrapper for the MATLAB function NC_info.m
rem It takes a NetCDF file as input and generates an output text file with information about the NetCDF file.
rem Usage: nc_info.bat <path_to_netcdf_file>
rem If no path is provided, it will prompt the user to enter one.
rem The output file will be named <input_file_name>_info.txt and will be created in the same directory as the input file.
rem Example: nc_info.bat C:\data\example.nc
rem 
rem In TotalCommander:
rem Start -> Change Start Menu -> Add Item 
rem Command:  C:\path\to\nc_info.bat
rem Parameters: %P%N
rem Start path: C:\path\to\

@echo off
setlocal

set "NC_FILE=%~1"
if "%NC_FILE%"=="" set /p "NC_FILE=Path to NetCDF file: "
if "%NC_FILE%"=="" (
    echo No file specified.
    exit /b 1
)
if not exist "%NC_FILE%" (
    echo File not found: %NC_FILE%
    exit /b 1
)

for %%F in ("%NC_FILE%") do set "OUT_FILE=%%~dpnF_info.txt"

matlab -batch "NC_info('%NC_FILE%','OutputFormat','table','outfile','%OUT_FILE%')"
set "RC=%ERRORLEVEL%"

echo Output written to: %OUT_FILE%

if not "%~1"=="" goto :end
pause

:end
exit /b %RC%
