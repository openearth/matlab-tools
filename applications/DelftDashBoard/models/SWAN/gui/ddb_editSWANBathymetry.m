function EditSwanBathymetry

ddb_refreshScreen('Grids','Bathymetry');
handles=getHandles;

handles.TextBathymetryData   = uicontrol(gcf,'Style','text','String','Bathymetry data is based on : ','Position',[360 100 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleCompGrid       = uicontrol(gcf,'Style','radiobutton', 'String','Computational grid','Position',[520 100 130 15],'Tag','UIControl');
handles.ToggleOtherGrid      = uicontrol(gcf,'Style','radiobutton', 'String','Other grid','Position',[520 80 130 15],'Tag','UIControl');
handles.PushEditBathyData    = uicontrol(gcf,'Style','pushbutton', 'String','Select bathymetry data','Position',[360 60 130 15],'Tag','UIControl');
handles.PushEditBathyGrid    = uicontrol(gcf,'Style','pushbutton', 'String','Select bathymetry grid','Position',[360 40 130 15],'Tag','UIControl');
handles.TextBathymetryDep    = uicontrol(gcf,'Style','text','String',['File : ' handles.SwanInput(handles.ActiveDomain).DepFile],'Position',[500 60  160 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextBathyOtherGrid   = uicontrol(gcf,'Style','text','String',['File : ' handles.SwanInput(handles.ActiveDomain).GrdFile],'Position',[500 40  160 15],'HorizontalAlignment','left','Tag','UIControl');

if handles.SwanInput(handles.ActiveDomain).CompGrid
    set(handles.ToggleCompGrid,'Value',1);
    set(handles.PushEditBathyData,'Enable','on');
    set(handles.PushEditBathyGrid,'Enable','off');
elseif handles.SwanInput(handles.ActiveDomain).OtherGrid
    set(handles.ToggleOtherGrid,'Value',1);
    set(handles.PushEditBathyData,'Enable','on');
    set(handles.PushEditBathyGrid,'Enable','on');
else
    set(handles.PushEditBathyData,'Enable','off');
    set(handles.PushEditBathyGrid,'Enable','off');    
end

set(handles.ToggleCompGrid,    'CallBack',{@ToggleCompGrid_CallBack});
set(handles.ToggleOtherGrid,   'CallBack',{@ToggleOtherGrid_CallBack});
set(handles.PushEditBathyData, 'CallBack',{@PushEditBathyData_CallBack});
set(handles.PushEditBathyGrid, 'CallBack',{@PushEditBathyGrid_CallBack});

setHandles(handles);

hp = uipanel('Title','Bathymetry grid specifications','Units','pixels','Position',[670 40 310 80],'Tag','UIControl');

handles.Xorig          = uicontrol(gcf,'Style','text','string',['X origin: '  ' [m]'],'Position',[675 85 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.Yorig          = uicontrol(gcf,'Style','text','string',['Y origin: '  ' [m]'],'Position',[825 85 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.Xgridsize      = uicontrol(gcf,'Style','text','string',['X grid size: '  ' [m]'],'Position',[675 65 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.Ygridsize      = uicontrol(gcf,'Style','text','string',['Y grid size: '  ' [m]'],'Position',[825 65 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.NumberMpts     = uicontrol(gcf,'Style','text','string',['Number of M points: ' ],'Position',[675 45 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.NumberNpts     = uicontrol(gcf,'Style','text','string',['Number of N points: ' ],'Position',[825 45 150 15],'HorizontalAlignment','left','Tag','UIControl');

%%
function ToggleCompGrid_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).CompGrid=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleCompGrid,'Value',1);
    set(handles.ToggleOtherGrid,'Value',0);
    set(handles.PushEditBathyData,'Enable','on');
    set(handles.PushEditBathyGrid,'Enable','off');
    handles.SwanInput(handles.ActiveDomain).OtherGrid=0;
end
setHandles(handles);

%%
function ToggleOtherGrid_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).OtherGrid=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleCompGrid,'Value',0);
    set(handles.ToggleOtherGrid,'Value',1);
    set(handles.PushEditBathyData,'Enable','on');
    set(handles.PushEditBathyGrid,'Enable','on');
    handles.SwanInput(handles.ActiveDomain).CompGrid=0;
end
setHandles(handles);

%%
function PushEditBathyData_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.dep', 'Select Depth File');
[fileid,rest]=strtok(filename,'.');
grid=wlgrid('read',[pathname str2num(fileid)]);
depth=ddb_wldep('read',[pathname filename],grid);
curdir=[lower(cd) '\'];
if ~strcmp(lower(curdir),lower(pathname))
    filename=[pathname filename];
end
handles.SwanInput(handles.ActiveDomain).DepFile=filename;
handles=EditBathyData(handles);
setHandles(handles);

%%
function PushEditBathyGrid_CallBack(hObject,eventdata)
handles=getHandles;
handles=EditBathyGrid(handles);
[filename, pathname, filterindex] = uigetfile('*.grd', 'Select Grid File');
[x,y,enc]=wlgrid('read',[pathname filename]);
curdir=[lower(cd) '\'];
if ~strcmp(lower(curdir),lower(pathname))
    filename=[pathname filename];
end
handles.SwanInput(handles.ActiveDomain).GrdFile=filename;
handles=EditBathyGrid(handles);
setHandles(handles);

