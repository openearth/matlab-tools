clear

%% INPUT

fpath_nc1='d:\temporal\221111_feyenoord\06_simulations\02_runs\r000\rmm_vzm_v1p1_mod_mod_net.nc';
fpath_nc2='d:\temporal\221111_feyenoord\06_simulations\02_runs\r000\grd_04_net.nc';
fpath_bl='d:\temporal\221111_feyenoord\06_simulations\02_runs\r000\bl.xyz';

%%

nci=ncinfo(fpath_nc2);
xn1=ncread(fpath_nc1,'mesh2d_node_x');
yn1=ncread(fpath_nc1,'mesh2d_node_y');
zn1=ncread(fpath_nc1,'mesh2d_node_z');

% xn2=ncread(fpath_nc2,'mesh2d_node_x');
% yn2=ncread(fpath_nc2,'mesh2d_node_y');
xn2=ncread(fpath_nc2,'NetNode_x');
yn2=ncread(fpath_nc2,'NetNode_y');
zn2=ncread(fpath_nc2,'NetNode_z');

F=scatteredInterpolant(xn1,yn1,zn1,'linear');
zn2int=F(xn2,yn2);
zn2int(isnan(zn2int))=-999;


%%
fpath_nc2int=strrep(fpath_nc2,'.nc','_int.nc');
copyfile_check(fpath_nc2,fpath_nc2int);
ncwrite_class(fpath_nc2int,'NetNode_z',zn2,zn2int)

mw=[xn2,yn2,zn2int];
write_2DMatrix(fpath_bl,mw,'check_existing',0);

%%
figure
hold on
% scatter(xn1,yn1,10,zn1,'filled')
% scatter(xn2,yn2,10,'xr')
scatter(xn2,yn2,10,zn2int,'filled')
colorbar
axis equal

%%
% figure
% hold on
% scatter(xn1,yn1,10,zn1,'filled')
% scatter(xn1,yn1,10,'xr')
% colorbar
% axis equal