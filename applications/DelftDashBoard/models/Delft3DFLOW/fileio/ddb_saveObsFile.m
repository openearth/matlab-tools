function ddb_saveObsFile(handles,id)

fid=fopen(handles.Model(md).Input(id).ObsFile,'w');
for i=1:handles.Model(md).Input(id).NrObservationPoints
    m=handles.Model(md).Input(id).ObservationPoints(i).M;
    n=handles.Model(md).Input(id).ObservationPoints(i).N;
    name=handles.Model(md).Input(id).ObservationPoints(i).Name;
    fprintf(fid,'%s %3.0f %3.0f\n',[name repmat(' ',1,21-length(name)) ] ,m,n);
end
fclose(fid);
