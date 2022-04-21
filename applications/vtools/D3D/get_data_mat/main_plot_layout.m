%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Plot results IJsselmeer 3D

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% fpath_project='d:\temporal\220217_ijsselmeer\';

% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
fpath_project='P:\11208075-002-ijsselmeer\';

%% ADD OET

addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT

in_plot.fdir_sim{1}=fullfile(fpaths.fdir_runs,'r016');
in_plot.lan='nl';

tag='fig_map_sal_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_sal_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).layer=NaN;
in_plot.(tag).clims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)]; %in [psu]
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).fig_overwrite=1; 
in_plot.(tag).unit='cl_surf';  %sal, cl
in_plot.(tag).fpath_ldb{1,1}=fullfile(fpaths.fdir_ldb,'lake_IJssel_ext.ldb');

tag='fig_map_ls_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_ls_01';
in_plot.(tag).tim=NaN;
% in_plot.(tag).pli{1,1}=fullfile(fpaths.fdir_pli,'ls_grotesluis_EPSG-28992.pli');
% in_plot.(tag).pli{2,1}=fullfile(fpaths.fdir_pli,'ls_kleinesluis_EPSG-28992.pli');
in_plot.(tag).pli{1,1}=fullfile(fpaths.fdir_pli,'ls_KU_01.pli');
in_plot.(tag).clims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)];
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).fig_overwrite=1;
in_plot.(tag).unit='cl';  %sal, cl
in_plot.(tag).fig_plot_vel=0; %plot velocity vector
in_plot.(tag).ylims=[-10.1,0];
in_plot.(tag).fig_flip_section=1;
in_plot.(tag).fig_size=[0,0,14,9];
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.

tag='fig_map_sal_mass_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_sal_mass_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).clims=[NaN,NaN;0,4]; %in [psu]
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).overwrite=0; 
in_plot.(tag).fig_overwrite=0; 
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.

tag='fig_map_q_01';
in_plot.(tag).do=1;
in_plot.(tag).tag='map_q_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).clims=[NaN,NaN;0,10]; %in [psu]
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).overwrite=0; 
in_plot.(tag).fig_overwrite=0; 
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).do_movie=0;
in_plot.(tag).fpath_ldb{1,1}=fullfile(fpaths.fdir_ldb,'lake_IJssel_ext.ldb');

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
    
    %% grid
	create_mat_grd(fid_log,in_plot,simdef)
        
    %% sal
    create_mat_map_sal_01(fid_log,in_plot.fig_map_sal_01,simdef)
    
    %% ls 
    create_mat_map_ls_01(fid_log,in_plot.fig_map_ls_01,simdef)
    
    %% sal mass
    create_mat_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
    
    %% q
    create_mat_map_q_01(fid_log,in_plot.fig_map_q_01,simdef)
end %ks


%% PLOT

%% individual runs

messageOut(fid_log,'---Plotting')
for ks=1:ns
    
    %% paths
    fdir_sim=in_plot.fdir_sim{ks};
    simdef=simulation_paths(fdir_sim,in_plot);
    
    %% map_sal_01
    plot_map_sal_01(fid_log,in_plot.fig_map_sal_01,simdef)

    %% map_ls_01
    plot_map_ls_01(fid_log,in_plot.fig_map_ls_01,simdef)
    
    %% sal mass
    plot_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
    
    %% q
    plot_map_q_01(fid_log,in_plot.fig_map_q_01,simdef)
end %ks
