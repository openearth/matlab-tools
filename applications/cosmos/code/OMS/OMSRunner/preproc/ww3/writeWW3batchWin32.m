function writeWW3batchWin32(fname,names,datstr)

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','ww3_grid.exe');
fprintf(fid,'%s\n','ww3_prep.exe');
fprintf(fid,'%s\n','ww3_shel.exe');
for i=1:length(names)
    fprintf(fid,'%s\n',['copy ww3_outp_' names{i} '.inp ww3_outp.inp']);    
    fprintf(fid,'%s\n','ww3_outp.exe');
    fprintf(fid,'%s\n',['move ww3.' datstr '.spc ww3.' names{i} '.spc']);    
end
% fprintf(fid,'%s\n','gx_outf.exe');
fclose(fid);
