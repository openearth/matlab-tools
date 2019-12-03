@ echo off
    rem
    rem This script is an example for running Delft3D-FLOW
    rem Adapt and use it for your own purpose
    rem
    rem adri.mourits@deltares.nl
    rem 01 Mar 2011
    rem 
    rem
    rem This script starts a single-domain Delft3D-FLOW computation online with Delft3D-WAVE on Windows
    rem


    rem
    rem Set the config file and mdw file
    rem
set runid=a01
set argfile=config.ini
set logfile=simulate_a01.log
set version=Release
set mdwfile=a01.mdw




    rem
    rem Set the directory containing delftflow.exe
    rem
set srcdir=..\executables
set exedir=%srcdir%\w32\flow\bin
set libdir=%srcdir%\w32\lib
set wavedir=%srcdir%\w32\wave\bin
set swandir=%wavedir%
set swanbatdir=%libdir%

    rem
    rem No adaptions needed below
    rem

    rem Set some (environment) parameters
    rem Only needed for the debug version:
    rem set inteldir=c:\Program Files\Intel\Compiler\11.0\072\fortran\lib\ia32
set PATH=%swanbatdir%;%exedir%;%swandir%;%inteldir%;%PATH%


    rem Run
start %exedir%\deltares_hydro.exe %argfile%

%wavedir%\wave.exe %mdwfile% 1

    rem To prevent the DOS box from disappearing immediately: remove the rem on the following line
pause
