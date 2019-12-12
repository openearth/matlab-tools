function subgrd=sfincs_read_binary_subgrid_tables(folder)

inpfile=[folder filesep 'sfincs.inp'];

inp=sfincs_read_input(inpfile);
nmax=inp.nmax;
mmax=inp.mmax;

% Read index file
fid=fopen([folder inp.indexfile],'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read subgrd file
fid=fopen([folder inp.sbgfile],'r');
np=fread(fid,1,'integer*4');
nbin=fread(fid,1,'integer*4');

v0=zeros(nmax,mmax);
v0(v0==0)=NaN;
v03=zeros(nmax,mmax);
v03(v03==0)=NaN;
subgrd.z_zmin=v0;
subgrd.z_zmax=v0;
subgrd.z_vol=v03;
subgrd.u_zmin=v0;
subgrd.u_zmax=v0;
subgrd.u_width=v03;
subgrd.u_area=v03;
subgrd.v_zmin=v0;
subgrd.v_zmax=v0;
subgrd.v_width=v03;
subgrd.v_area=v03;

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.z_zmin=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.z_zmax=v;
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.z_vol(:,:,ibin)=v;
end

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.u_zmin=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.u_zmax=v;
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.u_width(:,:,ibin)=v;
end
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.u_area(:,:,ibin)=v;
end

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.v_zmin=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.v_zmax=v;
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.v_width(:,:,ibin)=v;
end
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.v_area(:,:,ibin)=v;
end

fclose(fid);
