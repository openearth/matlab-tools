%input_single_ELV is a script that creates the input variable input.mat to run a single
%simulation

%HISTORY:
%160223
%   -V. Created for the first time.


%% 
%% MASTER DEFINITION VARIABLES
%% 

input.mdv.flowtype=1; %flow assumption: 0=NO update 1=steady; 2=quasi-steady; 3=unsteady; [-]; [1x1 double]; e.g. [1]
input.mdv.fluxtype=1; %flux type:  [-]; [1x1 double]; e.g. [1]
input.mdv.UpwFac=1; %upwind factor: 1=upwind; 0.5=centrad differences; 2/3=minimum dispersion [-]; [1x1 double]; e.g. [1]
input.mdv.frictiontype=1; %friction type: 1=constant; 2=related to grain size; 3=related to flow depth; [1x1 double]; e.g. [1]
input.mdv.bedforms=0; %bedforms for flow computation 0=NO; 1=YES [-]
input.mdv.Tstop=3600*1; %simulation time [s]; [1x1 double]; e.g. [3600]
input.mdv.dt=6; %time step [s]; [1x1 double]; e.g. [2]
input.mdv.Flmap_dt=600; %printing map-file interval time [s]; [1x1 double]; e.g. [60]  
% input.mdv.disp_t_nt=100; %number of time steps to average the time needed to finish the simulatin [-]; [1x1 double]; e.g. [100]  
input.mdv.Cf=0.01; %friction coefficient [-]; [1x1 double]; e.g. [0.008]
input.mdv.rhow=1000; %water density [kg/m^3]; [1x1 double]; e.g. [1000]
input.mdv.g=9.81; %gravity constant [m/s^2]; [1x1 double]; e.g. [9.81]
input.mdv.nu=1e-6; %kinematic viscosity of water [m^2/s]; [1x1 double]; e.g. [1e-6]
input.mdv.output_var={'u','h','etab','Mak','La','msk','Ls','qbk','Cf','ell_idx','time_loop'}; %map variables name to output; 
input.mdv.chk.mass=1; %mass check [-]; [1x1 double]; e.g. [1]
input.mdv.chk.dM_lim=1e-5; %mass error limit [m^2, -!!]; [1x1 double]; e.g. [1e-8]
input.mdv.chk.flow=1; %Froude and CFL check [-]; [1x1 double]; e.g. [1]
input.mdv.chk.Fr_lim=0.8; %Fr limit [-]; [1x1 double]; e.g. [0.8]
input.mdv.chk.cfl_lim=0.95; %CFL limit [-]; [1x1 double]; e.g. [0.95]
input.mdv.dd=1e-8; %diferential
input.mdv.chk.F_lim=0.01; %maximum error in volume fractions [-]; [1x1 double]; e.g. [0.01]
input.mdv.chk.nan=1; %check for NaN
input.mdv.savemethod=2; %1=directly in one file; 2=first in individual files
input.mdv.t0=1; %time step to start (for restarting simulations)

input.mdv.email.send=0; %0=NO; 1=YES
input.mdv.email.sender_mailAddress='v.chavarriasborras@tudelft.nl'; %use only TUD email
input.mdv.email.recipient_mailAddress='chavarrias.v@gmail.com';
input.mdv.email.userName='victorchavarri';
input.mdv.email.password_coded=[5682;5651;6481;5854;5879;6359;5527;5800;5556;5643;6238;6046;6191;5956;5224;5645;5717;6007;5683;6225;6411;6114;6494;5796;6563;5683;5255;5217;5367;6060];

%%
%% FRICTION
%%

input.frc.wall_corr=0; %flume wall correction: 0=NO; 1=YES
input.frc.ripple_corr=0; %ripple correction: 0=NO; 1=YES
input.frc.H=0.01; %bed form height [m]
input.frc.L=0.1; %bed form length [m]
input.frc.nk=2; %ks=nk*max(dx) (Nikuradse roughness length) [-]

%% 
%% GRID
%% 

input.grd.L=10; %domain length [m]; [1x1 double]; e.g. [100]
input.grd.dx=0.1; %streamwise discretizations [m]; [1x1 double]; e.g. [0.1]
input.grd.B=1; %width [m]; [1x1 double] | [1xnx double]; e.g. [10]

%% 
%% MORPHOLOGY
%% 

input.mor.bedupdate=1; %update bed elevation 0=NO; 1=YES [-]; e.g. 1
input.mor.gsdupdate=1; %update grain size distribution 0=NO; 1=Hirano ;2=eli 1 (max. La); 3=eli 1 (min. La); 4=pmm Mak(0,1); 5=pmm etab(0,1); 6=frozen Mak(0,1); 7=frozen Mak>1 [-]; e.g. 1
input.mor.ellcheck=1; %ellipticity check 0=NO; 1=YES [-]; e.g. 1
input.mor.interfacetype=1; %fractions at the interface 1=Hirano; 2=Hoey and Ferguson [-]; [1x1 double];
input.mor.fIk_alpha=1; %Hoey and Ferguson parameter (0=100% active layer, 1=100% bed load) [-]; [1x1 double];
input.mor.porosity=0.4; %porosity [-]; [1x1 double]; e.g. [0.4]
input.mor.Latype=1; %active layer assumption: 1=constant thickness; 2=related to grain size; 3=related to flow depth; 4=growing with time [-]; [1x1 double]; e.g. [1]
% input.mor.La_t_growth= 0.0001%growth factor [m/s]; [1x1 double]; e.g. [0.0001]
input.mor.La=0.01; %active layer thickness [m]; [1x1 double]; e.g. [0.1]
input.mor.ThUnLyr=0.025; %thickness of each underlayer [m]; [1x1 double]; e.g. [0.15]
input.mor.total_ThUnLyr=0.2; %thickness of the entire bed [m]; [1x1 double]; e.g. [2]
input.mor.ThUnLyrEnd=0.5; %thickness of the last underlayer [m]; [1x1 double]; e.g. [10]
% input.mor.MorStt=60; %spin-up time [s]; [1x1 double]; e.g. [60]
input.mor.MorFac=1; %morphological accelerator factor [-]; [1x1 double]; e.g. [10]

