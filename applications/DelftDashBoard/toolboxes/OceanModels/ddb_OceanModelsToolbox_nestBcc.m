function ddb_OceanModelsToolbox_nestBcc(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
    setUIElements('oceanmodelspanel.transportconditions');
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
flow.itDate=handles.Model(md).Input(ad).itDate;
flow.startTime=handles.Model(md).Input(ad).startTime;
flow.stopTime=handles.Model(md).Input(ad).stopTime;
flow.KMax=handles.Model(md).Input(ad).KMax;
flow.thick=handles.Model(md).Input(ad).thick;
flow.vertCoord=handles.Model(md).Input(ad).layerType;
flow.zTop=handles.Model(md).Input(ad).zTop;
flow.zBot=handles.Model(md).Input(ad).zBot;

flow.salinity.include=handles.Model(md).Input(ad).salinity.include;
flow.temperature.include=handles.Model(md).Input(ad).temperature.include;
flow.sediments=handles.Model(md).Input(ad).sediments;
flow.nrSediments=handles.Model(md).Input(ad).nrSediments;
flow.tracers=handles.Model(md).Input(ad).tracers;
flow.nrTracers=handles.Model(md).Input(ad).nrTracers;

% Set open boundaries
openBoundaries=handles.Model(md).Input(ad).openBoundaries;

% Set options
opt=handles.Toolbox(tb).Input.options;

% File name bcc file
[filename, pathname, filterindex] = uiputfile('*.bcc', 'Select Transport Boundary Conditions File',handles.Model(md).Input(ad).bccFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).bccFile=filename;
else
    return
end 

% Salinity
switch handles.Toolbox(tb).Input.options.salinity.BC.source
    case 1
        opt.salinity.BC.source='constant';
    case 2
        opt.salinity.BC.source='file';
        % Make large file salinity
        t0=handles.Model(md).Input(ad).startTime;
        t1=handles.Model(md).Input(ad).stopTime;
        outfile='TMPOCEAN_salinity.mat';
        errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'salinity',t0,t1);
        if ~isempty(errmsg)
            giveWarning('text',[errmsg ' Boundary generation aborted']);
            return
        end
        opt.salinity.BC.file=outfile;
    case 3
        opt.salinity.BC.source='profile';
        try
            opt.salinity.BC.profile=load(handles.Toolbox(tb).Input.options.salinity.BC.profileFile);
        catch
            giveWarning('text','An error occured while loading salinity profile');
            return
        end
end

% Temperature
switch handles.Toolbox(tb).Input.options.temperature.BC.source
    case 1
        opt.temperature.BC.source='constant';
    case 2
        opt.temperature.BC.source='file';
        % Make large file temperature
        t0=handles.Model(md).Input(ad).startTime;
        t1=handles.Model(md).Input(ad).stopTime;
        outfile='TMPOCEAN_temperature.mat';
        errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'temperature',t0,t1);
        if ~isempty(errmsg)
            giveWarning('text',[errmsg ' Boundary generation aborted']);
            return
        end
        opt.temperature.BC.file=outfile;
    case 3
        opt.temperature.BC.source='profile';
        try
            opt.temperature.BC.profile=load(handles.Toolbox(tb).Input.options.temperature.BC.profileFile);
        catch
            giveWarning('text','An error occured while loading temperature profile');
            return
        end
end

% Coordinate system
cs=handles.screenParameters.coordinateSystem;


wb = waitbox('Generating boundary conditions ...');

try
    openBoundaries=generateBccFile(flow,openBoundaries,opt);
    delft3dflow_saveBccFile(flow,openBoundaries,handles.Model(md).Input(ad).bccFile);
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
