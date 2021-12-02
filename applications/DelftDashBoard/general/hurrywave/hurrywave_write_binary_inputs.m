function hurrywave_write_binary_inputs(z0,msk,indexfile,bindepfile,binmskfile)

% Writes binary input files for SFINCS





iincl=0;  % include only msk=1 and msk=2
iincl=-1; % include all points


msk_dummy=zeros(size(msk,1)+2, size(msk,2)+2);
msk_dummy(2:end-1,2:end-1)=msk;
msk=msk_dummy;


% figure(123)
% %scatter(x,y,10,msk);colorbar;axis equal;
% pcolor(msk);shading flat;colorbar;axis equal;

msk22=zeros(size(msk,1)+2, size(msk,2)+2);
% Now for HurryWave, set all msk=0 points that do not have a msk=1 neighbor to -1
msk22(2:end-1,2:end-1)=msk;
% figure(124)
% %scatter(x,y,10,msk);colorbar;axis equal;
% pcolor(msk22);shading flat;colorbar;axis equal;


nbl=msk22(2:end-1,1:end-2);
nbr=msk22(2:end-1,3:end);
nbb=msk22(1:end-2,2:end-1);
nbt=msk22(3:end,2:end-1);
nbs=msk+nbl+nbr+nbb+nbt;
msk(nbs==0)=-1;

% figure(1234)
% pcolor(msk);shading flat;colorbar;




% Index file
indices=find(msk>iincl);

mskv=msk(msk>iincl);

fid=fopen(indexfile,'w');
fwrite(fid,length(indices),'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

z=zeros(size(z0,1)+2, size(z0,2)+2)-999.0;
z(2:end-1,2:end-1)=z0;
if ~isempty(bindepfile)
    % Depth file
    zv=z(msk>iincl);
    % zv=max(zv,-5);
    fid=fopen(bindepfile,'w');
    fwrite(fid,zv,'real*4');
    fclose(fid);
end

% Mask file
fid=fopen(binmskfile,'w');
fwrite(fid,mskv,'integer*1');
fclose(fid);
