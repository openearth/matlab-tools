function handles=ddb_initializeTracer(handles,ii)

handles.Model(md).Input(ad).tracer(ii).ICOpt='Constant';
handles.Model(md).Input(ad).tracer(ii).ICConst=0;
handles.Model(md).Input(ad).tracer(ii).ICPar=[0 0];
handles.Model(md).Input(ad).tracer(ii).BCOpt='Constant';
handles.Model(md).Input(ad).tracer(ii).BCConst=0;
handles.Model(md).Input(ad).tracer(ii).BCPar=[0 0];

t0=handles.Model(md).Input(ad).startTime;
t1=handles.Model(md).Input(ad).stopTime;

for j=1:handles.Model(md).Input(ad).nrOpenBoundaries
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).nrTimeSeries=2;
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).timeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).profile='Uniform';
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).interpolation='Linear';
    handles.Model(md).Input(ad).openBoundaries(j).tracer(ii).discontinuity=1;
end

for j=1:handles.Model(md).Input(ad).nrDischarges
    handles.Model(md).Input(ad).discharges(j).tracer(ii).timeSeries=[0.0;0.0];
end
