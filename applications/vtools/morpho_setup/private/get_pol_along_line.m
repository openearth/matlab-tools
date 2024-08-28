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
%rkm    = queary point. Can be any. 
%br     = branch code.
%dist   = distance to find the polygon names
%
function [rkm_pol,br_num]=get_pol_along_line(rkm,br,dist)

ds_pol=polygon_ds(br); 

%if the query is in a bend cut-off, there is no data to be taken, the point does not exist. 
[~,cutoff]=correct_for_bendcutoff(rkm,rkm,br,ds_pol/1000);
if cutoff
    rkm_pol=NaN;
    br_num=NaN;
    return
end

rkm_s=rkm-dist/2/1000:ds_pol/1000:rkm+dist/2/1000-ds_pol/1000/2;

ns=numel(rkm_s);
rkm_pol=NaN(ns,1);
for ks=1:ns
    rkm_pol(ks)=rkm_of_pol(rkm_s(ks),br); %the rkm along a certain branch closest to the query rkm. 
    rkm_pol(ks)=correct_for_bendcutoff(rkm_pol(ks),rkm,br,ds_pol/1000);
end

[br_l,br_num]=branch_str_num(rkm_pol,br,'ni_bo',true); %branch name (e.g., BO) for a given rkm and river branch (e.g. WA). 

end
