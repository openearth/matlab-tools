function ddb_saveBccFile(handles,id)

Flw=handles.Model(md).Input(id);

fname=Flw.BccFile;

nr=Flw.NrOpenBoundaries;

Info.Check='OK';
Info.FileName=fname;

kmax=Flw.KMax;

k=0;
for n=1:nr
    if Flw.Salinity.Include
        k=k+1;
        Info=SetInfo(Info,Flw.ItDate,Flw.OpenBoundaries(n),Flw.OpenBoundaries(n).Salinity,'Salinity','[ppt]',k,n,kmax);
    end
    if Flw.Temperature.Include
        k=k+1;
        Info=SetInfo(Info,Flw.ItDate,Flw.OpenBoundaries(n),Flw.OpenBoundaries(n).Temperature,'Temperature','[C]',k,n,kmax);
    end
    if Flw.Sediments
        for i=1:Flw.NrSediments
            k=k+1;
            Info=SetInfo(Info,Flw.ItDate,Flw.OpenBoundaries(n),Flw.OpenBoundaries(n).Sediment(i),Flw.Sediment(i).Name,'[kg/m3]',k,n,kmax);
        end
    end
    if Flw.Tracers
        for i=1:Flw.NrTracers
            k=k+1;
            Info=SetInfo(Info,Flw.ItDate,Flw.OpenBoundaries(n),Flw.OpenBoundaries(n).Tracer(i),Flw.Tracer(i).Name,'[kg/m3]',k,n,kmax);
        end
    end
end
ddb_bct_io('write',fname,Info);

function Info=SetInfo(Info,ItDate,Bnd,Par,quant,unit,k,nr,kmax)
Info.NTables=k;
Info.Table(k).Name=['Boundary Section : ' num2str(nr)];
Info.Table(k).Contents=lower(Par.Profile);
Info.Table(k).Location=Bnd.Name;
Info.Table(k).TimeFunction='non-equidistant';
itd=str2double(datestr(ItDate,'yyyymmdd'));
Info.Table(k).ReferenceTime=itd;
Info.Table(k).TimeUnit='minutes';
Info.Table(k).Interpolation='linear';
Info.Table(k).Parameter(1).Name='time';
Info.Table(k).Parameter(1).Unit='[min]';
quant=deblank(quant);
quant=[quant repmat(' ',1,21-length(quant))];

switch lower(Par.Profile)
    case{'uniform'}
        Info.Table(k).Parameter(2).Name=[quant 'end A uniform'];
        Info.Table(k).Parameter(2).Unit=unit;
        Info.Table(k).Parameter(3).Name=[quant 'end B uniform'];
        Info.Table(k).Parameter(3).Unit=unit;
        t=(Par.TimeSeriesT-ItDate)*1440;
        Info.Table(k).Data(:,1)=t;
        Info.Table(k).Data(:,2)=Par.TimeSeriesA;
        Info.Table(k).Data(:,3)=Par.TimeSeriesB;
    case{'step','linear'}
        Info.Table(k).Parameter(2).Name=[quant 'end A surface'];
        Info.Table(k).Parameter(2).Unit=unit;
        Info.Table(k).Parameter(3).Name=[quant 'end A bed'];
        Info.Table(k).Parameter(3).Unit=unit;
        Info.Table(k).Parameter(4).Name=[quant 'end B surface'];
        Info.Table(k).Parameter(4).Unit=unit;
        Info.Table(k).Parameter(5).Name=[quant 'end B bed'];
        Info.Table(k).Parameter(5).Unit=unit;
        if strcmpi(deblank(lower(Par.Profile)),'step')
            Info.Table(k).Parameter(6).Name='discontinuity';
            Info.Table(k).Parameter(6).Unit='[m]';
        end
        t=(Par.TimeSeriesT-ItDate)*1440;
        Info.Table(k).Data(:,1)=t;
        Info.Table(k).Data(:,2)=Par.TimeSeriesA(:,1);
        Info.Table(k).Data(:,3)=Par.TimeSeriesA(:,2);
        Info.Table(k).Data(:,4)=Par.TimeSeriesB(:,1);
        Info.Table(k).Data(:,5)=Par.TimeSeriesB(:,2);
        if strcmpi(deblank(lower(Par.Profile)),'step')
            dis=zeros(Par.NrTimeSeries,1)+Par.Discontinuity;
            Info.Table(k).Data(:,6)=dis;
        end
    case{'3d-profile'}
        j=1;
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Parameter(j).Name=[quant 'end A layer ' num2str(kk)];
            Info.Table(k).Parameter(j).Unit=unit;
        end
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Parameter(j).Name=[quant 'end B layer ' num2str(kk)];
            Info.Table(k).Parameter(j).Unit=unit;
        end
        t=(Par.TimeSeriesT-ItDate)*1440;
        Info.Table(k).Data(:,1)=t;
        j=1;
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Data(:,j)=Par.TimeSeriesA(:,kk);
        end
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Data(:,j)=Par.TimeSeriesB(:,kk);
        end
end
