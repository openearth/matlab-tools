function handles=ddb_initializeDischarge(handles,id,n)

handles.Model(md).Input(ad).Discharges(n).Name='unknown';
handles.Model(md).Input(ad).Discharges(n).M=0;
handles.Model(md).Input(ad).Discharges(n).N=0;
handles.Model(md).Input(ad).Discharges(n).K=0;
handles.Model(md).Input(ad).Discharges(n).Mout=0;
handles.Model(md).Input(ad).Discharges(n).Nout=0;
handles.Model(md).Input(ad).Discharges(n).Kout=0;
handles.Model(md).Input(ad).Discharges(n).Interpolation='linear';
handles.Model(md).Input(ad).Discharges(n).Type='Normal';
t0=handles.Model(md).Input(ad).StartTime;
t1=handles.Model(md).Input(ad).StopTime;
handles.Model(md).Input(ad).Discharges(n).TimeSeriesT=[t0;t1];
handles.Model(md).Input(ad).Discharges(n).TimeSeriesQ=[0.0;0.0];
handles.Model(md).Input(ad).Discharges(n).TimeSeriesM=[0.0;0.0];
handles.Model(md).Input(ad).Discharges(n).TimeSeriesD=[0.0;0.0];
handles.Model(md).Input(ad).Discharges(n).NrTimeSeries=2;

% Salinity
handles.Model(md).Input(ad).Discharges(n).Salinity.TimeSeries=[0.0;0.0];

% Temperature
handles.Model(md).Input(ad).Discharges(n).Temperature.TimeSeries=[20.0;20.0];

% Sediments
for i=1:handles.Model(md).Input(ad).NrSediments
    handles.Model(md).Input(ad).Discharges(n).Sediment(i).TimeSeries=[0.0;0.0];
end

% Tracers
for i=1:handles.Model(md).Input(ad).NrTracers
    handles.Model(md).Input(ad).Discharges(n).Tracer(i).TimeSeries=[0.0;0.0];
end

