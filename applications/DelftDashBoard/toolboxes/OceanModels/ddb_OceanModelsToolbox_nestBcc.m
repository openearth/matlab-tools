function ddb_OceanModelsToolbox_nestBcc(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('oceanmodelspanel.nesting.nestoptions.bcc');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'generatebcc'}
            generateBcc;
    end    
end

%%
function generateBcc

handles=getHandles;

% Set Delft3D-FLOW input
flow.itDate=handles.Model(md).Input.itDate;
flow.startTime=handles.Model(md).Input.startTime;
flow.stopTime=handles.Model(md).Input.stopTime;
flow.KMax=handles.Model(md).Input.KMax;
flow.thick=handles.Model(md).Input.thick;
flow.vertCoord=handles.Model(md).Input.layerType;
flow.zTop=handles.Model(md).Input.zTop;
flow.zBot=handles.Model(md).Input.zBot;

flow.salinity.include=handles.Model(md).Input.salinity.include;
flow.temperature.include=handles.Model(md).Input.temperature.include;
flow.sediments=handles.Model(md).Input.sediments;
flow.nrSediments=handles.Model(md).Input.nrSediments;
flow.tracers=handles.Model(md).Input.tracers;
flow.nrTracers=handles.Model(md).Input.nrTracers;

% Set open boundaries
openBoundaries=handles.Model(md).Input.openBoundaries;

% Set options
opt=handles.Toolbox(tb).Input.options;
if handles.Toolbox(tb).Input.options.salinity.BC.source==3
    % Profile
    opt.salinity.BC.profile=load(handles.Toolbox(tb).Input.options.salinity.BC.profileFile);
end
if handles.Toolbox(tb).Input.options.temperature.BC.source==3
    % Profile
    opt.temperature.BC.profile=load(handles.Toolbox(tb).Input.options.temperature.BC.profileFile);
end

switch handles.Toolbox(tb).Input.options.salinity.BC.source
    case 1
        opt.salinity.BC.source='constant';
    case 2
        opt.salinity.BC.source='file';
    case 3
        opt.salinity.BC.source='profile';
end

switch handles.Toolbox(tb).Input.options.temperature.BC.source
    case 1
        opt.temperature.BC.source='constant';
    case 2
        opt.temperature.BC.source='file';
    case 3
        opt.temperature.BC.source='profile';
end

% Coordinate system
cs=handles.screenParameters.coordinateSystem;

openBoundaries=generateBccFile(flow,openBoundaries,opt);

handles.Model(md).Input.bccFile='testje.bcc';

delft3dflow_saveBccFile(flow,openBoundaries,handles.Model(md).Input.bccFile);

handles.Model(md).Input.openBoundaries=openBoundaries;

setHandles(handles);
