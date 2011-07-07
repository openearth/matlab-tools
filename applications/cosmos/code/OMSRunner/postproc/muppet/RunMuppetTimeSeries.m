function runMuppetTimeSeries(hm,m)

Model=hm.Models(m);

try

    handles.MuppetVersion='3.20';

    handles.SessionName='dummy';
    handles.MuppetDir=hm.MainDir;

    handles=ReadDefaults(handles);
    handles.ColorMaps=ImportColorMaps;
    handles.DefaultColors=ReadDefaultColors;
    handles.Frames=ReadFrames;

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
                
                Parameter=Model.Stations(i).Parameters(ip);
                
                typ=Parameter.Name;

                partit=getParameterInfo(hm,typ,'plot','timeseries','title');
                ylab=getParameterInfo(hm,typ,'plot','timeseries','ylabel');
                yltp=getParameterInfo(hm,typ,'plot','timeseries','ylimtype');

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

                stationfile=Model.Stations(i).Name;

                if PlotCmp || PlotPrd || PlotObs

                    handles.DataProperties=[];
                    handles.Figure=[];

                    ymin=1e9;
                    ymax=-1e9;

                    handles.NrAvailableDatasets=0;
                    nd=0;

                    % Data Properties

                    if PlotCmp

                        PlotCmpOK=0;

                        nm=stationfile;
                        fname=[Model.ArchiveDir 'appended' filesep 'timeseries' filesep typ '.' nm '.mat'];
                        if exist(fname,'file')
                            PlotCmpOK=1;
                            data=load(fname);
                            nd=nd+1;
                            handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
                            handles.DataProperties(nd).Name='computed';
                            it1=find(data.Time<tstart,1,'last');
                            if isempty(it1)
                                it1=1;
                            end
                            handles.DataProperties(nd).x=data.Time(it1:end);
                            handles.DataProperties(nd).y=data.Val(it1:end);
                            if strcmpi(typ,'wl')
