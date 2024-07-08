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

%%
%% CALLING 
%%

% %
% %Victor Chavarrias (victor.chavarrias@deltares.nl)
% %
% %$Revision$
% %$Date$
% %$Author$
% %$Id$
% %$HeadURL$
% %
% %Description
% 
% %% PREAMBLE
% 
% % dbclear all;
% clear
% clc
% fclose all;
% 
% %% PATHS
% 
% fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='c:\checkouts\qp\';
%
% % fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% % fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';
%
% % fpath_add_oet='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\';
% % fdir_d3d='p:\studenten-riv\05_OpenEarthTools\02_qp\';
%
% % fpath_project='d:\temporal\220517_improve_exner\';
% fpath_project='p:\11209261-rivierkunde-2023-morerijn';
% 
% %% ADD OET
%
% if isunix %we assume that if Linux we are in the p-drive. 
%     fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
% end
% run(fpath_add_oet);
% 
% %% PATHS
% 
% fpaths=paths_project(fpath_project);
% 
% %% simulation
% 
% ks=0;
% 
% ks=ks+1;
% in_plot.fdir_sim{ks}=fullfile(fpaths.fdir_sim_runs,'r002'); 
% in_plot.str_sim{ks}='reference';
% 
% in_plot.sim_ref=1;
% in_plot.lan='en';
% in_plot.tag_serie='01';
% in_plot.path_tiles='C:\checkouts\earth_tiles\';
% in_plot.path_tiles='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\earth_tiles';

%% display map times

% tag='disp_time_map';
% in_plot.(tag).do=1;

%% grid

% tag='fig_grid_01';
% in_plot.(tag).do=1;
% in_plot.(tag).fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
% in_plot.(tag).fig_visible=0;
% in_plot.(tag).axis_equal=1;
% in_plot.(tag).do_plot_along_rkm=1;
% in_plot.(tag).do_rkm_disp=1;
% in_plot.(tag).fpath_rkm_plot_along=fullfile(fpaths.dir_rkm,'rkm_5km.csv');
% in_plot.(tag).fpath_rkm_disp=fullfile(fpaths.dir_rkm,'rkm.csv');
% in_plot.(tag).rkm_tol_x=5000;
% in_plot.(tag).rkm_tol_y=5000;
% in_plot.(tag).plot_tiles=1;
% in_plot.(tag).plot_fxw=1; %plot fixed weirs (from input, not snapped)
% in_plot.(tag).pol{1,1}=fullfile(fpaths.fdir_pol,'summerbed.shp');

%% 2DH

% tag='fig_map_2DH_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).do_diff=1; %difference initial time
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).do_s_diff=1; %difference with reference and initial time
% in_plot.(tag).do_s_perc=0; %difference with reference in percentage terms
% in_plot.(tag).do_3D=0; %3D plot
% in_plot.(tag).var={'T_max','T_da','T_surf'}; %open D3D_list_of_variables
% % in_plot.(tag).layer=NaN; %NaN=top layer; Inf=first layer above bed; []=all
% in_plot.(tag).tim_type=2; %Type of input time: 1=flow; 2=morpho. 
% in_plot.(tag).tim_just_load=0;
% % in_plot.(tag).var_idx={1,1,1}; %index of a variable with several indices: {'T_max','T_da','T_surf'}.
% in_plot.(tag).tim=NaN; %all times
% in_plot.(tag).order_anl=2; %1=normal; 2=random
% in_plot.(tag).clims_type=1; %1=regular; 2=upper limit is number of days since <clims_type_var>
% % in_plot.(tag).clims_type_var=datenum(2018,07,01); %in case of <clims_type>=2
% in_plot.(tag).clims=[NaN,NaN;-6.0,4.5]; 
% in_plot.(tag).filter_lim.clims=[998,1000]; %
% in_plot.(tag).clims_diff_t=[NaN,NaN]; %clim of difference with time
% in_plot.(tag).clims_diff_s=[NaN,NaN]; %clim of difference with simulation
% in_plot.(tag).filter_lim.clims_diff_s=[-1001,-998]; %
% in_plot.(tag).do_movie=0; %
% in_plot.(tag).tim_movie=40; %movie duration [s]
% in_plot.(tag).fpath_ldb{1,1}=fullfile(fpath_project,'model','postprocessing','mkm-inner.ldb');
% in_plot.(tag).fpath_ldb{2,1}=fullfile(fpath_project,'model','postprocessing','mkm-outer.ldb');
% in_plot.(tag).fig_overwrite=1; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).do_vector=0; %add velocity vectors
% in_plot.(tag).do_axis_equal=0;
% in_plot.(tag).do_fxw=0; %plot snapped fixed weirs: 0=NO; 1=non-snapped; 2=snapped
% in_plot.(tag).do_plot_along_rkm=0;
% in_plot.(tag).do_rkm_disp=0;
% % in_plot.(tag).fpath_rkm_plot_along=fullfile(fpaths.dir_rkm,'rkm_5km.csv'); %file to go along specified rkm to plot
% % in_plot.(tag).fpath_rkm_disp=fullfile(fpaths.dir_rkm,'rkm.csv'); %file to display rkm
% in_plot.(tag).rkm_tol_x=5000;
% in_plot.(tag).rkm_tol_y=5000;
% in_plot.(tag).plot_tiles=1; %plot satellite background image
% % in_plot.(tag).fig_size=[0,0,37/2,15];
% % in_plot.(tag).font_size=20;

