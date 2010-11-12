function handles=ddb_readBccFile(handles)

Flow=handles.Model(md).Input(ad);

kmax=Flow.KMax;

fname=Flow.BccFile;

Info=ddb_bct_io('read',fname);

for nb=1:Flow.NrOpenBoundaries
    if Flow.Salinity.Include
        nt=FindTable(Info,Flow.OpenBoundaries(nb).Name,'Salinity');
        if nt>0
            tab=Info.Table(nt);
            itd=tab.ReferenceTime;
            itd=datenum(num2str(itd),'yyyymmdd');
            t=itd+tab.Data(:,1)/1440;
            Flow.OpenBoundaries(nb).Salinity.TimeSeriesT=t;
            switch lower(deblank(tab.Contents))
                case{'uniform'}
                    Flow.OpenBoundaries(nb).Salinity.TimeSeriesA=tab.Data(:,2);
                    Flow.OpenBoundaries(nb).Salinity.TimeSeriesB=tab.Data(:,3);
                    Flow.OpenBoundaries(nb).Salinity.Profile='Uniform';
                case{'step'}
                    Flow.OpenBoundaries(nb).Salinity.TimeSeriesA=tab.Data(:,2);
                    Flow.OpenBoundaries(nb).Salinity.TimeSeriesB=tab.Data(:,3);
                    Flow.OpenBoundaries(nb).Salinity.Discontinuity=tab.Data(:,4);
                    Flow.OpenBoundaries(nb).Salinity.Profile='Step';
                case{'3d-profile'}
                    Flow.OpenBoundaries(nb).Salinity.TimeSeriesA=tab.Data(:,2:kmax+1);
                    Flow.OpenBoundaries(nb).Salinity.TimeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                    Flow.OpenBoundaries(nb).Salinity.Profile='3d-profile';
            end
        else
%             GiveWarning('text',['No data found in bcc file for boundary ' Flow.OpenBoundaries(nb).Name ' parameter: Salinity']);
            t=[Flow.StartTime;Flow.StopTime];
            Flow.OpenBoundaries(nb).Salinity.TimeSeriesT=t;
            Flow.OpenBoundaries(nb).Salinity.TimeSeriesA=[0;0];
            Flow.OpenBoundaries(nb).Salinity.TimeSeriesB=[0;0];
            Flow.OpenBoundaries(nb).Salinity.Profile='Uniform';
        end
    end
    if Flow.Temperature.Include
        nt=FindTable(Info,Flow.OpenBoundaries(nb).Name,'Temperature');
        if nt>0
            tab=Info.Table(nt);
            itd=tab.ReferenceTime;
            itd=datenum(num2str(itd),'yyyymmdd');
            t=itd+tab.Data(:,1)/1440;
            Flow.OpenBoundaries(nb).Temperature.TimeSeriesT=t;
            switch lower(deblank(tab.Contents))
                case{'uniform'}
                    Flow.OpenBoundaries(nb).Temperature.TimeSeriesA=tab.Data(:,2);
                    Flow.OpenBoundaries(nb).Temperature.TimeSeriesB=tab.Data(:,3);
                    Flow.OpenBoundaries(nb).Temperature.Profile='Uniform';
                case{'step'}
                    Flow.OpenBoundaries(nb).Temperature.TimeSeriesA=tab.Data(:,2);
                    Flow.OpenBoundaries(nb).Temperature.TimeSeriesB=tab.Data(:,3);
                    Flow.OpenBoundaries(nb).Temperature.Discontinuity=tab.Data(:,4);
                    Flow.OpenBoundaries(nb).Temperature.Profile='Step';
                case{'3d-profile'}
                    Flow.OpenBoundaries(nb).Temperature.TimeSeriesA=tab.Data(:,2:kmax+1);
                    Flow.OpenBoundaries(nb).Temperature.TimeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                    Flow.OpenBoundaries(nb).Temperature.Profile='3d-profile';
            end
        else
