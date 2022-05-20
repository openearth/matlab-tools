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
%Creates polygons of an unstructured grid
%
%Thanks to Julien Groeneboom

function polygons=D3D_grid_polygons(ncFile)

gridInfo=EHY_getGridInfo(ncFile,'face_nodes_xy');

nC=size(gridInfo.face_nodes_x,2);
polygons=cell(nC,1);
for iC=1:nC
    x=gridInfo.face_nodes_x(:,iC);
    y=gridInfo.face_nodes_y(:,iC);
    nonan=~isnan(x);
    
    polygons{iC,1} = [x(nonan) y(nonan)];
end