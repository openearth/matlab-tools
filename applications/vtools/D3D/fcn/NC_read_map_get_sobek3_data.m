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

function out=NC_read_map_get_sobek3_data(tag_read,file_map,in,branch,offset,x_node,y_node,branch_length,branch_id)

kt=in.kt;

% wl=ncread(file_map,tag_read,[1,kt(1)],[Inf,1]);
wl=ncread(file_map,tag_read,[1,kt(1)],[Inf,kt(2)]);

[wl_br,o_br]=NC_read_map_get_data_from_branches(wl,in,branch,offset,x_node,y_node,branch_length,branch_id);
[~,u_idx,~]=unique(o_br);
wl_o=wl_br(u_idx,:);
o_o=o_br(u_idx);

%output
out.z=wl_o;
out.XZ=x_node(u_idx);
out.YZ=y_node(u_idx);
out.SZ=o_o;

end %function