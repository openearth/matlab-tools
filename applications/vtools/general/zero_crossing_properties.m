%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18613 $
%$Date: 2022-12-09 18:24:34 +0100 (Fri, 09 Dec 2022) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_01.m 18613 2022-12-09 17:24:34Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_01.m $
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