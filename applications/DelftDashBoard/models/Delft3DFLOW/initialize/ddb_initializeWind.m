function handles=ddb_initializeWind(handles,id)

t0=handles.Model(md).Input(id).StartTime;
t1=handles.Model(md).Input(id).StopTime;

handles.Model(md).Input(id).WindData=[t0 0 0;t1 0 0];
