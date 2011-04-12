function delft3dflow_saveBctFile(flow,openBoundaries,fname)

%fname=Flow.BctFile;

nr=length(openBoundaries);
kmax=flow.KMax;

Info.Check='OK';
Info.FileName=fname;

k=0;
for n=1:nr
    quant2=[];
    unit2=[];
    if openBoundaries(n).forcing=='T'
        k=k+1;
        Info.NTables=k;
        Info.Table(k).Name=['Boundary Section : ' num2str(n)];
        Info.Table(k).Contents=lower(openBoundaries(n).profile);
        Info.Table(k).Location=openBoundaries(n).name;
        Info.Table(k).TimeFunction='non-equidistant';
        itd=str2double(datestr(flow.itDate,'yyyymmdd'));
        Info.Table(k).ReferenceTime=itd;
        Info.Table(k).TimeUnit='minutes';
        Info.Table(k).Interpolation='linear';
        Info.Table(k).Parameter(1).Name='time';
        Info.Table(k).Parameter(1).Unit='[min]';
        switch openBoundaries(n).type,
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
            case{'X'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
            case{'P'}
                quant='Current         (C)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
        end
        t=(openBoundaries(n).timeSeriesT-flow.itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        switch lower(openBoundaries(n).profile)
            case{'uniform','logarithmic'}
                Info.Table(k).Parameter(2).Name=[quant 'End A uniform'];
                Info.Table(k).Parameter(2).Unit=unit;
                Info.Table(k).Parameter(3).Name=[quant 'End B uniform'];
                Info.Table(k).Parameter(3).Unit=unit;
                Info.Table(k).Data(:,2)=openBoundaries(n).timeSeriesA;
                Info.Table(k).Data(:,3)=openBoundaries(n).timeSeriesB;
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
                if ~isempty(quant2)
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Parameter(j).Name=[quant2 'End A layer: ' num2str(kk)];
                        Info.Table(k).Parameter(j).Unit=unit2;
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Parameter(j).Name=[quant2 'End B layer: ' num2str(kk)];
                        Info.Table(k).Parameter(j).Unit=unit2;
                    end
                end
                j=1;
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Data(:,j)=openBoundaries(n).timeSeriesA(:,kk);
                end
                for kk=1:kmax
                    j=j+1;
                    Info.Table(k).Data(:,j)=openBoundaries(n).timeSeriesB(:,kk);
                end
                if ~isempty(quant2)
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Data(:,j)=openBoundaries(n).timeSeriesAV(:,kk);
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Data(:,j)=openBoundaries(n).timeSeriesBV(:,kk);
                    end
                end
        end
    end
end
ddb_bct_io('write',fname,Info);
