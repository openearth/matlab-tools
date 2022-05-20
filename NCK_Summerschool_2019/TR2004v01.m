function [data] = TR2004(varargin)
%TSAND computes tidal transports based on Van Rijn (2015) formulations
%
%   TR2004 computes transports based on Van Rijn (2007) formulations.
%   The model requiers basic hydraulic parameters (wave heights, tidal depth
%   variations, tidal velocities) and basic sediment characteristics (D50,
%   D90, etc) to compute the time varying sand and mud transport rates
%
%   Syntax:
%   [data] = TR2004v01('Times',Times,'Hs',Hsi,'U1',V1t,...
%             'V1',U1t,'zvel',zvelt,...
%             'zbedt',zbedt,'d',deptht,...
%             'salt',salt,'D50',D50,'D90',D90,...
%             'psand',psand,'pmud',pmud,'pgravel',pgravel);
%
%   Input:
%       Times:  times in days (vector)
%       Hs:     wave height per time step (vector)
%       Tp:     wave period per time step (vector)
%       U1:     x-velocity profile per time step (matrix [times, levels])
%       V1:     y-velocity profile per time step (matrix [times, levels])
%       zvel:   z of velocity profile per time step (matrix [times, levels])
%       zbedt:  bed level per time step (vector)
%       d:      depth per time step (vector)
%       salt:   salinity per time step (vector)
%       D50:    median grain diameter (m)
%       D90:    D90 grain diameter (m)
%       psand:  fraction of sand (-)
%       pmud:   fraction of mud (-)
%       pgravel: fraction of gravel (-)
%   Optional input:
%       computewaverelated: logical to compute wave related bed and suspended load transport (default is false)
%       compute_stokes_return_flow: logical to compute undertow (default is false);
%       use_stokes:  logical to use stokes drift to modify velocity profile and use in transport computations
%       use_return_flow: logical to use return flow to modify velocity profile and use in transport computations
%       RW: wave-related roughness height (default computed by TR2004 but if value is given here than this fixed values will be used)
%       RC: current-related roughness height (default computed by TSAND but if value is given here than this fixed values will be used)
%       aR: reference height above bed (default computed by TSAND but if value is given here than this fixed values will be used)
%
%   Output:
%   data struct with following fields:    
%       datenum:    same as Times input
%       z:          height above the bed (m)
%       Uz:         velocity profile in x direction (m/s)
%       Vz:         velocity profile in y direction (m/s)
%       Salz:       salinity (psu)
%       Ustokesx:   depth-averaged return flow (Stokes) in x direction (m/s)
%       Ustokesy:   depth-averaged return flow (Stokes) in y direction (m/s)
%       RMob:       mobility parameter (-)
%       L:          wave length (m)
%       UBWr:       representative peak orbital velocity for reference concentration (m/s)
%       Uwc:        representative peak velocity orbital+current (m/s)
%       Abw:        peak wave orbital excursion
%       Ubw:        peak wave orbital velocity (m/s)
%       Ubwfor:     forward peak wave orbital velocity (m/s)
%       Ubwback: 	backward peak wave orbital velocity (m/s)
%       Dstar:      Particle size parameter D*
%       Dsus:       Suspended particle diameter (m)
%       taucr:      Critical shear stress for erosion (N/m2)
%       RCr:        current-related roughness due to ripples (m)
%       RCmr:       current-related roughness due to megaripples (m)
%       RCd:        current-related roughness due to dunes in rivers not implemented!!
%       RC:         sum all current-related roughness values (m)
%       RWr:        wave-related roughness due to ripples (m)
%       RW:         wave related roughness (m)
%       RA:         apparent roughness (m)
%       ubx:        streaming velocity in x direction at edge of wave boundary layer (m/s)
%       uby:        streaming velocity in y direction at edge of wave boundary layer (m/s)
%       csand:      sand concentration profile (kg/m^3)
%       qtotsandx_tint: total time-integrated (bed+suspended) sand transport in x direction (kg/m)
%       qtotsandy_tint: total time-integrated (bed+suspended) sand transport in y direction (kg/m)
%   	qtotsandx:      total (bed+suspended) sand transport in x direction (kg/s/m)
%   	qtotsandy:      total (bed+suspended) sand transport in y direction (kg/s/m)
%       qssandx:        suspended sand transport profile, Uz*csand
%       qssandy:        suspended sand transport profile, Vz*csand
%       qssandx_dint:   depth-integrated suspended load transport in x direction (kg/s/m)
%       qssandy_dint:   depth-integrated suspended load transport in y direction (kg/s/m)
%       qbsandx:        bedload transport in x direction (kg/s/m)
%       qbsandy:        bedload transport in y direction (kg/s/m)
%       qbsandvec:      bedload transport vector magnitude (kg/s/m)
%       qbtsandx:       wave signal of bedload transport in x direction (kg/s/m) 
%       qbtsandy:       wave signal of bedload transport in y direction (kg/s/m) 
%       qsasym:         wave-related suspended transport due to wave skewness (kg/s/m) 
%       qsasymx:        wave-related suspended transport in x direction due to wave skewness (kg/s/m) 
%       qsasymy:        wave-related suspended transport in y direction due to wave skewness (kg/s/m) 
%       qsasymx_tint:   time-integrated wave-related suspended transport in x direction due to wave skewness (kg/m)
%       qsasymy_tint:   time-integrated wave-related suspended transport in y direction due to wave skewness (kg/m)
%       cmud:       mud concentration profile
%       qmudxtot:       mud transport profile in x direction, Uz*cmud
%       qmudytot:       mud transport profile in y direction, Vz*cmud
%       VR:             transports from Van Rijn formula
%       SVR:            transports from Soulby-Van Rijn formula
%       EH:             transports from Engelund-Hansen formula
%
%   Example
%   [data] = TR2004v01('Times',Times,'Hs',Hsi,'U1',V1t,...
%             'V1',U1t,'zvel',zvelt,...
%             'zbedt',zbedt,'d',deptht,...
%             'salt',salt,'D50',D50,'D90',D90,...
%             'psand',psand,'pmud',pmud,'pgravel',pgravel);
%
%   See also computebedloadtransportVR2007_fast02, MakeWaveVeloSignal_fast02, tsandv04

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Bart Grasmeijer
%
%       bart.grasmeijer@deltares.nl
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 10 Apr 2015
% Created with Matlab version: 8.5.0.197613 (R2015a)

% $Id: tsandv08.m 503 2019-05-17 10:16:16Z grasmeij $
% $Date: 2019-05-17 12:16:16 +0200 (vr, 17 mei 2019) $
% $Author: grasmeij $
% $Revision: 503 $
% $HeadURL: https://repos.deltares.nl/repos/MCS-AMO/trunk/matlab/projects/P1220339-kustgenese-diepe-vooroever/tsandv08.m $
% $Keywords: sand transport, van rijn, soulsby, tidal, tsand$

%%
OPT.Times = 0:300/(24*3600):1;  % times in days

