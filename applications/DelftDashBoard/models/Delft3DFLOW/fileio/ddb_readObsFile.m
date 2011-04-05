function handles=ddb_readObsFile(handles,id)

[name,m,n] = textread(handles.Model(md).Input(id).obsFile,'%21c%f%f');

for i=1:length(m)
    handles.Model(md).Input(id).observationPoints(i).name=deblank(name(i,:));
    handles.Model(md).Input(id).observationPoints(i).M=m(i);
    handles.Model(md).Input(id).observationPoints(i).N=n(i);
    handles.Model(md).Input(id).observationPoints(i).x=handles.Model(md).Input(id).gridXZ(m(i),n(i));
    handles.Model(md).Input(id).observationPoints(i).y=handles.Model(md).Input(id).gridYZ(m(i),n(i));
    handles.Model(md).Input(id).observationPointNames{i}=handles.Model(md).Input(id).observationPoints(i).name;
end

handles.Model(md).Input(id).nrObservationPoints=length(m);
