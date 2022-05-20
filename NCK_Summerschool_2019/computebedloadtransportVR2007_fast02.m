function data = computebedloadtransport(Hs, Tp, Hdir, hd, Ur, Vr, D10, D50, D90, varargin)
%Computes bed load transports based on Van Rijn (2004, 2007)
%
%   Copyright (C) 2017 Deltares
%       grasmeij

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Oct 2017
% Created with Matlab version: 9.2.0.538062 (R2017a)

% $Id: computebedloadtransportVR2007_fast02.m 336 2018-11-23 08:28:56Z grasmeij $
% $Date: 2018-11-23 09:28:56 +0100 (vr, 23 nov 2018) $
% $Author: grasmeij $
% $Revision: 336 $
% $HeadURL: https://repos.deltares.nl/repos/MCS-AMO/trunk/matlab/projects/P1220339-kustgenese-diepe-vooroever/computebedloadtransportVR2007_fast02.m $
% $Keywords: $

%%
% clearvars;close all;clc;

OPT.keepwavesignal = false;

% overwrite defaults with user arguments
if nargin>9
    OPT = setproperty(OPT, varargin);
end

g = 9.81;

Kappa = 0.4;

% D50 = 200.*10^-6;
% D90 = 400.*10^-6;
rhos = 2650;
rhow = 1000;
% nu = 1e-6;                                                              % Fluid viscosity (m2/s)
te = 15;
nu=(4.e-5)/(20.+te);

dclay=0.000008;
dsilt=0.000032;
dsand=0.000062;
dgravel=0.002;

% fch1= cohesive sediment factor for sediments smaller than about 62 microns
% pclay can be estimated with Pclay=1.-((d50-dclay)/(dsand-dclay))^0.1
pclay = 0;

Dstar = D50.*((rhos./rhow-1).*g/nu/nu).^(1/3);                          % Particle size parameter D*
taucr = (rhos-rhow).*g.*D50.*(0.24./Dstar+0.055*(1-exp(-0.02.*Dstar))); % critical bedshear stress

fch2 = D50./(1.5.*dsand);
if fch2 >= 1
    fch2=1;
end
if fch2< 0.3
    fch2=0.3;
end

% t = [datenum('01-Jan-2018') datenum('01-Feb-2018')];
% t = [datenum('01-Jan-2018') datenum('01-Feb-2018')];


% Hs = 1.*ones(size(t));
% Hdir = [270 180].*ones(size(t));    % wave from direction, nautical convention
Hdirto = mod(Hdir+180,360);         % wave to direction
% hd = 3.*ones(size(t));
% Tp = 5.5.*ones(size(t));
% Ur = 0.*ones(size(t));
% Vr = 0.*ones(size(t));
phi = pi/2; % angle between wave and current
tanbx = 0;
tanby = 0;

del=(rhos-rhow)/rhow;

k = NaN(size(Tp));
for i=1:length(hd)
    k(i) = disper(2.*pi./Tp(i), hd(i), g);
end

abw = Hs./(2.*sinh(k.*hd));                                               % peak wave orbital excursion
ubw = pi.*Hs./(Tp.*sinh(k.*hd));                                          % peak wave orbital velocity
rls = 2.*pi./k;                                                           % wave length

% wave velocity asymmetry according to Isobe-Horikawa
% (modified by Grasmeijer April 2003)

rr=-0.4.*Hs./hd+1.0;
umax=rr.*2.*ubw;
t1 = Tp.*(g./hd).^0.5;
u1=umax./(g.*hd).^0.5;
a11 = -0.0049.*(t1).^2-0.069.*(t1)+0.2911;
raIH = -5.25-6.1.*tanh(a11.*u1-1.76);
raIH(raIH<0.5) = 0.5;
bs = ((tanbx).^2+(tanby).^2).^0.5;
rmax = -2.5.*hd./rls+0.85;
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

% wave related return current
% htrough = hd.*(0.95-0.35.*(Hs./hd));
% ur = -0.125.*g.^0.5.*Hs.^2./(sqrt(hd).*htrough);
ur = 0;

% mobility parameter
% Uhulp = UBWr+abs(Ur);
% Uwc = (Uhulp.^2+Vr.^2).^0.5;
Uhulp = sqrt(Ur.^2+Vr.^2);
Uwc = (UBWr.^2+Uhulp.^2).^0.5;
RMob = Uwc.^2./(del.*g.*D50);

