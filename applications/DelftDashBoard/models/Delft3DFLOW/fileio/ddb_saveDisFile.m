function ddb_saveDisFile(handles,id)

Flw=handles.Model(md).Input(id);

fname=Flw.DisFile;

nr=Flw.NrDischarges;

Info.Check='OK';
Info.FileName=fname;

Info.NTables=nr;

for n=1:nr
    
    switch lower(Flw.Discharges(n).Type)
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
    Info.Table(n).Location=Flw.Discharges(n).Name;
    Info.Table(n).TimeFunction='non-equidistant';
    itd=str2double(datestr(Flw.ItDate,'yyyymmdd'));
    Info.Table(n).ReferenceTime=itd;
    Info.Table(n).TimeUnit='minutes';
    Info.Table(n).Interpolation=Flw.Discharges(n).Interpolation;
    Info.Table(n).Parameter(1).Name='time';
    Info.Table(n).Parameter(1).Unit='[min]';
    t=Flw.Discharges(n).TimeSeriesT;
    t=(t-Flw.ItDate)*1440;
    Info.Table(n).Data(:,1)=t;
    Info.Table(n).Parameter(2).Name='flux/discharge rate';
    Info.Table(n).Parameter(2).Unit='[m3/s]';
    Info.Table(n).Data(:,2)=Flw.Discharges(n).TimeSeriesQ;

    k=2;

    if Flw.Salinity.Include
        k=k+1;
        Info.Table(n).Parameter(k).Name='Salinity';
        Info.Table(n).Parameter(k).Unit='[ppt]';
        Info.Table(n).Data(:,k)=Flw.Discharges(n).Salinity.TimeSeries;
    end
    if Flw.Temperature.Include
        k=k+1;
        Info.Table(n).Parameter(k).Name='Temperature';
        Info.Table(n).Parameter(k).Unit='[C]';
        Info.Table(n).Data(:,k)=Flw.Discharges(n).Temperature.TimeSeries;
    end
    if Flw.Sediments
        for i=1:Flw.NrSediments
            k=k+1;
            Info.Table(n).Parameter(k).Name=Flw.Sediment(i).Name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=Flw.Discharges(n).Sediment(i).TimeSeries;
        end
    end
    if Flw.Tracers
        for i=1:Flw.NrTracers
            k=k+1;
            Info.Table(n).Parameter(k).Name=Flw.Tracer(i).Name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=Flw.Discharges(n).Tracer(i).TimeSeries;
        end
    end
    if strcmpi(Flw.Discharges(n).Type,'momentum')
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow magnitude';
        Info.Table(n).Parameter(k).Unit='[m/s]';
        Info.Table(n).Data(:,k)=Flw.Discharges(n).TimeSeriesM;
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow direction';
        Info.Table(n).Parameter(k).Unit='[deg]';
        Info.Table(n).Data(:,k)=Flw.Discharges(n).TimeSeriesM;
    end
    
    npar=length(Info.Table(n).Parameter);
    for i=1:npar
        quant=deblank(Info.Table(n).Parameter(i).Name);
        quant=[quant repmat(' ',1,20-length(quant))];
        Info.Table(n).Parameter(i).Name=quant;
    end
    
end
ddb_bct_io('write',fname,Info);