%% 2DH ls

% tag='fig_map_2DH_ls_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).do_diff=1; %difference with reference
% in_plot.(tag).do_all_t=0; %all times together
% in_plot.(tag).do_all_s=1; %all simulations in the same plot
% in_plot.(tag).var={'bl'}; 
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
% % in_plot.(tag).filter_lim=[0.992,1.1];
% in_plot.(tag).do_marker=1;
% in_plot.(tag).markersize=5;
% in_plot.(tag).do_staircase=1;
% in_plot.(tag).plot_val0=0; %plot initial

%% summerbed

%computes statistic values (mean, max, min, std) of a variables inside the summerbed 
%and inside a kilometre polygon. 

% tag='fig_map_summerbed_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_xvt=0;
% in_plot.(tag).do_diff=1; %difference with initial time
% in_plot.(tag).do_s=1; %difference with reference simulation
% in_plot.(tag).do_all=1; %all simulations in same figure
% in_plot.(tag).do_plot_structures=1; %plot bridge piles and structures: 0=NO; 1=YES
% in_plot.(tag).tim=NaN; %analysis time [datenum, datetime]. NaN=all, Inf=last.
% in_plot.(tag).tim_tol=hours(1); 
% % in_plot.(tag).tim=[datenum(2014,06,01),datenum(2015,06,01),datenum(2016,06,01),datenum(2017,06,01),datenum(2018,06,01)];
% in_plot.(tag).tim_type=2; %Type of input time: 1=flow; 2=morpho. 
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
% in_plot.(tag).fig_overwrite=0; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).do_movie=0;
% % in_plot.(tag).statis_plot={'val_mean'}; %statistics to plot. Comment to have all. 
% in_plot.(tag).var={'mesh2d_taus'}; % ,'mesh2d_dg'} %,14,27,'mesh2d_dg'}; % ,14,27,44,'mesh2d_dg',47}; %{1,14,27,44,'mesh2d_dg','mesh2d_DXX01','mesh2d_DXX06'}; %can be cell array vector. See <open D3D_list_of_variables> for possible input flags
%%plot of stacked sediment transport
% in_plot.(tag).var={'stot'}; % ,'mesh2d_dg'} %,14,27,'mesh2d_dg'}; % ,14,27,44,'mesh2d_dg',47}; %{1,14,27,44,'mesh2d_dg','mesh2d_DXX01','mesh2d_DXX06'}; %can be cell array vector. See <open D3D_list_of_variables> for possible input flags
% in_plot.(tag).var_idx={1:1:11}; %for 11 size fractions
% in_plot.(tag).do_area=1;
%%%
% in_plot.(tag).rkm={145:1:175}; %river km vectors to average the data; cell(1,nrkm)
% in_plot.(tag).rkm_name={'1km'}; %name of the river km vector (for saving); cell(1,nrkm)
%     %construct branches name
%     for kidx=1:numel(in_plot.(tag).rkm)
%         in_plot.(tag).rkm_br{kidx,1}=maas_branches(in_plot.(tag).rkm{kidx}); %branch name of each rkm point
%     end
% in_plot.(tag).xlims=[145,175]; %x limits for plotting [nxlims,2]
% in_plot.(tag).fpath_rkm=fullfile(fpaths.dir_rkm,'rkm.csv'); %river kilometer file. See format: open convert2rkm
% 
% %polygons and measurements associated to it
% 
% kp=0;
% 
% kp=kp+1;
% in_plot.(tag).sb_pol{kp,1}=fullfile(fpaths.dir_rkm,'L3R3.shp');
% in_plot.(tag).measurements{kp,1}=fullfile(fpaths.dir_data,'20220415_van_Arjan_1d_calibratie_parameters','L3R3_measured.mat'); 
%
% %time average
%
% %Computes the statistics (mean, max, min, std) for each statistic of a variable over a period of time. E.g., 
% %the std of the bed elevation between <t1> and <t2>.
%
% in_plot.(tag).overwrite_ave=1; %overwrite mat-files
% %Times taken to compute the statistics in time. [<t3>,<t4>] means e.g. that the mean is based on the results at <t3> and <t4>. 
% %For computing the mean based on all results between <t1> and <t2>, set these times in <tim> and set NaN in <tim_ave> (i.e., the time in <tim_ave> is the same as that in <tim>). 
% in_plot.(tag).tim_ave{1,1}=[datenum(2014,06,01),datenum(2015,06,01),datenum(2016,06,01),datenum(2017,06,01),datenum(2018,06,01)]; 
% in_plot.(tag).tim_ave_type=2; %1=flow; 2=morpho
% in_plot.(tag).tol_tim=30; %tolerance to match day in period with results

