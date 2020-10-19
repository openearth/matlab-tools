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
%rotate point '[x,y]' 'theta' radians around point '[xc,yc]' in cartesian
%coordinates.

function [x_rot,y_rot]=rotate2Dcart(x,y,xc,yc,theta)

x_rot= (x-xc)*cos(theta)+(y-yc)*sin(theta)+xc;
y_rot=-(x-xc)*sin(theta)+(y-yc)*cos(theta)+yc;

end %function