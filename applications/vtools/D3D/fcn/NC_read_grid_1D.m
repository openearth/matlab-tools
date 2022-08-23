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

function gridInfo=NC_read_grid_1D(fpath_map)

[~,~,str_network]=D3D_is(fpath_map);

x_node=ncread(fpath_map,'mesh1d_node_x');
y_node=ncread(fpath_map,'mesh1d_node_y');

x_edge=ncread(fpath_map,'mesh1d_edge_x');
y_edge=ncread(fpath_map,'mesh1d_edge_y');

offset_edge=ncread(fpath_map,'mesh1d_edge_offset');
branch_edge=ncread(fpath_map,'mesh1d_edge_branch');

offset=ncread(fpath_map,'mesh1d_node_offset');
branch=ncread(fpath_map,'mesh1d_node_branch');
branch_length=ncread(fpath_map,sprintf('%s_edge_length',str_network));
branch_id=ncread(fpath_map,sprintf('%s_branch_id',str_network))';

no_layers=1;

gridInfo=v2struct(x_node,y_node,x_edge,y_edge,offset_edge,branch_edge,offset,branch,branch_length,branch_id,no_layers);

end %function