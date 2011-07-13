function [hm,ok]=cosmos_readModel(hm,fname,i)

ok=1;

% Read Model

model=xml_load(fname);

hm.Models(i).Run=1;
if isfield(model,'run')
    if str2double(model.run)==0
        % Skip this model
        ok=0;
        hm.Models(i).Run=0;
        return
    end
end

%% Stations, maps and profiles
hm.Models(i).NrStations=0;
hm.Models(i).nrMaps=0;
hm.Models(i).NrProfiles=0;

%% Names
hm.Models(i).LongName=model.longname;
hm.Models(i).Name=model.name;
hm.Models(i).Continent=model.continent;
hm.Models(i).Dir=[hm.ScenarioDir 'models' filesep model.continent filesep model.name filesep];

% Website
try
if isfield(model,'websites')
    for j=1:length(model.websites)
        hm.Models(i).WebSite(j).Name=model.websites(j).website.name;
        hm.Models(i).WebSite(j).Location(1)=str2double(model.websites(j).website.locationx);
        hm.Models(i).WebSite(j).Location(2)=str2double(model.websites(j).website.locationy);
    end
else
    hm.Models(i).WebSite(1).Name=model.website;
    hm.Models(i).WebSite(1).Location(1)=str2double(model.locationx);
    hm.Models(i).WebSite(1).Location(2)=str2double(model.locationy);
end
catch
    shite=1
end

hm.Models(i).ArchiveDir=[hm.ArchiveDir model.continent filesep model.name filesep 'archive' filesep];
hm.Models(i).Type=model.type;
hm.Models(i).CoordinateSystem=model.coordsys;
hm.Models(i).CoordinateSystemType=model.coordsystype;
hm.Models(i).Runid=model.runid;

if isfield(model,'runenv')
    hm.Models(i).RunEnv=model.runenv;
else
    hm.Models(i).RunEnv=hm.RunEnv;
end
if isfield(model,'numcores')
    hm.Models(i).NumCores=model.numcores;
else
    hm.Models(i).NumCores=hm.NumCores;
end

% if ~isempty(hm.Models(i).WebSite)
%     hm.Models(i).figureURL=['http://dtvirt5.deltares.nl/~ormondt/' hm.Models(i).WebSite '/scenarios/' hm.Scenario '/' hm.Models(i).Continent '/' hm.Models(i).Name '/figures/'];
% else
%     hm.Models(i).figureURL='';
% end
hm.Models(i).figureURL='';

%% Domain

if isfield(model,'thick')
    fname=model.thick;
    fname=[hm.Models(i).Dir 'input' filesep fname];
    thck=load(fname);
    hm.Models(i).KMax=length(thck);
    hm.Models(i).thick=thck;
else
    hm.Models(i).KMax=1;
    hm.Models(i).thick(1)=100;
end

if isfield(model,'ztop')
    hm.Models(i).zTop=str2double(model.ztop);
else
    hm.Models(i).zTop=0;
end

if isfield(model,'zbot')
    hm.Models(i).zBot=str2double(model.zbot);
else
    hm.Models(i).zBot=0;
end

if isfield(model,'layertype')
    hm.Models(i).layerType=model.layertype;
else
    hm.Models(i).layerType='sigma';
end

%% Initial conditions
if isfield(model,'zeta0')
    hm.Models(i).Zeta0=str2double(model.zeta0);
else
    hm.Models(i).Zeta0=0;
end

%% Time
if isfield(model,'timestep')
    hm.Models(i).TimeStep=str2double(model.timestep);
else
    hm.Models(i).TimeStep=0;
end
if isfield(model,'runtime')
    hm.Models(i).RunTime=str2double(model.runtime);
else
    hm.Models(i).RunTime=999;
end
if isfield(model,'starttime')
    hm.Models(i).StartTime=str2double(model.starttime);
else
    hm.Models(i).StartTime=0;
end
if isfield(model,'wavetimestep')
    hm.Models(i).WaveTimeStep=str2double(model.wavetimestep);
else
    hm.Models(i).WaveTimeStep=30;
