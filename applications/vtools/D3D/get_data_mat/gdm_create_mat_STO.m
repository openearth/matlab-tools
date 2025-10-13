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

grd_hyd=load(fullfile(fdir_mat,'grd.mat'));
grd_mor=load(fullfile(fdir_mat,'grd_mor.mat'));

xy_hyd=[grd_hyd.gridInfo.Xcen,grd_hyd.gridInfo.Ycen];
xy_mor=[grd_mor.gridInfo.Xcen,grd_mor.gridInfo.Ycen];

if ~isequal(size(xy_hyd),size(xy_mor))
    error('The morphodynamic simulation has a different number of cells than the hydrodynamic simulation.')
end

tol=1e-2;
if any(max(abs(xy_hyd-xy_mor))>tol)
    messageOut(fid_log,sprintf('The grids differ by more than %f m',tol))
    messageOut(fid_log,'Reordering morphodynamic output.')

    [~,idx] = reorder_matrix(xy_hyd',xy_mor');

    varname=D3D_sediment_transport_offline_variables;
    nvar=numel(varname);
    for kvar=1:nvar
    varname_read_variable=D3D_sediment_transport_offline_variables_read(varname{kvar});
        for kt=1:nt
            tim_cmp=time_dnum(kt);
            fpath_mat_tmp_out=mat_tmp_name(fdir_mat,varname_read_variable,'tim',tim_cmp);      
            load(fpath_mat_tmp_out,'data')
            data=isfield_default(data,'reordered',false);
            if data.reordered
                messageOut(fid_log,sprintf('File already reordered: %s',fpath_mat_tmp_out));
                continue
            end
            data.reordered=true;
            data.val=data.val(:,idx,:,:,:);
            save(fpath_mat_tmp_out,'data')
        end %kt
    end %kvar
end %above tol

%% CREATE MAT

var_2_v=gdm_STO_create_mat(fid_log,flg_loc,simdef,in_plot_get_variables_2DH,time_dnum);

%% SUMMERBED

if flg_loc.do_sb
    gsm_STO_plot_SMB(fid_log,flg_loc,simdef,var_2_v)
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

%% CALL

D3D_gdm(in_plot)

%% PROCESS VARIABLE NAMES

in_plot_get_variables_2DH=gmd_tag(in_plot,tag);
[in_plot_get_variables_2DH,simdef]=gdm_parse_map_2DH(fid_log,in_plot_get_variables_2DH,simdef);

end %function

%% 

function gsm_STO_plot_SMB(fid_log,flg_loc,simdef,var_2_v)
    
nf=numel(D3D_read_sed(simdef.file.sed)); %we cannot use the size of `qbk` because the loop may be skipped if files exist

in_plot.fdir_sim=flg_loc.fdir_sim;
in_plot.str_sim=flg_loc.str_sim;
in_plot.lan=flg_loc.lan;
in_plot.tag_serie=flg_loc.tag_serie;

tag='SMB';
in_plot.(tag)=flg_loc;
in_plot.(tag).do=1;

%% PLOTS OF A SINGLE TIME STEP, AREA

in_plot.(tag).do_p_single=1; %regular plot
in_plot.(tag).do_xvt=0; %x-variable with time in color
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
% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).tim=flg_loc.tim(1); %one time of the analysis. Do not use integer here! The time vector does not make sense. 
in_plot.(tag).order_anl=2; %1=normal; 2=random
% in_plot_sb.(tag_sb).tim_ave{1,1}=[]; %NaN = all times. Empty = do not do. 
% in_plot_sb.(tag_sb).ylims_var=flg_loc.ylims_var_sum; %do we need it?

% in_plot_sb.(tag_sb).var=var_sum; %open D3D_list_of_variables
% in_plot_sb.(tag_sb).do_val_B_mor=ones(size(var_sum)); %compute value of the variable per unit of morphodynamic width

in_plot.(tag).var={'Fak'}; 

