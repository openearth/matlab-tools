%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 11:40:08 +0100 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_floodplane.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_floodplane.m $
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