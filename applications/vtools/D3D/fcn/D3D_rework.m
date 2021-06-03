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

vkappa=0.41; %von Karman

%%
%% GRID
%%

simdef.grd.dummy=NaN;

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
%% MDF
%%

simdef.mdf.dummy=NaN;

%secondary flow
if isfield(simdef.mdf,'secflow')
    
else
    simdef.mdf.secflow=0;
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
    simdef.mdf.Tstop=NaN;
end

%dt
if isfield(simdef.mdf,'Dt')==0
    simdef.mdf.Dt=NaN;
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

%map time
if isfield(simdef.mdf,'Flmap_dt')==0
    warning('you are not saving map results')
    simdef.mdf.Flmap_dt=0;
else
    if rem(simdef.mdf.Flmap_dt,simdef.mdf.Dt)~=0 
        warning('Map results time is not multiple of time step. I am rewring the map results time.')
        simdef.mdf.Flmap_dt=(floor(simdef.mdf.Flmap_dt/simdef.mdf.Dt)+1)*simdef.mdf.Dt;
    end
end

%history time and observations filr
simdef.mdf.obs_filename='obs.xyn';
if isfield(simdef.mdf,'Flhis_dt')==0
    simdef.mdf.Flhis_dt=0;
    simdef.mdf.obs_filename='';
else
    if rem(simdef.mdf.Flhis_dt,simdef.mdf.Dt)~=0 
        warning('History results time is not multiple of time step. I am rewring the history results time.')
        simdef.mdf.Flhis_dt=(floor(simdef.mdf.Flhis_dt/simdef.mdf.Dt)+1)*simdef.mdf.Dt;
    end
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
if simdef.mdf.C==0
    warning('You may not want to specify friction (i.e., friction type = 10), then, set the coefficient to 1, but not zero!')
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
    simdef.mdf.C=sqrt(simdef.mdf.g)/vkappa*log(-1+exp(simdef.mdf.C*vkappa/sqrt(simdef.mdf.g)));
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
if isfield(simdef.D3D,'structure')==0
    simdef.D3D.structure=0;
end
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


%%
%% INI 
%%

simdef.ini.dummy=NaN;

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

if isfield(simdef.ini,'h')==0
    simdef.ini.h=NaN;
end

%%
%% SED
%%

simdef.sed.dummy=NaN;

if isfield(simdef.sed,'dk')==0
    simdef.sed.dk=[];
end

%%
%% MOR
%%

simdef.mor.dummy=NaN;

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

%% 
%% BCM
%%

if isfield(simdef.bcm,'fname')==0
    simdef.bcm.fname=fullfile(simdef.D3D.dire_sim,'bcm.bcm');
end

switch simdef.mor.IBedCond
    case 3
%         deta_dt=simdef.bcm.deta_dt;
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
        simdef.bcm.location{kn,1}=sprintf('Upstream_%02d',kn); kl=kl+1;
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
%% RUNID
%%

if isfield(simdef,'runid')
    if isa(simdef.runid.number,'double')
        error('specify runid as string')
    end
end

%% RENAME OUT

% simdef.grd.M=M;
% simdef.grd.N=N;
% % simdef_out.ini.etab=etab;
% simdef.ini.h=h;
% simdef.ini.u=u;
% simdef.grd.L=L;