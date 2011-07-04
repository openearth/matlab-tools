function ddb_ShorelineToolbox_export(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    selectDataset;
    setUIElements('shorelinepanel.export');
    ddb_plotShoreline('activate');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'selectdataset'}
            selectDataset;
%        case{'selectscale'}
%            selectScale;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'exportlandboundary'}
            exportLandBoundary;
        case{'export'}
            exportData;
    end    
end

%%
function selectDataset
handles=getHandles;
handles.Toolbox(tb).Input.scaleText=[];
scl=handles.shorelines.shoreline(handles.Toolbox(tb).Input.activeDataset).scale;
for i=1:length(scl)
    handles.Toolbox(tb).Input.scaleText{i}=['1 : ' num2str(scl(i),'%20.0f')];
end
setHandles(handles);
setUIElements('shorelinepanel.export');

%%
function exportData

handles=getHandles;

filename=handles.Toolbox(tb).Input.shorelineFile;

if handles.shorelines.shoreline(handles.Toolbox(tb).Input.activeDataset).isAvailable
    
    wb = waitbox('Exporting shoreline ...');pause(0.1);
    
    cs.name=handles.shorelines.shoreline(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.name;
    cs.type=handles.shorelines.shoreline(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.type;
    
    % Convert polygon to coordinate system of shoreline database
    [xx,yy]=ddb_coordConvert(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,handles.screenParameters.coordinateSystem,cs);

    % Determine limits
    xlim(1)=min(xx);
    xlim(2)=max(xx);
    ylim(1)=min(yy);
    ylim(2)=max(yy);
    
    % Fetch shoreline
    [x,y]=ddb_getShoreline(handles,xlim,ylim,handles.Toolbox(tb).Input.activeScale);

    % Convert to local coordinate system
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    
    % Remove points outside polygon
    inp=inpolygon(x,y,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY);    
    x(~inp)=NaN;
    y(~inp)=NaN;
    
    close(wb);

    % Save shoreline
    saveLdb(filename,x,y,handles.screenParameters.coordinateSystem.type);

end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','ShorelinePolygon');
if ~isempty(h)
    delete(h);
end
UIPolyline(gca,'draw','Tag','ShorelinePolygon','Marker','o','Callback',@changePolygon,'closed',1);
setHandles(handles);
setUIElement('shorelinepanel.export.savepolygon');

%%
function deletePolygon
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=[];
handles.Toolbox(tb).Input.polygonY=[];
handles.Toolbox(tb).Input.polyLength=0;
h=findobj(gcf,'Tag','ShorelinePolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);
setUIElement('shorelinepanel.export.exportshoreline');
setUIElement('shorelinepanel.export.savepolygon');

%%
function changePolygon(x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);
setUIElement('shorelinepanel.export.exportshoreline');
setUIElement('shorelinepanel.export.savepolygon');

%%
function loadPolygon
handles=getHandles;
[x,y]=landboundary('read',handles.Toolbox(tb).Input.polygonFile);
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
h=findobj(gca,'Tag','ShorelinePolygon');
delete(h);
UIPolyline(gca,'plot','Tag','ShorelinePolygon','Marker','o','Callback',@changePolygon,'closed',1,'x',x,'y',y);
setHandles(handles);
setUIElement('shorelinepanel.export.exportshoreline');
setUIElement('shorelinepanel.export.savepolygon');

%%
function savePolygon
handles=getHandles;
x=handles.Toolbox(tb).Input.polygonX;
y=handles.Toolbox(tb).Input.polygonY;
landboundary('write',handles.Toolbox(tb).Input.polygonFile,x,y);

%%
function saveLdb(filename,x,y,cstype)

npol=0;
for i=1:length(x)
    if ~isnan(x(i))
        if i==1 && ~isnan(x(1))
            % Start of new polygon
            npol=npol+1;
            ipol=1;
            xx{npol}(ipol)=x(i);
            yy{npol}(ipol)=y(i);
        elseif i==1 && isnan(x(1))
            % Do nothing
        elseif ~isnan(x(i)) && isnan(x(i-1))
            % Start of new polygon
            npol=npol+1;
            ipol=1;
            xx{npol}(ipol)=x(i);
            yy{npol}(ipol)=y(i);
        elseif ~isnan(x(i)) && ~isnan(x(i-1))
            % Next point in polygon
            ipol=ipol+1;
            xx{npol}(ipol)=x(i);
            yy{npol}(ipol)=y(i);
        end
    end
end

switch lower(cstype)
    case{'geographic'}
        fmt='%11.6f %11.6f\n';
    otherwise
        fmt='%11.1f %11.1f\n';
end

fid=fopen(filename,'wt');

for j=1:npol
    fprintf(fid,'%s\n',['BL' num2str(j,'%0.5i')]);
    fprintf(fid,'%s\n',[num2str(length(xx{j})) ' 2']);
    for i=1:length(xx{j})
        fprintf(fid,fmt,xx{j}(i),yy{j}(i));
    end
end
fclose(fid);

