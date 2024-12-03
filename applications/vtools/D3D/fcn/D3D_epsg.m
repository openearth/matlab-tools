%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19843 $
%$Date: 2024-10-23 13:33:21 +0200 (Wed, 23 Oct 2024) $
%$Author: chavarri $
%$Id: fig_map_sal_01.m 19843 2024-10-23 11:33:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_map_sal_01.m $
%

function epsg=D3D_epsg(fpath_grd)

nci=ncinfo(fpath_grd);
bol_coordinate_system=strcmp({nci.Variables.Name},'projected_coordinate_system');
bol_epsg=strcmp({nci.Variables(bol_coordinate_system).Attributes.Name},'epsg');
epsg=double(nci.Variables(bol_coordinate_system).Attributes(bol_epsg).Value);

end %function
