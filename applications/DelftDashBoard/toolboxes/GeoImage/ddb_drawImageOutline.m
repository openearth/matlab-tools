function ddb_drawImageOutline(src,eventdata)

ddb_zoomOff;

set(gcf, 'windowbuttondownfcn',   {@StartTrack});
set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
set(gcf,'KeyPressFcn',[]);
set(gcf, 'Pointer', 'crosshair');

%%
function StartTrack(imagefig, varargins) 

set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', {@MoveTrack});
set(gcf, 'windowbuttonupfcn', {@StopTrack});

handles=getHandles;

hold on;

ddb_deleteImageOutline;

pos = get(gca, 'CurrentPoint');

usd.x0=pos(1,1);
usd.y0=pos(1,2);

handles.Toolbox(tb).Input.XLim(1)=usd.x0;
handles.Toolbox(tb).Input.YLim(1)=usd.y0;
handles.Toolbox(tb).Input.XLim(2)=usd.x0;
handles.Toolbox(tb).Input.YLim(2)=usd.y0;

set(handles.GUIHandles.EditX1,'String',num2str(usd.x0));
set(handles.GUIHandles.EditY1,'String',num2str(usd.y0));
set(handles.GUIHandles.EditX2,'String',num2str(usd.x0));
set(handles.GUIHandles.EditY2,'String',num2str(usd.y0));

setHandles(handles);

ddb_plotImageOutline('g');

set(0,'UserData',usd);

%%
function MoveTrack(imagefig, varargins)

set(gcf, 'windowbuttonupfcn', {@StopTrack});

handles=getHandles;

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');

posx=pos(1,1);
posy=pos(1,2);

ddb_deleteImageOutline;

handles.Toolbox(tb).Input.XLim(1)=min(posx,usd.x0);
handles.Toolbox(tb).Input.YLim(1)=min(posy,usd.y0);
handles.Toolbox(tb).Input.XLim(2)=max(posx,usd.x0);
handles.Toolbox(tb).Input.YLim(2)=max(posy,usd.y0);

set(handles.GUIHandles.EditX1,'String',num2str(handles.Toolbox(tb).Input.XLim(1)));
set(handles.GUIHandles.EditY1,'String',num2str(handles.Toolbox(tb).Input.YLim(1)));
set(handles.GUIHandles.EditX2,'String',num2str(handles.Toolbox(tb).Input.XLim(2)));
set(handles.GUIHandles.EditY2,'String',num2str(handles.Toolbox(tb).Input.YLim(2)));

setHandles(handles);

ddb_plotImageOutline('g');

set(0,'userdata',usd);

ddb_updateCoordinateText('crosshair',@StartTrack);
ddb_refreshZoomLevels(handles);

%%
function StopTrack(imagefig, varargins)

set(gcf, 'windowbuttonmotionfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'Pointer','arrow');
set(gcf, 'Units', 'pixels');

set(0,'userdata',[]);
ddb_updateCoordinateText('arrow',[]);

handles=getHandles;
ddb_refreshZoomLevels(handles);

%%
function MoveMouse(imagefig, varargins)

ddb_updateCoordinateText('crosshair',@StartTrack);
