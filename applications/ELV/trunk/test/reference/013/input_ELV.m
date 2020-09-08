%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: input_ELV.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/test/reference/013/input_ELV.m $
%
%function input_widening1
       
%% 
%% RUN IDENTIFICATOR
%% 

%% 
%% MASTER DEFINITION VARIABLES
%% 
%input.mdv.path_folder_results = folder_run;
input.mdv.flowtype = 1; %flow assumption: 0=NO update 1=steady; 2=quasi-steady; 3=unsteady explicit; 4=unsteady implicit [-]; [1x1 double]; e.g. [1]
input.mdv.dt = 3600; % time step 
%input.mdv.fluxtype = 4; %flux type:  [-]; [1x1 double]; e.g. [1]
input.mdv.UpwFac = 1; %upwind factor: 1=upwind; 0.5=centrad differences; 2/3=minimum dispersion (??? ask L) [-]; [1x1 double]; e.g. [1]
input.mdv.frictiontype = 1; %friction type: 1=constant; 2=related to grain size; 3=related to flow depth; [1x1 double]; e.g. [1]
input.mdv.bedforms = 0; %bedforms for flow computation 0=NO; 1=YES [-]
input.mdv.Tstop = 3600*24; %simulation time [s]; [1x1 double]; e.g. [3600]
input.mdv.Flmap_dt = 3600;
input.mdv.Cf = 0.004; %friction coefficient [-]; [1x1 double]; e.g. [0.008]
input.mdv.rhow = 1000; %water density [kg/m^3]; [1x1 double]; e.g. [1000]
input.mdv.g = 9.81; %gravity constant [m/s^2]; [1x1 double]; e.g. [9.81]
input.mdv.output_var = {'u','h','etab','Mak','La','msk','Ls','qbk','time_loop'}; 
%input.mdv.output_var = {'u','h','etab'}; %variables name to output;
input.mdv.chk.mass = 0; %mass check [-]; [1x1 double]; e.g. [1]
input.mdv.chk.dM_lim = 1e-5; %mass error limit [m^2]; [1x1 double]; e.g. [1e-8]
input.mdv.chk.flow = 1; %Froude and CFL check [-]; [1x1 double]; e.g. [1]
input.mdv.chk.Fr_lim = 0.8; %Fr limit [-]; [1x1 double]; e.g. [0.8]
input.mdv.chk.cfl_lim = 10; %CFL limit [-]; [1x1 double]; e.g. [0.95]
input.mdv.chk.F_lim = inf; %?????????????????????
input.mdv.dd = 1e-8; %diferential
input.mdv.chk.nan=1;
input.mdv.savemethod = 2;

%% 
%% GRID
%% 
L1 = 20000;
L2 = 20000;
Lb = 5000;
Lb2 = 5000;
input.grd.L = L1+L2+Lb+Lb2; %domain length [m]; [1x1 double]; e.g. [100]
input.grd.dx = 10; %streamwise discretizations [m]; [1x1 double]; e.g. [0.1]
%Channel narrowing with round of edges of a sine;

B0 = 300;
B1 = 200;
x1 = linspace(0,Lb/2,Lb/2/input.grd.dx)';
x2 = linspace(Lb/2,Lb,Lb/2/input.grd.dx)';
input.grd.B = [ones(L1/input.grd.dx,1)*B0; B0+(B1-B0)/2*(1-cos(2*pi*x1/Lb)); ones(Lb2/input.grd.dx,1)*B1; B0+(B1-B0)/2*(1-cos(2*pi*x2/Lb)); ones(L2/input.grd.dx,1)*B0]';
input.grd.crt = 1;
%% 
%% MORPHOLOGY
%% 

