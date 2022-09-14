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

warning('outdated, call <D3D_gdm>')
% out=nc2struct(simdef.file.grd,str_network1d));

[ismor,is1d,str_network1d,issus]=D3D_is(simdef.file.grd);

out.network1d_branch_order=ncread(simdef.file.grd,sprintf('%s_branch_order',str_network1d));
out.network1d_node_id=ncread(simdef.file.grd,sprintf('%s_node_id',str_network1d));
out.network1d_geom_node_count=ncread(simdef.file.grd,sprintf('%s_geom_node_count',str_network1d));
out.network1d_geom_x=ncread(simdef.file.grd,sprintf('%s_geom_x',str_network1d));
out.network1d_geom_y=ncread(simdef.file.grd,sprintf('%s_geom_y',str_network1d));
out.network1d_node_x=ncread(simdef.file.grd,sprintf('%s_node_x',str_network1d));
out.network1d_node_y=ncread(simdef.file.grd,sprintf('%s_node_y',str_network1d));
out.mesh1d_node_branch=ncread(simdef.file.grd,'mesh1d_node_branch');
out.network1d_branch_id=ncread(simdef.file.grd,sprintf('%s_branch_id',str_network1d));

out.mesh1d_node_x=ncread(simdef.file.grd,'mesh1d_node_x');
out.mesh1d_node_y=ncread(simdef.file.grd,'mesh1d_node_y');

end %function