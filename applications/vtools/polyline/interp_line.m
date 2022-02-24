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

function y=interp_line(xv,yv,x)
if isdatetime(x)
    y=(yv(2)-yv(1))/seconds(xv(2)-xv(1)).*seconds(x-xv(1))+yv(1);
else
    y=(yv(2)-yv(1))/(xv(2)-xv(1)).*(x-xv(1))+yv(1);
end
end