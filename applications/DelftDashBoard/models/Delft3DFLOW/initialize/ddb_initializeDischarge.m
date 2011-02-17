function handles=ddb_initializeDischarge(handles,id,n)

handles.Model(md).Input(id).discharges(n).name='unknown';
handles.Model(md).Input(id).discharges(n).M=0;
handles.Model(md).Input(id).discharges(n).N=0;
handles.Model(md).Input(id).discharges(n).K=0;
handles.Model(md).Input(id).discharges(n).mOut=0;
handles.Model(md).Input(id).discharges(n).nOut=0;
handles.Model(md).Input(id).discharges(n).kOut=0;
handles.Model(md).Input(id).discharges(n).interpolation='linear';
handles.Model(md).Input(id).discharges(n).type='Normal';
t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;
handles.Model(md).Input(id).discharges(n).timeSeriesT=[t0;t1];
handles.Model(md).Input(id).discharges(n).timeSeriesQ=[0.0;0.0];
handles.Model(md).Input(id).discharges(n).timeSeriesM=[0.0;0.0];
handles.Model(md).Input(id).discharges(n).timeSeriesD=[0.0;0.0];
handles.Model(md).Input(id).discharges(n).nrTimeSeries=2;

% Salinity
handles.Model(md).Input(id).discharges(n).salinity.timeSeries=[0.0;0.0];

% Temperature
handles.Model(md).Input(id).discharges(n).temperature.timeSeries=[20.0;20.0];

% Sediments
for i=1:handles.Model(md).Input(id).nrSediments
    handles.Model(md).Input(id).discharges(n).sediment(i).timeSeries=[0.0;0.0];
end

% Tracers
for i=1:handles.Model(md).Input(id).nrTracers
    handles.Model(md).Input(id).discharges(n).tracer(i).timeSeries=[0.0;0.0];
end

