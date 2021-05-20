%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17185 $
%$Date: 2021-04-14 14:53:56 +0200 (Wed, 14 Apr 2021) $
%$Author: chavarri $
%$Id: perpendicular_polyline.m 17185 2021-04-14 12:53:56Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/perpendicular_polyline.m $
%

function [xyL,xyR]=perpendicular_polyline(xy,np_average,ds)

angle_track=angle_polyline(xy(:,1),xy(:,2),np_average);
angle_perp=angle_track+pi/2;
xyL=xy+ds.*[cos(angle_perp),sin(angle_perp)];
xyR=xy-ds.*[cos(angle_perp),sin(angle_perp)];
