function handles=ddb_readOMSModelData(handles,fname)

model=xml_load(fname);

handles.Toolbox(tb).ShortName=model.name;
handles.Toolbox(tb).LongName=model.longname;
handles.Toolbox(tb).Runid=model.runid;
handles.Toolbox(tb).Type=model.type;
handles.Toolbox(tb).Location(1)=str2double(model.locationx);
handles.Toolbox(tb).Location(2)=str2double(model.locationy);
handles.Toolbox(tb).Continent=model.continent;

handles.Toolbox(tb).Size=str2double(model.size);
handles.Toolbox(tb).Priority=str2double(model.priority);

handles.Toolbox(tb).XLim(1)=str2double(model.xlim1);
handles.Toolbox(tb).XLim(2)=str2double(model.xlim2);
handles.Toolbox(tb).YLim(1)=str2double(model.ylim1);
handles.Toolbox(tb).YLim(2)=str2double(model.ylim2);

handles.Toolbox(tb).FlowNested=model.flownested;
handles.Toolbox(tb).WaveNested=model.wavenested;

handles.Toolbox(tb).FlowSpinUp=str2double(model.flowspinup);
handles.Toolbox(tb).FlowSpinUp=str2double(model.wavespinup);
handles.Toolbox(tb).MapTimeStep=str2double(model.maptimestep);
handles.Toolbox(tb).ComTimeStep=str2double(model.comtimestep);
handles.Toolbox(tb).HisTimeStep=str2double(model.histimestep);
handles.Toolbox(tb).RunTime=str2double(model.runtime);

if strcmpi(model.type,'xbeachcluster')
    handles.Toolbox(tb).MorFac=str2double(model.morfac);
end

handles.Toolbox(tb).UseMeteo=model.usemeteo;
handles.Toolbox(tb).DxMeteo=str2double(model.dxmeteo);
handles.Toolbox(tb).WebSite=model.website;

if ~strcmpi(model.type,'xbeachcluster')

    omsparameters=handles.Toolbox(tb).MapParameter;

    handles.Toolbox(tb).NrMaps=length(omsparameters);

    for i=1:handles.Toolbox(tb).NrMaps
        
        ii=strmatch(model.maps(i).map.parameter,omsparameters,'exact');
        
        if ~isempty(ii)

            handles.Toolbox(tb).MapParameter{i}=model.maps(ii).map.parameter;
            handles.Toolbox(tb).MapPlot(i)=str2double(model.maps(ii).map.plot);
            handles.Toolbox(tb).MapType{i}=model.maps(ii).map.type;
            handles.Toolbox(tb).MapColorMap{i}=model.maps(ii).map.colormap;
            handles.Toolbox(tb).MapLongName{i}=model.maps(ii).map.longname;
            handles.Toolbox(tb).MapShortName{i}=model.maps(ii).map.shortname;
            handles.Toolbox(tb).MapUnit{i}=model.maps(ii).map.unit;
            handles.Toolbox(tb).MapBarLabel{i}=model.maps(ii).map.barlabel;
            handles.Toolbox(tb).MapPlotRoutine{i}=model.maps(ii).map.plotroutine;
            if strcmpi(handles.Toolbox(tb).MapPlotRoutine{i},'PlotColoredCurvedArrows')
                handles.Toolbox(tb).MapDtAnim(i)=str2double(model.maps(ii).map.dtanim);
                handles.Toolbox(tb).MapDtCurVec(i)=str2double(model.maps(ii).map.dtcurvec);
                handles.Toolbox(tb).MapDxCurVec(i)=str2double(model.maps(ii).map.dxcurvec);
            end

        end

    end
    
    omsparameters={'hs','tp','wavdir','wl'};

    handles.Toolbox(tb).NrStations=length(model.stations);

    for i=1:handles.Toolbox(tb).NrStations
        
        handles.Toolbox(tb).Stations(i).Name=model.stations(i).station.name;
        handles.Toolbox(tb).Stations(i).LongName=model.stations(i).station.longname;
        handles.Toolbox(tb).Stations(i).x=str2double(model.stations(i).station.locationx);
        handles.Toolbox(tb).Stations(i).y=str2double(model.stations(i).station.locationy);
        handles.Toolbox(tb).Stations(i).m=str2double(model.stations(i).station.locationm);
        handles.Toolbox(tb).Stations(i).n=str2double(model.stations(i).station.locationn);
        handles.Toolbox(tb).Stations(i).Type=model.stations(i).station.type;
        handles.Toolbox(tb).Stations(i).StoreSP2=str2double(model.stations(i).station.storesp2);

        if isfield(model.stations(i).station,'sp2id')
            handles.Toolbox(tb).Stations(i).SP2id=model.stations(i).station.sp2id;
        else
            handles.Toolbox(tb).Stations(i).SP2id='';
        end

        for j=1:length(omsparameters)

            % Setting defaults
            handles.Toolbox(tb).Stations(i).Parameters(j).Name='';
            handles.Toolbox(tb).Stations(i).Parameters(j).PlotCmp=0;
            handles.Toolbox(tb).Stations(i).Parameters(j).PlotObs=0;
            handles.Toolbox(tb).Stations(i).Parameters(j).PlotPrd=0;
            handles.Toolbox(tb).Stations(i).Parameters(j).ObsSrc='';
            handles.Toolbox(tb).Stations(i).Parameters(j).ObsID='';
            handles.Toolbox(tb).Stations(i).Parameters(j).PrdSrc='';
            handles.Toolbox(tb).Stations(i).Parameters(j).PrdID='';

            for k=1:length(model.stations(i).station.parameters);
                modelparameters{k}=model.stations(i).station.parameters(k).parameter.name;
            end
            
            ii=strmatch(omsparameters{j},modelparameters,'exact');
            
            handles.Toolbox(tb).Stations(i).Parameters(j).Name=model.stations(i).station.parameters(ii).parameter.name;
            handles.Toolbox(tb).Stations(i).Parameters(j).PlotCmp=str2double(model.stations(i).station.parameters(ii).parameter.plotcmp);
            handles.Toolbox(tb).Stations(i).Parameters(j).PlotObs=str2double(model.stations(i).station.parameters(ii).parameter.plotobs);
 
            if isfield(model.stations(i).station.parameters(ii).parameter,'obssrc')
                handles.Toolbox(tb).Stations(i).Parameters(j).ObsSrc=model.stations(i).station.parameters(ii).parameter.obssrc;
            else
                handles.Toolbox(tb).Stations(i).Parameters(j).ObsSrc='';
            end
            if isfield(model.stations(i).station.parameters(ii).parameter,'obsid')
                handles.Toolbox(tb).Stations(i).Parameters(j).ObsID=model.stations(i).station.parameters(ii).parameter.obsid;
            else
                handles.Toolbox(tb).Stations(i).Parameters(j).ObsID='';
            end

            if strcmpi(omsparameters{j},'wl')
                if isfield(model.stations(i).station.parameters(ii).parameter,'prdsrc')
                    handles.Toolbox(tb).Stations(i).Parameters(j).PlotPrd=str2double(model.stations(i).station.parameters(ii).parameter.plotprd);
                    handles.Toolbox(tb).Stations(i).Parameters(j).PrdSrc=model.stations(i).station.parameters(ii).parameter.prdsrc;
                    handles.Toolbox(tb).Stations(i).Parameters(j).PrdID=model.stations(i).station.parameters(ii).parameter.prdid;
                end
            end
        end
    end

end

if ~strcmpi(model.type,'xbeachcluster')
%     for i=1:nprf
%     end
end

