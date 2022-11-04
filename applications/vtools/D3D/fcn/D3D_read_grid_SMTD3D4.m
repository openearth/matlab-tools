%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 12:07:53 +0200 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: gdm_load_grid.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_grid.m $
%
%

function gridInfo=D3D_read_grid_SMTD3D4(fpath_map)

ndd=numel(fpath_map);
gridInfo=EHY_getGridInfo(fpath_map{1},{'face_nodes_xy','XYcen','XYcor','no_layers','grid'},'mergePartitions',1); 

for kdd=2:ndd
    gridInfo_aux=EHY_getGridInfo(fpath_map{kdd},{'face_nodes_xy','XYcen','XYcor','no_layers','grid'},'mergePartitions',1); 

    gridInfo.Xcor=D3D_SMTD3D4_concatenate(gridInfo.Xcor,gridInfo_aux.Xcor,0);
    gridInfo.Ycor=D3D_SMTD3D4_concatenate(gridInfo.Ycor,gridInfo_aux.Ycor,0);
    gridInfo.Xcen=D3D_SMTD3D4_concatenate(gridInfo.Xcen,gridInfo_aux.Xcen,1);
    gridInfo.Ycen=D3D_SMTD3D4_concatenate(gridInfo.Ycen,gridInfo_aux.Ycen,1);
end
