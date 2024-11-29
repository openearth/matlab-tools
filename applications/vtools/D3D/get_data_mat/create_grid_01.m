%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function create_grid_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'write_shp')==0
    flg_loc.write_shp=0;
end
if flg_loc.write_shp==1
    messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_grd_mat=fullfile(fdir_mat,'grd.mat');

%% get map from grid

if exist(fpath_grd_mat,'file')
    return
end

if isfield(simdef.file,'map')==0 %there is no map file
    fpath_map=fullfile(fdir_mat,'grid_map.nc');
    D3D_grd2map(simdef.file.grd,'fpath_map',fpath_map);
    simdef.file.map=fpath_map;
end
fpath_map=gdm_fpathmap(simdef,0);

%% SHP

if flg_loc.write_shp
    fpath_poly=fullfile(fdir_mat,'grd_polygons.mat');
    if exist(fpath_poly,'file')==2
        load(fpath_poly,'polygons')
    else        
        polygons=D3D_grid_polygons(fpath_map);
        save_check(fpath_poly,'polygons');
    end
end

%% GRID

gdm_load_grid(fid_log,fdir_mat,fpath_map,'do_load',0);
% gdm_load_grid_simdef(fid_log,simdef,'do_load',0); %don't call, because we have to pass the grd-file

%% shp
if flg_loc.write_shp
    error('do')
%     EHY_convert(fpath_grd
end

end %function

%% 
%% FUNCTION
%%
