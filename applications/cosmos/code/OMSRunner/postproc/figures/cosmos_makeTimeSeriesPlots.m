function cosmos_makeTimeSeriesPlots(hm,m)

Model=hm.Models(m);

try

    if Model.NrStations>0

        nn=Model.NrStations;

        if strcmpi(hm.Scenario,'forecasts')
            tstart=Model.TOutputStart-5;
        else
            tstart=Model.TOutputStart;
        end
        tstop=Model.TStop;

        for i=1:nn
            clear pars

            for ip=1:Model.Stations(i).NrParameters
                
                tms=[];
                
                Parameter=Model.Stations(i).Parameters(ip);
                stationfile=Model.Stations(i).Name;                
                typ=Parameter.Name;

                % Title and labels
                partit=getParameterInfo(hm,typ,'plot','timeseries','title');
                ylab=getParameterInfo(hm,typ,'plot','timeseries','ylabel');
                yltp=getParameterInfo(hm,typ,'plot','timeseries','ylimtype');

                % Check if this parameter need to be plotted                
                PlotCmp=0;
                PlotPrd=0;
                PlotObs=0;
                
                if Parameter.PlotCmp
                    PlotCmp=1;
                end
                if Parameter.PlotPrd
                    PlotPrd=1;
                end
                if Parameter.PlotObs
                    PlotObs=1;
                end

                if PlotCmp || PlotPrd || PlotObs

                    ymin=1e9;
                    ymax=-1e9;

                    nd=0;
                    
                    % Fill data structure

                    % Computed
                    if PlotCmp
                        nm=stationfile;
                        fname=[Model.ArchiveDir 'appended' filesep 'timeseries' filesep typ '.' nm '.mat'];
                        if exist(fname,'file')
                            data=load(fname);
                            nd=nd+1;
                            it1=find(data.Time<tstart,1,'last');
                            if isempty(it1)
                                it1=1;
                            end
                            tms(nd).x=data.Time(it1:end);
                            tms(nd).y=data.Val(it1:end);
                            tms(nd).color='k';
                            tms(nd).name='computed';
                            ymin=min(ymin,min(tms(nd).y));
                            ymax=max(ymax,max(tms(nd).y));
                        end
                    end

                    % Predicted
                    if PlotPrd
                        src=Parameter.PrdSrc;
                        id=Parameter.PrdID;
                        fname=[hm.ScenarioDir 'observations' filesep src filesep id filesep typ '.' id '.mat'];
                        if exist(fname,'file')
                            data=load(fname);
                            nd=nd+1;
                            it1=find(data.Time<tstart,1,'last');
                            if isempty(it1)
                                it1=1;
                            end
                            tms(nd).x=data.Time(it1:end);
                            tms(nd).y=data.Val(it1:end);
                            tms(nd).color='r';
                            tms(nd).name='predicted';
                            ymin=min(ymin,min(tms(nd).y));
                            ymax=max(ymax,max(tms(nd).y));
                        end
                    end

                    % Observed
                    if PlotObs
                        src=Parameter.ObsSrc;
                        id=Parameter.ObsID;
                        fname=[hm.ScenarioDir 'observations' filesep src filesep id filesep typ '.' id '.mat'];
                        if exist(fname,'file')
                            data=load(fname);
                            nd=nd+1;
                            it1=find(data.Time<tstart,1,'last');
                            if isempty(it1)
                                it1=1;
                            end
                            tms(nd).x=data.Time(it1:end);
                            tms(nd).y=data.Val(it1:end);
                            tms(nd).color='b';
                            tms(nd).name='observed';
                            ymin=min(ymin,min(tms(nd).y));
                            ymax=max(ymax,max(tms(nd).y));
                        end
                    end

                    % Check if there is any data in structure tms
                    if ~isempty(tms)
                        
                        % X Axis properties
                        tlim=[tstart tstop];
                        if tstop-tstart>8
                            xticks=tstart:1:tstop;
                        else
                            xticks=tstart:0.5:tstop;
                        end
                        
                        % Y Axis properties
                        switch yltp
                            case{'sym'}
                                yminabs=abs(ymin);
                                ymaxabs=abs(ymax);
                                yabs=ceil(max(yminabs,ymaxabs));
                                ymin=-yabs;
                                ymax=yabs;
                            case{'fit'}
                                ymin=floor(ymin);
                                ymax=ceil(ymax);
                            case{'positive'}
                                ymin=0;
                                ymax=ceil(ymax);
                            case{'angle'}
                                ymin=0;
                                ymax=360;
                        end
                        ydif=ymax-ymin;
                        if ydif<1
                            ytck=0.05;
                            ydec=2;
                        elseif ydif<2
                            ytck=0.1;
                            ydec=1;
                        elseif ydif<4
                            ytck=0.2;
                            ydec=1;
                        elseif ydif<10
                            ytck=0.5;
                            ydec=1;
                        elseif ydif<20
                            ytck=1;
                            ydec=1;
                        elseif ydif<40
                            ytck=2;
                            ydec=1;
                        elseif ydif<100
                            ytck=5;
                            ydec=1;
                        else
                            ytck=30;
                            ydec=1;
                        end
                        ymax=max(ymax,ymin+0.1);
                        if strcmp(yltp,'angle')
                            ytck=45;
                            ydec=0;
                        end
                        ylim=[ymin ymax];
                        yticks=ymin:ytck:ymax;
                        
                        % Title
                        ttl=[partit ' - ' Model.Stations(i).LongName];
                        
                        % And export the figure
                        figname=[Model.Dir 'lastrun' filesep 'figures' filesep typ '.' stationfile '.png'];
                        cosmos_timeSeriesPlot(figname,tms,'ylabel',ylab,'title',ttl,'xlim',tlim,'ylim',ylim,'xticks',xticks,'yticks',yticks);
                    end
                end
            end
        end
    end

catch
    WriteErrorLogFile(hm,['Something went wrong with generating timeseries figure - ' typ ' - ' Model.Name]);
end
