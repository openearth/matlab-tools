function handles=ddb_readDisFile(handles,id)

Flow=handles.Model(md).Input(id);

fname=Flow.disFile;

Info=ddb_bct_io('read',fname);

for n=1:Flow.nrDischarges

    nt=FindTable(Info,Flow.discharges(n).name);
    tab=Info.Table(nt);
    itd=tab.ReferenceTime;
    itd=datenum(num2str(itd),'yyyymmdd');
    t=itd+tab.Data(:,1)/1440;

    Flow.discharges(n).timeSeriesT=t;
    Flow.discharges(n).timeSeriesQ=zeros(size(t));
    Flow.discharges(n).timeSeriesM=zeros(size(t));
    Flow.discharges(n).timeSeriesD=zeros(size(t));
    Flow.discharges(n).salinity.timeSeries=zeros(size(t));
    Flow.discharges(n).temperature.timeSeries=zeros(size(t));

    for k=1:Flow.nrSediments
        Flow.discharges(n).sediment(k).timeSeries=zeros(size(t));
    end
    for k=1:Flow.nrTracers
        Flow.discharges(n).tracer(k).timeSeries=zeros(size(t));
    end

    Flow.discharges(n).timeSeriesQ=tab.Data(:,2);

    if Flow.salinity.include
        np=findParameter(Info,nt,'Salinity');
        if np>0
            Flow.discharges(n).salinity.timeSeries=tab.Data(:,np);
        end
    end
    if Flow.temperature.include
        np=findParameter(Info,nt,'Temperature');
        if np>0
            Flow.discharges(n).temperature.timeSeries=tab.Data(:,np);
        end
    end
    for k=1:Flow.nrSediments
        Flow.discharges(n).sediment(k).timeSeries=zeros(size(t));
        np=findParameter(Info,nt,Flow.Sediment(k).Name);        
        if np>0
            Flow.discharges(n).Sediment(k).timeSeries=tab.Data(:,np);
        end
    end
    for k=1:Flow.nrTracers
        Flow.discharges(n).tracer(k).timeSeries=zeros(size(t));
        np=findParameter(Info,nt,Flow.tracer(k).name);
        if np>0
            Flow.discharges(n).tracer(k).timeSeries=tab.Data(:,np);
        end
    end
    if strcmpi(Flow.discharges(n).type,'momentum')
        np=findParameter(Info,nt,'flow magnitude');
        if np>0
            Flow.discharges(n).timeSeriesM=tab.Data(:,np);
        end
        np=findParameter(Info,nt,'flow direction');
        if np>0
            Flow.discharges(n).timeSeriesD=tab.Data(:,np);
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
function np=findParameter(Info,nt,name)
np=0;
tab=Info.Table(nt);
npar=length(tab.Parameter);
for i=1:npar
    if strcmpi(name,tab.Parameter(i).Name)
        np=i;
    end
end
