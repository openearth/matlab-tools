%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18070 $
%$Date: 2022-05-20 18:33:29 +0200 (Fri, 20 May 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_char.m 18070 2022-05-20 16:33:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_char.m $
%
%

function north_deg=xy2north_deg(x,y)

rad=atan2(y,x);
deg=rad*360/2/pi;
north_deg=-deg+90;
north_deg(north_deg<0)=360+north_deg(north_deg<0);

%CHECK

% theta=linspace(0,2*pi,360);
% [x,y]=pol2cart(theta,1.5);
% north_deg=xy2north_deg(x,y);
% 
% figure
% hold on
% scatter(x,y,10,north_deg)
% colorbar

end %function
