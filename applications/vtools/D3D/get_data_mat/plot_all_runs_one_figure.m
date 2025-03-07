%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Plot all runs in one figure

function plot_all_runs_one_figure(fid_log,in_plot,simdef,leg_str)

%% map_summerbed
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    % in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig.leg_str=leg_str;
    plot_summerbed(fid_log,in_plot_fig,simdef)
    if isfield(in_plot_fig,'tim_ave')
        error('The code below needs to be make to work. It used to be called when only one `simdef` was called in `plot_individual_runs`')
        if ~isempty(in_plot_fig.tim_ave{1,1}) 
            in_plot_fig.tag_fig=sprintf('%s_tim_ave',in_plot_fig.tag);
            plot_1D_tim_ave_01(fid_log,in_plot_fig,simdef)
        end
    end
end

%% his xt
%This functionality is moved to `fig_his_01` with `do_xt=1`
% tag_check='fig_his_xt_01';
% if isfield(in_plot,tag_check)==1
%     in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
%     in_plot_fig.leg_str=leg_str;
%     plot_his_xt_01(fid_log,in_plot_fig,simdef)
% end
    
%% his sal 01
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
%     in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig.leg_str=leg_str;
    plot_his_01(fid_log,in_plot_fig,simdef)
end

%% map 2DH his
tag_check='fig_map_2DH_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig.leg_str=leg_str;
    plot_his_01(fid_log,in_plot_fig,simdef)
end

%% map 1D
tag_check='fig_map_1D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig.leg_str=leg_str;
    plot_map_1D_xv_01(fid_log,in_plot_fig,simdef)
end

%% map 2DH ls
tag_check='fig_map_2DH_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_map_2DH_ls_01(fid_log,in_plot_fig,simdef)
end

%% map 2DH
tag_check='fig_map_2DH_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig.leg_str=leg_str;
    plot_map_2DH_02(fid_log,in_plot_fig,simdef)
end

end %function