end
hm.Models(i).FlowSpinUp=str2double(model.flowspinup);
hm.Models(i).WaveSpinUp=str2double(model.wavespinup);
if isfield(model,'histimestep')
    hm.Models(i).HisTimeStep=str2double(model.histimestep);
else
    hm.Models(i).HisTimeStep=1;
end
if isfield(model,'maptimestep')
    hm.Models(i).MapTimeStep=str2double(model.maptimestep);
else
    hm.Models(i).MapTimeStep=60;
end
if isfield(model,'comtimestep')
    hm.Models(i).ComTimeStep=str2double(model.comtimestep);
else
    hm.Models(i).ComTimeStep=0;
end
if isfield(model,'maptimestep')
    hm.Models(i).WavmTimeStep=str2double(model.maptimestep);
else
    hm.Models(i).WavmTimeStep=0;
end
if isfield(model,'priority')
    hm.Models(i).Priority=str2double(model.priority);
else
    hm.Models(i).Priority=0;
end

%% Parameters

if isfield(model,'roumet')
    hm.Models(i).RouMet=model.roumet;
else
    hm.Models(i).RouMet='M';
end
if isfield(model,'ccofu')
    hm.Models(i).Ccofu=str2double(model.ccofu);
else
    hm.Models(i).Ccofu=0.022;
end
if isfield(model,'dpsopt')
    hm.Models(i).DpsOpt=model.dpsopt;
else
    hm.Models(i).DpsOpt='MAX';
end
if isfield(model,'vicouv')
    hm.Models(i).VicoUV=str2double(model.vicouv);
else
    hm.Models(i).VicoUV=1;
end
if isfield(model,'momsol')
    hm.Models(i).MomSol=model.momsol;
else
    hm.Models(i).MomSol='Cyclic';
end
if isfield(model,'cstbnd')
    hm.Models(i).CstBnd=str2double(model.cstbnd);
else
    hm.Models(i).CstBnd=0;
end
hm.Models(i).SMVelo='euler';
if isfield(model,'smvelo')
    if strcmpi(model.smvelo,'glm')   
        hm.Models(i).SMVelo='GLM';
    end
end

hm.Models(i).dirSpace='circle';
hm.Models(i).nDirBins=36;

if isfield(model,'dirspace')
    hm.Models(i).dirSpace=model.dirspace;
end
if isfield(model,'ndirbins')
    hm.Models(i).nDirBins=str2double(model.ndirbins);
end
if isfield(model,'startdir')
    hm.Models(i).startDir=str2double(model.startdir);
end
if isfield(model,'enddir')
    hm.Models(i).endDir=str2double(model.enddir);
end

if isfield(model,'flowwaterlevel')
    hm.Models(i).FlowWaterLevel=str2double(model.flowwaterlevel);
else
    hm.Models(i).FlowWaterLevel=1;
end
if isfield(model,'flowvelocity')
    hm.Models(i).FlowVelocity=str2double(model.flowvelocity);
else
    hm.Models(i).FlowVelocity=0;
end
if isfield(model,'flowbedlevel')
    hm.Models(i).FlowBedLevel=str2double(model.flowbedlevel);
else
    hm.Models(i).FlowBedLevel=1;
end
if isfield(model,'flowwind')
    hm.Models(i).FlowWind=str2double(model.flowwind);
else
    hm.Models(i).FlowWind=1;
end
if isfield(model,'maxiter')
    hm.Models(i).MaxIter=str2double(model.maxiter);
else
    hm.Models(i).MaxIter=2;
end
if isfield(model,'morfac')
    hm.Models(i).MorFac=str2double(model.morfac);
else
    hm.Models(i).MorFac=1;
end
if isfield(model,'wavebedfriccoef')
    hm.Models(i).WaveBedFricCoef=str2double(model.wavebedfriccoef);
else
    hm.Models(i).WaveBedFricCoef=0.067;
end
if isfield(model,'wavebedfric')
    hm.Models(i).WaveBedFric=model.wavebedfric;
else
    hm.Models(i).WaveBedFric='jonswap';
end

hm.Models(i).windStress=[6.3000000e-004  0.0000000e+000  7.2300000e-003  1.0000000e+002];

if isfield(model,'windstress')
    hm.Models(i).windStress=str2num(model.windstress);