%% conditions
OPT.Hs = 1;   % wave height per time step
OPT.Tp = 6;     % wave period per time step
OPT.Hdir = 0;   % wave directions in degrees north (from direction)
OPT.U1 = [];    % velocity profile in x direction per time step
OPT.V1 = [];    % velocity profile in y direction per time step
OPT.zvel = [];  % z of velocity profile per time step
OPT.zbedt = [];  % bed level per time step
OPT.d = [];     % depth per time step
OPT.salt = [];   % salinity per time step

%% sediment fractions
OPT.psand = 0.8;    % fraction of sand (sum of sand, mud and gravel must be 1)
OPT.pmud = 0.1;     % fraction of mud
OPT.pgravel = 0.1;  % fraction of gravel
%% sand characteristics
OPT.D10 = 0.0001;   % D10 of bed material (m)
OPT.D50 = 0.0002;   % D50 of bed material (m)
OPT.D90 = 0.002;    % D90 of bed material (m)
OPT.rhosand = 1600; % sand density (kg/m3)
OPT.wssand = 0.02;  % fall velocity (m/s)
%% mud characteristics
OPT.wsmud = 0.0005; % Effective settling velocity of MUD (incl. flocculation) (m/s)
OPT.rhomud = 800;   % Dry bulk density MUD fraction (incl. pores)
OPT.cflood = 0;     % Background concentration mud (near bed) during flood (kg/m3)
OPT.cebb = 0;       % Background concentration mud (near bed) during ebb (kg/m3)
OPT.g = 9.81;       % acceleration of gravity

%% levels
OPT.nrofsigmalevels = 20;
OPT.iz = 1:1:OPT.nrofsigmalevels;   % Sigma levels

%% density, temperature and viscosity
OPT.rhos = 2650;    % Sediment density (kg/m3)
OPT.te = 15;        % temperature (degrees)
OPT.nu = 1e-6;      % Fluid viscosity (m2/s)

%% roughness heights
% RW and RC (or often also named ksw and ksc) are computed and not user
% defined

%% calibration coefficients
OPT.calcritsand = 1;
OPT.calsand = 1;
OPT.calrefsand = 1;
OPT.caleffmud = 1;
OPT.calrefconc = 1;
OPT.calmix = 1;
OPT.calSVR = 1; % calibation fector for Soulsby Van Rijn transport formula
OPT.betamax = 1.5;
OPT.calbeta = 1;

OPT.keepwavesignal = false;
OPT.computewaverelated = true;      % compute wave related bed and suspended load transport
OPT.gamma_s = 0.1;                  % coefficient for wave-related suspended load transport (default 0.1)
OPT.compute_stokes_return_flow = false;  % compute wave-related stokes drift and return flow (set OPT.use_stokes and OPT.use_return_flow to true if you want velocity profile to be corrected and used in transport computations)
OPT.use_stokes = false;             % use stokes drift to modify velocity profile and use in transport computations
OPT.use_return_flow = false;        % use return flow to modify velocity profile and use in transport computations
OPT.dampsuspension = false;         % damp suspension (set to true if in river or estuary; use x direction as positive inward)
OPT.RC = NaN;                       % current-related roughness is computed by TSAND but if value is given here than this fixed values will be used
OPT.RW = NaN;                       % wave-related roughness is computed by TSAND but if value is given here than this fixed values will be used
OPT.aR = NaN;                       % reference height is computed by TSAND based on RC and RW but if value is given here than this fixed values will be used

%% return defaults (aka introspection)
if nargin==0
    disp('No input arguments given...')
    varargout = {OPT};
    return
end

%% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
% save user arguments to output struct
data.OPT.computewaverelated = OPT.computewaverelated;
data.OPT.gamma_s = OPT.gamma_s;
data.OPT.compute_stokes_return_flow = OPT.compute_stokes_return_flow;
data.OPT.use_stokes = OPT.use_stokes;
data.OPT.use_return_flow = OPT.use_return_flow;
data.OPT.dampsuspension = OPT.dampsuspension;


%% viscosity
nu = (4.e-5)/(20.+OPT.te); % Fluid viscosity (m2/s)

%%
dclay=0.000008;
dsilt=0.000032;
dsand=0.000062;
dgravel=0.002;
% fch1= cohesive sediment factor for sediments smaller than about 62 microns
% pclay can be estimated with pclay=1.-((d50-dclay)/(dsand-dclay))^0.1
pclay = 0;

%% times
Times = OPT.Times;  % times in days
dt = (Times(4)-Times(3)).*24*3600;
data.datenum = Times;

%% conditions
data.Hs = OPT.Hs;
data.Tp = OPT.Tp;
data.Hdir = OPT.Hdir;

U1 = OPT.U1;
V1 = OPT.V1;
zvel = OPT.zvel;
zbedt = OPT.zbedt;
d = OPT.d;
salt = OPT.salt;

%% sediment fractions
psand = OPT.psand;
pmud = OPT.pmud;
pgravel = OPT.pgravel;

%% sand characteristics
D10 = OPT.D10;
D50 = OPT.D50;
D90 = OPT.D90;
rhosand = OPT.rhosand;
wssand = fallvelocity(D50);
%% mud characteristics
wsmud = OPT.wsmud; % Effective settling velocity of MUD (incl. flocculation) (m/s)
rhomud = OPT.rhomud;   % Dry bulk density MUD fraction (incl. pores)
cflood = OPT.cflood;     % Back ground concentration mud (near the bed) during flood (kg/m3)
cebb = OPT.cebb;       % Back ground concentration mud (near the bed) during ebb (kg/m3)

%% constants
g = OPT.g;       % acceleration of gravity
Kappa = 0.4;

%% levels
nrofsigmalevels = OPT.nrofsigmalevels;
iz = OPT.iz;                                                   % Sigma levels

%% density
rhos = OPT.rhos;    % Sediment density (kg/m3)

%% mean velocities
Utot = [mean(U1,2)];
Vtot = [mean(V1,2)];

%% calibration coefficients
calcritsand = OPT.calcritsand;
% calsand = OPT.calsand;
calrefsand = OPT.calrefsand;
caleffmud = OPT.caleffmud;
calrefconc = OPT.calrefconc;
calmix = OPT.calmix;
calSVR = OPT.calSVR;
gamma_s = OPT.gamma_s;

%%
t = [1:length(Times)]';                                                        % time in steps
time = (Times(t)-Times(t(1))).*24.*3600;                                    % time in seconds

% rhow = 1000+0.77.*mean(salt,2);
cl=(mean(salt,2)-0.03)./1.805;                       % from TR2004
rhow=1000.+1.455.*cl-0.0065.*(OPT.te-4.+0.4.*cl).^2; % from TR2004

fch2 = D50./(1.5.*dsand);
if fch2 >= 1
    fch2=1;
end
if fch2< 0.3
    fch2=0.3;
end

fsilt = dsand/D50;
if fsilt < 1
    fsilt = 1;
end

% Ur = mean(U1,2); % depth-mean velocity in x-direction
% Vr = mean(V1,2); % depth-mean velocity in y-direction
Ur = NaN(size(Times));
Vr = NaN(size(Times));
for iv = 1:length(Times)
    Ur(iv) = 1./d(iv).*trapz(zvel(iv,:),U1(iv,:));    
    Vr(iv) = 1./d(iv).*trapz(zvel(iv,:),V1(iv,:));
end

