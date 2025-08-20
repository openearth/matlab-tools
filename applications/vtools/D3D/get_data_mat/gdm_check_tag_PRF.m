%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20194 $
%$Date: 2025-06-13 09:30:18 +0200 (Fri, 13 Jun 2025) $
%$Author: chavarri $
%$Id: plot_all_runs_one_figure.m 20194 2025-06-13 07:30:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_all_runs_one_figure.m $
%
%

function in_plot_fig=gdm_check_tag_PRF(in_plot)

%% depending on tag

tag_check='PRF';
tag_old='fig_map_2DH_ls_01';

%% common

in_plot_fig=gdm_check_tag(in_plot,tag_old,tag_check);

end %function