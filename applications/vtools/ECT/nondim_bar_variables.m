%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18303 $
%$Date: 2022-08-15 16:11:52 +0200 (ma, 15 aug 2022) $
%$Author: chavarri $
%$Id: twoD_study.m 18303 2022-08-15 14:11:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%
%

function [l,b]=nondim_bar_variables(dir,x,y,h)

switch dir
    case 1 %nondimensionalize
        l=pi*y/2/x; %lambda
        b=y/4/h; %beta
    case -1 %dimensionalize
        b=4*y*h; %l_y
        l=pi/2*b/x; %l_x
end

end %function
