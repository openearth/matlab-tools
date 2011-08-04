function handles=ddb_initializeTracer(handles,id,ii)

handles.Model(md).Input(id).tracer(ii).ICOpt='Constant';
handles.Model(md).Input(id).tracer(ii).ICConst=0;
handles.Model(md).Input(id).tracer(ii).ICPar=[0 0];
handles.Model(md).Input(id).tracer(ii).BCOpt='Constant';
handles.Model(md).Input(id).tracer(ii).BCConst=0;
handles.Model(md).Input(id).tracer(ii).BCPar=[0 0];

t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

for j=1:handles.Model(md).Input(id).nrOpenBoundaries
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(j).tracer(ii).discontinuity=1;
end

for j=1:handles.Model(md).Input(id).nrDischarges
    nt=length(handles.Model(md).Input(id).discharges(j).timeSeriesT);
    handles.Model(md).Input(id).discharges(j).tracer(ii).timeSeries=zeros(nt,1);
end
