%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17273 $
%$Date: 2021-05-07 21:37:43 +0200 (Fri, 07 May 2021) $
%$Author: chavarri $
%$Id: absolute_limits.m 17273 2021-05-07 19:37:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%order points in a polyline

function cline_s=order_polyline(cline,p0_idx)

np=size(cline,1);

cline_s=NaN(size(cline)); %sorted 
cline_rem=cline; %remaining 

cline_s(1,:)=cline(p0_idx,:);
cline_rem(p0_idx,:)=NaN(1,2);

for kp=2:np
    dist2=sum((cline_s(kp-1,:)-cline_rem).^2,2);
    [~,idx_next]=min(dist2,[],'omitnan');
    cline_s(kp,:)=cline_rem(idx_next,:);
    cline_rem(idx_next,:)=NaN(1,2);
end %kp