in_plot.(tag).layer=1; %we want the first layer of `Fak` 

in_plot.(tag).var_idx{1,1}=1:1:nf;

% in_plot.(tag).do_val_B_mor=0; %compute value of the variable per unit of morphodynamic width

% in_plot.(tag).var_2=cell(1,nst+4+nf);
% in_plot.(tag).var_2(1:nst)=var_2_v;

% in_plot.(tag).do_cum=0; 

% CALL
D3D_gdm(in_plot)

%%


in_plot.(tag).do_p_single=flg_loc.do_sb_p; %regular plot
in_plot.(tag).do_xvt=1; %x-variable with time in color
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
% in_plot_sb.(tag_sb).do_all_s=flg_loc.do_all; %I do not understand what is this. All variables together may make sense, but not all simulations?
in_plot.(tag).tim=flg_loc.tim; %all times
in_plot.(tag).order_anl=2; %1=normal; 2=random
% in_plot_sb.(tag_sb).tim_ave{1,1}=[]; %NaN = all times. Empty = do not do. 
% in_plot_sb.(tag_sb).ylims_var=flg_loc.ylims_var_sum; %do we need it?

% in_plot_sb.(tag_sb).var=var_sum; %open D3D_list_of_variables
% in_plot_sb.(tag_sb).do_val_B_mor=ones(size(var_sum)); %compute value of the variable per unit of morphodynamic width

    %only var_sum
%TO DO: why not plotting only Fak as area for all fractions together?
in_plot.(tag).var=cat(2,var_sum,{'umag','mesh2d_czs','h','Ltot'},repmat({'Fak'},1,nf)); 

in_plot.(tag).layer=num2cell(cat(2,zeros(size(var_sum)),[0,0,0,0,ones(1,nf)])); %we want the first layer of `Fak` 
in_plot.(tag).layer{numel(var_sum)+1}=[]; %we do not want to specify any layer in velocity 

in_plot.(tag).var_idx=cell(1,nst+4+nf);
for kf=1:nf
    in_plot.(tag).var_idx{1,nst+4+kf}=kf;
end

in_plot.(tag).do_val_B_mor=[ones(1,nst),[0,0,0,0,zeros(1,nf)]]; %compute value of the variable per unit of morphodynamic width

in_plot.(tag).var_2=cell(1,nst+4+nf);
in_plot.(tag).var_2(1:nst)=var_2_v;

in_plot.(tag).do_cum=[ones(1,nst),0,0,0,0,zeros(1,nf)]; 

    %add each size fraction
for kst=1:nst
    for kf=1:nf
        in_plot.(tag).var=cat(2,in_plot.(tag).var,flg_loc.sedtrans_name{kst}); 
        in_plot.(tag).layer=cat(2,in_plot.(tag).layer,{0});
        in_plot.(tag).var_idx=cat(2,in_plot.(tag).var_idx,{kf});
        in_plot.(tag).do_val_B_mor=cat(2,in_plot.(tag).do_val_B_mor,1);
        in_plot.(tag).var_2=cat(2,in_plot.(tag).var_2,{'s'});
        in_plot.(tag).do_cum=cat(2,in_plot.(tag).do_cum,0);
    end
end

    %add transport per size fraction all together
in_plot.(tag).do_area=zeros(1,numel(in_plot.(tag).var));
for kst=1:nst
    in_plot.(tag).var=cat(2,in_plot.(tag).var,flg_loc.sedtrans_name{kst}); 
    in_plot.(tag).layer=cat(2,in_plot.(tag).layer,{0});
    in_plot.(tag).var_idx=cat(2,in_plot.(tag).var_idx,{1:1:nf});
    in_plot.(tag).do_val_B_mor=cat(2,in_plot.(tag).do_val_B_mor,1);
    in_plot.(tag).var_2=cat(2,in_plot.(tag).var_2,{'stot'});
    in_plot.(tag).do_cum=cat(2,in_plot.(tag).do_cum,1);
    in_plot.(tag).do_area=cat(2,in_plot.(tag).do_area,1);
