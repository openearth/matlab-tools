function runMuppet(hm,m)

dr=[hm.Models(m).Dir 'lastrun' filesep 'figures' filesep '*.*'];

delete(dr);

%% Time Series
disp('Making time series plots ...');
RunMuppetTimeSeries(hm,m);

%% Maps
switch lower(hm.Models(m).Type)
    case{'delft3dflowwave','delft3dflow'}
        disp('Making map plots ...');
        runMuppetMaps(hm,m);
%        makeKmlMaps(hm,m);
    case{'ww3'}
        disp('Making map plots ...');
        runMuppetMaps(hm,m);
%        makeKmlMaps(hm,m);
    case{'xbeach'}
        disp('Making map plots ...');
%        runMuppetMaps(hm,m);
        makeKmlMaps(hm,m);
end


%% Profiles
switch lower(hm.Models(m).Type)
    case{'xbeachcluster'}
        disp('Making profile plots ...');
        plotXBBeachProfiles(hm,m);
end

%% Hazards
switch lower(hm.Models(m).Type)
    case{'xbeachcluster'}
        disp('Making hazard KMZs ...');
        makeXBHazardsKMZs(hm,m);
end
