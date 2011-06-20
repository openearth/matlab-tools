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

flow.tracer=handles.Model(md).Input(ad).tracer;
flow.tracers=handles.Model(md).Input(ad).tracers;
flow.nrTracers=handles.Model(md).Input(ad).nrTracers;

% Set open boundaries
openBoundaries=handles.Model(md).Input(ad).openBoundaries;

% File name bcc file
[filename, pathname, filterindex] = uiputfile('*.bcc', 'Select Transport Boundary Conditions File',handles.Model(md).Input(ad).bccFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).bccFile=filename;
    flow.bccFile=filename;
else
    return
end 

opt=handles.Toolbox(tb).Input.options;
opt.salinity.BC.datafolder=handles.Toolbox(tb).Input.folder;
opt.salinity.BC.dataname=handles.Toolbox(tb).Input.name;
opt.temperature.BC.datafolder=handles.Toolbox(tb).Input.folder;
opt.temperature.BC.dataname=handles.Toolbox(tb).Input.name;

switch opt.salinity.BC.source
    case 5
        fname=handles.Toolbox(tb).Input.options.salinity.BC.profileFile;
        [pathstr,name,ext,vrsn]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.salinity.BC.datafolder=pathstr;
        opt.salinity.BC.dataname=[name ext];        
end

switch opt.temperature.BC.source
    case 5
        fname=handles.Toolbox(tb).Input.options.temperature.BC.profileFile;
        [pathstr,name,ext,vrsn]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.temperature.BC.datafolder=[pathstr filesep];
        opt.temperature.BC.dataname=[name ext];        
end

for it=1:flow.nrTracers
    opt.tracer(it).BC.datafolder=handles.Toolbox(tb).Input.folder;
    opt.tracer(it).BC.dataname=handles.Toolbox(tb).Input.name;
    opt.tracer(it).BC.source=4;
    opt.tracer(it).BC.constant=0;
end
for it=1:flow.nrSediments
    opt.sediment(it).BC.datafolder=handles.Toolbox(tb).Input.folder;
    opt.sediment(it).BC.dataname=handles.Toolbox(tb).Input.name;
    opt.sediment(it).BC.source=4;
    opt.sediment(it).BC.constant=0;
end

opt.inputDir='.\';

% Coordinate system
cs=handles.screenParameters.coordinateSystem;

wb = waitbox('Generating boundary conditions ...');

try
    openBoundaries=makeBctBccIni('bcc','flow',flow,'openboundaries',openBoundaries,'opt',opt,'cs',cs);
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
