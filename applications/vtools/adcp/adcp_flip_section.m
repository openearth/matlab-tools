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


function [s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_xy_28992,depth_track]=adcp_flip_section(s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_xy_28992,angle_track_4all,depth_track)
    s=[0,cumsum(fliplr(diff(s)))];
    vmag=fliplr(vmag);
    vvert=fliplr(vvert);
%     vpara=fliplr(vpara);
%     vperp=fliplr(vperp);
    vpara=-fliplr(vpara);
    vperp=-fliplr(vperp);
    depth_track=fliplr(depth_track);
    
    cords_xy_4326=flipud(cords_xy_4326);
    cords_xy_28992=flipud(cords_xy_28992);
    
    angle_track_v=angle_track+[pi,-pi];
    [~,idx]=min(abs(angle_track_v-angle_track_4all));
    angle_track=angle_track_v(idx);
end