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
function out=NC_read_grid(simdef,in)

% out=nc2struct(simdef.file.grd);

out.network1d_branch_order=ncread(simdef.file.grd,'network1d_branch_order');
out.network1d_node_id=ncread(simdef.file.grd,'network1d_node_id');
out.network1d_geom_node_count=ncread(simdef.file.grd,'network1d_geom_node_count');
out.network1d_geom_x=ncread(simdef.file.grd,'network1d_geom_x');
out.network1d_geom_y=ncread(simdef.file.grd,'network1d_geom_y');
out.network1d_node_x=ncread(simdef.file.grd,'network1d_node_x');
out.network1d_node_y=ncread(simdef.file.grd,'network1d_node_y');
out.mesh1d_node_branch=ncread(simdef.file.grd,'mesh1d_node_branch');
out.network1d_branch_id=ncread(simdef.file.grd,'network1d_branch_id');
% out.mesh1d

end %function