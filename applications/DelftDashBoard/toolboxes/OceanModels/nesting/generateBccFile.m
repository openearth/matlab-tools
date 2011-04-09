function GenerateBccFile(Flow)


nr=Flow.NrOpenBoundaries;
for i=1:nr
    dp(i,1)=-Flow.OpenBoundaries(i).Depth(1);
    dp(i,2)=-Flow.OpenBoundaries(i).Depth(2);
end

if strcmpi(Flow.VertCoord,'z')
    dplayer=GetLayerDepths(dp,Flow.Thick,Flow.ZBot,Flow.ZTop);
else
    dplayer=GetLayerDepths(dp,Flow.Thick);
end

%% Temperature
if Flow.Temperature.Include
    disp('   Temperature ...');
    Flow=GenerateTransportBoundaryConditions(Flow,'Temperature',1,dplayer);
end

%% Salinity
if Flow.Salinity.Include
   disp('   Salinity ...');
   Flow=GenerateTransportBoundaryConditions(Flow,'Salinity',1,dplayer);
end

%% Sediments
if Flow.NrSediments>0
    disp('   Sediments ...');
    for i=1:Flow.NrSediments
        Flow=GenerateTransportBoundaryConditions(Flow,'Sediment',i,dplayer);
    end
end

%% Sediments
if Flow.NrTracers>0
    disp('   Tracers ...');
    for i=1:Flow.NrTracers
        Flow=GenerateTransportBoundaryConditions(Flow,'Tracer',i,dplayer);
    end
end

disp('Saving bcc file');
SaveBccFile(Flow);
