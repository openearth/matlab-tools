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
%

function gdm_STO_plot_SMB(fid_log,flg_loc,simdef)
    
nf=numel(gdm_read_dk(simdef)); %we cannot use the size of `qbk` because the loop may be skipped if files exist

in_plot.fdir_sim=flg_loc.fdir_sim;
in_plot.str_sim=flg_loc.str_sim;
in_plot.lan=flg_loc.lan;
in_plot.tag_serie=flg_loc.tag_serie;

tag='SMB'; %Note that `in_plot.(tag).tag='STO'`. Hence, this is the tag used for saving time variables and display.
in_plot.(tag)=flg_loc;
in_plot.(tag).do=1;

%% PLOTS

gdm_plot_single_time_area(in_plot,flg_loc.tim);
gdm_plot_single_time_line(in_plot,flg_loc.tim);
gdm_plot_single_time_line_val_sum_length(in_plot,flg_loc.tim);
gdm_plot_all_times_hydro(in_plot,flg_loc.tim);
gdm_plot_all_times_qbk_area(in_plot,flg_loc.tim,flg_loc.sedtrans_name,nf);
gdm_plot_all_times_cumQbk_area(in_plot,flg_loc.tim,flg_loc.sedtrans_name,nf);

end %function

%%

function gdm_plot_single_time_area(in_plot,tim)

%% INPUT

tag='SMB';
in_plot.(tag).do_p_single=1; %regular plot
in_plot.(tag).do_area=1; %x-variable with time in color
in_plot.(tag).do_diff_t=0; %difference initial time
in_plot.(tag).do_diff_s=0; %difference with reference
in_plot.(tag).do_diff_s_t=0; %difference reference simulation and initial time
in_plot.(tag).do_diff_s_perc=0; %difference reference simulation in percentage terms
in_plot.(tag).do_all_s=0; %all simulations in same figure
in_plot.(tag).do_all_s_diff_t=0; %all simulations in same figure, difference with time
in_plot.(tag).do_xvt=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_single=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_t=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_s=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_cel=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_tv=0; %x-axis -> time; y-axis -> variable; for a certain rkm specified in `rkm_plot_tv`% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).order_anl=2; %1=normal; 2=random
in_plot.(tag).tim_just_load=0; %if at the top script it is set to 1, we override it here to 0 to be able to plot only one time

in_plot.(tag).tim=tim(1); %one time of the analysis. Do not use integer here! The time vector does not make sense. 
in_plot.(tag).var={'Fak'}; 
in_plot.(tag).layer=1; %we want the first layer of `Fak` 
in_plot.(tag).ylims=[0,1]; %check this is the right input!

%% CALL
D3D_plot(in_plot)

end %function

%%

function gdm_plot_single_time_line(in_plot,tim)

%% INPUT

tag='SMB';
in_plot.(tag).do_p_single=1; %regular plot
in_plot.(tag).do_area=[0,0]; %x-variable with time in color
in_plot.(tag).do_diff_t=0; %difference initial time
in_plot.(tag).do_diff_s=0; %difference with reference
in_plot.(tag).do_diff_s_t=0; %difference reference simulation and initial time
in_plot.(tag).do_diff_s_perc=0; %difference reference simulation in percentage terms
in_plot.(tag).do_all_s=0; %all simulations in same figure
in_plot.(tag).do_all_s_diff_t=0; %all simulations in same figure, difference with time
in_plot.(tag).do_xvt=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_single=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_t=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_s=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_cel=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_tv=0; %x-axis -> time; y-axis -> variable; for a certain rkm specified in `rkm_plot_tv`% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).order_anl=2; %1=normal; 2=random
in_plot.(tag).tim_just_load=0; %if at the top script it is set to 1, we override it here to 0 to be able to plot only one time