end

hm.Models(i).UseDtAirSea=0;
if isfield(model,'dtairsea')
    if strcmpi(model.dtairsea(1),'y')
        hm.Models(i).UseDtAirSea=1;
    end
end

hm.Models(i).useTidalForces=0;
if isfield(model,'tidalforces')
    if strcmpi(model.tidalforces(1),'y')
        hm.Models(i).useTidalForces=1;
    end
end

hm.Models(i).TmzRad=[];
hm.Models(i).includeTemperature=0;
if isfield(model,'temperature')
    if strcmpi(model.temperature(1),'y')
        hm.Models(i).includeTemperature=1;
    end
    if isfield(model,'tmzrad')
        hm.Models(i).TmzRad=str2double(model.tmzrad);
    end
end

hm.Models(i).includeSalinity=0;
if isfield(model,'salinity')
    if strcmpi(model.salinity(1),'y')
        hm.Models(i).includeSalinity=1;
    end
end

hm.Models(i).nudge=0;
if isfield(model,'nudge')
    if strcmpi(model.nudge(1),'y')
        hm.Models(i).nudge=1;
    end
end

% Discharges
hm.Models(i).discharge=[];
if isfield(model,'discharges')
    for j=1:length(model.discharges)
        % defaults
        hm.Models(i).discharge(j).interpolation='linear';
        hm.Models(i).discharge(j).type='regular';
 
        hm.Models(i).discharge(j).name=model.discharges(j).discharge.name;
        hm.Models(i).discharge(j).M=str2double(model.discharges(j).discharge.m);
        hm.Models(i).discharge(j).N=str2double(model.discharges(j).discharge.n);
        hm.Models(i).discharge(j).K=str2double(model.discharges(j).discharge.k);
        
        if isfield(model.discharges(j).discharge,'interpolation')
            hm.Models(i).discharge(j).interpolation=model.discharges(j).discharge.interpolation;
        end

        hm.Models(i).discharge(j).q=str2double(model.discharges(j).discharge.q);
        if isfield(model.discharges(j).discharge,'salinity')
            hm.Models(i).discharge(j).salinity.constant=str2double(model.discharges(j).discharge.salinity);
        end
        if isfield(model.discharges(j).discharge,'temperature')
            hm.Models(i).discharge(j).temperature.constant=str2double(model.discharges(j).discharge.temperature);
        end
        if isfield(model.discharges(j).discharge,'tracer1')
            hm.Models(i).discharge(j).tracer(1).constant=str2double(model.discharges(j).discharge.tracer1);
        end
        if isfield(model.discharges(j).discharge,'tracer2')
            hm.Models(i).discharge(j).tracer(2).constant=str2double(model.discharges(j).discharge.tracer2);
        end
        if isfield(model.discharges(j).discharge,'tracer3')
            hm.Models(i).discharge(j).tracer(3).constant=str2double(model.discharges(j).discharge.tracer3);
        end

    end
end

% Tracers
hm.Models(i).tracer=[];
if isfield(model,'tracers')
    for j=1:length(model.discharges)
        hm.Models(i).tracer(j).name=model.tracers(j).tracer.name;
        hm.Models(i).tracer(j).decay=0;
        if isfield(model.tracers(j).tracer,'decay')
            hm.Models(i).tracer(j).decay=str2double(model.tracers(j).tracer.decay);
        end
    end
end


%% Locations
hm.Models(i).Size=str2double(model.size);
try
    hm.Models(i).XLim(1)=str2double(model.xlim1);
end
try
    hm.Models(i).XLim(2)=str2double(model.xlim2);
end
try
    hm.Models(i).YLim(1)=str2double(model.ylim1);
end
try
    hm.Models(i).YLim(2)=str2double(model.ylim2);
end
try
    hm.Models(i).XLimPlot=hm.Models(i).XLim;
end
try
    hm.Models(i).YLimPlot=hm.Models(i).YLim;
end

if isfield(model,'xlimplot1')
    hm.Models(i).XLimPlot(1)=str2double(model.xlimplot1);
    hm.Models(i).XLimPlot(2)=str2double(model.xlimplot2);
    hm.Models(i).YLimPlot(1)=str2double(model.ylimplot1);
    hm.Models(i).YLimPlot(2)=str2double(model.ylimplot2);
