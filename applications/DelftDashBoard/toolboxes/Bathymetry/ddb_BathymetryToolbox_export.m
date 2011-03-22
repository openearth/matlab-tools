function ddb_BathymetryToolbox_export(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    selectDataset;
    setUIElements('bathymetrypanel.export');
    ddb_plotBathymetry('activate');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'selectzoomlevel'}
            selectZoomLevel;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'export'}
            exportData;
    end    
end

%%
function selectDataset
handles=getHandles;
handles.Toolbox(tb).Input.activeZoomLevel=1;
handles=setResolutionText(handles);
handles.Toolbox(tb).Input.zoomLevelText=[];
for i=1:length(handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).zoomLevel)
    handles.Toolbox(tb).Input.zoomLevelText{i}=num2str(i);
end
setHandles(handles);
setUIElements('bathymetrypanel.export');

%%
function selectZoomLevel
handles=getHandles;
handles=setResolutionText(handles);
setHandles(handles);
setUIElements('bathymetrypanel.export');

%%
function handles=setResolutionText(handles)

cellSize=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).zoomLevel(handles.Toolbox(tb).Input.activeZoomLevel).dx;
%     cellSize=dms2degrees([dg mn sc]);
if strcmpi(handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.type,'Geographic')
    cellSize=cellSize*111111;
    handles.Toolbox(tb).Input.resolutionText=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
else
    handles.Toolbox(tb).Input.resolutionText=['Cell Size : ' num2str(cellSize,'%10.0f') ' m'];
end

%%
function exportData

handles=getHandles;

filename=handles.Toolbox(tb).Input.bathyFile;

if handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).isAvailable
    
    wb = waitbox('Exporting samples ...');pause(0.1);
    
    cs.name=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.name;
    cs.type=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.type;
    
    [xx,yy]=ddb_coordConvert(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,handles.screenParameters.coordinateSystem,cs);
    
    ii=handles.Toolbox(tb).Input.activeDataset;
    str=handles.bathymetry.datasets;
    bset=str{ii};
    
    xlim(1)=min(xx);
    xlim(2)=max(xx);
    ylim(1)=min(yy);
    ylim(2)=max(yy);
    
    fname=filename;
    handles.originalBackgroundBathymetry=handles.screenParameters.backgroundBathymetry;
    handles.backgroundBathymetry=bset;
    
    zoomlevel=handles.Toolbox(tb).Input.activeZoomLevel;
    
    [x,y,z,ok]=ddb_getBathy(handles,xlim,ylim,'zoomlevel',zoomlevel);
    
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    
    handles.screenParameters.backgroundBathymetry=handles.originalBackgroundBathymetry;
    
    np=size(x,1)*size(x,2);
    
    x=reshape(x,[np,1]);
    y=reshape(y,[np,1]);
    z=reshape(z,[np,1]);
    
    in = inpolygon(x,y,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY);
    
    x=x(in);
    y=y(in);
    z=z(in);
    isn=isnan(z);
    
    %     if min(isn)==0
    x=x(~isn);
    y=y(~isn);
    z=z(~isn);
    %     end
    
    if strcmpi(handles.Toolbox(tb).Input.activeDirection,'down')
        z=z*-1;
    end
    
    data(:,1)=x;
    data(:,2)=y;
    data(:,3)=z;
        
    save(fname,'data','-ascii');
    
    close(wb);
    
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','BathymetryPolygon');
if ~isempty(h)
    delete(h);
end
UIPolyline(gca,'draw','Tag','BathymetryPolygon','Marker','o','Callback',@changePolygon,'closed',1);
setHandles(handles);
setUIElement('bathymetrypanel.export.savepolygon');

%%
function deletePolygon
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=[];
handles.Toolbox(tb).Input.polygonY=[];
handles.Toolbox(tb).Input.polyLength=0;
h=findobj(gcf,'Tag','BathymetryPolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);
setUIElement('bathymetrypanel.export.exportbathy');
setUIElement('bathymetrypanel.export.savepolygon');

%%
function changePolygon(x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);
setUIElement('bathymetrypanel.export.exportbathy');
setUIElement('bathymetrypanel.export.savepolygon');

%%
function loadPolygon
handles=getHandles;
[x,y]=landboundary('read',handles.Toolbox(tb).Input.polygonFile);
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
h=findobj(gca,'Tag','BathymetryPolygon');
delete(h);
UIPolyline(gca,'plot','Tag','BathymetryPolygon','Marker','o','Callback',@changePolygon,'closed',1,'x',x,'y',y);
setHandles(handles);
setUIElement('bathymetrypanel.export.exportbathy');
setUIElement('bathymetrypanel.export.savepolygon');

%%
function savePolygon
handles=getHandles;
x=handles.Toolbox(tb).Input.polygonX;
y=handles.Toolbox(tb).Input.polygonY;
landboundary('write',handles.Toolbox(tb).Input.polygonFile,x,y);
