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

function data=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name)

%%

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

fpath_rkm_pol=mat_tmp_name(fdir_mat,tag,'pol',rkm_name);
if exist(fpath_rkm_pol,'file')==2 %&& ~flg_loc.overwrite 
    load(fpath_rkm_pol,'data')
    return
end

rkm_edg=cen2cor(rkm_cen)';
%     rkm_edg_br=maas_branches(rkm_edg); %cannot call this function here
rkm_edg_br=[rkm_cen_br,rkm_cen_br{end}]; %this is not good enough. It may be that an edge point falls in a different branch name

rkm_edg_xy=convert2rkm(fpath_rkm,rkm_edg,rkm_edg_br);
rkm_cen_xy=convert2rkm(fpath_rkm,rkm_cen,rkm_cen_br);
[rkm_edg_xy_L,rkm_edg_xy_R]=perpendicular_polyline(rkm_edg_xy,2,1000);
npol=numel(rkm_cen);
bol_pol_loc=cell(npol,1);
for kpol=1:npol
    pol_loc=[[rkm_edg_xy_L(kpol:kpol+1,1);flipud(rkm_edg_xy_R(kpol:kpol+1,1));rkm_edg_xy_L(kpol,1)],[rkm_edg_xy_L(kpol:kpol+1,2);flipud(rkm_edg_xy_R(kpol:kpol+1,2));rkm_edg_xy_L(kpol,2)]];

    bol_pol_loc{kpol,1}=inpolygon(gridInfo.Xcen,gridInfo.Ycen,pol_loc(:,1),pol_loc(:,2));
%             %% BEGIN DEBUG
%             figure; hold on; plot(pol_loc(:,1),pol_loc(:,2),'-*')
%             % END DEBUG
end
data=v2struct(bol_pol_loc,rkm_cen,rkm_edg,rkm_cen_br,rkm_edg_br,rkm_edg_xy,rkm_cen_xy,rkm_edg_xy_L,rkm_edg_xy_R); %#ok
save_check(fpath_rkm_pol,'data');

