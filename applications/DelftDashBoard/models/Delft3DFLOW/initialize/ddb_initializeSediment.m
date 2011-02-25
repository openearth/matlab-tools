function handles=ddb_initializeSediment(handles,id,ii)

% Sediment name and type must be defined before this

handles.Model(md).Input(id).sediment(ii).ICOpt='Constant';
handles.Model(md).Input(id).sediment(ii).ICConst=0;
handles.Model(md).Input(id).sediment(ii).ICPar=[0 0];
handles.Model(md).Input(id).sediment(ii).BCOpt='Constant';
handles.Model(md).Input(id).sediment(ii).BCConst=0;
handles.Model(md).Input(id).sediment(ii).BCPar=[0 0];

t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

for j=1:handles.Model(md).Input(id).nrOpenBoundaries
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).discontinuity=1;
end

for j=1:handles.Model(md).Input(id).nrDischarges
    handles.Model(md).Input(id).discharges(j).sediment(ii).timeSeries=[0.0;0.0];
end

handles.Model(md).Input(id).sediment(ii).rhoSol           = 2.6500000e+003;
handles.Model(md).Input(id).sediment(ii).iniSedThick      = 5.0000000e+000;
handles.Model(md).Input(id).sediment(ii).facDSS           = 1.0000000e+000;
handles.Model(md).Input(id).sediment(ii).salMax           = 0.0000000e+000;
handles.Model(md).Input(id).sediment(ii).wS0              = 2.5000000e-001;
handles.Model(md).Input(id).sediment(ii).wSM              = 2.5000000e-001;
handles.Model(md).Input(id).sediment(ii).tCrSed           = 1.0000000e+003;
handles.Model(md).Input(id).sediment(ii).tCrEro           = 5.0000000e-001;
handles.Model(md).Input(id).sediment(ii).eroPar           = 1.0000000e-004;
handles.Model(md).Input(id).sediment(ii).sedDia           = 2.0000000e-001;
handles.Model(md).Input(id).sediment(ii).sedD10           = 3.0000000e-001;
handles.Model(md).Input(id).sediment(ii).sedD90           = 1.0000000e-001;

handles.Model(md).Input(id).sediment(ii).uniformThickness=1;
handles.Model(md).Input(id).sediment(ii).uniformTCrEro=1;
handles.Model(md).Input(id).sediment(ii).uniformTCrSed=1;
handles.Model(md).Input(id).sediment(ii).uniformEroPar=1;
handles.Model(md).Input(id).sediment(ii).sdbFile='';
handles.Model(md).Input(id).sediment(ii).tceFile='';
handles.Model(md).Input(id).sediment(ii).tcdFile='';
handles.Model(md).Input(id).sediment(ii).eroFile='';

switch lower(handles.Model(md).Input(id).sediment(ii).type)
    case{'cohesive'}
        handles.Model(md).Input(id).sediment(ii).cDryB            =  5.0000000e+002;
    case{'non-cohesive'}
        handles.Model(md).Input(id).sediment(ii).cDryB            =  1.6000000e+003;
end
