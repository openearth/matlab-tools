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