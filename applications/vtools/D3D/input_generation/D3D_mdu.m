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
%mdu creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .mdf file compatible with D3D is created in folder_out
%

function D3D_mdu(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt;   
Flmap_dt=simdef.mdf.Flmap_dt;
g=simdef.mdf.g;
secflow=simdef.mdf.secflow;

Vicouv=simdef.mdf.Vicouv;
Dicouv=simdef.mdf.Dicouv;
Vicoww=simdef.mdf.Vicoww;
Dicoww=simdef.mdf.Dicoww;

Smagorinsky=simdef.mdf.Smagorinsky;

wall_rough=simdef.mdf.wall_rough;
wall_ks=simdef.mdf.wall_ks;

obs_filename=simdef.mdf.obs_filename;

Flhis_dt=simdef.mdf.Flhis_dt;
Flrst_dt=simdef.mdf.Flrst_dt;

if isfield(simdef,'mor')
    morphology=simdef.mor.morphology;
else
    morphology=false;
end

file_name=simdef.file.mdf;
Idensform=simdef.mdf.Idensform;
K=simdef.mdf.K;

    
%% OPEN

[fid,fname_local]=write_local_and_copy('open',file_name,'overwrite',~check_existing);

%% WRITE

%% header

fprintf(fid,'# Generated: %s\r\n',datestr(datetime('now')));
fprintf(fid,'# %s\r\n',[getenv("USER"),getenv("USERNAME")]);
fprintf(fid,'\r\n');

%% model

fprintf(fid,'[model]\r\n');
fprintf(fid,'Program           = D-Flow FM       \r\n');
% data{kl,1}=        'Version           = 1.2.38.63285M   '; kl=kl+1;
fprintf(fid,'MDUFormatVersion  = 1.02            \r\n');
% data{kl,1}=        'GuiVersion        = 1.5.2.42543     '; kl=kl+1;
fprintf(fid,'AutoStart         = 0               \r\n');
fprintf(fid,'\r\n');
%% GEOMETRY
fprintf(fid,'[geometry]\r\n');
fprintf(fid,'NetFile           = %s\r\n',simdef.mdf.grd);
% if simdef.mor.morphology || simdef.grd.cell_type
% data{kl,1}=sprintf('BathymetryFile    = %s',simdef.mdf.dep); kl=kl+1;
% else
% data{kl,1}=        'BathymetryFile    =         ' ; kl=kl+1;
% end
fprintf(fid,'DryPointsFile     =         \r\n');
fprintf(fid,'GridEnclosureFile =         \r\n');
% if simdef.ini.etaw_type==2
% data{kl,1}=sprintf('WaterLevIniFile   = %s      ',simdef.ini.etaw_file); kl=kl+1;
% data{kl,1}=sprintf('WaterLevIniFile   = %s      ',simdef.mdf.etaw_file); kl=kl+1;
% else
% data{kl,1}=        'WaterLevIniFile   =         '; kl=kl+1;
% end
fprintf(fid,'IniFieldFile      = %s\r\n',simdef.mdf.IniFieldFile);
fprintf(fid,'LandBoundaryFile  =         \r\n');
fprintf(fid,'UseCaching        = 0       \r\n');
fprintf(fid,'ThinDamFile       =         \r\n');
fprintf(fid,'FixedWeirFile     =         \r\n');
fprintf(fid,'PillarFile        = %s\r\n',simdef.mdf.PillarFile);
fprintf(fid,'StructureFile     = %s\r\n',simdef.mdf.StructureFile);
% data{kl,1}=        'VertplizFile      =         '; kl=kl+1;
fprintf(fid,'CrossDefFile      = %s\r\n',simdef.mdf.CrossDefFile);
fprintf(fid,'CrossLocFile      = %s\r\n',simdef.mdf.CrossLocFile);
fprintf(fid,'FrictFile         = %s\r\n',simdef.mdf.FrictFile);
% data{kl,1}=        'ProflocFile       =         '; kl=kl+1;
% data{kl,1}=        'ProfdefFile       =         '; kl=kl+1;
% data{kl,1}=        'ProfdefxyzFile    =         '; kl=kl+1;
% data{kl,1}=        'Uniformwidth1D    = 2       '; kl=kl+1;
fprintf(fid,'ManholeFile       =         \r\n');
if isfield(simdef,'ini') && isfield(simdef.ini,'etaw') && simdef.ini.etaw_type==1
fprintf(fid,'WaterLevIni       = %0.7E\r\n',simdef.ini.etab+simdef.ini.h);
else
% data{kl,1}=        'WaterLevIni       = 0    '; kl=kl+1;
end
% if simdef.ini.etab0_type==2
% data{kl,1}=sprintf('Bedlevuni         = %0.7E',etab); kl=kl+1;
% else
fprintf(fid,'Bedlevuni         = -5      \r\n');
% end
fprintf(fid,'Bedslope          = 0       \r\n');
fprintf(fid,'BedlevType        = %i       \r\n', simdef.mdf.BedlevType);
fprintf(fid,'Blmeanbelow       = -999    \r\n');
fprintf(fid,'Blminabove        = -999    \r\n');
fprintf(fid,'PartitionFile     =         \r\n');
fprintf(fid,'Anglat            =  0        \r\n');
% data{kl,1}=        'Grdang            =  0        '; kl=kl+1;
fprintf(fid,'Conveyance2D      = -1        \r\n');
fprintf(fid,'Nonlin2D          = 0         \r\n');
fprintf(fid,'Sillheightmin     = 0         \r\n');
fprintf(fid,'Makeorthocenters  = 0         \r\n');
fprintf(fid,'Dcenterinside     = 1         \r\n');
fprintf(fid,'Bamin             = 1E-06     \r\n');
fprintf(fid,'OpenBoundaryTolerance= 3      \r\n');
fprintf(fid,'RenumberFlowNodes = 1         \r\n');
fprintf(fid,'Kmx               = %d\r\n',K)     ;
fprintf(fid,'Layertype         = 1         \r\n');
fprintf(fid,'Numtopsig         = 0         \r\n');
fprintf(fid,'SigmaGrowthFactor = 1         \r\n');
fprintf(fid,'ChangeVelocityAtStructures = 1         \r\n');
fprintf(fid,'Removesmalllinkstrsh = %d     \r\n',simdef.mdf.Removesmalllinkstrsh); %0.0 = remove no links ,  0.1 = remove links smaller than 0.1 sqrt(ba)
fprintf(fid,'Dpuopt            = %d     \r\n',simdef.mdf.Dpuopt); %# Bed level interpolation at velocity point in case of tile approach bed level: 1 = max (default); 2 = mean
fprintf(fid,'ExtrBl            = %d     \r\n',simdef.mdf.ExtrBl); %# Extrapolation of bed level at boundaries according to the slope: 0 = no extrapolation (default); 1 = extrapolate.

% Kmx                               = 28                  # Maximum number of vertical layers
% Layertype                         = 2                   # Vertical layer type (1: all sigma, 2: all z, 3: use VertplizFile)
% Numtopsig                         = 0                   # Number of sigma layers in top of z-layer model
% SigmaGrowthFactor                 = 1.                  # Layer thickness growth factor from bed up
% StretchType                       = 1                   # Type of layer stretching, 0 = uniform, 1 = user defined, 2 = fixed level double exponential
% StretchCoef                       = 6.392 5.9247 5.4884 5.0842 4.7097 4.3629 4.0416 3.7439 3.4682 3.2128 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762# Layers thickness percentage
% ZlayBot                           = -42.                # level of bottom layer in z-layers
% ZlayTop                           = 0.                  # level of top layer in z-layers

fprintf(fid,'\r\n');
%% NUMERICS
fprintf(fid,'[numerics]\r\n');
fprintf(fid,'CFLMax            = %f         \r\n',simdef.mdf.CFLMax);
fprintf(fid,'AdvecType         = 33         \r\n');
fprintf(fid,'TimeStepType      = 2          \r\n');
fprintf(fid,'Limtyphu          = 0          \r\n');
fprintf(fid,'Limtypmom         = 4          \r\n');
fprintf(fid,'Limtypsa          = 4          \r\n');
%data{kl,1}=        'TransportMethod   = 1          '; kl=kl+1;
fprintf(fid,'Vertadvtypmom     = 6          \r\n'); %vertical advection for u1: 0: No, 3: Upwind implicit, 4: Central implicit, 5: QUICKEST implicit., 6: centerbased upwind expl
fprintf(fid,'Vertadvtypsal     = 6          \r\n');
fprintf(fid,'Icgsolver         = 4          \r\n');
fprintf(fid,'Maxdegree         = 6          \r\n');
fprintf(fid,'FixedWeirScheme   = 6          \r\n');
fprintf(fid,'FixedWeirContraction= 1        \r\n');
fprintf(fid,'FixedWeirfrictscheme= 1        \r\n');
fprintf(fid,'Fixedweirtopwidth = 3          \r\n');
fprintf(fid,'Fixedweirtopfrictcoef= -999    \r\n');
fprintf(fid,'Fixedweirtalud    = 4          \r\n');
fprintf(fid,'Izbndpos          = %d         \r\n',simdef.mdf.izbndpos);
fprintf(fid,'Tlfsmo            = 0          \r\n');
fprintf(fid,'Logprofatubndin   = 1          \r\n'); % ubnds inflow: 0=uniform U1, 1 = log U1, 2 = user3D
fprintf(fid,'Logprofkepsbndin  = 0          \r\n'); % inflow: 0=0 keps, 1 = log keps inflow, 2 = log keps in and outflow
fprintf(fid,'Slopedrop2D       = 0          \r\n');
fprintf(fid,'Chkadvd           = 0.1        \r\n');
fprintf(fid,'Teta0             = %f         \r\n',simdef.mdf.theta);
% data{kl,1}=        'Qhrelax           = 0.01       '; kl=kl+1;
fprintf(fid,'Jbasqbnddownwindhs= 0          \r\n');
fprintf(fid,'cstbnd            = 0          \r\n');
fprintf(fid,'Maxitverticalforestersal= 0    \r\n');
fprintf(fid,'Maxitverticalforestertem= 0    \r\n');
% data{kl,1}=        'Jaorgsethu        = 1          '; kl=kl+1;
fprintf(fid,'Turbulencemodel   = 3          \r\n');
fprintf(fid,'Turbulenceadvection= 3         \r\n');
fprintf(fid,'AntiCreep         = 0          \r\n');
fprintf(fid,'Maxwaterleveldiff = 0          \r\n');
fprintf(fid,'Maxvelocitydiff   = 0          \r\n');
fprintf(fid,'Epshu             = 0.0001     \r\n');
fprintf(fid,'Epsz0             = %f        \r\n',simdef.mdf.epsz0);
% data{kl,1}=        'SobekDFM_umin     = 0          '; kl=kl+1;
fprintf(fid,'TransportAutoTimestepdiff = %d         \r\n',simdef.mdf.TransportAutoTimestepdiff);
% data{kl,1}=sprintf('filter            = %d         ',filter); kl=kl+1;
fprintf(fid,'MinTimestepBreak  = %d         \r\n',0);
fprintf(fid,'\r\n');
%%
fprintf(fid,'[physics]                        \r\n');
fprintf(fid,'UnifFrictCoef     = %0.7E\r\n',simdef.mdf.C);
fprintf(fid,'UnifFrictType     = %d\r\n',simdef.mdf.FrictType);
fprintf(fid,'UnifFrictCoef1D   = 0.023        \r\n');
fprintf(fid,'UnifFrictCoefLin  = 0            \r\n');
fprintf(fid,'Umodlin           = 0            \r\n');
fprintf(fid,'Vicouv            = %0.7E\r\n',Vicouv);
fprintf(fid,'Dicouv            = %0.7E\r\n',Dicouv);
fprintf(fid,'Vicoww            = %0.7E\r\n',Vicoww);
fprintf(fid,'Dicoww            = %0.7E\r\n',Dicoww);
fprintf(fid,'Vicwminb          = 0            \r\n');
fprintf(fid,'Smagorinsky       = %0.7E\r\n',Smagorinsky); %Add Smagorinsky horizontal turbulence : vicu = vicu + ( (Smagorinsky*dx)**2)*S, e.g. 0.1
fprintf(fid,'Elder             = 0            \r\n'); %Add Elder contribution                : vicu = vicu + Elder*kappa*ustar*H/6),   e.g. 1.0
fprintf(fid,'Irov              = %d\r\n',wall_rough);
fprintf(fid,'wall_ks           = %0.7E\r\n',wall_ks); %Nikuradse roughness for side walls, wall_z0=wall_ks/30
fprintf(fid,'Rhomean           = 1000         \r\n');
fprintf(fid,'Idensform         = %d\r\n',Idensform); %# Density calulation (0: uniform, 1: Eckart, 2: Unesco, 3=Unesco83, 13=3+pressure). Setting it to 2 causes computation of baroclinic terms althought there is no salt.
fprintf(fid,'Ag                = %0.7E\r\n',g)     ;
fprintf(fid,'TidalForcing      = 0            \r\n');
% data{kl,1}=        'Doodsonstart      = 55.565       '; kl=kl+1;
% data{kl,1}=        'Doodsonstop       = 375.575      '; kl=kl+1;
% data{kl,1}=        'Doodsoneps        = 0            '; kl=kl+1;
fprintf(fid,'Salinity          = 0            \r\n');
% data{kl,1}=        'InitialSalinity   = 0            '; kl=kl+1;
% data{kl,1}=        'Sal0abovezlev     = -999         '; kl=kl+1;
% data{kl,1}=        'DeltaSalinity     = -999         '; kl=kl+1;
% data{kl,1}=        'Backgroundsalinity= 0            '; kl=kl+1;
% data{kl,1}=        'InitialTemperature= 15           '; kl=kl+1;
% data{kl,1}=        'Secchidepth       = 2            '; kl=kl+1;
% data{kl,1}=        'Stanton           = -1           '; kl=kl+1;
% data{kl,1}=        'Dalton            = -1           '; kl=kl+1;
% data{kl,1}=        'Backgroundwatertemperature= 1    '; kl=kl+1;
fprintf(fid,'SecondaryFlow     = %d\r\n',secflow);
fprintf(fid,'BetaSpiral        = %d\r\n',secflow);
fprintf(fid,'Temperature       = 0            \r\n');
fprintf(fid,'                                                 \r\n');
%%
fprintf(fid,'[wind]                                  \r\n');
fprintf(fid,'ICdtyp            = 2                   \r\n');
fprintf(fid,'Cdbreakpoints     = 0.00063 0.00723     \r\n');
fprintf(fid,'Windspeedbreakpoints= 0 100             \r\n');
fprintf(fid,'Rhoair            = 1.205               \r\n');
fprintf(fid,'PavBnd            = 0                   \r\n');
fprintf(fid,'PavIni            = 0                   \r\n');
%%
fprintf(fid,'[waves]                                          \r\n');
fprintf(fid,'Wavemodelnr       = 0                            \r\n');
% data{kl,1}=        'WaveNikuradse     = 0.01                         '; kl=kl+1;
% data{kl,1}=        'Rouwav            = FR84                         '; kl=kl+1;
% data{kl,1}=        'Gammax            = 1                            '; kl=kl+1;
fprintf(fid,'                                                 \r\n');
%% TIME
fprintf(fid,'[time]                                           \r\n');
fprintf(fid,'RefDate           = 20000101                     \r\n');
fprintf(fid,'Tzone             = 0                            \r\n');
fprintf(fid,'DtUser            = %0.14E\r\n',simdef.mdf.DtUser);
fprintf(fid,'DtNodal           =                              \r\n');
fprintf(fid,'DtMax             = %0.14E\r\n',simdef.mdf.DtMax);
fprintf(fid,'DtInit            = 1                            \r\n');
fprintf(fid,'Timestepanalysis  = 0                            \r\n'); %# 0=no, 1=see file *.steps
% data{kl,1}=        'Autotimestepdiff  = 1                            '; kl=kl+1; %# 0 = no, 1 = yes (Time limitation based on explicit diffusive term)
fprintf(fid,'Tunit             = %s\r\n',simdef.mdf.Tunit)         ;
fprintf(fid,'TStart            = 0                            \r\n');
fprintf(fid,'TStop             = %0.14E\r\n',Tstop);
fprintf(fid,'AutoTimestepNoStruct = 1                         \r\n');
fprintf(fid,'                                                 \r\n');
%%
fprintf(fid,'[restart]                                        \r\n');
fprintf(fid,'RestartFile       =                              \r\n');
fprintf(fid,'RestartDateTime   =                              \r\n');
fprintf(fid,'                                                 \r\n');
%%
fprintf(fid,'[external forcing]                               \r\n');
fprintf(fid,'ExtForceFile      = %s\r\n',simdef.mdf.ext)           ;
fprintf(fid,'ExtForceFileNew   = %s\r\n',simdef.mdf.extn)          ;
fprintf(fid,'                                                 \r\n');
%%
fprintf(fid,'[trachytopes]                                    \r\n');
fprintf(fid,'TrtRou            = N                            \r\n');
% data{kl,1}=        'TrtDef            =                              '; kl=kl+1;
% data{kl,1}=        'TrtL              =                              '; kl=kl+1;
% data{kl,1}=        'DtTrt             = 60                           '; kl=kl+1;
fprintf(fid,'                                                 \r\n');
%%
fprintf(fid,'[output]                                         \r\n');
fprintf(fid,'Wrishp_crs        = 0                            \r\n');
fprintf(fid,'Wrishp_weir       = 0                            \r\n');
fprintf(fid,'Wrishp_gate       = 0                            \r\n');
fprintf(fid,'Wrishp_fxw        = 0                            \r\n');
fprintf(fid,'Wrishp_thd        = 0                            \r\n');
fprintf(fid,'Wrishp_obs        = 0                            \r\n');
fprintf(fid,'Wrishp_emb        = 0                            \r\n');
fprintf(fid,'Wrishp_dryarea    = 0                            \r\n');
fprintf(fid,'Wrishp_genstruc   = 0                            \r\n');
% data{kl,1}=        'Wrishp_enc        = 0                            '; kl=kl+1;
fprintf(fid,'Wrishp_src        = 0                            \r\n');
fprintf(fid,'Wrishp_pump       = 0                            \r\n');
fprintf(fid,'OutputDir         =                              \r\n');
fprintf(fid,'WAQOutputDir      =                              \r\n');
fprintf(fid,'FlowGeomFile      =                              \r\n');
if Flhis_dt>0
fprintf(fid,'ObsFile           = %s\r\n',obs_filename);
end
fprintf(fid,'CrsFile           =                              \r\n');
fprintf(fid,'HisFile           =                              \r\n');
fprintf(fid,'HisInterval       = %0.14E\r\n',Flhis_dt);
fprintf(fid,'XLSInterval       =                              \r\n');
fprintf(fid,'MapFile           =                              \r\n');
fprintf(fid,'MapInterval       = %0.14E %0.14E %0.14E\r\n',Flmap_dt(2),Flmap_dt(1),Tstop*time_factor(simdef.mdf.Tunit,'seconds')); %there used to be a +2*dt at the end. I do not think it is needed anymore
fprintf(fid,'RstInterval       = %0.14E\r\n',Flrst_dt);
fprintf(fid,'S1incinterval     =                              \r\n');
fprintf(fid,'MapFormat         = 4                            \r\n');
fprintf(fid,'NcFormat          = %d \r\n', simdef.mdf.NcFormat)    ;
fprintf(fid,'Wrihis_balance    = 1                            \r\n');
fprintf(fid,'Wrihis_structure_gen= 1                          \r\n');
fprintf(fid,'Wrihis_structure_dam= 1                          \r\n');
fprintf(fid,'Wrihis_structure_pump= 1                         \r\n');
fprintf(fid,'Wrihis_structure_gate= 1                         \r\n');
fprintf(fid,'Wrimap_waterlevel_s0= 0                          \r\n');
fprintf(fid,'Wrimap_waterlevel_s1= 1                          \r\n');
fprintf(fid,'Wrimap_velocity_component_u0= 0                  \r\n');
fprintf(fid,'Wrimap_velocity_component_u1= 1                  \r\n');
fprintf(fid,'Wrimap_velocity_vector= 1                        \r\n');
fprintf(fid,'Wrimap_waterdepth_hu= 1                          \r\n');
fprintf(fid,'Wrimap_upward_velocity_component= 1              \r\n');
fprintf(fid,'Wrimap_density_rho= 0                            \r\n');
fprintf(fid,'Wrimap_horizontal_viscosity_viu= 1               \r\n');
fprintf(fid,'Wrimap_horizontal_diffusivity_diu= 1             \r\n');
fprintf(fid,'Wrimap_flow_flux_q1= 1                           \r\n');
fprintf(fid,'Wrimap_flow_flux_q1_main= 1                      \r\n'); %mesh1d_q1_main = main channel flow dicharge per unit width
fprintf(fid,'Wrimap_spiral_flow= 1                            \r\n');
fprintf(fid,'Wrimap_numlimdt   = 1                            \r\n');
fprintf(fid,'Wrimap_taucurrent = 1                            \r\n');
fprintf(fid,'Wrimap_chezy      = 1                            \r\n');
fprintf(fid,'Wrimap_turbulence = 1                            \r\n');
fprintf(fid,'Wrimap_wind       = 0                            \r\n');
fprintf(fid,'Wrimap_heat_fluxes= 0                            \r\n');
fprintf(fid,'Wrimap_every_dt   = 0                            \r\n'); %# Write output to map file every dt, based on start and stop from MapInterval, 0=no (default), 1=yesÃƒÂ¯Ã‚Â¿Ã‚Â½
fprintf(fid,'Wrimap_fixed_weir_energy_loss   = 1              \r\n');
fprintf(fid,'MapOutputTimeVector=                             \r\n');
fprintf(fid,'FullGridOutput    = 0                            \r\n');
fprintf(fid,'EulerVelocities   = 0                            \r\n');
fprintf(fid,'ClassMapFile      =                              \r\n');
% data{kl,1}=        'WaterlevelClasses = 0.0                          '; kl=kl+1;
% data{kl,1}=        'WaterdepthClasses = 0.0                          '; kl=kl+1;
fprintf(fid,'ClassMapInterval  = 0                            \r\n');
fprintf(fid,'WaqInterval       = 0                            \r\n');
fprintf(fid,'StatsInterval     = -1                           \r\n');
%data{kl,1}=        'Writebalancefile  = 0                            '; kl=kl+1;
fprintf(fid,'TimingsInterval   =                              \r\n');
fprintf(fid,'Richardsononoutput= 0                            \r\n');
fprintf(fid,'                                                 \r\n');

%% morphology

fprintf(fid,'[sediment]                                       \r\n');
fprintf(fid,'MorFile           = %s                      \r\n',simdef.mdf.mor);
fprintf(fid,'SedFile           = %s                      \r\n',simdef.mdf.sed);
fprintf(fid,'Sedimentmodelnr   = %d                            \r\n',simdef.mdf.sedimentmodelnr);
fprintf(fid,'MorCFL            = 0                            \r\n'); %Use morphological time step restriction (1, default) or not (0)

%% CLOSE

write_local_and_copy('close',fid,fname_local,file_name)

end %function