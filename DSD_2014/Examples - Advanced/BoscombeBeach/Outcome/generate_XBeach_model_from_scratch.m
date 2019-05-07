% This script generates an XBeach storm impact model step-by-step for
% Boscombe Beach (U.K.) by using the Matlab toolbox for XBeach.
%
% -------------------------------------------------------------------------
% Version           Name                Date
% -------------------------------------------------------------------------
% v1.0              rooijen/thiel       03-Sep-2012
% v1.1              rooijen             27-Nov-2012
%
clear all;close all;clc

%% Load Toolbox into Matlab
addpath('D:\XBeach\Toolbox\')
oetsettings

%% Grid & Bathymetry

% Define the model directory
mod_dir = 'd:\XBeach\Examples\BoscombeBeach\Boscombe_SI\';

% Load the measured bathymetry into Matlab
bathy   = load([mod_dir 'bathy.dep']);

% Plot the measured bathymetry
figure; pcolor(bathy); shading interp; colorbar; title('measured bathymetry')
figure; surf(bathy); colorbar;title('measured bathymetry')

% Now construct grid
% 1) grid characteristics
nx = 124;   % number of grid cells in cross-shore direction
ny = 72;    % number of grid cells in alongshore direction
dx = 5;     % cross-shore grid size
dy = 20;    % alongshore grid size

% 2) generate grid vectors
x = [0:1:nx-1]*dx;
y = [0:1:ny-1]*dy;

% 3) translate grid vectors to grid
[xgr,ygr] = meshgrid(x,y);

% Plot the measured bathymetry again but with grid information
figure;surf(xgr,ygr,bathy);colorbar;title('measured bathymetry');
xlabel('x [m]');ylabel('y [m]');zlabel('z [m]')
figure;pcolor(xgr,ygr,bathy);colorbar;title('measured bathymetry');
xlabel('x [m]');ylabel('y [m]');shading interp

% Now make a cross-shore varying grid using the Courant condition
[xgr zgr] = xb_grid_xgrid(x,bathy(36,:),{'CFL',0.7,'Tm',8,'dxmin',5});

% Check if the profile is still o.k.
figure;
plot(x,bathy(36,:),'b*');hold on;
plot(xgr,zgr,'r-o');hold on; title('cross-shore grid')  

% Now make longshore varying grid
ygr = xb_grid_ygrid(y,'dymin',10,'dymax',20,'area_size',0.4);

% Interpolate bathymetry to new grid, and translate the new grid vectors to 
% a grid:
bathy_2 = interp2(x,y',bathy,xgr,ygr');
[xgr,ygr] = meshgrid(xgr,ygr);

% Plot new (grid size varying) grid with bathymetry
figure; surf(xgr,ygr,bathy_2); colorbar;title('measured bathymetry');
xlabel('x [m]');ylabel('y [m]');zlabel('z [m]')

% Now finalise your grid using 1) lateral extend and 2) seaward extend or
% seaward flatten.
[x y z] = xb_grid_finalise2(xgr(:,4:end), ygr(:,4:end), bathy_2(:,4:end), 'actions', {'lateral_extend','seaward_extend'},'n',5,'zmin',-15,'slope',1/50);

% Plot bathymetry including model domain extension
figure; surf(x,y,z); colorbar;

%% Final step model setup: adding model parameters and writing model input

% Make a structure for the bathymetry data
bathymetry = xb_grid_add('x', x, 'y', y, 'z', z);

% Define the parameter settings (and define a structure with the info)
pars = xb_generate_settings('xori',412500,'yori',90700,'alfa',0,...                         % grid stuff
                               'thetamin',-90,'thetamax',90,'dtheta',20,...
                               'instat','jons_table','bcfile','waves.txt',...               % wave bc
                               'tideloc',1,'zs0file','tide.txt',...                         % tide bc
                               'morfac',5,...                                               % morphology settings
                               'outputformat','netcdf','nglobal',{'H','u','v','zs','zb'},'tintg',100,... % output settings
                               'tstart',0,'tstop',3700,'morstart',100);                     % time management

% Merge the two (bathy/grid + parameters) structures
xbm_si = xs_join(bathymetry,pars);

% Write the XBeach input file, and save it in the model directory
xb_write_input([mod_dir,'params.txt'],xbm_si);

%% Check output (with Matlab Toolbox)

xbo = xb_read_output(mod_dir);
xb_view(xbo);