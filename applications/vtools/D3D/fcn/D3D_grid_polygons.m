%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bc_lateral.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bc_lateral.m $
%
%Creates polygons of an unstructured grid
%
%Thanks to Julien Groeneboom

function polygons=D3D_grid_polygons(ncFile)

gridInfo = EHY_getGridInfo(ncFile,'face_nodes_xy');

for iC = 1:size(gridInfo.face_nodes_x,2)
    x = gridInfo.face_nodes_x(:,iC);
    y = gridInfo.face_nodes_y(:,iC);
    nonan = ~isnan(x);
    
    polygons{iC,1} = [x(nonan) y(nonan)];
end