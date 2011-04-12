function makeBccBctIni(Flow,fil)

% This script will generate an initial conditions file (*.ini) and
% boundary conditions file (*.bct and *.bcc) for Delft3D
% Author: Maarten van Ormondt

Flow.OutputDir=Flow.InputDir;

if ~isfield(Flow,'CoordSysType')
    Flow.CoordSysName='WGS 84';
    Flow.CoordSysType='geographic';
end

Flow=readInput(Flow);

%% Water Level
Flow.WaterLevel.IC.File=[Flow.DataDir 'waterlevel_' Flow.DataFile '.mat'];
Flow.WaterLevel.BC.File=[Flow.DataDir 'waterlevel_' Flow.DataFile '.mat'];

% Flow.WaterLevel.IC.File=[Flow.DataDir 'surf_el_' Flow.DataFile '.mat'];
% Flow.WaterLevel.BC.File=[Flow.DataDir 'surf_el_' Flow.DataFile '.mat'];

%% Velocity
Flow.Current.IC.File=[Flow.DataDir 'velocity_' Flow.DataFile '.mat'];
Flow.Current.BC.File=[Flow.DataDir 'velocity_' Flow.DataFile '.mat'];

% Flow.CurrentU.IC.File=[Flow.DataDir 'water_u_' Flow.DataFile '.mat'];
% Flow.CurrentU.BC.File=[Flow.DataDir 'water_u_' Flow.DataFile '.mat'];
% Flow.CurrentV.IC.File=[Flow.DataDir 'water_v_' Flow.DataFile '.mat'];
% Flow.CurrentV.BC.File=[Flow.DataDir 'water_v_' Flow.DataFile '.mat'];

%% Salinity
Flow.Salinity.IC.File=[Flow.DataDir 'salinity_' Flow.DataFile '.mat'];
Flow.Salinity.BC.File=[Flow.DataDir 'salinity_' Flow.DataFile '.mat'];

Flow.Salinity.IC.ProfileFile='salinity.prf';
Flow.Salinity.BC.ProfileFile='salinity.prf';
if strcmpi(Flow.Salinity.IC.Source,'profile')
    Flow.Salinity.IC.Profile=load([Flow.DataDir Flow.Salinity.IC.ProfileFile]);
end
if strcmpi(Flow.Salinity.BC.Source,'profile')
    Flow.Salinity.BC.Profile=load([Flow.DataDir Flow.Salinity.BC.ProfileFile]);
end

%% Temperature
Flow.Temperature.IC.File=[Flow.DataDir 'temperature_' Flow.DataFile '.mat'];
Flow.Temperature.BC.File=[Flow.DataDir 'temperature_' Flow.DataFile '.mat'];

% Flow.Temperature.IC.File=[Flow.DataDir 'water_temp_' Flow.DataFile '.mat'];
% Flow.Temperature.BC.File=[Flow.DataDir 'water_temp_' Flow.DataFile '.mat'];
% 
Flow.Temperature.IC.ProfileFile='temperature.prf';
Flow.Temperature.BC.ProfileFile='temperature.prf';
if strcmpi(Flow.Temperature.IC.Source,'profile')
    Flow.Temperature.IC.Profile=load([Flow.DataDir Flow.Temperature.IC.ProfileFile]);
end
if strcmpi(Flow.Temperature.BC.Source,'profile')
    Flow.Temperature.BC.Profile=load([Flow.DataDir Flow.Temperature.BC.ProfileFile]);
end

%% Tracers   
for i=1:Flow.NrTracers
    % Initial conditions
    Flow.Tracer(1).IC.Source='constant';
    Flow.Tracer(1).IC.Constant=0;
    Flow.Tracer(1).BC.Source='constant';
    Flow.Tracer(1).BC.Constant=0;
end

%% And now to work!
switch lower(fil)
    case{'bct'}
        disp('Generating hydrodynamic boundary conditions ...');
        openBoundaries=generateBctFile(flow,openboundaries,opt);
    case{'ini'}
        disp('Generating initial conditions ...');
        generateIniFile(Flow);        
    case{'bcc'}
        disp('Generating transport boundary conditions ...');
        generateBccFile(Flow);
end
