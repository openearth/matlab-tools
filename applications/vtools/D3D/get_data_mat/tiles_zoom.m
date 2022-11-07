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

function tz1=tiles_zoom(dx)

if dx<100
    tz1=16;
elseif dx<10e3
    tz1=14;
elseif dx<20e3
    tz1=13;
elseif dx<50e3
    tz1=11;
elseif dx<100e3
    tz1=9;
elseif dx<500e3
    tz1=8;
else
    tz1=1;
end
end %function