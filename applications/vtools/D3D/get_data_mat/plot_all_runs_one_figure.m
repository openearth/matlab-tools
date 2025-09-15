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

nsim=numel(simdef);

%% map_summerbed
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    % in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
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
%     in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
%     plot_his_xt_01(fid_log,in_plot_fig,simdef)
% end
    
%% HIS
in_plot_fig=gdm_check_tag_HIS(in_plot);
if in_plot_fig.do
    in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
    gdm_plot_HIS(fid_log,in_plot_fig,simdef)
end

%% map 2DH his
tag_check='fig_map_2DH_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
    gdm_plot_HIS(fid_log,in_plot_fig,simdef)
end

%% map 1D
in_plot_fig=gdm_check_tag_M1D(in_plot);
if in_plot_fig.do
    in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
    gdm_plot_M1D(fid_log,in_plot_fig,simdef)
end

%% PRF
in_plot_fig=gdm_check_tag_PRF(in_plot);
if in_plot_fig.do
    in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
    gdm_plot_PRF(fid_log,in_plot_fig,simdef)
end

%% map 2DH
tag_check='fig_map_2DH_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    in_plot_fig=gdm_add_legend(in_plot_fig,leg_str);
    plot_map_2DH_02(fid_log,in_plot_fig,simdef)

    for ksim=1:nsim
        plot_map_2DH_cum_01(fid_log,in_plot_fig,simdef(ksim))
        plot_map_2DH_Fourier2D(fid_log,in_plot_fig,simdef(ksim))
    end

end

%% grid
tag_check='fig_grid_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);

    for ksim=1:nsim
        plot_grid_01(fid_log,in_plot_fig,simdef(ksim))
    end
end

%% his sal meteo
tag_check='fig_his_sal_meteo_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    for ksim=1:nsim
        plot_his_sal_meteo_01(fid_log,in_plot_fig,simdef(ksim))
    end
end

%% observation stations
tag_check='fig_his_obs_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    for ksim=1:nsim
        plot_his_obs_01(fid_log,in_plot_fig,simdef(ksim))
    end
end

%% fraction in left, centre, right of the channel
tag_check='fig_map_fraction_cs';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    for ksim=1:nsim
        plot_map_fraction_cs_01(fid_log,in_plot_fig,simdef(ksim))
    end
end

end %function

%%
%% FUNCTIONS
%%

function in_plot_fig=gdm_add_legend(in_plot_fig,leg_str)

in_plot_fig=isfield_default(in_plot_fig,'leg_str',leg_str);

end