%% 1D map

% tag='fig_map_1D_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=0; %regular plot
% in_plot.(tag).do_xtv=1; %
% in_plot.(tag).do_diff=1; %regular plot
% in_plot.(tag).do_s=1; %difference with reference
% in_plot.(tag).var={'h'}; %<open main_plot_layout>
% in_plot.(tag).branch{1,1}={'Channel_1D_1'}; %<open main_plot_layout>
% in_plot.(tag).branch_name{1,1}='c1';
% in_plot.(tag).tim=NaN;
% in_plot.(tag).tim_type=1;
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random
% in_plot.(tag).xlims=[NaN,NaN];
% in_plot.(tag).ylims=[NaN,NaN];
% % in_plot.(tag).ylims=[NaN,NaN;-0.2e-3,1.2e-3];
% % in_plot.(tag).rat=3*24*3600; %[s] we want <rat> model seconds in each movie second
% in_plot.(tag).fig_overwrite=1; %overwrite figures
% in_plot.(tag).overwrite=1; %overwrite mat-files
% in_plot.(tag).do_movie=0; %
% % in_plot.(tag).ml=2.5;
% in_plot.(tag).plot_markers=1;

%% HIS

% tag='fig_his_01';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=0; %regular plot
% % in_plot.(tag).do_diff=1; %difference initial time
% in_plot.(tag).do_s=0; %difference with reference
% % in_plot.(tag).do_s_diff=1; %difference with reference and initial time
% in_plot.(tag).do_all=1; %all figures in same plot
% in_plot.(tag).tim=NaN; Time to plot. This is not [initial,final] but all the times to consider. E.g., [initial:delta_t:final].
% in_plot.(tag).stations=NaN; %NaN=all
% in_plot.(tag).var={'sal'};
% in_plot.(tag).layer=NaN; %NaN=top layer; Inf=first layer above bed; []=all; 
% in_plot.(tag).ylims=[NaN,NaN;sal2cl(-1,110),sal2cl(-1,400)]; %in [psu]
% in_plot.(tag).ylims_diff=[NaN,NaN;-sal2cl(-1,400),sal2cl(-1,400)]; %in [psu]
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
% in_plot.(tag).fig_overwrite=1; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).unit={'cl_surf'};  %sal, cl

%% sed trans offline

