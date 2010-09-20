function EditSwanGrids

ddb_refreshScreen('Grids');
handles=getHandles;

hp = uipanel('Title','Grids','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.TextComputationalGrids = uicontrol(gcf,'Style','text','string','Computational grids','Position',[40 145 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditComputationalGrids = uicontrol(gcf,'Style','edit','Position',[40 90 200 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditComputationalGrids,'Max',3);
set(handles.EditComputationalGrids,'String',handles.SwanInput(handles.ActiveDomain).ComputationalGrids);
set(handles.EditComputationalGrids,'CallBack',{@EditComputationalGrids_CallBack});

handles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[250 120 70 20],'Tag','UIControl');
set(handles.PushAdd,'Enable','on');
set(handles.PushAdd,'CallBack',{@PushAdd_CallBack});

handles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[250 90 70 20],'Tag','UIControl');
set(handles.PushDelete,'Enable','off');
set(handles.PushDelete,'CallBack',{@PushDelete_CallBack});

handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','string',['Co-ordinate System : '],'Position',[40 70 150 15],'HorizontalAlignment','left','Tag','UIControl');

hp = uipanel('Title','Grid data','Units','pixels','Position',[340 25 655 140],'Tag','UIControl');

strings={'Computational grid','Bathymetry','Spectral resolution','Nesting'};
callbacks={@EditSwanComputationalgrid,@EditSwanBathymetry,@EditSwanSpectralresolution,@EditSwanNesting};
tabpanel(gcf,'tabpanel2','create','position',[350 35 635 90],'strings',strings,'callbacks',callbacks,'width',width);

EditSwanComputationalgrid;

%%
function EditComputationalGrids_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).ComputationalGrids=get(hObject,'String');
setHandles(handles);

%%
function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
handles=Add(handles);
setHandles(handles);

%%
function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
handles=Delete(handles);
setHandles(handles);
