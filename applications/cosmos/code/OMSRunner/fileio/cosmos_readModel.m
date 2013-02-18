function [hm,ok]=cosmos_readModel(hm,fname,i)

ok=1;

% Read Model

model=xml_load(fname);

hm.models(i).run=1;
if isfield(model,'run')
    if str2double(model.run)==0
        % Skip this model
        ok=0;
        hm.models(i).run=0;
        return
    end
end

%% Stations, maps and profiles
hm.models(i).nrStations=0;
hm.models(i).nrMaps=0;
hm.models(i).nrProfiles=0;

%% Names
hm.models(i).longName=model.longname;
hm.models(i).name=model.name;
hm.models(i).continent=model.continent;
hm.models(i).dir=[hm.scenarioDir 'models' filesep model.continent filesep model.name filesep];

% Website
if isfield(model,'websites')
    for j=1:length(model.websites)
        hm.models(i).webSite(j).name=model.websites(j).website.name;
        hm.models(i).webSite(j).Location=[];
        hm.models(i).webSite(j).elevation=[];
        hm.models(i).webSite(j).overlayFile=[];
        hm.models(i).webSite(j).positionToDisplay=[];
        if isfield(model.websites(j).website,'locationx') && isfield(model.websites(j).website,'locationy')
            hm.models(i).webSite(j).Location(1)=str2double(model.websites(j).website.locationx);
            hm.models(i).webSite(j).Location(2)=str2double(model.websites(j).website.locationy);
        elseif isfield(model.websites(j).website,'longitude') && isfield(model.websites(j).website,'latitude')
            hm.models(i).webSite(j).Location(1)=str2double(model.websites(j).website.longitude);
            hm.models(i).webSite(j).Location(2)=str2double(model.websites(j).website.latitude);
        end
        if isfield(model.websites(j).website,'elevation')
            hm.models(i).webSite(j).elevation=str2double(model.websites(j).website.elevation);
        end
        if isfield(model.websites(j).website,'overlay')
            hm.models(i).webSite(j).overlayFile=model.websites(j).website.overlay;
        end
        if isfield(model.websites(j).website,'positiontodisplay')
            hm.models(i).webSite(j).positionToDisplay=str2double(model.websites(j).website.positiontodisplay);
        else
            hm.models(i).webSite(j).positionToDisplay=-1;
        end
    end
else
    hm.models(i).webSite(1).name=model.website;
    hm.models(i).webSite(1).Location(1)=str2double(model.locationx);
    hm.models(i).webSite(1).Location(2)=str2double(model.locationy);
    hm.models(i).webSite(1).overlayFile=[];
end

hm.models(i).archiveDir=[hm.archiveDir model.continent filesep model.name filesep 'archive' filesep];
hm.models(i).type=model.type;
hm.models(i).coordinateSystem=model.coordsys;
hm.models(i).coordinateSystemType=model.coordsystype;
hm.models(i).runid=model.runid;

%% Roller model
hm.models(i).roller=0;
if isfield(model,'roller')
    hm.models(i).roller=str2double(model.roller);
end

%% Time zone
if isfield(model,'timezone')
    hm.models(i).timeZone=model.timezone;
else
    hm.models(i).timeZone=[];
end

if isfield(model,'runenv')
    hm.models(i).runEnv=model.runenv;
else
    hm.models(i).runEnv=hm.runEnv;
end
if isfield(model,'numcores')
    hm.models(i).numCores=model.numcores;
else
    hm.models(i).numCores=hm.numCores;
end

%% BeachWizard
hm.models(i).beachWizard=[];
if isfield(model,'beachwizard')
    hm.models(i).beachWizard=model.beachwizard;
end

hm.models(i).figureURL='';

%% Domain

if isfield(model,'thick')
    fname=model.thick;
    fname=[hm.models(i).dir 'input' filesep fname];
    thck=load(fname);
    hm.models(i).KMax=length(thck);
    hm.models(i).thick=thck;
else
    hm.models(i).KMax=1;
    hm.models(i).thick(1)=100;
end

if isfield(model,'ztop')
    hm.models(i).zTop=str2double(model.ztop);
else
    hm.models(i).zTop=0;
end

if isfield(model,'zbot')
    hm.models(i).zBot=str2double(model.zbot);
else
    hm.models(i).zBot=0;
end

if isfield(model,'layertype')
    hm.models(i).layerType=model.layertype;
else
    hm.models(i).layerType='sigma';
end

%% Initial conditions
if isfield(model,'zeta0')
    hm.models(i).zeta0=str2double(model.zeta0);
else
    hm.models(i).zeta0=0;
end

%% Time
if isfield(model,'timestep')
    hm.models(i).timeStep=str2double(model.timestep);
else
    hm.models(i).timeStep=0;
end
if isfield(model,'runtime')
    hm.models(i).runTime=str2double(model.runtime);
else
    hm.models(i).runTime=999;
end
if isfield(model,'starttime')
    hm.models(i).startTime=str2double(model.starttime);
else
    hm.models(i).startTime=0;
end
if isfield(model,'wavetimestep')
    hm.models(i).waveTimeStep=str2double(model.wavetimestep);
else
    hm.models(i).waveTimeStep=30;
end
hm.models(i).flowSpinUp=str2double(model.flowspinup);
hm.models(i).waveSpinUp=str2double(model.wavespinup);
if isfield(model,'histimestep')
    hm.models(i).hisTimeStep=str2double(model.histimestep);
else
    hm.models(i).hisTimeStep=1;
end
if isfield(model,'maptimestep')
    hm.models(i).mapTimeStep=str2double(model.maptimestep);
else
    hm.models(i).mapTimeStep=60;
end
if isfield(model,'comtimestep')
    hm.models(i).comTimeStep=str2double(model.comtimestep);
else
    hm.models(i).comTimeStep=0;
end
if isfield(model,'maptimestep')
    hm.models(i).wavmTimeStep=str2double(model.maptimestep);
else
    hm.models(i).wavmTimeStep=0;
