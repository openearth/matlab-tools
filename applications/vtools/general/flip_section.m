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


function [s,m]=flip_section(s,m)
    s=[0,cumsum(fliplr(diff(s)))];
    m=fliplr(m);
        
%     angle_track_v=angle_track+[pi,-pi];
%     [~,idx]=min(abs(angle_track_v-angle_track_4all));
%     angle_track=angle_track_v(idx);
end