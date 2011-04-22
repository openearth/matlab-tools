function openBoundaries=generateBccFile(flow,openBoundaries,opt)


for i=1:length(openBoundaries)
    dp(i,1)=-openBoundaries(i).depth(1);
    dp(i,2)=-openBoundaries(i).depth(2);
end

if strcmpi(flow.vertCoord,'z')
    dplayer=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
else
    dplayer=getLayerDepths(dp,flow.thick);
end

%% Temperature
if flow.temperature.include
    disp('   Temperature ...');
    openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,'temperature',1,dplayer);
end

%% Salinity
if flow.salinity.include
   disp('   Salinity ...');
   openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,'salinity',1,dplayer);
end

%% Sediments
if flow.nrSediments>0
    disp('   Sediments ...');
    for i=1:flow.nrSediments
        openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,'sediment',i,dplayer);
    end
end

%% Sediments
if flow.nrTracers>0
    disp('   Tracers ...');
    for i=1:flow.nrTracers
        openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,'tracer',i,dplayer);
    end
end