% tag='fig_map_sedtransoff_01';
% in_plot.(tag).do=1;
% % in_plot.(tag).do_2d=1;
% in_plot.(tag).do_sb=1; %do summerbed
% in_plot.(tag).do_sb_p=1; %plot summerbed
% in_plot.(tag).do_diff=0; 
% in_plot.(tag).smt_last_time=1;
% in_plot.(tag).do_all=1; %plot all simulations in same figure
% in_plot.(tag).tim=[datetime(2000,01,01,0,0,0,'timezone','+00:00'),datetime(2000,03,01,0,0,0,'timezone','+00:00'),datetime(2001,01,01,0,0,0,'timezone','+00:00')];
% in_plot.(tag).tim_type=1; %1=flow; 2=morpho
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random.
% in_plot.(tag).fig_overwrite=0; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% 
% %% sediment transport variations
% 
% kst=0;
% 
% kst=kst+1;
% in_plot.(tag).sedtrans_name{kst}='EH';
% in_plot.(tag).sedtrans{kst}=2;
% in_plot.(tag).sedtrans_param{kst,1}=[0.05,5];
% in_plot.(tag).sedtrans_hiding(kst,1)=0;
% in_plot.(tag).sedtrans_hiding_param(kst,1)=NaN;
% in_plot.(tag).sedtrans_mu(kst,1)=0;
% in_plot.(tag).sedtrans_mu_param(kst,1)=NaN;
% % in_plot.(tag).ylims_var{kst,1}=[NaN,NaN;0,1e-2;0,1e-1]; 
% % in_plot.(tag).ylims_var{kst,1}=[NaN,NaN]; 
% 
% kst=kst+1;
% in_plot.(tag).sedtrans_name{kst}='MPM01';
% in_plot.(tag).sedtrans{kst}=1;
% in_plot.(tag).sedtrans_param{kst,1}=[8,1.5,0.047];
% in_plot.(tag).sedtrans_hiding(kst,1)=1;
% in_plot.(tag).sedtrans_hiding_param(kst,1)=-0.8;
% in_plot.(tag).sedtrans_mu(kst,1)=0;
% in_plot.(tag).sedtrans_mu_param(kst,1)=NaN;
% % in_plot.(tag).ylims_var{kst,1}=[NaN,NaN;0,1e-2;0,1e-1]; 
% 
% kst=kst+1;
% in_plot.(tag).sedtrans_name{kst}='EHMPM01';
% in_plot.(tag).sedtrans{kst}=[2,1];
% in_plot.(tag).sedtrans_param{kst,1}{1}=[0.05,5];
% in_plot.(tag).sedtrans_param{kst,1}{2}=[8,1.5,0.047];
% in_plot.(tag).sedtrans_hiding(kst,1)=1;
% in_plot.(tag).sedtrans_hiding_param(kst,1)=-0.8;
% in_plot.(tag).sedtrans_mu(kst,1)=0;
% in_plot.(tag).sedtrans_mu_param(kst,1)=NaN;
% % in_plot.(tag).ylims_var{kst,1}=[NaN,NaN;0,1e-2;0,1e-1]; 
% 
% %% streamwise polygons
% 
% in_plot.(tag).statis_plot={'val_mean'}; %statistics to plot. Comment to have all.
% in_plot.(tag).rkm={872:1:957}; %river km vectors to average the data; cell(1,nrkm)
% in_plot.(tag).rkm_name={'1km'}; %river km vectors to average the data; cell(1,nrkm)
%     %construct branches name
%     for kidx=1:numel(in_plot.(tag).rkm)
%         in_plot.(tag).rkm_br{kidx,1}=branch_rijntakken(in_plot.(tag).rkm{kidx},'WA');
%     end
% in_plot.(tag).xlims=[872,957]; %x limits for plotting [nxlims,2]
% in_plot.(tag).fpath_rkm=fullfile(fpaths.fdir_rkm,'rkm_rijntakken_rhein.csv');
% 
% %% summerbed polygons
% kp=0;
% 
% kp=kp+1;
% in_plot.(tag).sb_pol{kp,1}=fullfile(fpaths.fdir_shp,'sb.shp');

%% cross-section along rkm and compute left-centre-right

