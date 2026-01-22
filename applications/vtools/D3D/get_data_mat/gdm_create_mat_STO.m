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

function gdm_create_mat_STO(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_sb')==0
    flg_loc.do_sb=0;
end

if isfield(flg_loc,'do_all')==0
    flg_loc.do_all=1;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% MODIFY TIME OUTPUT

gdm_modify_time_output(fid_log,flg_loc,simdef)

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% GET RAW VARIABLES map 2DH

in_plot_get_variables_2DH=gdm_get_mat_2DH_for_STO(fid_log,flg_loc,simdef);

%% REORDER INDICES

gdm_STO_reorder_indices_grd(fid_log,fdir_mat,time_dnum,in_plot_get_variables_2DH,simdef)

%% CREATE MAT

var_2_v=gdm_STO_create_mat(fid_log,flg_loc,simdef,in_plot_get_variables_2DH,time_dnum);

%% SUMMERBED PLOT

if flg_loc.do_sb
    gdm_STO_plot_SMB(fid_log,flg_loc,simdef,var_2_v)
end

end %function

%% 
%% FUNCTION
%%

function in_plot_get_variables_2DH=gdm_get_mat_2DH_for_STO(fid_log,flg_loc,simdef)

%% INPUT


var_raw={'umag','mesh2d_czs','h','Ltot','Fak'};

tag='M2D';

in_plot.fdir_sim=flg_loc.fdir_sim;
in_plot.(tag).do=1;
in_plot.(tag).do_p=0; %regular plot
in_plot.(tag).overwrite=flg_loc.overwrite;
in_plot.(tag).var=var_raw; %open D3D_list_of_variables
in_plot.(tag).tim=flg_loc.tim; 
in_plot.(tag).order_anl=2; %1=normal; 2=random

flg_loc=isfield_default(flg_loc,'tim_tol',1); %tolerance in days to find the closest time step
in_plot.(tag).tim_tol=flg_loc.tim_tol; 

%% CALL

D3D_gdm(in_plot)

%% PROCESS VARIABLE NAMES

in_plot_get_variables_2DH=gmd_tag(in_plot,tag);
[in_plot_get_variables_2DH,simdef]=gdm_parse_map_2DH(fid_log,in_plot_get_variables_2DH,simdef);

end %function

%% 

function gdm_STO_plot_SMB(fid_log,flg_loc,simdef,var_2_v)
    
nf=numel(gdm_read_dk(simdef)); %we cannot use the size of `qbk` because the loop may be skipped if files exist

in_plot.fdir_sim=flg_loc.fdir_sim;
in_plot.str_sim=flg_loc.str_sim;
in_plot.lan=flg_loc.lan;
in_plot.tag_serie=flg_loc.tag_serie;

tag='SMB';
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

function var_2_v=gdm_STO_create_mat(fid_log,flg_loc,simdef,in_plot_get_variables_2DH,time_dnum)


nst=numel(flg_loc.sedtrans); 
% nf=numel(dk);
nt=numel(time_dnum);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_map=gdm_fpathmap(simdef,0);

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% SED MOR

dk=gdm_read_dk(simdef);
mor=gdm_read_mor(simdef);

Thresh=mor.Morphology0.Thresh;

%% COMMON FLAGS

%This is not ideal. It is because I use a generic sediment transport rate
% function. It would be good ti read this from sediment file. 

[flg,cnt,mor_fac,E_param,vp_param,Gammak]=gdm_STO_flg_sediment_transport;

%% CREATE <qbk>

tag='M2D';

kt_v=gdm_kt_v(flg_loc,nt); %time index vector
var_sum=cell(1,nst);
var_2_v=cell(1,nst);

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kst=1:nst

    [flg,hiding_param,sed_trans_param]=gdm_STO_apply_variation_sediment_transport(flg_loc,flg,kst);

    var_sum{kst}=sprintf('%s_sum',flg_loc.sedtrans_name{kst});
    var_2_v{kst}='stot'; %the variable name under `var` has the name as input for the sediment transport relation. `var_2` contains the name understood for writing the labels. 
    
    ktc=0;
    for kt=kt_v
        ktc=ktc+1;
        
        %% qbk and hidexp

        fpath_mat_st=mat_tmp_name(fdir_mat,flg_loc.sedtrans_name{kst},'tim',time_dnum(kt)); %we save it as 'raw' to be able to read in <gdm_read_data_map_simdef>
        if exist(fpath_mat_st,'file')==2 && ~flg_loc.overwrite
            continue
        end
        
        [u,h,C,Fak,Ltot]=gdm_STO_load_data(in_plot_get_variables_2DH,simdef,gridInfo,time_dnum(kt));
        
        [data_qbk,data_hidexp]=gdm_STO_compute_qbk(u,h,C,Fak,Ltot,Thresh,dk,flg,cnt,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log);

        data=data_qbk;
        save_check(fpath_mat_st,'data') 
        
        %in case we want to save it, although the naming will be confusing. We have to add the variable to be read. 
        % data=data_hidexp;
        % save_check(fpath_mat_st,'data') 

        %% qbk sum
        
        fpath_mat_st=mat_tmp_name(fdir_mat,var_sum{kst},'tim',time_dnum(kt)); %we save it as 'raw' to be able to read in <gdm_read_data_map_simdef>
        if exist(fpath_mat_st,'file')==2 && ~flg_loc.overwrite
            continue
        end

        data=gdm_STO_compute_qbk_sum(data);

        save_check(fpath_mat_st,'data')
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kst %4.2f %%',tag,ktc/nt*100,kst/nst*100));
    end %kt
end %kst

end %function

%%
%% FUNCTIONS
%%

function [flg,cnt,mor_fac,E_param,vp_param,Gammak]=gdm_STO_flg_sediment_transport

flg.Dm=1; %arithmetic
flg.friction_closure=1; 
flg.E=0;
flg.vp=0;
flg.particle_activity=0;
flg.extra=0;

cnt.g=9.81; %we should read from mdu...
cnt.R=1.65; %we should read from sed, but then varie per sediment size fraction...
cnt.p=0.00; %we compute sediment transport without pores
cnt.rho_w=1000; %read properly...
cnt.rho_s=2650; %read properly...
cnt.nu = 1e-6; %we should compute based on temperature?

mor_fac=1;  
E_param=NaN;
vp_param=NaN;
Gammak=NaN;

end %function

%%

function [flg,hiding_param,sed_trans_param]=gdm_STO_apply_variation_sediment_transport(flg_loc,flg,kst)

flg.hiding=flg_loc.sedtrans_hiding(kst);
hiding_param=flg_loc.sedtrans_hiding_param(kst);
flg.mu=flg_loc.sedtrans_mu(kst);
flg.mu_param=flg_loc.sedtrans_mu_param(kst);
flg.sed_trans=flg_loc.sedtrans{kst};
sed_trans_param=flg_loc.sedtrans_param{kst};
if isfield(flg_loc,'sedtrans_sbform')
    flg.sbform=flg_loc.sedtrans_sbform(kst);
end

if isfield(flg_loc,'sedtrans_wsform')
    flg.wsform=flg_loc.sedtrans_wsform(kst);
end

if isfield(flg_loc,'sedtrans_theta_c')
    flg.theta_c = flg_loc.sedtrans_theta_c(kst); %shouldn't it crash?
end

end

%%

function [data_qbk,data_hidexp]=gdm_STO_compute_qbk(u,h,C,Fak,Ltot,Thresh,dk,flg,cnt,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log)

q=u.*h; %[nF,1]
cf=cnt.g./C.^2; %[nF,1]
La=ones(size(q)); %[nF,1]
Mak=Fak(:,1:end-1); %[nF,nf-1]

if numel(q) ~= size(Mak,1)
    error('The number of cells in the hydrodynamic output is different than in the morphodynamic output. Maybe an enclosure file has been used.')
end

[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log,NaN);

L_all=min(Ltot/Thresh,1);
val=L_all.*qbk;

data_qbk=struct();
data_qbk.val=val; %we have to save it as structure because we use 'raw' type
data_qbk.dimensions='[mesh2d_nFaces,sedimentFraction]'; %ok

data_hidexp=struct();
data_hidexp.val=xik; %we have to save it as structure because we use 'raw' type
data_hidexp.dimensions='[mesh2d_nFaces,sedimentFraction]'; %ok

end %function

%%

function [u,h,C,Fak,Ltot]=gdm_STO_load_data(in_plot_get_variables_2DH,simdef,gridInfo,time_dnum_loc)

nvar=numel(in_plot_get_variables_2DH.var); 
%load data
for kvar=1:nvar %variable
    [fpath_mat_tmp,~,~,~,~]=gdm_get_name_map_2DH(in_plot_get_variables_2DH,simdef,gridInfo,kvar,in_plot_get_variables_2DH.tag,time_dnum_loc);

    var_save=in_plot_get_variables_2DH.var{kvar};
    data_loc.(var_save)=load(fpath_mat_tmp,'data');
end

u=data_loc.umag.data'; %[nF,1]
h=data_loc.h.data'; %[nF,1]
C=data_loc.mesh2d_czs.data'; %[nF,1]
Fak=squeeze(data_loc.Fak.data); %[nF,nf] (take active layer) %NEW, we only read the active layer
Ltot=data_loc.Ltot.data'; %[nF,1]

end %function

%%

function data=gdm_STO_compute_qbk_sum(data)

data.val=sum(data.val,2); %we have to save it as structure because we use 'raw' type
data.dimensions='[mesh2d_nFaces]';

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
D3D_gdm(in_plot)

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
D3D_gdm(in_plot)

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
D3D_gdm(in_plot)

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
D3D_gdm(in_plot)

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

D3D_gdm(in_plot);

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

D3D_gdm(in_plot);

end %function

%%

function gdm_STO_reorder_indices_grd(fid_log,fdir_mat,time_dnum,in_plot_get_variables_2DH,simdef)

nt=numel(time_dnum);

grd_hyd=load(fullfile(fdir_mat,'grd.mat'));
grd_mor=load(fullfile(fdir_mat,'grd_mor.mat'));

xy_hyd=[grd_hyd.gridInfo.Xcen,grd_hyd.gridInfo.Ycen];
xy_mor=[grd_mor.gridInfo.Xcen,grd_mor.gridInfo.Ycen];

if ~isequal(size(xy_hyd),size(xy_mor))
    error('The morphodynamic simulation has a different number of cells than the hydrodynamic simulation.')
end

gridInfo=grd_hyd.gridInfo;

tol=1e-2;
if any(max(abs(xy_hyd-xy_mor))>tol)
    messageOut(fid_log,sprintf('The grids differ by more than %f m',tol))
    messageOut(fid_log,'Reordering morphodynamic output.')

    [~,idx] = reorder_matrix(xy_hyd',xy_mor');

    varname=D3D_sediment_transport_offline_variables;
    in_plot_get_variables_2DH.var=varname;
    nvar=numel(varname);
    for kvar=1:nvar
        %we modify both the raw variable and the M2D one. 
        varname_read_variable=D3D_sediment_transport_offline_variables_read(varname{kvar});
        for kt=1:nt
            time_dnum_loc=time_dnum(kt);

            %raw file
            fpath_mat_tmp_out=mat_tmp_name(fdir_mat,varname_read_variable,'tim',time_dnum_loc);    
            load(fpath_mat_tmp_out,'data')
            data=isfield_default(data,'reordered',false);
            if data.reordered
                messageOut(fid_log,sprintf('File already reordered: %s',fpath_mat_tmp_out));
                continue
            end

            data.reordered=true;
            data.val=data.val(:,idx,:,:,:);
            save(fpath_mat_tmp_out,'data')

            %M2D file
            [fpath_mat_tmp_out,~,~,~,~]=gdm_get_name_map_2DH(in_plot_get_variables_2DH,simdef,gridInfo,kvar,in_plot_get_variables_2DH.tag,time_dnum_loc);
            load(fpath_mat_tmp_out,'data')
            sz=size(data);
            bol_dim_faces=ismember(sz,numel(gridInfo.Xcen));
            if bol_dim_faces(1)
                data=data(idx,:,:,:,:);
            elseif bol_dim_faces(2)
                data=data(:,idx,:,:,:);
            else
                error('Dimensions do not match.')
            end
            save(fpath_mat_tmp_out,'data')

        end %kt
    end %kvar
end %above tol

end %function
