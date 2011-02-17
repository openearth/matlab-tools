function ddb_saveObsFile(handles,id)

fid=fopen(handles.Model(md).Input(id).obsFile,'w');
for i=1:handles.Model(md).Input(id).nrObservationPoints
    m=handles.Model(md).Input(id).observationPoints(i).M;
    n=handles.Model(md).Input(id).observationPoints(i).N;
    name=handles.Model(md).Input(id).observationPoints(i).name;
    fprintf(fid,'%s %3.0f %3.0f\n',[name repmat(' ',1,21-length(name)) ] ,m,n);
end
fclose(fid);
