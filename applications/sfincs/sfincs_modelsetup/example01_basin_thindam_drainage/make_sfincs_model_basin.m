% Create simple SFINCS model with thin dams + pumps
fclose('all');
clear all
close all
clc

%% 0. Settings
destin = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example00_basin_thindam_drainage\mymodel\';
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

% observation point in middle of domain
inp.obsfile         = 'sfincs.obs';
points_obs.x        = [xvalues(25,25), xvalues(25,75), xvalues(75, 75), xvalues(75, 25)];
points_obs.y        = [yvalues(25,25), yvalues(25,75), yvalues(75, 75), yvalues(75, 25)];
points_obs.length   = length(points_obs.x);
sfincs_write_boundary_points(inp.obsfile,points_obs);

% Write thin dam
clear thindam
inp.thdfile         = 'sfincs.thn';
thindam(1).name{1}  = 'dam1';
thindam(1).x        = [xvalues(50,1)-100 xvalues(50,end)+100];
thindam(1).y        = [yvalues(50,1) yvalues(50,1)];
thindam(1).length   = 2;
thindam(2).name{1}  = 'dam2';
thindam(2).x        = [xvalues(1,50) xvalues(1,50)];
thindam(2).y        = [yvalues(1,1)-100 yvalues(end,50)+100];
thindam(2).length   = 2;
sfincs_write_thin_dams(inp.thdfile,thindam)

figure; hold on;
pcolor(xvalues,yvalues,zvalues);
plot(thindam(1).x, thindam(1).y, '-k')
plot(thindam(2).x, thindam(2).y, '-k')

% Write two pumps
inp.drnfile         = 'sfincs.drn';
for jj = 1:2
    if jj == 1
        drain(jj).xsnk = xvalues(25,25);    % sink x-coordinate(s), from where water is taken
        drain(jj).ysnk = yvalues(25,25);    % sink y-coordinate(s)
        drain(jj).xsrc = xvalues(25,75);    % source x-coordinate(s), to where water is discharged
        drain(jj).ysrc = yvalues(25,75);    % source x-coordinate(s)
    else
        drain(jj).xsnk = xvalues(75,75);    % sink x-coordinate(s), from where water is taken
        drain(jj).ysnk = yvalues(75,75);    % sink y-coordinate(s)
        drain(jj).xsrc = xvalues(75,25);    % source x-coordinate(s), to where water is discharged
        drain(jj).ysrc = yvalues(75,25);    % source x-coordinate(s)
    end
    drain(jj).type = 1;     % 1= pump, 2=culvert
    drain(jj).par1 = 96.45; % possible drainage discharge in m3/s
    drain(jj).par2 = 0;     % not used yet
    drain(jj).par3 = 0;     % not used yet
    drain(jj).par4 = 0;     % not used yet
    drain(jj).par5 = 0;     % not used yet
end
sfincs_write_drainage_file(inp.drnfile,drain)

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
inp.zsini           = 2;
inp.outputformat   = 'net';
inp.qinf_zmin      = -999;
sfincs_write_input('sfincs.inp',inp);
fclose('all')

%%
% Empty the basin dry
total_volume_subset = 5000*5000*2;
time_seconds        = total_volume_subset / ((tend-tstart)*86400);
