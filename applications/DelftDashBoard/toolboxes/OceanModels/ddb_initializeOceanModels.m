function handles=ddb_initializeOceanModels(handles,varargin)

ii=strmatch('OceanModels',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

%% Read ocean models xml file

s=xml_load([handles.Toolbox(ii).dataDir 'OceanModels.xml']);
for i=1:length(s.models)
    handles.Toolbox(ii).Input.oceanModel(i).name = s.models(i).model.name;
    handles.Toolbox(ii).Input.oceanModel(i).longName = s.models(i).model.longname;
    handles.Toolbox(ii).Input.oceanModel(i).URL = s.models(i).model.url;
    handles.Toolbox(ii).Input.oceanModel(i).type = s.models(i).model.type;
    if isfield(s.models(i).model,'gridcoordinates')
        handles.Toolbox(ii).Input.oceanModel(i).gridCoordinates = s.models(i).model.gridcoordinates;
    else
        handles.Toolbox(ii).Input.oceanModel(i).gridCoordinates=[];
    end
    if isfield(s.models(i).model,'region')
        handles.Toolbox(ii).Input.oceanModel(i).region = s.models(i).model.region;
    else
        handles.Toolbox(ii).Input.oceanModel(i).region=[];
    end
    handles.Toolbox(ii).Input.oceanModels{i} = s.models(i).model.longname;
end

%% Download

handles.Toolbox(ii).Input.activeModel = 1;
handles.Toolbox(ii).Input.startTime= floor(now)-10;
handles.Toolbox(ii).Input.stopTime= floor(now)-5;
handles.Toolbox(ii).Input.xLim=[0 0];
handles.Toolbox(ii).Input.yLim=[0 0];
handles.Toolbox(ii).Input.getSSH=1;
handles.Toolbox(ii).Input.getCurrents=1;
handles.Toolbox(ii).Input.getSalinity=1;
handles.Toolbox(ii).Input.getTemperature=1;

handles.Toolbox(ii).Input.name=handles.Toolbox(ii).Input.oceanModel(1).name;
handles.Toolbox(ii).Input.folder=handles.Toolbox(ii).Input.oceanModel(1).name;
handles.Toolbox(ii).Input.URL=handles.Toolbox(ii).Input.oceanModel(1).URL;

handles.Toolbox(ii).Input.outlineHandle=[];


%% Nesting

% Hydro

handles.Toolbox(ii).Input.autoWL=1;
handles.Toolbox(ii).Input.activeTideModelWL=1;
handles.Toolbox(ii).Input.options.waterLevel.BC.source=1; % astro
handles.Toolbox(ii).Input.options.waterLevel.BC.astroFile='';
handles.Toolbox(ii).Input.options.waterLevel.BC.bndAstroFile='';
handles.Toolbox(ii).Input.options.waterLevel.BC.constant=0;


handles.Toolbox(ii).Input.autoCur=1;
handles.Toolbox(ii).Input.activeTideModelCur=1;
handles.Toolbox(ii).Input.options.current.BC.source=1; % astro
handles.Toolbox(ii).Input.options.current.BC.astroFile='';
handles.Toolbox(ii).Input.options.current.BC.bndAstroFile='';

handles.Toolbox(ii).Input.options.bctTimeStep=10;

% Transport
handles.Toolbox(ii).Input.options.salinity.BC.source=4; % constant
handles.Toolbox(ii).Input.options.salinity.BC.profileFile='';
handles.Toolbox(ii).Input.options.salinity.BC.constant=31;

handles.Toolbox(ii).Input.options.temperature.BC.source=4; % constant
handles.Toolbox(ii).Input.options.temperature.BC.profileFile='';
handles.Toolbox(ii).Input.options.temperature.BC.constant=15;

handles.Toolbox(ii).Input.options.bccTimeStep=30;

% Initial conditions
handles.Toolbox(ii).Input.options.waterLevel.IC.source=4; % constant
handles.Toolbox(ii).Input.options.waterLevel.IC.constant=0;

handles.Toolbox(ii).Input.options.current.IC.source=4; % constant
handles.Toolbox(ii).Input.options.current.IC.constant=0;

handles.Toolbox(ii).Input.options.salinity.IC.source=4; % constant
handles.Toolbox(ii).Input.options.salinity.IC.profileFile='';
handles.Toolbox(ii).Input.options.salinity.IC.constant=31;

handles.Toolbox(ii).Input.options.temperature.IC.source=4; % constant
handles.Toolbox(ii).Input.options.temperature.IC.profileFile='';
handles.Toolbox(ii).Input.options.temperature.IC.constant=15;

