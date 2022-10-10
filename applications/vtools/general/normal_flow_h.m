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

function h_out=normal_flow_h(Q,B,cf,slope)

g=9.81;

C=sqrt(g/cf);
F=@(h)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
h_out=fzero(F,1);

end %function


