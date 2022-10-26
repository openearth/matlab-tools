%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 5 $
%$Date: 2022-02-18 17:28:47 +0100 (Fri, 18 Feb 2022) $
%$Author: chavarri $
%$Id: adapt_input_bars.m 5 2022-02-18 16:28:47Z chavarri $
%$HeadURL: file:///P:/11206884-007-delft3d-fm/04-sensitivity-grid-type-and-resolution/scripts/svn/adapt_input_bars.m $
%
%Description

function simdef=adapt_input_01(input_m_s)

%% read reference

simdef.dummy=NaN;
simdef=input_D3D(simdef); %reference

%% input needed for analytical solution

%grid properties

    %how may times the length scale is the domain length
if isfield(input_m_s,'N_lb')
    N_lb=input_m_s.N_lb;
else
    N_lb=20; 
end

if isfield(simdef.ini,'noise_Lb') && isfield(input_m_s,'n_lb_x')
    simdef.grd.dx=simdef.ini.noise_Lb./input_m_s.n_lb_x;
elseif isfield(input_m_s,'dx')
    simdef.grd.dx=input_m_s.dx;
end

if isfield(input_m_s,'L')
    simdef.grd.L=input_m_s.L;
elseif isfield(simdef.grd,'L')==0
    simdef.grd.L=round(N_lb*simdef.ini.noise_Lb/simdef.grd.dx)*simdef.grd.dx;
end

if isfield(input_m_s,'noise_Lb')
    simdef.ini.noise_Lb=input_m_s.noise_Lb;
end

if isfield(input_m_s,'lb_y')
    simdef.grd.B=input_m_s.lb_y/2;
elseif isfield(input_m_s,'B')
    simdef.grd.B=input_m_s.B;
else
    if isfield(simdef.grd,'B')==0
        simdef.grd.B=simdef.grd.L;
    end
end

if isfield(input_m_s,'n_lb_y') 
    if isnan(input_m_s.n_lb_y)
        input_m_s.n_lb_y=input_m_s.n_lb_x;
    end
    simdef.grd.dy=input_m_s.lb_y./input_m_s.n_lb_y;
elseif isfield(input_m_s,'dy')
    if isnan(input_m_s.dy)
        simdef.grd.dy=simdef.grd.B;
    end
end

%% time 

tim_mod_thr=24*3600*30; %large time not to allow
nparts_res=30; %how many result times
        
if isfield(input_m_s,'q')
    q=input_m_s.q;
else
    q=simdef.ini.u.*simdef.ini.h;
end

c=q/simdef.ini.h+sqrt(simdef.mdf.g*simdef.ini.h);

if isfield(input_m_s,'n_l_prop')==0
    switch simdef.mor.BedUpd
        case 1 %morpho 
            n_l_prop=1; %how may times the length scale propagates in the simulation time
        case 2 %hydro
            n_l_prop=100;
    end
else
    n_l_prop=input_m_s.n_l_prop;
end

switch simdef.mor.BedUpd
    case 1 %morpho 
        [c_anl,~,~]=analytic_solution_morpho(simdef); %analytical solution
    case 2 %hydro
        c_anl=c;
        N_lb=1000;    %this should not be here...
end

% if isfield(input_m_s,'MorFac')==0
simdef.mor.MorFac=input_m_s.MorFac;

%input dependent on analytical solution
tim_mod=n_l_prop*simdef.ini.noise_Lb/c_anl; %desired simulation time with MF 1
if tim_mod>tim_mod_thr || tim_mod<0
    tim_mod=tim_mod_thr;
    fprintf('ATT! Time changed to a limit value \n');
end

if isfield(input_m_s,'CFL')
    simdef.mdf.CFL=input_m_s.CFL;
end

dt_opt=simdef.mdf.CFL*simdef.grd.dx/c; %optimum time step
% simdef.mdf.Dt=dt_opt; %time step [s] 

[simdef.mdf.Dt,simdef.mdf.Tstop,simdef.mdf.Flmap_dt,simdef.mor.MorStt]=D3D_adapt_time(dt_opt,tim_mod,simdef.mor.MorStt,simdef.mor.MorFac,nparts_res);

simdef.mdf.Flhis_dt=simdef.mdf.Flmap_dt(2)./10;

%% other input

if isfield(input_m_s,'structure')
    simdef.D3D.structure=input_m_s.structure;
end
simdef.bct.Q=q*simdef.grd.B;
simdef.ini.u=q/simdef.ini.h;

%grd
if isnan(simdef.grd.dy)
    simdef.grd.dy=simdef.grd.B;
    simdef.mdf.Tstop=7*24*3600+simdef.mor.MorStt; %the simulations for checking if bed level changes (1 cell wide) are longer
end

if isfield(input_m_s,'etab_noise')
    simdef.ini.etab_noise=input_m_s.etab_noise;
end

