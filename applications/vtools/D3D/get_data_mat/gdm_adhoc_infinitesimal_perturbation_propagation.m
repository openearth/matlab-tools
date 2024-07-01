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

[~,~,tag_serie]=gdm_tag_fig(flg_loc);
tag_fig='ipp';

%path to mat file with results from all simulations
% fdir_mat=simdef(1).file.mat.dir;
% fpath_mat=fullfile(fdir_mat,'infinitesimal_perturbation_propagation.mat');
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%time
[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%assume same matrices for all cases, we load only once
ks=1;
fpath_simdef=fullfile(simdef(ks).file.dire_sim);
load(fpath_simdef,'simdef')
ECT_input=D3D_input_2_ECT_input(simdef); %convert simdef to ECT_input
[ECT_matrices,sed_trans]=call_ECT(ECT_input);


in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

%% loop on simulations

ns=numel(simdef);
for ks=1:ns
    fdir_mat=simdef(ks).file.mat.dir;
    fpath_mat=fullfile(fdir_mat,'ipp.mat');
    fdir_fig=fullfile(simdef(ks).file.fig.dir,tag_fig,tag_serie); 

    %if exists file, skip loop
    if isfile(fpath_mat) && ~overwrite
        messageOut(fid_log,sprintf('File exists, loading: %s',fpath_mat));
        load(fpath_mat,'data');
        data_all(ks)=data;
        continue
    end

    %load simdef
    fpath_simdef=fullfile(simdef(ks).file.dire_sim);
    load(fpath_simdef,'simdef')

    %compute analytical celerity and wave dampening
    in_2D.kwx_v=2*pi/simdef.ini.noise_Lb;
    in_2D.kwy_v=2*pi/(simdef.grd.B*2);
    
    [eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
    [kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m]=derived_variables_twoD_study(ECT_input.h,eig_r,eig_i,kwx_v,kwy_v,kw_m);

    %compute observed celerity and wave dampening
    [c_obs,w_obs,ls]=gdm_compute_observed_wave_propagation(flg_loc,simdef,time_dnum);

    %plot waves: initial, filtered, initial guess
    in_p.ls=ls;
    in_p.fname=fullfile(fdir_fig,'sinus');

    fig_sinus(in_p);

    %save to mat
    [lambda,beta]=nondim_bar_variables(1,simdef.ini.noise_Lb,simdef.grd.B*2);

    data.Lb=simdef.ini.noise_Lb;
    data.B=simdef.grd.B;
    data.lambda=lambda;
    data.beta=beta;
    data.c_anl=c_morph_p;
    data.w_anl=max_gr_p;
    data.c_obs=c_obs;
    data.w_obs=w_obs;
    data.nx=simdef.ini.noise_Lb/simdef.grd.dx;

    save(fpath_mat,'data');

end %ks

%% plot

%scatter comparing observed against predicted celerity
ks=1;
fdir_fig=fullfile(simdef(ks).file.fig.dir,tag_fig,tag_serie); 
in_p.fname=fullfile(fdir_fig,'c');
in_p.x=[data_all.Lb];
in_p.y_anl=[data_all.c_anl];
in_p.y_obs=[data_all.c_obs];
in_p.z=[data_all.nx];
in_p.x_lab='wave length [m]';
in_p.y_lab='celerity [m/s]';

fig_ipp_scatter(in_p);

%scatter comparing observed against predicted wave dampening
%scatter comparing lambda-beta-celerity for analytical (left) and observed (right) 
%scatter comparing lambda-beta-dampening for analytical (left) and observed (right)

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

lambda=2*pi/B2; %should be the same for both waves

c=abs(C2-C1)*lambda/(2*pi)/dt;
w=log(A2/A1)/dt;

end %function

%%

function [c,w,ls]=gdm_compute_observed_wave_propagation(flg_loc,simdef,time_dnum)

%pli name
kpli=1; %we assume there is only 1
fpath_pli=flg_loc.pli{kpli,1};
pliname=gdm_pli_name(fpath_pli);

kvar=1; %it must be h
varname=flg_loc.var{kvar};
var_str=D3D_var_num2str_structure(varname,simdef);

%load ls section before and after
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(1),'var',var_str,'pli',pliname); %1 or 2?
fpath_ls{1}=fpath_mat_tmp;

fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(end),'var',var_str,'pli',pliname); 
fpath_ls{2}=fpath_mat_tmp;

[c,w,ls]=gdm_compute_sinus_propagation(fpath_ls);

end %function
