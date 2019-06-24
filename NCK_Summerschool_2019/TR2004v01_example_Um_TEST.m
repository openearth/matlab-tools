%Test TR2004v01. Example in Soulsby (1997)
%
%
%   Copyright (C) 2018 Deltares
%       grasmeij

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Aug 2018
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: TR2004v01_example_Um_TEST.m 502 2019-05-17 10:05:27Z grasmeij $
% $Date: 2019-05-17 12:05:27 +0200 (vr, 17 mei 2019) $
% $Author: grasmeij $
% $Revision: 502 $
% $HeadURL: https://repos.deltares.nl/repos/MCS-AMO/trunk/matlab/projects/P1220339-kustgenese-diepe-vooroever/tsandv08_example_Um_TEST.m $
% $Keywords: Soulsby, sand transport, TR2004$

%%
clearvars;close all;clc;

addtofname = 'TR2004v01';

dgravel=0.002;
g = 9.81;

Times = [1:1:50]';
it = 1:length(Times);
d = 15.*ones(size(Times));
D10 = 0.00010;
D50 = 0.00025;
D90 = 0.00050;
rhow = 1000;
rhos = 2650;
te = 15;
sal = 0;
Vr = interp1([1 50],[0.1 2],Times);
% Vr = interp1([1 50],[0.5 0.7],Times);
Ur = zeros(size(Times));
Hm0_00 = 0.01.*ones(size(Times));
Hm0_01 = 1.*ones(size(Times));
Hm0_02 = 2.*ones(size(Times));
Hm0_03 = 3.*ones(size(Times));
Tp = 6.*ones(size(Times));
phi = 90;
a = 0.05;
Hdir = 270.*ones(size(Times));
zbedt = -d.*ones(size(Times));
salt = zeros(size(Times));
psand = 1;
pmud = 0;
pgravel = 0;
pclay = 0;
nrofsigmalevels = 20;

myRW = NaN; % if NaN then computed by TR2004
myRC = NaN;
myaR = NaN;

del=(rhos-rhow)./rhow;

k = disper(2.*pi./Tp,d,g);
abw_00 = Hm0_00./(2.*sinh(k.*d));                                               % peak wave orbital excursion
abw_01 = Hm0_01./(2.*sinh(k.*d));                                               % peak wave orbital excursion
abw_02 = Hm0_02./(2.*sinh(k.*d));                                               % peak wave orbital excursion
abw_03 = Hm0_03./(2.*sinh(k.*d));                                               % peak wave orbital excursion

ubw_00 = pi.*Hm0_00./(Tp.*sinh(k.*d));                                          % peak wave orbital velocity
ubw_01 = pi.*Hm0_01./(Tp.*sinh(k.*d));                                          % peak wave orbital velocity
ubw_02 = pi.*Hm0_02./(Tp.*sinh(k.*d));                                          % peak wave orbital velocity
ubw_03 = pi.*Hm0_03./(Tp.*sinh(k.*d));                                          % peak wave orbital velocity

vrr = sqrt(Ur.^2+Vr.^2);
Uhulp = sqrt(Ur.^2+Vr.^2);

Uwc_00 = (ubw_00.^2+Uhulp.^2).^0.5;
RMob_00 = Uwc_00.^2./(del.*g.*D50);

Uwc_01 = (ubw_01.^2+Uhulp.^2).^0.5;
RMob_01 = Uwc_01.^2./(del.*g.*D50);

Uwc_02 = (ubw_02.^2+Uhulp.^2).^0.5;
RMob_02 = Uwc_02.^2./(del.*g.*D50);

Uwc_03 = (ubw_03.^2+Uhulp.^2).^0.5;
RMob_03 = Uwc_03.^2./(del.*g.*D50);

R00 = bedroughnessVanRijn(RMob_00, D50, D90, d);
R01 = bedroughnessVanRijn(RMob_01, D50, D90, d);
R02 = bedroughnessVanRijn(RMob_02, D50, D90, d);
R03 = bedroughnessVanRijn(RMob_03, D50, D90, d);

