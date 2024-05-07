function ddb_OceanModelsToolbox_nestIni(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
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
flow.itDate=handles.model.delft3dflow.domain(ad).itDate;
flow.startTime=handles.model.delft3dflow.domain(ad).startTime;
flow.stopTime=handles.model.delft3dflow.domain(ad).stopTime;
flow.KMax=handles.model.delft3dflow.domain(ad).KMax;
flow.thick=handles.model.delft3dflow.domain(ad).thick;
flow.vertCoord=handles.model.delft3dflow.domain(ad).layerType;
flow.zTop=handles.model.delft3dflow.domain(ad).zTop;
flow.zBot=handles.model.delft3dflow.domain(ad).zBot;
flow.gridX=handles.model.delft3dflow.domain(ad).gridX;
flow.gridY=handles.model.delft3dflow.domain(ad).gridY;
flow.gridXZ=handles.model.delft3dflow.domain(ad).gridXZ;
flow.gridYZ=handles.model.delft3dflow.domain(ad).gridYZ;
flow.depthZ=handles.model.delft3dflow.domain(ad).depthZ;
flow.latitude=handles.model.delft3dflow.domain(ad).latitude;

flow.salinity.include=handles.model.delft3dflow.domain(ad).salinity.include;
flow.temperature.include=handles.model.delft3dflow.domain(ad).temperature.include;
flow.sediments=handles.model.delft3dflow.domain(ad).sediments;
flow.nrSediments=handles.model.delft3dflow.domain(ad).nrSediments;
flow.tracer=handles.model.delft3dflow.domain(ad).tracer;
flow.tracers=handles.model.delft3dflow.domain(ad).tracers;
flow.nrTracers=handles.model.delft3dflow.domain(ad).nrTracers;

% File name bct file
[filename, pathname, filterindex] = uiputfile('*.ini', 'Select Initial Conditions File',handles.model.delft3dflow.domain(ad).iniFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.model.delft3dflow.domain(ad).iniFile=filename;
    flow.iniFile=filename;
else
    return
end 

opt=handles.toolbox.oceanmodels.options;

% Coordinate system
opt.cs=handles.screenParameters.coordinateSystem;

opt.waterLevel.IC.datafolder=handles.toolbox.oceanmodels.folder;
opt.waterLevel.IC.dataname=handles.toolbox.oceanmodels.name;
opt.current.IC.datafolder=handles.toolbox.oceanmodels.folder;
opt.current.IC.dataname=handles.toolbox.oceanmodels.name;
opt.salinity.IC.datafolder=handles.toolbox.oceanmodels.folder;
opt.salinity.IC.dataname=handles.toolbox.oceanmodels.name;
opt.temperature.IC.datafolder=handles.toolbox.oceanmodels.folder;
opt.temperature.IC.dataname=handles.toolbox.oceanmodels.name;

switch opt.salinity.IC.source
    case 5
        fname=handles.toolbox.oceanmodels.options.salinity.IC.profileFile;
        [pathstr,name,ext]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.salinity.IC.datafolder=pathstr;
        opt.salinity.IC.dataname=[name ext];
        opt.salinity.IC.profile=load(opt.salinity.IC.dataname);
end

switch opt.temperature.IC.source
    case 5
        fname=handles.toolbox.oceanmodels.options.temperature.IC.profileFile;
        [pathstr,name,ext]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.temperature.IC.datafolder=[pathstr filesep];
        opt.temperature.IC.dataname=[name ext];        
        opt.temperature.IC.profile=load(opt.temperature.IC.dataname);
end

for it=1:flow.nrTracers
    opt.tracer(it).IC.datafolder=handles.toolbox.oceanmodels.folder;
    opt.tracer(it).IC.dataname=handles.toolbox.oceanmodels.name;
    opt.tracer(it).IC.source=4;
    opt.tracer(it).IC.constant=0;
end
for it=1:flow.nrSediments
    opt.sediment(it).IC.datafolder=handles.toolbox.oceanmodels.folder;
    opt.sediment(it).IC.dataname=handles.toolbox.oceanmodels.name;
    opt.sediment(it).IC.source=4;
    opt.sediment(it).IC.constant=0;
end

opt.inputDir='.\';

wb = waitbox('Generating initial conditions ...');

try
    makeBctBccIni('ini','flow',flow,'opt',opt);
    handles.model.delft3dflow.domain(ad).initialConditions='ini';
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
    ddb_giveWarning('text','An error occured while generating initial conditions!');
end
