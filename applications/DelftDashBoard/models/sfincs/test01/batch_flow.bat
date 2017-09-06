@ echo off
set argfile=config_d_hydro.xml
set flowexedir="d:\checkouts\opendelft3d_002\bin\win32\flow2d3d\bin\"
set PATH=%flowexedir%;%waveexedir%;%PATH%
%flowexedir%\d_hydro.exe %argfile%
