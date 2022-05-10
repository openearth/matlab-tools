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

function create_mat_grd(fid_log,in_plot,simdef)

warning('outdated, call <gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map)>')
%calling only in those we need
% if ~in_plot.map
%     messageOut(fid_log,'It is not necessary to get the grid')
%     return
% end
% messageOut(fid_log,'It is necessary to get the grid')

if exist(simdef.file.mat.grd,'file')==2
    messageOut(fid_log,'Grid mat-file exist')
    return
end
messageOut(fid_log,'Grid mat-file does not exist. Reading.')

gridInfo=EHY_getGridInfo(simdef.file.map,{'face_nodes_xy','XYcen','no_layers'},'mergePartitions',1); %#ok
save_check(simdef.file.mat.grd,'gridInfo'); 
    
end %function