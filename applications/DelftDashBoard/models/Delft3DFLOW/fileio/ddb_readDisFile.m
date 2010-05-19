function handles=ddb_readDisFile(handles,id)

Flow=handles.Model(md).Input(id);

fname=Flow.DisFile;

Info=ddb_bct_io('read',fname);

for n=1:Flow.NrDischarges

    nt=FindTable(Info,Flow.Discharges(n).Name);
    tab=Info.Table(nt);
    itd=tab.ReferenceTime;
    itd=datenum(num2str(itd),'yyyymmdd');
    t=itd+tab.Data(:,1)/1440;

    Flow.Discharges(n).TimeSeriesT=t;
    Flow.Discharges(n).TimeSeriesQ=zeros(size(t));
    Flow.Discharges(n).TimeSeriesM=zeros(size(t));
    Flow.Discharges(n).TimeSeriesD=zeros(size(t));
    Flow.Discharges(n).Salinity.TimeSeries=zeros(size(t));
    Flow.Discharges(n).Temperature.TimeSeries=zeros(size(t));

    for k=1:Flow.NrSediments
        Flow.Discharges(n).Sediment(k).TimeSeries=zeros(size(t));
    end
    for k=1:Flow.NrTracers
        Flow.Discharges(n).Tracer(k).TimeSeries=zeros(size(t));
    end

    Flow.Discharges(n).TimeSeriesQ=tab.Data(:,2);

    if Flow.Salinity.Include
        np=FindParameter(Info,nt,'Salinity');
        if np>0
            Flow.Discharges(n).Salinity.TimeSeries=tab.Data(:,np);
        end
    end
    if Flow.Temperature.Include
        np=FindParameter(Info,nt,'Temperature');
        if np>0
            Flow.Discharges(n).Temperature.TimeSeries=tab.Data(:,np);
        end
    end
    for k=1:Flow.NrSediments
        Flow.Discharges(n).Sediment(k).TimeSeries=zeros(size(t));
        np=FindParameter(Info,nt,Flow.Sediment(k).Name);        
        if np>0
            Flow.Discharges(n).Sediment(k).TimeSeries=tab.Data(:,np);
        end
    end
    for k=1:Flow.NrTracers
        Flow.Discharges(n).Tracer(k).TimeSeries=zeros(size(t));
        np=FindParameter(Info,nt,Flow.Tracer(k).Name);
        if np>0
            Flow.Discharges(n).Tracer(k).TimeSeries=tab.Data(:,np);
        end
    end
    if strcmpi(Flow.Discharges(n).Type,'momentum')
        np=FindParameter(Info,nt,'flow magnitude');
        if np>0
            Flow.Discharges(n).TimeSeriesM=tab.Data(:,np);
        end
        np=FindParameter(Info,nt,'flow direction');
        if np>0
            Flow.Discharges(n).TimeSeriesD=tab.Data(:,np);
        end
    end
end

handles.Model(md).Input(id)=Flow;

%%
function nt=FindTable(Info,bndname)

nt=0;
for i=1:Info.NTables
    if strcmpi(deblank(Info.Table(i).Location),bndname)
        nt=i;
    end
end

%%
function np=FindParameter(Info,nt,name)
np=0;
tab=Info.Table(nt);
npar=length(tab.Parameter);
for i=1:npar
    if strcmpi(name,tab.Parameter(i).Name)
        np=i;
    end
end
