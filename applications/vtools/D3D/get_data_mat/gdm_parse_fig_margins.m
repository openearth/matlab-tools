%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20207 $
%$Date: 2025-06-19 15:56:51 +0200 (Thu, 19 Jun 2025) $
%$Author: chavarri $
%$Id: D3D_nt.m 20207 2025-06-19 13:56:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_nt.m $
%
%

function in_p=gdm_parse_fig_margins(in_p)

%in [cm]
in_p=isfield_default(in_p,'fig_margin_top',1.5);
in_p=isfield_default(in_p,'fig_margin_bottom',1.5);
in_p=isfield_default(in_p,'fig_margin_right',0.5);
in_p=isfield_default(in_p,'fig_margin_left',2.0);
in_p=isfield_default(in_p,'fig_margin_separation_horizontal',0.5);
in_p=isfield_default(in_p,'fig_margin_separation_vertical',0.0);

end %function