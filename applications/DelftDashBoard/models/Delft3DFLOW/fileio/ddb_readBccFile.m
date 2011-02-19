function handles=ddb_readBccFile(handles)

Flow=handles.Model(md).Input(ad);

kmax=Flow.KMax;

fname=Flow.bccFile;

Info=ddb_bct_io('read',fname);

for nb=1:Flow.nrOpenBoundaries
    if Flow.salinity.Include
        nt=FindTable(Info,Flow.openBoundaries(nb).Name,'salinity');
        if nt>0
            tab=Info.Table(nt);
            itd=tab.ReferenceTime;
            itd=datenum(num2str(itd),'yyyymmdd');
            t=itd+tab.Data(:,1)/1440;
            Flow.openBoundaries(nb).salinity.timeSeriesT=t;
            switch lower(deblank(tab.Contents))
                case{'uniform'}
                    Flow.openBoundaries(nb).salinity.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).salinity.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).salinity.profile='Uniform';
                case{'step'}
                    Flow.openBoundaries(nb).salinity.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).salinity.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).salinity.discontinuity=tab.Data(:,4);
                    Flow.openBoundaries(nb).salinity.profile='Step';
                case{'3d-profile'}
                    Flow.openBoundaries(nb).salinity.timeSeriesA=tab.Data(:,2:kmax+1);
                    Flow.openBoundaries(nb).salinity.timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                    Flow.openBoundaries(nb).salinity.profile='3d-profile';
            end
        else
            t=[Flow.StartTime;Flow.StopTime];
            Flow.openBoundaries(nb).salinity.timeSeriesT=t;
            Flow.openBoundaries(nb).salinity.timeSeriesA=[0;0];
            Flow.openBoundaries(nb).salinity.timeSeriesB=[0;0];
            Flow.openBoundaries(nb).salinity.profile='Uniform';
        end
    end
    if Flow.temperature.include
        nt=FindTable(Info,Flow.openBoundaries(nb).name,'temperature');
        if nt>0
            tab=Info.Table(nt);
            itd=tab.ReferenceTime;
            itd=datenum(num2str(itd),'yyyymmdd');
            t=itd+tab.Data(:,1)/1440;
            Flow.openBoundaries(nb).temperature.timeSeriesT=t;
            switch lower(deblank(tab.Contents))
                case{'uniform'}
                    Flow.openBoundaries(nb).temperature.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).temperature.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).temperature.profile='Uniform';
                case{'step'}
                    Flow.openBoundaries(nb).temperature.timeSeriesA=tab.Data(:,2);
                    Flow.openBoundaries(nb).temperature.timeSeriesB=tab.Data(:,3);
                    Flow.openBoundaries(nb).temperature.discontinuity=tab.Data(:,4);
                    Flow.openBoundaries(nb).temperature.profile='Step';
                case{'3d-profile'}
                    Flow.openBoundaries(nb).temperature.timeSeriesA=tab.Data(:,2:kmax+1);
                    Flow.openBoundaries(nb).temperature.timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                    Flow.openBoundaries(nb).temperature.profile='3d-profile';
            end
        else
            t=[Flow.StartTime;Flow.StopTime];
            Flow.openBoundaries(nb).temperature.timeSeriesT=t;
            Flow.openBoundaries(nb).temperature.timeSeriesA=[0;0];
            Flow.openBoundaries(nb).temperature.timeSeriesB=[0;0];
            Flow.openBoundaries(nb).temperature.profile='Uniform';
        end
    end
    if Flow.sediments.include
        for j=1:Flow.nrSediments
            nt=FindTable(Info,Flow.openBoundaries(nb).name,Flow.sediment(j).name);
            if nt>0
                tab=Info.Table(nt);
                itd=tab.ReferenceTime;
                itd=datenum(num2str(itd),'yyyymmdd');
                t=itd+tab.Data(:,1)/1440;
                Flow.openBoundaries(nb).sediment(j).timeSeriesT=t;
                switch lower(deblank(tab.Contents))
                    case{'uniform'}
                        Flow.openBoundaries(nb).sediment(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).sediment(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).sediment(j).profile='Uniform';
                    case{'step'}
                        Flow.openBoundaries(nb).sediment(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).sediment(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).sediment(j).discontinuity=tab.Data(:,4);
                        Flow.openBoundaries(nb).sediment(j).profile='Step';
                    case{'3d-profile'}
                        Flow.openBoundaries(nb).sediment(j).timeSeriesA=tab.Data(:,2:kmax+1);
                        Flow.openBoundaries(nb).sediment(j).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                        Flow.openBoundaries(nb).sediment(j).profile='3d-profile';
                end
            else
                t=[Flow.StartTime;Flow.StopTime];
                Flow.openBoundaries(nb).sediment(j).timeSeriesT=t;
                Flow.openBoundaries(nb).sediment(j).timeSeriesA=[0;0];
                Flow.openBoundaries(nb).sediment(j).timeSeriesB=[0;0];
                Flow.openBoundaries(nb).sediment(j).Profile='Uniform';
            end
        end
    end
    if Flow.tracers
        for j=1:Flow.nrTracers
            nt=FindTable(Info,Flow.openBoundaries(nb).Name,Flow.tracer(j).Name);
            if nt>0
                tab=Info.Table(nt);
                itd=tab.ReferenceTime;
                itd=datenum(num2str(itd),'yyyymmdd');
                t=itd+tab.Data(:,1)/1440;
                Flow.openBoundaries(nb).tracer(j).timeSeriesT=t;
                switch lower(deblank(tab.Contents))
                    case{'uniform'}
                        Flow.openBoundaries(nb).tracer(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).tracer(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).tracer(j).profile='Uniform';
                    case{'step'}
                        Flow.openBoundaries(nb).tracer(j).timeSeriesA=tab.Data(:,2);
                        Flow.openBoundaries(nb).tracer(j).timeSeriesB=tab.Data(:,3);
                        Flow.openBoundaries(nb).tracer(j).discontinuity=tab.Data(:,4);
                        Flow.openBoundaries(nb).tracer(j).profile='Step';
                    case{'3d-profile'}
                        Flow.openBoundaries(nb).tracer(j).timeSeriesA=tab.Data(:,2:kmax+1);
                        Flow.openBoundaries(nb).tracer(j).timeSeriesB=tab.Data(:,kmax+2:2*kmax+1);
                        Flow.openBoundaries(nb).tracer(j).profile='3d-profile';
                end
            else
                t=[Flow.StartTime;Flow.StopTime];
                Flow.openBoundaries(nb).tracer(j).timeSeriesT=t;
                Flow.openBoundaries(nb).tracer(j).timeSeriesA=[0;0];
                Flow.openBoundaries(nb).tracer(j).timeSeriesB=[0;0];
                Flow.openBoundaries(nb).tracer(j).profile='Uniform';
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

