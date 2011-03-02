function handles=ddb_readCrsFile(handles,id)

m1=[];
n1=[];
m2=[];
n2=[];
name=[];

[name,m1,n1,m2,n2] = textread(handles.Model(md).Input(id).crsFile,'%21c%f%f%f%f');

for i=1:length(m1)
    handles.Model(md).Input(id).crossSections(i).name=deblank(name(i,:));
    handles.Model(md).Input(id).crossSections(i).M1=m1(i);
    handles.Model(md).Input(id).crossSections(i).N1=n1(i);
    handles.Model(md).Input(id).crossSections(i).M2=m2(i);
    handles.Model(md).Input(id).crossSections(i).N2=n2(i);
    handles.Model(md).Input(id).crossSectionNames{i}=handles.Model(md).Input(id).crossSections(i).name;
end

handles.Model(md).Input(id).nrCrossSections=length(m1);
