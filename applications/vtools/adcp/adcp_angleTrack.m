aa %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function angle_track=adcp_angleTrack(cords_x,cords_y,isCross)

if isCross
    dcords_tot_xy=[cords_x(end)-cords_x(1),cords_y(end)-cords_y(1)];
    angle_track=atan2(dcords_tot_xy(1,2),dcords_tot_xy(1,1));
else
    ds=10; %use multiple of two 
    dcords_xy=[cords_x(1+ds:end)-cords_x(1:end-ds),cords_y(1+ds:end)-cords_y(1:end-ds)];
    angle_track=atan2(dcords_xy(:,2),dcords_xy(:,1));
    angle_track=[angle_track(1)*ones(ds/2,1);angle_track;angle_track(end)*ones(ds/2,1)];
end