end

if isfield(model,'zlevel')
    hm.Models(i).ZLevel=str2double(model.zlevel);
else
    hm.Models(i).ZLevel=0;
end

if isfield(model,'zslr')
    hm.Models(i).ZSeaLevelRise=str2double(model.zslr);
else
    hm.Models(i).ZSeaLevelRise=0;
end

if isfield(model,'xori')
    hm.Models(i).XOri=str2double(model.xori);
end
if isfield(model,'yori')
    hm.Models(i).YOri=str2double(model.yori);
end
if isfield(model,'dx')
    hm.Models(i).dX=str2double(model.dx);
end
if isfield(model,'dy')
    hm.Models(i).dY=str2double(model.dy);
end
if isfield(model,'nx')
    hm.Models(i).nX=str2double(model.nx);
end
if isfield(model,'ny')
    hm.Models(i).nY=str2double(model.ny);
end
if isfield(model,'alpha')
    hm.Models(i).alpha=str2double(model.alpha);
end

%% Nesting

% Flow
if isfield(model,'flownested')
    hm.Models(i).FlowNestModel=model.flownested;
    if strcmpi(model.flownested,'none')
        hm.Models(i).FlowNested=0;
    else
        hm.Models(i).FlowNested=1;
    end
else
    hm.Models(i).FlowNestModel='';
    hm.Models(i).FlowNested=0;
end

hm.Models(i).oceanModel='';
if isfield(model,'oceanmodel')
    hm.Models(i).oceanModel=model.oceanmodel;
end
if isfield(model,'flownesttype')
    hm.Models(i).FlowNestType=model.flownesttype;
else
    hm.Models(i).FlowNestType='regular';
end

if isfield(model,'flownestxml')
    hm.Models(i).FlowNestXML=model.flownestedxml;
else
    hm.Models(i).FlowNestXML=[];    
end

% Wave
hm.Models(i).WaveNestNr=0;
if isfield(model,'wavenested')
    hm.Models(i).WaveNestModel=model.wavenested;
    if strcmpi(model.wavenested,'none')
        hm.Models(i).WaveNested=0;
    else
        hm.Models(i).WaveNested=1;
        if isfield(model,'wavenestnr')
            hm.Models(i).WaveNestNr=str2double(model.wavenestnr);
        end
    end
else
    hm.Models(i).WaveNestModel='';
    hm.Models(i).WaveNested=0;
end

%% Initial conditions
hm.Models(i).makeIniFile=0;
if isfield(model,'makeinifile')
    if strcmpi(model.makeinifile(1),'y')
        hm.Models(i).makeIniFile=1;
    end
end

%% Meteo
if isfield(model,'usemeteo')
    hm.Models(i).UseMeteo=model.usemeteo;
else
    hm.Models(i).UseMeteo='none';
end
if isfield(model,'prcorr')
    hm.Models(i).PrCorr=str2double(model.prcorr);
else
    hm.Models(i).PrCorr=101200.0;
end
if isfield(model,'dxmeteo')
    hm.Models(i).dXMeteo=str2double(model.dxmeteo);
else
    hm.Models(i).dXMeteo=5000.0;
end
hm.Models(i).dYMeteo=hm.Models(i).dXMeteo;

%% XBeach
if isfield(model,'morfac')
    hm.Models(i).MorFac=model.morfac;
else
    hm.Models(i).MorFac=0;
end

