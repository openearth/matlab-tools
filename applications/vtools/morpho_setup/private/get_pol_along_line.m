%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18966 $
%$Date: 2023-05-26 09:39:44 +0200 (Fri, 26 May 2023) $
%$Author: chavarri $
%$Id: interpolate_bed_level_from_xlsx.m 18966 2023-05-26 07:39:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/interpolate_bed_level_from_xlsx.m $
%
%
%rkm    = queary point. Can be any. 
%br     = branch code.
%dist   = distance to find the polygon names
%
function [rkm_pol,br_num]=get_pol_along_line(rkm,br,dist)

% rkm_pol=rkm_of_pol(rkm,br); %the rkm along a certain branch closest to the query rkm. 
ds_pol=polygon_ds; 
rkm_s=rkm-dist/2/1000:ds_pol/1000:rkm+dist/2/1000;

ns=numel(rkm_s);
% str_pol=cell(ns,1);
br_l=cell(ns,1);
br_num=NaN(ns,1);
rkm_pol=NaN(ns,1);
for ks=1:ns
    rkm_pol(ks)=rkm_of_pol(rkm_s(ks),br); %the rkm along a certain branch closest to the query rkm. 
    br_l{ks}=branch_rt(br,rkm_pol(ks)); %branch name (e.g., BO) for a given rkm and river branch (e.g. WA). 
%     str_pol{ks,1}=polygon_str(br_l,rkm_pol);
    br_num(ks)=br_str2double(br_l{ks});
end

end
