function handles=ddb_readCrsFile(handles)

m1=[];
n1=[];
m2=[];
n2=[];
name=[];

[name,m1,n1,m2,n2] = textread(handles.Model(md).Input(ad).crsFile,'%21c%f%f%f%f');

for i=1:length(m1)
    handles.Model(md).Input(ad).crossSections(i).name=deblank(name(i,:));
    handles.Model(md).Input(ad).crossSections(i).M1=m1(i);
    handles.Model(md).Input(ad).crossSections(i).N1=n1(i);
    handles.Model(md).Input(ad).crossSections(i).M2=m2(i);
    handles.Model(md).Input(ad).crossSections(i).N2=n2(i);
    handles.Model(md).Input(ad).crossSectionNames{i}=handles.Model(md).Input(ad).crossSections(i).name;
end

handles.Model(md).Input(ad).nrCrossSections=length(m1);
