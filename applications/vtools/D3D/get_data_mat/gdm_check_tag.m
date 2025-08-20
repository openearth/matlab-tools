%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20194 $
%$Date: 2025-06-13 09:30:18 +0200 (Fri, 13 Jun 2025) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_ls_01.m 20194 2025-06-13 07:30:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_ls_01.m $
%
%

function in_plot_fig=gdm_check_tag(in_plot,tag_old,tag_check)

in_plot=gdm_check_deprecated_tag(in_plot,tag_old,tag_check);

if isfield(in_plot,tag_check)
    in_plot_fig=gmd_tag(in_plot,tag_check); %is this needed? I think it can be simplified and only take the still-relevant parts of it
end

end %function