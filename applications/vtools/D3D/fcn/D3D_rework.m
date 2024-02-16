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
%generate other input parameters 

%INPUT:
%   -simdef.ini.s = bed slope [-] [integer(1,1)]; e.g. [3e-4] 
%   -simdef.ini.h = uniform flow depth [m] [double(1,1)]; e.g. [0.19]
%   -simdef.ini.u = uniform flow velocity [m/s] [double(1,1)]; e.g. [0.6452] 
%   -simdef.grd.L = domain length [m] [integer(1,1)] [100]
%   -simdef.ini.etab = initial downstream bed level [m] [double(1,1)] e.g. [0]
%   -simdef.bct.Q =  water discharge [m3/s]
%
%OUTPUT:
%   -node_number
%   -M 
%   -etab
%   -h
%   -u
%
%ATTENTION:
%   -Very specific for 1D case in positive x direction
%

function [simdef]=D3D_rework(simdef) 
%% RENAME IN

% L=simdef.grd.L;
% B=simdef.grd.B;
% dx=simdef.grd.dx;
% dy=simdef.grd.dy;
% ds=simdef.grd.dx;
% dn=simdef.grd.dy;
% Q=simdef.bct.Q;
% s=simdef_in.ini.s;
% h=simdef.ini.h;
% C=simdef_in.mdf.C;
% etab=simdef_in.mdf.etab;
% lambda=simdef.grd.lambda; % [m] wave length
% lambda_num=simdef.grd.lambda_num; % [-] number of wave lengths
% Tstop=simdef.mdf.Tstop;
% Dt=simdef.mdf.Dt;
% C=simdef.mdf.C;

simdef.mdf.vkappa=0.41; %von Karman

simdef.file.dummy=NaN;

%%
%% D3D
%%

simdef.D3D.dummy=NaN;

if isfield(simdef.D3D,'dire_sim')==0
    if isfield(simdef.runid,'serie')
        if strcmp(simdef.runid.serie,'Rhine')
            simdef.D3D.dire_sim=fullfile(file.main_folder,sprintf('%02d',runid.number));
        else
            simdef.D3D.dire_sim=fullfile(simdef.D3D.paths_runs,simdef.runid.serie,simdef.runid.number);
        end
    else
        simdef.D3D.dire_sim='';
    end
end
if isfield(simdef.D3D,'structure')==0
    simdef.D3D.structure=0;
end
if isfield(simdef.D3D,'OMP_num')==0
    simdef.D3D.OMP_num=NaN; %maximum
end

if ~isfield(simdef.file,'runid')
    simdef.file.runid=fullfile(simdef.D3D.dire_sim,'runid');
end

%default is serial computation in h7
simdef=D3D_rework_nodes(simdef);

%%
%% FILE
%%

%not needed when parameters passed through sed-file?
% switch simdef.D3D.structure
%     case 1
%         if isfield(simdef.file,'tra')==0
%             simdef.file.tra=fullfile(simdef.D3D.dire_sim,'tra.tra');
%         end
% end

if isfield(simdef.file,'exe_input')==0
    simdef.file.exe_input='c:\Program Files (x86)\Deltares\Delft3D Flexible Mesh Suite HMWQ (2021.03)\plugins\DeltaShell.Dimr\kernels\x64\dimr\scripts\run_dimr.bat';
end
if isfield(simdef.file,'exe_grd2map')==0
    simdef.file.exe_grd2map=simdef.file.exe_input;
end

%%
%% GRID
%%

simdef.grd.dummy=NaN;

if isfield(simdef.file,'grd')==0
    if simdef.D3D.structure==1
        simdef.file.grd=fullfile(simdef.D3D.dire_sim,'grd.grd');
    else
        simdef.file.grd=fullfile(simdef.D3D.dire_sim,'grd_net.nc');
    end
end

if isfield(simdef.grd,'cell_type')==0
    simdef.grd.cell_type=1;
end

%grid variables
if isfield(simdef.grd,'type')==0
    simdef.grd.type=0;
end

