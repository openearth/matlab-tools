clear all;
close all;
clc;

time = 0:60:12.5*3600;
h = 5+sin(time()./(12.5*2*pi));
ux = 0.1+0.1*sin(time()./(12.5*2*pi));
uy = zeros(size(ux));
H13 = 0.0001+zeros(size(ux));
Tp = 0.0001+zeros(size(ux));

[cmud, csand, z, qxmud1depthint, qymud1depthint, qxsand1depthint,...
   qysand1depthint] = sandandmudtransport(time,h,ux,uy,H13,Tp);
