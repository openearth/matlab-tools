function handles=ddb_initializeTemperature(handles,id)

handles.Model(md).Input(id).temperature.ICOpt='Constant';
handles.Model(md).Input(id).temperature.ICConst=20;
handles.Model(md).Input(id).temperature.ICPar=[0 0];
handles.Model(md).Input(id).temperature.BCOpt='Constant';
handles.Model(md).Input(id).temperature.BCConst=20;
handles.Model(md).Input(id).temperature.BCPar=[0 0];

t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

for j=1:handles.Model(md).Input(id).nrOpenBoundaries
    handles.Model(md).Input(id).openBoundaries(j).temperature.nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(j).temperature.timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(j).temperature.timeSeriesA=[20.0;20.0];
    handles.Model(md).Input(id).openBoundaries(j).temperature.timeSeriesB=[20.0;20.0];
    handles.Model(md).Input(id).openBoundaries(j).temperature.profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(j).temperature.interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(j).temperature.discontinuity=1;
end

for j=1:handles.Model(md).Input(id).nrDischarges
    handles.Model(md).Input(id).Discharges(j).temperature.timeSeries=[20.0;20.0];
end
