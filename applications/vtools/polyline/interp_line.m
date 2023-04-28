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
%Linear equation. Find `y(x)` knowing the lines passes through two points 
%defined by their x-coordinates `xv` and y-coordinates `yv`.
%


function y=interp_line(xv,yv,x)
if isdatetime(x)
    y=interp_line_dtime(xv,yv,x); 
else
    y=interp_line_double(xv,yv,x);
end
end