end
if isfield(model,'priority')
    hm.models(i).priority=str2double(model.priority);
else
    hm.models(i).priority=0;
end

hm.models(i).deleterestartfiles=1;
if isfield(model,'deleterestartfiles')
    if strcmpi(model.deleterestartfiles(1),'n') || strcmpi(model.deleterestartfiles(1),'0')
        hm.models(i).deleterestartfiles=0;
    end
end

%% Parameters

if isfield(model,'roumet')
    hm.models(i).RouMet=model.roumet;
else
    hm.models(i).RouMet='M';
end
if isfield(model,'ccofu')
    hm.models(i).ccofu=str2double(model.ccofu);
else
    hm.models(i).ccofu=0.022;
end
if isfield(model,'dpsopt')
    hm.models(i).DpsOpt=model.dpsopt;
else
    hm.models(i).DpsOpt='MAX';
end
if isfield(model,'vicouv')
    hm.models(i).VicoUV=str2double(model.vicouv);
else
    hm.models(i).VicoUV=1;
end
if isfield(model,'dicouv')
    hm.models(i).DicoUV=str2double(model.dicouv);
else
    hm.models(i).DicoUV=1;
end
if isfield(model,'filedy')
    hm.models(i).Filedy=model.filedy;
else
    hm.models(i).Filedy=[];    
end
if isfield(model,'momsol')
    hm.models(i).momSol=model.momsol;
else
    hm.models(i).momSol='Cyclic';
end
if isfield(model,'cstbnd')
    hm.models(i).cstBnd=str2double(model.cstbnd);
else
    hm.models(i).cstBnd=0;
end
hm.models(i).SMVelo='euler';
if isfield(model,'smvelo')
    if strcmpi(model.smvelo,'glm')
        hm.models(i).SMVelo='GLM';
    end
end

hm.models(i).nonstationary=1;
if isfield(model,'stationary')
    if strcmpi(model.stationary(1),'y') || strcmpi(model.stationary(1),'1')
        hm.models(i).nonstationary=0;
    end
end

hm.models(i).dirSpace='circle';
hm.models(i).nDirBins=36;

if isfield(model,'dirspace')
    hm.models(i).dirSpace=model.dirspace;
end
if isfield(model,'ndirbins')
    hm.models(i).nDirBins=str2double(model.ndirbins);
end
if isfield(model,'startdir')
    hm.models(i).startDir=str2double(model.startdir);
end
if isfield(model,'enddir')
    hm.models(i).endDir=str2double(model.enddir);
end

if isfield(model,'flowwaterlevel')
    hm.models(i).flowWaterLevel=str2double(model.flowwaterlevel);
else
    hm.models(i).flowWaterLevel=1;
end
if isfield(model,'flowvelocity')
    hm.models(i).flowVelocity=str2double(model.flowvelocity);
else
    hm.models(i).flowVelocity=0;
end
if isfield(model,'flowbedlevel')
    hm.models(i).flowBedLevel=str2double(model.flowbedlevel);
else
    hm.models(i).flowBedLevel=1;
end
if isfield(model,'flowwind')
    hm.models(i).flowWind=str2double(model.flowwind);
else
    hm.models(i).flowWind=1;
end
if isfield(model,'maxiter')
    hm.models(i).maxIter=str2double(model.maxiter);
else
    hm.models(i).maxIter=2;
end
if isfield(model,'morfac')
    hm.models(i).morFac=str2double(model.morfac);
else
    hm.models(i).morFac=1;
end
if isfield(model,'wavebedfric')
    hm.models(i).waveBedFric=model.wavebedfric;
else
    hm.models(i).waveBedFric='jonswap';
end
if isfield(model,'wavebedfriccoef')
    hm.models(i).waveBedFricCoef=str2double(model.wavebedfriccoef);
else
    hm.models(i).waveBedFricCoef=0.067;
end

if isfield(model,'whitecapping')
    hm.models(i).whiteCapping=model.whitecapping;
else
    hm.models(i).whiteCapping='Westhuysen';
end

hm.models(i).windStress=[6.3000000e-004  0.0000000e+000  7.2300000e-003  1.0000000e+002];

if isfield(model,'windstress')
    hm.models(i).windStress=str2num(model.windstress);
end

hm.models(i).useDtAirSea=0;
if isfield(model,'dtairsea')
    if strcmpi(model.dtairsea(1),'y')
        hm.models(i).useDtAirSea=1;
    end
end

hm.models(i).useTidalForces=0;
if isfield(model,'tidalforces')
    if strcmpi(model.tidalforces(1),'y')
        hm.models(i).useTidalForces=1;
    end
end

hm.models(i).tmzRad=[];
hm.models(i).includeTemperature=0;
hm.models(i).includeHeatExchange=0;
if isfield(model,'temperature')
    if strcmpi(model.temperature(1),'y')
        hm.models(i).includeTemperature=1;
        hm.models(i).includeHeatExchange=1;
    end
    if isfield(model,'tmzrad')
        hm.models(i).tmzRad=str2double(model.tmzrad);
    end
end
if isfield(model,'heatexchange')
    if strcmpi(model.heatexchange(1),'y')
        hm.models(i).includeHeatExchange=1;
    else        
        hm.models(i).includeHeatExchange=0;
    end
end

hm.models(i).includeAirPressure=1;
if isfield(model,'airpressure')
    if strcmpi(model.airpressure(1),'n')
        hm.models(i).includeAirPressure=0;
    end
end

hm.models(i).includeSalinity=0;
if isfield(model,'salinity')
    if strcmpi(model.salinity(1),'y')
        hm.models(i).includeSalinity=1;
    end
end

hm.models(i).nudge=0;
if isfield(model,'nudge')
    if strcmpi(model.nudge(1),'y')
        hm.models(i).nudge=1;
    end
end

