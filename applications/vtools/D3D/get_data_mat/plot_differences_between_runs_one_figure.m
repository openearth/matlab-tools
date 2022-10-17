%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18361 $
%$Date: 2022-09-14 07:43:17 +0200 (Wed, 14 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18361 2022-09-14 05:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Plot differences between runs in one figure

function plot_differences_between_runs_one_figure(fid_log,in_plot,simdef_ref,simdef,leg_str)

str_fig='diff_all';

%% his sal 01
tag_check='fig_his_sal_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig',str_fig);
    in_plot_fig.leg_str=leg_str;
    plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef)
end

%% map 2DH ls
tag_check='fig_map_2DH_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig',str_fig);
    in_plot_fig.leg_str=leg_str;
    plot_map_2DH_ls_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
end

%% map 1D
tag_check='fig_map_1D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig',str_fig);
    in_plot_fig.leg_str=leg_str;
    plot_map_1D_xv_diff_01(fid_log,in_plot_fig,simdef_ref,simdef);
end

end %function 