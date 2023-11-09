%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 12:07:53 +0200 (di, 27 sep 2022) $
%$Author: chavarri $
%$Id: NC_read_grid_1D.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_grid_1D.m $
%
%

function gridInfo=NC_read_grid_S3(fpath_map,simdef)

% file_read=S3_file_read(simdef.flg.which_v,file);
file_read=fpath_map;

x_node=ncread(file_read,'x_coordinate');
y_node=ncread(file_read,'y_coordinate');

offset=ncread(file_read,'chainage');
branch=ncread(file_read,'branchid');
branch_length=branch_length_sobek3(offset,branch);

branch_id=S3_get_branch_order(simdef);

%I think that I should add the values from the reachsegments to the edges.
x_edge=NaN;
y_edge=NaN;
offset_edge=NaN;
branch_edge=NaN;

%read from networkgeometry
x_net_node=NaN;
y_net_node=NaN;
net_node_id=NaN;
node_count_geom=NaN;
x_geom=NaN;
y_geom=NaN;

no_layers=1;

gridInfo=v2struct(x_node,y_node,x_edge,y_edge,offset_edge,branch_edge,offset,branch,branch_length,branch_id,no_layers,x_geom,y_geom,node_count_geom,net_node_id,x_net_node,y_net_node);

end %function