% Discharges
hm.models(i).discharge=[];
if isfield(model,'discharges')
    for j=1:length(model.discharges)
        % defaults
        hm.models(i).discharge(j).interpolation='linear';
        hm.models(i).discharge(j).type='regular';
        
        hm.models(i).discharge(j).name=model.discharges(j).discharge.name;
        hm.models(i).discharge(j).m=str2double(model.discharges(j).discharge.m);
        hm.models(i).discharge(j).N=str2double(model.discharges(j).discharge.n);
        hm.models(i).discharge(j).K=str2double(model.discharges(j).discharge.k);
        
        if isfield(model.discharges(j).discharge,'interpolation')
            hm.models(i).discharge(j).interpolation=model.discharges(j).discharge.interpolation;
        end
        
        hm.models(i).discharge(j).q=str2double(model.discharges(j).discharge.q);
        if isfield(model.discharges(j).discharge,'salinity')
            hm.models(i).discharge(j).salinity.constant=str2double(model.discharges(j).discharge.salinity);
        end
        if isfield(model.discharges(j).discharge,'temperature')
            hm.models(i).discharge(j).temperature.constant=str2double(model.discharges(j).discharge.temperature);
        end
        if isfield(model.discharges(j).discharge,'tracer1')
            hm.models(i).discharge(j).tracer(1).constant=str2double(model.discharges(j).discharge.tracer1);
        end
        if isfield(model.discharges(j).discharge,'tracer2')
            hm.models(i).discharge(j).tracer(2).constant=str2double(model.discharges(j).discharge.tracer2);
        end
        if isfield(model.discharges(j).discharge,'tracer3')
            hm.models(i).discharge(j).tracer(3).constant=str2double(model.discharges(j).discharge.tracer3);
        end
        
    end
end

% Tracers
hm.models(i).tracer=[];
if isfield(model,'tracers')
    for j=1:length(model.discharges)
        hm.models(i).tracer(j).name=model.tracers(j).tracer.name;
        hm.models(i).tracer(j).decay=0;
        if isfield(model.tracers(j).tracer,'decay')
            hm.models(i).tracer(j).decay=str2double(model.tracers(j).tracer.decay);
        end
    end
end


%% Locations
hm.models(i).size=str2double(model.size);
try
    hm.models(i).xLim(1)=str2double(model.xlim1);
end
try
    hm.models(i).xLim(2)=str2double(model.xlim2);
end
try
    hm.models(i).yLim(1)=str2double(model.ylim1);
end
try
    hm.models(i).yLim(2)=str2double(model.ylim2);
end
try
    hm.models(i).xLimPlot=hm.models(i).xLim;
end
try
    hm.models(i).yLimPlot=hm.models(i).yLim;
end

if isfield(model,'xlimplot1')
    hm.models(i).xLimPlot(1)=str2double(model.xlimplot1);
    hm.models(i).xLimPlot(2)=str2double(model.xlimplot2);
    hm.models(i).yLimPlot(1)=str2double(model.ylimplot1);
    hm.models(i).yLimPlot(2)=str2double(model.ylimplot2);
end

if isfield(model,'zlevel')
    hm.models(i).zLevel=str2double(model.zlevel);
else
    hm.models(i).zLevel=0;
end

if isfield(model,'zslr')
    hm.models(i).zSeaLevelRise=str2double(model.zslr);
else
    hm.models(i).zSeaLevelRise=0;
end

if isfield(model,'xori')
    hm.models(i).xOri=str2double(model.xori);
end
if isfield(model,'yori')
    hm.models(i).yOri=str2double(model.yori);
end
if isfield(model,'dx')
    hm.models(i).dX=str2double(model.dx);
end
if isfield(model,'dy')
    hm.models(i).dY=str2double(model.dy);
end
if isfield(model,'nx')
    hm.models(i).nX=str2double(model.nx);
end
if isfield(model,'ny')
    hm.models(i).nY=str2double(model.ny);
end
if isfield(model,'alpha')
    hm.models(i).alpha=str2double(model.alpha);
end

%% Nesting

% Flow
if isfield(model,'flownested')
    hm.models(i).flowNestModel=model.flownested;
    if strcmpi(model.flownested,'none')
        hm.models(i).flowNested=0;
    else
        hm.models(i).flowNested=1;
    end
else
    hm.models(i).flowNestModel='';
    hm.models(i).flowNested=0;
end

hm.models(i).oceanModel='';
if isfield(model,'oceanmodel')
    hm.models(i).oceanModel=model.oceanmodel;
end
hm.models(i).oceanmodelnesttype='file+astro';
if isfield(model,'oceanmodelnesttype')
    hm.models(i).oceanmodelnesttype=model.oceanmodelnesttype;
end
hm.models(i).wlboundarycorrection=0;
if isfield(model,'wlboundarycorrection')
    hm.models(i).wlboundarycorrection=str2double(model.wlboundarycorrection);
end
if isfield(model,'flownesttype')
    hm.models(i).flowNestType=model.flownesttype;
else
    hm.models(i).flowNestType='regular';
end

if isfield(model,'flownestxml')
    hm.models(i).flowNestXML=model.flownestedxml;
else
    hm.models(i).flowNestXML=[];
end

% Wave
hm.models(i).waveNestNr=0;
if isfield(model,'wavenested')
    hm.models(i).waveNestModel=model.wavenested;
    if strcmpi(model.wavenested,'none')
        hm.models(i).waveNested=0;
    else
        hm.models(i).waveNested=1;
        if isfield(model,'wavenestnr')
            hm.models(i).waveNestNr=str2double(model.wavenestnr);
        end
    end
else
    hm.models(i).waveNestModel='';
    hm.models(i).waveNested=0;
end

%% Initial conditions
hm.models(i).makeIniFile=0;
if isfield(model,'makeinifile')
    if strcmpi(model.makeinifile(1),'y')
        hm.models(i).makeIniFile=1;
    end
end

%% Meteo
if isfield(model,'usemeteo')
    hm.models(i).useMeteo=model.usemeteo;
else
    hm.models(i).useMeteo='none';
end
if isfield(model,'meteobackup1')
    hm.models(i).backupMeteo=model.meteobackup1;
else
    hm.models(i).backupMeteo='none';
end
if isfield(model,'prcorr')
    hm.models(i).prCorr=str2double(model.prcorr);
