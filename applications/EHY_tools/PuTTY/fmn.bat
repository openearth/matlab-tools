if not exist unstruc.ini   copy n:\Deltabox\Bulletin\groenenb\PuTTY\fm\unstruc.ini .
if not exist isocolour.hls copy n:\Deltabox\Bulletin\groenenb\PuTTY\fm\isocolour.hls .
if not exist interact.ini  copy n:\Deltabox\Bulletin\groenenb\PuTTY\fm\interact.ini .
SET OMP_NUM_THREADS=3
REM "d:\programFiles\dflowfm\dflowfm-x64-1.1.209.49712\dflowfm.exe" %1
"d:\programFiles\dflowfm\dflowfm-x64-1.1.209.49712\dflowfm.exe" %1 %2 %3 %4
