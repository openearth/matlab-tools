%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 10:24:15 +0200 (do, 15 apr 2021) $
%$Author: chavarri $
%$Id: D3D_grd_DHL.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_DHL.m $
%

function grd4=D3D_grd_DHL_coordinates(simdef)

%% RENAME

%Struiksma83_2
% W = 1.5;
% L1 = 7;
% L2 = 11;
% R = 12;
% dx = 0.05;
% dy = 0.15;
% angle = 140;

%Olesen85
% W = 2.0;
% L1 = 1;
% L2 = 11;
% R = 11.75;
% dx = 0.40;
% dy = 0.20;
% angle = 140;

W     = simdef.grd.B;
L1    = simdef.grd.L1;
L2    = simdef.grd.L2;
R     = simdef.grd.R;
dx    = simdef.grd.dx;
dy    = simdef.grd.dy;
angle = simdef.grd.angle;

%% CALC

m = round(W/dy); %13;%W/dx;

n1 = ceil(L1/dx);
n2 = ceil(L2/dx);
n3 = round(abs(R)*2*pi*angle/360/dx);

grd1a = d3dmakestraightgrid(W,L1,m,n1);
grd1b = d3dmakestraightgrid(W,L2,m,n2);
grd2  = d3dmakecurvedgrid  (W,R,angle,m,n3);

if n1>0
    grd3 = d3djoingrid(grd1a,grd2);
else
    grd3=grd2;
end
if n2>0
    grd4 = d3djoingrid(grd3,grd1b);
else
    grd4=grd3;
end

grd4 = d3dtranslategrid(grd4, 0, -sign(R)*(2*abs(R)+sign(R)*W)/2);
grd4 = d3drotategrid(grd4,angle+90);
% d3dplotgrid(grd4);

end %function