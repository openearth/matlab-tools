function handles=ddb_readThdFile(handles,id)

m1=[];
m2=[];
n1=[];
n2=[];
uv=[];

[m1,n1,m2,n2,uv] = textread(handles.Model(md).Input(id).thdFile,'%f%f%f%f%s');

for i=1:length(m1)
    handles.Model(md).Input(id).thinDams(i).M1=m1(i);
    handles.Model(md).Input(id).thinDams(i).N1=n1(i);
    handles.Model(md).Input(id).thinDams(i).M2=m2(i);
    handles.Model(md).Input(id).thinDams(i).N2=n2(i);
    handles.Model(md).Input(id).thinDams(i).UV=uv{i};
end

handles.Model(md).Input(id).nrThinDams=length(m1);
for i=1:length(m1)
    handles.Model(md).Input(id).thinDams(i).name=['(' num2str(m1(i)) ',' num2str(n1(i)) ')...(' num2str(m2(i)) ',' num2str(n2(i)) ')'];
    handles.Model(md).Input(id).thinDamNames{i}=handles.Model(md).Input(id).thinDams(i).name;
end
