function sfincs_write_binary_subgrid_tables_v7(subgrd,msk,nbin,subgridfile)

% Writes binary subgrid files for SFINCS
% nmax=size(msk,1);
% mmax=size(msk,2);

indices=find(msk>0);

fid=fopen(subgridfile,'w');

fwrite(fid,length(indices),'integer*4');
fwrite(fid,nbin,'integer*4');

% Volumes
val=subgrd.z_zmin(msk>0);
fwrite(fid,val,'real*4');
val=subgrd.z_zmax(msk>0);
fwrite(fid,val,'real*4');
volmax=squeeze(subgrd.z_volmax);
val=volmax(msk>0);
fwrite(fid,val,'real*4');
for ibin=1:nbin
%    v=squeeze(subgrd.z_vol(:,:,ibin));
    v=squeeze(subgrd.z_depth(:,:,ibin));
    val=v(msk>0);
    fwrite(fid,val,'real*4');
end

% U points
val=subgrd.u_zmin(msk>0);
fwrite(fid,val,'real*4');
val=subgrd.u_zmax(msk>0);
fwrite(fid,val,'real*4');
for ibin=1:nbin
    v=squeeze(subgrd.u_hrep(:,:,ibin));
    val=v(msk>0);
    fwrite(fid,val,'real*4');
end
% for ibin=1:nbin
% %    v=squeeze(subgrd.u_area(:,:,ibin));
%     v=squeeze(subgrd.u_hrep(:,:,ibin));
%     val=v(msk>0);
%     fwrite(fid,val,'real*4');
% end

% V points
val=subgrd.v_zmin(msk>0);
fwrite(fid,val,'real*4');
val=subgrd.v_zmax(msk>0);
fwrite(fid,val,'real*4');
for ibin=1:nbin
    v=squeeze(subgrd.v_hrep(:,:,ibin));
    val=v(msk>0);
    fwrite(fid,val,'real*4');
end
% for ibin=1:nbin
% %    v=squeeze(subgrd.v_area(:,:,ibin));
%     v=squeeze(subgrd.v_hrep(:,:,ibin));
%     val=v(msk>0);
%     fwrite(fid,val,'real*4');
% end

fclose(fid);
