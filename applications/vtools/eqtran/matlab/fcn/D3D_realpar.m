%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19299 $
%$Date: 2023-12-12 17:03:24 +0100 (Tue, 12 Dec 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19299 2023-12-12 16:03:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Builds `realpar` variable to call `eqtran` in Delft3D. 
%Used is made of `v2struct`. This is expensive. Consider an explicit
%interface if calling in loop. 

function realpar=D3D_realpar(ins)

%% allocate

%useful for not having to pass all input 

utot     = NaN;
u        = NaN;
v        = NaN;
uuu      = NaN;
vvv      = NaN;
umod     = NaN;
zumod    = NaN;
h1       = NaN;
chezy    = NaN;
hrms     = NaN;
tp       = NaN;
teta     = NaN;
rlabda   = NaN;
uorb     = NaN;
kwtur    = NaN;
dzbdt    = NaN;
dzdx     = NaN;
dzdy     = NaN;
di50     = NaN;
dss      = NaN;
dstar    = NaN;
d10      = NaN;
d15      = NaN;
d90      = NaN;
mudfrac  = NaN;
hidexp   = NaN;
wsb      = NaN;
rhosol   = NaN;
rhowat   = NaN;
salinity = NaN;
ag       = NaN;
vicmol   = NaN;
taub     = NaN;
vonkar   = NaN;
z0cur    = NaN;
z0rou    = NaN;
ustarc   = NaN;
dg       = NaN;
dgsd     = NaN;
sandfrac = NaN;

%% overwrite with input

v2struct(ins);

%% index

RP_TIME  =  1;     % time since reference date [s]
RP_EFUMN =  2;     % U component of effective depth averaged velocity [m/s]
RP_EFVMN =  3;     % V component of effective depth averaged velocity [m/s]
RP_EFVLM =  4;     % effective depth averaged flow velocity magnitude [m/s]
RP_UCHAR =  5;     % U component of characteristic flow velocity [m/s]
RP_VCHAR =  6;     % V component of characteristic flow velocity [m/s]
RP_VELCH =  7;     % characteristic flow velocity magnitude [m/s]
RP_ZVLCH =  8;     % elevation above bed at which characteristic velocity is given [m]
RP_DEPTH =  9;     % water depth [m]
RP_CHEZY = 10;     % Chezy roughness [m0.5/s]
RP_HRMS  = 11;     % wave height [m]
RP_TPEAK = 12;     % peak wave period [s]
RP_TETA  = 13;     % wave angle [deg pos counter-clockwise relative to U direction]
RP_RLAMB = 14;     % wave length [m]
RP_UORB  = 15;     % orbital velocity [m/s]
RP_D50   = 16;     % D50 of sediment fraction [m]
RP_DSS   = 17;     % effective suspended sediment diameter of sediment fraction [m]
RP_DSTAR = 18;     % Dstar of sediment fraction [m]
RP_D10MX = 19;     % D10 of particle size mix of the part of the bed exposed to transport [m]
RP_D90MX = 20;     % D90 of particle size mix of the part of the bed exposed to transport [m]
RP_MUDFR = 21;     % mud fraction of particle size mix of the part of the bed exposed to transport [-]
RP_HIDEX = 22;     % hiding-exposure factor correcting the shear stress [-]
RP_SETVL = 23;     % settling velocity [m/s]
RP_RHOSL = 24;     % solid density of sediment [kg/m3]
RP_RHOWT = 25;     % density of water [kg/m3]
RP_SALIN = 26;     % salinity [ppt]
RP_TEMP  = 27;     % temperature [deg C]
RP_GRAV  = 28;     % gravitational acceleration [m2/s]
RP_VICML = 29;     % molecular viscosity [m2/s]
RP_TAUB  = 30;     % bed shear stress [N/m2]
RP_UBED  = 31;     % U component of near-bed velocity [m/s]
RP_VBED  = 32;     % V component of near-bed velocity [m/s]
RP_VELBD = 33;     % near-bed velocity magnitude [m/s]
RP_ZVLBD = 34;     % elevation above bed at which near-bed velocity is given [m]
RP_VNKAR = 35;     % von Karman constant [-]
RP_Z0CUR = 36;     % current related roughness height [m]
RP_Z0ROU = 37;     % wave enhanced roughness height [m]
RP_KTUR  = 38;     % flow induced turbulence [m2/s2]
RP_DG    = 39;     % geometric mean sediment diameter of the part of the bed exposed to transport [m]
RP_SNDFR = 40;     % sand fraction of particle size mix of the part of the bed exposed to transport [-]
RP_DGSD  = 41;     % geometric standard deviation of particle size mix of the part of the bed exposed to transport [m]
RP_UMEAN = 42;     % U component of velocity [m/s]
RP_VMEAN = 43;     % V component of velocity [m/s]
RP_VELMN = 44;     % velocity magnitude [m/s]
RP_USTAR = 45;     % effective shear velocity [m/s]
RP_KWTUR = 46;     % wave breaking induced turbulence
RP_UAU   = 47;     % U component of velocity asymmetry due to short waves [m/s]
RP_VAU   = 48;     % V component of velocity asymmetry due to short waves [m/s]
RP_BLCHG = 49;     % bed level change rate (needed for dilatancy calculation in van Thiel formulation) [m/s]
RP_D15MX = 50;     % D15 of particle size mix of the part of the bed exposed to transport [m]
RP_POROS = 51;     % porosity of particle size mix of the part of the bed exposed to transport [-]
RP_DZDX  = 52;     % U component of bed slope [-]
RP_DZDY  = 53;     % V component of bed slope [-]
RP_DM    = 54;     % median sediment diameter of particle size mix of the part of the bed exposed to transport [m]
RP_DBG   = 55;     % debug array value from eqtran [-]
MAX_RP   = 55;     % mmaximum number of real parameters

%% assign

realpar=zeros(1,numrealpar);

realpar(RP_EFVLM) = utot     ;
realpar(RP_EFUMN) = u        ;
realpar(RP_EFVMN) = v        ;
realpar(RP_UCHAR) = uuu      ;
realpar(RP_VCHAR) = vvv      ;
realpar(RP_VELCH) = umod     ;
realpar(RP_ZVLCH) = zumod    ;
realpar(RP_DEPTH) = h1       ;
realpar(RP_CHEZY) = chezy    ;
realpar(RP_HRMS)  = hrms     ;
realpar(RP_TPEAK) = tp       ;
realpar(RP_TETA)  = teta     ;
realpar(RP_RLAMB) = rlabda   ;
realpar(RP_UORB)  = uorb     ;
realpar(RP_KWTUR) = kwtur    ;
realpar(RP_BLCHG) = dzbdt    ;
realpar(RP_DZDX)  = dzdx     ;
realpar(RP_DZDY)  = dzdy     ;
realpar(RP_D50)   = di50     ;
realpar(RP_DSS)   = dss      ;
realpar(RP_DSTAR) = dstar    ;
realpar(RP_D10MX) = d10      ;
realpar(RP_D15MX) = d15      ;
realpar(RP_D90MX) = d90      ;
realpar(RP_MUDFR) = mudfrac  ;
realpar(RP_HIDEX) = hidexp   ;
realpar(RP_SETVL) = wsb      ;
realpar(RP_RHOSL) = rhosol   ;
realpar(RP_RHOWT) = rhowat   ;
realpar(RP_SALIN) = salinity ;
realpar(RP_GRAV)  = ag       ;
realpar(RP_VICML) = vicmol   ;
realpar(RP_TAUB)  = taub     ;
realpar(RP_VNKAR) = vonkar   ;
realpar(RP_Z0CUR) = z0cur    ;
realpar(RP_Z0ROU) = z0rou    ;
realpar(RP_USTAR) = ustarc   ;
realpar(RP_DG)    = dg       ;
realpar(RP_DGSD)  = dgsd     ;
realpar(RP_SNDFR) = sandfrac ;

end %function