in_plot.(tag).tim=tim(1); %one time of the analysis. Do not use integer here! The time vector does not make sense. 
in_plot.(tag).var={'Ltot','dg'}; %%`dg` needs to be available in output. If it is not, add in `gdm_read_data_map_simdef` the computation based on `lyrfrac` It would be nice to add `dg` but we need to make sure it is output in the morpho simulation

%% CALL
D3D_plot(in_plot)

end %function

function gdm_plot_single_time_line_val_sum_length(in_plot,tim)

%% INPUT

tag='SMB';
in_plot.(tag).do_p_single=1; %regular plot
in_plot.(tag).do_area=0; %x-variable with time in color
in_plot.(tag).do_diff_t=0; %difference initial time
in_plot.(tag).do_diff_s=0; %difference with reference
in_plot.(tag).do_diff_s_t=0; %difference reference simulation and initial time
in_plot.(tag).do_diff_s_perc=0; %difference reference simulation in percentage terms
in_plot.(tag).do_all_s=0; %all simulations in same figure
in_plot.(tag).do_all_s_diff_t=0; %all simulations in same figure, difference with time
in_plot.(tag).do_xvt=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_single=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_t=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_s=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_cel=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_tv=0; %x-axis -> time; y-axis -> variable; for a certain rkm specified in `rkm_plot_tv`% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).order_anl=2; %1=normal; 2=random
in_plot.(tag).statis_plot={'val_sum_length','val_mean'};
in_plot.(tag).tim_just_load=0; %if at the top script it is set to 1, we override it here to 0 to be able to plot only one time

in_plot.(tag).tim=tim(1); %one time of the analysis. Do not use integer here! The time vector does not make sense. 
in_plot.(tag).var={'ba_mor'}; 

%% CALL
D3D_plot(in_plot)

end %function

%%

function gdm_plot_all_times_hydro(in_plot,tim)

tag='SMB';
in_plot.(tag).do_p_single=0; %regular plot
in_plot.(tag).do_diff_t=0; %difference initial time
in_plot.(tag).do_diff_s=0; %difference with reference
in_plot.(tag).do_diff_s_t=0; %difference reference simulation and initial time
in_plot.(tag).do_diff_s_perc=0; %difference reference simulation in percentage terms
in_plot.(tag).do_all_s=0; %all simulations in same figure
in_plot.(tag).do_all_s_diff_t=0; %all simulations in same figure, difference with time
in_plot.(tag).do_xvt=1; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_single=1; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_t=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_s=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_cel=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_tv=0; %x-axis -> time; y-axis -> variable; for a certain rkm specified in `rkm_plot_tv`% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).order_anl=2; %1=normal; 2=random
in_plot.(tag).tim_just_load=0; %if at the top script it is set to 1, we override it here to 0 to be able to plot only one time
    
in_plot.(tag).tim=tim; %all times
in_plot.(tag).var={'umag','mesh2d_czs','h','Fr','ShieldsD'}; 

%% CALL
D3D_plot(in_plot)

end %function

%%

function gdm_plot_all_times_qbk_area(in_plot,tim,sedtrans_name,nf)

tag='SMB';
in_plot.(tag).do_p_single=1; %regular plot
in_plot.(tag).do_diff_t=0; %difference initial time
in_plot.(tag).do_diff_s=0; %difference with reference
in_plot.(tag).do_diff_s_t=0; %difference reference simulation and initial time
in_plot.(tag).do_diff_s_perc=0; %difference reference simulation in percentage terms
in_plot.(tag).do_all_s=0; %all simulations in same figure
in_plot.(tag).do_all_s_diff_t=0; %all simulations in same figure, difference with time
in_plot.(tag).do_xvt=1; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_single=1; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_t=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_s=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_cel=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_tv=0; %x-axis -> time; y-axis -> variable; for a certain rkm specified in `rkm_plot_tv`% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).order_anl=2; %1=normal; 2=random
in_plot.(tag).tim_just_load=0; %if at the top script it is set to 1, we override it here to 0 to be able to plot only one time

in_plot.(tag).tim=tim; %all times

