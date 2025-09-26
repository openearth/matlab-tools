%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20289 $
%$Date: 2025-08-20 10:19:00 +0200 (Wed, 20 Aug 2025) $
%$Author: chavarri $
%$Id: gdm_check_tag_PRF.m 20289 2025-08-20 08:19:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_check_tag_PRF.m $
%
%

function in_plot_fig=gdm_check_tag_GRD(in_plot)

%% depending on tag

tag_check='GRD';
tag_old='fig_grid_01';

%% common

in_plot_fig=gdm_check_tag(in_plot,tag_old,tag_check);

end %function