%% Stations
if isfield(model,'stations')

    hm.Models(i).NrStations=length(model.stations);

    for j=1:hm.Models(i).NrStations

        hm.Models(i).Stations(j).Name=model.stations(j).station.name;
        hm.Models(i).Stations(j).LongName=model.stations(j).station.longname;
        hm.Models(i).Stations(j).Location(1)=str2double(model.stations(j).station.locationx);
        hm.Models(i).Stations(j).Location(2)=str2double(model.stations(j).station.locationy);
        if isfield(model.stations(j).station,'locationm')
            hm.Models(i).Stations(j).M=str2double(model.stations(j).station.locationm);
            hm.Models(i).Stations(j).N=str2double(model.stations(j).station.locationn);
        end
        hm.Models(i).Stations(j).Type=model.stations(j).station.type;

        %% SP2
        if isfield(model.stations(j).station,'storesp2')
            hm.Models(i).Stations(j).StoreSP2=str2double(model.stations(j).station.storesp2);
            if isfield(model.stations(j).station,'sp2id')
                hm.Models(i).Stations(j).SP2id=model.stations(j).station.sp2id;
            else
                hm.Models(i).Stations(j).SP2id='';
            end
        else
            hm.Models(i).Stations(j).StoreSP2=0;
            hm.Models(i).Stations(j).SP2id='';
        end

        %% Parameters
        hm.Models(i).Stations(j).NrParameters=length(model.stations(j).station.parameters);
        for k=1:hm.Models(i).Stations(j).NrParameters

            % Defaults
            hm.Models(i).Stations(j).Parameters(k).PlotCmp=0;
            hm.Models(i).Stations(j).Parameters(k).PlotObs=0;
            hm.Models(i).Stations(j).Parameters(k).PlotPrd=0;
            hm.Models(i).Stations(j).Parameters(k).ObsCode='';
            hm.Models(i).Stations(j).Parameters(k).PrdCode='';
            hm.Models(i).Stations(j).Parameters(k).ObsID='';
            hm.Models(i).Stations(j).Parameters(k).PrdID='';
            hm.Models(i).Stations(j).Parameters(k).layer=[];
            hm.Models(i).Stations(j).Parameters(k).toOPeNDAP=0;
            
            hm.Models(i).Stations(j).Parameters(k).Name=model.stations(j).station.parameters(k).parameter.name;

            if isfield(model.stations(j).station.parameters(k).parameter,'plotcmp')
                hm.Models(i).Stations(j).Parameters(k).PlotCmp=str2double(model.stations(j).station.parameters(k).parameter.plotcmp);
            end

            if isfield(model.stations(j).station.parameters(k).parameter,'plotobs')
                hm.Models(i).Stations(j).Parameters(k).PlotObs=str2double(model.stations(j).station.parameters(k).parameter.plotobs);
            end
            if isfield(model.stations(j).station.parameters(k).parameter,'obssrc')
                hm.Models(i).Stations(j).Parameters(k).ObsSrc=model.stations(j).station.parameters(k).parameter.obssrc;
            end
            if isfield(model.stations(j).station.parameters(k).parameter,'obsid')
                hm.Models(i).Stations(j).Parameters(k).ObsID=model.stations(j).station.parameters(k).parameter.obsid;
            end

            if isfield(model.stations(j).station.parameters(k).parameter,'plotprd')
                hm.Models(i).Stations(j).Parameters(k).PlotPrd=str2double(model.stations(j).station.parameters(k).parameter.plotprd);
            end
            if isfield(model.stations(j).station.parameters(k).parameter,'prdsrc')
                hm.Models(i).Stations(j).Parameters(k).PrdSrc=model.stations(j).station.parameters(k).parameter.prdsrc;
            end
            if isfield(model.stations(j).station.parameters(k).parameter,'prdid')
                hm.Models(i).Stations(j).Parameters(k).PrdID=model.stations(j).station.parameters(k).parameter.prdid;
            end
            if isfield(model.stations(j).station.parameters(k).parameter,'layer')
                hm.Models(i).Stations(j).Parameters(k).layer=str2double(model.stations(j).station.parameters(k).parameter.layer);
            end
            if isfield(model.stations(j).station.parameters(k).parameter,'toopendap')
                hm.Models(i).Stations(j).Parameters(k).toOPeNDAP=str2double(model.stations(j).station.parameters(k).parameter.toopendap);
            end

        end
    end
end

%% Map Datasets
hm.Models(i).nrMapDatasets=0;
if isfield(model,'mapdatasets')
    hm.Models(i).nrMapDatasets=length(model.mapdatasets);
    for j=1:hm.Models(i).nrMapDatasets
        hm.Models(i).mapDatasets(j).name=model.mapdatasets(j).dataset.name;
        hm.Models(i).mapDatasets(j).layer=[];
        if isfield(model.mapdatasets(j).dataset,'layer')
            hm.Models(i).mapDatasets(j).layer=str2double(model.mapdatasets(j).dataset.layer);
        end
    end