switch simdef.grd.type
    case 0
    case 1
        simdef.grd.node_number_x=simdef.grd.L/simdef.grd.dx; %number of nodes 
        simdef.grd.node_number_y=simdef.grd.B/simdef.grd.dy; %number of nodes 
        simdef.grd.M=simdef.grd.node_number_x+2; %M (number of cells in x direction)
        simdef.grd.N=simdef.grd.node_number_y+2; %N (number of cells in y direction)


        if rem(simdef.grd.node_number_x,1) || rem(simdef.grd.node_number_y,1) 
            error('Make L and B to be multiples of dx and dy')
        end
    case 2
        mmax=round(simdef.grd.lambda_num*simdef.grd.lambda/ds);
        nmax=floor(simdef.grd.B/simdef.grd.dy*2);
        
        simdef.grd.M=mmax+1; %M (number of cells in x direction)
        simdef.grd.N=nmax+1; %N (number of cells in y direction)
        simdef.grd.node_number_x=simdef.grd.M-2; %number of nodes 
        simdef.grd.node_number_y=simdef.grd.N-2; %number of nodes 
        simdef.grd.L=simdef.grd.node_number_x*dx;
    case 3
        simdef.grd.node_number_y=round(simdef.grd.B/simdef.grd.dy); %number of nodes
        simdef.grd.node_number_x=ceil(simdef.grd.L1/simdef.grd.dx)+ceil(simdef.grd.L2/simdef.grd.dx)+round(simdef.grd.R*2*pi*simdef.grd.angle/360/simdef.grd.dx); %number of nodes
        
        simdef.grd.M=simdef.grd.node_number_x+2; %M (number of cells in x direction)
        simdef.grd.N=simdef.grd.node_number_y+2; %N (number of cells in y direction)
    otherwise
        error('idiot...')    
        
end

%uniform flow
% if isnan(simdef.ini.h)
%     error('add call to equilibrium')
%     h=((Q/B)^2./C^2./s).^(1/3);
%     etab=-h(end);
% end

%%
%% SED
%%

simdef.sed.dummy=NaN;

if isfield(simdef.file,'sed')==0
    simdef.file.sed=fullfile(simdef.D3D.dire_sim,'sed.sed');
end

if isfield(simdef.sed,'dk')==0
    simdef.sed.dk=[];
end

%%
%% TRA
%%

simdef=D3D_sedTrans_default(simdef);
simdef=D3D_sedTyp_default(simdef);

nf=numel(simdef.sed.dk);

for kf=1:nf
    if simdef.tra.IFORM(kf)==-3 && simdef.tra.SedTyp(kf)~=1
        warning('With Partheniades-Krone the sediment type must be mud. It has been changed.')
        simdef.tra.SedTyp(kf)=1;
    end
end

%%
%% MDF
%%

simdef.mdf.dummy=NaN;

%grd
[~,fname,fext]=fileparts(simdef.file.grd); %should always be in simulation folder
simdef.mdf.grd=sprintf('%s%s',fname,fext);

%secondary flow
if isfield(simdef.mdf,'secflow')
    
else
    simdef.mdf.secflow=0;
end

%times computed
if isfield(simdef.mdf,'nparts_res')
    c=simdef.ini.u+sqrt(simdef.mdf.g*simdef.ini.h);
    dt_opt=simdef.mdf.CFL*simdef.grd.dx/c; %optimum time step
    [simdef.mdf.Dt,simdef.mdf.Tstop,simdef.mdf.Flmap_dt,simdef.mor.MorStt]=D3D_adapt_time(dt_opt,simdef.mdf.Tstop,simdef.mor.MorStt,simdef.mor.MorFac,simdef.mdf.nparts_res);
end

%time units
if isfield(simdef.mdf,'Tunit')==0
    simdef.mdf.Tunit='S';
    simdef.mdf.Tfact=1; %input is in seconds
end

%start time
if isfield(simdef.mdf,'Tstart')==0
    simdef.mdf.Tstart=0;
end

%stop time
if isfield(simdef.mdf,'Tstop')==0
    error('You need to provide Tstop')
end

%dt
if isfield(simdef.mdf,'Dt')==0
    warning('There was no Dt. It is set to 1. In FM used to round of times.')
    simdef.mdf.Dt=1;
end
if numel(simdef.mdf.Dt)>1
    error('Dimension of <Dt> should be 1')
end

