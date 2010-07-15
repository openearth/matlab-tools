function handles=ddb_initializeBoundary(handles,nb)

handles.Model(md).Input(ad).OpenBoundaries(nb).Name='unknown';
handles.Model(md).Input(ad).OpenBoundaries(nb).Alpha=0.0;
handles.Model(md).Input(ad).OpenBoundaries(nb).CompA='unnamed';
handles.Model(md).Input(ad).OpenBoundaries(nb).CompB='unnamed';
handles.Model(md).Input(ad).OpenBoundaries(nb).Type='Z';
handles.Model(md).Input(ad).OpenBoundaries(nb).Forcing='A';
handles.Model(md).Input(ad).OpenBoundaries(nb).Profile='Uniform';
handles.Model(md).Input(ad).OpenBoundaries(nb).THLag=[0 0];

[xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,ad,nb);
handles.Model(md).Input(ad).OpenBoundaries(nb).X=xb;
handles.Model(md).Input(ad).OpenBoundaries(nb).Y=yb;
handles.Model(md).Input(ad).OpenBoundaries(nb).Depth=zb;
handles.Model(md).Input(ad).OpenBoundaries(nb).Side=side;
handles.Model(md).Input(ad).OpenBoundaries(nb).Orientation=orientation;

% Timeseries
t0=handles.Model(md).Input(ad).StartTime;
t1=handles.Model(md).Input(ad).StopTime;
handles.Model(md).Input(ad).OpenBoundaries(nb).TimeSeriesT=[t0;t1];
handles.Model(md).Input(ad).OpenBoundaries(nb).TimeSeriesA=[0.0;0.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).TimeSeriesB=[0.0;0.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).NrTimeSeries=2;

% Harmonic
handles.Model(md).Input(ad).OpenBoundaries(nb).HarmonicAmpA=zeros(1,handles.Model(md).Input(ad).NrHarmonicComponents);
handles.Model(md).Input(ad).OpenBoundaries(nb).HarmonicAmpB=zeros(1,handles.Model(md).Input(ad).NrHarmonicComponents);
handles.Model(md).Input(ad).OpenBoundaries(nb).HarmonicPhaseA=zeros(1,handles.Model(md).Input(ad).NrHarmonicComponents);
handles.Model(md).Input(ad).OpenBoundaries(nb).HarmonicPhaseB=zeros(1,handles.Model(md).Input(ad).NrHarmonicComponents);

% QH
handles.Model(md).Input(ad).OpenBoundaries(nb).QHDischarge =[0.0 100.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).QHWaterLevel=[0.0 0.0];

% Salinity
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.NrTimeSeries=2;
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.TimeSeriesT=[t0;t1];
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.TimeSeriesA=[31.0;31.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.TimeSeriesB=[31.0;31.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.Profile='Uniform';
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.Interpolation='Linear';
handles.Model(md).Input(ad).OpenBoundaries(nb).Salinity.Discontinuity=1;

% Temperature
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.NrTimeSeries=2;
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.TimeSeriesT=[t0;t1];
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.TimeSeriesA=[20.0;20.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.TimeSeriesB=[20.0;20.0];
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.Profile='Uniform';
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.Interpolation='Linear';
handles.Model(md).Input(ad).OpenBoundaries(nb).Temperature.Discontinuity=1;

% Sediments
for i=1:handles.Model(md).Input(ad).NrSediments
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).NrTimeSeries=2;
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).TimeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).TimeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).TimeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).Profile='Uniform';
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).Interpolation='Linear';
    handles.Model(md).Input(ad).OpenBoundaries(nb).Sediment(i).Discontinuity=1;
end

% Tracers
for i=1:handles.Model(md).Input(ad).NrTracers
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).NrTimeSeries=2;
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).TimeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).TimeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).TimeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).Profile='Uniform';
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).Interpolation='Linear';
    handles.Model(md).Input(ad).OpenBoundaries(nb).Tracer(i).Discontinuity=1;
end