input.mor.bedupdate = 1; %update bed elevation 0=NO; 1=YES [-]; e.g. 1
input.mor.gsdupdate = 0; %update grain size distribution 0=NO; 1=Hirano ;2=eli 1 (max. La); 3=eli 1 (min. La); 4=pmm Mak(0,1); 5=pmm etab(0,1); 6=frozen Mak(0,1); 7=frozen Mak>1 [-]; e.g. 1
input.mor.ellcheck = 0; %ellipticity check 0=NO; 1=YES [-]; e.g. 1
input.mor.interfacetype = 1; %fractions at the interface 1=Hirano; 2=Hoey and Ferguson [-]; [1x1 double];
input.mor.porosity = 0.4; %porosity[-]; [1x1 double]; e.g. [0.4]
input.mor.Latype=1; %active layer assumption: 1=constant thickness; 2=related to grain size; 3=related to flow depth; 4=growing with time [-]; [1x1 double]; e.g. [1]
% input.mor.La_t_growth= 0.0001%growth factor [m/s]; [1x1 double]; e.g. [0.0001]
input.mor.La = 1.0; %active layer thickness [m]; [1x1 double]; e.g. [0.1]
input.mor.ThUnLyr = 1.0; %thickness of each underlayer [m]; [1x1 double]; e.g. [0.15]
input.mor.total_ThUnLyr = 5.0; %thickness of the entire bed [m]; [1x1 double]; e.g. [2]
% input.mor.MorStt=60; %spin-up time [s]; [1x1 double]; e.g. [60]
input.mor.MorFac = 1;
%% 
%% SEDIMENT CHARACTERISTICS
%% 

input.sed.dk =  [0.002]; % characteristic grain sizes [m]; [nfx1 double]; e.g. [0.0005;0.003;0.005]
input.sed.rhos = 2650; %sediment density [kg/m^3]; [1x1 double]; e.g. [2650]

%% 
%% SEDIMENT TRANSPORT
%%
input.tra.cr = 1;
%input.tra.param = [0.05 5];
%input.tra.hid=0; %hiding function= %0=NO function; 1=Egiazaroff; 2=Power-Law; 3=Ashida-Mishihue;
input.tra.hiding_b=0; %power function of the Power Law function 

%% 
%% INITIAL CONDITION
%% 
input.ini.initype=52; %kind of initial condition= %1=normal flow (for a given qbk0 and Q0); 2=free; 3=from file; 4=normal flow (for a given initial condition) [-]   [1x1 double]; e.g. [1]
input.ini.Fak=[]; %effective fractions at the active layer [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
input.ini.fsk = 'Fak';%0.42; %effective fractions at the substrate [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
input.ini.sp.dx=1;
input.ini.sp.dT=input.mdv.dt;
%input.ini.sp.etaw0=0;

%% 
%% HYDRODYNAMIC BOUNDARY CONDITIONS
%% 

input.bch.uptype=11; %type of hydrodynamic boundary condition at the upstream end: 1x= water discharge (Q); [-] x1 = from input; x2 = from file; 1 =water discharge from file [1x1 double]; e.g. [1]
%tpath = pwd;
%input.bch.path_file_Q = fullfile(source_path,'data','Qw_bi2_5d.mat'); %pathname where data is located [-]
input.bch.timeQ0=[0; 3*input.mdv.dt; 4*input.mdv.dt; 5*input.mdv.dt]; %time at which the water discharge is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.Q0=[4000; 4000; 4000; 4000]; %water discharge at the specified times [m^3/s]; [ntx1 double]; e.g. [1;2]
input.bch.dotype=3; %type of hydrodynamic boundary condition at the downstream end: 1=water level 2=water depth [-]; 3=normal flow downstream x1 = from input; x2 = from file; [1x1 double]; e.g. [1]
%input.bch.timeetaw0=[0;input.mdv.dt]; %time at which the downstream water level is specified [s]; [nix1 double]; e.g. [1800;3600]
%input.bch.etaw0=[0;0]; %downstream water level at the specified times [m]; [nix1 double]; e.g. [1;1.5]



%% 
%% MORPHODYNAMIC BOUNDARY CONDITIONS
%% 

input.bcm.type=13; %type of morphodynamic boundary condition: 1=sediment discharge [-];  2=equilibrium sediment discharge (at start); 11 = sediment discharge from input; 12 = sediment discharge from file [1x1 double]; e.g. [1]
input.bcm.NFLtype = 3;
input.bcm.NFLparam = 0.67*1000*1000*1000/2650/31536000;
%input.bcm.timeQbk0=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
%input.bcm.path_file_Qbk0 = fullfile(folder_run, 'Qbk'); % file path to location of morphodynamic boundary condition
%input.bcm.Qbk0=[5.66;5.66]*1e-2; %volume of sediment transported excluding pores per unit time, and per size fraction at the specified times [m^3/s]; [ntxnf double]; e.g. [2e-4,4-4;3e-4,5e-4]



%% 
%% SAVE
%% 

%save(fullfile(folder_run,'input.mat'),'input')
