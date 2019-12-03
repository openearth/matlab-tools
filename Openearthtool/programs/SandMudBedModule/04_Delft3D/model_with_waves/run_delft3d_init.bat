@ echo off

echo     run_delft3d_init.bat called with runid %1

REM ============ remove output files
del /f runid                          > del.log 2>&1
del /f td-diag.%1                     > del.log 2>&1
del /f tri-diag.%1                    > del.log 2>&1
del /f swn-diag.%1                    > del.log 2>&1
del /f md-diag.%1                     > del.log 2>&1
del /f TMP_%1.*                       > del.log 2>&1
del /f *.msg                          > del.log 2>&1
del /f tri-prt.%1                     > del.log 2>&1
del /f trih-%1.*                      > del.log 2>&1
del /f trim-%1.*                      > del.log 2>&1
del /f trid-%1.*                      > del.log 2>&1
del /f fourier.%1                     > del.log 2>&1
del /f dio-*                          > del.log 2>&1
del /f dio.errors                     > del.log 2>&1
del /f gpp*                           > del.log 2>&1
del /f fort.*                         > del.log 2>&1
   rem Online with RTC:
del /f SignalToRtc*                   > del.log 2>&1
del /f RTC.Log                        > del.log 2>&1
del /f RTC.Dbg                        > del.log 2>&1
del /f TMP_Bar.bcb                    > del.log 2>&1
del /f TMP_SYNC.RUN                   > del.log 2>&1
del /f rtc_d3d.dat                    > del.log 2>&1
del /f DioDumpRTC.Txt                 > del.log 2>&1
del /f RTCPARAL.HIS                   > del.log 2>&1
del /f RTCPARAL.HIS_.stream           > del.log 2>&1
del /f RTCPARAL.HIS_RTCPARAL.HIS.data > del.log 2>&1
   rem Online with WAVE:
del /f FLOW2WAVE*                     > del.log 2>&1
del /f WAVE2FLOW*                     > del.log 2>&1
del /f swan.inp                       > del.log 2>&1
del /f BOTNOW                         > del.log 2>&1
del /f CURNOW                         > del.log 2>&1
del /f WNDNOW                         > del.log 2>&1
del /f TMP_grid2swan*                 > del.log 2>&1
del /f PRINT                          > del.log 2>&1
del /f %1.prt                         > del.log 2>&1
del /f INPUT                          > del.log 2>&1
del /f *.swn                          > del.log 2>&1
del /f norm_end                       > del.log 2>&1
del /f zzxxqq                         > del.log 2>&1
del /f HISWAOUT                       > del.log 2>&1
del /f SWANOUT                        > del.log 2>&1
del /f swaninit                       > del.log 2>&1
del /f Errfile                        > del.log 2>&1
del /f *.erf                          > del.log 2>&1
del /f wavm-%1.*                      > del.log 2>&1
del /f CompositionRun.log             > del.log 2>&1
REM ============ optional:
REM del /f com-%1.*           > del.log 2>&1

del /f del.log

echo     . . . Delft3D-FLOW_init finished
rem pause
