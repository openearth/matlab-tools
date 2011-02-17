function handles=ddb_initializeBoundary(handles,nb)

handles.Model(md).Input(ad).openBoundaries(nb).name='unknown';
handles.Model(md).Input(ad).openBoundaries(nb).alpha=0.0;
handles.Model(md).Input(ad).openBoundaries(nb).compA='unnamed';
handles.Model(md).Input(ad).openBoundaries(nb).compB='unnamed';
handles.Model(md).Input(ad).openBoundaries(nb).type='Z';
handles.Model(md).Input(ad).openBoundaries(nb).forcing='A';
handles.Model(md).Input(ad).openBoundaries(nb).profile='Uniform';
handles.Model(md).Input(ad).openBoundaries(nb).THLag=[0 0];

[xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,ad,nb);
handles.Model(md).Input(ad).openBoundaries(nb).x=xb;
handles.Model(md).Input(ad).openBoundaries(nb).y=yb;
handles.Model(md).Input(ad).openBoundaries(nb).depth=zb;
handles.Model(md).Input(ad).openBoundaries(nb).side=side;
handles.Model(md).Input(ad).openBoundaries(nb).orientation=orientation;

% Timeseries
t0=handles.Model(md).Input(ad).startTime;
t1=handles.Model(md).Input(ad).stopTime;
handles.Model(md).Input(ad).openBoundaries(nb).timeSeriesT=[t0;t1];
handles.Model(md).Input(ad).openBoundaries(nb).timeSeriesA=[0.0;0.0];
handles.Model(md).Input(ad).openBoundaries(nb).timeSeriesB=[0.0;0.0];
handles.Model(md).Input(ad).openBoundaries(nb).nrTimeSeries=2;

% Harmonic
handles.Model(md).Input(ad).openBoundaries(nb).harmonicAmpA=zeros(1,handles.Model(md).Input(ad).nrHarmonicComponents);
handles.Model(md).Input(ad).openBoundaries(nb).harmonicAmpB=zeros(1,handles.Model(md).Input(ad).nrHarmonicComponents);
handles.Model(md).Input(ad).openBoundaries(nb).harmonicPhaseA=zeros(1,handles.Model(md).Input(ad).nrHarmonicComponents);
handles.Model(md).Input(ad).openBoundaries(nb).harmonicPhaseB=zeros(1,handles.Model(md).Input(ad).nrHarmonicComponents);

% QH
handles.Model(md).Input(ad).openBoundaries(nb).QHDischarge =[0.0 100.0];
handles.Model(md).Input(ad).openBoundaries(nb).QHWaterLevel=[0.0 0.0];

% Salinity
handles.Model(md).Input(ad).openBoundaries(nb).salinity.nrTimeSeries=2;
handles.Model(md).Input(ad).openBoundaries(nb).salinity.timeSeriesT=[t0;t1];
handles.Model(md).Input(ad).openBoundaries(nb).salinity.timeSeriesA=[31.0;31.0];
handles.Model(md).Input(ad).openBoundaries(nb).salinity.timeSeriesB=[31.0;31.0];
handles.Model(md).Input(ad).openBoundaries(nb).salinity.profile='Uniform';
handles.Model(md).Input(ad).openBoundaries(nb).salinity.interpolation='Linear';
handles.Model(md).Input(ad).openBoundaries(nb).salinity.discontinuity=1;

% Temperature
handles.Model(md).Input(ad).openBoundaries(nb).temperature.nrTimeSeries=2;
handles.Model(md).Input(ad).openBoundaries(nb).temperature.timeSeriesT=[t0;t1];
handles.Model(md).Input(ad).openBoundaries(nb).temperature.timeSeriesA=[20.0;20.0];
handles.Model(md).Input(ad).openBoundaries(nb).temperature.timeSeriesB=[20.0;20.0];
handles.Model(md).Input(ad).openBoundaries(nb).temperature.profile='Uniform';
handles.Model(md).Input(ad).openBoundaries(nb).temperature.interpolation='Linear';
handles.Model(md).Input(ad).openBoundaries(nb).temperature.discontinuity=1;

% Sediments
for i=1:handles.Model(md).Input(ad).nrSediments
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).nrTimeSeries=2;
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).timeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).profile='Uniform';
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).interpolation='Linear';
    handles.Model(md).Input(ad).openBoundaries(nb).sediment(i).discontinuity=1;
end

% Tracers
for i=1:handles.Model(md).Input(ad).nrTracers
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).nrTimeSeries=2;
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).timeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).profile='Uniform';
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).interpolation='Linear';
    handles.Model(md).Input(ad).openBoundaries(nb).tracer(i).discontinuity=1;
end

