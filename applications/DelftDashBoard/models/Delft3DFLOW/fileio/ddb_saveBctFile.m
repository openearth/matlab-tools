function ddb_saveBctFile(handles,id)

fname=handles.Model(md).Input(id).BctFile;

nr=handles.Model(md).Input(id).NrOpenBoundaries;
kmax=handles.Model(md).Input(id).KMax;

Info.Check='OK';
Info.FileName=fname;

k=0;
for n=1:nr
    if handles.Model(md).Input(id).OpenBoundaries(n).Forcing=='T'
        k=k+1;
        Info.NTables=k;
        Info.Table(k).Name=['Boundary Section : ' num2str(n)];
        Info.Table(k).Contents=lower(handles.Model(md).Input(id).OpenBoundaries(n).Profile);
        Info.Table(k).Location=handles.Model(md).Input(id).OpenBoundaries(n).Name;
        Info.Table(k).TimeFunction='non-equidistant';
        itd=str2double(datestr(handles.Model(md).Input(id).ItDate,'yyyymmdd'));
        Info.Table(k).ReferenceTime=itd;
        Info.Table(k).TimeUnit='minutes';
        Info.Table(k).Interpolation='linear';
        Info.Table(k).Parameter(1).Name='time';
        Info.Table(k).Parameter(1).Unit='[min]';
        switch handles.Model(md).Input(id).OpenBoundaries(n).Type,
            case{'Z'}
                quant='Water elevation (Z)  ';
                unit='[m]';
            case{'C'}
                quant='Current         (C)  ';
                unit='[m/s]';
            case{'N'}
                quant='Neumann         (N)  ';
                unit='[-]';
            case{'T'}
                quant='Total discharge (T)  ';
                unit='[m3/s]';
            case{'Q'}
                quant='Flux/discharge  (Q)  ';
                unit='[m3/s]';
            case{'R'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
        end
        t=(handles.Model(md).Input(id).OpenBoundaries(n).TimeSeriesT-handles.Model(md).Input(id).ItDate)*1440;
        Info.Table(k).Data(:,1)=t;
        switch lower(handles.Model(md).Input(id).OpenBoundaries(n).Profile)
            case{'uniform','logarithmic'}
                Info.Table(k).Parameter(2).Name=[quant 'End A uniform'];
                Info.Table(k).Parameter(2).Unit=unit;
                Info.Table(k).Parameter(3).Name=[quant 'End B uniform'];
                Info.Table(k).Parameter(3).Unit=unit;
                Info.Table(k).Data(:,2)=handles.Model(md).Input(id).OpenBoundaries(n).TimeSeriesA;
                Info.Table(k).Data(:,3)=handles.Model(md).Input(id).OpenBoundaries(n).TimeSeriesB;
            case{'3d-profile'}
                j=1;
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Parameter(j).Name=[quant 'End A layer: ' num2str(kk)];
                    Info.Table(k).Parameter(j).Unit=unit;
                end
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Parameter(j).Name=[quant 'End B layer: ' num2str(kk)];
                    Info.Table(k).Parameter(j).Unit=unit;
                end
                j=1;
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Data(:,j)=handles.Model(md).Input(id).OpenBoundaries(n).TimeSeriesA(:,kk);
                end
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Data(:,j)=handles.Model(md).Input(id).OpenBoundaries(n).TimeSeriesB(:,kk);
                end
        end
    end
end
ddb_bct_io('write',fname,Info);
