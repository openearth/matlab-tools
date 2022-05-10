%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18016 $
%$Date: 2022-05-03 16:22:21 +0200 (Tue, 03 May 2022) $
%$Author: chavarri $
%$Id: create_mat_grd.m 18016 2022-05-03 14:22:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_grd.m $
%
%

function gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map)

fpath_grd=fullfile(fdir_mat,'grd.mat');

if exist(fpath_grd,'file')==2
    messageOut(fid_log,'Grid mat-file exist. Loading.')
    load(fpath_grd,'gridInfo')
    return
end

messageOut(fid_log,'Grid mat-file does not exist. Reading.')

gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy','XYcen','no_layers'},'mergePartitions',1); %#ok
save_check(fpath_grd,'gridInfo'); 
    
end %function