function handles=ddb_initializeSalinity(handles,id)

handles.Model(md).Input(id).salinity.ICOpt='Constant';
handles.Model(md).Input(id).salinity.ICConst=31;
handles.Model(md).Input(id).salinity.ICPar=[0 0];
handles.Model(md).Input(id).salinity.BCOpt='Constant';
handles.Model(md).Input(id).salinity.BCConst=31;
handles.Model(md).Input(id).salinity.BCPar=[0 0];

t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

for j=1:handles.Model(md).Input(id).nrOpenBoundaries
    handles.Model(md).Input(id).openBoundaries(j).salinity.nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(j).salinity.timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(j).salinity.timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).salinity.timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).salinity.profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(j).salinity.interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(j).salinity.discontinuity=1;
end

for j=1:handles.Model(md).Input(id).nrDischarges
    handles.Model(md).Input(id).discharges(j).salinity.timeSeries=[0.0;0.0];
end

