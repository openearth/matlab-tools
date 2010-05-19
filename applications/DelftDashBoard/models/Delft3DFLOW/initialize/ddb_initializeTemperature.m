function handles=ddb_initializeTemperature(handles,id)

handles.Model(md).Input(id).Temperature.ICOpt='Constant';
handles.Model(md).Input(id).Temperature.ICConst=20;
handles.Model(md).Input(id).Temperature.ICPar=[0 0];
handles.Model(md).Input(id).Temperature.BCOpt='Constant';
handles.Model(md).Input(id).Temperature.BCConst=20;
handles.Model(md).Input(id).Temperature.BCPar=[0 0];

t0=handles.Model(md).Input(id).StartTime;
t1=handles.Model(md).Input(id).StopTime;

for j=1:handles.Model(md).Input(id).NrOpenBoundaries
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.NrTimeSeries=2;
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.TimeSeriesT=[t0;t1];
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.TimeSeriesA=[20.0;20.0];
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.TimeSeriesB=[20.0;20.0];
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.Profile='Uniform';
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.Interpolation='Linear';
    handles.Model(md).Input(id).OpenBoundaries(j).Temperature.Discontinuity=1;
end

for j=1:handles.Model(md).Input(id).NrDischarges
    handles.Model(md).Input(id).Discharges(j).Temperature.TimeSeries=[20.0;20.0];
end
