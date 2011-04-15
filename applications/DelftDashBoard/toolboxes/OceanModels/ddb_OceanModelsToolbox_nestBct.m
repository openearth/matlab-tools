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

% File name bct file
[filename, pathname, filterindex] = uiputfile('*.bct', 'Select Hydrodynamic Boundary Conditions File',handles.Model(md).Input(ad).bctFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).bctFile=filename;
else
    return
end 

wb = waitbox('Generating boundary conditions ...');

% Water levels
switch handles.Toolbox(tb).Input.options.waterLevel.BC.source
    case {2,3}
        % From file
        % Make large file water level
        t0=handles.Model(md).Input(ad).startTime;
        t1=handles.Model(md).Input(ad).stopTime;
        outfile='TMPOCEAN_waterlevel.mat';
        errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'waterlevel',t0,t1);
        if ~isempty(errmsg)
            close(wb);
            giveWarning('text',[errmsg ' Boundary generation aborted']);
            return
        end
        opt.waterLevel.BC.file=outfile;
end

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
            [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
            bndFile='TMPOCEAN_wl.bnd';
            bcaFile='TMPOCEAN_wl.bca';
            delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
            delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
            opt.waterLevel.BC.bndAstroFile=bndFile;
            opt.waterLevel.BC.astroFile=bcaFile;
        end
end

% Currents
switch handles.Toolbox(tb).Input.options.current.BC.source
    case {2,3}
        % From file
        % Make large file for currents
        t0=handles.Model(md).Input(ad).startTime;
        t1=handles.Model(md).Input(ad).stopTime;
        outfile='TMPOCEAN_current_u.mat';
        errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'current_u',t0,t1);
        if ~isempty(errmsg)
            close(wb);
            giveWarning('text',[errmsg ' Boundary generation aborted']);
            return
        end
        opt.current.BC.file_u=outfile;
        outfile='TMPOCEAN_current_v.mat';
        errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'current_v',t0,t1);
        if ~isempty(errmsg)
            giveWarning('text',[errmsg ' Boundary generation aborted']);
            return
        end
        opt.current.BC.file_v=outfile;
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
    openBoundaries=generateBctFile(flow,openBoundaries,opt);
    delft3dflow_saveBctFile(flow,openBoundaries,handles.Model(md).Input(ad).bctFile);
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
