%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 13:43:41 +0200 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: main_plot.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/main_plot.m $
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

fpaths=paths_project(fpath_project); %generate the paths of the project folder depending whether it is the local folder or the one in the p-drive

%% INPUT

in_plot.fdir_sim{1}=fullfile(fpaths.fdir_runs,'r018');
in_plot.lan='nl';

in_plot.fig_map_sal_01.do=0;
in_plot.fig_map_sal_01.tim=NaN;
in_plot.fig_map_sal_01.layer=NaN;
in_plot.fig_map_sal_01.clims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)]; %in [psu]
in_plot.fig_map_sal_01.rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.fig_map_sal_01.fig_overwrite=1; 
in_plot.fig_map_sal_01.unit='cl';  %sal, cl

in_plot.fig_map_ls_01.do=1;
% in_plot.fig_map_ls_01.tim=[1,5];
in_plot.fig_map_ls_01.tim=NaN;
in_plot.fig_map_ls_01.pli{1,1}=fullfile(fpaths.fdir_pli,'ls_KU_01.pli');
in_plot.fig_map_ls_01.clims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)];
in_plot.fig_map_ls_01.rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.fig_map_ls_01.fig_overwrite=0;
in_plot.fig_map_ls_01.unit='cl';  %sal, cl
in_plot.fig_map_ls_01.fig_plot_vel=0; %plot velocity vector
in_plot.fig_map_ls_01.ylims=[-10.1,0];
in_plot.fig_map_ls_01.fig_flip_section=1;

in_plot.fig_map_sal_mass_01.do=0;
in_plot.fig_map_sal_mass_01.tag='map_sal_mass_01';
in_plot.fig_map_sal_mass_01.tim=NaN;
in_plot.fig_map_sal_mass_01.clims=[NaN,NaN;0,4]; %in [psu]
in_plot.fig_map_sal_mass_01.rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.fig_map_sal_mass_01.overwrite=0; 
in_plot.fig_map_sal_mass_01.fig_overwrite=0; 
% in_plot.fig_map_sal_mass_01.unit='cl';  %sal, cl

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
    
end %ks
