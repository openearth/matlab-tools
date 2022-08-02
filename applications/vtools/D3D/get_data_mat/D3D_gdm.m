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
%variables: open D3D_list_of_variables

%% 2DH

% tag='fig_map_2DH_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).do_diff=0; 
% in_plot.(tag).var={'T_max','T_da','T_surf'}; %open D3D_list_of_variables
% in_plot.(tag).layer=NaN; %NaN=top layer
% % in_plot.(tag).var_idx={1,1,1}; %index of a variable with several indices: {'T_max','T_da','T_surf'}.
% in_plot.(tag).tim=NaN; %all times
% in_plot.(tag).order_anl=2; %1=normal; 2=random
% in_plot.(tag).clims_type=1; %1=regular; 2=upper limit is number of days since <clims_type_var>
% % in_plot.(tag).clims_type_var=datenum(2018,07,01); %in case of <clims_type>=2
% in_plot.(tag).clims=[NaN,NaN]; 
% in_plot.(tag).clims_diff_t=[NaN,NaN]; %clim of difference with time
% in_plot.(tag).clims_diff_s=[NaN,NaN]; %clim of difference with simulation
% in_plot.(tag).do_movie=0; %
% in_plot.(tag).tim_movie=40; %movie duration [s]
% in_plot.(tag).fpath_ldb{1,1}=fullfile(fpath_project,'model','postprocessing','mkm-inner.ldb');
% in_plot.(tag).fpath_ldb{2,1}=fullfile(fpath_project,'model','postprocessing','mkm-outer.ldb');
% in_plot.(tag).fig_overwrite=1; %overwrite figures
% in_plot.(tag).overwrite=1; %overwrite mat-files

%% 2DH ls

% tag='fig_map_2DH_ls_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).var={'bl'}; %<open main_plot_layout>
% in_plot.(tag).tim=NaN;
% in_plot.(tag).tim_type=2;
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random
% in_plot.(tag).tol_tim=1.1;
% in_plot.(tag).fig_size=[0,0,16,9].*2;
% in_plot.(tag).pli{1,1}=fullfile(fpaths.fdir_pli,'y500.pli');
% in_plot.(tag).ylims=[NaN,NaN;-0.2e-3,1.2e-3];
% in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
% in_plot.(tag).fig_overwrite=0; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).do_movie=0; %
% in_plot.(tag).ml=2.5;
% in_plot.(tag).plot_markers=1;

function D3D_gdm(in_plot)

%% CREATE MAT-FILES

in_plot=create_mat_default_flags(in_plot);
fid_log=NaN;

%loop on simulations
ns=numel(in_plot.fdir_sim);

%% LOOP
messageOut(fid_log,'---Creating mat-files')
for ks=1:ns
    
    %% paths
    fdir_sim=in_plot.fdir_sim{ks};
    simdef=simulation_paths(fdir_sim,in_plot);
    messageOut(fid_log,sprintf('Simulation: %s',simdef.file.runid))	
        
    %% sal
    if isfield(in_plot,'fig_map_sal_01')==1
        create_mat_map_sal_01(fid_log,in_plot.fig_map_sal_01,simdef)
    end
    
    %% ls 
    if isfield(in_plot,'fig_map_ls_01')==1
        create_mat_map_ls_01(fid_log,in_plot.fig_map_ls_01,simdef)
    end
    
    %% sal mass
    if isfield(in_plot,'fig_map_sal_mass_01')==1
        messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <clm2>')