else
    hm.models(i).prCorr=101200.0;
end
if isfield(model,'applypressurecorrection')
    hm.models(i).applyPressureCorrection=str2double(model.applypressurecorrection);
else
    hm.models(i).applyPressureCorrection=0;
end
if isfield(model,'dxmeteo')
    hm.models(i).dXMeteo=str2double(model.dxmeteo);
else
    hm.models(i).dXMeteo=5000.0;
end
hm.models(i).dYMeteo=hm.models(i).dXMeteo;

%% XBeach
if isfield(model,'morfac')
    hm.models(i).morFac=model.morfac;
else
    hm.models(i).morFac=0;
end


%% Stations
if isfield(model,'stations')
    j=0;
    switch lower(model.type)
        case{'delft3dflow','delft3dflowwave'}
            GRID = wlgrid('read', [hm.models(i).dir 'input' filesep hm.models(i).name '.grd']);
            GRID.Z = -10*zeros(size(GRID.X));
    end
    for istat=1:length(model.stations)
        iac=1;
        if isfield(model.stations(istat).station,'active')
            iac=str2double(model.stations(istat).station.active);
        end
        
        
        if iac
            switch lower(model.type)
                case{'delft3dflow','delft3dflowwave'}
                    if ~isfield(model.stations(istat).station,'locationm')
                        [m n iindex] = ddb_findStations(str2double(model.stations(istat).station.locationx),...
                            str2double(model.stations(istat).station.locationy),GRID.X,GRID.Y,GRID.Z);
                        if isempty(m)
                            iac=0;
                        else
                            model.stations(istat).station.locationm=num2str(m);
                            model.stations(istat).station.locationn=num2str(n);
                        end
                    end
            end
        end
        
        if iac
            
            j=j+1;
            hm.models(i).nrStations=j;
            
            hm.models(i).stations(j).name=model.stations(istat).station.name;
            hm.models(i).stations(j).longName=model.stations(istat).station.longname;
            hm.models(i).stations(j).location(1)=str2double(model.stations(istat).station.locationx);
            hm.models(i).stations(j).location(2)=str2double(model.stations(istat).station.locationy);
            if isfield(model.stations(istat).station,'locationm')
                hm.models(i).stations(j).m=str2double(model.stations(istat).station.locationm);
                hm.models(i).stations(j).n=str2double(model.stations(istat).station.locationn);
            end
            hm.models(i).stations(j).type=model.stations(istat).station.type;
            if isfield(model.stations(istat).station,'toopendap')
                hm.models(i).stations(j).toOPeNDAP=str2double(model.stations(istat).station.toopendap);
            else
                hm.models(i).stations(j).toOPeNDAP=0;
            end
            
            if isfield(model.stations(istat).station,'toOPeNDAP')
                hm.models(i).stations(j).toOPeNDAP=str2double(model.stations(istat).station.toOPeNDAP);
            else
                hm.models(i).stations(j).toOPeNDAP=0;
            end
            
            if isfield(model.stations(istat).station,'timezone')
                % Use time zone specified in station
                hm.models(i).stations(j).timeZone=model.stations(istat).station.timezone;
            else
                % Use model time
                hm.models(i).stations(j).timeZone=hm.models(i).timeZone;
            end
            
            %% Time-series datasets
            hm.models(i).stations(j).nrDatasets=0;
            if isfield(model.stations(istat).station,'datasets')
                hm.models(i).stations(j).nrDatasets=length(model.stations(istat).station.datasets);
                for k=1:hm.models(i).stations(j).nrDatasets
                    hm.models(i).stations(j).datasets(k).parameter=model.stations(istat).station.datasets(k).dataset.parameter;
                    hm.models(i).stations(j).datasets(k).layer=[];
                    hm.models(i).stations(j).datasets(k).sp2id=hm.models(i).stations(j).name;
                    hm.models(i).stations(j).datasets(k).toOPeNDAP=hm.models(i).stations(j).toOPeNDAP;
                    if isfield(model.stations(istat).station.datasets(k).dataset,'layer')
                        hm.models(i).stations(j).datasets(k).layer=str2double(model.stations(istat).station.datasets(k).dataset.layer);
                    end
                    if isfield(model.stations(istat).station.datasets(k).dataset,'sp2id')
                        hm.models(i).stations(j).datasets(k).sp2id=model.stations(istat).station.datasets(k).dataset.sp2id;
                    end
                    if isfield(model.stations(istat).station.datasets(k).dataset,'toopendap')
                        hm.models(i).stations(j).datasets(k).toOPeNDAP=str2double(model.stations(istat).station.datasets(k).dataset.toopendap);
                    end
                end
            end
            
            hm.models(i).stations(j).plots=[];
            %% Time-series plots
            if isfield(model.stations(istat).station,'plots')
                hm.models(i).stations(j).nrPlots=length(model.stations(istat).station.plots);
                for k=1:hm.models(i).stations(j).nrPlots
                    hm.models(i).stations(j).plots(k).type='timeseries';
                    if isfield(model.stations(istat).station.plots(k).plot,'type')
                        hm.models(i).stations(j).plots(k).type=model.stations(istat).station.plots(k).plot.type;
                    end
                    hm.models(i).stations(j).plots(k).nrDatasets=length(model.stations(istat).station.plots(k).plot.datasets);
                    for id=1:length(model.stations(istat).station.plots(k).plot.datasets)
                        hm.models(i).stations(j).plots(k).datasets(id).parameter=model.stations(istat).station.plots(k).plot.datasets(id).dataset.parameter;
                        hm.models(i).stations(j).plots(k).datasets(id).type=model.stations(istat).station.plots(k).plot.datasets(id).dataset.type;
                        hm.models(i).stations(j).plots(k).datasets(id).source=[];
                        hm.models(i).stations(j).plots(k).datasets(id).id=[];
                        if isfield(model.stations(istat).station.plots(k).plot.datasets(id).dataset,'source')
                            hm.models(i).stations(j).plots(k).datasets(id).source=model.stations(istat).station.plots(k).plot.datasets(id).dataset.source;
                        end
                        if isfield(model.stations(istat).station.plots(k).plot.datasets(id).dataset,'id')
                            hm.models(i).stations(j).plots(k).datasets(id).id=model.stations(istat).station.plots(k).plot.datasets(id).dataset.id;
                        end
                    end
                    hm.models(i).stations(j).storeSP2=0;
                end
            end
        end
    end