if isfield(input_m_s,'noise_amp')
    simdef.ini.noise_amp=input_m_s.noise_amp;
end

if isfield(input_m_s,'Dpuopt')
    simdef.mdf.Dpuopt=input_m_s.Dpuopt;
end

if isfield(input_m_s,'theta')
    simdef.mdf.theta=input_m_s.theta;
end

if isfield(input_m_s,'BedUpd')
    simdef.mor.BedUpd=input_m_s.BedUpd;
end

simdef.ini.noise_x0=[simdef.grd.L/2,simdef.grd.B/2];

%mor
% if input_m_s.test==2
%     simdef.mor.morphology=0;
%     simdef.mdf.C=NaN;
%     simdef.ini.s=0;
%     simdef.ini.etab0_type=2; 
%     simdef.ini.noise_x0=simdef.grd.L/2;
%     simdef.ini.etaw_noise=5;
%     simdef.ini.etab_noise=0;
%     simdef.mdf.CFL=0;
%     simdef.mdf.Vicouv=0.005;
%     simdef.mdf.Dicouv=0.005;
%     if simdef.D3D.structure==2
%         simdef.ini.noise_amp=-simdef.ini.noise_amp; %then it is switched again!
%     end
% else
    simdef.ini.s=q^2/simdef.ini.h.^3/simdef.mdf.C^2;
% end

if isfield(input_m_s,'UpwindBedload')
    simdef.mor.UpwindBedload=input_m_s.UpwindBedload;
end
if isfield(input_m_s,'BedloadScheme')
    simdef.mor.BedloadScheme=input_m_s.BedloadScheme;
end

%dire sim
simdef.runid.name=input_m_s.sim_id;
switch simdef.D3D.structure
    case 1
        ext='mdf';
    case 2
        ext='mdu';
end
fname_mdu=sprintf('%s.%s',simdef.runid.name,ext);
simdef.D3D.dire_sim=input_m_s.path_sim;

simdef.file.mdf=fullfile(simdef.D3D.dire_sim,fname_mdu);
% if ~isempty(path_input_folder)
%     simdef.file.grd=input_m_s.fpath_grd;
%     %     simdef.file.bcm=fullfile(path_input_folder,'bcm','bcm_00.bcm');
%     simdef.file.bc_wL=fullfile(path_input_folder,'bc','bc_wL_00.bc');
%     simdef.file.bc_q0=fullfile(path_input_folder,'bc','bc_q0_00.bc');
%     simdef.file.dep=input_m_s.fpath_dep;
%     %     simdef.file.dep=input_m.sim(ksim).fpath_waterlevel; %changed in situ
%     simdef.file.extn=input_m_s.fpath_extn;
%     simdef.file.mor=input_m_s.fpath_mor;
%     simdef.file.sed=input_m_s.fpath_sed;
%     simdef.file.fdir_pli=fullfile(path_input_folder,'pli');
%     simdef.file.fdir_pli_rel=sprintf('%s/pli/',path_input_folder_refmdf); %relative to mdu
%     simdef.file.fdir_bc_rel=sprintf('%s/bc/',path_input_folder_refmdf); %relative to mdu
% 
%     simdef.pli.fname_u=input_m_s.fname_pli_u;
%     simdef.pli.fname_d=input_m_s.fname_pli_d;
%     simdef.bc.fname_u=input_m_s.fname_bc_u;
%     simdef.bc.fname_d=input_m_s.fname_bc_d;
% 
%     simdef.mdf.grd=input_m_sim_loc.mdf(ksim).NetFile;
%     simdef.mdf.dep=input_m_sim_loc.mdf(ksim).BedlevelFile;
%     simdef.ini.etaw_file=input_m_sim_loc.mdf(ksim).WaterLevIniFile;
%     simdef.mdf.extn=input_m_sim_loc.mdf(ksim).ExtForceFileNew;
%     simdef.mdf.mor=input_m_sim_loc.mdf(ksim).MorFile;
%     simdef.mdf.sed=input_m_sim_loc.mdf(ksim).SedFile;
% end

%bat
% switch

%% observations

nobs=11;
simdef.mdf.obs_cord=[linspace(simdef.grd.dx,simdef.grd.L-simdef.grd.dx,nobs)',1000*ones(nobs,1)]; %coordinates of the observations points [x,y] [m] [double(np,2)] e.g. [0,0;1,0.5]    
for kobs=1:nobs
simdef.mdf.obs_name{kobs,1}=sprintf('s%02d',kobs); %name of the observation stations [-] [cell(np,1)] e.g. {'s1','s2'}
end

end %function

%%
% simdef.mor.MorStt=tim_mod_rd_hydro/nparts_res;
% simdef.mor.MorStt=ceil(simdef.mor.MorStt./nparts_res).*nparts_res;
% dt_app=simdef.mdf.Flmap_dt(2)./ceil(simdef.mdf.Flmap_dt(2)/dt_opt);