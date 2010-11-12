function handles=ddb_readBctFile(handles)

nr=handles.Model(md).Input(ad).NrOpenBoundaries;
kmax=handles.Model(md).Input(ad).KMax;

fname=handles.Model(md).Input(ad).BctFile;

Info=ddb_bct_io('read',fname);

for i=1:nr
    str{i}=handles.Model(md).Input(ad).OpenBoundaries(i).Name;
end

for i=1:Info.NTables
    kk=strmatch(lower(Info.Table(i).Location),lower(str),'exact');
    if length(kk)==1
        tab=Info.Table(i);
        itd=Info.Table(i).ReferenceTime;
        itd=datenum(num2str(itd),'yyyymmdd');
        t=itd+Info.Table(i).Data(:,1)/1440;
        handles.Model(md).Input(ad).OpenBoundaries(kk).TimeSeriesT=t;        
        switch lower(deblank(tab.Contents))
            case{'uniform','logarithmic'}
                handles.Model(md).Input(ad).OpenBoundaries(kk).TimeSeriesA=tab.Data(:,2);
                handles.Model(md).Input(ad).OpenBoundaries(kk).TimeSeriesB=tab.Data(:,3);               
            case{'3d-profile'}
                handles.Model(md).Input(ad).OpenBoundaries(kk).TimeSeriesA=tab.Data(:,2:kmax+1);
                handles.Model(md).Input(ad).OpenBoundaries(kk).TimeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
        end
    end
end