end

%     %add celerities
% in_plot_sb.(tag_sb).var=cat(2,in_plot_sb.(tag_sb).var,'cel_morpho'); 
% in_plot_sb.(tag_sb).layer=cat(2,in_plot_sb.(tag_sb).layer,{0});
% in_plot_sb.(tag_sb).var_idx=cat(2,in_plot_sb.(tag_sb).var_idx,{zeros(0,0)});
% in_plot_sb.(tag_sb).do_val_B_mor=cat(2,in_plot_sb.(tag_sb).do_val_B_mor,0);
% in_plot_sb.(tag_sb).var_2=cat(2,in_plot_sb.(tag_sb).var_2,{'cel_morpho'});
% in_plot_sb.(tag_sb).do_cum=cat(2,in_plot_sb.(tag_sb).do_cum,1);
% in_plot_sb.(tag_sb).do_area=cat(2,in_plot_sb.(tag_sb).do_area,0);

%add mean grain size -> should be first requested as output in the
%simulation!
% in_plot_sb.(tag_sb).var=cat(2,in_plot_sb.(tag_sb).var,'dg'); 
% in_plot_sb.(tag_sb).layer=cat(2,in_plot_sb.(tag_sb).layer,{0});
% in_plot_sb.(tag_sb).var_idx=cat(2,in_plot_sb.(tag_sb).var_idx,{[]});
% in_plot_sb.(tag_sb).do_val_B_mor=cat(2,in_plot_sb.(tag_sb).do_val_B_mor,0);
% in_plot_sb.(tag_sb).var_2=cat(2,in_plot_sb.(tag_sb).var_2,{'dg'});
% in_plot_sb.(tag_sb).do_cum=cat(2,in_plot_sb.(tag_sb).do_cum,0);
% in_plot_sb.(tag_sb).do_area=cat(2,in_plot_sb.(tag_sb).do_area,0);

% CALL
D3D_gdm(in_plot)

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

dk=D3D_read_sed(simdef.file.sed);
        
mor=D3D_io_input('read',simdef.file.mor);
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
        
        fpath_mat_st=mat_tmp_name(fdir_mat,flg_loc.sedtrans_name{kst},'tim',time_dnum(kt)); %we save it as 'raw' to be able to read in <gdm_read_data_map_simdef>
        if exist(fpath_mat_st,'file')==2 && ~flg_loc.overwrite
            continue
        end
        
        [u,h,C,Fak,Ltot]=gdm_STO_load_data(in_plot_get_variables_2DH,simdef,gridInfo,time_dnum(kt));
        
        data=gdm_STO_compute_qbk(u,h,C,Fak,Ltot,Thresh,dk,flg,cnt,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log);

        save_check(fpath_mat_st,'data') 
        
        %% save sum 
        
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

function data=gdm_STO_compute_qbk(u,h,C,Fak,Ltot,Thresh,dk,flg,cnt,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log)

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

data=struct();
data.val=val; %we have to save it as structure because we use 'raw' type
data.dimensions='[mesh2d_nFaces,sedimentFraction]'; %ok

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


%         u=data_loc.mesh2d_umod.data'; %[nF,1]
u=data_loc.umag.data'; %[nF,1]
h=data_loc.h.data'; %[nF,1]
C=data_loc.mesh2d_czs.data'; %[nF,1]
%         Fak=squeeze(data_loc.Fak.data(:,1,:)); %[nF,nf] (take active layer) %OLD, we were reading all the layers
Fak=squeeze(data_loc.Fak.data); %[nF,nf] (take active layer) %NEW, we only read the active layer
Ltot=data_loc.Ltot.data'; %[nF,1]

end %function

%%

function data=gdm_STO_compute_qbk_sum(data)

data.val=sum(data.val,2); %we have to save it as structure because we use 'raw' type
data.dimensions='[mesh2d_nFaces]';

end %function