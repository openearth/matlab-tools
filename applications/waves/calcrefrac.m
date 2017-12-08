function [Kr,alfa]=calcrefrac(d,T,alfa0)
% calcrefrac refraction coefficient and angle of incidence
%
% [Kr,alfa]=calcrefrac(d,T,alfa0)
%
% Calculates refraction coefficient and angle of incidence
% (between wave crests and bottom contours)
% for parallel, straight bottom contours
%
% d     = water depth (shallow water)
% T     = wave period (seconds)
% alfa0 = angle of incidence in degrees (deep water)
%
% Kr    = refraction coefficient
% alfa  = wave angle at shallow water site
%
%see also: waves, swan

% Based on script by James Hu

[L,e,c] = wavelength(T,d,0,0,0,1e-6);
alfa0=alfa0*pi/180;
k=2*pi/L;
if alfa0>=0 && alfa0<=pi/2
    alfa=asin(tanh(k*d)*sin(alfa0));
    Kr=sqrt(cos(alfa0)/cos(alfa));
elseif alfa0>pi/2 && alfa0<pi
    alfa0=pi-alfa0;
    alfa=asin(tanh(k*d)*sin(alfa0));
    Kr=sqrt(cos(alfa0)/cos(alfa));
    alfa=pi-alfa;
else
    Kr=0;
    alfa=0;
end
alfa=alfa*180/pi;
