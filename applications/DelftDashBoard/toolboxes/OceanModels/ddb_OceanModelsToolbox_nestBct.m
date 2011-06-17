function ddb_OceanModelsToolbox_nestBct(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
    setUIElements('oceanmodelspanel.hydroconditions');
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
flow.itDate=handles.Model(md).Input(ad).itDate;
flow.startTime=handles.Model(md).Input(ad).startTime;
flow.stopTime=handles.Model(md).Input(ad).stopTime;
flow.KMax=handles.Model(md).Input(ad).KMax;
flow.thick=handles.Model(md).Input(ad).thick;
flow.vertCoord=handles.Model(md).Input(ad).layerType;
flow.zTop=handles.Model(md).Input(ad).zTop;
flow.zBot=handles.Model(md).Input(ad).zBot;

% Set open boundaries
openBoundaries=handles.Model(md).Input(ad).openBoundaries;

% Set options
opt=handles.Toolbox(tb).Input.options;
opt.waterLevel.BC.datafolder=handles.Toolbox(tb).Input.folder;
opt.waterLevel.BC.dataname=handles.Toolbox(tb).Input.name;
opt.current.BC.datafolder=handles.Toolbox(tb).Input.folder;
opt.current.BC.dataname=handles.Toolbox(tb).Input.name;
opt.inputDir='.\';


% Coordinate system
cs=handles.screenParameters.coordinateSystem;
% if ~strcmpi(cs.type,'geographic')
%     % First convert boundary coordinates to WGS 84
%     for ib=1:length(openBoundaries)
%         [openBoundaries(ib).x,openBoundaries(ib).y]=convertCoordinates(openBoundaries(ib).x,openBoundaries(ib).y,'persistent', ...
%             'CS1.name',cs.name,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
%     end
% end


% File name bct file
[filename, pathname, filterindex] = uiputfile('*.bct', 'Select Hydrodynamic Boundary Conditions File',handles.Model(md).Input(ad).bctFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).bctFile=filename;
    flow.bctFile=filename;
else
    return
end 

wb = waitbox('Generating boundary conditions ...');

switch handles.Toolbox(tb).Input.options.waterLevel.BC.source
    case {1,3}
        % Astronomic
        if handles.Toolbox(tb).Input.autoWL
            % Water levels
            tempOpenBoundaries=openBoundaries;
            for i=1:length(tempOpenBoundaries)
                tempOpenBoundaries(i).forcing='A';
                tempOpenBoundaries(i).type='Z';
            end
            % Tide file
            ii=handles.Toolbox(tb).Input.activeTideModelWL;
            name=handles.tideModels.model(ii).name;
            if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
                tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
            else
                tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
            end
            [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
            bndFile='TMPOCEAN_wl.bnd';
            bcaFile='TMPOCEAN_wl.bca';
            delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
            delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
            opt.waterLevel.BC.bndAstroFile=bndFile;
            opt.waterLevel.BC.astroFile=bcaFile;
        end
end

switch handles.Toolbox(tb).Input.options.current.BC.source
    case {1,3}
        % Astronomic
        if handles.Toolbox(tb).Input.autoCur
            tempOpenBoundaries=openBoundaries;
            for i=1:length(tempOpenBoundaries)
                tempOpenBoundaries(i).forcing='A';
                tempOpenBoundaries(i).type='C';
            end
            % Tide file
            ii=handles.Toolbox(tb).Input.activeTideModelCur;
            name=handles.tideModels.model(ii).name;
            if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
                tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
            else
                tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
            end
            [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
            bndFile='TMPOCEAN_current.bnd';
            bcaFile='TMPOCEAN_current.bca';
            delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
            delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
            opt.current.BC.bndAstroFile=bndFile;
            opt.current.BC.astroFile=bcaFile;
        end
end

try
    openBoundaries=makeBctBccIni('bct','flow',flow,'openboundaries',openBoundaries,'opt',opt,'cs',cs);
    handles.Model(md).Input(ad).openBoundaries=openBoundaries;
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
    giveWarning('text','An error occured while generating boundary conditions!');
end
