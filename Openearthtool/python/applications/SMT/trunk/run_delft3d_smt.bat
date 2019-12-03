@ echo off
    rem
    rem This script is an example for running Delft3D-FLOW 6.00 (Windows)
    rem Adapt and use it for your own purpose
    rem
    rem adri.mourits@deltares.nl
    rem 30 oct 2013
    rem 
  
    rem
    rem Set the config file here
    rem 
set argfile=config_d_hydro.xml
set ARCH=win32
set D3D_HOME=%~dp0..\..\executables\6.01.04.3058
rem set exedir=%D3D_HOME%\%ARCH%\flow2d3d\bin

    rem
    rem No adaptions needed below
    rem

    rem Set some (environment) parameters
rem set PATH=%exedir%;%PATH%

    rem Run

python.exe runsim.py > simulate.log 

:end
    rem To prevent the DOS box from disappearing immediately: remove the rem on the following line
rem pause
