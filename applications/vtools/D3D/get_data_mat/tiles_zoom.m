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

if dx<1000
    tz1=17;
elseif dx<5000
    tz1=15;
elseif dx<10e3
    tz1=14;
elseif dx<20e3
    tz1=13;
elseif dx<50e3
    tz1=11;
elseif dx<100e3
    tz1=10;
elseif dx<500e3
    tz1=9;
else
    tz1=1;
end
end %function