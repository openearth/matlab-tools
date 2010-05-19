function handles=ddb_readCrsFile(handles)

m1=[];
n1=[];
m2=[];
n2=[];
name=[];

[name,m1,n1,m2,n2] = textread(handles.Model(md).Input(ad).CrsFile,'%21c%f%f%f%f');

for i=1:length(m1)
    handles.Model(md).Input(ad).CrossSections(i).Name=deblank(name(i,:));
    handles.Model(md).Input(ad).CrossSections(i).M1=m1(i);
    handles.Model(md).Input(ad).CrossSections(i).N1=n1(i);
    handles.Model(md).Input(ad).CrossSections(i).M2=m2(i);
    handles.Model(md).Input(ad).CrossSections(i).N2=n2(i);
end

handles.Model(md).Input(ad).NrCrossSections=length(m1);
