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

function [cline_s,idx_o]=order_polyline(cline,varargin)

p0_idx=1;
if nargin==2
    p0_idx=varargin{1,1};
end

np=size(cline,1);

cline_s=NaN(size(cline)); %sorted 
cline_rem=cline; %remaining 

cline_s(1,:)=cline(p0_idx,:);
cline_rem(p0_idx,:)=NaN(1,2);
idx_o=NaN(np,1);
idx_o(p0_idx)=1;
for kp=2:np
    dist2=sum((cline_s(kp-1,:)-cline_rem).^2,2);
    [~,idx_o(kp)]=min(dist2,[],'omitnan');
    cline_s(kp,:)=cline_rem(idx_o(kp),:);
    cline_rem(idx_o(kp),:)=NaN(1,2);
end %kp

