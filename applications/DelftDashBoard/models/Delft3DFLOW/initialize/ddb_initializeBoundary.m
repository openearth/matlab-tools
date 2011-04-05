function handles=ddb_initializeBoundary(handles,id,nb)

handles.Model(md).Input(id).openBoundaries(nb).name='unknown';
handles.Model(md).Input(id).openBoundaries(nb).alpha=0.0;
handles.Model(md).Input(id).openBoundaries(nb).compA='unnamed';
handles.Model(md).Input(id).openBoundaries(nb).compB='unnamed';
handles.Model(md).Input(id).openBoundaries(nb).type='Z';
handles.Model(md).Input(id).openBoundaries(nb).forcing='A';
handles.Model(md).Input(id).openBoundaries(nb).profile='Uniform';
handles.Model(md).Input(id).openBoundaries(nb).THLag=[0 0];

[xb,yb,zb,side,orientation]=delft3dflow_getBoundaryCoordinates(handles,id,nb);
handles.Model(md).Input(id).openBoundaries(nb).x=xb;
handles.Model(md).Input(id).openBoundaries(nb).y=yb;
handles.Model(md).Input(id).openBoundaries(nb).depth=zb;
handles.Model(md).Input(id).openBoundaries(nb).side=side;
handles.Model(md).Input(id).openBoundaries(nb).orientation=orientation;

% Timeseries
t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;
handles.Model(md).Input(id).openBoundaries(nb).timeSeriesT=[t0;t1];
handles.Model(md).Input(id).openBoundaries(nb).timeSeriesA=[0.0;0.0];
handles.Model(md).Input(id).openBoundaries(nb).timeSeriesB=[0.0;0.0];
handles.Model(md).Input(id).openBoundaries(nb).nrTimeSeries=2;

% Harmonic
handles.Model(md).Input(id).openBoundaries(nb).harmonicAmpA=zeros(1,handles.Model(md).Input(id).nrHarmonicComponents);
handles.Model(md).Input(id).openBoundaries(nb).harmonicAmpB=zeros(1,handles.Model(md).Input(id).nrHarmonicComponents);
handles.Model(md).Input(id).openBoundaries(nb).harmonicPhaseA=zeros(1,handles.Model(md).Input(id).nrHarmonicComponents);
handles.Model(md).Input(id).openBoundaries(nb).harmonicPhaseB=zeros(1,handles.Model(md).Input(id).nrHarmonicComponents);

% QH
handles.Model(md).Input(id).openBoundaries(nb).QHDischarge =[0.0 100.0];
handles.Model(md).Input(id).openBoundaries(nb).QHWaterLevel=[0.0 0.0];

% Salinity
handles.Model(md).Input(id).openBoundaries(nb).salinity.nrTimeSeries=2;
handles.Model(md).Input(id).openBoundaries(nb).salinity.timeSeriesT=[t0;t1];
handles.Model(md).Input(id).openBoundaries(nb).salinity.timeSeriesA=[31.0;31.0];
handles.Model(md).Input(id).openBoundaries(nb).salinity.timeSeriesB=[31.0;31.0];
handles.Model(md).Input(id).openBoundaries(nb).salinity.profile='Uniform';
handles.Model(md).Input(id).openBoundaries(nb).salinity.interpolation='Linear';
handles.Model(md).Input(id).openBoundaries(nb).salinity.discontinuity=1;

% Temperature
handles.Model(md).Input(id).openBoundaries(nb).temperature.nrTimeSeries=2;
handles.Model(md).Input(id).openBoundaries(nb).temperature.timeSeriesT=[t0;t1];
handles.Model(md).Input(id).openBoundaries(nb).temperature.timeSeriesA=[20.0;20.0];
handles.Model(md).Input(id).openBoundaries(nb).temperature.timeSeriesB=[20.0;20.0];
handles.Model(md).Input(id).openBoundaries(nb).temperature.profile='Uniform';
handles.Model(md).Input(id).openBoundaries(nb).temperature.interpolation='Linear';
handles.Model(md).Input(id).openBoundaries(nb).temperature.discontinuity=1;

% Sediments
for i=1:handles.Model(md).Input(id).nrSediments
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(nb).sediment(i).discontinuity=1;
end

% Tracers
for i=1:handles.Model(md).Input(id).nrTracers
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(nb).tracer(i).discontinuity=1;
end

