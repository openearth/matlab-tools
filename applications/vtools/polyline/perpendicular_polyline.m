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

function [xyL,xyR]=perpendicular_polyline(xy,np_average,ds)

angle_track=angle_polyline(xy(:,1),xy(:,2),np_average);
angle_perp=angle_track+pi/2;
xyL=xy+ds.*[cos(angle_perp),sin(angle_perp)];
xyR=xy-ds.*[cos(angle_perp),sin(angle_perp)];
