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