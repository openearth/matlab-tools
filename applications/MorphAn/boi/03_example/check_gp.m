clear all
close all

addpath('../02_analyse')

%% 

iTest = 6;

if iTest==1
    % simple dune:  1:1 line. Boundary profile should fit
    x = -10:1:50;
    zp = [-10 -10 10 10];
    xp = [-10 -5 5 50];
    z  = interp1(xp,zp,x);

    znat    = 2;
    xnat    = 0;
    Rp      = 2.5;
elseif iTest==2
    % simple dune: 1:1 line. Boundary profile does not fit
    % Coarse resolution of profile
    x = -10:1:10;
    zp = [-10 -10 10 10];
    xp = [-10 -5 5 10];
    z  = interp1(xp,zp,x); 


    znat    = 8;
    xnat    = 0;
    Rp      = 4.5;    
    
elseif iTest==3
    % simple dune: 1:1 line. Boundary profile does not fit
    % High resolution of profile
    x = -10:0.1:10;
    zp = [-10 -10 10 10];
    xp = [-10 -5 5 10];
    z  = interp1(xp,zp,x); 


    znat    = 8;
    xnat    = 0;
    Rp      = 4.5;    
elseif iTest==4
    % dune: crossing left and right. Boundary profile should not fit
    x = -10:0.1:20;
    zp = [-10 -10 10 10 -10];
    xp = [-10 -5  5  15 20];
    z  = interp1(xp,zp,x); 


    znat    = 7;
    xnat    = 0;
    Rp      = 6;    
    
elseif iTest==5
    % two dunes: boundary profile fit in second dune
    x = -10:0.1:20;
    zp = [-10 -10 10 5 5 10 10];
    xp = [-10 -2  2  4 6 10 20];
    z  = interp1(xp,zp,x);


    znat    = 7;
    xnat    = -5;
    Rp      = 6;  
elseif iTest==6
    % two dunes: no second lower crossing. boudnary profile should be fit
    % in second dune
    x = -10:0.1:20;
    zp = [-10.1 -10 10.02 5.1 5.1 10.01 10.02];
    xp = [-10 -2  2  4 6 10 20];
    z  = interp1(xp,zp,x);


    znat    = 5;
    xnat    = -5;
    Rp      = 4;  

elseif iTest==7
    % two dunes. same as iTest 6, but on different scale. Second method is slower
    x = -1000:0.1:200;
    zp = [-10.1 -10 10.02 5.1 5.1 10.01 10.02];
    xp = [-1000 -200  20  40 60 100 200];
    z  = interp1(xp,zp,x);


    znat    = 5;
    xnat    = -5;
    Rp      = 4;  
end


%% fast method (more complex)
tic
V = 50
X0      = loc_boundary_profile_v2(znat,xnat,x,z,Rp,V,true);
toc
height  = znat + 1.5 - Rp;

figure
plot(x,z)
hold on
plot([X0 X0+height*1 X0+height+3 X0+height+3+height*2],[Rp, znat+1.5 znat+1.5 Rp],'b-','linewidth',2)

%% slow method

X0      = loc_boundary_profile_slow(znat,xnat,x,z,Rp,true);
height  = znat + 1.5 - Rp;

figure
plot(x,z)
hold on
tic
plot([X0 X0+height*1 X0+height+3 X0+height+3+height*2],[Rp, znat+1.5 znat+1.5 Rp],'b-','linewidth',2)
toc

%% old method

X0      = loc_boundary_profile(znat,xnat,x,z,Rp);
height  = znat + 1.5 - Rp;

figure
plot(x,z)
hold on
tic
plot([X0 X0+height*1 X0+height+3 X0+height+3+height*2],[Rp, znat+1.5 znat+1.5 Rp],'b-','linewidth',2)
toc