function handles=ddb_readBctFile(handles,id)

nr=handles.Model(md).Input(id).nrOpenBoundaries;
kmax=handles.Model(md).Input(id).KMax;

fname=handles.Model(md).Input(id).bctFile;

Info=ddb_bct_io('read',fname);

for i=1:nr
    str{i}=handles.Model(md).Input(id).openBoundaries(i).name;
end

for i=1:Info.NTables
    kk=strmatch(lower(Info.Table(i).Location),lower(str),'exact');
    if length(kk)==1
        tab=Info.Table(i);
        itd=Info.Table(i).ReferenceTime;
        itd=datenum(num2str(itd),'yyyymmdd');
        t=itd+Info.Table(i).Data(:,1)/1440;
        handles.Model(md).Input(id).openBoundaries(kk).timeSeriesT=t;        
        switch lower(deblank(tab.Contents))
            case{'uniform','logarithmic'}
                handles.Model(md).Input(id).openBoundaries(kk).timeSeriesA=tab.Data(:,2);
                handles.Model(md).Input(id).openBoundaries(kk).timeSeriesB=tab.Data(:,3);               
            case{'3d-profile'}
                handles.Model(md).Input(id).openBoundaries(kk).timeSeriesA=tab.Data(:,2:kmax+1);
                handles.Model(md).Input(id).openBoundaries(kk).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
        end
    end
end
