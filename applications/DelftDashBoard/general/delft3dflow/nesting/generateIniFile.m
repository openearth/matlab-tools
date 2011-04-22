function generateIniFile(flow,opt,fname)

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
wldep('write',fname,h,'negate','n','bndopt','n');

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
