function GenerateIniFile(Flow)

mmax=size(Flow.GridXZ,1)+1;
nmax=size(Flow.GridYZ,2)+1;

dp=zeros(mmax,nmax);
dp(dp==0)=NaN;
dp(1:end-1,1:end-1)=-Flow.DepthZ;

if strcmpi(Flow.VertCoord,'z')
    dplayer=GetLayerDepths(dp,Flow.Thick,Flow.ZBot,Flow.ZTop);
else
    dplayer=GetLayerDepths(dp,Flow.Thick);
end

%% Water Level
disp('   Water levels ...');
% Constant
h=zeros(mmax,nmax)+Flow.WaterLevel.IC.Constant;
if exist([Flow.OutputDir Flow.IniFile],'file')
    delete([Flow.OutputDir Flow.IniFile]);
end
if isempty(Flow.IniFile)
    error('No file name specified for initial conditions in mdf file');
end
wldep_mvo('write',[Flow.OutputDir Flow.IniFile],h,'negate','n','bndopt','n');

%% Velocities
disp('   Velocities ...');
GenerateInitialConditions(Flow,'Current',1,dplayer);
%GenerateInitialConditions(Flow,'CurrentU',1,dplayer);
%GenerateInitialConditions(Flow,'CurrentV',1,dplayer);

%% Salinity
if Flow.Salinity.Include
    disp('   Salinity ...');
    GenerateInitialConditions(Flow,'Salinity',1,dplayer);
end

%% Temperature
if Flow.Temperature.Include
    disp('   Temperature ...');
    GenerateInitialConditions(Flow,'Temperature',1,dplayer);
end

%% Sediments
for i=1:Flow.NrSediments
    disp('   Sediments ...');
    GenerateInitialConditions(Flow,'Sediment',i,dplayer);
end

%% Tracers
for i=1:Flow.NrTracers
    disp('   Tracers ...');
    GenerateInitialConditions(Flow,'Tracer',i,dplayer);
end

