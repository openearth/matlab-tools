@echo off
echo This compiles the run_osm2dh to a standalone executable
echo Please make sure that pyinstaller is installed (pip install pyinstaller)
echo Compiling........
pyinstaller.exe --additional-hooks-dir hooks --onefile run_osm2dh.py
rd /s /q build
move dist\run_osm2dh.exe dist\osm2dh.exe
echo Done!
