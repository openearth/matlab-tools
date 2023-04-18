%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17465 $
%$Date: 2021-08-25 16:36:23 +0200 (wo, 25 aug 2021) $
%$Author: chavarri $
%$Id: perpendicular_polyline.m 17465 2021-08-25 14:36:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/perpendicular_polyline.m $
%
%Compute polylines <xyL> and <xyR> perpendicular to the 
%left and right, respectively, of a polyline
%defined by coordinates in <xp> at a distance <ds>. The 
%angle of the polyline is defined on an average based on
%<np_average> points

function [xy_int_L,xy_int_R]=gdm_intersect_rkm_sb(flg_loc,xy_ext,xy_loc,sb)

%% PARSE

if isfield(flg_loc,'s_floodplain')==0
    flg_loc.s_floodplain=6000; %distance across the rkm-line to intersect with summerbed and winterbed [m]
end

%% CALC

[xy_L,xy_R]=perpendicular_polyline(xy_ext,2,flg_loc.s_floodplain); %polyline parallel to the left and right of the rkm polyline

xy_perp_L=[xy_loc;xy_L(2,:)]; %line perpendicular to the rkm point. At location 2 in `xy_L` and `xy_R` it is the point perpendicular to the `xy_loc`, as this was the second point in `xy_ext`.
xy_int_L=InterX(xy_perp_L',sb')'; %intersection with the summerbed
if isempty(xy_int_L)
    figure
    hold on
    axis equal

    plot(sb(:,1),sb(:,2),'-k');
    plot(xy_ext(:,1),xy_ext(:,2),'or-')
    plot(xy_perp_L(:,1),xy_perp_L(:,2))
    scatter(xy_L(2,1),xy_L(2,2))
    scatter(xy_int_L(:,1),xy_int_L(:,2))

    error('no intersection to the left')
end
xy_int_L=xy_int_L(1,:); %if there are several interverntions we take the first one

xy_perp_R=[xy_loc;xy_R(2,:)];
xy_int_R=InterX(xy_perp_R',sb')';    
if isempty(xy_int_L)
    figure
    hold on
    axis equal

    plot(sb(:,1),sb(:,2),'-k');
    plot(xy_ext(:,1),xy_ext(:,2),'or-')
    plot(xy_perp_L(:,1),xy_perp_L(:,2))
    scatter(xy_R(2,1),xy_R(2,2))
    scatter(xy_int_R(1,1),xy_int_R(1,2))

    error('no intersection to the right')
end
xy_int_R=xy_int_R(1,:); %if there are several interverntions we take the first one

%% DEBUG

%     figure
%     hold on
%     plot(sb(:,1),sb(:,2),'-k');
%     plot(xy_ext(:,1),xy_ext(:,2),'or-')
%     plot(xy_perp_L(:,1),xy_perp_L(:,2))
%     scatter(xy_L(2,1),xy_L(2,2))
%     
%     axis equal
%     scatter(xy_int_L(:,1),xy_int_L(:,2))
%     scatter(xy_int_R(1,1),xy_int_R(1,2))
% 

end %function