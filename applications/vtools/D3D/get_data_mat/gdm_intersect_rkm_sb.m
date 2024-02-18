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
xy_int_L=intersect_sb_line(xy_loc,xy_L,sb,xy_ext);
xy_int_R=intersect_sb_line(xy_loc,xy_R,sb,xy_ext);

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

%%
%% FUNCTIONS
%%

function plot_and_error(sb,xy_ext,xy_perp_L,xy_L,xy_int_L)

figure
hold on
axis equal

plot(sb(:,1),sb(:,2),'-k');
plot(xy_ext(:,1),xy_ext(:,2),'or-')
plot(xy_perp_L(:,1),xy_perp_L(:,2))
scatter(xy_L(2,1),xy_L(2,2))
scatter(xy_int_L(:,1),xy_int_L(:,2))

error('no intersection')

end %function

%%

function xy_int_L=intersect_sb_line(xy_loc,xy_L,sb,xy_ext)

xy_perp_L=[xy_loc;xy_L(2,:)]; %line perpendicular to the rkm point. At location 2 in `xy_L` and `xy_R` it is the point perpendicular to the `xy_loc`, as this was the second point in `xy_ext`.
xy_int_L=InterX(xy_perp_L',sb')'; %intersection with the summerbed
if isempty(xy_int_L)
    plot_and_error(sb,xy_ext,xy_perp_L,xy_L,xy_int_L)
end
xy_int_L=xy_int_L(1,:); %if there are several interverntions we take the first one

end %function