% R00.RC = 0.03.*ones(size(RMob_00));
% R01.RC = 0.03.*ones(size(RMob_01));
% R02.RC = 0.03.*ones(size(RMob_02));
% R03.RC = 0.03.*ones(size(RMob_03));

% R00.RW = R00.RC;
% R01.RW = R01.RC
% R02.RW = R02.RC
% R03.RW = R03.RC

% apparent roughness
gamma=0;
h2=pi/2; % assuming waves perpendiculat to current
if h2 > pi
    h2=2.*pi-phi;
end
gamma=0.8+h2-0.3*h2.^2;

uratio_00 = ubw_00./vrr;
uratio_00(uratio_00 > 5) = 5;
R00.RA = exp(gamma.*uratio_00).*R00.RC;
R00.RA(R00.RA > 10*R00.RC) = 10.*R00.RC(R00.RA > 10*R00.RC);

uratio_01 = ubw_01./vrr;
uratio_01(uratio_01 > 5) = 5;
R01.RA = exp(gamma.*uratio_01).*R01.RC;
R01.RA(R01.RA > 10*R01.RC) = 10.*R01.RC(R01.RA > 10*R01.RC);

uratio_02 = ubw_02./vrr;
uratio_02(uratio_02 > 5) = 5;
R02.RA = exp(gamma.*uratio_02).*R02.RC;
R02.RA(R02.RA > 10*R02.RC) = 10.*R02.RC(R02.RA > 10*R02.RC);

uratio_03 = ubw_03./vrr;
uratio_03(uratio_03 > 5) = 5;
R03.RA = exp(gamma.*uratio_03).*R03.RC;
R03.RA(R03.RA > 10*R03.RC) = 10.*R03.RC(R03.RA > 10*R03.RC);

DELm_00 = zeros(size(RMob_00));
DELw_00 = zeros(size(RMob_00));
DELw_00(abw_00 > 0) = 0.36.*abw_00(abw_00 > 0).*(abw_00(abw_00 > 0)./R00.RW(abw_00 > 0)).^-0.25;
DELm_00(abw_00 > 0) = 2.*DELw_00(abw_00 > 0);
DELm_00 = max(DELm_00,R00.RC);
DELm_00(DELm_00 <= R00.RA./29.9) = R00.RA(DELm_00 <= R00.RA./29.9)./29.9;
DELm_00(DELm_00>= 0.2) = 0.2;
DELm_00(DELm_00<= 0.05) = 0.05;

DELm_01 = zeros(size(RMob_01));
DELw_01 = zeros(size(RMob_01));
DELw_01(abw_01 > 0) = 0.36.*abw_01(abw_01 > 0).*(abw_01(abw_01 > 0)./R01.RW(abw_01 > 0)).^-0.25;
DELm_01(abw_01 > 0) = 2.*DELw_01(abw_01 > 0);
DELm_01 = max(DELm_01,R01.RC);
DELm_01(DELm_01 <= R01.RA./29.9) = R01.RA(DELm_01 <= R01.RA./29.9)./29.9;
DELm_01(DELm_01>= 0.2) = 0.2;
DELm_01(DELm_01<= 0.05) = 0.05;

DELm_02 = zeros(size(RMob_02));
DELw_02 = zeros(size(RMob_02));
DELw_02(abw_02 > 0) = 0.36.*abw_02(abw_02 > 0).*(abw_02(abw_02 > 0)./R02.RW(abw_02 > 0)).^-0.25;
DELm_02(abw_02 > 0) = 2.*DELw_02(abw_02 > 0);
DELm_02 = max(DELm_02,R02.RC);
DELm_02(DELm_02 <= R02.RA./29.9) = R02.RA(DELm_02 <= R02.RA./29.9)./29.9;
DELm_02(DELm_02>= 0.2) = 0.2;
DELm_02(DELm_02<= 0.05) = 0.05;

