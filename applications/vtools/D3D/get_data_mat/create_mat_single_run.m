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
%Create mat-files of a single run

function create_mat_single_run(fid_log,in_plot,simdef)

%% DSP (display time)
tag_check='disp_time_map';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    disp_time_map(fid_log,in_plot_fig,simdef);
end

%% GRD (grid)
tag_check='fig_grid_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_grid_01(fid_log,in_plot_fig,simdef);
end


%% HIS (history)
in_plot_fig=gdm_check_tag_HIS(in_plot);
if in_plot_fig.do
    gdm_create_mat_HIS(fid_log,in_plot_fig,simdef)
end

%% SMB (summerbed)
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    gdm_create_mat_summerbed(fid_log,in_plot_fig,simdef)
    pp_sb_var_01(fid_log,in_plot_fig,simdef)
    if isfield(in_plot_fig,'sb_pol_diff')
        create_mat_map_summerbed_diff(fid_log,in_plot_fig,simdef)
    end
    if isfield(in_plot_fig,'tim_ave')
        if ~isempty(in_plot_fig.tim_ave{1,1}) 
           pp_sb_tim_ave_01(fid_log,in_plot_fig,simdef)
        end
    end
%     pp_sb_var_cum_01(fid_log,in_plot_fig,simdef) %not really needed. We are already loading all the data in the plot part for the xtv plot
end

%% M2D (map 2D)
tag_check='fig_map_2DH_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_2DH_01(fid_log,in_plot_fig,simdef)
    pp_mat_map_2DH_cum_01(fid_log,in_plot_fig,simdef) %compute integrated amount over surface with time    
    pp_mat_map_2DH_Fourier2D(fid_log,in_plot_fig,simdef) 
end

%% HFM (history data from map data)
tag_check='fig_map_2DH_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_2DH_his_01(fid_log,in_plot_fig,simdef)
%     in_plot_fig=gmd_tag(in_plot,'fig_map_2DH_01'); %use the same output as for map_2DH 
%     create_mat_map_2DH_01(fid_log,in_plot_fig,simdef) %create map_2DH mat-files
%     pp_mat_map_2DH_his_01(fid_log,in_plot_fig,simdef) %postporcess to get his-style data
end

%% PRF (profile) 
in_plot_fig=gdm_check_tag_PRF(in_plot);
if in_plot_fig.do
    create_mat_map_2DH_ls_01(fid_log,in_plot_fig,simdef)
end

%% OBS (observation stations)
tag_check='fig_his_obs_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_his_obs_01(fid_log,in_plot_fig,simdef)
end

%% M1D (map 1D)
in_plot_fig=gdm_check_tag_M1D(in_plot);
if in_plot_fig.do
    gdm_create_mat_M1D(fid_log,in_plot_fig,simdef)
end

%% STO (sediment transport offline)
tag_check='fig_map_sedtransoff_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_sedtransoff_01(fid_log,in_plot_fig,simdef)
end

%% FCS (fraction right, centre, left in cross-section)
tag_check='fig_map_fraction_cs';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_fraction_cs_01(fid_log,in_plot_fig,simdef)
end

%% sal 3D (3D surface of constant salinity. This is different than a 3D view of a 2D such as bed level)
tag_check='fig_map_sal3D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_sal3D_01(fid_log,in_plot_fig,simdef)
end

%% his sal meteo
tag_check='fig_his_sal_meteo_01';
if isfield(in_plot,tag_check)==1
    warning('unclear what this does')
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_his_sal_meteo_01(fid_log,in_plot_fig,simdef)
end

%%
%% OUTDATED
%%

%% sal
tag_check='fig_map_sal_01';
if isfield(in_plot,tag_check)==1
    error('Outdated?')
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_sal_01(fid_log,in_plot_fig,simdef)
end

%% ls 
tag_check='fig_map_ls_01';
if isfield(in_plot,tag_check)==1
    error('Outdated?')
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_ls_01(fid_log,in_plot_fig,simdef)
end

%% sal mass
if isfield(in_plot,'fig_map_sal_mass_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <clm2>')
%         create_mat_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
%         create_mat_map_sal_mass_cum_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
end

%% q
tag_check='fig_map_q_01';
if isfield(in_plot,tag_check)==1
    error('Outdated?')
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_q_01(fid_log,in_plot_fig,simdef)
end

%% his sal
if isfield(in_plot,'fig_his_sal_01')==1
    warning('deprecate and call <his_01>')
%         create_mat_his_sal_01(fid_log,in_plot.fig_his_sal_01,simdef)
end

%% his xt
tag_check='fig_his_xt_01';
if isfield(in_plot,tag_check)==1
    error('This is now done by calling `fig_his_01` with flag `do_xt=1`')
%     in_plot_fig=gmd_tag(in_plot,tag_check);
%     create_mat_his_xt_01(fid_log,in_plot_fig,simdef)
end

end %function

%%
%% FUNCTIONS
%%

