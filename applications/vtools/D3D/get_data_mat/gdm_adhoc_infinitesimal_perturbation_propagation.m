%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19687 $
%$Date: 2024-06-24 17:30:38 +0200 (Mon, 24 Jun 2024) $
%$Author: chavarri $
%$Id: twoD_study.m 19687 2024-06-24 15:30:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%

function gdm_adhoc_infinitesimal_perturbation_propagation(fid_log,flg_loc,simdef)

[tag,~,tag_serie]=gdm_tag_fig(flg_loc);
tag_fig='ipp';

%we save `simdef_all` to be able to skip all the processing if we only want to do the adhoc work.
fpath_sda=fullfile(pwd,'simdef.mat');
if ~isstruct(simdef) && isfile(fpath_sda)
    load(fpath_sda,'simdef');
else
    save(fpath_sda,'simdef');
end

%path to mat file with results from all simulations
% fdir_mat=simdef(1).file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));

%assume same matrices for all cases, we load only once
ks=1;
fpath_simdef=fullfile(simdef(ks).D3D.dire_sim);
simdef_loc=load(fullfile(fpath_simdef,'simdef.mat'),'simdef');
ECT_input=D3D_input_2_ECT_input(simdef_loc.simdef); %convert simdef to ECT_input
[ECT_matrices,sed_trans]=call_ECT(ECT_input);

in_2D.lims_lwy=[1,80];
in_2D.lims_lwx=[36,1000];

[eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
[kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m]=derived_variables_twoD_study(ECT_input.h,eig_r,eig_i,kwx_v,kwy_v,kw_m);

in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.fig_overwrite=1;

%% loop on simulations

ns=numel(simdef);
for ks=1:ns
    fdir_mat=simdef(ks).file.mat.dir;
    fpath_mat=fullfile(fdir_mat,'ipp.mat');

    %if exists file, skip loop
    if isfile(fpath_mat) && ~flg_loc.overwrite
        messageOut(fid_log,sprintf('File exists, loading: %s',fpath_mat));
        load(fpath_mat,'data');
        data_all(ks)=data;
        continue
    end

    data=process_simulation(fpath_mat,fid_log,flg_loc,simdef(ks),ECT_input,ECT_matrices,tag_fig,tag_serie,in_p);

    save(fpath_mat,'data');

    data_all(ks)=data;

end %ks

%% plot

ks=1;
fdir_fig=fullfile(simdef(ks).file.fig.dir,tag_fig,tag_serie); 

plot_data_all(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p);

end %function

%%
%% FUNCTIONS
%%

function [c,w,ls]=gdm_compute_sinus_propagation(fpath_ls)

nls=numel(fpath_ls);
ls=struct('data',1);
for kls=1:nls
    ls(kls)=load(fpath_ls{kls});

    x=ls(kls).data.Xcen;
    y=ls(kls).data.val';

    bol_nan=isnan(x) | isnan(y);
    x=x(~bol_nan);
    y=y(~bol_nan);

    xl=x(end)/3;
    bol_get=x>xl & x<2*xl;
    xg=x(bol_get);
    yg=y(bol_get);

    [y_fit,ABCD,y_0]=fit_sine(xg,yg);
    % [y_fit,ABCD,y_0]=fit_sine(xg,yg,'ini',ls(1).data.ABCD);
    
    ls(kls).data.xg=xg;
    ls(kls).data.yg=yg;
    ls(kls).data.y_fit=y_fit;
    ls(kls).data.y_0=y_0;
    ls(kls).data.ABCD=ABCD;
end

%%

A1=ls(1).data.ABCD(1);
A2=ls(2).data.ABCD(1);
B1=ls(1).data.ABCD(2);
B2=ls(2).data.ABCD(2);
C1=ls(1).data.ABCD(3);
C2=ls(2).data.ABCD(3);
t1=ls(1).data.times;
t2=ls(2).data.times;
dt=(t2-t1)*24*3600;

lambda1=2*pi/B2; %should be the same for both waves
lambda2=2*pi/B1; %should be the same for both waves

lambda=mean([lambda1,lambda2]);

c=-(C2-C1)*lambda/(2*pi)/dt;
w=log(A2/A1)/dt;

end %function

%%

function [c,w,ls]=gdm_compute_observed_wave_propagation(flg_loc,simdef,time_dnum)

fdir_mat=simdef.file.mat.dir;
tag=flg_loc.tag;

%pli name
kpli=1; %we assume there is only 1
fpath_pli=flg_loc.pli{kpli,1};
pliname=gdm_pli_name(fpath_pli);

kvar=1; %it must be h
varname=flg_loc.var{kvar};
var_str=D3D_var_num2str_structure(varname,simdef);

%load ls section before and after
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(1),'var',var_str,'pli',pliname); 
fpath_ls{1}=fpath_mat_tmp;

fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(end),'var',var_str,'pli',pliname); 
fpath_ls{2}=fpath_mat_tmp;

[c,w,ls]=gdm_compute_sinus_propagation(fpath_ls);

end %function

%%

function data=process_simulation(fpath_mat,fid_log,flg_loc,simdef,ECT_input,ECT_matrices,tag_fig,tag_serie,in_p)

fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie); 

%load time
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%load simdef
fpath_simdef=fullfile(simdef.D3D.dire_sim);
simdef_loc=load(fullfile(fpath_simdef,'simdef.mat'),'simdef');

%compute analytical celerity and wave dampening
in_2D.kwx_v=2*pi/simdef_loc.simdef.ini.noise_Lb;
in_2D.kwy_v=2*pi/(simdef_loc.simdef.grd.B*2);

[eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
[kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m]=derived_variables_twoD_study(ECT_input.h,eig_r,eig_i,kwx_v,kwy_v,kw_m);

%compute observed celerity and wave dampening
[c_obs,w_obs,ls_data]=gdm_compute_observed_wave_propagation(flg_loc,simdef,time_dnum);

%plot waves: initial, filtered, initial guess
in_p.ls_data=ls_data;
mkdir_check(fdir_fig);
in_p.fname=fullfile(fdir_fig,'sinus');

fig_sinus(in_p);

%save to mat
[lambda,beta]=nondim_bar_variables(1,simdef_loc.simdef.ini.noise_Lb,simdef_loc.simdef.grd.B*2,simdef_loc.simdef.ini.h);

data.Lb=simdef_loc.simdef.ini.noise_Lb;
data.B=simdef_loc.simdef.grd.B;
data.lambda=lambda;
data.beta=beta;
data.c_anl=c_morph_p;
data.w_anl=max_gr_p;
data.c_obs=c_obs;
data.w_obs=w_obs;
data.nx=simdef_loc.simdef.ini.noise_Lb/simdef_loc.simdef.grd.dx;
data.software=simdef_loc.simdef.D3D.structure;
data.noise=simdef_loc.simdef.ini.etab_noise;

end %function

%%

function plot_data_all(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p)

bol_pert=[data_all.noise]~=0;

for ksoft=1:2 %D3D4 and FM
    switch ksoft
        case 1
            str_soft='D3D4';
        case 2
            str_soft='FM';
    end

    bol_soft=[data_all.software]==ksoft;
    bol_get=bol_soft & bol_pert;

    data_get=data_all(bol_get);

    plot_1_software(fdir_fig,data_get,str_soft,in_p,tri,c_morph_p,max_gr_p,lambda_p,beta_p);

end %ksoft

%comparison between software
plot_software(fdir_fig,data_all,in_p);

end %function

%% 

function plot_1_software(fdir_fig,data_all,str_soft,in_p,tri,c_morph_p,max_gr_p,lambda_p,beta_p)

in_p.tit_str=str_soft;

for kv=1:2 %celerity and wave growth

    [d_anl,d_obs,str,str_u,str_f]=switch_celerity_growth_rate(kv,data_all);

    str_f=sprintf('%s_%s',str_f,str_soft);

    %%
    in_p.do_11_line=1;
    for kae=0:1
        in_p.do_axis_equal=kae;
    
        %scatter comparing observed against predicted celerity
        in_p.fname=fullfile(fdir_fig,sprintf('%s_ae%d',str_f,kae));
        in_p.x=d_anl;
        in_p.y=d_obs;
        in_p.z=[data_all.nx];
        in_p.x_lab=sprintf('analytical %s %s',str,str_u);
        in_p.y_lab=sprintf('observed %s %s',str,str_u);
        
        fig_ipp_scatter(in_p);
    
    end %kae

    %scatter comparing error between observed and predicted celerity in proportioanal terms as a function of the wavelength
    in_p.fname=fullfile(fdir_fig,sprintf('%s_error_rel',str_f));
    in_p.x=[data_all.Lb];
    in_p.y=abs((d_obs-d_anl)./d_anl*100);
    in_p.z=[data_all.nx];
    in_p.x_lab='wave length [m]';
    in_p.y_lab=sprintf('error in absolute %s [%%]',str);
    in_p.do_axis_equal=0;
    in_p.do_11_line=0;
    
    fig_ipp_scatter(in_p);
    
    %scatter comparing error between observed and predicted celerity in absolute terms as a function of the wavelength
    in_p.fname=fullfile(fdir_fig,sprintf('%s_error_abs',str_f));
    in_p.x=[data_all.Lb];
    in_p.y=abs(d_obs-d_anl);
    in_p.z=[data_all.nx];
    in_p.x_lab='wave length [m]';
    in_p.y_lab=sprintf('error in absolute %s %s',str,str_u);
    in_p.do_axis_equal=0;
    in_p.do_11_line=0;
    
    fig_ipp_scatter(in_p);
    
    %scatter comparing the celerity to the wavelength
    in_p.fname=fullfile(fdir_fig,sprintf('%s_Lb',str_f));
    in_p.x=[data_all.Lb];
    in_p.y=d_obs;
    in_p.z=[data_all.nx];
    in_p.x_lab='wave length [m]';
    in_p.y_lab=sprintf('observed %s %s',str,str_u);
    in_p.do_axis_equal=0;
    in_p.do_11_line=0;
    
    fig_ipp_scatter(in_p);

    %scatter comparing lambda-beta-celerity for analytical (left) and observed (right) 
    beta_obs=[data_all.beta];
    lambda_obs=[data_all.lambda];
    nx=[data_all.nx];
    mnx=max(nx); %maximum resolution results
    bol_g=nx==mnx;

    in_p.fname=fullfile(fdir_fig,sprintf('%s_domain',str_f));
    in_p.lambda_p=lambda_p;
    in_p.beta_p=beta_p;
    in_p.max_gr_p=max_gr_p;
    in_p.c_morph_p=c_morph_p;
    in_p.tri=tri;
    in_p.beta_s=beta_obs(bol_g);
    in_p.lambda_s=lambda_obs(bol_g);
    in_p.d_obs=d_obs(bol_g);
    in_p.d_anl=d_anl(bol_g);
    in_p.str=sprintf('%s %s',str,str_u);
    
    fig_twoD_nondim_anl_obs(in_p)

    %scatter comparing lx-B-celerity for analytical (left) and observed (right)
%     in_p.fname=fullfile(fdir_fig,sprintf('%s_domain_dim',str_f));
%     in_p.lambda_p=lambda_p;
%     in_p.beta_p=beta_p;
%     in_p.max_gr_p=max_gr_p;
%     in_p.c_morph_p=c_morph_p;
%     in_p.tri=tri;
%     in_p.beta_s=[data_all.beta];
%     in_p.lambda_s=[data_all.lambda];
%     in_p.d_obs=d_obs;
%     in_p.d_anl=d_anl;
%     in_p.str=sprintf('%s %s',str,str_u);
%     
%     fig_twoD_nondim_anl_obs(in_p)

end %kv

end %function

%%

function plot_software(fdir_fig,data_all,in_p)

bol_pert=[data_all.noise]~=0;

nx_v=[data_all.nx];
nxu=unique(nx_v);
nu=numel(nxu);

for ku=1:nu
    bol_nx=nx_v==nxu(ku);
    bol_get=bol_pert & bol_nx;

    data_get=data_all(bol_get);

    for kv=1:2
        
        [d_anl,d_obs,str,str_u,str_f]=switch_celerity_growth_rate(kv,data_get);
        str_f=sprintf('%s_soft_nx%02d',str_f,ku);

        in_p.do_axis_equal=0;
        in_p.do_11_line=0;
        in_p.leg_type=2;
        in_p.tit_str=sprintf('nx=%d',nxu(ku));
        in_p.x=[data_get.Lb];
        in_p.z=[data_get.software];
        in_p.x_lab='wave length [m]';

        %scatter comparing error between observed and predicted celerity in proportioanal terms as a function of the wavelength
        in_p.fname=fullfile(fdir_fig,sprintf('%s_error_rel',str_f));
        in_p.y=abs((d_obs-d_anl)./d_anl*100);
        in_p.y_lab=sprintf('error in absolute %s [%%]',str);

        fig_ipp_scatter(in_p);
        
        %scatter comparing error between observed and predicted celerity in absolute terms as a function of the wavelength
        in_p.fname=fullfile(fdir_fig,sprintf('%s_error_abs',str_f));
        in_p.y=abs(d_obs-d_anl);
        in_p.y_lab=sprintf('error in absolute %s %s',str,str_u);

        fig_ipp_scatter(in_p);
    
    end %kv
end %ku

end %function

%%

function [d_anl,d_obs,str,str_u,str_f]=switch_celerity_growth_rate(kv,data_all)

switch kv
    case 1
        d_anl=[data_all.c_anl];
        d_obs=[data_all.c_obs];
        str='celerity';
        str_u='[m/s]';
    case 2
        d_anl=[data_all.w_anl];
        d_obs=[data_all.w_obs];
        str='growth rate';            
        str_u='[1/s]';
end

str_f=strrep(str,' ','_');

end