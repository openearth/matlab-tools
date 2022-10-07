%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18411 $
%$Date: 2022-10-06 14:18:03 +0200 (Thu, 06 Oct 2022) $
%$Author: chavarri $
%$Id: fig_map_sal_01.m 18411 2022-10-06 12:18:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_map_sal_01.m $
%

function tz1=tiles_zoom(dx)

if dx<100
    tz1=16;
elseif dx<10e3
    tz1=14;
elseif dx<20e3
    tz1=13;
elseif dx<100e3
    tz1=9;
elseif dx<500e3
    tz1=8;
else
    tz1=1;
end
end %function