%% 
%% SEDIMENT CHARACTERISTICS
%% 

input.sed.dk=[0.002,0.004]; %characteristic grain sizes [m]; [nfx1 double]; e.g. [0.0005;0.003;0.005]
input.sed.rhos=2650; %sediment density [kg/m^3]; [1x1 double]; e.g. [2650]

%% 
%% SEDIMENT TRANSPORT
%% 

input.tra.cr=1; %sediment transport closure relation= %1=Meyer-Peter-Muller; 2=Engelund-Hansen; 3=Ashida-Michiue; 4=Wilcock-Crowe; [1x1 double]; e.g. [1]
input.tra.param=[8,1.5,0.047]; %sediment transport parameters (depending on the closure relation)
input.tra.hid=0; %hiding function= %0=NO function; 1=Egiazaroff; 2=Power-Law; 3=Ashida-Mishihue;
input.tra.hiding_b=0; %power function of the Power Law function 
input.tra.Dm=1; %1=geometric 2^sum(Fak*log2(dk); 2=arithmetic sum(Fak*dk);

%% 
%% INITIAL CONDITION
%% 

input.ini.initype=1; %kind of initial condition= %1=normal flow (for a given qbk0); 2=free; 3=from file; 4=normal flow (for a given initial condition) [-] [1x1 double]; e.g. [1]
    %1 => out of the upstrem hydrodynamic and morphodynamic and boundary conditions (Q0, Qbk0), the initial condition (u, h, etab, Mak) is set such that the start is normal flow
    %4 => out of the intial condition (u, h, etab, Mak) the upstream morphodynamic boundary condition (Qbk0) and the downstream hydraulic boundary condition (etaw0) are set such that the start is normal flow
% input.ini.rst_file='d:\victorchavarri\SURFdrive\projects\00_codes\ELV\runs\B\04\output.mat'; %path to the folder
% input.ini.rst_resultstimestep=294; %result time step with the initial condition [-]; [1x1 double]; e.g. [70]; if NaN it will be the last one     
% input.ini.u=999; %flow velocity [m/s]; [1x1 double] | [1xnx double]; e.g. [1]
% input.ini.h=0.30; %flow depth [m]; [1x1 double] | [1xnx double]; e.g. [1.5]
% input.ini.slopeb=999; %bed slope [-]; [1x1 double] | [1xnx double]; e.g. [1e-3]
% input.ini.etab0=0; %downstream bed elevation [m]; [1x1 double]; e.g. [0]
% input.ini.etab=1:0.1;10; %bed level [-]; [1x1 double] | [1xnx double]; e.g. [1e-3]
% input.ini.Fak=0.30; %effective fractions at the active layer [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
input.ini.fsk=1.0; %effective fractions at the substrate [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
% input.ini.subs.patch.x=[6,6.4]; %x coordinate of the upper corners of the patch [m]; [1x2 double]; e.g. [5,7.5]
% input.ini.subs.patch.releta=0.04; %substrate depth of the upper corners of the patch [m]; [1x1 double]; e.g. [0.2,0.2]
% input.ini.subs.patch.fsk=1; %effective fractions in the patch at the substrate [-]; (nf-1)x1 double]; e.g. [0.2,0.3]

%% 
%% HYDRODYNAMIC BOUNDARY CONDITIONS
%% 

input.bch.uptype=1; %type of hydrodynamic boundary condition at the upstream end: 1=water discharge; 2=cyclic hydrograph [-] [1x1 double]; e.g. [1]
input.bch.dotype=1; %type of hydrodynamic boundary condition at the downstream end: 1=water level 2=water depth [-]; [1x1 double]; e.g. [1]
input.bch.timeQ0=[0;input.mdv.Tstop]; %time at which the water discharge is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.Q0=[0.2;0.2]; %water discharge at the specified times [m^3/s]; [ntx1 double]; e.g. [1;2]
input.bch.timeetaw0=[0;input.mdv.Tstop]; %time at which the downstream water level is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.etaw0=[0;-0.01]; %downstream water level at the specified times [m]; [nix1 double]; e.g. [1;1.5]

%% 
%% MORPHODYNAMIC BOUNDARY CONDITIONS
%% 

input.bcm.type=1; %type of morphodynamic boundary condition: 1=sediment discharge [-]; 2=periodic; 3=cyclic hydrograph [1x1 double]; e.g. [1]
input.bcm.timeQbk0=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bcm.Qbk0=[0,1;0,1]*1e-5; %volume of sediment transported excluding pores per unit time, and per size fraction at the specified times [m^3/s]; [ntxnf double]; e.g. [2e-4,4-4;3e-4,5e-4]