DELm_03 = zeros(size(RMob_03));
DELw_03 = zeros(size(RMob_03));
DELw_03(abw_03 > 0) = 0.36.*abw_03(abw_03 > 0).*(abw_03(abw_03 > 0)./R03.RW(abw_03 > 0)).^-0.25;
DELm_03(abw_03 > 0) = 2.*DELw_03(abw_03 > 0);
DELm_03 = max(DELm_03,R03.RC);
DELm_03(DELm_03 <= R03.RA./29.9) = R03.RA(DELm_03 <= R03.RA./29.9)./29.9;
DELm_03(DELm_03>= 0.2) = 0.2;
DELm_03(DELm_03<= 0.05) = 0.05;


%%
% figure;
% plot(R00.aR)
% hold on;
% plot(R01.aR)
% plot(R02.aR)
% plot(R03.aR)
% title('reference height aR')
%%

iz = 1:1:nrofsigmalevels;   % Sigma levels
z_00 = NaN(length(it),nrofsigmalevels);
U1t_00 = NaN(length(it),nrofsigmalevels);
V1t_00 = NaN(length(it),nrofsigmalevels);
z_01 = NaN(length(it),nrofsigmalevels);
U1t_01 = NaN(length(it),nrofsigmalevels);
V1t_01 = NaN(length(it),nrofsigmalevels);

z_02 = NaN(length(it),nrofsigmalevels);
U1t_02 = NaN(length(it),nrofsigmalevels);
V1t_02 = NaN(length(it),nrofsigmalevels);

z_03 = NaN(length(it),nrofsigmalevels);
U1t_03 = NaN(length(it),nrofsigmalevels);
V1t_03 = NaN(length(it),nrofsigmalevels);

salt = zeros(length(it),nrofsigmalevels);

% make velocity profile for Hm0_00
for it = 1:length(Times)
    z_00(it,1) = R00.aR(it);
    z_00(it,2:end) = R00.aR(it).*(d(it)./R00.aR(it)).^(iz(1:end-1)./(length(iz)-1));
    
    iz05 = z_00(it,:)<0.5.*d(it);
    V1t_00(it,iz05) = Vr(it) .* ((z_00(it,iz05)./(0.32.*d(it)))).^(1/7);
    V1t_00(it,~iz05) = 1.07.*Vr(it);
end
zvelt_00 = z_00+zbedt;
U1t_00 = zeros(size(V1t_00));

% make velocity profile for Hm0_01
for it = 1:length(Times)
    z_01(it,1) = R01.aR(it);
    z_01(it,2:end) = R01.aR(it).*(d(it)./R01.aR(it)).^(iz(1:end-1)./(length(iz)-1));
    
    iz05 = z_00(it,:)<0.5.*d(it);
    V1t_01(it,iz05) = Vr(it) .* ((z_01(it,iz05)./(0.32.*d(it)))).^(1/7);
    V1t_01(it,~iz05) = 1.07.*Vr(it);
end
zvelt_01 = z_01+zbedt;
U1t_01 = zeros(size(V1t_01));

% make velocity profile for Hm0_02
for it = 1:length(Times)
    z_02(it,1) = R02.aR(it);
    z_02(it,2:end) = R02.aR(it).*(d(it)./R02.aR(it)).^(iz(1:end-1)./(length(iz)-1));
    
    iz05 = z_00(it,:)<0.5.*d(it);
    V1t_02(it,iz05) = Vr(it) .* ((z_02(it,iz05)./(0.32.*d(it)))).^(1/7);
    V1t_02(it,~iz05) = 1.07.*Vr(it);
end
zvelt_02 = z_02+zbedt;
U1t_02 = zeros(size(V1t_02));

% make velocity profile for Hm0_03
for it = 1:length(Times)
    z_03(it,1) = R03.aR(it);
    z_03(it,2:end) = R03.aR(it).*(d(it)./R03.aR(it)).^(iz(1:end-1)./(length(iz)-1));
    
    iz05 = z_03(it,:)<0.5.*d(it);
    V1t_03(it,iz05) = Vr(it) .* ((z_03(it,iz05)./(0.32.*d(it)))).^(1/7);
    V1t_03(it,~iz05) = 1.07.*Vr(it);
