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
