%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18956 $
%$Date: 2023-05-23 16:04:36 +0200 (Tue, 23 May 2023) $
%$Author: chavarri $
%$Id: gdm_read_data_map.m 18956 2023-05-23 14:04:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map.m $
%
%

function [idx_obs,nobs]=gdm_get_idx_grd(gridInfo,flg_loc);

%% PARSE

if isfield(flg_loc,'obs_tol')==0
    flg_loc.obs_tol=500;
end

%% CALC

nobs=numel(flg_loc.obs);

idx_obs=NaN(nobs,1);

for kobs=1:nobs
    dist=hypot(gridInfo.Xcen-flg_loc.obs(kobs).xy(1),gridInfo.Ycen-flg_loc.obs(kobs).xy(2));
    [idx_obs(kobs),min_v,flg_found]=absmintol(dist,0,'tol',flg_loc.obs_tol);
end %kobs

%% BEGIN DEBUG

% figure
% hold on
% plot(gridInfo.grid(:,1),gridInfo.grid(:,2))
% for kobs=1:nobs
%     scatter(gridInfo.Xcen(idx_obs(kobs)),gridInfo.Ycen(idx_obs(kobs)),10,'r','filled')
% end
% axis equal

%END DEBUG

end %function