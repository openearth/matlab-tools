clear variables
close all
% SeanPaul La Selle, USGS
% 13 July, 2015
% This script loads data from a UCSB format subfault file using
% "read_subfault.m" then calculates the resulting vertical displacement
% using "okada.m"
%
% Plots of slip on subfaults are created using "plot_subfaults.m"

%% LOAD SUBFAULT DATA
% read in ucsb subfault file for Tohoku
file = 'ucsb_subfault_2011_03_11_v3.cfg'; % Tohoku, Japan 2011
path = '';
title = 'Tohoku, Japan 11-03-2011';
subfaults = read_subfault('path',fullfile(path,file));

%% PLOT SUBFAULT SLIP
figure(1)
% plotting
plot_subfaults(subfaults,'plot_slip',1, ...
    'background_color','w',...
    'figure_title',title,...
    'cbar',1,...
    'c_range',[0 60 10],...
    'Mw',1);
drawnow;

%% CALCULATE DTOPO

% First define the lat/lon of the grid.  If a delft grid is rectilinear,
% could read this info in.
xlower = 135;
xupper = 150;
ylower = 30;
yupper = 45;

% discretize grid
gridsize = 60; % in arcseconds
mx = int16((xupper-xlower)*(3600/gridsize) + 1); 
my = int16((yupper-ylower)*(3600/gridsize) + 1);
x = linspace(xlower,xupper,mx);
y = linspace(ylower,yupper,my);

% calculate the combined deformation from all the subfaults using Okada
[X,Y,DZ,times] = okada(subfaults, x, y);
% note: once we begin calculating dynamic rupture, DZ should be a [M,N,K]
% array, where times(K) gives the time of the rupture in seconds.

%% PLOT DTOPO
figure(2)
pcolor(x,y,DZ)
shading flat
colormap(brewermap([],'*RdBu'));
caxis([-5 5]);
cb = colorbar;
ylabel(cb,'deformation [m]','fontsize',14);
set(gca,'fontsize',14);
xlabel('Longitude')
ylabel('Latitude')

