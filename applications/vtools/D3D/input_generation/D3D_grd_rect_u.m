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
[nr,nc]=size(x);

n=reshape(1:length(x(:)),[nr,nc]);

lnk=[[reshape(n(1:nr-1,:), [(nr-1)*nc, 1]), reshape(n(2:nr,:), [(nr-1)*nc, 1])]; ...
    [reshape(n(:,1:nc-1), [nr*(nc-1), 1]), reshape(n(:,2:nc), [nr*(nc-1), 1])]];

%rename
x_v=x(:);
y_v=y(:);
lnk_v=lnk.';

% lnk_x=[x_v(lnk(:,1)),x_v(lnk(:,2))];
% lnk_y=[y_v(lnk(:,1)),y_v(lnk(:,2))];

%% SAVE

dflowfm.writeNet(grdfile,x_v,y_v,lnk_v);

end %function