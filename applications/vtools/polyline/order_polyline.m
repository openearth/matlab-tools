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