%         create_mat_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
%         create_mat_map_sal_mass_cum_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
    end
    
    %% q
    if isfield(in_plot,'fig_map_q_01')==1
        create_mat_map_q_01(fid_log,in_plot.fig_map_q_01,simdef)
    end
    
    %% his sal
    if isfield(in_plot,'fig_his_sal_01')==1
        create_mat_his_sal_01(fid_log,in_plot.fig_his_sal_01,simdef)
    end
    
    %% sal 3D
    if isfield(in_plot,'fig_map_sal3D_01')==1
        create_mat_map_sal3D_01(fid_log,in_plot.fig_map_sal3D_01,simdef)
    end
    
    %% map summerbed
    if isfield(in_plot,'fig_map_summerbed_01')==1
        create_mat_map_summerbed_01(fid_log,in_plot.fig_map_summerbed_01,simdef)
        pp_sb_var_01(fid_log,in_plot.fig_map_summerbed_01,simdef)
            if isfield(in_plot.fig_map_summerbed_01,'tim_ave')
                pp_sb_tim_ave_01(fid_log,in_plot.fig_map_summerbed_01,simdef)
            end
    end
    
    %% map 2DH
    if isfield(in_plot,'fig_map_2DH_01')==1
        in_plot.fig_map_2DH_01.tag='map_2DH_01';
        create_mat_map_2DH_01(fid_log,in_plot.fig_map_2DH_01,simdef)
        pp_mat_map_2DH_cum_01(fid_log,in_plot.fig_map_2DH_01,simdef) %compute integrated amount over surface with time       
    end
    
    %% map 2DH ls
    if isfield(in_plot,'fig_map_2DH_ls_01')==1
        in_plot.fig_map_2DH_ls_01.tag='map_2DH_ls_01';
        create_mat_map_2DH_ls_01(fid_log,in_plot.fig_map_2DH_ls_01,simdef)
    end
    
    %% his sal meteo
    if isfield(in_plot,'fig_his_sal_meteo_01')==1
        create_mat_his_sal_meteo_01(fid_log,in_plot.fig_his_sal_meteo_01,simdef)
    end
    
    %% observation stations
    if isfield(in_plot,'fig_his_obs_01')==1
        in_plot.fig_his_obs_01.tag='his_obs_01';
        create_mat_his_obs_01(fid_log,in_plot.fig_his_obs_01,simdef)
    end
    
end %ks


%% PLOT

%% individual runs

messageOut(fid_log,'---Plotting individual runs')
for ks=1:ns
    
    %% paths
    fdir_sim=in_plot.fdir_sim{ks};
    simdef=simulation_paths(fdir_sim,in_plot);
    messageOut(fid_log,sprintf('Simulation: %s',simdef.file.runid))
    
    %% map_sal_01
    if isfield(in_plot,'fig_map_sal_01')==1
        plot_map_sal_01(fid_log,in_plot.fig_map_sal_01,simdef)
    end
    
    %% map_ls_01
    if isfield(in_plot,'fig_map_ls_01')==1
        plot_map_ls_01(fid_log,in_plot.fig_map_ls_01,simdef)
    end
    
    %% map_ls_02
    if isfield(in_plot,'fig_map_ls_02')==1
        plot_map_ls_02(fid_log,in_plot.fig_map_ls_02,simdef)
    end
    
    %% sal mass
    if isfield(in_plot,'fig_map_sal_mass_01')==1
%         plot_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
        
%         in_plot_loc=in_plot.fig_map_sal_mass_01;
%         in_plot_loc.tag=strcat(in_plot.fig_map_sal_mass_01.tag,'_cum');
%         in_plot_loc.tag_tim=in_plot.fig_map_sal_mass_01.tag;
% 
%         plot_tim_y(fid_log,in_plot_loc,simdef)
    end
    
    %% q
    if isfield(in_plot,'fig_map_q_01')==1
        plot_map_q_01(fid_log,in_plot.fig_map_q_01,simdef)
    end
    
    %% his sal 01
    if isfield(in_plot,'fig_his_sal_01')==1
        plot_his_sal_01(fid_log,in_plot.fig_his_sal_01,simdef)
    end
    
    %% sal 3D
    if isfield(in_plot,'fig_map_sal3D_01')==1
        plot_map_sal3D_01(fid_log,in_plot.fig_map_sal3D_01,simdef)
    end
    
    %% map_summerbed
    if isfield(in_plot,'fig_map_summerbed_01')==1
        plot_1D_01(fid_log,in_plot.fig_map_summerbed_01,simdef)
        if isfield(in_plot.fig_map_summerbed_01,'sb_pol_diff')
            plot_1D_sb_diff_01(fid_log,in_plot.fig_map_summerbed_01,simdef)
        end
        if isfield(in_plot.fig_map_summerbed_01,'tim_ave')
            in_plot_loc=in_plot.fig_map_summerbed_01;
            in_plot_loc.tag_fig=sprintf('%s_tim_ave',in_plot_loc.tag);
            plot_1D_tim_ave_01(fid_log,in_plot_loc,simdef)
        end
    end
    
    %% map 2DH
    if isfield(in_plot,'fig_map_2DH_01')==1
        plot_map_2DH_01(fid_log,in_plot.fig_map_2DH_01,simdef)
        plot_map_2DH_cum_01(fid_log,in_plot.fig_map_2DH_01,simdef)
    end
    
    %% map 2DH ls
    if isfield(in_plot,'fig_map_2DH_ls_01')==1
        plot_map_2DH_ls_01(fid_log,in_plot.fig_map_2DH_ls_01,simdef)
    end
    
    %% his sal meteo
    if isfield(in_plot,'fig_his_sal_meteo_01')==1
        plot_his_sal_meteo_01(fid_log,in_plot.fig_his_sal_meteo_01,simdef)
    end
    
    %% observation stations
    if isfield(in_plot,'fig_his_obs_01')==1
        plot_his_obs_01(fid_log,in_plot.fig_his_obs_01,simdef)
    end
    
