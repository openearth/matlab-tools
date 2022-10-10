%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 16:37:21 +0200 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%compute normal flow

function slope=normal_flow_slope_simplified(Q,B,cf,h)

g=9.81;

slope=cf*(Q/B)^2/g/h^3;

end %function


