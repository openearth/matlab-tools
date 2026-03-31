%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 527 $
%$Date: 2025-11-11 16:15:38 +0100 (Tue, 11 Nov 2025) $
%$Author: ottevan $
%$Id: main_plot_01.m 527 2025-11-11 15:15:38Z ottevan $
%$HeadURL: file:///P:/11211565-002-maas-mor-2025/E_Software_Scripts/svn/57_plot_Lixhe_Roermond/main_plot_01.m $
%
%

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m'; %change path to your location

%% ADD OET

run(fpath_add_oet);

%% PATHS

addpath(fullfile(pwd,'../00_general'));

%% INPUT

%% simulations

ks=0;

ks=ks+1;
in_plot.fdir_sim{ks}='path to your simulation'; 
in_plot.str_sim{ks}='ACal=8.0';

in_plot.sim_ref=1;
in_plot.lan='en';
in_plot.tag_serie='01';

%%

tag='M2D';
in_plot.(tag).do=1;
in_plot.(tag).do_p_single=1;
in_plot.(tag).do_diff_t=1;
in_plot.(tag).do_diff_t_first_time=0; 
in_plot.(tag).do_diff_s=0;
in_plot.(tag).do_diff_s_t=0;
in_plot.(tag).do_s=0; %difference with reference
in_plot.(tag).var={'bl'};
in_plot.(tag).tim=NaN; %NaN = all times; Inf = last time
in_plot.(tag).tim_type=2; %1=flow; 2=morpho
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).do_movie=0; %
in_plot.(tag).do_axis_equal=1;

%%

D3D_plot(in_plot)


