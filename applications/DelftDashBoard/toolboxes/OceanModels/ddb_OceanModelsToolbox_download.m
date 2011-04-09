function ddb_OceanModelsToolbox_download(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
    setUIElements('oceanmodelspanel.download');
else
    %Options selected
    opt=lower(varargin{1});
    handles=getHandles;
    switch opt
        case{'nesthd1'}
            nestHD1;
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to model limits on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','OceanModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeOutlineOnMap,'onstart',@deleteOutline);
        case{'editoutline'}
            editOutline;
        case{'selectoceanmodel'}
            selectOceanModel;
        case{'download'}
            downloadData;
    end    
end

%%
function selectOceanModel
handles=getHandles;
ii=handles.Toolbox(tb).Input.activeModel;
handles.Toolbox(tb).Input.name=handles.Toolbox(tb).Input.oceanModel(ii).name;
handles.Toolbox(tb).Input.folder=handles.Toolbox(tb).Input.oceanModel(ii).folder;
handles.Toolbox(tb).Input.URL=handles.Toolbox(tb).Input.oceanModel(ii).URL;
setHandles(handles);
setUIElement('oceanmodels.download.editname');
setUIElement('oceanmodels.download.editfolder');
setUIElement('oceanmodels.download.editurl');

%%
function changeOutlineOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.Toolbox(tb).Input.outlineHandle=h;
handles.Toolbox(tb).Input.xLim(1)=x0;
handles.Toolbox(tb).Input.yLim(1)=y0;
handles.Toolbox(tb).Input.xLim(2)=x0+dx;
handles.Toolbox(tb).Input.yLim(2)=y0+dy;

cs=handles.screenParameters.coordinateSystem;
dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    ddx=dx/10;
    ddy=dy/10;
    [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    dx=max(max(xtmp2))-min(min(xtmp2));
end

setHandles(handles);
setUIElement('oceanmodels.download.editxmin');
setUIElement('oceanmodels.download.editxmax');
setUIElement('oceanmodels.download.editymin');
setUIElement('oceanmodels.download.editymax');

%%
function editOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.outlineHandle)
    try
        delete(handles.Toolbox(tb).Input.outlineHandle);
    end
end
x0=handles.Toolbox(tb).Input.xLim(1);
y0=handles.Toolbox(tb).Input.yLim(1);
dx=handles.Toolbox(tb).Input.xLim(2)-x0;
dy=handles.Toolbox(tb).Input.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','OceanModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeOutlineOnMap, ...
    'onstart',@deleteOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.Toolbox(tb).Input.outlineHandle=h;
setHandles(handles);

%%
function deleteOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.outlineHandle)
    try
        delete(handles.Toolbox(tb).Input.outlineHandle);
    end
end

%%
function downloadData

handles=getHandles;

xl=handles.Toolbox(tb).Input.xLim;
yl=handles.Toolbox(tb).Input.yLim;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;

url=handles.Toolbox(tb).Input.URL;
outname=handles.Toolbox(tb).Input.name;
outdir=handles.Toolbox(tb).Input.folder;

if ~isdir(outdir)
    mkdir(outdir);
end

switch handles.Toolbox(tb).Input.activeModel
    case 1
        load([handles.Toolbox(tb).miscDir 'hycom.mat']);
        if handles.Toolbox(tb).Input.getSSH
            getHYCOM2(url,outname,outdir,'waterlevel',xl,yl,0.1,0.1,[t0 t1],s);
        end
        if handles.Toolbox(tb).Input.getCurrents
            getHYCOM2(url,outname,outdir,'current_u',xl,yl,0.1,0.1,[t0 t1],s);
            getHYCOM2(url,outname,outdir,'current_v',xl,yl,0.1,0.1,[t0 t1],s);
        end
        if handles.Toolbox(tb).Input.getSalinity
            getHYCOM2(url,outname,outdir,'salinity',xl,yl,0.1,0.1,[t0 t1],s);
        end
        if handles.Toolbox(tb).Input.getTemperature
            getHYCOM2(url,outname,outdir,'temperature',xl,yl,0.1,0.1,[t0 t1],s);
        end
end
