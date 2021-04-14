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

function [xyL,xyR]=perpendicular_polyline(xy,np_average,ds)

angle_track=angle_polyline(xy(:,1),xy(:,2),np_average);
angle_perp=angle_track+pi/2;
xyL=xy+ds.*[cos(angle_perp),sin(angle_perp)];
xyR=xy-ds.*[cos(angle_perp),sin(angle_perp)];