end
zvelt_03 = z_03+zbedt;
U1t_03 = zeros(size(V1t_03));


% cd C:\Users\grasmeij\OnCLOSeDrive - Stichting Deltares\Documents\SVN_Projects\MCS-AMO\trunk\matlab\projects\P1220339-kustgenese-diepe-vooroever\
for it = 1:length(Times)
    velprof_00(it) = velocityprofileVanRijn(Ur(it), Vr(it), d(it), R00.RC(it), R00.RA(it), DELm_00(it), R00.aR(it), nrofsigmalevels);
    velprof_01(it) = velocityprofileVanRijn(Ur(it), Vr(it), d(it), R01.RC(it), R01.RA(it), DELm_01(it), R01.aR(it), nrofsigmalevels);    
    velprof_02(it) = velocityprofileVanRijn(Ur(it), Vr(it), d(it), R02.RC(it), R02.RA(it), DELm_02(it), R02.aR(it), nrofsigmalevels);    
    velprof_03(it) = velocityprofileVanRijn(Ur(it), Vr(it), d(it), R03.RC(it), R03.RA(it), DELm_03(it), R03.aR(it), nrofsigmalevels);    
    
    V1t_00(it,:) = velprof_00(it).UCa;
    V1t_01(it,:) = velprof_01(it).UCa;   
    V1t_02(it,:) = velprof_02(it).UCa;    
    V1t_03(it,:) = velprof_03(it).UCa;    
end

