function handles=ddb_initializeTracer(handles,ii)

handles.Model(md).Input(ad).Tracer(ii).ICOpt='Constant';
handles.Model(md).Input(ad).Tracer(ii).ICConst=0;
handles.Model(md).Input(ad).Tracer(ii).ICPar=[0 0];
handles.Model(md).Input(ad).Tracer(ii).BCOpt='Constant';
handles.Model(md).Input(ad).Tracer(ii).BCConst=0;
handles.Model(md).Input(ad).Tracer(ii).BCPar=[0 0];

t0=handles.Model(md).Input(ad).StartTime;
t1=handles.Model(md).Input(ad).StopTime;

for j=1:handles.Model(md).Input(ad).NrOpenBoundaries
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).NrTimeSeries=2;
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).TimeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).TimeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).TimeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).Profile='Uniform';
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).Interpolation='Linear';
    handles.Model(md).Input(ad).OpenBoundaries(j).Tracer(ii).Discontinuity=1;
end

for j=1:handles.Model(md).Input(ad).NrDischarges
    handles.Model(md).Input(ad).Discharges(j).Tracer(ii).TimeSeries=[0.0;0.0];
end
