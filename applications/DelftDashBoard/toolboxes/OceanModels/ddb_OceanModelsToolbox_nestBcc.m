function ddb_OceanModelsToolbox_nestBcc(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
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
flow.itDate=handles.model.delft3dflow.domain(ad).itDate;
flow.startTime=handles.model.delft3dflow.domain(ad).startTime;
flow.stopTime=handles.model.delft3dflow.domain(ad).stopTime;
flow.KMax=handles.model.delft3dflow.domain(ad).KMax;
flow.thick=handles.model.delft3dflow.domain(ad).thick;
flow.vertCoord=handles.model.delft3dflow.domain(ad).layerType;
flow.zTop=handles.model.delft3dflow.domain(ad).zTop;
flow.zBot=handles.model.delft3dflow.domain(ad).zBot;
flow.latitude=handles.model.delft3dflow.domain(ad).latitude;

flow.salinity.include=handles.model.delft3dflow.domain(ad).salinity.include;
flow.temperature.include=handles.model.delft3dflow.domain(ad).temperature.include;

flow.sediments=handles.model.delft3dflow.domain(ad).sediments;
flow.nrSediments=handles.model.delft3dflow.domain(ad).nrSediments;

flow.tracer=handles.model.delft3dflow.domain(ad).tracer;
flow.tracers=handles.model.delft3dflow.domain(ad).tracers;
flow.nrTracers=handles.model.delft3dflow.domain(ad).nrTracers;

flow.gridY=handles.model.delft3dflow.domain(ad).gridY;

% Set open boundaries
openBoundaries=handles.model.delft3dflow.domain(ad).openBoundaries;

% File name bcc file
[filename, pathname, filterindex] = uiputfile('*.bcc', 'Select Transport Boundary Conditions File',handles.model.delft3dflow.domain(ad).bccFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.model.delft3dflow.domain(ad).bccFile=filename;
    flow.bccFile=filename;
else
    return
end 

opt=handles.toolbox.oceanmodels.options;
opt.salinity.BC.datafolder=handles.toolbox.oceanmodels.folder;
opt.salinity.BC.dataname=handles.toolbox.oceanmodels.name;
opt.temperature.BC.datafolder=handles.toolbox.oceanmodels.folder;
opt.temperature.BC.dataname=handles.toolbox.oceanmodels.name;

switch opt.salinity.BC.source
    case 5
        fname=handles.toolbox.oceanmodels.options.salinity.BC.profileFile;
%        [pathstr,name,ext,vrsn]=fileparts(fname);
        [pathstr,name,ext]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.salinity.BC.datafolder=pathstr;
        opt.salinity.BC.dataname=[name ext];        
end

switch opt.temperature.BC.source
    case 5
        fname=handles.toolbox.oceanmodels.options.temperature.BC.profileFile;
%        [pathstr,name,ext,vrsn]=fileparts(fname);
        [pathstr,name,ext]=fileparts(fname);
        if isempty(pathstr)
            pathstr='.';
        end
        opt.temperature.BC.datafolder=[pathstr filesep];
        opt.temperature.BC.dataname=[name ext];        
end

for it=1:flow.nrTracers
    opt.tracer(it).BC.datafolder=handles.toolbox.oceanmodels.folder;
    opt.tracer(it).BC.dataname=handles.toolbox.oceanmodels.name;
    opt.tracer(it).BC.source=4;
    opt.tracer(it).BC.constant=0;
end
for it=1:flow.nrSediments
    opt.sediment(it).BC.datafolder=handles.toolbox.oceanmodels.folder;
    opt.sediment(it).BC.dataname=handles.toolbox.oceanmodels.name;
    opt.sediment(it).BC.source=4;
    opt.sediment(it).BC.constant=0;
end

opt.inputDir='.\';

% Coordinate system
opt.cs=handles.screenParameters.coordinateSystem;

wb = waitbox('Generating boundary conditions ...');

try
    openBoundaries=makeBctBccIni('bcc','flow',flow,'openboundaries',openBoundaries,'opt',opt);
    handles.model.delft3dflow.domain(ad).openBoundaries=openBoundaries;
    handles.model.delft3dflow.domain(ad).bccChanged=0;
    handles.model.delft3dflow.domain(ad).bccLoaded=1;
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