end

%% Map plots
hm.Models(i).nrMapPlots=0;
if isfield(model,'mapplots')
    hm.Models(i).nrMapPlots=length(model.mapplots);
    for j=1:hm.Models(i).nrMapPlots
        
        hm.Models(i).mapPlots(j).name=model.mapplots(j).mapplot.name;
        hm.Models(i).mapPlots(j).longName=model.mapplots(j).mapplot.longname;

        hm.Models(i).mapPlots(j).timeStep=[];
        if isfield(model.mapplots(j).mapplot,'timestep')
             hm.Models(i).mapPlots(j).timeStep=str2double(model.mapplots(j).mapplot.timestep);
        end

        hm.Models(i).mapPlots(j).plot=1;
        if isfield(model.mapplots(j).mapplot,'plot')
             hm.Models(i).mapPlots(j).plot=str2double(model.mapplots(j).mapplot.plot);
        end

        if isfield(model.mapplots(j).mapplot,'datasets')

            hm.Models(i).mapPlots(j).nrDatasets=length(model.mapplots(j).mapplot.datasets);
            
            for k=1:hm.Models(i).mapPlots(j).nrDatasets

                hm.Models(i).mapPlots(j).datasets(k).name=model.mapplots(j).mapplot.datasets(k).dataset.name;
                
                hm.Models(i).mapPlots(j).datasets(k).plotRoutine='patches';
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'plotroutine')
                hm.Models(i).mapPlots(j).datasets(k).plotRoutine=model.mapplots(j).mapplot.datasets(k).dataset.plotroutine;
                end
                
                hm.Models(i).mapPlots(j).datasets(k).plot=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'plot')
                    hm.Models(i).mapPlots(j).datasets(k).plot=str2num(model.mapplots(j).mapplot.datasets(k).dataset.plot);
                end
                
                hm.Models(i).mapPlots(j).datasets(k).component='magnitude';
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'component')
                    hm.Models(i).mapPlots(j).datasets(k).component=model.mapplots(j).mapplot.datasets(k).dataset.component;
                end

                hm.Models(i).mapPlots(j).datasets(k).arrowLength=3600;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'arrowlength')
                    hm.Models(i).mapPlots(j).datasets(k).arrowLength=str2num(model.mapplots(j).mapplot.datasets(k).dataset.arrowlength);
                end

                hm.Models(i).mapPlots(j).datasets(k).spacing=10000;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'spacing')
                    hm.Models(i).mapPlots(j).datasets(k).spacing=str2num(model.mapplots(j).mapplot.datasets(k).dataset.spacing);
                end

                hm.Models(i).mapPlots(j).datasets(k).thinning=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'thinning')
                    hm.Models(i).mapPlots(j).datasets(k).thinning=str2num(model.mapplots(j).mapplot.datasets(k).dataset.thinning);
                end
                
                hm.Models(i).mapPlots(j).datasets(k).thinningX=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'thinningx')
                    hm.Models(i).mapPlots(j).datasets(k).thinningX=str2num(model.mapplots(j).mapplot.datasets(k).dataset.thinningx);
                end

                hm.Models(i).mapPlots(j).datasets(k).thinningY=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'thinningy')
                    hm.Models(i).mapPlots(j).datasets(k).thinningY=str2num(model.mapplots(j).mapplot.datasets(k).dataset.thinningy);
                end

                hm.Models(i).mapPlots(j).datasets(k).cLim=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'clim')
                    hm.Models(i).mapPlots(j).datasets(k).cLim=str2num(model.mapplots(j).mapplot.datasets(k).dataset.clim);
                end

                hm.Models(i).mapPlots(j).datasets(k).polygon=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'polygon')
                    hm.Models(i).mapPlots(j).datasets(k).polygon=model.mapplots(j).mapplot.datasets(k).dataset.polygon;
                end

                hm.Models(i).mapPlots(j).datasets(k).relativeSpeed=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'relativespeed')
                    hm.Models(i).mapPlots(j).datasets(k).relativeSpeed=str2num(model.mapplots(j).mapplot.datasets(k).dataset.relativespeed);
                end

                hm.Models(i).mapPlots(j).datasets(k).scaleFactor=0.001;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'scalefactor')
                    hm.Models(i).mapPlots(j).datasets(k).scaleFactor=str2num(model.mapplots(j).mapplot.datasets(k).dataset.scalefactor);
                end

                hm.Models(i).mapPlots(j).datasets(k).colorBarDecimals=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'colorbardecimals')
                    hm.Models(i).mapPlots(j).datasets(k).colorBarDecimals=str2num(model.mapplots(j).mapplot.datasets(k).dataset.colorbardecimals);
                end

                hm.Models(i).mapPlots(j).datasets(k).colorMap=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'colormap')
                    hm.Models(i).mapPlots(j).datasets(k).colorMap=model.mapplots(j).mapplot.datasets(k).dataset.colormap;
                end

                hm.Models(i).mapPlots(j).datasets(k).barLabel=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'barlabel')
                    hm.Models(i).mapPlots(j).datasets(k).barLabel=model.mapplots(j).mapplot.datasets(k).dataset.barlabel;
                end

            end
        end
    end