Dsus=(1+0.0006.*(D50./D10-1.0).*(RMob-550)).*D50;
Dsus(RMob>=550.0) = D50;
Dsus(Dsus <= 0.5.*(D10+D50)) =0.5.*(D10+D50);
Dsus(Dsus <= 0.5.*dsilt) = 0.5*dsilt;

fcoarse = (0.25.*dgravel./D50).^1.5;
fcoarse(fcoarse >= 1)=1;

% initialize arrays
% RCr = zeros(size(RMob));
% RCmr = zeros(size(RMob));
% RWr = zeros(size(RMob));
% RCd= zeros(size(RMob));
% RC  = zeros(size(RMob));
% RW =  zeros(size(RMob));
% RA =  zeros(size(RMob));
% DELm =  zeros(size(RMob));
% DELw =  zeros(size(RMob));
% aa1 =  zeros(size(RMob));
% aa2 =  zeros(size(RMob));
% aR =   zeros(size(RMob));
% Vdel = zeros(size(RMob));
% Udel = zeros(size(RMob));
% VRa = zeros(size(RMob));
% URa =  zeros(size(RMob));
% uspar =   zeros(size(RMob));
% ustream = zeros(size(RMob));
% fcw1 = zeros(size(RMob));
% ub =  zeros(size(RMob));
% ubtotx = zeros(size(RMob));
% ubtoty = zeros(size(RMob));
% acw =  zeros(size(RMob));
% fw1ii = zeros(size(RMob));
% fw1i  = zeros(size(RMob));
% profact = zeros(size(RMob));
% fc11  = zeros(size(RMob));
% fc1i =  zeros(size(RMob));
% 
% fc02 = zeros(size(RMob));
% fw02 = zeros(size(RMob));
% beta = zeros(size(RMob));
% fcw02 = zeros(size(RMob));
% 
% fc03 = zeros(size(RMob));
% fw03 = zeros(size(RMob));
% fcw03 = zeros(size(RMob));
% 
% ubx = zeros(size(RMob));
% uby = zeros(size(RMob));

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
RCmr(i_50) = 0.0002.*fch2.*RMob(i_50).*hd(i_50);
RCmr(i_50_550) = fch2.*(-0.00002.*RMob(i_50_550)+0.011).*hd(i_50_550);
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
RMob(i_50) = 150*fcoarse*D50;
RWr(i_50_250)=(-0.65.*RMob(i_50_250)+182.5)*fcoarse*D50;
RWr(i_250) = 20*fcoarse*D50;
if D50 <= dsilt
    RWr = 20*dsilt.*ones(size(RMob));
end
RWr(RWr>=0.1)= 0.1;

% sum all roughness values
RC = (RCr.^2 + RCmr.^2 + RCd.^2).^0.5;
RW = RWr;
RC(RC<0.001) = 0.001;

disp('computing apparent roughness...')
% apparent bed roughness
RA = exp(gamma.*uratio).*RC;
RA(RA > 10*RC) = 10.*RC(RA > 10*RC);

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

aa1 = 0.5*RCr;
aa2 = 0.5*RWr;
aR = max(aa1,aa2);
aR(aR <= 0.01) = 0.01;
aR(aR <= RC/30) = RC(aR <= RC/30)./30 + max(aa1(aR <= RC/30),aa2(aR <= RC/30));

disp('computing velocity at top of effective fluid mixing layer and at reference level...')
% velocity at top of effective fluid mixing layer
hulp30=-1.+log(30.*hd./RA);
Vdel = Vr.*log(30.*DELm./RA)./hulp30;
Udel = Ur.*log(30.*DELm./RA)./hulp30;

% velocity at reference level a
VRa = Vdel.*log(30.*aR./RC)./log(30.*DELm./RC);
URa = Udel.*log(30.*aR./RC)./log(30.*DELm./RC);

VRa(DELm <= RA./30) = 0;
URa(DELm <= RA./30) = 0;

% vrar is absolute value of VRa and URa
vrar = (VRa.^2+URa.^2).^0.5;

