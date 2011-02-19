function ddb_saveBccFile(handles,id)

Flw=handles.Model(md).Input(id);

fname=Flw.bccFile;

nr=Flw.nrOpenBoundaries;

Info.Check='OK';
Info.FileName=fname;

kmax=Flw.KMax;

k=0;
for n=1:nr
    if Flw.salinity.include
        k=k+1;
        Info=SetInfo(Info,Flw.itDate,Flw.openBoundaries(n),Flw.openBoundaries(n).salinity,'Salinity','[ppt]',k,n,kmax);
    end
    if Flw.temperature.include
        k=k+1;
        Info=SetInfo(Info,Flw.itDate,Flw.openBoundaries(n),Flw.openBoundaries(n).temperature,'Temperature','[C]',k,n,kmax);
    end
    if Flw.sediments.include
        for i=1:Flw.nrSediments
            k=k+1;
            Info=SetInfo(Info,Flw.itDate,Flw.openBoundaries(n),Flw.openBoundaries(n).sediment(i),Flw.sediment(i).name,'[kg/m3]',k,n,kmax);
        end
    end
    if Flw.tracers
        for i=1:Flw.nrTracers
            k=k+1;
            Info=SetInfo(Info,Flw.itDate,Flw.openBoundaries(n),Flw.openBoundaries(n).tracer(i),Flw.tracer(i).name,'[kg/m3]',k,n,kmax);
        end
    end
end
ddb_bct_io('write',fname,Info);

function Info=SetInfo(Info,itDate,Bnd,Par,quant,unit,k,nr,kmax)
Info.NTables=k;
Info.Table(k).Name=['Boundary Section : ' num2str(nr)];
Info.Table(k).Contents=lower(Par.profile);
Info.Table(k).Location=Bnd.name;
Info.Table(k).TimeFunction='non-equidistant';
itd=str2double(datestr(itDate,'yyyymmdd'));
Info.Table(k).ReferenceTime=itd;
Info.Table(k).TimeUnit='minutes';
Info.Table(k).Interpolation='linear';
Info.Table(k).Parameter(1).Name='time';
Info.Table(k).Parameter(1).Unit='[min]';
quant=deblank(quant);
quant=[quant repmat(' ',1,21-length(quant))];

switch lower(Par.profile)
    case{'uniform'}
        Info.Table(k).Parameter(2).Name=[quant 'end A uniform'];
        Info.Table(k).Parameter(2).Unit=unit;
        Info.Table(k).Parameter(3).Name=[quant 'end B uniform'];
        Info.Table(k).Parameter(3).Unit=unit;
        t=(Par.timeSeriesT-itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        Info.Table(k).Data(:,2)=Par.timeSeriesA;
        Info.Table(k).Data(:,3)=Par.timeSeriesB;
    case{'step','linear'}
        Info.Table(k).Parameter(2).Name=[quant 'end A surface'];
        Info.Table(k).Parameter(2).Unit=unit;
        Info.Table(k).Parameter(3).Name=[quant 'end A bed'];
        Info.Table(k).Parameter(3).Unit=unit;
        Info.Table(k).Parameter(4).Name=[quant 'end B surface'];
        Info.Table(k).Parameter(4).Unit=unit;
        Info.Table(k).Parameter(5).Name=[quant 'end B bed'];
        Info.Table(k).Parameter(5).Unit=unit;
        if strcmpi(deblank(lower(Par.profile)),'step')
            Info.Table(k).Parameter(6).Name='discontinuity';
            Info.Table(k).Parameter(6).Unit='[m]';
        end
        t=(Par.timeSeriesT-itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        Info.Table(k).Data(:,2)=Par.timeSeriesA(:,1);
        Info.Table(k).Data(:,3)=Par.timeSeriesA(:,2);
        Info.Table(k).Data(:,4)=Par.timeSeriesB(:,1);
        Info.Table(k).Data(:,5)=Par.timeSeriesB(:,2);
        if strcmpi(deblank(lower(Par.profile)),'step')
            dis=zeros(Par.nrTimeSeries,1)+Par.discontinuity;
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
        t=(Par.TimeSeriesT-itDate)*1440;
        Info.Table(k).Data(:,1)=t;
        j=1;
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Data(:,j)=Par.timeSeriesA(:,kk);
        end
        for kk=1:kmax
            j=j+1;
            Info.Table(k).Data(:,j)=Par.timeSeriesB(:,kk);
        end
end
