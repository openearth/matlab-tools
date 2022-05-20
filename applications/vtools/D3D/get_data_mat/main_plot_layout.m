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

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT

ks=0;

ks=ks+1;
in_plot.fdir_sim{ks}=fullfile(fpaths.fdir_runs,'r030'); 
in_plot.str_sim{ks}='reference';

ks=ks+1;
in_plot.fdir_sim{ks}=fullfile(fpaths.fdir_runs,'r031'); 
in_plot.str_sim{ks}='scenario 1';

ks=ks+1;
in_plot.fdir_sim{ks}=fullfile(fpaths.fdir_runs,'r032'); 
in_plot.str_sim{ks}='scenario 2';

ks=ks+1;
in_plot.fdir_sim{ks}=fullfile(fpaths.fdir_runs,'r033'); 
in_plot.str_sim{ks}='scenario 3';

ks=ks+1;
in_plot.fdir_sim{ks}=fullfile(fpaths.fdir_runs,'r034'); 
in_plot.str_sim{ks}='scenario 4';

in_plot.sim_ref=1;
in_plot.lan='nl';

tag='fig_map_sal_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_sal_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).layer=NaN;
in_plot.(tag).clims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)]; %in [psu]
in_plot.(tag).clims_diff=[NaN,NaN;-sal2cl(-1,400),sal2cl(-1,400)]; %in [psu]
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).unit='cl_surf';  %sal, cl
in_plot.(tag).ldb_thk=0.1;  %sal, cl
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
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).unit='cl';  %sal, cl
in_plot.(tag).fig_plot_vel=0; %plot velocity vector
in_plot.(tag).ylims=[-10.1,0];
in_plot.(tag).fig_flip_section=1;
in_plot.(tag).fig_size=[0,0,14,9];

tag='fig_map_ls_02';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_ls_01';
in_plot.(tag).tim=NaN;
% in_plot.(tag).pli{1,1}=fullfile(fpaths.fdir_pli,'ls_grotesluis_EPSG-28992.pli');
% in_plot.(tag).pli{2,1}=fullfile(fpaths.fdir_pli,'ls_kleinesluis_EPSG-28992.pli');
in_plot.(tag).pli{1,1}=fullfile(fpaths.fdir_pli,'ls_KU_01.pli');
in_plot.(tag).clims_sal=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)];
in_plot.(tag).clims_us=[NaN,NaN;-0.25,0.25];
in_plot.(tag).clims_un=[NaN,NaN;-0.25,0.25];
in_plot.(tag).clims_uz=[NaN,NaN;-0.025,0.025];
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).unit='cl';  %sal, cl
in_plot.(tag).fig_plot_vel=0; %plot velocity vector
in_plot.(tag).ylims=[-10.1,0];
in_plot.(tag).fig_flip_section=1;
in_plot.(tag).fig_size=[0,0,14,21];

tag='fig_map_sal_mass_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_sal_mass_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).clims=[NaN,NaN;0,4]; %in [psu]
in_plot.(tag).clims_diff=[NaN,NaN;-4,4]; %in [psu]
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).unit='clm2';

tag='fig_map_q_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_q_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).clims_mag=[NaN,NaN;0,1]; %in [psu]
in_plot.(tag).clims_x=[NaN,NaN;-1,1]; %in [psu]
in_plot.(tag).clims_y=[NaN,NaN;-1,1]; %in [psu]
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).do_movie=0;
in_plot.(tag).ldb_thk=0.1;  %sal, cl
in_plot.(tag).fpath_ldb{1,1}=fullfile(fpaths.fdir_ldb,'lake_IJssel_ext.ldb');

tag='fig_his_sal_01';
in_plot.(tag).do=1;
in_plot.(tag).tag='his_sal_01';
in_plot.(tag).tim=NaN;
in_plot.(tag).stations=NaN;
in_plot.(tag).layer=NaN;
in_plot.(tag).ylims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)]; %in [psu]
in_plot.(tag).ylims_diff=[NaN,NaN;-sal2cl(-1,400),sal2cl(-1,400)]; %in [psu]
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).unit='cl_surf';  %sal, cl
in_plot.(tag).ldb_thk=0.1;  %sal, cl
in_plot.(tag).fpath_ldb{1,1}=fullfile(fpaths.fdir_ldb,'lake_IJssel_ext.ldb');

tag='fig_map_sal3D_01';
in_plot.(tag).do=0;
in_plot.(tag).tag='map_sal3D_01';
in_plot.(tag).tim=NaN;
% in_plot.(tag).tim=datetime(2018,06,05);
in_plot.(tag).pol{1,1}=fullfile(fpaths.fdir_pol,'KWZ_01_EPSG-28992.pol');
in_plot.(tag).isoval=sal2cl(-1,400);
in_plot.(tag).resx=10;
in_plot.(tag).resy=10;
in_plot.(tag).resz=0.5;
in_plot.(tag).maxz=0.5;
in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
in_plot.(tag).view=[60,70];
in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
in_plot.(tag).fig_overwrite=0; %overwrite figures
in_plot.(tag).overwrite=0; %overwrite mat-files
in_plot.(tag).do_movie=1;
in_plot.(tag).unit='cl';  %sal, cl
% in_plot.(tag).fpath_ldb{1,1}=fullfile(fpaths.fdir_ldb,'lake_IJssel_ext.ldb');


%%

D3D_gdm(in_plot)
