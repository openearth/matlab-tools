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
        GenerateBctFile(Flow);        
    case{'ini'}
        disp('Generating initial conditions ...');
        GenerateIniFile(Flow);        
    case{'bcc'}
        disp('Generating transport boundary conditions ...');
        GenerateBccFile(Flow);
end

% 
% 
% 
% 
% 
% 
% 
% 
% 
% % Water levels
% 
%     % Initial conditions
%     Flow.WaterLevel.ICDataSource='uniform';
%     Flow.WaterLevel.ICConst=0.3;
% 
% 
% %     Flow.WaterLevel.BCDataSource='file';
% %     Flow.WaterLevel.DataFile='data\ncom\wl_ncom_20080901.mat';
% %     Flow.WaterLevel.ZCor=-0.6;
% 
% % Currents
% 
%     % Initial conditions
%     Flow.Current.ICDataSource='uniform';
%     Flow.Current.ICConst=0;
%     Flow.Current.ICProfile=[];
% 
%     Flow.Current.ICDataSource='3d';
%     Flow.Current.ICConst=0;
%     Flow.Current.ICProfile=[];
% 
%     % Boundary conditions
%     Flow.Current.BCDataSource='file';
% %    Flow.Current.BCProfile=[];
%     Flow.Current.BCConst=0;
%     Flow.Current.DataFile='data\ncom\velocity_ncom_20080901.mat';
% 
% % Flow.Riemann.WLDataSource='astro';
% % Flow.Riemann.WLDataFile='input\sd014\sd014.bca';
% % Flow.Riemann.VelDataSource='file';
% % Flow.Riemann.VelDataFile='ncom\velocity_ncom_20090715.mat';
% % Flow.Riemann.VelDataBndPrefix{1}='Sou';
% % Flow.Riemann.VelDataFile{2}='zeros.tek';
% % Flow.Riemann.VelDataBndPrefix{2}='Wes';
% % Flow.Riemann.VelDataFile{3}='zeros.tek';
% % Flow.Riemann.VelDataBndPrefix{3}='Nor';
% 
% % Flow.Riemann.BCProfile=[];
% % Flow.Riemann.ICProfile=[];
% 
% % Salinity
% 
%     % Initial conditions
%     Flow.Salinity.ICDataSource='profile';
%     Flow.Salinity.ICDataSource='3d';
%     salprf=load([Flow.InputDir 'salinity.prf']);
%     Flow.Salinity.ICProfile=salprf;
% 
%     % Boundary conditions
%     Flow.Salinity.BCDataSource='3d';
%     Flow.Salinity.DataFile='data\ncom\salinity_ncom_20080901.mat';
%     %Flow.Salinity.BCProfile=salprf;
% 
% % Temperature
% 
%     % Initial conditions
%     Flow.Temperature.ICDataSource='profile';
%     Flow.Temperature.ICDataSource='3d';
%     tmpprf=load([Flow.InputDir 'temperature.prf']);
%     Flow.Temperature.ICProfile=tmpprf;
% 
%     % Boundary conditions
% 
%     Flow.Temperature.BCDataSource='3d';
%     Flow.Temperature.DataFile='data\ncom\temperature_ncom_20080901.mat';
%     % Flow.Temperature.BCProfile=tmpprf;
% 
% % Tracer    
% 
%     % Initial conditions
%     Flow.Tracer(1).ICDataSource='uniform';
%     Flow.Tracer(1).ICConst=0;
% 
%     % Boundary conditions
%     Flow.Tracer(1).BCDataSource='uniform';
%     Flow.Tracer(1).BCConst=0;
% 
%     % Initial conditions
%     Flow.Tracer(2).ICDataSource='uniform';
%     Flow.Tracer(2).ICConst=0;
% 
%     % Boundary conditions
%     Flow.Tracer(2).BCDataSource='uniform';
%     Flow.Tracer(2).BCConst=0;
% 
% switch lower(fil)
%     case{'bct'}
%         GenerateBctFile(Flow);        
%     case{'ini'}
%         GenerateIniFile(Flow);        
%     case{'bcc'}
%         GenerateBccFile(Flow);
% end
