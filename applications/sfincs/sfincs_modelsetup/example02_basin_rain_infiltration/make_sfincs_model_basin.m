% Create simple SFINCS model with spatial-varying infiltration
fclose('all');
clear all
close all
clc

%% 0. Settings
destin = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example00_basin\mymodel\';
mkdir(destin); cd(destin);

%% 1. Bathymetry
xvalues                 = [0:100:10000];
yvalues                 = [0:100:10000];
[xvalues, yvalues]      = meshgrid(xvalues,yvalues);
zvalues                 = zeros(size(xvalues));
figure; pcolor(zvalues); shading flat;

%% 2. SFINCS
% Inp
inp             = sfincs_initialize_input;
inp.nmax        = size(xvalues,1);
inp.mmax        = size(yvalues,2);
inp.dx          = nanmedian(diff(xvalues(1,:)));
inp.dy          = nanmedian(diff(yvalues(:,1)));
inp.x0          = min(min(xvalues));
inp.y0          = min(min(yvalues));
inp.mskfile     = 'sfincs.msk';
inp.depfile     = 'sfincs.dep';
inp.indexfile   = 'sfincs.ind';

% Active versus inactive
msk             = ones(size(zvalues));
figure; pcolor(msk); shading flat;

% Write binary inputs for bed, mask and index
sfincs_write_binary_inputs(zvalues,msk,inp.indexfile,inp.depfile,inp.mskfile)

% Infiltration in the middle of the domain
qfield                      = zeros(size(zvalues));
qfield(25:75, 25:75)        = 10;  % mm/hr
qfieldv                     = qfield(msk>0);
inp.qinffile                = 'sfincs.qinf';
fid=fopen(inp.qinffile,'w');
fwrite(fid,qfieldv,'real*4');
fclose(fid);

% Also simple rainfall
t               = [0  86400 86401 86400*7] ;
rain            = [10 10    0     0];
inp.precipfile  = 'sfincs.rain';
sfincs_write_boundary_conditions(inp.precipfile,t,rain')

% observation point in middle of domain
inp.obsfile         = 'sfincs.obs';
points_obs.x        = mean(xvalues(:));
points_obs.y        = mean(yvalues(:));
points_obs.length   = length(points_obs.x);
sfincs_write_boundary_points(inp.obsfile,points_obs);

% Times
tstart              = datenum(2019,1,1);
tend                = datenum(2019,1,7);
inp.tref            = tstart;
inp.tstart          = tstart;
inp.tstop           = tend;

% Reduce output
inp.dtout           = 3600;
inp.alpha           = 0.25;
inp.theta           = 0.90;
inp.dtwnd           = 1800;
inp.min_lev_hmax    = -5;

% Additional parameters
inp.dtout           = 86400;
inp.dthisout        = 600;
inp.zsini           = 1;
inp.outputformat   = 'net';
inp.qinf_zmin      = -999;
sfincs_write_input('sfincs.inp',inp);

% Basin is 10x10 km so this means 
% 10 mm per hour for 1 day is 0.24m water level increase
% however there is 1/4 of domain a 10 mm-hr infiltration capacity
% so 0.24 * 0.75 is 0.18 m increase in water level for the first day
% after that 0.06 m per day decrease for 5 days is 0.32m 
% leading to 1+0.18-0.32 = 0.82m water level at the end
