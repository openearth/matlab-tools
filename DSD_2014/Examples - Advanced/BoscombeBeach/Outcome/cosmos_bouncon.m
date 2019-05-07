% This script uses data from an operational model (Cosmos) to provide
% boundary conditions for an XBeach storm impact model for Boscombe Beach
% (U.K.).
% 
% -------------------------------------------------------------------------
% Version           Name                Date
% -------------------------------------------------------------------------
% v1.0              rooijen/thiel       04-Sep-2012
% v1.1	            rooijen             27-Nov-2012
%
clear all;close all;clc

%% Read in StormImpact model and apply COSMOS b.c

mod_dir = ('d:\XBeach\Examples\BoscombeBeach\Boscombe_CM\');
xbm_si = xb_read_input([mod_dir,'params.txt']);

% get COSMOS data

internet = 1
if internet == 1
    
    % This part of the code you need internet connection. it downloads
    % output files from the COSMOS system, which will be used below to generate
    % tide and wave b.c. for operational BW model
    url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/cosmos/forecasts/csm/';

    % Netcdf files  
    nc_wl = 'boscombe.wl.2012.nc';
    nc_hs = 'boscombe.hs.2012.nc';
    nc_tp = 'boscombe.tp.2012.nc';
    nc_dir = 'boscombe.wavdir.2012.nc';

    % Read the time
    time = nc_varget([url nc_wl],'time');
    time = datenum(1900,1,1)+time/3600/24;

    % Read variables
    wl   = nc_varget([url nc_wl],'wl');
    hs   = nc_varget([url nc_hs],'hs');
    tp   = nc_varget([url nc_tp],'tp');
    dir  = nc_varget([url nc_dir],'wavdir');

    save boscombedata.mat wl hs tp dir time 
else
    load boscombedata.mat
end

% check what we've got
figure; 
subplot(2,2,1); plot(time,wl,'b'); title('\eta [m]'); datetick('x','dd-mmm');
subplot(2,2,2); plot(time,hs,'b'); title('H_s [m]'); datetick('x','dd-mmm');
subplot(2,2,3); plot(time,tp,'b'); title('T_p [s]'); datetick('x','dd-mmm');
subplot(2,2,4); plot(time,dir,'b'); title('Dir [degrees]'); datetick('x','dd-mmm');

% choose simulation time
Tsim = 1;
dt = time(end)-time(end-1);
ndt = ceil(Tsim/dt);

% define new tide and wave conditions
tide = xb_generate_tide('time', (time(end-ndt:end)-time(end-ndt))*3600*24, 'front', wl(end-ndt:end));
waves = xb_generate_waves('Hm0',hs(end-ndt:end),'Tp',tp(end-ndt:end),'mainang',dir(end-ndt:end),'duration',repmat(dt*3600*24,ndt+1,1));

% Fix simulation time
pars_si_COSMOS = xb_generate_settings('tstop',floor(ndt*dt*3600*24));      

% Merge all boundary condition and settings structures
xbm_si_COSMOS = xs_join(xbm_si,tide,waves,pars_si_COSMOS);

% Write model
xb_write_input([mod_dir,'params.txt'],xbm_si_COSMOS);