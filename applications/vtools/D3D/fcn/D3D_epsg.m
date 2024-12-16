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

function epsg=D3D_epsg(fpath_grd)

nci=ncinfo(fpath_grd);
bol_coordinate_system=strcmp({nci.Variables.Name},'projected_coordinate_system');
bol_epsg=strcmp({nci.Variables(bol_coordinate_system).Attributes.Name},'epsg');
epsg=double(nci.Variables(bol_coordinate_system).Attributes(bol_epsg).Value);

end %function