disp('computing streaming...')
% streaming at edge of wave boundary layer
uspar = ((ubwfor+ubwback)./2.).^2./(rls./Tp);
RRR=Tp.*((ubwfor+ubwback)./2./(2.*pi))./RW;
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
profact = ((-1.+log(30.*hd./RC))./log(30.*aR./RC)).^2;
acw = abs(vrr)./(abs(ubw)+abs(vrr));
fc1i = 0.24.*log10(12.*hd./D50).^(-2.);
fc11 = 0.25.*fc1i.*profact;
fw1ii = abw./D50;
fw1ii(fw1ii > 0) = fw1ii(fw1ii > 0).^(-0.19);
fw1i = exp(-6.+5.2.*fw1ii);
fw1i(fw1i > 0.05)=0.05;
fcw1 = acw.*fc11+(1.-acw).*fw1i;

%% fcw method 02
fc02 = 8.*g./(18*log10(12.*hd/D90)).^2;
fw02 = exp(-6.+5.2.*(abw./D90).^-0.19);
fw02(fw02 > 0.05) = 0.05;
beta = 0.25.*((-1+log(30.*hd./RC))./log(30.*DELm./RC)).^2;
fcw02 = acw.*beta.*fc02+(1.-acw).*fw02;
%%

%% fcw method 03
fc03 = 2.*(Kappa./log(30.*(aR./D90))).^2;
fw03 = exp(-6.+5.2.*(abw./D90).^-0.19);
fw03(fw03 > 0.05) = 0.05;
fcw03 = acw.*fc03+(1.-acw).*fw03;
%%

tfor=ubwback./(ubwfor+ubwback).*Tp;
tback=Tp-tfor;

%% initialize arrays
data.sbx = zeros(size(RMob));
data.sbx02 = zeros(size(RMob));
data.sbx03 = zeros(size(RMob));
data.sby = zeros(size(RMob));
data.sby02 = zeros(size(RMob));
data.sby03 = zeros(size(RMob));

udtx = zeros(length(RMob),201); % wave signal is discretized in 201 steps
udty = zeros(length(RMob),201);
wavetime = zeros(length(RMob),201);
data.TT = zeros(length(RMob),201);
data.TT02 = zeros(length(RMob),201);
data.TT03 = zeros(length(RMob),201);
data.sbtx = zeros(length(RMob),201);
data.sbty = zeros(length(RMob),201);
data.sbtx02 = zeros(length(RMob),201);
data.sbty02 = zeros(length(RMob),201);
data.sbtx03 = zeros(length(RMob),201);
data.sbty03 = zeros(length(RMob),201);


%% make wave signals
disp('making wave signals...')
% hwb_wave = waitbar(0,'Making wave signals');
for it = 1:length(RMob)
%     waitbar(it./length(RMob), hwb_wave);
    [udtx(it,:), udty(it,:), wavetime(it,:)] = MakeWaveVeloSignal_fast02(ubwfor(it), ubwback(it), tfor(it), tback(it), Tp(it), Hdirto(it));
end
% close(hwb_wave);

%% compute bedload transport
% hwb_trans = waitbar(0,'Computing bed load transport');
for it = 1:length(RMob)
%     waitbar(it./length(RMob),hwb_trans);
    % combine wave orbital velocity and mean velocity
    uxt = udtx(it,:)+ubtotx(it);
    uyt = udty(it,:)+ubtoty(it);
    utvec = sqrt((uxt.^2 + uyt.^2 ));
    
    %% bedload transport with fcw method01
    tau1t = 0.5.*rhow.*fcw1(it).*utvec.^2;
    TT = (tau1t-taucr)/taucr;
    TT(TT<0.0001) = 0.0001;
    uster1t = (tau1t./rhow).^0.5;
    fsilt = dsand/D50;
    if fsilt < 1
        fsilt = 1;
    end
    sbt=0.5.*fsilt.*(1.-pclay).*D50.*rhos.*uster1t.*TT./(Dstar).^0.3;
    sbtx = uxt./utvec.*sbt;
    sbty = uyt./utvec.*sbt;
