function handles=ddb_readBctFile(handles)

nr=handles.Model(md).Input(ad).nrOpenBoundaries;
kmax=handles.Model(md).Input(ad).KMax;

fname=handles.Model(md).Input(ad).bctFile;

Info=ddb_bct_io('read',fname);

for i=1:nr
    str{i}=handles.Model(md).Input(ad).openBoundaries(i).name;
end

for i=1:Info.NTables
    kk=strmatch(lower(Info.Table(i).Location),lower(str),'exact');
    if length(kk)==1
        tab=Info.Table(i);
        itd=Info.Table(i).ReferenceTime;
        itd=datenum(num2str(itd),'yyyymmdd');
        t=itd+Info.Table(i).Data(:,1)/1440;
        handles.Model(md).Input(ad).openBoundaries(kk).timeSeriesT=t;        
        switch lower(deblank(tab.Contents))
            case{'uniform','logarithmic'}
                handles.Model(md).Input(ad).openBoundaries(kk).timeSeriesA=tab.Data(:,2);
                handles.Model(md).Input(ad).openBoundaries(kk).timeSeriesB=tab.Data(:,3);               
            case{'3d-profile'}
                handles.Model(md).Input(ad).openBoundaries(kk).timeSeriesA=tab.Data(:,2:kmax+1);
                handles.Model(md).Input(ad).openBoundaries(kk).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
        end
    end
end
