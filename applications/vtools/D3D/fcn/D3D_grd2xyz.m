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

function D3D_grd2xyz(fpath_grd,varargin)

%% PARSE

if exist(fpath_grd,'file')~=2
    error('grid file does not exist: %s',fpath_grd)
end
[fdir,fname,~]=fileparts(fpath_grd);

parin=inputParser;

addOptional(parin,'fpath_out',fullfile(fdir,sprintf('%s.xyz',fname)));
% addOptional(parin,'fdir_work',fullfile(pwd,'tmp_grd2map'));
addOptional(parin,'fpath_exe','c:\Program Files (x86)\Deltares\Delft3D Flexible Mesh Suite HMWQ (2021.03)\plugins\DeltaShell.Dimr\kernels\x64\dimr\scripts\run_dimr.bat');
addOptional(parin,'fpath_map',fullfile(pwd,sprintf('%s_map.nc',fname)));
addOptional(parin,'fid_log',NaN);
addOptional(parin,'add_header',0)
addOptional(parin,'cell_centre',0)


parse(parin,varargin{:});

fpath_out=parin.Results.fpath_out;
% fdir_work=parin.Results.fdir_work;
fpath_exe=parin.Results.fpath_exe;
fpath_map=parin.Results.fpath_map;
add_header=parin.Results.add_header;
cell_centre=parin.Results.cell_centre; 
% fid_log=parin.Results.fid_log;

%% READ

% D3D_grd2map(fpath_grd,'fpath_exe',fpath_exe,'fpath_map',fpath_map)
% map=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_bl');
% gridInfo=EHY_getGridInfo(fpath_map,'XYcen');
% gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy'});

if cell_centre; 
    loc_str='mesh2d_face';
else
    loc_str='mesh2d_node';
end

xn=ncread(fpath_grd,[loc_str,'_x']);
yn=ncread(fpath_grd,[loc_str,'_y']);
zn=ncread(fpath_grd,[loc_str,'_z']);

%% PLOT
% map.val(map.val==-5)=NaN; %-5 is the default when calling D3D_grd2map. I should change this I think. 

% figure
% hold on
% EHY_plotMapModelData(gridInfo,map.val)
% scatter(xn,yn,10,zn,'filled')
% scatter(xn,yn,10,'rx')
% colorbar
% axis equal

%% WRITE
% map.val(map.val==-5)=NaN; %-5 is the default when calling D3D_grd2map. I should change this I think. 
bol_nn=~isnan(zn);

[~,fname_out,fext]=fileparts(fpath_out);
fpath_out_loc=fullfile(pwd,sprintf('%s%s',fname_out,fext));
write_2DMatrix(fpath_out_loc,[xn(bol_nn),yn(bol_nn),zn(bol_nn)],'add_header',add_header);
copyfile_check(fpath_out_loc,fpath_out);
delete(fpath_out_loc)
% %%
% 

% 
% %%
% figure
% hold on
% scatter(xn,yn,10,zn,'filled')
% axis equal

end