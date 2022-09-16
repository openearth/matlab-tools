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
%Plot all runs in one figure

function plot_all_runs_one_figure(fid_log,in_plot,simdef,leg_str)

%% map_summerbed
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_1D_01(fid_log,in_plot_fig,simdef)
end

%% his xt
tag_check='fig_his_xt_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_his_xt_01(fid_log,in_plot_fig,simdef)
end
    
%% his sal 01
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_his_01(fid_log,in_plot_fig,simdef)
end

end %function