function handles=ddb_initializeOceanModels(handles,varargin)

%% Read ocean models xml file
if ~isdir(handles.toolbox.oceanmodels.dataDir)
    mkdir(handles.toolbox.oceanmodels.dataDir)
end

ddb_getToolboxData(handles,handles.toolbox.oceanmodels.dataDir,'oceanmodels','OceanModels');

if ~exist([handles.toolbox.oceanmodels.dataDir 'OceanModels.xml'],'file')
    disp(['File ' handles.toolbox.oceanmodels.dataDir 'OceanModels.xml not found, cannot download data!']);
else

%    s.models=xml_load([handles.toolbox.oceanmodels.dataDir 'OceanModels.xml']);
    s=xml2struct([handles.toolbox.oceanmodels.dataDir 'OceanModels.xml']);
    
    for i=1:length(s.model)
        handles.toolbox.oceanmodels.oceanModel(i).name = s.model(i).model.name;
        handles.toolbox.oceanmodels.oceanModel(i).longName = s.model(i).model.longname;
        handles.toolbox.oceanmodels.oceanModel(i).URL = s.model(i).model.url;
        handles.toolbox.oceanmodels.oceanModel(i).type = s.model(i).model.type;
        if isfield(s.model(i).model,'gridcoordinates')
            handles.toolbox.oceanmodels.oceanModel(i).gridCoordinates = s.model(i).model.gridcoordinates;
        else
            handles.toolbox.oceanmodels.oceanModel(i).gridCoordinates=[];
        end
        if isfield(s.model(i).model,'region')
            handles.toolbox.oceanmodels.oceanModel(i).region = s.model(i).model.region;
        else
            handles.toolbox.oceanmodels.oceanModel(i).region=[];
        end
        handles.toolbox.oceanmodels.oceanModels{i} = s.model(i).model.longname;
    end
    
    %% Download
    
    handles.toolbox.oceanmodels.activeModel = 1;
    handles.toolbox.oceanmodels.startTime= floor(now)-10;
    handles.toolbox.oceanmodels.stopTime= floor(now)-5;
    handles.toolbox.oceanmodels.xLim=[0 0];
    handles.toolbox.oceanmodels.yLim=[0 0];
    handles.toolbox.oceanmodels.getSSH=1;
    handles.toolbox.oceanmodels.getCurrents=1;
    handles.toolbox.oceanmodels.getSalinity=1;
    handles.toolbox.oceanmodels.getTemperature=1;
    
    handles.toolbox.oceanmodels.name=handles.toolbox.oceanmodels.oceanModel(1).name;
    handles.toolbox.oceanmodels.folder=handles.toolbox.oceanmodels.oceanModel(1).name;
    handles.toolbox.oceanmodels.URL=handles.toolbox.oceanmodels.oceanModel(1).URL;
    
    handles.toolbox.oceanmodels.outlineHandle=[];
    
    
    %% Nesting
    
    % Hydro

    jj=strmatch('tpxo72',handles.tideModels.names,'exact');

    handles.toolbox.oceanmodels.autoWL=1;
    handles.toolbox.oceanmodels.activeTideModelWL=jj;
    handles.toolbox.oceanmodels.options.waterLevel.BC.source=1; % astro
    handles.toolbox.oceanmodels.options.waterLevel.BC.astroFile='';
    handles.toolbox.oceanmodels.options.waterLevel.BC.bndAstroFile='';
    handles.toolbox.oceanmodels.options.waterLevel.BC.constant=0;
    
    
    handles.toolbox.oceanmodels.autoCur=1;
    handles.toolbox.oceanmodels.activeTideModelCur=jj;
    handles.toolbox.oceanmodels.options.current.BC.source=1; % astro
    handles.toolbox.oceanmodels.options.current.BC.astroFile='';
    handles.toolbox.oceanmodels.options.current.BC.bndAstroFile='';
    
    handles.toolbox.oceanmodels.options.bctTimeStep=10;
    
    % Transport
    handles.toolbox.oceanmodels.options.salinity.BC.source=4; % constant
    handles.toolbox.oceanmodels.options.salinity.BC.profileFile='';
    handles.toolbox.oceanmodels.options.salinity.BC.constant=31;
    
    handles.toolbox.oceanmodels.options.temperature.BC.source=4; % constant
    handles.toolbox.oceanmodels.options.temperature.BC.profileFile='';
    handles.toolbox.oceanmodels.options.temperature.BC.constant=15;
    
    handles.toolbox.oceanmodels.options.bccTimeStep=30;
    
    % Initial conditions
    handles.toolbox.oceanmodels.options.waterLevel.IC.source=4; % constant
    handles.toolbox.oceanmodels.options.waterLevel.IC.constant=0;
    
    handles.toolbox.oceanmodels.options.current.IC.source=4; % constant
    handles.toolbox.oceanmodels.options.current.IC.constant=0;
    
    handles.toolbox.oceanmodels.options.salinity.IC.source=4; % constant
    handles.toolbox.oceanmodels.options.salinity.IC.profileFile='';
    handles.toolbox.oceanmodels.options.salinity.IC.constant=31;
    
    handles.toolbox.oceanmodels.options.temperature.IC.source=4; % constant
    handles.toolbox.oceanmodels.options.temperature.IC.profileFile='';
    handles.toolbox.oceanmodels.options.temperature.IC.constant=15;
    
end
