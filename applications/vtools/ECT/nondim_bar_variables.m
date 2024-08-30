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
