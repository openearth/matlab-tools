%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: read_ascii.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/read_ascii.m $
%
%rotate point '[x,y]' 'theta' radians around point '[xc,yc]' in cartesian
%coordinates.

function [x_rot,y_rot]=rotate2Dcart(x,y,xc,yc,theta)

x_rot= (x-xc)*cos(theta)+(y-yc)*sin(theta)+xc;
y_rot=-(x-xc)*sin(theta)+(y-yc)*cos(theta)+yc;

end %function