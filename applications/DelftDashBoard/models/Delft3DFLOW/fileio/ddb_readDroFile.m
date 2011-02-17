function handles=ddb_readDroFile(handles)

[name,t1,t2,m,n] = textread(handles.Model(md).Input(ad).droFile,'%21c%f%f%f%f');

for i=1:length(m)
    handles.Model(md).Input(ad).drogues(i).name=deblank(name(i,:));
    handles.Model(md).Input(ad).drogues(i).releaseTime=handles.Model(md).Input(ad).itDate+t1(i)/1440;
    handles.Model(md).Input(ad).drogues(i).recoveryTime=handles.Model(md).Input(ad).itDate+t2(i)/1440;
    handles.Model(md).Input(ad).drogues(i).M=m(i);
    handles.Model(md).Input(ad).drogues(i).N=n(i);
end

handles.Model(md).Input(ad).nrDrogues=length(m);
