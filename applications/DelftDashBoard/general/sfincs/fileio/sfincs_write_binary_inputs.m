function sfincs_write_binary_inputs(z,msk,indexfile,bindepfile,binmskfile)

% Writes binary input files for SFINCS
    
% Index file
indices=find(msk>0);
mskv=msk(msk>0);
fid=fopen(indexfile,'w');
fwrite(fid,length(indices),'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

% Depth file
zv=z(msk>0);
% zv=max(zv,-5);
fid=fopen(bindepfile,'w');
fwrite(fid,zv,'real*4');
fclose(fid);

% Mask file
fid=fopen(binmskfile,'w');
fwrite(fid,mskv,'integer*1');
fclose(fid);
