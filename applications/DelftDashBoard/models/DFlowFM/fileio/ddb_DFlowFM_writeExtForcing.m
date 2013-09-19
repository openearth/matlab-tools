function ddb_DFlowFM_writeExtForcing(fname,boundaries)

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','* QUANTITY    : waterlevelbnd, velocitybnd, dischargebnd, tangentialvelocitybnd, normalvelocitybnd  filetype=9         method=2,3');
fprintf(fid,'%s\n','*             : salinitybnd                                                                         filetype=9         method=2,3');
fprintf(fid,'%s\n','*             : lowergatelevel, damlevel                                                            filetype=9         method=2,3');
fprintf(fid,'%s\n','*             : frictioncoefficient, horizontaleddyviscositycoefficient, advectiontype              filetype=4,10      method=4');
fprintf(fid,'%s\n','*             : initialwaterlevel, initialsalinity                                                  filetype=4,10      method=4');
fprintf(fid,'%s\n','*             : windx, windy, windxy, rain, atmosphericpressure                                     filetype=1,2,4,7,8 method=1,2,3');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* kx = Vectormax = Nr of variables specified on the same time/space frame. Eg. Wind magnitude,direction: kx = 2');
fprintf(fid,'%s\n','* FILETYPE=1  : uniform              kx = 1 value               1 dim array      uni');
fprintf(fid,'%s\n','* FILETYPE=2  : unimagdir            kx = 2 values              1 dim array,     uni mag/dir transf to u,v, in index 1,2');
fprintf(fid,'%s\n','* FILETYPE=3  : svwp                 kx = 3 fields  u,v,p       3 dim array      nointerpolation');
fprintf(fid,'%s\n','* FILETYPE=4  : arcinfo              kx = 1 field               2 dim array      bilin/direct');
fprintf(fid,'%s\n','* FILETYPE=5  : spiderweb            kx = 3 fields              3 dim array      bilin/spw');
fprintf(fid,'%s\n','* FILETYPE=6  : curvi                kx = ?                                      bilin/findnm');
fprintf(fid,'%s\n','* FILETYPE=7  : triangulation        kx = 1 field               1 dim array      triangulation');
fprintf(fid,'%s\n','* FILETYPE=8  : triangulation_magdir kx = 2 fields consisting of Filetype=2      triangulation in (wind) stations');
fprintf(fid,'%s\n','* FILETYPE=9  : poly_tim             kx = 1 field  consisting of Filetype=1      line interpolation in (boundary) stations');
fprintf(fid,'%s\n','* FILETYPE=10 : inside_polygon       kx = 1 field                                uniform value inside polygon for INITIAL fields');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* METHOD  =0  : provider just updates, another provider that pointers to this one does the actual interpolation');
fprintf(fid,'%s\n','*         =1  : intp space and time (getval) keep  2 meteofields in memory');
fprintf(fid,'%s\n','*         =2  : first intp space (update), next intp. time (getval) keep 2 flowfields in memory');
fprintf(fid,'%s\n','*         =3  : save weightfactors, intp space and time (getval),   keep 2 pointer- and weight sets in memory');
fprintf(fid,'%s\n','*         =4  : only spatial interpolation');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* OPERAND =+  : Add');
fprintf(fid,'%s\n','*         =O  : Override');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* VALUE   =   : Offset value for this provider');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* FACTOR  =   : Conversion factor for this provider');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','**************************************************************************************************************');
fprintf(fid,'%s\n','');

for ip=1:length(boundaries)
    fprintf(fid,'%s\n',['QUANTITY=' boundaries(ip).type]);
    fprintf(fid,'%s\n',['FILENAME=' boundaries(ip).filename]);
    fprintf(fid,'%s\n','FILETYPE=9');
    fprintf(fid,'%s\n','METHOD=2');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

fclose(fid);
