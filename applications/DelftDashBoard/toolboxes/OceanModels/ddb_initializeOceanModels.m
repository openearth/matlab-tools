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
