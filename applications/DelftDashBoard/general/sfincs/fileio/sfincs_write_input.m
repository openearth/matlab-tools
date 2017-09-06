function sfincs_write_input(fname,inp)

keywords=fieldnames(inp);

fid=fopen(fname,'wt');

for ii=1:length(keywords)
    keyw=keywords{ii};
    val=inp.(keyw);
    if ~isempty(val)
        str1=[keyw repmat(' ',[1 15-length(keyw)]) '= '];
        if ischar(val)
            str2=deblank2(val);
        else
            str2=num2str(val);
        end
        fprintf(fid,'%s\n',[str1 str2]);
    end
end
fclose(fid);

% mmax            = 880
% nmax            = 1286
% dx              = 10.0
% dy              = 10.0
% x0              = 894657.550682
% y0              = 841633.481739
% rotation        = 180.0
% simtime         = 1800.0
% dtout           = 20.0
% alpha           = 0.75
% vmax            = 999.0
% manning         = 0.04
% zsini           = 0.0
% qinf            = 0.0
% inputformat     = bin
% outputformat    = bin
% depfile         = bindep.dat
% mskfile         = binmsk.dat
% indexfile       = indices.dat
% bndfile         = level1_0001.bnd
% bctfile         = level1_0001.bct
% hsfile          = level1_0001.bhs
% zsfile          = zs.dat
% hmaxfile        = hmax.dat
% hmaxgeofile     = hmaxgeo.dat


% fid=fopen(fname,'wt');
% fprintf(fid,'%i\n',inp.mmax);
% fprintf(fid,'%i\n',inp.nmax);
% fprintf(fid,'%f\n',inp.dx);
% fprintf(fid,'%f\n',inp.dy);
% fprintf(fid,'%f\n',inp.x0);
% fprintf(fid,'%f\n',inp.y0);
% fprintf(fid,'%f\n',inp.rundur);
% fprintf(fid,'%f\n',inp.dtout);
% fprintf(fid,'%f\n',inp.alfa);
% fprintf(fid,'%f\n',inp.vmax);
% fprintf(fid,'%f\n',inp.manning);
% fprintf(fid,'%s\n',inp.depfile);
% fprintf(fid,'%s\n',inp.mskfile);
% fprintf(fid,'%s\n',inp.bndfile);
% fprintf(fid,'%s\n',inp.bctfile);
% fprintf(fid,'%s\n',inp.hsfile);
% fprintf(fid,'%s\n',inp.srcfile);
% fprintf(fid,'%s\n',inp.disfile);
% fprintf(fid,'%f\n',inp.zini);
% fprintf(fid,'%f\n',inp.qinf);
% fprintf(fid,'%s\n',inp.hmaxfile);
% fprintf(fid,'%s\n',inp.zsfile);
% fprintf(fid,'%s\n',inp.indexfile);
% fprintf(fid,'%s\n',inp.bindepfile);
% fprintf(fid,'%s\n',inp.binmskfile);
% fprintf(fid,'%s\n',inp.bingeomskfile);
% fprintf(fid,'%s\n',inp.inputtype);
% fprintf(fid,'%s\n',inp.outputtype);
% fclose(fid);