Hdirto = mod(data.Hdir+180,360);         % wave to direction
phi = pi/2; % angle between wave and current
tanbx = 0;
tanby = 0;

del=(rhos-rhow)./rhow;

k = NaN(size(data.Tp));
for i=1:length(d)
    k(i) = disper(2.*pi./data.Tp(i), d(i), g);
end

abw = data.Hs./(2.*sinh(k.*d));                                               % peak wave orbital excursion
ubw = pi.*data.Hs./(data.Tp.*sinh(k.*d));                                          % peak wave orbital velocity
rls = 2.*pi./k;                                                           % wave length

% wave velocity skewness according to Isobe-Horikawa
% (modified by Grasmeijer April 2003)
rr=-0.4.*data.Hs./d+1.0;
umax=rr.*2.*ubw;
t1 = data.Tp.*(g./d).^0.5;
u1=umax./(g.*d).^0.5;
a11 = -0.0049.*(t1).^2-0.069.*(t1)+0.2911;
raIH = -5.25-6.1.*tanh(a11.*u1-1.76);
raIH(raIH<0.5) = 0.5;
bs = ((tanbx).^2+(tanby).^2).^0.5;
rmax = -2.5.*d./rls+0.85;
rmax(rmax> 0.75) = 0.75;
rmax(rmax< 0.62) = 0.62;
ubwfor = umax.*(0.5+(rmax-0.5).*tanh((raIH-0.5)./(rmax-0.5)));
ubwback = umax-ubwfor;

gamma=0;
h2=phi;
if h2 > pi
    h2=2.*pi-phi;
end
gamma=0.8+h2-0.3*h2.^2;

vrr = sqrt(Ur.^2+Vr.^2);
UBWr = (0.5.*ubwfor.^3 + 0.5.*ubwback.^3).^(1./3.); % representative peak orbital velocity for reference concentration
uratio=UBWr./vrr;
uratio(uratio > 5) = 5;

% mobility parameter
Uhulp = sqrt(Ur.^2+Vr.^2);
Uwc = (UBWr.^2+Uhulp.^2).^0.5;
RMob = Uwc.^2./(del.*g.*D50);

Dsus=(1+0.0006.*(D50./D10-1.0).*(RMob-550)).*D50;
Dsus(RMob>=550.0) = D50;
Dsus(Dsus <= 0.5.*(D10+D50)) =0.5.*(D10+D50);
Dsus(Dsus <= 0.5.*dsilt) = 0.5*dsilt;

%% fall velocity of suspended sediment
wss = NaN(size(Dsus));
dshh=0.01.*g.*del.*Dsus.^3./nu./nu;
idsmall = Dsus<1.5.*dsand;
idmedium = (Dsus>=1.5*dsand & Dsus < 0.5*dgravel);
idlarge = Dsus>=0.5*dgravel;
wss(idsmall)=(del(idsmall).*g.*Dsus(idsmall).*Dsus(idsmall))./(18.*nu);
wss(idmedium) = (10.*nu./Dsus(idmedium)).*((1.+dshh(idmedium)).^0.5-1.);
wss(idlarge)=1.1.*(del(idlarge).*g.*Dsus(idlarge)).^0.5;

fcoarse = (0.25.*dgravel./D50).^1.5;
fcoarse(fcoarse >= 1)=1;

disp('computing current-related roughness due to ripples...')
% current-related roughness due to ripples
RCr = zeros(size(RMob));
i_50 = RMob<=50;
i_50_250 = RMob > 50 & RMob <= 250;
i_250 = RMob > 250;
RCr(i_50)=150.*fcoarse.*D50;
RCr(i_50_250)=(-0.65.*RMob(i_50_250)+182.5).*fcoarse.*D50;
RCr(i_250) = 20.*fcoarse.*D50;
if D50 <= dsilt
    RCr=20.*dsilt.*ones(size(RMob));
end
RCr(RCr<=D90)=D90;
RCr(RCr>=0.1)=0.1;

disp('computing current-related roughness due to megaripples...')
% current-related roughness due to megaripples in rivers,
% estuaries and coastal seas and represents the larger
% scale bed roughness
RCmr = zeros(size(RMob));
i_50 = RMob<=50;
i_50_550 = RMob > 50 & RMob <= 550;
i_550 = RMob > 550;
RCmr(i_50) = 0.0002.*fch2.*RMob(i_50).*d(i_50);
RCmr(i_50_550) = fch2.*(-0.00002.*RMob(i_50_550)+0.011).*d(i_50_550);
RCmr(i_550)=0.0;
RCmr(RCmr>0.2) = 0.2;
RCmr(RCmr < 0.02 & D50 >= 1.5.*dsand) = 0.02;
RCmr(RCmr < 0.02 & D50 < 1.5*dsand) = 200.*(D50./(1.5.*dsand)).*D50;
if D50 < 1.5*dsand
    RCmr = 200.*(D50/(1.5*dsand))*D50.*ones(size(RMob));
end
if D50 <= dsilt
    RCmr = 0.*ones(size(RMob));
end

% current-related roughness due to dunes in rivers not implemented!!
RCd = zeros(size(RMob));

disp('computing wave-related roughness due to ripples...')
% wave-related roughness due to ripples
i_50 = RMob<=50;
i_50_250 = RMob > 50 & RMob <= 250;
i_250 = RMob > 250;
RWr = zeros(size(RMob));
RWr(i_50) = 150*fcoarse*D50;
RWr(i_50_250)=(-0.65.*RMob(i_50_250)+182.5)*fcoarse*D50;
RWr(i_250) = 20*fcoarse*D50;
if D50 <= dsilt
    RWr = 20*dsilt.*ones(size(RMob));
end
RWr(RWr>=0.1)= 0.1;

% sum all roughness values
if isnan(OPT.RC) % if RC value is given as input (so not NaN) then this user defined value will be used
    RC = (RCr.^2 + RCmr.^2 + RCd.^2).^0.5;
else 
    RC = OPT.RC;
end
if isnan(OPT.RW) % if RW value is given as input (so not NaN) then this user defined value will be used
    RW = RWr;
else
    RW = OPT.RW;
end
RC(RC<0.001) = 0.001;

%% current-related friction factors TR2004
CC=18.*log10(12.*d./RC);
CC1=18.*log10(12.*d./D90);
FC=0.24.*log10(12.*d./RC).^(-2.0);
FC1=0.24.*log10(12.*d./D90).^(-2.0);

disp('computing apparent roughness...')
% apparent bed roughness
RA = exp(gamma.*uratio).*RC;
RA(RA > 10*RC) = 10.*RC(RA > 10*RC);

aa1 = 0.5*RCr;
aa2 = 0.5*RWr;
if isnan(OPT.aR) % if reference height aR value is given as input (so not NaN) then this user defined value will be used
    aR = max(aa1,aa2);
    aR(aR <= 0.01) = 0.01;
    aR(aR <= RC/30) = RC(aR <= RC/30)./30 + max(aa1(aR <= RC/30),aa2(aR <= RC/30));
else
    aR = OPT.aR;
end

%% initialize
data.z = NaN(length(t),nrofsigmalevels);
data.Uz = NaN(length(t),nrofsigmalevels);
data.Vz = NaN(length(t),nrofsigmalevels);
data.Salz = NaN(length(t),nrofsigmalevels);