%% plot effect of waves on velocity profile
figpath = [cd,'\']; % change cd to the figure path
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(V1t_00(18,:),z_00(18,:),'b-');
hold on;
plot(V1t_01(18,:),z_01(18,:),'g--');
plot(V1t_02(18,:),z_02(18,:),'m:');
plot(V1t_03(18,:),z_03(18,:),'r-.');
grid on;
set(gca,'fontsize',7)
legend('Hm0 = 0 m','Hm0 = 1 m', 'Hm0 = 2 m','Hm0 = 3 m');
title('Effect of waves on velocity profile')
xlabel('velocity (m/s)');
ylabel('z (m)');
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r300',[figpath,filesep,'Deltares_figure'])  % print figure at 300 dpi
%%

data00 = TR2004v01('Times',Times,...
    'Hs',Hm0_00,'Tp',Tp,'Hdir',Hdir,...
    'U1',U1t_00,...
    'V1',V1t_00,'zvel',zvelt_00,...
    'zbedt',zbedt,'d',d,...
    'salt',salt,'D10',D10,'D50',D50,'D90',D90,...
    'psand',psand,'pmud',pmud,'pgravel',pgravel,...
    'computewaverelated',true,...
    'compute_stokes_return_flow',false,...
    'nrofsigmalevels',nrofsigmalevels,...
    'RW',myRW.*ones(size(Hm0_00)),...
    'RC',myRC.*ones(size(Hm0_00)),...
    'aR',myaR.*ones(size(Hm0_00)));

data01 = TR2004v01('Times',Times,...
    'Hs',Hm0_01,'Tp',Tp,'Hdir',Hdir,...
    'U1',U1t_01,...
    'V1',V1t_01,'zvel',zvelt_01,...
    'zbedt',zbedt,'d',d,...
    'salt',salt,'D10',D10,'D50',D50,'D90',D90,...
    'psand',psand,'pmud',pmud,'pgravel',pgravel,...
    'computewaverelated',true,...
    'compute_stokes_return_flow',false,...
    'nrofsigmalevels',nrofsigmalevels,...    
    'RW',myRW.*ones(size(Hm0_01)),...
    'RC',myRC.*ones(size(Hm0_01)),...
    'aR',myaR.*ones(size(Hm0_01)));

data02 = TR2004v01('Times',Times,...
    'Hs',Hm0_02,'Tp',Tp,'Hdir',Hdir,...
    'U1',U1t_02,...
    'V1',V1t_02,'zvel',zvelt_02,...
    'zbedt',zbedt,'d',d,...
    'salt',salt,'D10',D10,'D50',D50,'D90',D90,...
    'psand',psand,'pmud',pmud,'pgravel',pgravel,...
    'computewaverelated',true,...
    'compute_stokes_return_flow',false,...
    'nrofsigmalevels',nrofsigmalevels,...    
    'RW',myRW.*ones(size(Hm0_02)),...
    'RC',myRC.*ones(size(Hm0_02)),...
    'aR',myaR.*ones(size(Hm0_02)));

data03 = TR2004v01('Times',Times,...
    'Hs',Hm0_03,'Tp',Tp,'Hdir',Hdir,...
    'U1',U1t_03,...
    'V1',V1t_03,'zvel',zvelt_03,...
    'zbedt',zbedt,'d',d,...
    'salt',salt,'D10',D10,'D50',D50,'D90',D90,...
    'psand',psand,'pmud',pmud,'pgravel',pgravel,...
    'computewaverelated',true,...
    'compute_stokes_return_flow',false,...
    'nrofsigmalevels',nrofsigmalevels,...    
    'RW',myRW.*ones(size(Hm0_03)),...
    'RC',myRC.*ones(size(Hm0_03)),...
    'aR',myaR.*ones(size(Hm0_03)));   

% figure;
% subplot(2,1,1)
% plot(data01.Vz(50,:),data01.z(50,:))
% subplot(2,1,2)
% plot(data01.csand(50,:),data01.z(1,:))

%%
% figure;
% subplot(3,1,1)
% plot(Vmean(2:end),data00.RMob(2:end))
% hold on;
% plot(Vmean(2:end),data01.RMob(2:end))
% plot(Vmean(2:end),data03.RMob(2:end))
% xlabel('V (m/s)')
% ylabel('RMob')
% subplot(3,1,2)
% plot(Vmean(2:end),data00.RWr(2:end))
% hold on;
% plot(Vmean(2:end),data01.RWr(2:end))
% plot(Vmean(2:end),data03.RWr(2:end))
% xlabel('V (m/s)')
% ylabel('Rwr')
% subplot(3,1,3)
% plot(Vmean(2:end),data00.RWr(2:end))
% hold on;
% plot(Vmean(2:end),data01.RWr(2:end))
% plot(Vmean(2:end),data03.RWr(2:end))
% xlabel('V (m/s)')
% ylabel('Rwr')
% 
%%

%% TR2004
NS = 1;
RTYPE = 3;
FCR = 1;

%% plot velocity profiles TR2004
it = 18;
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
hold on;
semilogy(data03.Vz(it,:),data03.z(it,:),'o-')
grid on;
title(['Velocity profiles Vr: ',num2str(Vr(it),'%2.2f'),'m/s'])

%% plot concentration profiles TR2004 for one time step it
% it = 2;
% it = 18;
it = 50;
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
loglog(data03.csand(it,:),data03.z(it,:),'b--');
hold on;
grid on;
legend(addtofname)
title(['Concentration profiles Vr: ',num2str(Vr(it),'%2.2f'),'m/s'])

%% compare the two velocity profiles for one time step it
it = 18;
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
hold on;
plot(data03.Vz(it,:),data03.z(it,:),'.-')
plot(velprof_03(it).UCa,velprof_03(it).z,'x--')
grid on;
title(['Velocity profile ',num2str(Vr(it),'%2.2f'),'m/s'])

%% plot the apparent roughness for different wave heights
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.RA(2:end),'b--','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.RA(2:end),'b--','linewidth',1)
hold on;
plot(Vr(2:end),data03.RA(2:end),'b--','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Apparent roughness [m]')
title(['Comparison of computed roughness ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_apparent_roughness',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.RW(2:end),'b--','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.RW(2:end),'b--','linewidth',1)
hold on;
plot(Vr(2:end),data03.RW(2:end),'b--','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Wave-related roughness [m]')
title(['Comparison of computed wave-related roughness ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_wave-related_roughness',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.RC(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.RC(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.RC(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Current-related roughness [m]')
title(['Comparison of computed current-related roughness ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_current-related_roughness',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


% figure;
% figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
% set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
% plot(Vr(2:end),data00.tauc(2:end),'b--','linewidth',0.7)
% hold on;
% plot(Vr(2:end),data01.tauc(2:end),'b--','linewidth',1)
% hold on;
% plot(Vr(2:end),data03.tauc(2:end),'b--','linewidth',1.3)
% hold on;
% grid on
% set(gca,'fontsize',7);
% legend(addtofname);
% xlabel('Depth-averaged flow velocity [m/s]')
% ylabel('Current-related shear stress [N/m^2]')
% title(['Comparison of computed current-related shear stress ', num2str(d(1)) ' m water depth'])
% text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
% annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% % print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TAUC',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi

%%
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.tauw(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.tauw(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.tauw(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Wave-related shear stress [N/m^2]')
title(['Comparison of computed wave-related shear stress ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TAUW',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi



%%
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.TAUCWE(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.TAUCWE(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.TAUCWE(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Effective bed shear stress C+W [N/m^2]')
title(['Comparison of computed effective bed shear stress C+W ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TAUCWE',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi



%%
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.EBW(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.EBW(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.EBW(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Near-bed mixing EBW [m^2/s]')
title(['Comparison of near-bed mixing ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_EBW',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%% plot mixinf at mid depth
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.EMAXW(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.EMAXW(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.EMAXW(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Mixing at mid depth EMAX [m^2/s]')
title(['Comparison of mixing at mid depth ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_EMAXW',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi

%% plot mixing coefficient betaw
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.betaw(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.betaw(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.betaw(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Mixing coefficient BETAW [m^2/s]')
title(['Comparison of mixing coefficient BETAW ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_BETAW',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%% plot wave-related friction coefficient fw
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.fw(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.fw(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.fw(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Wave-related friction coefficient FW [-]')
title(['Comparison of wave-related friction coefficient FW ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_FW',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%% plot representative orbital velocity UBWr
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.UBWr(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.UBWr(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.UBWr(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('UBWr [m/s]')
title(['Comparison of representative orbital velocity UBWr ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_UBWr',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%% plot critical bed shear stress
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.taucr(2:end),'b--','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.taucr(2:end),'b--','linewidth',1)
hold on;
plot(Vr(2:end),data03.taucr(2:end),'b--','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('TAUCR [N/m^2]')
title(['Comparison of critical bed shear stress TAUCR ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TAUCR',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%% plot effective bed shear stress TAUCEF
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.TAUCEF(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.TAUCEF(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.TAUCEF(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('TAUCEF [N/m^2]')
title(['Comparison of effective bed shear stress TAUCEF ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TAUCEF',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%% plot effective bed shear stress TAUWEF
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.TAUWEF(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.TAUWEF(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.TAUWEF(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('TAUWEF [N/m^2]')
title(['Comparison of effective bed shear stress TAUWEF ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TAUWEF',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi



%% plot reference concentration csandref
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.csandref(2:end),'b-','linewidth',0.7)
hold on;
% plot(Vr(2:end),data00.CA(2:end).*rhos,'k:','linewidth',2)
plot(Vr(2:end),data01.csandref(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.csandref(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Reference concentration [kg/m^3]')
title(['Comparison of reference concentration ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_CA',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi

%% plot fall velocity suspended material
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Vr(2:end),data00.wssand(2:end),'b-','linewidth',0.7)
hold on;
plot(Vr(2:end),data01.wssand(2:end),'g--','linewidth',1)
hold on;
plot(Vr(2:end),data03.wssand(2:end),'r-.','linewidth',1.3)
hold on;
grid on
set(gca,'fontsize',7);
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Fall velocity WS [m/s]')
title(['Comparison of fall velocity ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_WS',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%%
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
semilogy(Vr(2:end),data00.qtotsandy(2:end)./2650,'b-','linewidth',0.7)
hold on;
% semilogy(Vmean(2:end),data00.SVR.qtotsandy(2:end)./2650,'g-','linewidth',0.7);
% semilogy(Vr(2:end),data00.VR.qtotsandy(2:end)./2650,'g-','linewidth',0.7);

semilogy(Vr(2:end),data01.qtotsandy(2:end)./2650,'g--','linewidth',1);
% semilogy(Vmean(2:end),data01.SVR.qtotsandy(2:end)./2650,'g-','linewidth',1);
% semilogy(Vr(2:end),data01.VR.qtotsandy(2:end)./2650,'g-','linewidth',1);

semilogy(Vr(2:end),data03.qtotsandy(2:end)./2650,'r-.','linewidth',1.3);
% semilogy(Vmean(2:end),data03.SVR.qtotsandy(2:end)./2650,'g-','linewidth',1.3);
% semilogy(Vr(2:end),data03.VR.qtotsandy(2:end)./2650,'g-','linewidth',1.3);
grid on;
set(gca,'fontsize',7)
ylim([10^-7 10^-1])
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Total load transport in current direction [m^2/s/m, excl pores]')
title(['Comparison of computed total load transport for ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_TotalTransport_d',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%%
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
semilogy(Vr(2:end),data00.qssandy_dint(2:end)./2650,'b-','linewidth',0.7)
hold on;
semilogy(Vr(2:end),data01.qssandy_dint(2:end)./2650,'g--','linewidth',1);
semilogy(Vr(2:end),data03.qssandy_dint(2:end)./2650,'r-.','linewidth',1.3);
grid on;
set(gca,'fontsize',7)
ylim([10^-7 10^-1])
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Suspended load transport in current direction [m^2/s/m, excl pores]')
title(['Comparison of computed suspended load transport for ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
% print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_SUStransports_d',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%%
figure;
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
semilogy(Vr(2:end),data00.qbsandy(2:end)./2650,'b-','linewidth',0.7)
hold on;
semilogy(Vr(2:end),data01.qbsandy(2:end)./2650,'g--','linewidth',1);
semilogy(Vr(2:end),data03.qbsandy(2:end)./2650,'r-.','linewidth',1.3);
grid on;
set(gca,'fontsize',7)
ylim([10^-7 10^-1])
legend('Hm0 = 0 m','Hm0 = 1 m','Hm0 = 3 m');
xlabel('Depth-averaged flow velocity [m/s]')
ylabel('Bed load transport in current direction [m^2/s/m, excl pores]')
title(['Comparison of computed bed load transport for ', num2str(d(1)) ' m water depth'])
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
print('-dpng','-r600',[figpath,filesep,'TEST_',addtofname,'_BEDtransports_d',num2str(d(1),'%02.0f'),'m'])  % print figure at 300 dpi


%%

disp(['Vmean: ',num2str(data01.SVR.Vmean(2))])
disp(['Cf: ',num2str(data01.SVR.Cf(2))])
disp(['Ucr: ',num2str(data01.SVR.Ucr(2))])
disp(['Asb: ',num2str(data01.SVR.Asb(2))])
disp(['Dstar: ',num2str(data01.Dstar(2))])
disp(['Ass: ',num2str(data01.SVR.Ass(2))])
disp(['As: ',num2str(data01.SVR.As(2))])
disp(['qtotsand_SVR: ',num2str(data01.SVR.qtotsand(2))])
disp(['qtotsandx_SVR: ',num2str(data01.SVR.qtotsandx(2))])
% disp(['qbsandx: ',num2str(data.SVR.qbsandx(2))])
% disp(['qssandx: ',num2str(data.SVR.qssandx(2))])
disp(['qtotsandy_SVR: ',num2str(data01.SVR.qtotsandy(2))])
% disp(['qbsandy: ',num2str(data.SVR.qbsandy(2))])
% disp(['qssandy: ',num2str(data.SVR.qssandy(2))])
disp(['qtotsandy: ',num2str(data01.qtotsandy(2))])

