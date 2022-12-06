clear all
close all

% two dunes: no second lower crossing. boudnary profile should be fit
% in second dune
x = -10:0.1:20;
zp = [-10.1 -10 10.02 5.1 5.1 10.01 10.02];
xp = [-10 -2  2  4 6 10 20];
z  = interp1(xp,zp,x);


znat    = 5;
xnat    = -5;
Rp      = 4;  
V_input = 50;
figure
plot(x,z)
hold on


x_basepoint = get_basepoint_(x,z,Rp,V_input);