%restart
if isfield(simdef.mdf,'restart')==0
    simdef.mdf.restart=0;
end

if simdef.mdf.restart==1
    simdef.mdf.Tunit='M'; %there is a bug with the time units. when you restart a simulation it only works when the units are minutes
    simdef.mdf.Tfact=1/60; %input is in seconds
end

%rework stop time
if rem(simdef.mdf.Tstop,simdef.mdf.Dt)~=0
    simdef.mdf.Tstop=(floor(simdef.mdf.Tstop/simdef.mdf.Dt)+1)*simdef.mdf.Dt; %output in seconds
    warning('Simulation time does not match with time step. I have changed the simulation time.')
end

    %Add one time step in FM such that the output at the N-1 time is at the time we wanted using the output interval for sure
if simdef.D3D.structure==2
    simdef.mdf.Tstop=simdef.mdf.Tstop+2*simdef.mdf.Dt;
end

%map time
if isfield(simdef.mdf,'Flmap_dt')==0
    warning('you are not saving map results')
    simdef.mdf.Flmap_dt=[0,0]; %start, interval
else
    if numel(simdef.mdf.Flmap_dt)==1
        simdef.mdf.Flmap_dt=[0,simdef.mdf.Flmap_dt];
    elseif numel(simdef.mdf.Flmap_dt)==2
    else
        error('Flmap_dt [start,interval]')
    end
    if rem(simdef.mdf.Flmap_dt(2),simdef.mdf.Dt)~=0 
        warning('Map results time is not multiple of time step. I am rewring the map results time.')
        simdef.mdf.Flmap_dt=[simdef.mdf.Flmap_dt(1),(floor(simdef.mdf.Flmap_dt(2)/simdef.mdf.Dt)+1)*simdef.mdf.Dt];
    end
    
%     if simdef.D3D.structure==2 
        %In case of FM floor start time time for preventing that the last result time is not written. It is a bit dangerous. 
%         simdef.mdf.Flmap_dt(1)=floor(simdef.mdf.Flmap_dt(1));
        %A better option is to finish the simulation slighlty later
%         simdef.mdf.Flmap_dt(2)=floor(simdef.mdf.Flmap_dt(2));
%     end
end

%history time and observations file
if ~isfield(simdef.mdf,'Flhis_dt')
    simdef.mdf.Flhis_dt=0;
end
if simdef.mdf.Flhis_dt==0
    simdef.mdf.obs_filename='';
    simdef.file.obs='';

    simdef.mdf.crs_filename='';
    simdef.file.crs='';
end
if ~isfield(simdef.file,'obs') && simdef.mdf.Flhis_dt>0
    switch simdef.D3D.structure
        case 1
            simdef.file.obs=fullfile(simdef.D3D.dire_sim,'obs.obs');
            simdef.mdf.obs_filename='obs.obs';
        case 2
            simdef.file.obs=fullfile(simdef.D3D.dire_sim,'obs.xyn');
            simdef.mdf.obs_filename='obs.xyn';
    end
end
if ~isfield(simdef.file,'crs') && simdef.mdf.Flhis_dt>0
    switch simdef.D3D.structure
        case 1
            simdef.file.crs=fullfile(simdef.D3D.dire_sim,'crs.crs');
            simdef.mdf.crs_filename='crs.crs';
        case 2
            simdef.file.crs=fullfile(simdef.D3D.dire_sim,'crs.xyn');
            simdef.mdf.crs_filename='crs.xyn';
    end
end

if simdef.mdf.Flhis_dt>0 && rem(simdef.mdf.Flhis_dt,simdef.mdf.Dt)~=0 
    warning('History results time is not multiple of time step. I am rewring the history results time.')
    simdef.mdf.Flhis_dt=(floor(simdef.mdf.Flhis_dt/simdef.mdf.Dt)+1)*simdef.mdf.Dt;
end

%gravity
if isfield(simdef.mdf,'g')==0
    simdef.mdf.g=9.81;
end

%friction
if isfield(simdef.mdf,'C')==0
    simdef.mdf.C=NaN;
%     error('specify friction coefficient, even though it is not used') %why?
end
if isnan(simdef.mdf.C) %no friction
    switch simdef.D3D.structure
        case 1
            simdef.mdf.C=5e3;
        case 2
            simdef.mdf.C=0;
    end
