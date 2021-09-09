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


function [s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_x_28992,cords_y_28992]=flip_section(s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_x_28992,cords_y_28992,angle_track_4all)
    s=[0,cumsum(fliplr(diff(s)))];
    vmag=fliplr(vmag);
    vvert=fliplr(vvert);
%     vpara=fliplr(vpara);
%     vperp=fliplr(vperp);
    vpara=-fliplr(vpara);
    vperp=-fliplr(vperp);
    
    cords_xy_4326=flipud(cords_xy_4326);
    cords_x_28992=flipud(cords_x_28992);
    cords_y_28992=flipud(cords_y_28992);
    
    angle_track_v=angle_track+[pi,-pi];
    [~,idx]=min(abs(angle_track_v-angle_track_4all));
    angle_track=angle_track_v(idx);
end