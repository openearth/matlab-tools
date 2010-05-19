function handles=ddb_readThdFile(handles)

m1=[];
m2=[];
n1=[];
n2=[];
uv=[];

[m1,n1,m2,n2,uv] = textread(handles.Model(md).Input(ad).ThdFile,'%f%f%f%f%s');

for i=1:length(m1)
    handles.Model(md).Input(ad).ThinDams(i).M1=m1(i);
    handles.Model(md).Input(ad).ThinDams(i).N1=n1(i);
    handles.Model(md).Input(ad).ThinDams(i).M2=m2(i);
    handles.Model(md).Input(ad).ThinDams(i).N2=n2(i);
    handles.Model(md).Input(ad).ThinDams(i).UV=uv{i};
end

handles.Model(md).Input(ad).NrThinDams=length(m1);
for i=1:length(m1)
    handles.Model(md).Input(ad).ThinDams(i).Name=['(' num2str(m1(i)) ',' num2str(n1(i)) ')...(' num2str(m2(i)) ',' num2str(n2(i)) ')'];
end