%             GiveWarning('text',['No data found in bcc file for boundary ' Flow.OpenBoundaries(nb).Name ' parameter: Temperature']);
            t=[Flow.StartTime;Flow.StopTime];
            Flow.OpenBoundaries(nb).Temperature.TimeSeriesT=t;
            Flow.OpenBoundaries(nb).Temperature.TimeSeriesA=[0;0];
            Flow.OpenBoundaries(nb).Temperature.TimeSeriesB=[0;0];
            Flow.OpenBoundaries(nb).Temperature.Profile='Uniform';
        end
    end
    if Flow.Sediments
        for j=1:Flow.NrSediments
            nt=FindTable(Info,Flow.OpenBoundaries(nb).Name,Flow.Sediment(j).Name);
            if nt>0
                tab=Info.Table(nt);
                itd=tab.ReferenceTime;
                itd=datenum(num2str(itd),'yyyymmdd');
                t=itd+tab.Data(:,1)/1440;
                Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesT=t;
                switch lower(deblank(tab.Contents))
                    case{'uniform'}
                        Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesA=tab.Data(:,2);
                        Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesB=tab.Data(:,3);
                        Flow.OpenBoundaries(nb).Sediment(j).Profile='Uniform';
                    case{'step'}
                        Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesA=tab.Data(:,2);
                        Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesB=tab.Data(:,3);
                        Flow.OpenBoundaries(nb).Sediment(j).Discontinuity=tab.Data(:,4);
                        Flow.OpenBoundaries(nb).Sediment(j).Profile='Step';
                    case{'3d-profile'}
                        Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesA=tab.Data(:,2:kmax+1);
                        Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                        Flow.OpenBoundaries(nb).Sediment(j).Profile='3d-profile';
                end
            else
%                 GiveWarning('text',['No data found in bcc file for boundary ' Flow.OpenBoundaries(nb).Name ' parameter: ' Flow.Sediment(j).Name]);
                t=[Flow.StartTime;Flow.StopTime];
                Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesT=t;
                Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesA=[0;0];
                Flow.OpenBoundaries(nb).Sediment(j).TimeSeriesB=[0;0];
                Flow.OpenBoundaries(nb).Sediment(j).Profile='Uniform';
            end
        end
    end
    if Flow.Tracers
        for j=1:Flow.NrTracers
            nt=FindTable(Info,Flow.OpenBoundaries(nb).Name,Flow.Tracer(j).Name);
            if nt>0
                tab=Info.Table(nt);
                itd=tab.ReferenceTime;
                itd=datenum(num2str(itd),'yyyymmdd');
                t=itd+tab.Data(:,1)/1440;
                Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesT=t;
                switch lower(deblank(tab.Contents))
                    case{'uniform'}
                        Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesA=tab.Data(:,2);
                        Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesB=tab.Data(:,3);
                        Flow.OpenBoundaries(nb).Tracer(j).Profile='Uniform';
                    case{'step'}
                        Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesA=tab.Data(:,2);
                        Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesB=tab.Data(:,3);
                        Flow.OpenBoundaries(nb).Tracer(j).Discontinuity=tab.Data(:,4);
                        Flow.OpenBoundaries(nb).Tracer(j).Profile='Step';
                    case{'3d-profile'}
                        Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesA=tab.Data(:,2:kmax+1);
                        Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                        Flow.OpenBoundaries(nb).Tracer(j).Profile='3d-profile';
                end
            else
%                 GiveWarning('text',['No data found in bcc file for boundary ' Flow.OpenBoundaries(nb).Name ' parameter: ' Flow.Tracer(j).Name]);
                t=[Flow.StartTime;Flow.StopTime];
                Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesT=t;
                Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesA=[0;0];
                Flow.OpenBoundaries(nb).Tracer(j).TimeSeriesB=[0;0];
                Flow.OpenBoundaries(nb).Tracer(j).Profile='Uniform';
            end

        end
    end
end
handles.Model(md).Input(ad)=Flow;


function nt=FindTable(Info,bndname,par)

ifound=0;
nt=0;
for i=1:Info.NTables
    if strcmpi(deblank(Info.Table(i).Location),bndname)
        tab=Info.Table(i);
        p=tab.Parameter(2).Name;
        lstr=length(par);
        if length(p)>=lstr
            if strcmpi(p(1:lstr),par)
                nt=i;
                ifound=1;
            end
        end
    end
end
% if ifound==0
%     GiveWarning('text',['Error reading bcc file for boundary ' bndname ' parameter: ' par]);
% end

