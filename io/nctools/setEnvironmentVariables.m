%SETENVIRONMENTVARIABLES .
%
%See also:

% @echo off
% REM ==========================================================================
% REM This script is normally invoked from FWTools\setfw.bat
% 
% REM The FWTOOLS_OVERRIDE environment variable allows you to set a the 
% REM install directory in your environment, instead of having to edit 
% REM setfw.bat.  This is especially useful if you frequently upgrade to new 
% REM versions, and don't want to have to edit the file every time. 
% 
% IF exist "%FWTOOLS_OVERRIDE%\setfw.bat" SET FWTOOLS_DIR=%FWTOOLS_OVERRIDE%
% 
% IF exist "%FWTOOLS_DIR%\setfw.bat" goto skip_err
% 
% echo FWTOOLS_DIR not set properly in setfw.bat, please fix and rerun.
% goto ALL_DONE

FWTOOLS_DIR = 'C:\Program Files\FWTools2.2.6';
setenv('PATH'            , [getenv('PATH')            ,';', FWTOOLS_DIR, '\bin'])
setenv('PATH'            , [getenv('PATH')            ,';', FWTOOLS_DIR, '\python'])
setenv('PYTHONPATH'      , [getenv('PYTHONPATH')      ,';', FWTOOLS_DIR, '\pymod'])
setenv('PROJ_LIB'        , [getenv('PROJ_LIB')        ,';', FWTOOLS_DIR, '\proj_lib'])
setenv('GEOTIFF_CSV'     , [getenv('GEOTIFF_CSV')     ,';', FWTOOLS_DIR, '\data'])
setenv('GDAL_DATA'       , [getenv('GDAL_DATA')       ,';', FWTOOLS_DIR, '\data'])
setenv('GDAL_DRIVER_PATH', [getenv('GDAL_DRIVER_PATH'),';', FWTOOLS_DIR, '\gdal_plugins'])


system(['gdalinfo KB120_2120_20060213.asc']);
system(['gdal_merge -o merged.tiff KB120_2120_20060213.asc KB121_2120_20060213.asc']);

% system(['gdalwarp -s_srs EPGS:28992 -t_srs EPSG:4326 mergedgeo.tiff']);
% system(['gdal_translate -of NETCDF mergedgeo.tiff mergedgeo.nc']);

% PATH=%FWTOOLS_DIR%\bin;%FWTOOLS_DIR%\python;%PATH%
% set PYTHONPATH=%FWTOOLS_DIR%\pymod
% set PROJ_LIB=%FWTOOLS_DIR%\proj_lib
% set GEOTIFF_CSV=%FWTOOLS_DIR%\data
% set GDAL_DATA=%FWTOOLS_DIR%\data
% set GDAL_DRIVER_PATH=%FWTOOLS_DIR%\gdal_plugins
% REM set CPL_DEBUG=ON
% 
% :ALL_DONE
