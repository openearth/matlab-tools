function handles=ddb_initializeSediment(handles,ii)

handles.Model(md).Input(ad).sediment(ii).type='cohesive';

handles.Model(md).Input(ad).sediment(ii).ICOpt='Constant';
handles.Model(md).Input(ad).sediment(ii).ICConst=0;
handles.Model(md).Input(ad).sediment(ii).ICPar=[0 0];
handles.Model(md).Input(ad).sediment(ii).BCOpt='Constant';
handles.Model(md).Input(ad).sediment(ii).BCConst=0;
handles.Model(md).Input(ad).sediment(ii).BCPar=[0 0];

t0=handles.Model(md).Input(ad).startTime;
t1=handles.Model(md).Input(ad).stopTime;

for j=1:handles.Model(md).Input(ad).nrOpenBoundaries
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).nrTimeSeries=2;
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).timeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).profile='Uniform';
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).interpolation='Linear';
    handles.Model(md).Input(ad).openBoundaries(j).sediment(ii).discontinuity=1;
end

for j=1:handles.Model(md).Input(ad).nrDischarges
    handles.Model(md).Input(ad).Discharges(j).sediment(ii).timeSeries=[0.0;0.0];
end
