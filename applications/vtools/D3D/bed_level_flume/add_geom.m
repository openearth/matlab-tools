%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_aru_arv.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_aru_arv.m $
%

function z=add_geom(geom,x,y)

z=0;

z=add_flume_slope(geom,x,y,z);

z=add_floodplane(geom,x,y,z);

z_groyne_field=add_groyne_field(geom,x,y,z);
% z_groyne_field=0;

z_groynes=add_groynes(geom,x,y,z);
% z_groynes=0;

z=max(z_groyne_field,z_groynes);

end %function