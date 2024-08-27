%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19028 $
%$Date: 2023-07-04 08:38:28 +0200 (Tue, 04 Jul 2023) $
%$Author: chavarri $
%$Id: filter_pol_data.m 19028 2023-07-04 06:38:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/private/filter_pol_data.m $
%
%

function bol_ex=compute_exclude_booleans(exclude_id,rkm_pol_num,br_pol_num)

tol_rkm=1e-10;

bol_rkm_ex=ismember_num(rkm_pol_num,[exclude_id{:,2}],tol_rkm); %boolean of the rkm to exclude from the mean
br_ex_num=cellfun(@(X)branch_rijntakken_str2double(X),exclude_id(:,1));
bol_br_ex=ismember(br_pol_num,br_ex_num); %boolean of the branch to compute the mean
bol_ex=bol_rkm_ex & bol_br_ex; %boolean of the identificators to exclude from the mean

end