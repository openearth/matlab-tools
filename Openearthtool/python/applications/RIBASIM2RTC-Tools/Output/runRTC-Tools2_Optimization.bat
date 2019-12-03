cd src
call c:\Software\RTC-Tools2.4\venvRTC-Tools\Scripts\activate.bat
python .\RIBASIM.py > ..\RIBASIM.txt 2>&1
cd ..
exit /b