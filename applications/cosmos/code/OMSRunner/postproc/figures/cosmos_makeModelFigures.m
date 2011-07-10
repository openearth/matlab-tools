function cosmos_makeModelFigures(hm,m)

dr=[hm.Models(m).Dir 'lastrun' filesep 'figures' filesep '*.*'];

delete(dr);

%% Time Series
disp('Making time series plots ...');
% cosmos_makeTimeSeriesPlots(hm,m);

%% Maps
switch lower(hm.Models(m).Type)
    case{'delft3dflowwave','delft3dflow'}
        disp('Making map plots ...');
        cosmos_makeMapKMZs(hm,m);
    case{'ww3'}
        disp('Making map plots ...');
        cosmos_makeMapKMZs(hm,m);
    case{'xbeach'}
        disp('Making map plots ...');
        cosmos_makeMapKMZs(hm,m);
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