nst=numel(sedtrans_name);

in_plot.(tag).var={};
in_plot.(tag).layer={};
in_plot.(tag).var_idx={};
in_plot.(tag).do_val_B_mor=[];
in_plot.(tag).var_2={};
in_plot.(tag).do_cum=[];
in_plot.(tag).do_area=[];

%% qbk: regular variable, no cumulative, no B_mor 

for kst=1:nst
    in_plot.(tag).var=cat(2,in_plot.(tag).var,sedtrans_name{kst}); 
    in_plot.(tag).layer=cat(2,in_plot.(tag).layer,{0});
    in_plot.(tag).var_idx=cat(2,in_plot.(tag).var_idx,{1:1:nf});
    in_plot.(tag).do_val_B_mor=cat(2,in_plot.(tag).do_val_B_mor,0);
    in_plot.(tag).var_2=cat(2,in_plot.(tag).var_2,{'stot'});
    in_plot.(tag).do_cum=cat(2,in_plot.(tag).do_cum,0);
    in_plot.(tag).do_area=cat(2,in_plot.(tag).do_area,1);
end

%% CALL

D3D_plot(in_plot);

end %function

function gdm_plot_all_times_cumQbk_area(in_plot,tim,sedtrans_name,nf)

tag='SMB';
in_plot.(tag).do_p_single=0; %regular plot
in_plot.(tag).do_diff_t=0; %difference initial time
in_plot.(tag).do_diff_s=0; %difference with reference
in_plot.(tag).do_diff_s_t=0; %difference reference simulation and initial time
in_plot.(tag).do_diff_s_perc=0; %difference reference simulation in percentage terms
in_plot.(tag).do_all_s=0; %all simulations in same figure
in_plot.(tag).do_all_s_diff_t=0; %all simulations in same figure, difference with time
in_plot.(tag).do_xvt=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_single=1; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_t=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_diff_s=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_xvt_cel=0; %x-axis -> x; y-axis-> variable; one line for each time
in_plot.(tag).do_tv=0; %x-axis -> time; y-axis -> variable; for a certain rkm specified in `rkm_plot_tv`% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).order_anl=2; %1=normal; 2=random
in_plot.(tag).statis_plot={'val_mean_weighted'}; %we need for cumulative, which strictly requires this variable. 
in_plot.(tag).tim_just_load=0; %if at the top script it is set to 1, we override it here to 0 to be able to plot only one time

in_plot.(tag).tim=tim; %all times

in_plot.(tag)=isfield_default(in_plot.(tag),'ylims_qb_B_mor_cum',[NaN,NaN]);
in_plot.(tag)=isfield_default(in_plot.(tag),'ylims',in_plot.(tag).ylims_qb_B_mor_cum);

nst=numel(sedtrans_name);

in_plot.(tag).var={};
in_plot.(tag).layer={};
in_plot.(tag).var_idx={};
in_plot.(tag).do_val_B_mor=[];
in_plot.(tag).var_2={};
in_plot.(tag).do_cum=[];
in_plot.(tag).do_area=[];

%% sum(Qbk): cumulative of product with width, cumulative, B_mor 

for kst=1:nst
    in_plot.(tag).var=cat(2,in_plot.(tag).var,sedtrans_name{kst}); 
    in_plot.(tag).layer=cat(2,in_plot.(tag).layer,{0});
    in_plot.(tag).var_idx=cat(2,in_plot.(tag).var_idx,{1:1:nf});
    in_plot.(tag).do_val_B_mor=cat(2,in_plot.(tag).do_val_B_mor,1);
    in_plot.(tag).var_2=cat(2,in_plot.(tag).var_2,{'stot'});
    in_plot.(tag).do_cum=cat(2,in_plot.(tag).do_cum,1);
    in_plot.(tag).do_area=cat(2,in_plot.(tag).do_area,1);
end

%% CALL

D3D_plot(in_plot);

end %function