%     sbx = mean(sbtx);
%     sby = mean(sbty);
%     data.sbvec = sqrt(sbx^2+sby^2);

    data.sbtx(it,:) = sbtx;         % intra wave transport in x direction
    data.sbty(it,:) = sbty;         % intra wave transport in y direction
    data.sbx(it) = 1./Tp(it).*trapz(wavetime(it,:),sbtx);
    data.sby(it) = 1./Tp(it).*trapz(wavetime(it,:),sbty);
    data.TT(it,:) = TT;
    
    %% bedload transport with fcw method 02
    tau1t02 = 0.5.*rhow.*fcw02(it).*utvec.^2;
    TT02 = (tau1t02-taucr)/taucr;
    TT02(TT02<0.0001) = 0.0001;
    uster1t02 = (tau1t02./rhow).^0.5;
    fsilt = dsand/D50;
    if fsilt < 1
        fsilt = 1;
    end
    sbt02=0.5.*fsilt.*(1.-pclay).*D50.*rhos.*uster1t02.*TT02./(Dstar).^0.3;
    sbtx02 = uxt./utvec.*sbt02;
    sbty02 = uyt./utvec.*sbt02;
    data.sbtx02(it,:) = sbtx02;         % intra wave transport in x direction
    data.sbty02(it,:) = sbty02;         % intra wave transport in y direction
    data.sbx02(it) = 1./Tp(it).*trapz(wavetime(it,:),sbtx02);
    data.sby02(it) = 1./Tp(it).*trapz(wavetime(it,:),sbty02);
    data.TT02(it,:) = TT02;
    
    %% bedload transport with fcw method 03
    tau1t03 = 0.5.*rhow.*fcw03(it).*utvec.^2;
    TT03 = (tau1t03-taucr)/taucr;
    TT03(TT03<0.0001) = 0.0001;
    uster1t03 = (tau1t03./rhow).^0.5;
    fsilt = dsand/D50;
    if fsilt < 1
        fsilt = 1;
    end
    sbt03=0.5.*fsilt.*(1.-pclay).*D50.*rhos.*uster1t03.*TT03./(Dstar).^0.3;
    sbtx03 = uxt./utvec.*sbt03;
    sbty03 = uyt./utvec.*sbt03;
    data.sbtx03(it,:) = sbtx03;         % intra wave transport in x direction
    data.sbty03(it,:) = sbty03;         % intra wave transport in y direction
    data.sbx03(it) = 1./Tp(it).*trapz(wavetime(it,:),sbtx03);
    data.sby03(it) = 1./Tp(it).*trapz(wavetime(it,:),sbty03);
    data.TT03(it,:) = TT03;
    
    if OPT.keepwavesignal
        data.wavetime = wavetime;
        data.uxt = uxt;
        data.uyt = uyt;
    end
    
    
    %     %%
    %     figure;
    %     subplot(2,1,1);
    %     plot(wavetime,uxt);
    %     hold on;
    %     plot(wavetime,uyt);
    %     grid on
    %     legend('x','y')
    %     grid on;
    %     title('intra wave velocity');
    %     xlabel('time (s)');
    %     ylabel('orbital velocity (m/s)');
    %     subplot(2,1,2);
    %     plot(wavetime,sbtx);
    %     hold on;
    %     plot(wavetime,sbty);
    %     grid on
    %     legend('sbtx','sbty')
    %     grid on;
    %     title('intra wave transport');
    %    %%
    %
    %     subplot(2,1,2);
    %     plot(wavetime,sbtx);
    %     hold on;
    %     plot(wavetime,sbty);
    %     grid on
    %     legend('x','y')
    %     title('bedload transport');
    %     xlabel('time (s)');
    %     ylabel('bedload transport (kg/s/m)');
    
    %     data.sbt(it) = trapz(wavetime,sbt);
end
% close(hwb_trans);

%% copy to struct
data.L = rls;
data.RMob = RMob;
data.UBWr = UBWr;
data.Abw = abw;
data.Ubw = ubw;
data.Ubwfor = ubwfor;
data.Ubwback = ubwback;
data.Dstar = Dstar;
data.Dsus = Dsus;
data.taucr = taucr;
data.sbvec = sqrt(data.sbx.^2+data.sby.^2);
data.RCr = RCr;
data.RCmr = RCmr;
data.RCd = RCd;
data.RWr = RWr;
data.RC = RC;
data.RW = RW;
data.RA = RA;
data.fcw1 = fcw1;
data.fcw = fcw02;
data.DELw = DELw;
data.DELm = DELm;
data.fc1i = fc1i;
data.fc11 = fc11;
data.VRa = VRa;
data.URa = URa;
data.profact = profact;
data.hd = hd;
data.beta = beta;
data.fw1i = fw1i;
data.fc1i = fc1i;
data.fc11 = fc11;
data.fc02 = fc02;
data.fw02 = fw02;
data.fc03 = fc03;
data.fw03 = fw03;

data.ubx = ubx; % streaming in x direction
data.uby = uby; % streaming in y direction