data.Ureturn = NaN(length(t),nrofsigmalevels);
data.Ureturnx = NaN(length(t),nrofsigmalevels);
data.Ureturny = NaN(length(t),nrofsigmalevels);

data.Ustokes = NaN(length(t),nrofsigmalevels);
data.Ustokesx = NaN(length(t),nrofsigmalevels);
data.Ustokesy = NaN(length(t),nrofsigmalevels);

disp('making velocity profiles...')
data.z(:,1) = aR;
for it = 1:length(t)
    data.z(it,2:end) = aR(it).*(d(it)./aR(it)).^(iz(1:end-1)./(length(iz)-1));
    data.Uz(it,:) = interp1(zvel(it,:)-zbedt(it),U1(it,:),data.z(it,:),'linear','extrap');
    data.Vz(it,:) = interp1(zvel(it,:)-zbedt(it),V1(it,:),data.z(it,:),'linear','extrap');
    data.Salz(it,:) = interp1(zvel(it,:)-zbedt(it),salt(it,:),data.z(it,:),'linear','extrap');
    
    if OPT.compute_stokes_return_flow
        [data.Ureturn(it,:), data.Ustokes(it,:)] = stokes_return_flow_z(data.Hs(it) ,data.Tp(it) ,d(it) , 0, data.z(it,:), 'ksw',RW(it), 'ksc', RC(it), 'ka', RA(it)); % compute wave-related stokes drift and return current
        data.Ustokesx(it,:) = data.Ustokes(it,:).*sind(Hdirto(it));
        data.Ustokesy(it,:) = data.Ustokes(it,:).*cosd(Hdirto(it));
        data.Ureturnx(it,:) = data.Ureturn(it,:).*sind(Hdirto(it));
        data.Ureturny(it,:) = data.Ureturn(it,:).*cosd(Hdirto(it));
    end
end

% modify velocity profile with wave related stokes drift and/or return current
if OPT.compute_stokes_return_flow
    if OPT.use_stokes
        disp('modifying velocity profile with wave related stokes drift...')
        data.Uz = data.Uz+data.Ustokesx;
        data.Vz = data.Vz+data.Ustokesy;
    end
    if OPT.use_return_flow
        disp('modifying velocity profile with wave related return flow...')        
        data.Uz = data.Uz+data.Ureturnx;
        data.Vz = data.Vz+data.Ureturny;
    end 
end % OPT.compute_stokes_return_flow

C = 18.*log10(12.*d./RC);
fc = 8.*g./C.^2;
Dstar = D50.*((rhos./rhow-1).*g/nu/nu).^(1/3);                          % Particle size parameter D*

UST=sqrt(g).*abs(vrr)./CC;

k = NaN(size(t));
for i=1:length(d)
    k(i) = disper(2.*pi./data.Tp(i), d(i), g);
end

adelta = data.Hs./(2.*sinh(k.*d));                                               % peak wave orbital excursion
udelta = pi.*data.Hs./(data.Tp.*sinh(k.*d));                                          % peak wave orbital velocity
fw = exp(-6+5.2.*(adelta./RW).^-0.19);                                     % method Van Rijn
fw = min(fw,0.3);
tauw = 0.25 * rhow .* fw .* (udelta).^2;
ustarw = sqrt(tauw./rhow);
% taucw = sqrt(tauc.^2+tauw.^2);
ustarcw = sqrt(UST.^2+ustarw.^2);
data.ustarcw = ustarcw;

%% mixing
mixmax = 0.1.*ustarcw.*d;
mix = NaN(size(data.z));
for i = 1:length(d)                                                          % i is the i'th time step
    mix(i,:) = mixmax(i).*(1-(1-2.*data.z(i,:)./d(i)).^2);
    jup = data.z(i,:) >= 0.5*d(i);
    mix(i,jup) = mixmax(i);
end

%% suspension number of sand
beta = 1+2.*(wss./UST).^2;                                           % larger beta gives larger concentrations (due to smaller susnumsand)
beta(beta>OPT.betamax) = OPT.betamax; 
% mybeta = 0.5+tanh(2*wssand./ustarcw);
% mybeta = 1.+tanh(2*wssand./ustarcw-0.75);
% beta = 1.25+tanh(2*wssand./ustarcw-1);
% beta = 1.5+tanh(2*wssand./ustarcw-1.25);
% figure;
% plot(Vr,beta,'b-');
% hold on;
% plot(Vr,mybeta,'r--');
data.beta = beta;
% susnumsand = wssand./(beta.*0.4.*ustarcw);                                  % suspension number for sand without damping (larger value gives smaller concentrations)
% if OPT.dampsuspension
%     iUtotpos = Utot>0;                                                          % find flood velocities
%     lenpos = length(find(iUtotpos==1));
%     susnumsanddamp = NaN(size(Utot));                                           % initialize
%     susnumsanddampflood = wssand./(beta.*0.4.*ustarcw) ...                      % suspension number of sand with damping for flood velocities
%         +2.5.*(wssand./ustarcw).^0.8.*(crefsandadjust0./0.65).^0.4 ...
%         +(rhow./1000-1).^(calmix.*0.5);
%     susnumsanddampebb  = wssand./(beta.*0.4.*ustarcw) ...                       % suspension number of sand with damping for ebb velocities
%         +2.5.*(wssand./ustarcw).^0.8.*(crefsandadjust0./0.65).^0.4;
%     susnumsanddamp(iUtotpos) = susnumsanddampflood(iUtotpos);
%     susnumsanddamp(~iUtotpos) = susnumsanddampebb(~iUtotpos);
%     susnumsanddamp(susnumsanddamp>10) = 10;                                       % maximum value
% else
%     susnumsanddamp = susnumsand;
% end

%% suspension number of mud
susnummud = (wsmud./(0.4.*ustarcw));                                        % suspension number for mud
if OPT.dampsuspension
    susnummuddamp = NaN(size(Utot));                                            % initialize
    susnummuddampflood = wsmud./(0.4.*ustarcw)+(rhow./1000-1).^(calmix.*0.5);   % suspension number of mud with damping for flood velocities
    susnummuddampebb   = wsmud./(0.4*ustarcw);                                  % suspension number of mud with damping for ebb velocities
    susnummuddamp(iUtotpos) = susnummuddampflood(iUtotpos);
    susnummuddamp(~iUtotpos) = susnummuddampebb(~iUtotpos);
    susnummuddamp(susnummuddamp>10) = 10;                                         % maximum value
else
    susnummuddamp = susnummud;
end



%% mobility parameter
% Me = (ueff-ucritcw)./sqrt((rhos./rhow-1).*g.*D50);
% Me(Me<0) = 0;                                                           % mobility parameter

%% bed load transport formula

% disp('computing bedload transport (NOT wave-related)')
% data.VR.qbsandx = sin(alpha10).*0.015.*rhos.*(1-pmud)*1.2.*hypot(u10,v10).*d.*Me.^1.5.*(D50./d).^1.2;     % bed load transport in x direction (alpha10 is angle relative to north)
% data.VR.qbsandy = cos(alpha10).*0.015.*rhos.*(1-pmud)*1.2.*hypot(u10,v10).*d.*Me.^1.5.*(D50./d).^1.2;     % bed load transport in y direction (alpha10 is angle relative to north)
% data.VR.qbsandx_tint = trapz(time,data.VR.qbsandx);
% data.VR.qbsandy_tint = trapz(time,data.VR.qbsandy);

