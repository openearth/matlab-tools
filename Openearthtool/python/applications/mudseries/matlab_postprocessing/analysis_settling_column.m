% Script to analyse settling column data. Use software to compute the
% height of the interface from the photos. Then use this script to
% determine the permeability constant Kk and fractal dimension D. 
clear all; close all; clc;

%% Input
% Height of the interface over time, from software

[num,txt,raw] = xlsread('p:\1205711-edspa\Data\Soilsampling\SettlingColumns\h_interface.xlsx','60gl');
t = num(:,4);
h = num(:,8)./1000;
h(h<0.05)=NaN;
t = t(~isnan(h));
h = h(~isnan(h));

% Constants, dependent on sample
samplename = 'sample119';  % used for saving figure
c         = 60; %concentration g/l
Conc_ini   = [num2str(c) 'gpl']; % used for saving figure
h_ini = 0.8;         % initial water level of the settling column in m
rho_s = 2650;         % density of solids in kg/m3
rho_w = 1015;         % density of water in kg/m3 (dependent on salinity)
w_ini = rho_w/(c);%1.002/0.06;   % initial water content = mass of water / mass of dry material
sandfrac = 0.447;     % fraction of sand present in sample

%% Factors computed from constants above
phi_0   = 1/(1+((rho_s*w_ini)/rho_w));
Delta   = (rho_s-rho_w)/rho_w;
phi_sa0 = phi_0*sandfrac;
phi_m0  = phi_0*(1-sandfrac);             
zeta_m  = h_ini*phi_m0/(1-phi_sa0); % Gibson or material height for fines or reduced Gibson height: same as zeta = h_ini*phi_0 when there is no sand in sample, but distinction between sand and fines included
zeta_s  = h_ini*phi_sa0; %Gibson or material height for sand

%% Plotting and tuning

% The fractal dimension D determines the slope of the blue line. Time t1 
% determines the starting point of the blue line and the end point of the
% red and green line. It is the time that the interface between clear water 
% and mud suspension meets the interface of the mud suspension and the bed.
% It is the time that the suspension has reached its gelling point. At
% t=t2, effective stress starts to become important and function
% h_phase_one is not valid anymore.

% Parameters to change:
t1 = 2000;      % time step where hindered settling phase goes over in phase I (bend in obs)
t2 = 10000;    % time step where phase I goes over in phase II

% Plot of interface, used for choosing t1
figure(1)
plot(t,h,'m.','markerfacecolor','m','displayname','Measurement')
hold on
set(gca,'xscale','log','yscale','log')
grid on
xlim([10 1000000])
ylim([0.001 1])
ylabel('height of the interface [m]')
xlabel('time [s]')
text(t2,0.95,'Phase II','horizontalalignment','left')
text(t1,0.95,'      Phase I','horizontalalignment','left')
text(t1/2,0.95,'Hindered Settling Phase','horizontalalignment','right')

%% Compute fit for phase I (determined by permeability)
% first pick t = t1 (transition from hindered settling phase to phase I)
if sum(t==t1)==0
    t_1 = t(t < t1); t_1 = t_1(end);
    t_2 = t(t > t1); t_2 = t_2(1);
    h1_1 = h(t == t_1);
    h1_2 = h(t == t_2);
    h1 = h1_1 - (h1_1-h1_2)/(t_2-t_1)*(t1-t_1);
else
    h1 = h(t==t1);
end
t_p1(:,1) = t1:t(end);

save('tmp.mat','zeta_m','h1','t1','Delta','phi_sa0','h_ini','phi_0')

xdata = t(t>t1 & t<t2);
ydata = h(t>t1 & t<t2);

