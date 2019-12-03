@ECHO OFF
ECHO Extract WATCH Rainfall data from the nested archive set that you receive when requesting data
ECHO[
ECHO Press any key to start or Ctrl-Break to abort...
pause
ECHO[
ECHO Extracting decennia 1950's-2000's
ECHO[
del /Q Rainf_WFD_GPCC\*.*
"C:\Program Files (x86)\7-Zip\7z.exe" e -oRainf_WFD_GPCC Rainf_WFD_GPCC.tar
cd Rainf_WFD_GPCC
ECHO[
ECHO Extracting all years
ECHO[
"C:\Program Files (x86)\7-Zip\7z.exe" e -o. Rainf_WFD_GPCC_1950s.tar
"C:\Program Files (x86)\7-Zip\7z.exe" e -o. Rainf_WFD_GPCC_1960s.tar
"C:\Program Files (x86)\7-Zip\7z.exe" e -o. Rainf_WFD_GPCC_1970s.tar
"C:\Program Files (x86)\7-Zip\7z.exe" e -o. Rainf_WFD_GPCC_1980s.tar
"C:\Program Files (x86)\7-Zip\7z.exe" e -o. Rainf_WFD_GPCC_1990s.tar
"C:\Program Files (x86)\7-Zip\7z.exe" e -o. Rainf_WFD_GPCC_2000s.tar
ECHO Extracting all months
ECHO[
for %%a in (Rainf_WFD_GPCC_????.tar) do "C:\Program Files (x86)\7-Zip\7z.exe" e -o. %%a
del *.tar
ECHO Extracting all months
ECHO[
for %%a in (*.gz) do "C:\Program Files (x86)\7-Zip\7z.exe" e -o. %%a
del *.gz
pause