if OPT.computewaverelated
    %% compute wave-related transports
    disp('computing wave-related bedload transports...')
    
    disp('computing wave boundary layer and mixing layer thickness...')
    % wave boundary layer and mixing layer thickness
    DELm = zeros(size(RMob));
    DELw = zeros(size(RMob));
    DELw(abw > 0) = 0.36.*abw(abw > 0).*(abw(abw > 0)./RW(abw > 0)).^-0.25;
    DELm(abw > 0) = 2.*DELw(abw > 0);
    DELm = max(DELm,RC);
    DELm(DELm <= RA./29.9) = RA(DELm <= RA./29.9)./29.9;
    DELm(DELm>= 0.2) = 0.2;
    DELm(DELm<= 0.05) = 0.05;
    
    gambr = ones(size(data.Hs));
    ibr = find(data.Hs./d>0.4);
    gambr(ibr) = 1.+((data.Hs(ibr)./d(ibr))-0.4).^0.5;
    DS = 2.*gambr.*DELw;
    DS(DS<0.05)=0.05;
    DS(DS>=0.2)=0.2;

    h3=(log(30.*DELm./RA)./log(30.*DELm./RC)).^2;
    h4=((-1.+log(30.*d./RC))./(-1.+log(30.*d./RA))).^2;
    alfaw=h3.*h4;
    alfaw(alfaw<0) = 0;
    alfaw(alfaw>1) = 1;    
    RMUC=FC1./FC;
    RMUC(RMUC>1) = 1;
    RMUW=0.7./Dstar;
    RMUW(Dstar>=5) = 0.14;
    RMUW(Dstar<=2) = 0.35;    

    %% TAUCR from TR2004
    cmaxs=0.65;
    fch1=(dsand./D50).^1.5;
    cmax=(D50./dsand).*cmaxs;
    cmax(cmax<0.05)=0.05;
    cmax(cmax>cmaxs)=cmaxs;
    fpack=cmax/cmaxs;
    fch1(fch1<1)=1.;
    fpack(fpack>1)=1;
    fclay=1.;
    fclay(pclay>=0)=(1.+pclay).^3;
    fclay(fclay>=2)=2;
    iDstar00 = Dstar<=4;
    iDstar01 = Dstar>4 & Dstar<=10;
    iDstar02 = Dstar>10 & Dstar<=20;
    iDstar03 = Dstar>20 & Dstar<=150;
    iDstar04 = Dstar>150;
    THETCR(iDstar00,:)=0.115/(Dstar(iDstar00)).^0.5;
    THETCR(iDstar01,:)=.14*Dstar(iDstar01).^(-.64);
    THETCR(iDstar02,:)=.04*Dstar(iDstar02).^(-.1 );
    THETCR(iDstar03,:)=.013*Dstar(iDstar03).^(.29 );
    THETCR(iDstar04,:)=.055;
    FCR = 1; % correction factor for critical bed shear stress
    taucr=FCR.*fpack.*fch1.*fclay.*(rhos-rhow).*g.*D50.*THETCR;
    
    TAUC=0.125.*rhow.*FC.*vrr.*vrr;
    TAUW=0.25.*rhow.*fw.*UBWr.*UBWr;
    tauce=RMUC.*TAUC;
    TAUCEF=RMUC.*alfaw.*TAUC;
    Tc=(tauce-taucr)./taucr;
    Tc=max(0.0001,Tc);
    TAUWEF=RMUW.*TAUW;
    
    TAUCWE=TAUCEF+TAUWEF;
    RRR1=0.8+0.2.*((TAUCWE./taucr-0.8)./1.2);
    RRR1(RRR1<=0.8) = 0.8;
    RRR1(RRR1>=1.)=1;
    Tcw=(TAUCWE-RRR1.*taucr)./taucr;
    Tcw=max(.0001,Tcw);
    Thetacw=TAUCWE./((rhos-rhow).*g.*D50);
    CA=calrefsand.*0.015.*fsilt.*(1.-pclay).*D50./aR.*Dstar.^(-.3).*Tcw.^1.5;
    CA=min(CA,0.05);
    data.CA = CA;
    
%     figure;plot(crefsandadjust0,CA,'.'); grid on
    
    %% mixing, concentrations and suspended transport from TR2004
    disp('computing mixing based on TR2004...')
    
    USTW = TAUW./rhow;
    betaw = 1+2.*(wss./USTW).^2;                                           % larger beta gives larger concentrations (due to smaller susnumsand)
    betaw(betaw>OPT.betamax) = OPT.betamax;
    
	Fdamp=sqrt(250./RMob);
	Fdamp(Fdamp>=1)=1;
    Fdamp(Fdamp<=0.1)=0.1;
	EBW=0.018.*Fdamp.*betaw.*gambr.*DS.*UBWr;
    EMAXW = 0.035.*gambr.*d.*data.Hs./data.Tp;
    EMAXW(data.Tp<1) = 0;
    EMAXW(EMAXW<=EBW)=EBW(EMAXW<=EBW);
    EMAXW(EMAXW>=0.05)=0.05;
    EMAXC = 0.25.*Kappa.*UST.*d.*beta; 
    
    ESW = NaN(size(data.z));
    ESC = NaN(size(data.z)); 
    ES = NaN(size(data.z));
    csandvol = NaN(size(data.z));    
    for it = 1:length(Times)
        ESW(it,data.z(it,:)<=DS(it)) = EBW(it);
        iz_ds_05d = data.z(it,:)>DS(it)&data.z(it,:)<0.5*d(it);
        ESW(it,iz_ds_05d) = EBW(it)+(EMAXW(it)-EBW(it)).*((data.z(it,iz_ds_05d)-DS(it))./(0.5.*d(it)-DS(it)));
        iz_05_1d = data.z(it,:)>=0.5*d(it);
        ESW(it,iz_05_1d) = EMAXW(it);
        
        iz_05d = data.z(it,:)<0.5*d(it);
        ESC(it,iz_05d) = EMAXC(it)-EMAXC(it).*(1.-2.0*data.z(it,iz_05d)/d(it)).^2;
        ESC(it,iz_05_1d) = EMAXC(it);
        ES(it,:)=sqrt(ESW(it,:).^2+ESC(it,:).^2);
                
        dz = diff(data.z(it,:));
        csandvol(it,1) = CA(it);
        c1 = CA(it);
        for j = 2:length(data.z(it,:))                                      % j is the j'th height above bed
            dcdz = sedimentdcdz(ES(it,j), wss(it), c1);
            c2 = c1 + dcdz * dz(j-1);
            if(c2<0)
                c2=0;
            end
            csandvol(it,j) = c2;
            c1 = c2;
        end
        csand0 = csandvol;
        data.csand = csandvol.*rhos;
        data.csandref = data.csand(:,1);
        data.zref = data.z(:,1);
        
