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
    create_mat_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
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
    plot_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
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
    
end %ks

%% differences plot

messageOut(fid_log,'---Plotting differences between runs')

%reference paths
ks_ref=in_plot.sim_ref;
fdir_sim=in_plot.fdir_sim{ks_ref};
simdef_ref=simulation_paths(fdir_sim,in_plot);

for ks=1:ns
    
    if ks==ks_ref; continue; end
    
    %% paths
    fdir_sim=in_plot.fdir_sim{ks};
    simdef=simulation_paths(fdir_sim,in_plot);
    messageOut(fid_log,sprintf('Simulation %s',simdef.file.runid))
    
    %% map_sal_01
    if isfield(in_plot,'fig_map_sal_01')==1
    plot_map_sal_diff_01(fid_log,in_plot.fig_map_sal_01,simdef_ref,simdef)
    end
    
    %% sal mass  
    if isfield(in_plot,'fig_map_sal_mass_01')==1
    plot_map_sal_diff_01(fid_log,in_plot.fig_map_sal_mass_01,simdef_ref,simdef)
    end
    
    %% his sal 01
    if isfield(in_plot,'fig_his_sal_01')==1
    plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef)
    end
    
end

end %function