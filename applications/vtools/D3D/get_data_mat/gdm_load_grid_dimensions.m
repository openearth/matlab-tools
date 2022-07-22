%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-20 18:31:37 +0200 (Fri, 20 May 2022) $
%$Author: chavarri $
%$Id: gdm_load_grid.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_grid.m $
%
%

function NetElem=gdm_load_grid_dimensions(fid_log,fdir_mat,fpath_map)

fpath_grd=fullfile(fdir_mat,'grd_NetElem.mat');

if exist(fpath_grd,'file')==2
    messageOut(fid_log,'NetElem mat-file exist. Loading.')
    load(fpath_grd,'NetElem')
    return
end

messageOut(fid_log,'NeElem mat-file does not exist. Reading.')

gridInfo=EHY_getGridInfo(fpath_map,{'dimensions'},'mergePartitions',1); %#ok
NetElem=gridInfo.no_NetElem;
save_check(fpath_grd,'NetElem'); 
    
end %function