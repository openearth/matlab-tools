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

function z_out=add_floodplane(geom,x,y,z_in)

%% RENAME

%external
h_floodplane=geom.h_floodplane;
B_floodplane=geom.B_floodplane;

%% CALC

if y<=B_floodplane
    z_out=z_in+h_floodplane;
else
    z_out=z_in;
end

end %function