end

% hm.models(i).stations(j).nrParameters=length(model.stations(j).station.parameters);
%
%         %% Parameters
%         hm.models(i).stations(j).nrParameters=length(model.stations(j).station.parameters);
%         for k=1:hm.models(i).stations(j).nrParameters
%
%             % Defaults
%             hm.models(i).stations(j).parameters(k).plotCmp=0;
%             hm.models(i).stations(j).parameters(k).plotObs=0;
%             hm.models(i).stations(j).parameters(k).plotPrd=0;
%             hm.models(i).stations(j).parameters(k).obsCode='';
%             hm.models(i).stations(j).parameters(k).prdCode='';
%             hm.models(i).stations(j).parameters(k).obsID='';
%             hm.models(i).stations(j).parameters(k).prdID='';
%             hm.models(i).stations(j).parameters(k).layer=[];
%             hm.models(i).stations(j).parameters(k).toOPeNDAP=0;
%
%             hm.models(i).stations(j).parameters(k).name=model.stations(j).station.parameters(k).parameter.name;
%
%             if isfield(model.stations(j).station.parameters(k).parameter,'plotcmp')
%                 hm.models(i).stations(j).parameters(k).plotCmp=str2double(model.stations(j).station.parameters(k).parameter.plotcmp);
%             end
%
%             if isfield(model.stations(j).station.parameters(k).parameter,'plotobs')
%                 hm.models(i).stations(j).parameters(k).plotObs=str2double(model.stations(j).station.parameters(k).parameter.plotobs);
%             end
%             if isfield(model.stations(j).station.parameters(k).parameter,'obssrc')
%                 hm.models(i).stations(j).parameters(k).obsSrc=model.stations(j).station.parameters(k).parameter.obssrc;
%             end
%             if isfield(model.stations(j).station.parameters(k).parameter,'obsid')
%                 hm.models(i).stations(j).parameters(k).obsID=model.stations(j).station.parameters(k).parameter.obsid;
%             end
%
%             if isfield(model.stations(j).station.parameters(k).parameter,'plotprd')
%                 hm.models(i).stations(j).parameters(k).plotPrd=str2double(model.stations(j).station.parameters(k).parameter.plotprd);
%             end
%             if isfield(model.stations(j).station.parameters(k).parameter,'prdsrc')
%                 hm.models(i).stations(j).parameters(k).prdSrc=model.stations(j).station.parameters(k).parameter.prdsrc;
%             end
%             if isfield(model.stations(j).station.parameters(k).parameter,'prdid')
%                 hm.models(i).stations(j).parameters(k).prdID=model.stations(j).station.parameters(k).parameter.prdid;
%             end
%             if isfield(model.stations(j).station.parameters(k).parameter,'layer')
%                 hm.models(i).stations(j).parameters(k).layer=str2double(model.stations(j).station.parameters(k).parameter.layer);
%             end
%             if isfield(model.stations(j).station.parameters(k).parameter,'toopendap')
%                 hm.models(i).stations(j).parameters(k).toOPeNDAP=str2double(model.stations(j).station.parameters(k).parameter.toopendap);
%             end
%
%         end
%     end
% end

%% Map Datasets
hm.models(i).nrMapDatasets=0;
if isfield(model,'mapdatasets')
    hm.models(i).nrMapDatasets=length(model.mapdatasets);
    for j=1:hm.models(i).nrMapDatasets
        hm.models(i).mapDatasets(j).name=model.mapdatasets(j).dataset.name;
        hm.models(i).mapDatasets(j).layer=[];
        if isfield(model.mapdatasets(j).dataset,'layer')
            hm.models(i).mapDatasets(j).layer=str2double(model.mapdatasets(j).dataset.layer);
        end
    end
end

