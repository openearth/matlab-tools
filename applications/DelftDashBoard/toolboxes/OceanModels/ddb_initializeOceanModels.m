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


%% Download

handles.Toolbox(ii).Input.oceanModels = {'HYCOM','NCOM'};

handles.Toolbox(ii).Input.oceanModel(1).name = 'hycom';
handles.Toolbox(ii).Input.oceanModel(1).folder = 'hycom';
handles.Toolbox(ii).Input.oceanModel(1).URL = 'http://tds.hycom.org/thredds/dodsC/GLBa0.08/expt_90.9/2011';

handles.Toolbox(ii).Input.oceanModel(2).name = 'ncom';
handles.Toolbox(ii).Input.oceanModel(2).folder = 'ncom';
handles.Toolbox(ii).Input.oceanModel(2).URL = 'http://edac-dap.northerngulfinstitute.org/thredds/dodsC/ncom';

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
handles.Toolbox(ii).Input.folder=handles.Toolbox(ii).Input.oceanModel(1).folder;
handles.Toolbox(ii).Input.URL=handles.Toolbox(ii).Input.oceanModel(1).URL;

handles.Toolbox(ii).Input.outlineHandle=[];


%% Nesting

% Hydro

handles.Toolbox(ii).Input.autoWL=1;
handles.Toolbox(ii).Input.activeTideModelWL=1;
handles.Toolbox(ii).Input.options.waterLevel.BC.source=1;
handles.Toolbox(ii).Input.options.waterLevel.BC.astroFile='';
handles.Toolbox(ii).Input.options.waterLevel.BC.bndAstroFile='';
handles.Toolbox(ii).Input.options.waterLevel.BC.constant=0;

handles.Toolbox(ii).Input.autoCur=1;
handles.Toolbox(ii).Input.activeTideModelCur=1;
handles.Toolbox(ii).Input.options.current.BC.source=1;
handles.Toolbox(ii).Input.options.current.BC.astroFile='';
handles.Toolbox(ii).Input.options.current.BC.bndAstroFile='';

handles.Toolbox(ii).Input.options.bctTimeStep=10;

% Transport
handles.Toolbox(ii).Input.options.salinity.BC.source=1;
handles.Toolbox(ii).Input.options.salinity.BC.profileFile='';
handles.Toolbox(ii).Input.options.salinity.BC.constant=31;

handles.Toolbox(ii).Input.options.temperature.BC.source=1;
handles.Toolbox(ii).Input.options.temperature.BC.profileFile='';
handles.Toolbox(ii).Input.options.temperature.BC.constant=15;

handles.Toolbox(ii).Input.options.bccTimeStep=10;
