function ddb_saveDroFile(handles,id)

fid=fopen(handles.Model(md).Input(id).droFile,'w');
for i=1:handles.Model(md).Input(id).nrDrogues
    t1=(handles.Model(md).Input(id).drogues(i).releaseTime-handles.Model(md).Input(id).itDate)*1440;
    t2=(handles.Model(md).Input(id).drogues(i).recoveryTime-handles.Model(md).Input(id).itDate)*1440;
    m=handles.Model(md).Input(id).drogues(i).M;
    n=handles.Model(md).Input(id).drogues(i).N;
    name=handles.Model(md).Input(id).drogues(i).name;
    fprintf(fid,'%s %16.7e %16.7e %16.7e %16.7e\n',[name repmat(' ',1,21-length(name)) ] ,t1,t2,m,n);
end
fclose(fid);
