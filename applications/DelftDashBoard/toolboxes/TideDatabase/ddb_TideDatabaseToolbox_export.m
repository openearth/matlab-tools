function ddb_TideDatabaseToolbox_export(varargin)

handles=getHandles;

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('tidedatabasepanel.export');
    ddb_plotTideDatabase('activate');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'selectmodel'}
            selectModel;
%        case{'selectscale'}
%            selectScale;
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw data outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','TideDatabaseBox','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeTideDatabaseBox,'onstart',@deleteTideDatabaseBox);
        case{'export'}
            exportData;
        case{'editoutline'}
            editOutline;
    end    
end

%%
function changeTideDatabaseBox(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});
handles=getHandles;
handles.Toolbox(tb).Input.tideDatabaseBoxHandle=h;
handles.Toolbox(tb).Input.xLim(1)=x0;
handles.Toolbox(tb).Input.yLim(1)=y0;
handles.Toolbox(tb).Input.xLim(2)=x0+dx;
handles.Toolbox(tb).Input.yLim(2)=y0+dy;
setHandles(handles);
setUIElement('tidedatabasepanel.export.editxmin');
setUIElement('tidedatabasepanel.export.editxmax');
setUIElement('tidedatabasepanel.export.editymin');
setUIElement('tidedatabasepanel.export.editymax');

%%
function selectModel
handles=getHandles;
setHandles(handles);
% setUIElements('tidedatabasepanel.export');

%%
function exportData

handles=getHandles;

wb = waitbox('Exporting tide data ...');pause(0.1);

try
    
    filename=handles.Toolbox(tb).Input.exportFile;
    
    ii=handles.Toolbox(tb).Input.activeModel;
    name=handles.tideModels.model(ii).name;
    
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    xx=handles.Toolbox(tb).Input.xLim;
    yy=handles.Toolbox(tb).Input.yLim;
    
    [lon,lat,ampz,phasez,conList] = readTideModel(tidefile,'type','h','xlim',xx,'ylim',yy,'constituent','all');

    [xg,yg]=meshgrid(lon,lat);
    
    for i=1:length(conList)
        amp{i}=squeeze(ampz(:,:,i));
        phi{i}=squeeze(phasez(:,:,i));
    end
    
    ddb_saveAstroMapFile(filename,xg,yg,conList,amp,phi);
       
    close(wb);
    
catch
    close(wb);
    giveWarning('text','An error occured while generating tide data!');
end

%%
function editOutline
handles=getHandles;
deleteTideDatabaseBox;
x0=handles.Toolbox(tb).Input.xLim(1);
y0=handles.Toolbox(tb).Input.yLim(1);
dx=handles.Toolbox(tb).Input.xLim(2)-x0;
dy=handles.Toolbox(tb).Input.yLim(2)-y0;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeTideDatabaseBox, ...
    'onstart',@deleteTideDatabaseBox,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.Toolbox(tb).Input.tideDatabaseBoxHandle=h;
setHandles(handles);

%%
function deleteTideDatabaseBox
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.tideDatabaseBoxHandle)
    try
        delete(handles.Toolbox(tb).Input.tideDatabaseBoxHandle);
    end
end