end

% hm.Models(i).mapPlots(j).Plot=str2double(model.maps(j).map.plot);
%         hm.Models(i).mapPlots(j).ColorMap=model.maps(j).map.colormap;
%         hm.Models(i).mapPlots(j).longName=model.maps(j).map.longname;
%         hm.Models(i).mapPlots(j).shortName=model.maps(j).map.shortname;
%         hm.Models(i).mapPlots(j).Unit=model.maps(j).map.unit;
%         if isfield(model.maps(j).map,'barlabel')
%             hm.Models(i).mapPlots(j).BarLabel=model.maps(j).map.barlabel;
%         else
%             hm.Models(i).mapPlots(j).BarLabel='';
%         end
%         if isfield(model.maps(j).map,'dtanim')
%             hm.Models(i).mapPlots(j).dtAnim=str2double(model.maps(j).map.dtanim);
%         else
%             % Default animation time step is 3 hrs
%             hm.Models(i).mapPlots(j).dtAnim=10800;
%         end
%         hm.Models(i).mapPlots(j).Dataset.Parameter=model.maps(j).map.parameter;
%         hm.Models(i).mapPlots(j).Dataset.Type=model.maps(j).map.type;
% 
%         if isfield(model.maps(j).map,'dxcurvec')
%             hm.Models(i).mapPlots(j).Dataset.DxCurVec=str2double(model.maps(j).map.dxcurvec);
%             hm.Models(i).mapPlots(j).Dataset.DtCurVec=str2double(model.maps(j).map.dtcurvec);
%         end
%         hm.Models(i).mapPlots(j).Dataset.DdtCurVec=3600;
%         if isfield(model.maps(j).map,'ddtcurvec')
%             hm.Models(i).mapPlots(j).Dataset.DdtCurVec=str2double(model.maps(j).map.ddtcurvec);
%         end
% 
%         if isfield(model.maps(j).map,'plotroutine')
%             hm.Models(i).mapPlots(j).Dataset.PlotRoutine=model.maps(j).map.plotroutine;
%         else
%             hm.Models(i).mapPlots(j).Dataset.PlotRoutine='PlotPatches';
%         end
%         if isfield(model.maps(j).map,'layer')
%             hm.Models(i).mapPlots(j).Dataset.layer=str2double(model.maps(j).map.layer);
%         else
%             hm.Models(i).mapPlots(j).Dataset.layer=[];
%         end
%         hm.Models(i).mapPlots(j).Dataset.cLim=[];
%         if isfield(model.maps(j).map,'clim')
%             hm.Models(i).mapPlots(j).Dataset.cLim=str2num(model.maps(j).map.clim);
%         end
%         hm.Models(i).mapPlots(j).Dataset.polygon=[];
%         if isfield(model.maps(j).map,'polygon')
%             hm.Models(i).mapPlots(j).Dataset.polygon=model.maps(j).map.polygon;
%         end
%         hm.Models(i).mapPlots(j).colorBarDecimals=1;
%         if isfield(model.maps(j).map,'colorbardecimals')
%             hm.Models(i).mapPlots(j).colorBarDecimals=str2num(model.maps(j).map.colorbardecimals);
%         end
%         hm.Models(i).mapPlots(j).thinning=1;
%         if isfield(model.maps(j).map,'thinning')
%             hm.Models(i).mapPlots(j).thinning=str2num(model.maps(j).map.thinning);
%         end
%         hm.Models(i).mapPlots(j).thinningX=[];
%         if isfield(model.maps(j).map,'thinningx')
%             hm.Models(i).mapPlots(j).thinningX=str2num(model.maps(j).map.thinningx);
%         end
%         hm.Models(i).mapPlots(j).thinningY=[];
%         if isfield(model.maps(j).map,'thinningy')
%             hm.Models(i).mapPlots(j).thinningY=str2num(model.maps(j).map.thinningy);
%         end
%         hm.Models(i).mapPlots(j).scaleFactor=0.1;
%         if isfield(model.maps(j).map,'scalefactor')
%             hm.Models(i).mapPlots(j).scaleFactor=str2num(model.maps(j).map.scalefactor);
%         end
% 
% %         if ~isempty(hm.Models(i).WebSite)
% %             hm.Models(i).mapPlots(j).Url=['http://dtvirt5.deltares.nl/~ormondt/' hm.Models(i).WebSite '/scenarios/' hm.Scenario '/' hm.Models(i).Continent '/' hm.Models(i).Name '/figures/'];
% %         else
%             hm.Models(i).mapPlots(j).Url='';
% %         end
%     end
% end
% 
%% X-Beach Profiles
if isfield(model,'profiles')
    hm.Models(i).NrProfiles=length(model.profiles);
    for j=1:hm.Models(i).NrProfiles
        hm.Models(i).Profile(j).Name=model.profiles(j).profile.name;
        hm.Models(i).Profile(j).Location(1)=str2double(model.profiles(j).profile.originx);
        hm.Models(i).Profile(j).Location(2)=str2double(model.profiles(j).profile.originy);
        hm.Models(i).Profile(j).OriginX=str2double(model.profiles(j).profile.originx);
        hm.Models(i).Profile(j).OriginY=str2double(model.profiles(j).profile.originy);
        hm.Models(i).Profile(j).Alpha=str2double(model.profiles(j).profile.alpha);
        hm.Models(i).Profile(j).Length=str2double(model.profiles(j).profile.length);
        hm.Models(i).Profile(j).nX=str2double(model.profiles(j).profile.nx);
        hm.Models(i).Profile(j).nY=str2double(model.profiles(j).profile.ny);
        hm.Models(i).Profile(j).dX=str2double(model.profiles(j).profile.dx);
        hm.Models(i).Profile(j).dY=str2double(model.profiles(j).profile.dy);
        hm.Models(i).Profile(j).DistBluff=str2double(model.profiles(j).profile.distbluff);
        hm.Models(i).Profile(j).Run=str2double(model.profiles(j).profile.run);
        if isfield(model.profiles(j).profile,'dtheta')
            hm.Models(i).Profile(j).dTheta=str2double(model.profiles(j).profile.dtheta);
        else
            hm.Models(i).Profile(j).dTheta=5;
        end
        if isfield(model.profiles(j).profile,'xgrid')
            hm.Models(i).Profile(j).xGrid = model.profiles(j).profile.xgrid;
        else
            hm.Models(i).Profile(j).xGrid = '';
        end
        if isfield(model.profiles(j).profile,'ygrid')
            hm.Models(i).Profile(j).yGrid = model.profiles(j).profile.ygrid;
        else
            hm.Models(i).Profile(j).yGrid = '';
        end
        if isfield(model.profiles(j).profile,'zgrid')
            hm.Models(i).Profile(j).zGrid = model.profiles(j).profile.zgrid;
        else
            hm.Models(i).Profile(j).zGrid = '';
        end
        if isfield(model.profiles(j).profile,'negrid')
            hm.Models(i).Profile(j).neGrid = model.profiles(j).profile.negrid;
        else
            hm.Models(i).Profile(j).neGrid = '';
        end
    end
end
