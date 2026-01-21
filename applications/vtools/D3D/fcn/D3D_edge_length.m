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
%D3D_EDGE_LENGTH Compute edge lengths from node coordinates and edge-node connectivity

function edgeLength = D3D_edge_length(mesh2d_node_x,mesh2d_node_y,mesh2d_edge_nodes)

dx = mesh2d_node_x(mesh2d_edge_nodes(2,:)) - ...
     mesh2d_node_x(mesh2d_edge_nodes(1,:));
dy = mesh2d_node_y(mesh2d_edge_nodes(2,:)) - ...
     mesh2d_node_y(mesh2d_edge_nodes(1,:));

edgeLength = hypot(dx,dy);

end %function