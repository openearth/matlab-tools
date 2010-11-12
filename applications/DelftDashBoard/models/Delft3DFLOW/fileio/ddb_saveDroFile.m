function ddb_saveDroFile(handles,id)

fid=fopen(handles.Model(md).Input(id).DroFile,'w');
for i=1:handles.Model(md).Input(id).NrDrogues
    t1=(handles.Model(md).Input(id).Drogues(i).ReleaseTime-handles.Model(md).Input(id).ItDate)*1440;
    t2=(handles.Model(md).Input(id).Drogues(i).RecoveryTime-handles.Model(md).Input(id).ItDate)*1440;
    m=handles.Model(md).Input(id).Drogues(i).M;
    n=handles.Model(md).Input(id).Drogues(i).N;
    name=handles.Model(md).Input(id).Drogues(i).Name;
    fprintf(fid,'%s %16.7e %16.7e %16.7e %16.7e\n',[name repmat(' ',1,21-length(name)) ] ,t1,t2,m,n);
end
fclose(fid);
