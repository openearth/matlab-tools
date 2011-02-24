function handles=ddb_readObsFile(handles)

[name,m,n] = textread(handles.Model(md).Input(ad).obsFile,'%21c%f%f');

for i=1:length(m)
    handles.Model(md).Input(ad).observationPoints(i).name=deblank(name(i,:));
    handles.Model(md).Input(ad).observationPoints(i).M=m(i);
    handles.Model(md).Input(ad).observationPoints(i).N=n(i);
    handles.Model(md).Input(ad).observationPoints(i).x=handles.Model(md).Input(ad).gridXZ(m(i),n(i));
    handles.Model(md).Input(ad).observationPoints(i).y=handles.Model(md).Input(ad).gridYZ(m(i),n(i));
    handles.Model(md).Input(ad).observationPointNames{i}=handles.Model(md).Input(ad).observationPoints(i).name;
end

handles.Model(md).Input(ad).nrObservationPoints=length(m);
