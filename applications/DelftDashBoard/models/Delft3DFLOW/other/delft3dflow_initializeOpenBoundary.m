function openBoundaries=delft3dflow_initializeOpenBoundary(openBoundaries,nb,t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs)

openBoundaries(nb).THLag=[0 0];

[xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(openBoundaries(nb),x,y,depthZ,kcs);

openBoundaries(nb).x=xb;
openBoundaries(nb).y=yb;
openBoundaries(nb).depth=zb;
openBoundaries(nb).side=side;
openBoundaries(nb).alphau=alphau;
openBoundaries(nb).alphav=alphav;
openBoundaries(nb).orientation=orientation;

% Timeseries
openBoundaries(nb).timeSeriesT=[t0;t1];
openBoundaries(nb).timeSeriesA=[0.0;0.0];
openBoundaries(nb).timeSeriesB=[0.0;0.0];
openBoundaries(nb).nrTimeSeries=2;

% Harmonic
openBoundaries(nb).harmonicAmpA=zeros(1,nrharmo);
openBoundaries(nb).harmonicAmpB=zeros(1,nrharmo);
openBoundaries(nb).harmonicPhaseA=zeros(1,nrharmo);
openBoundaries(nb).harmonicPhaseB=zeros(1,nrharmo);

% QH
openBoundaries(nb).QHDischarge =[0.0 100.0];
openBoundaries(nb).QHWaterLevel=[0.0 0.0];

% Salinity
openBoundaries(nb).salinity.nrTimeSeries=2;
openBoundaries(nb).salinity.timeSeriesT=[t0;t1];
openBoundaries(nb).salinity.timeSeriesA=[31.0;31.0];
openBoundaries(nb).salinity.timeSeriesB=[31.0;31.0];
openBoundaries(nb).salinity.profile='Uniform';
openBoundaries(nb).salinity.interpolation='Linear';
openBoundaries(nb).salinity.discontinuity=1;

% Temperature
openBoundaries(nb).temperature.nrTimeSeries=2;
openBoundaries(nb).temperature.timeSeriesT=[t0;t1];
openBoundaries(nb).temperature.timeSeriesA=[20.0;20.0];
openBoundaries(nb).temperature.timeSeriesB=[20.0;20.0];
openBoundaries(nb).temperature.profile='Uniform';
openBoundaries(nb).temperature.interpolation='Linear';
openBoundaries(nb).temperature.discontinuity=1;

% Sediments
for i=1:nrsed
    openBoundaries(nb).sediment(i).nrTimeSeries=2;
    openBoundaries(nb).sediment(i).timeSeriesT=[t0;t1];
    openBoundaries(nb).sediment(i).timeSeriesA=[0.0;0.0];
    openBoundaries(nb).sediment(i).timeSeriesB=[0.0;0.0];
    openBoundaries(nb).sediment(i).profile='Uniform';
    openBoundaries(nb).sediment(i).interpolation='Linear';
    openBoundaries(nb).sediment(i).discontinuity=1;
end

% Tracers
for i=1:nrtrac
    openBoundaries(nb).tracer(i).nrTimeSeries=2;
    openBoundaries(nb).tracer(i).timeSeriesT=[t0;t1];
    openBoundaries(nb).tracer(i).timeSeriesA=[0.0;0.0];
    openBoundaries(nb).tracer(i).timeSeriesB=[0.0;0.0];
    openBoundaries(nb).tracer(i).profile='Uniform';
    openBoundaries(nb).tracer(i).interpolation='Linear';
    openBoundaries(nb).tracer(i).discontinuity=1;
end

