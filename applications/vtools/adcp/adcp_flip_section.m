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