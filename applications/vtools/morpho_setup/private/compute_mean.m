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

function [val,idx_rkm]=compute_mean(etab_cen,area_cen,loc_pol_num,rkm_pol_num,br_pol_num,loc_v,rkm_cen,br,bol_ex)

tol_rkm=1e-10;

%preallocate
nrkm=numel(rkm_cen);
val=NaN(nrkm,1);
idx_rkm=NaN(size(etab_cen));

dist=diff(cen2cor(rkm_cen))*1000;

for krkm=1:nrkm
% for krkm=1:27
    rkm_q=rkm_cen(krkm); %query rkm (any) at which to compute the mean
    rkm_mod=rkm_of_pol(rkm_q,br); %rkm to modify. Along a certain branch closest to the query rkm. 
    br_mod_str=branch_rijntakken(rkm_mod,br,'ni_bo',true); %branch name to modify (e.g., BO) for a given rkm and river branch (e.g. WA). 
    [rkm_me,br_me]=get_pol_along_line(rkm_q,br_mod_str{1},dist(krkm)); %rkm and branch to compute the mean
    
    bol_rkm_me=ismember_num(rkm_pol_num,rkm_me,tol_rkm); %boolean of the rkm to compute the mean
    bol_br_me=ismember(br_pol_num,br_me); %boolean of the branch to compute the mean
    bol_loc=ismember(loc_pol_num,loc_v);
    bol_used=~isnan(idx_rkm);

    bol_me=bol_rkm_me & bol_loc & bol_br_me & ~bol_ex & ~bol_used;

    val(krkm,1)=sum(etab_cen(bol_me).*area_cen(bol_me))/sum(area_cen(bol_me));

    %save for plot
    idx_rkm(bol_me)=krkm;

    %DEBUG
%     if ~all(isnan(idx_rkm(bol_me)))
%         warning('Some values have already been used. rkm idx')
%         bol_used=~isnan(idx_rkm);
% %         bol_overwrite=bol_used & bol_me;
%         fprintf('rkm %f \n',rkm_q);    
% %         fprintf('%f \n',rkm_pol_num(bol_overwrite))
%     else
%         idx_rkm(bol_me)=krkm;
%     end
%     fprintf('rkm %f \n',rkm_q)    
%     fprintf('%f \n',rkm_pol_num(bol_me))
%     fprintf('%d \n',br_pol_num(bol_me))
%     fprintf('%f \n',loc_pol_num(bol_me))
    %END DEBUG
       
end %krkm

end %function