function handles=ddb_readDryFile(handles)

m1=[];
m2=[];
n1=[];
n2=[];

dat=load(handles.Model(md).Input(ad).DryFile);

m1=dat(:,1);
n1=dat(:,2);
m2=dat(:,3);
n2=dat(:,4);

for i=1:length(m1);
    handles.Model(md).Input(ad).DryPoints(i).M1=m1(i);
    handles.Model(md).Input(ad).DryPoints(i).N1=n1(i);
    handles.Model(md).Input(ad).DryPoints(i).M2=m2(i);
    handles.Model(md).Input(ad).DryPoints(i).N2=n2(i);
    handles.Model(md).Input(ad).DryPoints(i).Name=['(' num2str(m1(i)) ',' num2str(n1(i)) ')...(' num2str(m2(i)) ',' num2str(n2(i)) ')'];
end
handles.Model(md).Input(ad).nrDryPoints=length(m1);