% tag='fig_map_fraction_cs';
% in_plot.(tag).do=1;
% in_plot.(tag).do_p=1; %regular plot
% in_plot.(tag).var={'Q','qsp'}; 
% in_plot.(tag).tim=Inf;
% in_plot.(tag).tim_just_load=true;
% in_plot.(tag).tim_type=2;
% in_plot.(tag).order_anl=1; %time processing order: 1=serial, 2=random
% in_plot.(tag).tol_tim=1.1;
% in_plot.(tag).ylims=[NaN,NaN];
% in_plot.(tag).fig_overwrite=0; %overwrite figures
% in_plot.(tag).overwrite=0; %overwrite mat-files
% in_plot.(tag).fpath_sb=fullfile(fpaths.fdir_sb,'L3R3.shp');
% % in_plot.(tag).fpath_wb=fullfile(fpaths.fdir_wb,''); %if commented out, it uses model enclosure
% in_plot.(tag).fpath_rkm=fullfile(fpaths.fdir_rkm,'rkm_mod.csv'); %river kilometer file. See format: open convert2rkm
%     rkm_lim=rkm_limits('linne-roermond');
% in_plot.(tag).rkm=rkm_lim(1)+2:1:rkm_lim(2); %river km vectors to average the data; 
% in_plot.(tag).xy_input_type=2; %Maas
% in_plot.(tag).s_floodplain=9000;

%%

function D3D_gdm(in_plot)

%% DEFAULT

in_plot=create_mat_default_flags(in_plot);
fid_log=NaN;

simdef_all=NaN; %for passing to `gdm_adhoc`. 

if in_plot.only_adhoc==0

if ~isfield(in_plot,'fdir_sim')
    error('Specify the simulations to analyse <fdir_sim>')
end
ns=numel(in_plot.fdir_sim);

%% CREATE MAT-FILES

messageOut(fid_log,'Creating mat-files',3)

for ks=1:ns

    %% paths
    simdef=gdm_paths_single_run(fid_log,in_plot,ks);
    
    %% call
    create_mat_single_run(fid_log,in_plot,simdef);
    
end %ks

%%

%2DO Reworking
%Currently we first plot individual runs, then against a 
%reference and then together, all calling different runs. 
%This is idiotic. Here we have to prepare <simdef_ref> and 
%<simdef> as structure having all simulations. Then, each
%independent plotting function plots each run individually
%and compared to a reference. See <plot_1D_01>.
%An improvement to <plot_1D_01> is not to pass <simdef_ref>
%but to get it withing the function. Consider it at least. 

%% PLOT INDIVIDUAL RUNS

messageOut(fid_log,'Plotting individual runs',3)

for ks=1:ns
    
    %% paths
    simdef=gdm_paths_single_run(fid_log,in_plot,ks);
    
    %% call
    plot_individual_runs(fid_log,in_plot,simdef);
    
end %ks

%% PLOT DIFFERENCES WITH REFERENCE

if isfield(in_plot,'sim_ref') && ~isnan(in_plot.sim_ref) && ns>1

    %% reference paths
    ks_ref=in_plot.sim_ref;
    simdef_ref=gdm_paths_single_run(fid_log,in_plot,ks_ref,'disp',0);

    %% PLOT DIFFERENCES BETWEEN RUNS

    messageOut(fid_log,'Plotting differences between runs',3)

    for ks=1:ns

        if ks==ks_ref; continue; end

        %% paths
        simdef=gdm_paths_single_run(fid_log,in_plot,ks);

        %% call
        plot_differences_between_runs(fid_log,in_plot,simdef_ref,simdef)

    end %ks

    %% PLOT DIFFERENCES BETWEEN RUNS IN ONE FIGURE

    messageOut(fid_log,'Plotting differences between runs in one figure',3)

    %% paths no ref
    ksc=0;
    for ks=1:ns
        if ks==ks_ref; continue; end
        ksc=ksc+1;
        [simdef_no_ref(ksc),leg_str_no_ref{ksc}]=gdm_paths_single_run(fid_log,in_plot,ks,'disp',0);
    end
    
    %% call
    plot_differences_between_runs_one_figure(fid_log,in_plot,simdef_ref,simdef_no_ref,leg_str_no_ref)

end %reference run 

%% PLOT ALL RUNS IN ONE FIGURE

if ns>1
    
    messageOut(fid_log,'Plotting all runs in one figure-',3)

    %% paths all
    simdef_all=struct('D3D',NaN,'err',NaN,'file',NaN);
    for ks=1:ns
        [simdef_all(ks),leg_str_all{ks}]=gdm_paths_single_run(fid_log,in_plot,ks,'disp',0);
    end

    %% call
    plot_all_runs_one_figure(fid_log,in_plot,simdef_all,leg_str_all)
    
end %ns>1

%% AD-HOC

end %only_adhoc

gdm_adhoc(fid_log,in_plot,simdef_all)

%% END

messageOut(fid_log,'Done!!!',3);

end %function