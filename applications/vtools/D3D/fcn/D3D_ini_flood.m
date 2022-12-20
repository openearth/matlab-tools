
fpath_grd='d:\temporal\221111_feyenoord\06_simulations\02_runs\r000\grd_04_int_net.nc';
fpath_wl='d:\temporal\221111_feyenoord\06_simulations\02_runs\r000\etaw.xyz';

xyz_ini=[96e3,435e3,1.0];

fpath_map=strrep(fpath_grd,'.nc','_map.nc');
D3D_grd2map(fpath_grd,'fpath_map',fpath_map);
nci=ncinfo(fpath_map);
fn=ncread(fpath_map,'mesh2d_face_nodes');
ef=ncread(fpath_map,'mesh2d_edge_faces');
fx=ncread(fpath_map,'mesh2d_face_x');
fy=ncread(fpath_map,'mesh2d_face_y');
bl=ncread(fpath_map,'mesh2d_flowelem_bl');

nf=size(fn,2); %number of faces

% % gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','Z','mesh2d_edge_faces'});

%% search initial face

hy=hypot(fx-xyz_ini(1),fy-xyz_ini(2));
[~,f0]=min(hy);

%%

wl=xyz_ini(3);

fs=f0;
do_search=1;
bol_flood=false(nf,1);
bol_flood(f0)=true;
bol_anl=false(nf,1);
bol_check=bol_flood & ~bol_anl;
while any(bol_check)
    idx_check=find(bol_flood & ~bol_anl);
    nfs=numel(idx_check);
    for kfs=1:nfs
        fsloc=idx_check(kfs);
        [~,idx_e]=find(ef==fsloc); %edges connected to the face we are currently checking
        idx_f=unique(ef(:,idx_e)); %faces connected to the face we are currently checking (including itself)
        idx_f(idx_f==fsloc)=[]; %remove itself
        idx_f(idx_f==0)=[]; %remove 0
        bol_get=wl-bl(idx_f)>0;
        bol_get=bol_get & bl(idx_f)~=-5; %-5 is used to filled empty values
        bol_flood(idx_f)=bol_get;
        bol_anl(fsloc)=true;
    end
    bol_check=bol_flood & ~bol_anl;
end

%%
wlz=-999.*ones(nf,1);
wlz(bol_flood)=wl;
% mw=[fx,fy,wlz];
mw=[fx(bol_flood),fy(bol_flood),wl.*ones(sum(bol_flood),1)];
write_2DMatrix(fpath_wl,mw,'check_existing',0);

%% plot

figure
hold on
% scatter(fx,fy,10,bl,'filled')
% scatter(fx,fy,10,bol_flood,'filled')
scatter(fx,fy,10,wl>bl,'filled')
scatter(fx(bol_flood),fy(bol_flood),10,'xr')
% scatter(fx(f0),fy(f0),20,'xr')
colorbar
% clim([-15,4])
axis equal