% Method of Merkelbach (2000), eq. 4.51: without correction for sand (only
% valid if sand_frac = 0;
n0 = 15; % initial guess
[nM,resnorm] = lsqcurvefit(@h_phase_one_merkelbach,n0,xdata,ydata);
[h_p1M,KkM] = h_phase_one_merkelbach(nM,t_p1);
DM = 3-2/nM; % fractal dimension D
plot(t_p1,h_p1M,'b:','linewidth',1.5,'displayname',['Height of the interface [Merckelbach (2000), eq. 4.51], D = ' num2str(DM,'%1.4f') ', K_k = ' num2str(KkM,'%1.4e')])
hold on

% Method of Winterwerp & van Kesteren (2004), eq. 7.63: including
% correction for sand
[n,resnorm] = lsqcurvefit(@h_phase_one,n0,xdata,ydata);
[h_p1,Kk] = h_phase_one(n,t_p1);
D = 3-2/n; % fractal dimension D
plot(t_p1,h_p1,'b','linewidth',1.5,'displayname',['Height of the interface [Winterwerp & van Kesteren (2004), eq. 7.63], D = ' num2str(D,'%1.4f') ', K_k = ' num2str(Kk,'%1.4e')])
hold on

% Compute line for height of the bed
t_b(:,1) = [0:0.001:1].*t1;
h_b(:,1) = (h1/t1)*t_b;

plot(t_b,h_b,'r','linewidth',1.5,'displayname','Height of the bed')
hold on

%% Compute line for hindered settling phase
% set(gca,'xscale','lin','yscale','lin')
% xlim([0 2*t_b(end)])
if 1
    % Method of Thijs van Kessel to include effect of flocculation
    % The gelling factor and the initial settling velocity determine the 
    % shape/slope of the green line. 
    
    % Adjust gelling factor
    fact_gel = 1.1; % gelling factor
    ws0 = 0.00109598;   % initial settling velocity in m/s -> determined from slope of h,t between tstart and tstart+1
    m = 2; %in between 1 and 2
    
    phi_gel = fact_gel*h_ini*phi_0/h_b(end);
    c_gel = phi_gel*rho_s; % gelling concentration in kg/m3
    for tt = 1:length(t_b)
        if tt==1
            h_hs(tt,1)  = h_ini;
            phi_s(tt,1) = h_ini*phi_0/h_hs(tt,1);
            phi_m(tt,1) = rho_s*phi_s(tt,1)/c_gel;
            ws(tt,1)    = ws0*((1-phi_m(tt,1)).^m)*(1-phi_s(tt,1))/(1+2.5*phi_m(tt,1));
        else        
            h_hs(tt,1)  = h_hs(tt-1,1)-(t_b(tt,1)-t_b(tt-1,1))*ws(tt-1);
            phi_s(tt,1) = h_ini*phi_0/h_hs(tt,1);
            phi_m(tt,1) = rho_s*phi_s(tt,1)/c_gel;
            ws(tt,1)    = ws0*((1-phi_m(tt,1)).^m)*(1-phi_s(tt,1))/(1+2.5*phi_m(tt,1));
        end
    end
%     plot(t_b,h_hs,'g','linewidth',1.5,'displayname','Interface computed with gelling concentration [Dankers & Winterwerp (2007), eq. 16]')
    hold on
end

% Method Merkelbach, 2000
Kk_hs = (h_ini*phi_0/phi_0-h1)/(phi_0^(1-n)*Delta*t1); % solution eq. 4.49 for h_hs = h1 at t=t1, 'permeability constant' for hindered settling phase
h_hsM = h_ini*phi_0/phi_0-phi_0^(1-n)*Kk_hs*Delta*t_b; % eq. 4.49
% plot(t_b,h_hsM,'y','linewidth',1.5,'displayname','Height of the interface [Merckelbach (2000), eq. 4.49]')
hold on

%% Phase II
h_inf_meas = 0.058%h(end);

save('tmp2.mat','zeta_s','n','rho_s','rho_w','zeta_m','h_inf_meas')
[K_p,y1] = fminbnd(@h_phase_two,1e4,1e12);

h_p2 = zeta_s+(n/(n-1))*(K_p./(9.81*(rho_s-rho_w)))*((9.81*(rho_s-rho_w)*zeta_m)/K_p)^((n-1)/n);
plot([t2 t(end)],[h_p2 h_p2],'k','linewidth',1.5,'displayname',['Height of the bed [Winterwerp & van Kesteren (2004), eq. 7.66], K_p = ' num2str(K_p,'%1.4e')])

%%
ll1 = legend('Location','southwest');
set(ll1,'fontsize',8)

D         % fractal dimension D
Kk        % permeability constant for phase I
% text(t2/2,h1+0.2,[{['Fractal dimension D = ' num2str(D,'%1.4f')]};{['Permeability constant K_k = ' num2str(Kk,'%1.4e')]}],'fontsize',12,'horizontalalignment','right')
title([samplename ', ' Conc_ini ', h_{ini} = ' num2str(h_ini) 'm, w_{ini} = ' num2str(w_ini,'%1.2f') ', sandfrac = ' num2str(sandfrac)])
print(gcf,'-r300','-dpng',['sample_' samplename '_' Conc_ini])

save(['sample_' samplename '_' Conc_ini '.mat'])