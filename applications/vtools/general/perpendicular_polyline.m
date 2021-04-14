%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: compute_distance_along_line.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/compute_distance_along_line.m $
%

function [xyL,xyR]=perpendicular_polyline(xy,np_average,ds)

angle_track=angle_polyline(xy(:,1),xy(:,2),np_average);
angle_perp=angle_track+pi/2;
xyL=xy+ds.*[cos(angle_perp),sin(angle_perp)];
xyR=xy-ds.*[cos(angle_perp),sin(angle_perp)];