%% Map plots
hm.models(i).nrMapPlots=0;
if isfield(model,'mapplots')
    hm.models(i).nrMapPlots=length(model.mapplots);
    for j=1:hm.models(i).nrMapPlots
        
        hm.models(i).mapPlots(j).name=model.mapplots(j).mapplot.name;
        hm.models(i).mapPlots(j).longName=model.mapplots(j).mapplot.longname;
        
        hm.models(i).mapPlots(j).timeStep=[];
        if isfield(model.mapplots(j).mapplot,'timestep')
            hm.models(i).mapPlots(j).timeStep=str2double(model.mapplots(j).mapplot.timestep);
        end
        
        hm.models(i).mapPlots(j).plot=1;
        if isfield(model.mapplots(j).mapplot,'plot')
            hm.models(i).mapPlots(j).plot=str2double(model.mapplots(j).mapplot.plot);
        end

        hm.models(i).mapPlots(j).type='kmz';
        if isfield(model.mapplots(j).mapplot,'type')
            hm.models(i).mapPlots(j).type=model.mapplots(j).mapplot.type;
        end

        if isfield(model.mapplots(j).mapplot,'datasets')
            
            hm.models(i).mapPlots(j).nrDatasets=length(model.mapplots(j).mapplot.datasets);
            
            for k=1:hm.models(i).mapPlots(j).nrDatasets
                
                hm.models(i).mapPlots(j).datasets(k).name=model.mapplots(j).mapplot.datasets(k).dataset.name;
                
                hm.models(i).mapPlots(j).datasets(k).plotRoutine='patches';
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'plotroutine')
                    hm.models(i).mapPlots(j).datasets(k).plotRoutine=model.mapplots(j).mapplot.datasets(k).dataset.plotroutine;
                end
                
                hm.models(i).mapPlots(j).datasets(k).plot=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'plot')
                    hm.models(i).mapPlots(j).datasets(k).plot=str2num(model.mapplots(j).mapplot.datasets(k).dataset.plot);
                end
                
                hm.models(i).mapPlots(j).datasets(k).component='magnitude';
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'component')
                    hm.models(i).mapPlots(j).datasets(k).component=model.mapplots(j).mapplot.datasets(k).dataset.component;
                end
                
                hm.models(i).mapPlots(j).datasets(k).arrowLength=3600;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'arrowlength')
                    hm.models(i).mapPlots(j).datasets(k).arrowLength=str2num(model.mapplots(j).mapplot.datasets(k).dataset.arrowlength);
                end
                
                hm.models(i).mapPlots(j).datasets(k).spacing=10000;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'spacing')
                    hm.models(i).mapPlots(j).datasets(k).spacing=str2num(model.mapplots(j).mapplot.datasets(k).dataset.spacing);
                end
                
                hm.models(i).mapPlots(j).datasets(k).thinning=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'thinning')
                    hm.models(i).mapPlots(j).datasets(k).thinning=str2num(model.mapplots(j).mapplot.datasets(k).dataset.thinning);
                end
                
                hm.models(i).mapPlots(j).datasets(k).thinningX=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'thinningx')
                    hm.models(i).mapPlots(j).datasets(k).thinningX=str2num(model.mapplots(j).mapplot.datasets(k).dataset.thinningx);
                end
                
                hm.models(i).mapPlots(j).datasets(k).thinningY=1;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'thinningy')
                    hm.models(i).mapPlots(j).datasets(k).thinningY=str2num(model.mapplots(j).mapplot.datasets(k).dataset.thinningy);
                end
                
                hm.models(i).mapPlots(j).datasets(k).cLim=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'clim')
                    hm.models(i).mapPlots(j).datasets(k).cLim=str2num(model.mapplots(j).mapplot.datasets(k).dataset.clim);
                end

                hm.models(i).mapPlots(j).datasets(k).cMinCutOff=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'cmincutoff')
                    hm.models(i).mapPlots(j).datasets(k).cMinCutOff=str2num(model.mapplots(j).mapplot.datasets(k).dataset.cmincutoff);
                end
                
                hm.models(i).mapPlots(j).datasets(k).cMaxCutOff=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'cmaxcutoff')
                    hm.models(i).mapPlots(j).datasets(k).cMaxCutOff=str2num(model.mapplots(j).mapplot.datasets(k).dataset.cmaxcutoff);
                end
                
                hm.models(i).mapPlots(j).datasets(k).polygon=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'polygon')
                    hm.models(i).mapPlots(j).datasets(k).polygon=model.mapplots(j).mapplot.datasets(k).dataset.polygon;
                end
                
                hm.models(i).mapPlots(j).datasets(k).relativeSpeed=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'relativespeed')
                    hm.models(i).mapPlots(j).datasets(k).relativeSpeed=str2num(model.mapplots(j).mapplot.datasets(k).dataset.relativespeed);
                end
                
                hm.models(i).mapPlots(j).datasets(k).scaleFactor=0.001;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'scalefactor')
                    hm.models(i).mapPlots(j).datasets(k).scaleFactor=str2num(model.mapplots(j).mapplot.datasets(k).dataset.scalefactor);
                end
                
                hm.models(i).mapPlots(j).datasets(k).colorBarDecimals=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'colorbardecimals')
                    hm.models(i).mapPlots(j).datasets(k).colorBarDecimals=str2num(model.mapplots(j).mapplot.datasets(k).dataset.colorbardecimals);
                end
                
                hm.models(i).mapPlots(j).datasets(k).colorMap=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'colormap')
                    hm.models(i).mapPlots(j).datasets(k).colorMap=model.mapplots(j).mapplot.datasets(k).dataset.colormap;
                end
                
                hm.models(i).mapPlots(j).datasets(k).barLabel=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'barlabel')
                    hm.models(i).mapPlots(j).datasets(k).barLabel=model.mapplots(j).mapplot.datasets(k).dataset.barlabel;
                end

                % Argus merged image
                hm.models(i).mapPlots(j).datasets(k).argusstation=[];
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'argusstation')
                    hm.models(i).mapPlots(j).datasets(k).argusstation=model.mapplots(j).mapplot.datasets(k).dataset.argusstation;
                end
                hm.models(i).mapPlots(j).datasets(k).argusxorigin=0;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'argusxorigin')
                    hm.models(i).mapPlots(j).datasets(k).argusxorigin=str2num(model.mapplots(j).mapplot.datasets(k).dataset.argusxorigin);
                end
                hm.models(i).mapPlots(j).datasets(k).argusyorigin=0;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'argusyorigin')
                    hm.models(i).mapPlots(j).datasets(k).argusyorigin=str2num(model.mapplots(j).mapplot.datasets(k).dataset.argusyorigin);
                end
                hm.models(i).mapPlots(j).datasets(k).arguswidth=0;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'arguswidth')
                    hm.models(i).mapPlots(j).datasets(k).arguswidth=str2num(model.mapplots(j).mapplot.datasets(k).dataset.arguswidth);
                end
                hm.models(i).mapPlots(j).datasets(k).argusheight=0;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'argusheight')
                    hm.models(i).mapPlots(j).datasets(k).argusheight=str2num(model.mapplots(j).mapplot.datasets(k).dataset.argusheight);
                end
                hm.models(i).mapPlots(j).datasets(k).argusrotation=0;
                if isfield(model.mapplots(j).mapplot.datasets(k).dataset,'argusrotation')
                    hm.models(i).mapPlots(j).datasets(k).argusrotation=str2num(model.mapplots(j).mapplot.datasets(k).dataset.argusrotation);
                end
                
                
                
            end
        end
    end
end