%         figure;
%         semilogx(data.csand(it,:),data.z(it,:),'linewidth',1);
%         hold on;
%         semilogx(csandnew(it,:),data.z(it,:),'linewidth',1);        
%         legend('TSAND','TSANDnew')
%         title(['veloticy at 0.1 h: ',num2str(v10(it),'%2.2f'),' m/s; Hm0: ',num2str(data.Hs(it),'%2.2f'),' m'])
%         pause
%         figure;        
%         plot(ES(it,:),data.z(it,:),'linewidth',1);
%         hold on;
%         grid on;
%         plot(ESW(it,:),data.z(it,:));        
%         plot(ESC(it,:),data.z(it,:));    
%         legend('ES','ESW','ESC')
    end

data.qssandx = data.Uz.*data.csand;                                                          % sand transport (kg/m2/s)
data.qssandx(:,end) = 0;
data.qssandy = data.Vz.*data.csand;                                                          % sand transport (kg/m2/s)
data.qssandy(:,end) = 0;
 
data.qssandx_dint = NaN(size(d));
data.qssandy_dint = NaN(size(d));
qssandtottmp = NaN(size(d));
for i = 1:length(d)
    data.qssandx_dint(i) = trapz(data.z(i,:),data.qssandx(i,:));
    data.qssandy_dint(i) = trapz(data.z(i,:),data.qssandy(i,:));    
end
cavsand = data.qssandx_dint./(d.*Utot);

% %%
% figure;
% plot(qssandxtot,qssandtottmp,'.')
% hold on;
% grid on;
% axis equal;
% plot([-0.6 0.6],[-0.6 0.6],'x-');
% %%

sandload = zeros(size(d));
sandloadtmp = zeros(size(d));
for i = 1:length(d)
    for j = 1:nrofsigmalevels-1
        sandload(i) = sandload(i)+rhos.*0.5*(csand0(i,j)+csand0(i,j+1)).*(data.z(i,j+1)-data.z(i,j));
    end
    sandloadtmp(i) = rhos.*trapz(data.z(i,:),csand0(i,:));
end
    

%% mud concentration and transport profiles
cmud0 = NaN(size(mix));                                                     % mud concentration in m3/m3
for i = 1:length(d)                                                         % i is the i'th time step
    cmud0(i,:) = real(1.*(((d(i)-data.z(i,:))./data.z(i,:)) ...
        .*(aR(i)./(d(i)-aR(i)))).^susnummuddamp(i));
end
cmud0(:,nrofsigmalevels) = 0;
mudload = zeros(size(d));
mudloadtmp = zeros(size(d));
for i = 1:length(d)
    for j = 1:nrofsigmalevels-1
        mudload(i) = mudload(i)+0.5*(cmud0(i,j)+cmud0(i,j+1)).*(data.z(i,j+1)-data.z(i,j));
    end
    mudloadtmp(i) = trapz(data.z(i,:),cmud0(i,:));
end

crefmud = cflood+(pmud/psand).*(rhomud/rhosand).*(sandload./mudload);

data.cmud = NaN(size(mix));
for i = 1:length(d)
    data.cmud(i,:) = crefmud(i).*cmud0(i,:);
end
% cmud(cmud<0.00000037) = 0.00000037;
qmudx = data.Uz.*data.cmud;                                                            % mud transport (kg/m2/s)
qmudy = data.Vz.*data.cmud;                                                            % mud transport (kg/m2/s)

data.qmudxtot = NaN(size(d));
data.qmudytot = NaN(size(d));
qmudtottmp = NaN(size(d));
for i = 1:length(d)
    data.qmudxtot(i) = 0.666.*data.z(i,1).*qmudx(i,1);
    data.qmudytot(i) = 0.666.*data.z(i,1).*qmudy(i,1);
    for j = 1:nrofsigmalevels-1
        data.qmudxtot(i) = data.qmudxtot(i)+0.5*(qmudx(i,j)+qmudx(i,j+1)).*(data.z(i,j+1)-data.z(i,j));
        data.qmudytot(i) = data.qmudytot(i)+0.5*(qmudy(i,j)+qmudy(i,j+1)).*(data.z(i,j+1)-data.z(i,j));
    end
    qmudtottmp(i) = trapz(data.z(i,:),qmudx(i,:));
end

    
    disp('computing velocity at top of effective fluid mixing layer and at reference level...')
    % velocity at top of effective fluid mixing layer
    hulp30=-1.+log(30.*d./RA);
    Vdel = Vr.*log(30.*DELm./RA)./hulp30;
    Udel = Ur.*log(30.*DELm./RA)./hulp30;
    
    % velocity at reference level aR
    VRa = Vdel.*log(30.*aR./RC)./log(30.*DELm./RC);
    URa = Udel.*log(30.*aR./RC)./log(30.*DELm./RC);
    
    VRa(DELm <= RA./30) = 0;
    URa(DELm <= RA./30) = 0;
    
    % vrar is absolute value of VRa and URa
    vrar = (VRa.^2+URa.^2).^0.5;
    
    disp('computing streaming...')
    % streaming at edge of wave boundary layer
    uspar = ((ubwfor+ubwback)./2.).^2./(rls./data.Tp);
    RRR=data.Tp.*((ubwfor+ubwback)./2./(2.*pi))./RW;
    ustream = zeros(size(RMob));
    iRRR_1 = RRR <= 1;
    iRRR_1_100 = RRR > 1 & RRR <= 100;
    iRRR_100 = RRR > 100;
    ustream(iRRR_1) = -1.0*uspar(iRRR_1);
    ustream(iRRR_1_100) = (-1.+0.875.*log10(RRR(iRRR_1_100))).*uspar(iRRR_1_100);
    ustream(iRRR_100) = 0.75.*uspar(iRRR_100);
    ub = ustream;
    
    ubx = ub.*sind(Hdirto);
    uby = ub.*cosd(Hdirto);
    
    ubtotx = ub.*sind(Hdirto)+URa; % streaming + velocity in x direction
    ubtoty = ub.*cosd(Hdirto)+VRa; % streaming + velocity in y direction
    
    disp('computing fcw...')
    %% fcw method 01
    profact = ((-1.+log(30.*d./RC))./log(30.*aR./RC)).^2;
    acw = abs(vrr)./(abs(ubw)+abs(vrr));
    fc1i = 0.24.*log10(12.*d./D50).^(-2.);
    fc11 = 0.25.*fc1i.*profact;
    fw1ii = abw./D50;
    fw1ii(fw1ii > 0) = fw1ii(fw1ii > 0).^(-0.19);
    fw1i = exp(-6.+5.2.*fw1ii);
    fw1i(fw1i > 0.05)=0.05;
    fcw1 = acw.*fc11+(1.-acw).*fw1i;
    
    %% fcw method 02
%     fc02 = 8.*g./(18*log10(12.*d/D90)).^2;
%     fw02 = exp(-6.+5.2.*(abw./D90).^-0.19);
%     fw02(fw02 > 0.05) = 0.05;
%     betacw = 0.25.*((-1+log(30.*d./RC))./log(30.*DELm./RC)).^2;
%     fcw02 = acw.*betacw.*fc02+(1.-acw).*fw02;
    %%
    
