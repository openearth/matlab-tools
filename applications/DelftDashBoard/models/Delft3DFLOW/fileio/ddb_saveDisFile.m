function ddb_saveDisFile(handles,id)

Flw=handles.Model(md).Input(id);

fname=Flw.disFile;

nr=Flw.nrDischarges;

Info.Check='OK';
Info.FileName=fname;

Info.NTables=nr;

for n=1:nr
    
    switch lower(Flw.discharges(n).type)
        case{'normal'}
            tp='regular';
        case{'walking'}
            tp='walking';
        case{'momentum'}
            tp='momentum';
        case{'in-out'}
            tp='inoutlet';
    end
    Info.Table(n).Name=['Discharge : ' num2str(n)];
    Info.Table(n).Contents=tp;
    Info.Table(n).Location=Flw.discharges(n).name;
    Info.Table(n).TimeFunction='non-equidistant';
    itd=str2double(datestr(Flw.itDate,'yyyymmdd'));
    Info.Table(n).ReferenceTime=itd;
    Info.Table(n).TimeUnit='minutes';
    Info.Table(n).Interpolation=Flw.discharges(n).interpolation;
    Info.Table(n).Parameter(1).Name='time';
    Info.Table(n).Parameter(1).Unit='[min]';
    t=Flw.discharges(n).timeSeriesT;
    t=(t-Flw.itDate)*1440;
    Info.Table(n).Data(:,1)=t;
    Info.Table(n).Parameter(2).Name='flux/discharge rate';
    Info.Table(n).Parameter(2).Unit='[m3/s]';
    Info.Table(n).Data(:,2)=Flw.discharges(n).timeSeriesQ;

    k=2;

    if Flw.salinity.include
        k=k+1;
        Info.Table(n).Parameter(k).Name='Salinity';
        Info.Table(n).Parameter(k).Unit='[ppt]';
        Info.Table(n).Data(:,k)=Flw.discharges(n).salinity.timeSeries;
    end
    if Flw.temperature.include
        k=k+1;
        Info.Table(n).Parameter(k).Name='Temperature';
        Info.Table(n).Parameter(k).Unit='[C]';
        Info.Table(n).Data(:,k)=Flw.discharges(n).temperature.timeSeries;
    end
    if Flw.sediments.include
        for i=1:Flw.nrSediments
            k=k+1;
            Info.Table(n).Parameter(k).Name=Flw.sediment(i).name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=Flw.discharges(n).sediment(i).timeSeries;
        end
    end
    if Flw.tracers
        for i=1:Flw.nrTracers
            k=k+1;
            Info.Table(n).Parameter(k).Name=Flw.tracer(i).name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=Flw.discharges(n).tracer(i).timeSeries;
        end
    end
    if strcmpi(Flw.discharges(n).Type,'momentum')
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow magnitude';
        Info.Table(n).Parameter(k).Unit='[m/s]';
        Info.Table(n).Data(:,k)=Flw.discharges(n).timeSeriesM;
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow direction';
        Info.Table(n).Parameter(k).Unit='[deg]';
        Info.Table(n).Data(:,k)=Flw.discharges(n).timeSeriesM;
    end
    
    npar=length(Info.Table(n).Parameter);
    for i=1:npar
        quant=deblank(Info.Table(n).Parameter(i).Name);
        quant=[quant repmat(' ',1,20-length(quant))];
        Info.Table(n).Parameter(i).Name=quant;
    end
    
end
ddb_bct_io('write',fname,Info);

