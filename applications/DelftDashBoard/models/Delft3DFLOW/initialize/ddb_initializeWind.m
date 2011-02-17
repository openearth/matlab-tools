function handles=ddb_initializeWind(handles,id)

t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

handles.Model(md).Input(id).windData=[t0 0 0;t1 0 0];