end %ks

%% differences plot

if isfield(in_plot,'sim_ref') && ~isnan(in_plot.sim_ref)

    messageOut(fid_log,'---Plotting differences between runs')

    %reference paths
    ks_ref=in_plot.sim_ref;
    fdir_sim=in_plot.fdir_sim{ks_ref};
    simdef_ref=simulation_paths(fdir_sim,in_plot);
    
    %%
    for ks=1:ns

        if ks==ks_ref; continue; end

        %% paths
        fdir_sim=in_plot.fdir_sim{ks};
        simdef=simulation_paths(fdir_sim,in_plot);
        messageOut(fid_log,sprintf('Simulation %s',simdef.file.runid))

        %% map_sal_01
        if isfield(in_plot,'fig_map_sal_01')==1
            in_plot_loc=in_plot_loc.fig_map_sal_01;
            in_plot_loc.tag_fig=sprintf('%s_diff',in_plot_loc.tag);
            plot_map_sal_diff_01(fid_log,in_plot_loc,simdef_ref,simdef)
        end

        %% sal mass  
        if isfield(in_plot,'fig_map_sal_mass_01')==1
            plot_map_sal_diff_01(fid_log,in_plot.fig_map_sal_mass_01,simdef_ref,simdef)
        end

        %% his sal 01
        if isfield(in_plot,'fig_his_sal_01')==1
            in_plot.fig_his_sal_01.tag_fig=sprintf('%s_diff',in_plot.fig_his_sal_01.tag);
            plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef)
        end

        %% map 2DH
        if isfield(in_plot,'fig_map_2DH_01')==1
            in_plot.fig_map_2DH_01.tag_fig=sprintf('%s_diff',in_plot.fig_map_2DH_01.tag);
            plot_map_2DH_diff_01(fid_log,in_plot.fig_map_2DH_01,simdef_ref,simdef)
        end
        
        %% map 2DH ls
        if isfield(in_plot,'fig_map_2DH_ls_01')==1
            in_plot.fig_map_2DH_ls_01.tag_fig=sprintf('%s_diff',in_plot.fig_map_2DH_ls_01.tag);
            plot_map_2DH_ls_diff_01(fid_log,in_plot.fig_map_2DH_ls_01,simdef_ref,simdef)
        end
    end

    %% differences plot all in one

    messageOut(fid_log,'---Plotting differences between runs in one plot')

    ksc=0;
    for ks=1:ns

        if ks==ks_ref; continue; end
        ksc=ksc+1;
        
        %paths
        fdir_sim=in_plot.fdir_sim{ks};
        simdef_all(ksc)=simulation_paths(fdir_sim,in_plot); %2DO change name to all but no ref
        leg_str{ksc}=in_plot.str_sim{ks};
    end

    %% his sal 01
    if isfield(in_plot,'fig_his_sal_01')==1 && ~isempty(simdef_all)
        in_plot.fig_his_sal_01.tag_fig='his_sal_diff_all_01';
        in_plot.fig_his_sal_01.leg_str=leg_str;
        plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef_all)
    end

    %% map 2DH ls
    if isfield(in_plot,'fig_map_2DH_ls_01')==1
        in_plot.fig_map_2DH_ls_01.tag_fig=sprintf('%s_diff_all',in_plot.fig_map_2DH_ls_01.tag);
        in_plot.fig_map_2DH_ls_01.leg_str=leg_str;
        plot_map_2DH_ls_diff_01(fid_log,in_plot.fig_map_2DH_ls_01,simdef_ref,simdef_all)
    end
        
end %reference run 

%% plot all runs in same figure

messageOut(fid_log,'---Plotting all runs in one figure')

for ks=1:ns

    %paths
    fdir_sim=in_plot.fdir_sim{ks};
    simdef_all_2(ks)=simulation_paths(fdir_sim,in_plot); %2DO change name to all
    leg_str_all_2{ks}=in_plot.str_sim{ks};
end

%% map_summerbed
if isfield(in_plot,'fig_map_summerbed_01')==1
    in_plot.fig_map_summerbed_01.tag_fig=sprintf('%s_all',in_plot.fig_map_summerbed_01.tag);
    in_plot.fig_map_summerbed_01.leg_str=leg_str_all_2;
    plot_1D_01(fid_log,in_plot.fig_map_summerbed_01,simdef_all_2)
end


end %function