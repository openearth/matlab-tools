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
%Finds the points of a grid that are representative of a river kilometer. 
%Given a set of river-kilometer points (it does not need to be exact river
%kilometers nor be equispaced), a polygon is created around these points.
%The polygon is a quadrilateral formed by two lines parallel to the
%centerline at a user-defined distance and two lines perpendicular to the
%centerline between subsequent river-kilometer points.
%
%It considers the distances corrected by bend cutoff. 

function data=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,fpath_map,fpath_rkm,rkm_cen,rkm_cen_br,rkm_name,varargin)

%% PARSE

fpath_rkm_pol=mat_tmp_name(fdir_mat,tag,'pol',rkm_name);
if exist(fpath_rkm_pol,'file')==2 %&& ~flg_loc.overwrite 
    load(fpath_rkm_pol,'data')
    return
end

if numel(varargin)>0
    track=varargin{1,1};
else
    track=rkm_cen_br{1};
end

if numel(varargin)>1
    parallel_distance=varargin{2,1};
else
    parallel_distance=1000;
end

if numel(varargin)>2
    ds_pol=varargin{3,1};
else
    ds_pol=100;
end

%% LOAD

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% CALC

%% dx

%dx is based on original rkm centres, not corrected by bend cutoff
rkm_edg=cen2cor(rkm_cen)';
rkm_dx=diff(rkm_edg);

%% correct for bend cutoff

%remove rkm_cen which are inside a cutoff
ncen=numel(rkm_cen);
co=false(ncen,1);
for kpol=1:ncen
    [~,co(kpol)]=correct_for_bendcutoff(rkm_cen(kpol),rkm_cen(kpol)-0.1,rkm_cen_br{kpol},ds_pol); %!!! ATTENTION a negative number implies that the rkm must be increasing. 
end
rkm_cen(co)=[];
rkm_dx(co)=[];

%compute edges of corrected cutoff points
rkm_edg=[rkm_cen-rkm_dx/2;rkm_cen(end)+rkm_dx(end)/2]; %cannot `cen2cor` because of the bend cutoff. 
ncen=numel(rkm_cen);
rkm_edg_br=cell(ncen+1,1);
for kpol=1:ncen
    rkm_edg_br(kpol)=branch_str_num(rkm_edg(kpol),track);
    rkm_edg(kpol)=correct_for_bendcutoff(rkm_edg(kpol),rkm_cen(kpol),rkm_edg_br{kpol},ds_pol); 
end
%last edge also associated to last rkm
rkm_edg_br(end)=branch_str_num(rkm_edg(end),track);
rkm_edg(end)=correct_for_bendcutoff(rkm_edg(end),rkm_cen(end),rkm_edg_br{kpol},ds_pol); 

%%

rkm_edg_xy=convert2rkm(fpath_rkm,rkm_edg,rkm_edg_br);
rkm_cen_xy=convert2rkm(fpath_rkm,rkm_cen,rkm_cen_br);
[rkm_edg_xy_L,rkm_edg_xy_R]=perpendicular_polyline(rkm_edg_xy,2,parallel_distance); %lines `parallel_distance` to the right and left of the centre. 
bol_pol_loc=cell(ncen,1);
for kpol=1:ncen
    pol_loc=[[rkm_edg_xy_L(kpol:kpol+1,1);flipud(rkm_edg_xy_R(kpol:kpol+1,1));rkm_edg_xy_L(kpol,1)],[rkm_edg_xy_L(kpol:kpol+1,2);flipud(rkm_edg_xy_R(kpol:kpol+1,2));rkm_edg_xy_L(kpol,2)]];

    bol_pol_loc{kpol,1}=inpolygon(gridInfo.Xcen(:),gridInfo.Ycen(:),pol_loc(:,1),pol_loc(:,2));

% %% BEGIN DEBUG
% figure
% hold on
% 
% scatter(gridInfo.Xcen(:),gridInfo.Ycen(:),5,'.k')
% 
% plot(rkm_cen_xy(:,1),rkm_cen_xy(:,2),'-ob')
% 
% plot(rkm_edg_xy(:,1),rkm_edg_xy(:,2),'-om','linewidth',2)
% plot(rkm_edg_xy_L(:,1),rkm_edg_xy_L(:,2),'-or')
% plot(rkm_edg_xy_R(:,1),rkm_edg_xy_R(:,2),'-og')
% 
% scatter(rkm_cen_xy(kpol  ,1),rkm_cen_xy(kpol  ,2),40,'ob','filled')
% scatter(rkm_edg_xy(kpol  ,1),rkm_edg_xy(kpol  ,2),40,'sr','filled')
% scatter(rkm_edg_xy(kpol+1,1),rkm_edg_xy(kpol+1,2),40,'sg','filled')
% 
% plot(pol_loc(:,1),pol_loc(:,2),'-dy')
% 
% axis equal

% %% END DEBUG

end %kpol

data=v2struct(bol_pol_loc,rkm_cen,rkm_edg,rkm_cen_br,rkm_edg_br,rkm_edg_xy,rkm_cen_xy,rkm_edg_xy_L,rkm_edg_xy_R,rkm_dx);
save_check(fpath_rkm_pol,'data');

end %function