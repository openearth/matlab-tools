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
%grid creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_grd_rect_u(simdef)

%% RENAME
    
grdfile=simdef.file.grd;
dx=simdef.grd.dx;
dy=simdef.grd.dy;
L=simdef.grd.L;
B=simdef.grd.B;

%% CALC

xr=0:dx:L;
yr=0:dy:B;

[x,y]=meshgrid(xr,yr);

write_structured_NC_grid(grdfile,x,y);

end %function