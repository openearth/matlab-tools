%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Main scrip to call `eqtran.dll` for computing sediment transport as in Delft3D

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';

% fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

%% ADD OET
 
if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% INPUT

    %% DLL

fpath_dll='../fortran/x64/Release/eqtran.dll'; 
fpath_h  ='../header/eqtran.h';

%% EQTRAN

sig=NaN; %real(fp), dimension(kmax), intent(in)  :: sig      !< sigma coordinate of the centre of each layer
thick=NaN; %real(fp), dimension(kmax), intent(in)  :: thick    !< thickness of each layer
kmax=0; %integer                  , intent(in)  :: kmax     !< number of layers (counted top to bottom)
ws=0.002; %real(fp)     , dimension(0:kmax)    , intent(in)    :: ws       !< settling velocity. 
iturbulencemodel=3; %integer   !< 0=no, 1 = constant, 2 = algebraic, 3 = k-eps, 4 = k-tau
frac=0.2; %real(fp) , intent(in)    :: frac !< effective fraction of sediment in bed available for transport
dicww=0; %real(fp)     , dimension(0:kmax)    , intent(in)    :: dicww !<diffusivity [m^2/s]
rksrs=0.01; %real(fp)                            , intent(in)    :: rksrs !< [m] Ripple roughness height in flow cell center
i2d3d=2; %integer, intent(in) :: i2d3d !< 2=2D; 3=3D
lsecfl=0; %integer                             , intent(in)    :: lsecfl !< Flag for secondary flow: 0=NO, 1=YES. 
spirint=0.01; %real(fp)                            , intent(in)    :: spirint  !  Spiral flow intensity [m/s]
suspfrac=false; %logical                             , intent(in)    :: suspfrac !  suspended sediment fraction
concin=0; %real(fp)     , dimension(kmax)      , intent(inout) :: concin. !<sediment concentration. if (i2d3d==2 .or. epspar) then output else input
    %bottom slope components in the cell centres. Bottom slopes are positive on downsloping parts, so bl(k1)-bl(k2) instead of other way round.
dzduu=0; %x (U) direction %real(fp)                            , intent(in)    :: dzduu
dzdvv=0; %y (V) direction %real(fp)                            , intent(in)    :: dzduu
uorb=0; %!< [m/s] orbital velocity
sus=1; %real(fp)                            , intent(in)    :: sus !<calibration factor for suspended load transport
bed=1; %real(fp)                            , intent(in)    :: bed !<calibration factor for bed load transport
susw=1; %real(fp) , intent(in)    :: susw !<calibration factor for wave-related suspended sand transport (included in bed-load)
bedw=1;  %real(fp)                            , intent(in)    :: bedw !<calibration factor for wave-related bed-load sand transport (included in bed-load)
espir=1; %real(fp)                            , intent(in)    :: espir !<factor for weighing the effect of the spiral flow intensity in 2D simulations
wave=false; %logical                             , intent(in)    :: wave !<flag for computing effect of waves 
ubot_from_com=false; %logical                             , intent(in)    :: ubot_from_com !< .TRUE. = set `uorb` from input; .FALSE. = compute `uorb` based on wave parameters.
camax=0.65; %real(fp)                            , intent(in)    :: camax !<Maximum volumetric reference concentration
iform=4; %integer                             , intent(in)    :: iform !<Sediment transport formula number
ag=9.81; %real(fp) :: ag !<gravity acceleration
rhowat=1000; %!< density at cell centres (kg/m3), only salt and temp
rhosol=2650; %!< solid sediment density [kg/m3]
factcr=1; %factor of the critical bed shear stress `taucr0` 

acal=8; %`ACal` [-]
acals=0; %`Acal` for suspended load [-]
b=0; %power `theta` in General Formula [-]
bs=0; %power `theta` in General Formula for suspended load [-]
cc=1.5; %power excess Shields stress in General Formula  [-]
ccs=0; %power excess Shields stress in General Formula  for suspended load [-]
rmu=1; %ripple factor [-]
rmus=1; %ripple factor for suspended load [-]
thcr=0.047; %critical Shields [-]
thcrs=0.047; %critical Shields for suspended load [-]
vicmol=1e-6; %molecular viscosity [m^2/s]

ucxq_mor=1;
ucyq_mor=0;

zcc=0.01; %! cell centre position in vertical layer admin, using absolute height. Value that fulfills `zcc>=(bl(kk)+maxdepfrac*hs(kk)) .or. zcc>=(bl(kk)+deltas(kk))` [mAD]
bl=0; %bed level [mAD]
hs_mor=1; %flow depth at cell centre. Possibly limited by maximum water level at links. 
h1        = hs_mor; %flow depth at cell centre. `s1-bl`.
hrms      = 0;
tp        = 0;
teta      = 0;
rlabda    = 0;
kwtur     = 0;
dzbdt     = 0;
di50      = 1e-3;
dss       = 0;
dstar     = 0;
d10       = 0;
d15       = 0;
d90       = 0;
mudfrac   = 0;
hidexp    = 1;
wsb       = 0;
salinity  = 0;
taub      = 0;
z0cur     = 0.01; %currents
z0rouk     = 0.01; %wave
dg        = 0;
dgsd      = 0;
sandfrac  = 0;

    %% OUTPUT

