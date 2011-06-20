function ddb_OceanModelsToolbox_nestIni(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
    setUIElements('oceanmodelspanel.initialconditions');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'generateini'}
            generateIni;
    end    
end

%%
function generateIni

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
flow.gridX=handles.Model(md).Input(ad).gridX;
flow.gridY=handles.Model(md).Input(ad).gridY;
flow.gridXZ=handles.Model(md).Input(ad).gridXZ;
flow.gridYZ=handles.Model(md).Input(ad).gridYZ;
flow.depthZ=handles.Model(md).Input(ad).depthZ;

flow.salinity.include=handles.Model(md).Input(ad).salinity.include;
flow.temperature.include=handles.Model(md).Input(ad).temperature.include;
flow.sediments=handles.Model(md).Input(ad).sediments;
flow.nrSediments=handles.Model(md).Input(ad).nrSediments;
flow.tracer=handles.Model(md).Input(ad).tracer;
flow.tracers=handles.Model(md).Input(ad).tracers;
flow.nrTracers=handles.Model(md).Input(ad).nrTracers;

% Coordinate system
cs=handles.screenParameters.coordinateSystem;

% File name bct file
[filename, pathname, filterindex] = uiputfile('*.ini', 'Select Initial Conditions File',handles.Model(md).Input(ad).iniFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).iniFile=filename;
    flow.iniFile=filename;
else
    return
end 

opt=handles.Toolbox(tb).Input.options;

opt.waterLevel.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.waterLevel.IC.dataname=handles.Toolbox(tb).Input.name;
opt.current.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.current.IC.dataname=handles.Toolbox(tb).Input.name;
opt.salinity.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.salinity.IC.dataname=handles.Toolbox(tb).Input.name;
opt.temperature.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.temperature.IC.dataname=handles.Toolbox(tb).Input.name;

switch opt.salinity.IC.source
    case 5
        fname=handles.Toolbox(tb).Input.options.salinity.IC.profileFile;
        [pathstr,name,ext,vrsn]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.salinity.IC.datafolder=pathstr;
        opt.salinity.IC.dataname=[name ext];        
end

switch opt.temperature.IC.source
    case 5
        fname=handles.Toolbox(tb).Input.options.temperature.IC.profileFile;
        [pathstr,name,ext,vrsn]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.temperature.IC.datafolder=[pathstr filesep];
        opt.temperature.IC.dataname=[name ext];        
end

for it=1:flow.nrTracers
    opt.tracer(it).IC.datafolder=handles.Toolbox(tb).Input.folder;
    opt.tracer(it).IC.dataname=handles.Toolbox(tb).Input.name;
    opt.tracer(it).IC.source=4;
    opt.tracer(it).IC.constant=0;
end
for it=1:flow.nrSediments
    opt.sediment(it).IC.datafolder=handles.Toolbox(tb).Input.folder;
    opt.sediment(it).IC.dataname=handles.Toolbox(tb).Input.name;
    opt.sediment(it).IC.source=4;
    opt.sediment(it).IC.constant=0;
end

opt.inputDir='.\';

wb = waitbox('Generating initial conditions ...');

try
    makeBctBccIni('ini','flow',flow,'opt',opt,'cs',cs);
    handles.Model(md).Input(ad).initialConditions='ini';
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
    giveWarning('text','An error occured while generating initial conditions!');
end
