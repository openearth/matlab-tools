function sfincs_write_binary_subgrid_tables_netcdf(subgrd,msk,nbin,subgridfile,uopt)
% Writes binary subgrid files for SFINCS

nbin=nbin+1;

iincl=0;  % include only msk=1 and msk=2
indices=find(msk>iincl);
np=length(indices);

nmax=size(msk,1);
mmax=size(msk,2);

z_depth=zeros(nmax,mmax,nbin);
z_depth(:,:,1)=subgrd.z_zmin;
z_depth(:,:,2:end)=subgrd.z_depth;

% Count UV points
ipuv=0;
for m=1:mmax
    for n=1:nmax
        if msk(n,m)>0
            if m<mmax
                if msk(n,m+1)>0
                    ipuv=ipuv+1;
                end
            end
            if n<nmax
                if msk(n+1,m)>0
                    ipuv=ipuv+1;
                end
            end
        end
    end
end

npuv=ipuv;

delete(subgridfile);

nccreate(subgridfile,'z_zmin','Dimensions',{'np',np},'Datatype','single');
nccreate(subgridfile,'z_zmax','Dimensions',{'np',np},'Datatype','single');
nccreate(subgridfile,'z_volmax','Dimensions',{'np',np},'Datatype','single');
nccreate(subgridfile,'z_level','Dimensions',{'bins',nbin,'np',np},'Datatype','single');

nccreate(subgridfile,'uv_zmin',  'Dimensions',{'npuv',npuv},            'Datatype','single');
nccreate(subgridfile,'uv_zmax',  'Dimensions',{'npuv',npuv},            'Datatype','single');
nccreate(subgridfile,'uv_fnfit', 'Dimensions',{'npuv',npuv},            'Datatype','single');
nccreate(subgridfile,'uv_navg_w','Dimensions',{'npuv',npuv},            'Datatype','single');
nccreate(subgridfile,'uv_havg',  'Dimensions',{'bins',nbin,'npuv',npuv},'Datatype','single');
nccreate(subgridfile,'uv_nrep',  'Dimensions',{'bins',nbin,'npuv',npuv},'Datatype','single');
nccreate(subgridfile,'uv_pwet',  'Dimensions',{'bins',nbin,'npuv',npuv},'Datatype','single');

% Volumes
val=subgrd.z_zmin(msk>iincl);
ncwrite(subgridfile,'z_zmin',val);

val=subgrd.z_zmax(msk>iincl);
ncwrite(subgridfile,'z_zmax',val);

volmax=squeeze(subgrd.z_volmax);
val=volmax(msk>iincl);
ncwrite(subgridfile,'z_volmax',val);

val=zeros(nbin,np);
for ibin=1:nbin
    v=squeeze(z_depth(:,:,ibin));
    v=v(indices);
    val(ibin,:)=v;
end
ncwrite(subgridfile,'z_level',val);

% UV points

uv_zmin=zeros(1,npuv);
uv_zmax=uv_zmin;
uv_navg_w=uv_zmin;
uv_fnfit=uv_zmin;
uv_havg=zeros(nbin,npuv);
uv_nrep=uv_havg;
uv_pwet=uv_havg;

ipuv=0;
for m=1:mmax
    for n=1:nmax
        if msk(n,m)>0
            if m<mmax
                if msk(n,m+1)>0
                    ipuv=ipuv+1;
                    uv_zmin(ipuv)=subgrd.u_zmin(n,m);
                    uv_zmax(ipuv)=subgrd.u_zmax(n,m);
                    uv_fnfit(ipuv)=subgrd.u_fnfit(n,m);
                    uv_navg_w(ipuv)=subgrd.u_navg_w(n,m);
                    uv_havg(:,ipuv)=squeeze(subgrd.u_hrep(n,m,:))';
                    uv_nrep(:,ipuv)=squeeze(subgrd.u_navg(n,m,:))';
                    uv_pwet(:,ipuv)=squeeze(subgrd.u_pwet(n,m,:))';
                end
            end
            if n<nmax
                if msk(n+1,m)>0
                    ipuv=ipuv+1;
                    uv_zmin(ipuv)=subgrd.v_zmin(n,m);
                    uv_zmax(ipuv)=subgrd.v_zmax(n,m);
                    uv_fnfit(ipuv)=subgrd.v_fnfit(n,m);
                    uv_navg_w(ipuv)=subgrd.v_navg_w(n,m);
                    uv_havg(:,ipuv)=squeeze(subgrd.v_hrep(n,m,:))';
                    uv_nrep(:,ipuv)=squeeze(subgrd.v_navg(n,m,:))';
                    uv_pwet(:,ipuv)=squeeze(subgrd.v_pwet(n,m,:))';
                end
            end
        end
    end
end

ncwrite(subgridfile,'uv_zmin',uv_zmin);
ncwrite(subgridfile,'uv_zmax',uv_zmax);
ncwrite(subgridfile,'uv_navg_w',uv_navg_w);
ncwrite(subgridfile,'uv_fnfit',uv_fnfit);
ncwrite(subgridfile,'uv_havg',uv_havg);
ncwrite(subgridfile,'uv_nrep',uv_nrep);
ncwrite(subgridfile,'uv_pwet',uv_pwet);