%     %% fcw method 03
%     fc03 = 2.*(Kappa./log(30.*(aR./D90))).^2;
%     fw03 = exp(-6.+5.2.*(abw./D90).^-0.19);
%     fw03(fw03 > 0.05) = 0.05;
%     fcw03 = acw.*fc03+(1.-acw).*fw03;

    %%   
    tfor=ubwback./(ubwfor+ubwback).*data.Tp;
    tback=data.Tp-tfor;
    
    %% initialize arrays
    data.qbsandx = zeros(size(RMob));
%     data.qbsandx02 = zeros(size(RMob));
%     data.qbsandx03 = zeros(size(RMob));
    data.qbsandy = zeros(size(RMob));
%     data.qbsandy02 = zeros(size(RMob));
%     data.qbsandy03 = zeros(size(RMob));
    
    udtx = zeros(length(RMob),201); % wave signal is discretized in 201 steps
    udty = zeros(length(RMob),201);
    wavetime = zeros(length(RMob),201);
    data.TT = zeros(length(RMob),201);
%     data.TT02 = zeros(length(RMob),201);
%     data.TT03 = zeros(length(RMob),201);
    data.qbtsandx = zeros(length(RMob),201);
    data.qbtsandy = zeros(length(RMob),201);
%     data.qbtsandx02 = zeros(length(RMob),201);
%     data.qbtsandy02 = zeros(length(RMob),201);
%     data.qbtsandx03 = zeros(length(RMob),201);
%     data.qbtsandy03 = zeros(length(RMob),201);
    
    
    %% make wave signals
    disp('making wave signals...')
    for it = 1:length(RMob)
        [udtx(it,:), udty(it,:), wavetime(it,:)] = MakeWaveVeloSignal_fast02(ubwfor(it), ubwback(it), tfor(it), tback(it), data.Tp(it), Hdirto(it));
    end
    
    %% compute bedload transport
    for it = 1:length(RMob)
        % combine wave orbital velocity and mean velocity
        uxt = udtx(it,:)+ubtotx(it);
        uyt = udty(it,:)+ubtoty(it);
        utvec = sqrt((uxt.^2 + uyt.^2 ));
        
%         %% bedload transport with fcw method01
        tau1t = 0.5.*rhow(it).*fcw1(it).*utvec.^2;
        TT = (tau1t-taucr(it))/taucr(it);
        TT(TT<0.0001) = 0.0001;
        uster1t = (tau1t./rhow(it)).^0.5;
        fsilt = dsand/D50;
        if fsilt < 1
            fsilt = 1;
        end
        sbt=0.5.*fsilt.*(1.-pclay).*D50.*rhos.*uster1t.*TT./(Dstar(it)).^0.3;
        qbtsandx = uxt./utvec.*sbt;
        qbtsandy = uyt./utvec.*sbt;
        
        data.qbtsandx(it,:) = qbtsandx;         % intra wave transport in x direction
        data.qbtsandy(it,:) = qbtsandy;         % intra wave transport in y direction
        data.qbsandx(it) = 1./data.Tp(it).*trapz(wavetime(it,:),qbtsandx);
        data.qbsandy(it) = 1./data.Tp(it).*trapz(wavetime(it,:),qbtsandy);
        data.TT(it,:) = TT;
        
        if OPT.keepwavesignal
            data.wavetime = wavetime;
            data.uxt = uxt;
            data.uyt = uyt;
        end
        
    end
%     close(hwb_trans);

    %% copy to struct
    data.L = rls;
    data.RMob = RMob;
    data.UBWr = UBWr;
    data.Uwc = Uwc;
    data.Abw = abw;
    data.Ubw = ubw;
    data.Ubwfor = ubwfor;
    data.Ubwback = ubwback;
    data.Dstar = Dstar;
    data.Dsus = Dsus;
    data.taucr = taucr;
%     data.tauc = tauc;
    data.tauw = TAUW;
    data.EBW = EBW;
    data.EMAXW = EMAXW;
    data.wssand = wss;
    data.TAUCEF = TAUCEF;
    data.TAUWEF = TAUWEF;
    data.TAUCWE = TAUCWE;
    data.qbsandvec = sqrt(data.qbsandx.^2+data.qbsandy.^2);
    data.RCr = RCr;
    data.RCmr = RCmr;
    data.RCd = RCd;
    data.RWr = RWr;
    data.RC = RC;
    data.RW = RW;
    data.RA = RA;
    data.aR = aR;
    data.fw = fw;
    data.fcw1 = fcw1;
%     data.fcw = fcw01;
    data.DELw = DELw;
    data.DELm = DELm;
    data.fc1i = fc1i;
    data.fc11 = fc11;
    data.VRa = VRa;
    data.URa = URa;
    data.profact = profact;
    data.d = d;
    data.beta = beta;
    data.betaw = betaw;
    data.fw1i = fw1i;
    data.fc1i = fc1i;
    data.fc11 = fc11;
    
    data.ubx = ubx; % streaming in x direction
    data.uby = uby; % streaming in y direction
    
    Phasef = ones(size(data.Hs));
    PP = RWr./(wssand.*data.Tp);
    PPCR = 0.1;
    Phasef=-tanh(100.*(PP-PPCR));
    
    disp('computing wave-related suspended load transports...')
    for it = 1:length(ubwfor)
        ids = find(data.z(it,:)<=DS(it));
        if length(ids)>1
            data.qsasym(it,1) = gamma_s.*(ubwfor(it).^4-ubwback(it).^4)./(ubwfor(it).^3+ubwback(it).^3).*trapz(data.z(it,ids),data.csand(it,ids));
            data.qsasymx(it,1) = sind(Hdirto(it)).*data.qsasym(it);
            data.qsasymy(it,1) = cosd(Hdirto(it)).*data.qsasym(it);
        else
            data.qsasym(it,1) = 0;
            data.qsasymx(it,1) = 0;
            data.qsasymy(it,1) = 0;
        end        
    end
end

%% total load transport from conc profiles and bedload
if OPT.computewaverelated
    data.qtotsandx = data.qssandx_dint+data.qsasymx+data.qbsandx;               % total load transport (kg/s/m)
else
    data.qtotsandx = data.qssandx_dint+data.qbsandx;               % total load transport (kg/s/m)
end
data.qssandx_tint = trapz(time,data.qssandx_dint);                          % suspended load transport time-integrated (kg/m)
data.qbsandx_tint = trapz(time,data.qbsandx);                               % bedload transport time-integrated (kg/m)
data.qtotsandx_tint = trapz(time,data.qtotsandx);                           % total load transport time-integrated (kg/m)

if OPT.computewaverelated
    data.qtotsandy = data.qssandy_dint+data.qsasymy+data.qbsandy;               % total load transport in y direction (kg/s/m)
else
    data.qtotsandy = data.qssandy_dint+data.qbsandy;               % total load transport in y direction (kg/s/m)
end
data.qssandy_tint = trapz(time,data.qssandy_dint);                          % suspended load transport time-integrated (kg/m)
data.qbsandy_tint = trapz(time,data.qbsandy);                               % bedload transport time-integrated (kg/m)
data.qtotsandy_tint = trapz(time,data.qtotsandy);                           % total load transport in y direction time-integrated (kg/m)