%% Hazards
hm.models(i).nrHazards=0;
hm.models(i).hazards=[];
if isfield(model,'hazards')
    hm.models(i).nrHazards=length(model.hazards);
    for j=1:hm.models(i).nrHazards
        hm.models(i).hazards(j).type=model.hazards(j).hazard.type;
        hm.models(i).hazards(j).name=model.hazards(j).hazard.name;
        hm.models(i).hazards(j).longName=model.hazards(j).hazard.longname;
        hm.models(i).hazards(j).location(1)=str2double(model.hazards(j).hazard.locationx);
        hm.models(i).hazards(j).location(2)=str2double(model.hazards(j).hazard.locationy);
        hm.models(i).hazards(j).wlStation=[];
        if isfield(model.hazards(j).hazard,'wlstation')
            hm.models(i).hazards(j).wlStation=model.hazards(j).hazard.wlstation;
        end
        hm.models(i).hazards(j).geoJpgFile=[];
        if isfield(model.hazards(j).hazard,'geojpgfile')
            hm.models(i).hazards(j).geoJpgFile=model.hazards(j).hazard.geojpgfile;
        end
        hm.models(i).hazards(j).geoJgwFile=[];
        if isfield(model.hazards(j).hazard,'geojgwfile')
            hm.models(i).hazards(j).geoJgwFile=model.hazards(j).hazard.geojgwfile;
        end
        hm.models(i).hazards(j).x0=[];
        if isfield(model.hazards(j).hazard,'x0')
            hm.models(i).hazards(j).x0=str2double(model.hazards(j).hazard.x0);
        end
        hm.models(i).hazards(j).y0=[];
        if isfield(model.hazards(j).hazard,'y0')
            hm.models(i).hazards(j).y0=str2double(model.hazards(j).hazard.y0);
        end
        hm.models(i).hazards(j).coastOrientation=[];
        if isfield(model.hazards(j).hazard,'orientation')
            hm.models(i).hazards(j).coastOrientation=str2double(model.hazards(j).hazard.orientation);
        end
        hm.models(i).hazards(j).length1=[];
        if isfield(model.hazards(j).hazard,'length1')
            hm.models(i).hazards(j).length1=str2double(model.hazards(j).hazard.length1);
        end
        hm.models(i).hazards(j).length2=[];
        if isfield(model.hazards(j).hazard,'length2')
            hm.models(i).hazards(j).length2=str2double(model.hazards(j).hazard.length2);
        end
        hm.models(i).hazards(j).width1=[];
        if isfield(model.hazards(j).hazard,'width1')
            hm.models(i).hazards(j).width1=str2double(model.hazards(j).hazard.width1);
        end
        hm.models(i).hazards(j).width2=[];
        if isfield(model.hazards(j).hazard,'width2')
            hm.models(i).hazards(j).width2=str2double(model.hazards(j).hazard.width2);
        end
    end
end

% hm.models(i).mapPlots(j).plot=str2double(model.maps(j).map.plot);
%         hm.models(i).mapPlots(j).colorMap=model.maps(j).map.colormap;
%         hm.models(i).mapPlots(j).longName=model.maps(j).map.longname;
%         hm.models(i).mapPlots(j).shortName=model.maps(j).map.shortname;
%         hm.models(i).mapPlots(j).Unit=model.maps(j).map.unit;
%         if isfield(model.maps(j).map,'barlabel')
%             hm.models(i).mapPlots(j).BarLabel=model.maps(j).map.barlabel;
%         else
%             hm.models(i).mapPlots(j).BarLabel='';
%         end
%         if isfield(model.maps(j).map,'dtanim')
%             hm.models(i).mapPlots(j).dtAnim=str2double(model.maps(j).map.dtanim);
%         else
%             % Default animation time step is 3 hrs
%             hm.models(i).mapPlots(j).dtAnim=10800;
%         end
%         hm.models(i).mapPlots(j).Dataset.parameter=model.maps(j).map.parameter;
%         hm.models(i).mapPlots(j).Dataset.type=model.maps(j).map.type;
%
%         if isfield(model.maps(j).map,'dxcurvec')
%             hm.models(i).mapPlots(j).Dataset.DxCurVec=str2double(model.maps(j).map.dxcurvec);
%             hm.models(i).mapPlots(j).Dataset.DtCurVec=str2double(model.maps(j).map.dtcurvec);
%         end
%         hm.models(i).mapPlots(j).Dataset.DdtCurVec=3600;
%         if isfield(model.maps(j).map,'ddtcurvec')
%             hm.models(i).mapPlots(j).Dataset.DdtCurVec=str2double(model.maps(j).map.ddtcurvec);
%         end
%
%         if isfield(model.maps(j).map,'plotroutine')
%             hm.models(i).mapPlots(j).Dataset.plotRoutine=model.maps(j).map.plotroutine;
%         else
%             hm.models(i).mapPlots(j).Dataset.plotRoutine='PlotPatches';
%         end
%         if isfield(model.maps(j).map,'layer')
%             hm.models(i).mapPlots(j).Dataset.layer=str2double(model.maps(j).map.layer);
%         else
%             hm.models(i).mapPlots(j).Dataset.layer=[];
%         end
%         hm.models(i).mapPlots(j).Dataset.cLim=[];
%         if isfield(model.maps(j).map,'clim')
%             hm.models(i).mapPlots(j).Dataset.cLim=str2num(model.maps(j).map.clim);
%         end
%         hm.models(i).mapPlots(j).Dataset.polygon=[];
%         if isfield(model.maps(j).map,'polygon')
%             hm.models(i).mapPlots(j).Dataset.polygon=model.maps(j).map.polygon;
%         end
%         hm.models(i).mapPlots(j).colorBarDecimals=1;
%         if isfield(model.maps(j).map,'colorbardecimals')
%             hm.models(i).mapPlots(j).colorBarDecimals=str2num(model.maps(j).map.colorbardecimals);
%         end
%         hm.models(i).mapPlots(j).thinning=1;
%         if isfield(model.maps(j).map,'thinning')
%             hm.models(i).mapPlots(j).thinning=str2num(model.maps(j).map.thinning);
%         end
%         hm.models(i).mapPlots(j).thinningX=[];
%         if isfield(model.maps(j).map,'thinningx')
%             hm.models(i).mapPlots(j).thinningX=str2num(model.maps(j).map.thinningx);
%         end
%         hm.models(i).mapPlots(j).thinningY=[];
%         if isfield(model.maps(j).map,'thinningy')
%             hm.models(i).mapPlots(j).thinningY=str2num(model.maps(j).map.thinningy);
%         end
%         hm.models(i).mapPlots(j).scaleFactor=0.1;
%         if isfield(model.maps(j).map,'scalefactor')
%             hm.models(i).mapPlots(j).scaleFactor=str2num(model.maps(j).map.scalefactor);
%         end
%
% %         if ~isempty(hm.models(i).webSite)
% %             hm.models(i).mapPlots(j).Url=['http://dtvirt5.deltares.nl/~ormondt/' hm.models(i).webSite '/scenarios/' hm.scenario '/' hm.models(i).continent '/' hm.models(i).name '/figures/'];
% %         else
%             hm.models(i).mapPlots(j).Url='';
% %         end
%     end
% end
%
%% X-Beach Profiles
if isfield(model,'profiles')
    hm.models(i).nrProfiles=length(model.profiles);
    for j=1:hm.models(i).nrProfiles
        hm.models(i).profile(j).name=model.profiles(j).profile.name;
        hm.models(i).profile(j).Location(1)=str2double(model.profiles(j).profile.originx);
        hm.models(i).profile(j).Location(2)=str2double(model.profiles(j).profile.originy);
        hm.models(i).profile(j).originX=str2double(model.profiles(j).profile.originx);
        hm.models(i).profile(j).originY=str2double(model.profiles(j).profile.originy);
        hm.models(i).profile(j).alpha=str2double(model.profiles(j).profile.alpha);
        hm.models(i).profile(j).length=str2double(model.profiles(j).profile.length);
        hm.models(i).profile(j).nX=str2double(model.profiles(j).profile.nx);
        hm.models(i).profile(j).nY=str2double(model.profiles(j).profile.ny);
        hm.models(i).profile(j).dX=str2double(model.profiles(j).profile.dx);
        hm.models(i).profile(j).dY=str2double(model.profiles(j).profile.dy);
        hm.models(i).profile(j).DistBluff=str2double(model.profiles(j).profile.distbluff);
        hm.models(i).profile(j).run=str2double(model.profiles(j).profile.run);
        if isfield(model.profiles(j).profile,'dtheta')
            hm.models(i).profile(j).dTheta=str2double(model.profiles(j).profile.dtheta);
        else
            hm.models(i).profile(j).dTheta=5;
        end
        if isfield(model.profiles(j).profile,'xgrid')
            hm.models(i).profile(j).xGrid = model.profiles(j).profile.xgrid;
        else
            hm.models(i).profile(j).xGrid = '';
        end
        if isfield(model.profiles(j).profile,'ygrid')
            hm.models(i).profile(j).yGrid = model.profiles(j).profile.ygrid;
        else
            hm.models(i).profile(j).yGrid = '';
        end
        if isfield(model.profiles(j).profile,'zgrid')
            hm.models(i).profile(j).zGrid = model.profiles(j).profile.zgrid;
        else
            hm.models(i).profile(j).zGrid = '';
        end
        if isfield(model.profiles(j).profile,'negrid')
            hm.models(i).profile(j).neGrid = model.profiles(j).profile.negrid;
        else
            hm.models(i).profile(j).neGrid = '';
        end
    end
