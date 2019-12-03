@ echo off
# This script removes work, output and *.pyc files 
# Use at own risk 

rmdir work /s /q
rmdir output /s /q
del *.pyc 
del simulate.log

:end
    rem To prevent the DOS box from disappearing immediately: remove the rem on the following line
rem pause
