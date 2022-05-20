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

function gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map)

fpath_grd=fullfile(fdir_mat,'grd.mat');

if exist(fpath_grd,'file')==2
    messageOut(fid_log,'Grid mat-file exist. Loading.')
    load(fpath_grd,'gridInfo')
    return
end

messageOut(fid_log,'Grid mat-file does not exist. Reading.')

gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy','XYcen','XYcor','no_layers'},'mergePartitions',1); %#ok
save_check(fpath_grd,'gridInfo'); 
    
end %function