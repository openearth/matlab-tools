%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Copyright (C) 2007 Delft University                                     %
% Ad Reniers                                                              %
%                                                                         %
% a.j.h.m.reniers@tudelft.nl                                              %
% Department of Civil Engineering and Geosciences                         %
% Delft University of Technology                                          %
% 2600 GA Delft                                                           %
% The Netherlands                                                         %
%                                                                         %
% This library is free software; you can redistribute it and/or           %
% modify it under the terms of the GNU Lesser General Public              %
% License as published by the Free Software Foundation; either            %
% version 2.1 of the License, or (at your option) any later version.      %
%                                                                         %
% This library is distributed in the hope that it will be useful,         %
% but WITHOUT ANY WARRANTY; without even the implied warranty of          %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU        %
% Lesser General Public License for more details.                         %
%                                                                         %
% You should have received a copy of the GNU Lesser General Public        %
% License along with this library; if not, write to the Free Software     %
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307     %
% USA                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Model calculates the infragravity and (very) low frequency motions forced by 
% a bi-chromatic wave (obliquely) incident on an alongshore 
% uniform beach. Details of the alogorithm can be found in Roelvink and 
% Reniers, Coastal Morphodynamic Modeling Guide, 2011, World Scientific and
% Reniers, Van Dongeren, Battjes and Thornton, Linear modeling of 
% Infragravity waves during DELILAH, JGR, 107(C10), 2002

clear all
%

h = [15.000001 .000001];
x = [0 1000];
dx = 0.25;
xr = [x(1):dx:x(end)];
zr = interp1(x,h,xr)';

% define model parameters
% constants
rho = 1023;
g = 9.81;

%wave breaking variables for incident short waves

alfa = 2.0;
ndis = 10
gamb = 0.45

f = [0.11 0.09];                       % frequencies of the two short waves
w = 2*pi*f;  
wp = mean(w);

theta = [24.5 15]*pi/180;              % angle of the two carrier waves
k1 = disper(w(1),zr(1));               % wave numebr of first carrier wave
k2 = disper(w(2),zr(1));               % wave number of second carrier wave
theta_in = atan((k1.*sin(theta(1))+ k2.*sin(theta(2)))/(k1.*cos(theta(1))+k2.*cos(theta(2)))); % mean incidence angle of short waves
a = [0.5 0.1];  % short wave amplitudes
E0 = 0.5*rho*g*sum(a.^2); % mean energy
E1 = rho*g*a(1)*a(2);     % energy modulation

     % compute low-freq response
     
     [k_yb,f_yb,eta_b,y,yu,yv,R,Fx,Fy,Px,Py,Em,Evx]  = ...
     forcedir_bic2(xr,zr,E0,wp,theta_in,E1,f(1),f(2), ...
               theta(1),theta(2),gamb,alfa,ndis,dx);
           
     % proces output    
     
     ni = length(xr);
     xm = xr;
     xm(ni+1) = xr(ni) + dx;
     Emm = Em;
     Emm(ni+1) = 0;
     figure(3)
     subplot(411)
     plot(xr,sqrt(8*(Em+real(Evx))/rho/g),'k','linewidth',2)
     hold
     plot(xr,sqrt(8*(Em+abs(Evx))/rho/g),'k:','linewidth',2)
     plot(xr,sqrt(8*(Em-abs(Evx))/rho/g),'k:','linewidth',2)
     hold     
     axis([0 1000 0 2])
     set(gca,'Xticklabel',[])
     set(gca,'fontsize',14)
     ylabel('H_{rms} (m)','fontsize',14)
     subplot(412)
     plot(xr,real(y),'k','linewidth',2)
     hold
     plot(xr,abs(y),'k:','linewidth',2)
     plot(xr,-abs(y),'k:','linewidth',2)
     hold
     axis([0 1000 -0.5 0.5])
     set(gca,'Xticklabel',[])
     set(gca,'fontsize',14)
     ylabel('\eta (m)','fontsize',14)

     subplot(413)
     plot(xr,real(yu),'k','linewidth',2)
     hold
     plot(xr,abs(yu),'k:','linewidth',2)
     plot(xr,-abs(yu),'k:','linewidth',2)
     hold
     axis([0 1000 -1.5 1.5])
     set(gca,'Xticklabel',[])
     set(gca,'fontsize',14)
     ylabel('u (m/s)','fontsize',14)
     subplot(414)

     plot(xr,real(yv),'k','linewidth',2)
     hold
     plot(xr,abs(yv),'k:','linewidth',2)
     plot(xr,-abs(yv),'k:','linewidth',2)
     hold
     
     axis([0 1000 -.5 .5])
     set(gca,'fontsize',14)
     ylabel('v (m/s)','fontsize',14)
     xlabel('X (m)','fontsize',14)
     

     
% construct spatial velocity field
    t = [1:1:5/f_yb];
    ycor = [0:10:6/abs(k_yb/2/pi)]+5;
    nt = length(t)
    for jt = 1:1 % change to nt if you want to see the time evolution
    Z = real(conj(y')*exp(-sqrt(-1)*k_yb*ycor+sqrt(-1)*2*pi*f_yb*t(jt)))';
    U = real(yu*exp(-sqrt(-1)*k_yb*ycor+sqrt(-1)*2*pi*f_yb*t(jt)))';
    V = real(yv*exp(-sqrt(-1)*k_yb*ycor+sqrt(-1)*2*pi*f_yb*t(jt)))';
    E = (Em*ones(size(ycor)))'+real(Evx*exp(-sqrt(-1)*k_yb*ycor+sqrt(-1)*2*pi*f_yb*t(jt)))';
    xcor = xr;
    
    
    figure(4)
    pcolor(xcor,ycor,Z)
    caxis([-0.25 0.25])
    shading flat
    axis equal
    axis([0 1000 0 2400])
    xlabel('X (m)','fontsize',14)
    ylabel('Y (m)','fontsize',14)
    set(gca,'fontsize',14)
    h = colorbar('north');
    set(h,'fontsize',14)
    set(h,'Ylim',[-.25 0.25])
    pause(.1)
    
    % add caustic
    hturn = (w(2)-w(1))^2/g/k_yb^2
    xturn = interp1(zr,xr,hturn)
    hold
    plot([xturn xturn],[0 2400],'k:','linewidth',2)
    hold 
    
    figure(5)
    pcolor(xcor,ycor,sqrt(8*E/rho/g))
    caxis([0 1.5])
    shading flat
    axis equal
    axis([0 1000 0 2400])
    xlabel('X (m)','fontsize',14)
    ylabel('Y (m)','fontsize',14)
    set(gca,'fontsize',14)
    h = colorbar('north');
    set(h,'fontsize',14)
    set(h,'Ylim',[0 1.5])
    pause(.1)
    
    end % end of time series for plotting purpose
    

