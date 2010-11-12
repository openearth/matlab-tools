function handles=ddb_readDroFile(handles)

[name,t1,t2,m,n] = textread(handles.Model(md).Input(ad).DroFile,'%21c%f%f%f%f');

for i=1:length(m)
    handles.Model(md).Input(ad).Drogues(i).Name=deblank(name(i,:));
    handles.Model(md).Input(ad).Drogues(i).ReleaseTime=handles.Model(md).Input(ad).ItDate+t1(i)/1440;
    handles.Model(md).Input(ad).Drogues(i).RecoveryTime=handles.Model(md).Input(ad).ItDate+t2(i)/1440;
    handles.Model(md).Input(ad).Drogues(i).M=m(i);
    handles.Model(md).Input(ad).Drogues(i).N=n(i);
end

handles.Model(md).Input(ad).NrDrogues=length(m);
