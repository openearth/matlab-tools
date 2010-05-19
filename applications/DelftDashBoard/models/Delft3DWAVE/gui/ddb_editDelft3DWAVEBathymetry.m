function ddb_editDelft3DWAVEBathymetry

ddb_refreshScreen('Grids','Bathymetry');
handles=getHandles;

id=handles.Model(md).Input.ActiveDomain;

hp = uipanel('Title','Grids','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextComputationalGrids = uicontrol(gcf,'Style','text','string','Computational grids :','Position',[40 145 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditComputationalGrids = uicontrol(gcf,'Style','listbox','Position',[40 90 200 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditComputationalGrids,'Max',3);
set(handles.GUIHandles.EditComputationalGrids,'String',handles.Model(md).Input.ComputationalGrids,'Value',id);
set(handles.GUIHandles.EditComputationalGrids,'CallBack',{@EditComputationalGrids_CallBack});

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[250 120 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushAdd,'Enable','off');

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[250 90 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushDelete,'Enable','off');

handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','string',['Co-ordinate System : '],'Position',[40 70 150 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

hp = uipanel('Title','Grid data','Units','pixels','Position',[340 25 655 140],'Tag','UIControl');

handles.GUIHandles.TextBathymetryData   = uicontrol(gcf,'Style','text','String','Bathymetry data is based on : ','Position',[360 100 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleCompGrid       = uicontrol(gcf,'Style','radiobutton', 'String','Computational grid','Position',[520 100 130 15],'Tag','UIControl');
handles.GUIHandles.ToggleOtherGrid      = uicontrol(gcf,'Style','radiobutton', 'String','Other grid','Position',[520 80 130 15],'Tag','UIControl');
handles.GUIHandles.PushEditBathyData    = uicontrol(gcf,'Style','pushbutton', 'String','Select bathymetry data','Position',[360 60 130 15],'Tag','UIControl');
handles.GUIHandles.PushEditBathyGrid    = uicontrol(gcf,'Style','pushbutton', 'String','Select bathymetry grid','Position',[360 40 130 15],'Tag','UIControl');
handles.GUIHandles.TextBathyOtherGrid   = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input.Domain(id).GrdFile],'Position',[500 40  160 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextBathymetryDep    = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input.Domain(id).DepFile],'Position',[500 60  160 15],'HorizontalAlignment','left','Tag','UIControl');

if handles.Model(md).Input.Domain(id).CompGrid
    set(handles.GUIHandles.ToggleCompGrid,'Value',1);
    set(handles.GUIHandles.PushEditBathyData,'Enable','on');
    set(handles.GUIHandles.PushEditBathyGrid,'Enable','off');
elseif handles.Model(md).Input.Domain(id).OtherGrid
    set(handles.GUIHandles.ToggleOtherGrid,'Value',1);
    set(handles.GUIHandles.PushEditBathyData,'Enable','on');
    set(handles.GUIHandles.PushEditBathyGrid,'Enable','on');
else
    set(handles.GUIHandles.PushEditBathyData,'Enable','off');
    set(handles.GUIHandles.PushEditBathyGrid,'Enable','off');    
end

set(handles.GUIHandles.ToggleCompGrid,    'CallBack',{@ToggleCompGrid_CallBack});
set(handles.GUIHandles.ToggleOtherGrid,   'CallBack',{@ToggleOtherGrid_CallBack});
set(handles.GUIHandles.PushEditBathyData, 'CallBack',{@PushEditBathyData_CallBack});
set(handles.GUIHandles.PushEditBathyGrid, 'CallBack',{@PushEditBathyGrid_CallBack});

setHandles(handles);

hp = uipanel('Title','Bathymetry grid specifications','Units','pixels','Position',[670 40 310 80],'Tag','UIControl');

handles.GUIHandles.Xorig          = uicontrol(gcf,'Style','text','string',['X origin: '  ' [m]'],'Position',[675 85 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Yorig          = uicontrol(gcf,'Style','text','string',['Y origin: '  ' [m]'],'Position',[825 85 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Xgridsize      = uicontrol(gcf,'Style','text','string',['X grid size: '  ' [m]'],'Position',[675 65 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Ygridsize      = uicontrol(gcf,'Style','text','string',['Y grid size: '  ' [m]'],'Position',[825 65 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.NumberMpts     = uicontrol(gcf,'Style','text','string',['Number of M points: ' ],'Position',[675 45 150 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.NumberNpts     = uicontrol(gcf,'Style','text','string',['Number of N points: ' ],'Position',[825 45 150 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

Refresh(handles)


%%
function EditComputationalGrids_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ActiveDomain=get(hObject,'Value');
setHandles(handles);
Refresh(handles)

function ToggleCompGrid_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).CompGrid=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleCompGrid,'Value',1);
    set(handles.GUIHandles.ToggleOtherGrid,'Value',0);
    set(handles.GUIHandles.PushEditBathyData,'Enable','on');
    set(handles.GUIHandles.PushEditBathyGrid,'Enable','off');
    handles.Model(md).Input.Domain(id).OtherGrid='';
    pathname=handles.Model(md).Input.Domain(id).PathnameComputationalGrids;
    handles.Model(md).Input.Domain(id).GrdFile=[pathname handles.Model(md).Input.ComputationalGrids{id} '.grd'];
    handles.Model(md).Input.Domain(id).EncFile=[pathname handles.Model(md).Input.ComputationalGrids{id} '.enc'];
    handles.Model(md).Input.Domain(id).CompGrid=[handles.Model(md).Input.ComputationalGrids{id} '.grd'];
    set(handles.GUIHandles.TextBathyOtherGrid,'String',['File : '  handles.Model(md).Input.Domain(id).CompGrid]);
    [x,y,enc]=wlgrid('read',handles.Model(md).Input.Domain(id).GrdFile);
    handles.Model(md).Input.Domain(id).Xorig=x(1);
    handles.Model(md).Input.Domain(id).Yorig=y(1);
    handles.Model(md).Input.Domain(id).Xgridsize=x(end)-x(1);
    handles.Model(md).Input.Domain(id).Ygridsize=y(end)-y(1);
    handles.Model(md).Input.Domain(id).MMax=enc(3,1);
    handles.Model(md).Input.Domain(id).NMax=enc(3,2);
end
setHandles(handles);
Refresh(handles)

function ToggleOtherGrid_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).OtherGrid=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleCompGrid,'Value',0);
    set(handles.GUIHandles.ToggleOtherGrid,'Value',1);
    set(handles.GUIHandles.PushEditBathyData,'Enable','on');
    set(handles.GUIHandles.PushEditBathyGrid,'Enable','on');
    handles.Model(md).Input.Domain(id).CompGrid='';
    handles.Model(md).Input.Domain(id).GrdFile='';
    handles.Model(md).Input.Domain(id).EncFile='';
    handles.Model(md).Input.Domain(id).Xorig='';
    handles.Model(md).Input.Domain(id).Yorig='';
    handles.Model(md).Input.Domain(id).Xgridsize='';
    handles.Model(md).Input.Domain(id).Ygridsize='';
    handles.Model(md).Input.Domain(id).MMax='';
    handles.Model(md).Input.Domain(id).NMax='';
end
setHandles(handles);
Refresh(handles)

function PushEditBathyData_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
[filename, pathname, filterindex] = uigetfile('*.dep', 'Select Depth File');
if pathname~=0
    handles.Model(md).Input.Domain(id).DepFile=[pathname filename];
    handles.Model(md).Input.Domain(id).CompDep=filename;
end
setHandles(handles);
Refresh(handles)

function PushEditBathyGrid_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
[filename, pathname, filterindex] = uigetfile('*.grd', 'Select Grid File');
if pathname~=0
    [x,y,enc]=wlgrid('read',[pathname filename]);
    handles.Model(md).Input.Domain(id).GrdFile=[pathname filename];
    token = strtok(filename,'.');
    handles.Model(md).Input.Domain(id).EncFile=[pathname token '.enc'];
    handles.Model(md).Input.Domain(id).OtherGrid=filename;
    handles.Model(md).Input.Domain(id).Xorig=x(1);
    handles.Model(md).Input.Domain(id).Yorig=y(1);
    handles.Model(md).Input.Domain(id).Xgridsize=x(end)-x(1);
    handles.Model(md).Input.Domain(id).Ygridsize=y(end)-y(1);
    handles.Model(md).Input.Domain(id).MMax=enc(3,1);
    handles.Model(md).Input.Domain(id).NMax=enc(3,2);
end
setHandles(handles);
Refresh(handles)

%%
function Refresh(handles)
handles=getHandles;
if ~isempty(handles.Model(md).Input.ComputationalGrids)
    id=handles.Model(md).Input.ActiveDomain;
    if ~isempty(handles.Model(md).Input.Domain(id).OtherGrid)
        set(handles.GUIHandles.ToggleCompGrid,'Value',0);
        set(handles.GUIHandles.ToggleOtherGrid,'Value',1);
        set(handles.GUIHandles.PushEditBathyData,'Enable','on');
        set(handles.GUIHandles.PushEditBathyGrid,'Enable','on');
        set(handles.GUIHandles.TextBathyOtherGrid,'String',['File : '  handles.Model(md).Input.Domain(id).OtherGrid]);
    elseif ~isempty(handles.Model(md).Input.Domain(id).CompGrid)
        set(handles.GUIHandles.ToggleCompGrid,'Value',1);
        set(handles.GUIHandles.ToggleOtherGrid,'Value',0);
        set(handles.GUIHandles.PushEditBathyData,'Enable','on');
        set(handles.GUIHandles.PushEditBathyGrid,'Enable','off');
        set(handles.GUIHandles.TextBathyOtherGrid,'String',['File : '  handles.Model(md).Input.Domain(id).CompGrid]);
    end
    set(handles.GUIHandles.TextBathymetryDep,'String',['File : '  handles.Model(md).Input.Domain(id).CompDep]);
    set(handles.GUIHandles.Xorig,'string',['X origin: ' num2str(handles.Model(md).Input.Domain(id).Xorig) ' [m]']);
    set(handles.GUIHandles.Yorig,'string',['Y origin: ' num2str(handles.Model(md).Input.Domain(id).Yorig) ' [m]']);
    set(handles.GUIHandles.Xgridsize,'string',['X grid size: ' num2str(handles.Model(md).Input.Domain(id).Xgridsize) ' [m]']);
    set(handles.GUIHandles.Ygridsize,'string',['Y grid size: ' num2str(handles.Model(md).Input.Domain(id).Ygridsize) ' [m]']);
    set(handles.GUIHandles.NumberMpts,'string',['Number of M points: '  num2str(handles.Model(md).Input.Domain(id).MMax)]);
    set(handles.GUIHandles.NumberNpts,'string',['Number of N points: '  num2str(handles.Model(md).Input.Domain(id).NMax)]);
end
setHandles(handles);


