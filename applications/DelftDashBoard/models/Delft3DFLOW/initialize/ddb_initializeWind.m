function handles=ddb_initializeWind(handles,id)

t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

handles.Model(md).Input(id).windTimeSeriesT=[t0;t1];
handles.Model(md).Input(id).windTimeSeriesSpeed=[0;0];
handles.Model(md).Input(id).windTimeSeriesDirection=[0;0];
