function ddb_drawGridOutline(src,eventdata)

pan off;
h=findall(gcf,'ToolTipString','Pan');
set(h,'State','off');
h=findall(gcf,'ToolTipString','Zoom In');
set(h,'State','off');
h=findall(gcf,'ToolTipString','Zoom Out');
set(h,'State','off');
zoom off;
plotedit off;

set(gcf, 'windowbuttondownfcn',  {@StartTrack});
set(gcf, 'windowbuttonmotionfcn',{@MoveMouse});
set(gcf,'KeyPressFcn',[]);

%%
function StartTrack(imagefig, varargins) 

set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', {@MoveTrack});
set(gcf, 'windowbuttonupfcn', {@StopTrack});

h=findobj('Tag','MainWindow');
handles=guidata(h);

hold on;

ddb_deleteGridOutline;

pos = get(gca, 'CurrentPoint');

usd.x0=pos(1,1);
usd.y0=pos(1,2);
handles.Toolbox(tb).Input.XOri=usd.x0;
handles.Toolbox(tb).Input.YOri=usd.y0;
handles.Toolbox(tb).Input.nX=0;
handles.Toolbox(tb).Input.nY=0;
handles.Toolbox(tb).Input.dX=str2double(get(handles.EditDX,'String'));
handles.Toolbox(tb).Input.dY=str2double(get(handles.EditDY,'String'));
handles.GUIHandles.GridRotation=0;

set(handles.GUIHandles.EditXOri,'String',num2str(usd.x0));
set(handles.GUIHandles.EditYOri,'String',num2str(usd.y0));
set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
set(handles.GUIHandles.EditRotation,'String',num2str(handles.Toolbox(tb).Input.Rotation));

guidata(h,handles);

ddb_plotGridOutline('g');

set(0,'UserData',usd);

%%
function MoveTrack(imagefig, varargins)

set(gcf, 'windowbuttonupfcn', {@StopTrack});

h=findobj('Tag','MainWindow');
handles=guidata(h);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');

posx=pos(1,1);
posy=pos(1,2);

ddb_deleteGridOutline;

handles.Toolbox(tb).Input.XOri=min(posx,usd.x0);
handles.Toolbox(tb).Input.YOri=min(posy,usd.y0);
handles.Toolbox(tb).Input.nX=round(abs(posx-usd.x0)/handles.Toolbox(tb).Input.dX);
handles.Toolbox(tb).Input.nY=round(abs(posy-usd.y0)/handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.Rotation=0;

set(handles.GUIHandles.EditXOri,'String',num2str(handles.Toolbox(tb).Input.XOri));
set(handles.GUIHandles.EditYOri,'String',num2str(handles.Toolbox(tb).Input.YOri));
set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
set(handles.GUIHandles.EditRotation,'String',num2str(handles.Toolbox(tb).Input.Rotation));

guidata(h,handles);
ddb_plotGridOutline('g');

set(0,'userdata',usd);

ddb_updateCoordinateText('crosshair');

%%
function StopTrack(imagefig, varargins)

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

set(0,'userdata',[]);

%%
function MoveMouse(imagefig, varargins)

ddb_updateCoordinateText('crosshair');
