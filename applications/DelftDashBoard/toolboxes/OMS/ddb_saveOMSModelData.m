function ddb_saveOMSModelData(handles)

dr=[handles.Toolbox(tb).Directory '\'];

fname=[dr handles.Toolbox(tb).ShortName '\' handles.Toolbox(tb).ShortName '.xml'];

nobs=handles.Toolbox(tb).NrStations;
nmaps=handles.Toolbox(tb).NrMaps;
nprf=handles.Toolbox(tb).NrProfiles;

model.name=handles.Toolbox(tb).ShortName;
model.longname=handles.Toolbox(tb).LongName;
model.runid=handles.Toolbox(tb).Runid;
model.type=handles.Toolbox(tb).Type;
model.locationx=num2str(handles.Toolbox(tb).Location(1));
model.locationy=num2str(handles.Toolbox(tb).Location(2));
model.continent=handles.Toolbox(tb).Continent;
model.coordsys=handles.ScreenParameters.CoordinateSystem.Name;
model.coordsystype=handles.ScreenParameters.CoordinateSystem.Type;
if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'cartesian')
    model.coordsystype='projected';
end
model.size=handles.Toolbox(tb).Size;
model.priority=handles.Toolbox(tb).Priority;
model.xlim1=handles.Toolbox(tb).XLim(1);
model.xlim2=handles.Toolbox(tb).XLim(2);
model.ylim1=handles.Toolbox(tb).YLim(1);
model.ylim2=handles.Toolbox(tb).YLim(2);
model.flownested=handles.Toolbox(tb).FlowNested;
model.wavenested=handles.Toolbox(tb).WaveNested;
model.timestep=handles.Toolbox(tb).TimeStep;
model.flowspinup=handles.Toolbox(tb).FlowSpinUp;
model.wavespinup=handles.Toolbox(tb).WaveSpinUp;
model.maptimestep=handles.Toolbox(tb).MapTimeStep;
model.comtimestep=handles.Toolbox(tb).ComTimeStep;
model.histimestep=handles.Toolbox(tb).HisTimeStep;
model.runtime=handles.Toolbox(tb).RunTime;

if strcmpi(model.type,'xbeachcluster')
    model.morfac=num2str(handles.Toolbox(tb).MorFac);
end

model.usemeteo=handles.Toolbox(tb).UseMeteo;
model.dxmeteo=handles.Toolbox(tb).DxMeteo;
model.website=handles.Toolbox(tb).WebSite;

if ~strcmpi(model.type,'xbeachcluster')

    for i=1:handles.Toolbox(tb).NrMaps
        model.maps(i).map.parameter=handles.Toolbox(tb).MapParameter{i};
        model.maps(i).map.plot=handles.Toolbox(tb).MapPlot(i);
        model.maps(i).map.type=handles.Toolbox(tb).MapType{i};
        model.maps(i).map.colormap=handles.Toolbox(tb).MapColorMap{i};
        model.maps(i).map.longname=handles.Toolbox(tb).MapLongName{i};
        model.maps(i).map.shortname=handles.Toolbox(tb).MapShortName{i};
        model.maps(i).map.unit=handles.Toolbox(tb).MapUnit{i};
        model.maps(i).map.barlabel=handles.Toolbox(tb).MapBarLabel{i};
        model.maps(i).map.plotroutine=handles.Toolbox(tb).MapPlotRoutine{i};
        model.maps(i).map.dtanim=handles.Toolbox(tb).MapDtAnim(i);
        if strcmpi(handles.Toolbox(tb).MapPlotRoutine{i},'PlotColoredCurvedArrows')
            model.maps(i).map.dtcurvec=handles.Toolbox(tb).MapDtCurVec(i);
            model.maps(i).map.dxcurvec=handles.Toolbox(tb).MapDxCurVec(i);
        end
    end
    
    for i=1:nobs
        model.stations(i).station.name=handles.Toolbox(tb).Stations(i).Name;
        model.stations(i).station.longname=handles.Toolbox(tb).Stations(i).LongName;
        model.stations(i).station.locationx=num2str(handles.Toolbox(tb).Stations(i).x);
        model.stations(i).station.locationy=num2str(handles.Toolbox(tb).Stations(i).y);
        model.stations(i).station.locationm=num2str(handles.Toolbox(tb).Stations(i).m);
        model.stations(i).station.locationn=num2str(handles.Toolbox(tb).Stations(i).n);
        model.stations(i).station.type=handles.Toolbox(tb).Stations(i).Type;
        model.stations(i).station.storesp2=num2str(handles.Toolbox(tb).Stations(i).StoreSP2);
        if ~isempty(handles.Toolbox(tb).Stations(i).SP2id)
            model.stations(i).station.sp2id=handles.Toolbox(tb).Stations(i).SP2id;
        end
        for j=1:length(handles.Toolbox(tb).Stations(i).Parameters)
            model.stations(i).station.parameters(j).parameter.name=handles.Toolbox(tb).Stations(i).Parameters(j).Name;
            model.stations(i).station.parameters(j).parameter.plotcmp=handles.Toolbox(tb).Stations(i).Parameters(j).PlotCmp;
            model.stations(i).station.parameters(j).parameter.plotobs=handles.Toolbox(tb).Stations(i).Parameters(j).PlotObs;
            if ~isempty(handles.Toolbox(tb).Stations(i).Parameters(j).ObsSrc)
                model.stations(i).station.parameters(j).parameter.obssrc=handles.Toolbox(tb).Stations(i).Parameters(j).ObsSrc;
            end
            if ~isempty(handles.Toolbox(tb).Stations(i).Parameters(j).ObsID)
                model.stations(i).station.parameters(j).parameter.obsid=handles.Toolbox(tb).Stations(i).Parameters(j).ObsID;
            end
            if strcmpi(handles.Toolbox(tb).Stations(i).Parameters(j).Name,'wl')
                if isfield(handles.Toolbox(tb).Stations(i).Parameters(j),'PrdSrc')
                    model.stations(i).station.parameters(j).parameter.plotprd=handles.Toolbox(tb).Stations(i).Parameters(j).PlotPrd;
                    if ~isempty(handles.Toolbox(tb).Stations(i).Parameters(j).PrdSrc)
                        model.stations(i).station.parameters(j).parameter.prdsrc=handles.Toolbox(tb).Stations(i).Parameters(j).PrdSrc;
                    end
                    if ~isempty(handles.Toolbox(tb).Stations(i).Parameters(j).PrdID)
                        model.stations(i).station.parameters(j).parameter.prdid=handles.Toolbox(tb).Stations(i).Parameters(j).PrdID;
                    end
                end
            end
        end
    end

end

if ~strcmpi(model.type,'xbeachcluster')
    for i=1:nprf
    end
end

xml_save(fname,model,'off');
