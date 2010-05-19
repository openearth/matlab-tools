function handles=ddb_initializeSalinity(handles,id)

handles.Model(md).Input(id).Salinity.ICOpt='Constant';
handles.Model(md).Input(id).Salinity.ICConst=31;
handles.Model(md).Input(id).Salinity.ICPar=[0 0];
handles.Model(md).Input(id).Salinity.BCOpt='Constant';
handles.Model(md).Input(id).Salinity.BCConst=31;
handles.Model(md).Input(id).Salinity.BCPar=[0 0];

t0=handles.Model(md).Input(id).StartTime;
t1=handles.Model(md).Input(id).StopTime;

for j=1:handles.Model(md).Input(id).NrOpenBoundaries
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.NrTimeSeries=2;
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.TimeSeriesT=[t0;t1];
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.TimeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.TimeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.Profile='Uniform';
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.Interpolation='Linear';
    handles.Model(md).Input(id).OpenBoundaries(j).Salinity.Discontinuity=1;
end

for j=1:handles.Model(md).Input(id).NrDischarges
    handles.Model(md).Input(id).Discharges(j).Salinity.TimeSeries=[0.0;0.0];
end

