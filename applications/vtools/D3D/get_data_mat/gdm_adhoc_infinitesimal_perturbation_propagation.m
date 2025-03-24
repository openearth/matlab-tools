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

in_2D.lims_lwy=[10,80];
in_2D.lims_lwx=[30,1000];

[eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
[kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m,tri_dim]=derived_variables_twoD_study(ECT_input.h,eig_r,eig_i,kwx_v,kwy_v,kw_m);

in_p.fig_print=[1,3]; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
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
mkdir_check(fdir_fig,NaN,1,0);

plot_data_all(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p,tri_dim,lwx_p,lwy_p);

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
data.Dpuopt=simdef_loc.simdef.mdf.Dpuopt;
data.UpwindBedload=simdef_loc.simdef.mor.UpwindBedload;

end %function

%%

function plot_data_all(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p,tri_dim,lwx_p,lwy_p)

plot_domain(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p,tri_dim,lwx_p,lwy_p)

plot_each_case(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p);

plot_software(fdir_fig,data_all,in_p);

end %function

%% 

function plot_1_software(fdir_fig,data_all,in_p,tri,c_morph_p,max_gr_p,lambda_p,beta_p)

[z,tit_str,str_leg]=select_data_write_string(data_all);
in_p.z=z;
in_p.tit_str=tit_str;
in_p.leg_type=NaN;
in_p.str_leg=str_leg;

for kv=1:2 %celerity and wave growth

    [d_anl,d_obs,str,str_u,str_f]=switch_celerity_growth_rate(kv,data_all);

    str_f=sprintf('%s_%s',str_f,clean_str(tit_str));

    %%
    in_p.do_11_line=1;
    in_p.x=d_anl;
    in_p.y=d_obs;
    in_p.fig_size=[0,0,14,8];
    in_p.tolx=[0,0];
    in_p.ylims=NaN;
    
    for kae=0:1
        in_p.do_axis_equal=kae;
    
        %scatter comparing observed against predicted celerity
        in_p.fname=fullfile(fdir_fig,sprintf('%s_ae%d',str_f,kae));
        in_p.x_lab=sprintf('analytical %s %s',str,str_u);
        in_p.y_lab=sprintf('observed %s %s',str,str_u);
        
        fig_ipp_scatter(in_p);
    
    end %kae

    in_p.fig_size=[0,0,14,8];
    in_p.tolx=[-35,100];
    in_p.x=[data_all.Lb];
    in_p.do_axis_equal=0;
    in_p.do_11_line=0;

    %scatter comparing error between observed and predicted celerity in proportioanal terms as a function of the wavelength
    in_p.fname=fullfile(fdir_fig,sprintf('%s_error_rel',str_f));
    in_p.y=abs((d_obs-d_anl)./d_anl*100);
    in_p.ylims=[0,100];
    in_p.x_lab='wave length [m]';
    in_p.y_lab=sprintf('error in absolute %s [%%]',str);
    
    fig_ipp_scatter(in_p);
    
    %scatter comparing error between observed and predicted celerity in absolute terms as a function of the wavelength
    in_p.fname=fullfile(fdir_fig,sprintf('%s_error_abs',str_f));
    in_p.y=abs(d_obs-d_anl);
    in_p.ylims=NaN;
    in_p.x_lab='wave length [m]';
    in_p.y_lab=sprintf('error in absolute %s %s',str,str_u);
    
    fig_ipp_scatter(in_p);
    
    %scatter comparing the celerity to the wavelength
    in_p.fname=fullfile(fdir_fig,sprintf('%s_Lb',str_f));
    in_p.y=d_obs;
    in_p.ylims=NaN;
    in_p.x_lab='wave length [m]';
    in_p.y_lab=sprintf('observed %s %s',str,str_u);
    
    fig_ipp_scatter(in_p);

    %scatter comparing lambda-beta-celerity for analytical (left) and observed (right) 
%     beta_obs=[data_all.beta];
%     lambda_obs=[data_all.lambda];
%     nx=[data_all.nx];
%     mnx=max(nx); %maximum resolution results
%     bol_g=nx==mnx;

    %domain for each case. Not 
%     in_p.fname=fullfile(fdir_fig,sprintf('%s_domain',str_f));
%     in_p.lambda_p=lambda_p;
%     in_p.beta_p=beta_p;
%     in_p.max_gr_p=max_gr_p;
%     in_p.c_morph_p=c_morph_p;
%     in_p.tri=tri;
%     in_p.beta_s=beta_obs(bol_g);
%     in_p.lambda_s=lambda_obs(bol_g);
%     in_p.d_obs=d_obs(bol_g);
%     in_p.d_anl=d_anl(bol_g);
%     in_p.str=sprintf('%s %s',str,str_u);
%     
%     fig_twoD_nondim_anl_obs(in_p)

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

bol_mat=create_bol_mat(data_all);

np=size(bol_mat,1);

for kp=1:np    
    for kv=1:2 %growth rate and celerity
       
        %select data
        data_get=data_all(bol_mat(kp,:));

        [z,tit_str,str_leg]=select_data_write_string(data_get);
    
        [d_anl,d_obs,str,str_u,str_f]=switch_celerity_growth_rate(kv,data_get);
        str_f=sprintf('%s_%02d',str_f,kp);

        %common to figures
        in_p.z=z;
        in_p.do_axis_equal=0;
        in_p.do_11_line=0;
        in_p.tit_str=tit_str;
        in_p.str_leg=str_leg;
        in_p.x=[data_get.Lb];
        in_p.leg_type=NaN;
        in_p.fig_size=[0,0,14,8];
        in_p.tolx=[-35,100];
        in_p.x_lab='wave length [m]';

        %scatter comparing error between observed and predicted celerity in proportioanal terms as a function of the wavelength
        in_p.fname=fullfile(fdir_fig,sprintf('%s_error_rel',str_f));
        in_p.y=abs((d_obs-d_anl)./d_anl*100);
        in_p.ylims=[0,100];
        in_p.y_lab=sprintf('error in absolute %s [%%]',str);

       fig_ipp_scatter(in_p);
        
        %scatter comparing error between observed and predicted celerity in absolute terms as a function of the wavelength
        in_p.fname=fullfile(fdir_fig,sprintf('%s_error_abs',str_f));
        in_p.y=abs(d_obs-d_anl);
        in_p.ylims=NaN;
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

%%

function plot_each_case(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p)

bol_pert=[data_all.noise]~=0;

%2DO this could be done using a matrix of booleans and call the same as later for comparing cases.
for ksoft=1:2 %D3D4 and FM
    for kscheme=0:1
        for kdpuopt=1:2

            bol_soft=[data_all.software]==ksoft;
            bol_scheme=[data_all.UpwindBedload]==kscheme;
            bol_dpuopt=[data_all.Dpuopt]==kdpuopt;
            
            bol_get=bol_pert & bol_soft & bol_scheme & bol_dpuopt;
            data_get=data_all(bol_get);
            
            plot_1_software(fdir_fig,data_get,in_p,tri,c_morph_p,max_gr_p,lambda_p,beta_p);
        end %kdpuopt
    end %scheme
end %ksoft

end %function

%%

function plot_domain(fdir_fig,data_all,tri,c_morph_p,max_gr_p,lambda_p,beta_p,in_p,tri_dim,lwx_p,lwy_p)

%% non-dimensional

in_p_loc=in_p;
in_p_loc.tri=tri;
in_p_loc.lambda_p=lambda_p;
in_p_loc.beta_p=beta_p;
in_p_loc.max_gr_p=max_gr_p;
in_p_loc.c_morph_p=c_morph_p;
in_p_loc.lambda_s=[data_all.lambda];
in_p_loc.beta_s=[data_all.beta];
in_p_loc.lims_c1=1e-5*[-1,1];
in_p_loc.str_x='\lambda [-]';
in_p_loc.str_y='\beta [-]';
in_p_loc.fname=fullfile(fdir_fig,'domain_nodim');

fig_twoD_nondim_surf(in_p_loc);

%% dimensional

in_p_loc.tri=tri_dim;
in_p_loc.lambda_p=lwx_p;
in_p_loc.beta_p=lwy_p;
in_p_loc.lambda_s=[data_all.Lb];
in_p_loc.beta_s=[data_all.B]*2;
in_p_loc.str_x='L_x [m]';
in_p_loc.str_y='L_y [m]';
in_p_loc.fname=fullfile(fdir_fig,'domain_dim');

fig_twoD_nondim_surf(in_p_loc);

end %function

%% 

function [bol_nx,bol_UpwindBedload,bol_soft,bol_Dpuopt]=initialize_bol(bol_pert)

bol_nx=true(size(bol_pert));
bol_UpwindBedload=true(size(bol_pert));
bol_soft=true(size(bol_pert));
bol_Dpuopt=true(size(bol_pert));

end %function

%%

function bol_mat=create_bol_mat(data_all)

bol_pert=[data_all.noise]~=0;
% bol_fm=[input_m_s.D3D__structure]==2;
% bol_min=[input_m_s.mdf__Dpuopt]==1;
% bol_lx400=[input_m_s.ini__noise_Lb]==400;
% bol_noise=[input_m_s.ini__etab_noise]==2;
% bol_upw=[input_m_s.mor__UpwindBedload]==1;

nx_v=[data_all.nx];
nx_u=unique(nx_v);
nnx=numel(nx_u);

soft_v=[data_all.software];
soft_u=unique(soft_v);
nsoft=numel(soft_u);

Dpuopt_v=[data_all.Dpuopt];
Dpuopt_u=unique(Dpuopt_v);
nDpuopt=numel(Dpuopt_u);

UpwindBedload_v=[data_all.UpwindBedload];
UpwindBedload_u=unique(UpwindBedload_v);
nUpwindBedload=numel(UpwindBedload_u);

bol_mat=false(0,0);

%varying UpwindBedLoad
[bol_nx,bol_UpwindBedload,bol_soft,bol_Dpuopt]=initialize_bol(bol_pert);
for knx=1:nnx 
    bol_nx=nx_v==nx_u(knx);
    for ksoft=1:nsoft 
        bol_soft=soft_v==soft_u(ksoft);
        for kDpuopt=1:nDpuopt
            bol_Dpuopt=Dpuopt_v==Dpuopt_u(kDpuopt);

            bol_get=bol_pert & bol_nx & bol_soft & bol_Dpuopt & bol_UpwindBedload;
        
            bol_mat=cat(1,bol_mat,bol_get);
        end %dpuopt
    end %ksoft
end %ku

%varying Dpuopt
[bol_nx,bol_UpwindBedload,bol_soft,bol_Dpuopt]=initialize_bol(bol_pert);
for knx=1:nnx 
    bol_nx=nx_v==nx_u(knx);
    for ksoft=1:nsoft 
        bol_soft=soft_v==soft_u(ksoft);
        for kUpwindBedload=1:nUpwindBedload
            bol_UpwindBedload=UpwindBedload_v==UpwindBedload_u(kUpwindBedload);

            bol_get=bol_pert & bol_nx & bol_soft & bol_Dpuopt & bol_UpwindBedload;
        
            bol_mat=cat(1,bol_mat,bol_get);
        end %dpuopt
    end %ksoft
end %ku

%varying software
[bol_nx,bol_UpwindBedload,bol_soft,bol_Dpuopt]=initialize_bol(bol_pert);
for knx=1:nnx 
    bol_nx=nx_v==nx_u(knx);
    for kDpuopt=1:nDpuopt
        bol_Dpuopt=Dpuopt_v==Dpuopt_u(kDpuopt);
        for kUpwindBedload=1:nUpwindBedload
            bol_UpwindBedload=UpwindBedload_v==UpwindBedload_u(kUpwindBedload);

            bol_get=bol_pert & bol_nx & bol_soft & bol_Dpuopt & bol_UpwindBedload;
        
            bol_mat=cat(1,bol_mat,bol_get);
        end %dpuopt
    end %ksoft
end %ku

end %function

%%

function [software_str,nx,upwindbedload_str,dpuopt_str]=get_strings(data)

switch data.software
    case 1
        software_str='D3D';
    case 2
        software_str='FM';
end

nx=data.nx;

switch data.UpwindBedload
    case 1
        upwindbedload_str='upwind';
    case 0
        upwindbedload_str='central';
end

switch data.Dpuopt
    case 1
        dpuopt_str='min';
    case 2
        dpuopt_str='mean';
end

end %function

%% 

function [z,tit_str,str_leg]=select_data_write_string(data_get)

m1=[data_get.Dpuopt;data_get.software;data_get.UpwindBedload;data_get.nx]';
idx_var=find(sum(diff(m1,1,1)~=0,1),1); %index of the column in which there is variation in `m1`
if size(idx_var)~=1
    error('Only 1 variation is accepted.')
end
z=m1(:,idx_var);

zu=unique(m1(:,idx_var));
nu=numel(zu);
str_leg=cell(nu,1);
switch idx_var
    case 1
        for ku=1:nu
            if zu(ku)==1
                str_leg{ku}='min';
            elseif zu(ku)==2
                str_leg{ku}='mean';
            end
        end
        [software_str,nx,upwindbedload_str,dpuopt_str]=get_strings(data_get(1));
        tit_str=sprintf('%s, nx=%d, %s',software_str,nx,upwindbedload_str);
    case 2
        for ku=1:nu
            if zu(ku)==1
                str_leg{ku}='D3D';
            elseif zu(ku)==2
                str_leg{ku}='FM';
            end
        end
        [software_str,nx,upwindbedload_str,dpuopt_str]=get_strings(data_get(1));
        tit_str=sprintf('%s, nx=%d, %s',dpuopt_str,nx,upwindbedload_str);
    case 3
        for ku=1:nu
            if zu(ku)==0
                str_leg{ku}='central';
            elseif zu(ku)==1
                str_leg{ku}='upwind';
            end
        end
        [software_str,nx,upwindbedload_str,dpuopt_str]=get_strings(data_get(1));
        tit_str=sprintf('%s, nx=%d, %s',dpuopt_str,nx,software_str);
    case 4
        for ku=1:nu
            str_leg{ku}=sprintf('nx=%2d',zu(ku));
        end
        [software_str,nx,upwindbedload_str,dpuopt_str]=get_strings(data_get(1));
        tit_str=sprintf('%s, %s, %s',dpuopt_str,upwindbedload_str,software_str);
    otherwise
        error('ups...')
end

end %function