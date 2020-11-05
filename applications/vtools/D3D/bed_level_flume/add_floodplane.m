%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_aru_arv.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_aru_arv.m $
%

function z_out=add_floodplane(geom,x,y,z_in)

%% RENAME

%external
h_floodplane=geom.h_floodplane;
B_floodplane=geom.B_floodplane;

%% CALC

if y<=B_floodplane
    z_out=z_in+h_floodplane;
else
    z_out=z_in;
end

end %function