%                                 handles.DataProperties(nd).y=handles.DataProperties(nd).y+hm.Models(m).ZLevel;
                            end
                            ymin=min(ymin,min(handles.DataProperties(nd).y));
                            ymax=max(ymax,max(handles.DataProperties(nd).y));
                        end
                    end

                    if PlotPrd
                        PlotPrdOK=0;
                        src=Parameter.PrdSrc;
                        id=Parameter.PrdID;
                        fname=[hm.ScenarioDir 'observations' filesep src filesep id filesep typ '.' id '.mat'];
                        if exist(fname,'file')
                            PlotPrdOK=1;
                            data=load(fname);
                            nd=nd+1;
                            handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
                            handles.DataProperties(nd).Name='predicted';
                            it1=find(data.Time<tstart,1,'last');
                            if isempty(it1)
                                it1=1;
                            end
                            handles.DataProperties(nd).x=data.Time(it1:end);
                            handles.DataProperties(nd).y=data.Val(it1:end);
                            ymin=min(ymin,min(handles.DataProperties(nd).y));
                            ymax=max(ymax,max(handles.DataProperties(nd).y));
                        end
                    end

                    if PlotObs
                        PlotObsOK=0;
                        src=Parameter.ObsSrc;
                        id=Parameter.ObsID;
                        fname=[hm.ScenarioDir 'observations' filesep src filesep id filesep typ '.' id '.mat'];
                        if exist(fname,'file')
                            PlotObsOK=1;
                            data=load(fname);
                            nd=nd+1;
                            handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
                            handles.DataProperties(nd).Name='observed';
                            it1=find(data.Time<tstart,1,'last');
                            if isempty(it1)
                                it1=1;
                            end
                            handles.DataProperties(nd).x=data.Time(it1:end);
                            handles.DataProperties(nd).y=data.Val(it1:end);
                            ymin=min(ymin,min(handles.DataProperties(nd).y));
                            ymax=max(ymax,max(handles.DataProperties(nd).y));
                        end
                    end

                    handles.Figure.Axis(1).Nr=nd;

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

                    % Figure Properties
                    handles.FigureProperties=handles.DefaultFigureProperties;

                    dr=Model.Dir;

                    figname=[dr 'lastrun' filesep 'figures' filesep typ '.' stationfile '.png'];

                    handles.Figure.Name='figure1';
                    handles.Figure.PaperSize=[11 4.5];
                    handles.Figure.Frame='none';

                    handles.Figure.FileName=figname;
                    handles.Figure.Format='png';
                    handles.Figure.Resolution=150;
                    handles.Figure.Renderer='zbuffer';
                    handles.Figure.Orientation='p';
                    handles.Figure.NrAnnotations=0;
                    handles.Figure.BackgroundColor='white';

                    % Subplot Properties
                    handles=InitializeAxisProperties(handles,1);

                    handles.Figure.NrSubplots=1;

                    handles.Figure.Axis(1).Nr=nd;

                    handles.Figure.Axis(1).Position=[0.8 1 7 3];
                    handles.Figure.Axis(1).PlotType='timeseries';
                    handles.Figure.Axis(1).BackgroundColor='white';

                    handles.Figure.Axis(1).YearMin=str2double(datestr(tstart,'yyyy'));
                    handles.Figure.Axis(1).MonthMin=str2double(datestr(tstart,'mm'));
                    handles.Figure.Axis(1).DayMin=str2double(datestr(tstart,'dd'));
                    handles.Figure.Axis(1).HourMin=str2double(datestr(tstart,'HH'));
                    handles.Figure.Axis(1).MinuteMin=str2double(datestr(tstart,'MM'));
                    handles.Figure.Axis(1).SecondMin=str2double(datestr(tstart,'SS'));

                    handles.Figure.Axis(1).YearMax=str2double(datestr(tstop,'yyyy'));
                    handles.Figure.Axis(1).MonthMax=str2double(datestr(tstop,'mm'));
                    handles.Figure.Axis(1).DayMax=str2double(datestr(tstop,'dd'));
                    handles.Figure.Axis(1).HourMax=str2double(datestr(tstop,'HH'));
                    handles.Figure.Axis(1).MinuteMax=str2double(datestr(tstop,'MM'));
                    handles.Figure.Axis(1).SecondMax=str2double(datestr(tstop,'SS'));

                    handles.Figure.Axis(1).YearTick=0;
                    handles.Figure.Axis(1).MonthTick=0;
                    if tstop-tstart>8
                        handles.Figure.Axis(1).DayTick=1;
                        handles.Figure.Axis(1).HourTick=0;
                        handles.Figure.Axis(1).AddDate=0;
                        handles.Figure.Axis(1).DateFormat='dd/mm/yy';
                    else
                        handles.Figure.Axis(1).DayTick=0;
                        handles.Figure.Axis(1).HourTick=12;
                        handles.Figure.Axis(1).AddDate=1;
                        handles.Figure.Axis(1).DateFormat='HH:MM';
                    end
                    handles.Figure.Axis(1).MinuteTick=0;
                    handles.Figure.Axis(1).SecondTick=0;

                    handles.Figure.Axis(1).YMin=ymin;
                    handles.Figure.Axis(1).YMax=ymax;
                    handles.Figure.Axis(1).YTick=ytck;
                    handles.Figure.Axis(1).DecimY=ydec;
                    handles.Figure.Axis(1).XGrid=1;
                    handles.Figure.Axis(1).YGrid=1;
                    handles.Figure.Axis(1).Title=[partit ' - ' Model.Stations(i).LongName];
                    handles.Figure.Axis(1).YLabel=ylab;
                    handles.Figure.Axis(1).PlotLegend=1;
                    handles.Figure.Axis(1).LegendPosition=[ 8.1 3.2 2.0 0.8];
                    handles.Figure.Axis(1).LegendBox=1;

                    handles.Figure.Axis(1).AxesFontSize=5;
                    handles.Figure.Axis(1).TitleFontSize=6;
                    handles.Figure.Axis(1).XLabelFontSize=5;
                    handles.Figure.Axis(1).YLabelFontSize=5;
                    handles.Figure.Axis(1).LegendFontSize=5;

                    nd=0;

                    if PlotCmp &&  PlotCmpOK
                        nd=nd+1;
                        handles=InitializePlotProperties(handles,1,nd);
                        handles.Figure.Axis(1).Plot(nd).Name='computed';
                        handles.Figure.Axis(1).Plot(nd).PlotRoutine='PlotLine';
                        handles.Figure.Axis(1).Plot(nd).LineColor='black';
                        handles.Figure.Axis(1).Plot(nd).LineStyle='-';
                        handles.Figure.Axis(1).Plot(nd).Marker='none';
                        handles.Figure.Axis(1).Plot(nd).LegendText='computed';
                    end

                    if PlotPrd && PlotPrdOK
                        nd=nd+1;
                        handles=InitializePlotProperties(handles,1,nd);
                        handles.Figure.Axis(1).Plot(nd).Name='predicted';
                        handles.Figure.Axis(1).Plot(nd).PlotRoutine='PlotLine';
                        handles.Figure.Axis(1).Plot(nd).LineColor='red';
                        handles.Figure.Axis(1).Plot(nd).LineStyle='-';
                        handles.Figure.Axis(1).Plot(nd).Marker='none';
                        handles.Figure.Axis(1).Plot(nd).LegendText='predicted';
                    end

                    if PlotObs && PlotObsOK
                        nd=nd+1;
                        handles=InitializePlotProperties(handles,1,nd);
                        handles.Figure.Axis(1).Plot(nd).Name='observed';
                        handles.Figure.Axis(1).Plot(nd).PlotRoutine='PlotLine';
                        handles.Figure.Axis(1).Plot(nd).LineColor='blue';
                        handles.Figure.Axis(1).Plot(nd).LineStyle='-';
                        handles.Figure.Axis(1).Plot(nd).Marker='none';
                        handles.Figure.Axis(1).Plot(nd).LegendText='observed';
                    end

                    if nd>0
                        % Make figure
                        mpt=figure('Visible','off','Position',[0 0 0.2 0.2]);
                        set(mpt,'Name','Muppet','NumberTitle','off');
                        guidata(mpt,handles);
                        ExportFigure(handles,1,'export');
                        close(mpt);
                    end
                    
                end
            end
        end
    end

catch

    WriteErrorLogFile(hm,['Something went wrong with generating Muppet timeseries - ' typ ' - ' Model.Name]);

end