aks      =0;   %real(fp)                        , intent(inout):: aks ! out parameter for Van Rijn, in parameter for others
caks     =0;   %real(fp)                        , intent(out)  :: caks
taurat   =0;   %real(fp)                        , intent(out)  :: taurat
seddif=zeros(1,kmax+1); %real(fp), dimension(0:kmax)     , intent(out)  :: seddif
rsedeq=zeros(1,kmax); %real(fp), dimension(kmax)       , intent(out)  :: rsedeq
kmaxsd   =0;    %integer                         , intent(out)  :: kmaxsd
conc2d   =0;    %real(fp)                        , intent(out)  :: conc2d
sbcu     =0;    %real(fp)                        , intent(out)  :: sbcu !< m^2/s * rhosol (as in Van Rijn)
sbcv     =0;    %real(fp)                        , intent(out)  :: sbcv !< m^2/s * rhosol (as in Van Rijn)
sbwu     =0;    %real(fp)                        , intent(out)  :: sbwu
sbwv     =0;    %real(fp)                        , intent(out)  :: sbwv    
sswu     =0;    %real(fp)                        , intent(out)  :: sswu
sswv     =0;    %real(fp)                        , intent(out)  :: sswv
% dss      =0;    %real(fp)                        , intent(out)  :: dss
caks_ss3d=0;    %real(fp)                        , intent(out)  :: caks_ss3d
aks_ss3d =0;    %real(fp)                        , intent(out)  :: aks_ss3d
ust2     =0;    %real(fp)                        , intent(out)  :: ust2
t_relax  =0;    %real(fp)                        , intent(out)  :: t_relax
error    =false;    %logical                         , intent(out)  :: error

%% rework

[...
    par,realpar,kmax,ws,dicww,ltur,jawave,ubot,sigmol,lundia,tauadd,scour,eps,npar,numintpar,numrealpar,...
    numstrpar,dllfunc,dllhandle,intpar,strpar,lsecfl,drho,tetacr,dstar,taucr0...
    ]=D3D_erosed(...
    kmax,i2d3d,lsecfl,ws,dicww,iturbulencemodel,frac,suspfrac,wave,ucxq_mor,ucyq_mor,h1,...
    chezy,hrms,tp,teta,rlabda,uorb,kwtur,dzbdt,di50,dss,dstar,d10,d15,d90,mudfrac,hidexp,...
    wsb,rhosol,rhowat,salinity,ag,vicmol,taub,z0cur,dg,dgsd,sandfrac,acal,b,cc,...
    rmu,thcr,acals,bs,ccs,rmus,thcrs,factcr,bl,hs_mor,dzduu,dzdvv,zcc);

%% load library

[lib,warn]=loadlibrary(fpath_dll,fpath_h);

%% call

% subroutine eqtran(sig       ,thick     ,kmax      ,ws        ,ltur      , &
%                 & frac      ,sigmol    ,dicww     ,lundia    ,taucr0    , &
%                 & rksrs     ,i2d3d     ,lsecfl    ,spirint   ,suspfrac  , &
%                 & tetacr    ,concin    , &
%                 & dzduu     ,dzdvv     ,ubot      ,tauadd    ,sus       , &
%                 & bed       ,susw      ,bedw      ,espir     ,wave      , &
%                 & scour     ,ubot_from_com        ,camax     ,eps       , &
%                 & iform     ,npar      ,par       ,numintpar ,numrealpar, &
%                 & numstrpar ,dllfunc   ,dllhandle ,intpar    ,realpar   , &
%                 & strpar    , &
% !output:
%                 & aks       ,caks      ,taurat    ,seddif    ,rsedeq    , &
%                 & kmaxsd    ,conc2d    ,sbcu      ,sbcv      ,sbwu      , &
%                 & sbwv      ,sswu      ,sswv      ,dss       ,caks_ss3d , &
%                 & aks_ss3d  ,ust2      ,t_relax   ,error     )


[sig       ,thick     ,kmax      ,ws        ,ltur      , ...
frac      ,sigmol    ,dicww     ,lundia    ,taucr0    , ...
rksrs     ,i2d3d     ,lsecfl    ,spirint   ,suspfrac  , ...
tetacr    ,concin    , ...
dzduu     ,dzdvv     ,ubot      ,tauadd    ,sus       , ...
bed       ,susw      ,bedw      ,espir     ,wave      , ...
scour     ,ubot_from_com        ,camax     ,eps       , ...
iform     ,npar      ,par       ,numintpar ,numrealpar, ...
numstrpar ,dllfunc   ,dllhandle ,intpar    ,realpar   , ...
strpar    , ...
aks       ,caks      ,taurat    ,seddif    ,rsedeq    , ...
kmaxsd    ,conc2d    ,sbcu      ,sbcv      ,sbwu      , ...
sbwv      ,sswu      ,sswv      ,dss       ,caks_ss3d , ...
aks_ss3d  ,ust2      ,t_relax   ,error     ]...
=calllib('eqtran','eqtran',...
sig       ,thick     ,kmax      ,ws        ,ltur      , ...
frac      ,sigmol    ,dicww     ,lundia    ,taucr0    , ...
rksrs     ,i2d3d     ,lsecfl    ,spirint   ,suspfrac  , ...
tetacr    ,concin    , ...
dzduu     ,dzdvv     ,ubot      ,tauadd    ,sus       , ...
bed       ,susw      ,bedw      ,espir     ,wave      , ...
scour     ,ubot_from_com        ,camax     ,eps       , ...
iform     ,npar      ,par       ,numintpar ,numrealpar, ...
numstrpar ,dllfunc   ,dllhandle ,intpar    ,realpar   , ...
strpar    , ...
aks       ,caks      ,taurat    ,seddif    ,rsedeq    , ...
kmaxsd    ,conc2d    ,sbcu      ,sbcv      ,sbwu      , ...
sbwv      ,sswu      ,sswv      ,dss       ,caks_ss3d , ...
aks_ss3d  ,ust2      ,t_relax   ,error     );

%% unload library

unloadlibrary eqtran
