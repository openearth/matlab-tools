function handles=ddb_initializeSediment(handles,ii)

handles.Model(md).Input(ad).Sediment(ii).ICOpt='Constant';
handles.Model(md).Input(ad).Sediment(ii).ICConst=0;
handles.Model(md).Input(ad).Sediment(ii).ICPar=[0 0];
handles.Model(md).Input(ad).Sediment(ii).BCOpt='Constant';
handles.Model(md).Input(ad).Sediment(ii).BCConst=0;
handles.Model(md).Input(ad).Sediment(ii).BCPar=[0 0];

t0=handles.Model(md).Input(ad).StartTime;
t1=handles.Model(md).Input(ad).StopTime;

for j=1:handles.Model(md).Input(ad).NrOpenBoundaries
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).NrTimeSeries=2;
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).TimeSeriesT=[t0;t1];
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).TimeSeriesA=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).TimeSeriesB=[0.0;0.0];
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).Profile='Uniform';
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).Interpolation='Linear';
    handles.Model(md).Input(ad).OpenBoundaries(j).Sediment(ii).Discontinuity=1;
end

for j=1:handles.Model(md).Input(ad).NrDischarges
    handles.Model(md).Input(ad).Discharges(j).Sediment(ii).TimeSeries=[0.0;0.0];
end