end
%% Forecast plots
if isfield(model,'forecastplot')
    
    hm.models(i).forecastplot.timeStep=[];
    if isfield(model.forecastplot,'timestep')
        hm.models(i).forecastplot.timeStep=str2double(model.forecastplot.timestep);
    end
    
    if isfield(model.forecastplot,'xlims')
        hm.models(i).forecastplot.xlims=str2num(model.forecastplot.xlims);
    end
    
    if isfield(model.forecastplot,'ylims')
        hm.models(i).forecastplot.ylims=str2num(model.forecastplot.ylims);
    end
    
    if isfield(model.forecastplot,'clims')
        hm.models(i).forecastplot.clims=str2num(model.forecastplot.clims);
    end
    
    if isfield(model.forecastplot,'scalefactor')
        hm.models(i).forecastplot.scalefactor=str2num(model.forecastplot.scalefactor);
    end
    
    if isfield(model.forecastplot,'thinning')
        hm.models(i).forecastplot.thinning=str2num(model.forecastplot.thinning);
    end
    
    if isfield(model.forecastplot,'ldb')
        hm.models(i).forecastplot.ldb=model.forecastplot.ldb;
    end
    
    if isfield(model.forecastplot,'name')
        hm.models(i).forecastplot.name=model.forecastplot.name;
    end
    
    if isfield(model.forecastplot,'wlstation')
        hm.models(i).forecastplot.wlstation=model.forecastplot.wlstation;
    end
    
    if isfield(model.forecastplot,'weatherstation')
        hm.models(i).forecastplot.weatherstation=model.forecastplot.weatherstation;
    end
    
    if isfield(model.forecastplot,'windstation')
        hm.models(i).forecastplot.windstation=str2num(model.forecastplot.windstation);
    end
    
    if isfield(model.forecastplot,'wavestation')
        hm.models(i).forecastplot.wavestation=model.forecastplot.wavestation;
    end
    
    if isfield(model.forecastplot,'waterstation')
        hm.models(i).forecastplot.waterstation=model.forecastplot.waterstation;
    end
    
    if isfield(model.forecastplot,'kmaxis')
        hm.models(i).forecastplot.kmaxis=str2num(model.forecastplot.kmaxis);
    end
    
    if isfield(model.forecastplot,'archive')
        hm.models(i).forecastplot.archive=str2double(model.forecastplot.archive);
    else
        hm.models(i).forecastplot.archive=0;
    end
    
    hm.models(i).forecastplot.plot=1;
    if isfield(model.forecastplot,'plot')
        hm.models(i).forecastplot.plot=str2double(model.forecastplot.plot);
    end
else
    hm.models(i).forecastplot.plot=0;
    hm.models(i).forecastplot.archive=0;
end

