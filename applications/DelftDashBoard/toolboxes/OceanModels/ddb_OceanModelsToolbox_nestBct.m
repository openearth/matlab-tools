function ddb_OceanModelsToolbox_nestBct(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
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
flow.itDate=handles.model.delft3dflow.domain(ad).itDate;
flow.startTime=handles.model.delft3dflow.domain(ad).startTime;
flow.stopTime=handles.model.delft3dflow.domain(ad).stopTime;
flow.KMax=handles.model.delft3dflow.domain(ad).KMax;
flow.thick=handles.model.delft3dflow.domain(ad).thick;
flow.vertCoord=handles.model.delft3dflow.domain(ad).layerType;
flow.zTop=handles.model.delft3dflow.domain(ad).zTop;
flow.zBot=handles.model.delft3dflow.domain(ad).zBot;
flow.gridY=handles.model.delft3dflow.domain(ad).gridY;
flow.latitude=handles.model.delft3dflow.domain(ad).latitude;

% Set open boundaries
openBoundaries=handles.model.delft3dflow.domain(ad).openBoundaries;

% Set options
opt=handles.toolbox.oceanmodels.options;
opt.waterLevel.BC.datafolder=handles.toolbox.oceanmodels.folder;
opt.waterLevel.BC.dataname=handles.toolbox.oceanmodels.name;
opt.current.BC.datafolder=handles.toolbox.oceanmodels.folder;
opt.current.BC.dataname=handles.toolbox.oceanmodels.name;
opt.inputDir='.\';


% Coordinate system
opt.cs=handles.screenParameters.coordinateSystem;
% if ~strcmpi(cs.type,'geographic')
%     % First convert boundary coordinates to WGS 84
%     for ib=1:length(openBoundaries)
%         [openBoundaries(ib).x,openBoundaries(ib).y]=convertCoordinates(openBoundaries(ib).x,openBoundaries(ib).y,'persistent', ...
%             'CS1.name',cs.name,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
%     end
% end

for ii=1:length(openBoundaries) 
    if strcmp(openBoundaries(ii).type,'C') && ~strcmp(openBoundaries(ii).forcing,'T')
        ddb_giveWarning('text',['Forcing type should be timeseries for nesting ocean currents - inconsistency found for (at least) boundary ' openBoundaries(ii).name]);
        return
    end
    if flow.KMax>1 && ~strcmp(openBoundaries(ii).profile,'3d-profile') && ~strcmpi(openBoundaries(ii).type,'Z')
        ddb_giveWarning('text',['Boundary profile should be 3D for nesting 3D ocean currents - inconsistency found for (at least) boundary ' openBoundaries(ii).name]);
        return
    end
end

% File name bct file
[filename, pathname, filterindex] = uiputfile('*.bct', 'Select Hydrodynamic Boundary Conditions File',handles.model.delft3dflow.domain(ad).bctFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.model.delft3dflow.domain(ad).bctFile=filename;
    flow.bctFile=filename;
else
    return
end 

wb = waitbox('Generating boundary conditions ...');

switch handles.toolbox.oceanmodels.options.waterLevel.BC.source
    case {1,3}
        % Astronomic
        if handles.toolbox.oceanmodels.autoWL
            % Water levels
            tempOpenBoundaries=openBoundaries;
            for i=1:length(tempOpenBoundaries)
                tempOpenBoundaries(i).forcing='A';
                tempOpenBoundaries(i).type='Z';
            end
            % Tide file
            ii=handles.toolbox.oceanmodels.activeTideModelWL;
            name=handles.tideModels.model(ii).name;
            if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
                tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
            else
                tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
            end
            [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,opt.cs);
            bndFile='TMPOCEAN_wl.bnd';
            bcaFile='TMPOCEAN_wl.bca';
            delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
            delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
            opt.waterLevel.BC.bndAstroFile=bndFile;
            opt.waterLevel.BC.astroFile=bcaFile;
        end
end

switch handles.toolbox.oceanmodels.options.current.BC.source
    case {1,3}
        % Astronomic
        if handles.toolbox.oceanmodels.autoCur
            tempOpenBoundaries=openBoundaries;
            for i=1:length(tempOpenBoundaries)
                tempOpenBoundaries(i).forcing='A';
                tempOpenBoundaries(i).type='C';
            end
            % Tide file
            ii=handles.toolbox.oceanmodels.activeTideModelCur;
            name=handles.tideModels.model(ii).name;
            if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
                tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
            else
                tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
            end
            [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,opt.cs);
            bndFile='TMPOCEAN_current.bnd';
            bcaFile='TMPOCEAN_current.bca';
            delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
            delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
            opt.current.BC.bndAstroFile=bndFile;
            opt.current.BC.astroFile=bcaFile;
        end
end

try
    openBoundaries=makeBctBccIni('bct','flow',flow,'openboundaries',openBoundaries,'opt',opt);
    handles.model.delft3dflow.domain(ad).openBoundaries=openBoundaries;
    handles.model.delft3dflow.domain(ad).bctChanged=0;
    handles.model.delft3dflow.domain(ad).bctLoaded=1;
    flist=dir('TMPOCEAN*');
    for i=1:length(flist)
        try
            delete(flist(i).name);
        end
    end
    close(wb);
    setHandles(handles);
catch
    close(wb);
    ddb_giveWarning('text','An error occured while generating boundary conditions!');
end