% if simdef.mdf.C==0 && simdef.D3D.structure=1
%     error('friction coefficient cannot be 0 in D3D4
%     warning('You may not want to specify friction (i.e., friction type = 10), then, set the coefficient to 1, but not zero!')
end
%in d3d, even when friction is set to constant, it accounts for some
%roughness height that messes all... I think it is incorrect. Here I solve
%it 
% Cw=30.712688432783460;
% vkappa=0.41;
% simdef.mdf.g=9.81;
if isfield(simdef.mdf,'correct_C')==0
    simdef.mdf.correct_C=0;
end
if simdef.mdf.correct_C==1
    simdef.mdf.C=sqrt(simdef.mdf.g)/simdef.mdf.vkappa*log(-1+exp(simdef.mdf.C*simdef.mdf.vkappa/sqrt(simdef.mdf.g)));
end
% Cin =sqrt(simdef.mdf.g)/vkappa*log(-1+exp(Cw *vkappa/sqrt(simdef.mdf.g)));
% Cd3d=sqrt(simdef.mdf.g)/vkappa*log(+1+exp(Cin*vkappa/sqrt(simdef.mdf.g)));

if isfield(simdef.mdf,'wall_rough')==0
    simdef.mdf.wall_rough=0;
    simdef.mdf.wall_ks=0;
end
if simdef.mdf.wall_rough==1 && isfield(simdef.mdf,'wall_ks')==0
    error('specify wall friction!')
end

%2D/3D

switch simdef.D3D.structure
    case 1
        if isfield(simdef.grd,'K')==0
            simdef.grd.K=1; 
        end
    case 2
        if isfield(simdef.grd,'K')==0
            simdef.grd.K=0; 
        end
        if simdef.grd.K==1
            warning('You want a 3D computation with one layer')
        end    
        if isfield(simdef.grd,'Thick') && simdef.grd.K>0 && simdef.D3D.structure==2
            warning('You want a 3D computation with varying layer thickness. This is not yet possible')
        end
end

if isfield(simdef.grd,'Thick')==0
    simdef.grd.Thick=(1./(simdef.grd.K.*ones(1,simdef.grd.K-1)))*100;
end

if isfield(simdef.mdf,'Flrst_dt')==0
    simdef.mdf.Flrst_dt=0;
end
 
if isfield(simdef.mdf,'filter')==0
    simdef.mdf.filter=0;
end

if isfield(simdef.mdf,'Dpsopt')==0
    simdef.mdf.Dpsopt='MEAN';
end
if isfield(simdef.mdf,'Dpuopt')==0
    simdef.mdf.Dpuopt=1; %this is default. Most accurate is <mean_dps>
end
if ischar(simdef.mdf.Dpuopt)
    switch simdef.mdf.Dpuopt
        case 'min_dps'
            simdef.mdf.Dpuopt=1;
        case 'mean_dps'
            simdef.mdf.Dpuopt=2;
        otherwise
            error('here')
    end
end

if isfield(simdef.mdf,'ExtrBl')==0
    simdef.mdf.ExtrBl=0;
end

% if strcmp(simdef.mdf.Dpsopt,'MEAN')~=1
%     error('adjust flow depth file accordingly')
% end

if isfield(simdef.mdf,'ext')==0
    simdef.mdf.ext='ext.ext';
end

if isfield(simdef.mdf,'extn')==0
    simdef.mdf.extn='bnd.ext';
end

if isfield(simdef.mdf,'mor')==0
    simdef.mdf.mor='mor.mor';
end

if isfield(simdef.mdf,'sed')==0
    simdef.mdf.sed='sed.sed';
end

if simdef.D3D.structure==1
if isfield(simdef.mdf,'tra')==0
    simdef.mdf.tra='tra.tra';
end
end

if isfield(simdef.mdf,'izbndpos')==0
    if simdef.D3D.structure==1
        simdef.mdf.izbndpos=0;
    else
        simdef.mdf.izbndpos=1;
    end
end

if isfield(simdef.mdf,'CFLMax')==0
    simdef.mdf.CFLMax=0.7;
end

if isfield(simdef.mdf,'TransportAutoTimestepdiff')==0
    simdef.mdf.TransportAutoTimestepdiff=1;
end

if isfield(simdef.mdf,'theta')==0
    simdef.mdf.theta=0.55;
end

if isfield(simdef.mdf,'Removesmalllinkstrsh')==0
    simdef.mdf.Removesmalllinkstrsh=0.1;
end

if isfield(simdef.mdf,'Idensform')==0
    simdef.mdf.Idensform=0;
end

%%
%% MOR
%%

simdef.mor.dummy=NaN;

if isfield(simdef.file,'mor')==0
    simdef.file.mor=fullfile(simdef.D3D.dire_sim,'mor.mor');
end

nf=numel(simdef.sed.dk);
if nf==1
    simdef.mor.IUnderLyr=1;
else
    simdef.mor.IUnderLyr=2;
end

if isfield(simdef.mor,'CondPerNode')==0
    simdef.mor.CondPerNode=0;
end
switch simdef.mor.CondPerNode
    case 0
        simdef.mor.upstream_nodes=1;
    case 1
%         if simdef.grd.type~=3
%             error('CondPerNode for another grid wich is not DHL is not implemented')
%         end
        simdef.mor.upstream_nodes=simdef.grd.node_number_y;
        
end

if isfield(simdef.mor,'IBedCond')==0
    simdef.mor.IBedCond=NaN;
end

if isfield(simdef.mor,'UpwindBedload')==0
    simdef.mor.UpwindBedload=1;
end
if isfield(simdef.mor,'BedloadScheme')==1
    simdef.mor.UpwindBedload=NaN;
else
    simdef.mor.BedloadScheme=NaN;
end
if isfield(simdef.mor,'SedThr')==0
    simdef.mor.SedThr=1e-3;
end
if isfield(simdef.mor,'AlfaBs')==0
    simdef.mor.AlfaBs=0;
end
if isfield(simdef.mor,'ThetSD')==0
    simdef.mor.ThetSD=0;
end
if isfield(simdef.mor,'HMaxTH')==0
    simdef.mor.HMaxTH=0;
end

if isfield(simdef.file,'mini')==0
    simdef.file.mini=fullfile(simdef.D3D.dire_sim,'mini.ini');
end

%% 
%% BCM
%%

simdef.bcm.dummy=NaN;

% if isfield(simdef.bcm,'fname')==0
if isfield(simdef.file,'bcm')==0
%     simdef.bcm.fname=fullfile(simdef.D3D.dire_sim,'bcm.bcm');
    simdef.file.bcm=fullfile(simdef.D3D.dire_sim,'bcm.bcm');
end

switch simdef.mor.IBedCond
    case 3
        if simdef.D3D.structure==2
            simdef.mor.IBedCond=7; %I change the sign of 3 in structured, so in all cases it is 7
        end
    case 5
        time=simdef.bcm.time;
        nt=length(time);
        transport=simdef.bcm.transport;
        [nt_a,nf_a]=size(transport);
        if nf>0
            if nf_a~=nf
                error('Inconsistent input in simdef.bcm.transport')
            end
        end
        if nt_a~=nt
            error('Time does not match transport')
        end
end

if isfield(simdef.bcm,'location')==0
    simdef.bcm.location=cell(simdef.mor.upstream_nodes,1);
    for kn=1:simdef.mor.upstream_nodes
        simdef.bcm.location{kn,1}=sprintf('Upstream_%02d',kn); 
    end
end
        
%% ILL-POSEDNESS

if isfield(simdef.mor,'HiranoCheck')==0
    simdef.mor.HiranoCheck=0;
end
if isfield(simdef.mor,'HiranoRegularize')==0
    simdef.mor.HiranoRegularize=0;
end
if isfield(simdef.mor,'HiranoDiffusion')==0
    simdef.mor.HiranoDiffusion=1;
end
if simdef.mor.HiranoRegularize==1 && simdef.mor.HiranoCheck==0
    error('You want to regularize the active layer model but you don''t want to check for ill-posedness')
end
if simdef.mor.HiranoRegularize==1 && simdef.mdf.Dicouv==0
    error('You want to regularize the active layer model but the diffusion coefficient of trachitops (simdef.mdf.Dicouv) is set to 0. This should not be a problem, but in the way it is implemented simdef.mdf.Dicouv needs to be different than 0 to work')
end

%%
%% FINI
%%

simdef.ini.dummy=NaN;

if isfield(simdef.ini,'etaw_type')==0
    simdef.ini.etaw_type=1;
end

if isfield(simdef.ini,'h')==0
    simdef.ini.h=NaN;
end

if isfield(simdef.ini,'u')==0
    simdef.ini.u=0;
end

if isfield(simdef.ini,'v')==0
    simdef.ini.v=0;
end

if simdef.D3D.structure==1
    if isfield(simdef.file,'fini')==0
        simdef.file.fini=fullfile(simdef.D3D.dire_sim,'fini.ini');
    end
    if isfield(simdef.ini,'I0')==0
        simdef.ini.I0=0;
    end
else
    if isfield(simdef.file,'ext')==0
        simdef.file.ext=fullfile(simdef.D3D.dire_sim,'ext.ext');
    end
    if isfield(simdef.file,'etaw')==0
        simdef.file.etaw=fullfile(simdef.D3D.dire_sim,'etaw.xyz');
    end
    if isfield(simdef.ini,'etaw_file')==0
        simdef.ini.etaw_type='etaw.xyz'; %? why?
    end
    if isfield(simdef.file,'ini_vx')==0
        simdef.file.ini_vx=fullfile(simdef.D3D.dire_sim,'ini_vx.xyz');
    end
    if isfield(simdef.file,'ini_vy')==0
        simdef.file.ini_vy=fullfile(simdef.D3D.dire_sim,'ini_vy.xyz');
    end
end
    
if isfield(simdef.ini,'etab0_type')==0
    simdef.ini.etab0_type=1;
end
switch simdef.ini.etab0_type
    case {1,2}
    case 3
        aux_dim=size(simdef.ini.xyz);
        if aux_dim(2)~=3
            error('dimensions do not agree')
        end
    otherwise
        error('etab0_type nonexistent')
end

if isfield(simdef.ini,'etaw_noise')==0
    simdef.ini.etaw_noise=0;
end

%%
%% RUNID
%%

switch simdef.D3D.structure
    case 1
        ext='mdf';
    case 2
        ext='mdu';
end

simdef.runid.dummy=NaN;
if isfield(simdef.runid,'name')==0
    if isfield(simdef.runid,'number')
        if isa(simdef.runid.number,'double')
            error('specify runid as string')
        end
    end
%     simdef.runid.name=sprintf('sim_%s%s.%s',simdef.runid.serie,simdef.runid.number,ext);
    simdef.runid.name=sprintf('r%s%s.%s',simdef.runid.serie,simdef.runid.number,ext);
end


if isfield(simdef.file,'mdf')==0
    fname_mdu=sprintf('%s.%s',simdef.runid.name,ext);
    simdef.file.mdf=fullfile(simdef.D3D.dire_sim,fname_mdu);
end

%% 
%% DEP
%%

if isfield(simdef.file,'dep')==0
    switch simdef.D3D.structure
        case 1
            simdef.mdf.dep='dep.dep';
            simdef.file.dep=fullfile(simdef.D3D.dire_sim,'dep.dep');
        case 2
            simdef.mdf.dep='dep.xyz';
            simdef.file.dep=fullfile(simdef.D3D.dire_sim,'dep.xyz');
    end
end

%%
%% PLI
%%

simdef.pli.dummy=NaN;
if isfield(simdef.file,'fdir_pli')==0
    simdef.file.fdir_pli=simdef.D3D.dire_sim;
    simdef.file.fdir_pli_rel='';
end

if isfield(simdef.pli,'fname_u')==0
    simdef.pli.fname_u='Upstream';
end

if isfield(simdef.pli,'str_bc_u')==0
    simdef.pli.str_bc_u='bc_q0';    
end

if isfield(simdef.pli,'fname_d')==0
    simdef.pli.fname_d='Downstream';
end

if isfield(simdef.pli,'str_bc_d')==0
    simdef.pli.str_bc_u='bc_wL';    
end

%%
%% EXTN
%%

if isfield(simdef.file,'bc_wL')==0
    simdef.file.bc_wL=fullfile(simdef.D3D.dire_sim,'bc_wL.bc');    
end

if isfield(simdef.file,'bc_q0')==0
    simdef.file.bc_q0=fullfile(simdef.D3D.dire_sim,'bc_q0.bc');    
end

if isfield(simdef.file,'extn')==0
    simdef.file.extn=fullfile(simdef.D3D.dire_sim,'bnd.ext');
end

%%
%% BC
%%

if isfield(simdef.file,'fdir_bc_rel')==0
    simdef.file.fdir_bc_rel='';
end

simdef.bc.dummy=NaN;
if isfield(simdef.bc,'fname_u')==0
    simdef.bc.fname_u='bc_q0';
end
if isfield(simdef.bc,'fname_d')==0
    simdef.bc.fname_d='bc_wL';
end

%%
%% BCT
%%

if ~isfield(simdef.file,'bct')
    switch simdef.D3D.structure
        case 1
            simdef.file.bct=fullfile(simdef.D3D.dire_sim,'bct.bct'); 
        case 2
            simdef.file.bct=simdef.file.bc_wL; %we copy the value in D3D4 to check whether it exists or not
    end
end

%discharge
if isfield(simdef.bct,'time_Q')==0
    simdef.bct.time_Q=[simdef.mdf.Tstart;simdef.mdf.Tstop];
end
if numel(simdef.bct.Q)==1
    simdef.bct.Q=simdef.bct.Q.*ones(size(simdef.bct.time_Q));
end
if any(size(simdef.bct.time_Q)-size(simdef.bct.Q))
    error('dimensions of Q boundary condition do not agree')
end

%add extra time with same value as last in case the last time step gets outside the domain
if simdef.D3D.structure==2
simdef.bct.Q=cat(1,simdef.bct.Q,simdef.bct.Q(end));
simdef.bct.time_Q=cat(1,simdef.bct.time_Q,simdef.bct.time_Q(end)*1.1);
end

%water level
if isfield(simdef.bct,'time')==0
    simdef.bct.time=[simdef.mdf.Tstart;simdef.mdf.Tstop];
end
if numel(simdef.bct.etaw)==1
    simdef.bct.etaw=simdef.bct.etaw.*ones(size(simdef.bct.time));
end
if any(size(simdef.bct.time)-size(simdef.bct.etaw))
    error('dimensions of etaw boundary condition do not agree')
end
    %correcting for last cell
%In D3D4 we correct. 
%In FM with Dpuopt=1 we correct.
%In FM with Dpuopt=2 it is one full dx, not half. 
switch simdef.D3D.structure
    case 1
        if simdef.mdf.izbndpos==0 
            simdef.bct.etaw=simdef.bct.etaw-simdef.grd.dx/2*simdef.ini.s; %displacement of boundary condition to ghost node
        end
    case 2
        if simdef.mdf.izbndpos==0 && simdef.mdf.Dpuopt==1
            simdef.bct.etaw=simdef.bct.etaw-simdef.grd.dx/2*simdef.ini.s; %displacement of boundary condition to ghost node
        elseif simdef.mdf.Dpuopt==2
            simdef.bct.etaw=simdef.bct.etaw-simdef.grd.dx*simdef.ini.s; %displacement of boundary condition to ghost node
        end
end
    %correcting for dpuopt. 
if simdef.D3D.structure==1
    %The truth is that I am not sure why I do not need it for FM. 
    
    %This correction only makes sense in idealistic cases maybe. If bed level at velocity points is 'min' in an ideal case (normal flow, sloping case),
    %there is a shift of half a cell in the water level at velocity points. To start under normal flow, we correct for that shift in the BC. 
    if strcmp(simdef.mdf.Dpuopt,'min_dps')
        warning('correction of BC')
        simdef.bct.etaw=simdef.bct.etaw+simdef.grd.dx/2*simdef.ini.s;

        %as a consequence, the flow depth at the water level point is larger than it should and the velocity smaller. We correct the sedimen transport rate. 
        %ACal_corrected=ACal*qb_intended/qb_wrong
        %qb_wrong: sediment transport with the wrong velocity at water level point
        switch simdef.tra.IFORM
            case 4
                if simdef.tra.sedTrans(3)==0
                    warning('correction ACal')
                    h_wrong=simdef.ini.h+simdef.ini.s*simdef.grd.dx/2;
                    u_wrong=simdef.bct.Q(1)/simdef.grd.B/h_wrong;
                    simdef.tra.sedTrans(1)=simdef.tra.sedTrans(1)*(simdef.ini.u/u_wrong)^(simdef.tra.sedTrans(2)*2);
                else
                    messageOut(NaN,'A correction should be applied to <ACal>')
                end
            otherwise
                messageOut(NaN,'A correction should be applied to <ACal>')
        end
    end
end


%add extra time with same value as last in case the last time step gets outside the domain
if simdef.D3D.structure==2
simdef.bct.etaw=cat(1,simdef.bct.etaw,simdef.bct.etaw(end));
simdef.bct.time=cat(1,simdef.bct.time,simdef.bct.time(end)*1.1);
end

%%
%% BCC
%%

%for D3D4 we need to write a BCC file if there is a suspended sediment 
%fraction even if Neumann BC are imposed. 

%if the file name does not exists, we create an empty one. If empty we 
%do not write it.
if ~isfield(simdef.file,'bcc')
    simdef.file.bcc=''; 
    %if a file is needed, we add the name
    if simdef.D3D.structure==1 && ~isempty(simdef.tra.SedTyp) && any(ismember(simdef.tra.SedTyp,[1,2]))
        simdef.file.bcc=fullfile(simdef.D3D.dire_sim,'bcc.bcc');
    end
end

if ~isfield(simdef,'bcc')
    simdef.bcc=D3D_bcc_dummy(simdef);
end

%%
%% BND
%%

if ~isfield(simdef.file,'bnd')
    switch simdef.D3D.structure
        case 1
            simdef.file.bnd=fullfile(simdef.D3D.dire_sim,'bnd.bnd');
        case 2
            simdef.file.bnd=simdef.file.extn;
    end
end

%% RENAME OUT

% simdef.grd.M=M;
% simdef.grd.N=N;
% % simdef_out.ini.etab=etab;
% simdef.ini.h=h;
% simdef.ini.u=u;
% simdef.grd.L=L;


end %function

%%
%% FUNCTIONS
%%

function bcc=D3D_bcc_dummy(simdef)

nf=numel(simdef.sed.dk);
bcc.NTables=simdef.mor.upstream_nodes+1; %upstream and downstream
kc=0;
%the prder of the tables matter. First all sediment for one boundary and
%then all sediment for the other boundary
    %upstream
for ku=1:simdef.mor.upstream_nodes
    for kf=1:nf
        kc=kc+1;
        bcc.Table(kc)=D3D_bcc_table_dummy(simdef,ku,sprintf('Upstream_%02d',ku),kf);
    end
end %ku
    %downstream
for kf=1:nf
    kc=kc+1;
    ku=simdef.mor.upstream_nodes+1;
    bcc.Table(kc)=D3D_bcc_table_dummy(simdef,ku,'Downstream',kf);
end %kf

end %function

%%

function bcc_tab=D3D_bcc_table_dummy(simdef,ku,location,kf)

bcc_tab.Name=sprintf('Boundary Section : %d',ku);
bcc_tab.Contents='Uniform';
bcc_tab.Location=location;
bcc_tab.TimeFunction='non-equidistant';
bcc_tab.ReferenceTime=20000101; %`Itdate` is harcoded in mdu. It would be better to read the mdu file here. 
bcc_tab.TimeUnit='seconds';
bcc_tab.Interpolation='linear';
%para
bcc_tab.Parameter(1).Name='time';
bcc_tab.Parameter(1).Unit='[sec]';
bcc_tab.Parameter(2).Name=sprintf('Sediment%d           end A uniform',kf);
bcc_tab.Parameter(2).Unit='[kg/m3]';
bcc_tab.Parameter(3).Name=sprintf('Sediment%d           end B uniform',kf);
bcc_tab.Parameter(3).Unit='[kg/m3]';
%data
bcc_tab.Data=zeros(2,3);
bcc_tab.Data(2,1)=simdef.mdf.Tstop;

end
