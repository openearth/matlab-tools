%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17498 $
%$Date: 2021-09-29 08:53:15 +0200 (Wed, 29 Sep 2021) $
%$Author: chavarri $
%$Id: adcp_flip_section.m 17498 2021-09-29 06:53:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_flip_section.m $
%


function [s,m]=flip_section(s,m)
    s=[0,cumsum(fliplr(diff(s)))];
    m=fliplr(m);
        
%     angle_track_v=angle_track+[pi,-pi];
%     [~,idx]=min(abs(angle_track_v-angle_track_4all));
%     angle_track=angle_track_v(idx);
end