if not exist unstruc.ini copy d:\unstruc\unstruc.ini .
if not exist isocolour.hls copy d:\unstruc\isocolour.hls .
if not exist interact.ini  copy d:\unstruc\interact.ini .
SET OMP_NUM_THREADS=3
"d:\unstruc\unstruc.exe" %1
