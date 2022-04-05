%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 27 $
%$Date: 2022-03-31 13:12:25 +0200 (Thu, 31 Mar 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 27 2022-03-31 11:12:25Z chavarri $
%$HeadURL: file:///P:/11208075-002-ijsselmeer/07_scripts/svn/create_mat_map_sal_mass_01.m $
%
%

function create_mat_grd(fid_log,in_plot,simdef)
    
if ~in_plot.map
    messageOut(fid_log,'It is not necessary to get the grid')
    return
end
messageOut(fid_log,'It is necessary to get the grid')

if exist(simdef.file.mat.grd,'file')==2
    messageOut(fid_log,'Grid mat-file exist')
    return
end
messageOut(fid_log,'Grid mat-file does not exist. Reading.')

gridInfo=EHY_getGridInfo(simdef.file.map,{'face_nodes_xy','XYcen','no_layers'},'mergePartitions',1);
save_check(simdef.file.mat.grd,'gridInfo');
    
end %function