function handles=ddb_readDroFile(handles,id)

[name,t1,t2,m,n] = textread(handles.Model(md).Input(id).droFile,'%21c%f%f%f%f');

handles.Model(md).Input(id).drogues=[];
handles.Model(md).Input(id).drogueNames={''};
for i=1:length(m)
    handles.Model(md).Input(id).drogues(i).name=deblank(name(i,:));
    handles.Model(md).Input(id).drogues(i).releaseTime=handles.Model(md).Input(id).itDate+t1(i)/1440;
    handles.Model(md).Input(id).drogues(i).recoveryTime=handles.Model(md).Input(id).itDate+t2(i)/1440;
    handles.Model(md).Input(id).drogues(i).M=m(i);
    handles.Model(md).Input(id).drogues(i).N=n(i);
    handles.Model(md).Input(id).drogueNames{i}=handles.Model(md).Input(id).drogues(i).name;
end

handles.Model(md).Input(id).nrDrogues=length(m);
