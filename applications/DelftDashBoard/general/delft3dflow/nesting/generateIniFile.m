function generateIniFile(flow,opt,fname)

% Coordinate conversion
if isfield(flow,'coordSysType')
    if ~strcmpi(flow.coordSysType,'geographic')
        % First convert grid to WGS 84
        [flow.gridX,flow.gridY]=convertCoordinates(flow.gridX,flow.gridY,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
        [flow.gridXZ,flow.gridYZ]=convertCoordinates(flow.gridXZ,flow.gridYZ,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
        flow.gridX=mod(flow.gridX,360);
        flow.gridXZ=mod(flow.gridXZ,360);
    end
end

mmax=size(flow.gridXZ,1)+1;
nmax=size(flow.gridYZ,2)+1;

dp=zeros(mmax,nmax);
dp(dp==0)=NaN;
dp(1:end-1,1:end-1)=-flow.depthZ;

if strcmpi(flow.vertCoord,'z')
    dplayer=GetLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
else
    dplayer=GetLayerDepths(dp,flow.thick);
end

%% Water Level
disp('   Water levels ...');
% Constant
h=zeros(mmax,nmax)+opt.waterLevel.IC.constant;
ddb_wldep('write',fname,h,'negate','n','bndopt','n');

%% Velocities
disp('   Velocities ...');
generateInitialConditions(flow,opt,'current',1,dplayer,fname);

%% Salinity
if flow.salinity.include
    disp('   Salinity ...');
    generateInitialConditions(flow,opt,'salinity',1,dplayer,fname);
end

%% Temperature
if flow.temperature.include
    disp('   Temperature ...');
    generateInitialConditions(flow,opt,'temperature',1,dplayer,fname);
end

%% Sediments
for i=1:flow.nrSediments
    disp('   Sediments ...');
    generateInitialConditions(flow,opt,'sediment',i,dplayer,fname);
end

%% Tracers
for i=1:flow.nrTracers
    disp('   Tracers ...');
    generateInitialConditions(flow,opt,'tracer',i,dplayer,fname);
end
