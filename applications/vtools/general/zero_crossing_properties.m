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
%

function [am,lm]=zero_crossing_properties(x,z)

zm=mean(z,'omitnan');
zp=z>zm;

idx_u=strfind(zp,[0,1]);
nu=numel(idx_u)-1;
a=NaN(nu,1);
l=NaN(nu,1);
for ku=1:nu
    idx_get=idx_u(ku):1:idx_u(ku+1)-1;
    xl=x(idx_get);
    zl=z(idx_get);
    a(ku)=(max(zl)-min(zl));
    l(ku)=xl(end)-xl(1);
end
lm=mean(l);
am=mean(a);