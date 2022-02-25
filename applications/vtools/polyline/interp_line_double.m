%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17792 $
%$Date: 2022-02-24 21:11:49 +0100 (Thu, 24 Feb 2022) $
%$Author: chavarri $
%$Id: interp_line.m 17792 2022-02-24 20:11:49Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/interp_line.m $
%

function y=interp_line_double(xv,yv,x)
y=(yv(2)-yv(1))/(xv(2)-xv(1)).*(x-xv(1))+yv(1);
end %function