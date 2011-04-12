function ddb_OceanModelsToolbox_nestBct(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('oceanmodelspanel.nesting.nestoptions.bct');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'generatebct'}
            generateBct;
    end    
end

%%
function generateBct

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

% Set open boundaries
openBoundaries=handles.Model(md).Input.openBoundaries;

% Set options
opt=handles.Toolbox(tb).Input.options;

% Tide file
ib=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');
ii=handles.Toolbox(ib).Input.activeTideModelBC;
name=handles.tideModels.model(ii).name;
if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
    tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
else
    tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
end
% Coordinate system
cs=handles.screenParameters.coordinateSystem;

if handles.Toolbox(tb).Input.autoWL
    % Water levels
    tempOpenBoundaries=openBoundaries;
    for i=1:length(tempOpenBoundaries)
        tempOpenBoundaries(i).forcing='A';
        tempOpenBoundaries(i).type='Z';
    end
    [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
    bndFile='TMP_wl.bnd';
    bcaFile='TMP_wl.bca';
    delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
    delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
    opt.waterLevel.BC.bndAstroFile=bndFile;
    opt.waterLevel.BC.astroFile=bcaFile;
end

if handles.Toolbox(tb).Input.autoCur
    % Currents
    tempOpenBoundaries=openBoundaries;
    for i=1:length(tempOpenBoundaries)
        tempOpenBoundaries(i).forcing='A';
        tempOpenBoundaries(i).type='C';
    end
    [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
    bndFile='TMP_current.bnd';
    bcaFile='TMP_current.bca';
    delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
    delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
    opt.current.BC.bndAstroFile=bndFile;
    opt.current.BC.astroFile=bcaFile;
end

openBoundaries=generateBctFile(flow,openBoundaries,opt);

handles.Model(md).Input.bctFile='testje.bct';

delft3dflow_saveBctFile(flow,openBoundaries,handles.Model(md).Input.bctFile);

handles.Model(md).Input.openBoundaries=openBoundaries;

setHandles(handles);