if OPT.computewaverelated
    data.qsasymx_tint = trapz(time,data.qsasymx);                               % wave-related suspended transport in x direction time integrated (kg/m)
    data.qsasymy_tint = trapz(time,data.qsasymy);                               % wave-related suspended transport in y direction time integrated (kg/m)
else
    
end

%% suspended load transport formula
% data.VR.qssandx = sin(alpha10).*0.008.*rhos.*(1-pmud).*1.2.*hypot(u10,v10).*d.*Me.^2.4.*(D50./d).*Dstar.^-0.6;    % suspended load transport in x direction (alpha10 is angle relative to north)
% data.VR.qssandy = cos(alpha10).*0.008.*rhos.*(1-pmud).*1.2.*hypot(u10,v10).*d.*Me.^2.4.*(D50./d).*Dstar.^-0.6;    % suspended load transport in y direction (alpha10 is angle relative to north)
% data.VR.qssandx_tint = trapz(time,data.VR.qssandx);
% data.VR.qssandy_tint = trapz(time,data.VR.qssandy);

% data.VR.qssandxadjust = NaN(size(data.VR.qssandx));
% data.VR.qssandxadjust(1) = data.VR.qssandx(1);
% data.VR.qssandyadjust = NaN(size(data.VR.qssandy));
% data.VR.qssandyadjust(1) = data.VR.qssandy(1);

% for i = 2:length(data.VR.qssandx)
%     data.VR.qssandxadjust(i) = (1./(1+coefsand(i)*dt)).*data.VR.qssandxadjust(i-1) ...
%         +((coefsand(i).*dt)./(1+coefsand(i).*dt))*data.VR.qssandx(i);
%     data.VR.qssandyadjust(i) = (1./(1+coefsand(i)*dt)).*data.VR.qssandyadjust(i-1) ...
%         +((coefsand(i).*dt)./(1+coefsand(i).*dt))*data.VR.qssandy(i);
% end

%% total load transport Van Rijn formula in x direction
% data.VR.qtotsandx = data.VR.qbsandx+data.VR.qssandx;                                           % total load transport Van Rijn formula
% data.VR.qtotsandadjust = data.VR.qbsandx+data.VR.qssandxadjust;                               % total load transport Van Rijn formula adjusted
% cav = data.VR.qtotsandx./(d.*Utot);                                            % depth-averaged concentration Van Rijn formula (kg/m3)
% data.VR.qtotsandx_tint = trapz(time,data.VR.qtotsandx);                       % total load transport time-integrated (kg/m)

%% total load transport Van Rijn formula in y direction
% data.VR.qtotsandy = data.VR.qbsandy+data.VR.qssandy;                                           % total load transport Van Rijn formula
% data.VR.qtotsandyadjust = data.VR.qbsandy+data.VR.qssandyadjust;                               % total load transport Van Rijn formula adjusted
% cavy = data.VR.qtotsandy./(d.*Utot);                                            % depth-averaged concentration Van Rijn formula (kg/m3)
% data.VR.qtotsandy_tint = trapz(time,data.VR.qtotsandy);                       % total load transport time-integrated (kg/m)

%% total load transport Engelund Hansen formula
% qtotsandEH = 0.05.*rhos.*psand.*(C.^2.*UST.^5) ...
%     ./((rhos./rhow-1).^2.*g^3.*D50);
% qtotsandEH_tint = trapz(time,qtotsandEH);

%% total load transport Engelund Hansen formula
% data.EH.qtotsandx = sin(alpha10).*0.05.*rhos.*psand.*(C.^2.*UST.^5) ...
%     ./((rhos./rhow-1).^2.*g^3.*D50);
% data.EH.qtotsandx_tint = trapz(time,data.EH.qtotsandx);

%% total load transport Engelund Hansen formula
% data.EH.qtotsandy = cos(alpha10).*0.05.*rhos.*psand.*(C.^2.*UST.^5) ...
%     ./((rhos./rhow-1).^2.*g^3.*D50);
% data.EH.qtotsandy_tint = trapz(time,data.EH.qtotsandy);

%% total load transport Soulsby Van Rijn; see Dynamics of Marine Sands by Soulsby (1997)
Tz = 0.781.*data.Tp;
Hrms = 1/sqrt(2).*data.Hs;
data.SVR.Urms = 1/sqrt(2).*pi.*Hrms./data.Tp./sinh(k.*d);
% data.SVR.Urms = 0.262.*ones(size(Hrms));
% z0=RC./30;
z0 = 0.006;
delta = rhos./rhow-1;
if D50<=0.5e-3
    data.SVR.Ucr = 0.19.*D50.^0.1*log10(4.*d./D90);
else
    data.SVR.Ucr = 8.5.*D50.^0.6.*log10(4.*d./D90);
end
data.SVR.Cf =(Kappa./(log(d./z0)-1)).^2;
% vrr10 = sqrt(u10.^2+v10.^2);
% figure;plot(vrr,vrr10,'.'); hold on; plot([0 1],[0 1]); xlabel('vrr');ylabel('vrr10'); axis equal
umod = sqrt(vrr.^2+0.018./data.SVR.Cf.*data.SVR.Urms.^2); 
imotion = umod>data.SVR.Ucr;
ksi = zeros(size(umod));
ksi(imotion) = (umod(imotion)-data.SVR.Ucr(imotion)).^2.4;
data.SVR.Vmean = vrr;
data.SVR.Asb = 0.005.*d.*(D50./d./delta./g./D50).^1.2;
data.SVR.Ass = 0.012.*D50.*Dstar.^(-0.6)./(delta.*g.*D50).^1.2;
data.SVR.As = data.SVR.Asb+data.SVR.Ass;

data.SVR.qtotsand = calSVR.*rhos.*data.SVR.As.*vrr.*ksi;
data.SVR.qtotsandx = abs(data.SVR.qtotsand).*Ur./abs(vrr);
data.SVR.qtotsandy = abs(data.SVR.qtotsand).*Vr./abs(vrr);
data.SVR.qbsandx = calSVR.*rhos.*data.SVR.Asb.*vrr.*Ur./abs(vrr).*ksi;
data.SVR.qbsandy = calSVR.*rhos.*data.SVR.Asb.*vrr.*Vr./abs(vrr).*ksi;
data.SVR.qssandx = calSVR.*rhos.*data.SVR.Ass.*vrr.*Ur./abs(vrr).*ksi;
data.SVR.qssandy = calSVR.*rhos.*data.SVR.Ass.*vrr.*Vr./abs(vrr).*ksi;

data.SVR.qtotsandx_tint = trapz(time,data.SVR.qtotsandx);
data.SVR.qtotsandy_tint = trapz(time,data.SVR.qtotsandy);
data.SVR.qbsandx_tint = trapz(time,data.SVR.qbsandx);
data.SVR.qbsandy_tint = trapz(time,data.SVR.qbsandy);
data.SVR.qssandx_tint = trapz(time,data.SVR.qssandx);
data.SVR.qssandy_tint = trapz(time,data.SVR.qssandy);

disp(['Adding ',mfilename,' meta data to output struct...'])
data.meta.username = getenv('username');
data.meta.computername = getenv('computername');
data.meta.mfilename = mfilename;
data.meta.date = datestr(now);
